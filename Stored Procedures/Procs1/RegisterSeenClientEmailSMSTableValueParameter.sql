-- =============================================
-- Author:		<Author,,GD>
-- Create date: <Create Date,,26 Jun 2015>
-- Description:	<Description,,>
-- Call SP:		RegisterSeenClientEmailSMS 72979,0,330,1313,313,'A',''
-- =============================================
CREATE PROCEDURE [dbo].[RegisterSeenClientEmailSMSTableValueParameter]
    @RegisterSeenClientEmailSMS RegisterSeenClientEmailSMSTableType READONLY
--   @SeenClientAnswerMasterId BIGINT ,
--   @SeenClientAnswerChildId BIGINT = 0 ,
--   @SeenClientId BIGINT ,
--   @EstablishmentId BIGINT ,
--   @AppUserId BIGINT ,
--   @EncryptedId NVARCHAR(500) ,
--   @RRules NVARCHAR(MAX),
--@Resend bit
AS
BEGIN
    DECLARE @TempTable TABLE
    (
        Id BIGINT IDENTITY(1, 1),
        SeenClientAnswerMasterId BIGINT,
        SeenClientAnswerChildId BIGINT,
        SeenClientId BIGINT,
        EstablishmentId BIGINT,
        AppUserId BIGINT,
        EncryptedId NVARCHAR(500),
        RRules NVARCHAR(MAX),
        Resend BIT
    );

    INSERT INTO @TempTable
    (
        SeenClientAnswerMasterId,
        SeenClientAnswerChildId,
        SeenClientId,
        EstablishmentId,
        AppUserId,
        EncryptedId,
        RRules,
        Resend
    )
    SELECT lgAnswerMasterId,
           SeenClientAnswerChildId,
           lgSeenClientId,
           lgEstablishmentId,
           lgAppUserId,
           EncryptedId,
           lstReoccurring,
           Resend
    FROM @RegisterSeenClientEmailSMS;


    DECLARE @Counter INT,
            @TotalCount INT;
    SET @Counter = 1;
    SET @TotalCount =
    (
        SELECT COUNT(*) FROM @TempTable
    );

    WHILE (@Counter <= @TotalCount)
    BEGIN
        DECLARE @SeenClientAnswerMasterId BIGINT,
                @SeenClientAnswerChildId BIGINT = 0,
                @SeenClientId BIGINT,
                @EstablishmentId BIGINT,
                @AppUserId BIGINT,
                @EncryptedId NVARCHAR(500),
                @RRules NVARCHAR(MAX),
                @Resend BIT;

        SELECT @SeenClientAnswerMasterId = SeenClientAnswerMasterId,
               @SeenClientAnswerChildId = SeenClientAnswerChildId,
               @SeenClientId = SeenClientId,
               @EstablishmentId = EstablishmentId,
               @AppUserId = AppUserId,
               @EncryptedId = EncryptedId,
               @RRules = RRules,
               @Resend = Resend
        FROM @TempTable
        WHERE Id = @Counter;

        DECLARE @SendSMS BIT,
                @SendEmail BIT,
                @SMSText NVARCHAR(MAX),
                @EmailText NVARCHAR(MAX),
                @Notification NVARCHAR(MAX),
                @DelayTime NVARCHAR(10),
                @TimeOffSet INT = 0,
                @FutureTimeOffSet INT = 0,
                @ScheduleDateTime DATETIME,
                @SeenClientEscalationType INT,
                @UserEmailId NVARCHAR(500),
                @FeedbackOnce BIT,
                @EmailSubject NVARCHAR(MAX),
                @SendCaptureSMS BIT,
                @SendCaptureEmail BIT,
                @SendCaptureNotirication BIT,
                @CaptureEmail NVARCHAR(MAX),
                @CaptureEmailSubject NVARCHAR(MAX),
                @CaptureEmailText NVARCHAR(MAX),
                @CaptureSmsText NVARCHAR(MAX),
                @CaptureMobile NVARCHAR(MAX),
                @CaptureNotificationText NVARCHAR(MAX),
                @ManagerEmailId NVARCHAR(MAX),
                @EmailReceiver NVARCHAR(MAX),
                @SMSReceiver NVARCHAR(MAX),
                @CaptureNotificationForAll BIT,
                @SmileType NVARCHAR(10),
                @IsManager BIT,
                @NotificationStatus BIT;

        SELECT @EmailReceiver = COALESCE(@EmailReceiver, '') + Email + ',',
               @SMSReceiver = COALESCE(@SMSReceiver, '') + Mobile + ','
        FROM dbo.AppUser AS U
            INNER JOIN dbo.AppUserEstablishment AS UE
                ON UE.AppUserId = U.Id
                   AND UE.IsDeleted = 0
                   AND U.IsAreaManager = 1
                   AND U.IsActive = 1
            INNER JOIN
            (
                SELECT Data
                FROM dbo.Split(
                     (
                         SELECT dbo.AllUserSelected(@AppUserId, @EstablishmentId, 0)
                     ),
                     ','
                              )
            ) AS ALLUser
                ON ALLUser.Data = U.Id
        WHERE UE.EstablishmentId = @EstablishmentId; --AND UE.NotificationStatus = 1  ---- FOR User Notification trun on then Send ~/by SUNIL
        --END;


        SELECT @UserEmailId = Email,
               @IsManager = IsAreaManager
        FROM dbo.AppUser
        WHERE Id = @AppUserId
              AND IsDeleted = 0
              AND IsActive = 1;



        SELECT TOP 1
            @SendSMS = SendSeenClientSMS,
            @SendEmail = SendSeenClientEmail,
            @DelayTime = CASE
                             WHEN Eg.AllowToChangeDelayTime = 1 THEN
                                 ISNULL(UE.DelayTime, Eg.DelayTime)
                             ELSE
                                 Eg.DelayTime
                         END,
            @FutureTimeOffSet = E.TimeOffSet,
            @ScheduleDateTime
                = CASE E.SeenClientEscalationTime
                      WHEN 1 THEN
                          CASE
                              WHEN (DATEADD(
                                               HOUR,
                                               DATEPART(HOUR, E.SeenClientSchedulerTime),
                                               DATEADD(
                                                          MINUTE,
                                                          DATEPART(MINUTE, E.SeenClientSchedulerTime) - E.TimeOffSet,
                                                          CAST(CAST(GETUTCDATE() AS DATE) AS DATETIME)
                                                      )
                                           )
                                   ) > GETUTCDATE() THEN
            (DATEADD(
                        HOUR,
                        DATEPART(HOUR, E.SeenClientSchedulerTime),
                        DATEADD(
                                   MINUTE,
                                   DATEPART(MINUTE, E.SeenClientSchedulerTime) - E.TimeOffSet,
                                   CAST(CAST(GETUTCDATE() AS DATE) AS DATETIME)
                               )
                    )
            )
                              ELSE
                                  DATEADD(
                                             DAY,
                                             1,
                                             (DATEADD(
                                                         HOUR,
                                                         DATEPART(HOUR, E.SeenClientSchedulerTime),
                                                         DATEADD(
                                                                    MINUTE,
                                                                    DATEPART(MINUTE, E.SeenClientSchedulerTime)
                                                                    - E.TimeOffSet,
                                                                    CAST(CAST(GETUTCDATE() AS DATE) AS DATETIME)
                                                                )
                                                     )
                                             )
                                         )
                          END
                      WHEN 0 THEN
                          dbo.RoundTime(GETUTCDATE(), E.SeenClientSchedulerTimeString)
                      ELSE
                          GETUTCDATE()
                  END,
            --CASE E.SeenClientEscalationTime
            --                                   WHEN 1
            --                                   THEN DATEADD(HOUR,
            --                                                DATEPART(HOUR,
            --                                                   E.SeenClientSchedulerTime),
            --                                                DATEADD(MINUTE,
            --                                                   DATEPART(MINUTE,
            --                                                   E.SeenClientSchedulerTime)
            --                                                   - E.TimeOffSet,
            --                                                   CAST(CAST(GETUTCDATE() AS DATE) AS DATETIME)))
            --                                   WHEN 0
            --                                   THEN dbo.RoundTime(GETUTCDATE(),
            --                                                   E.SeenClientSchedulerTimeString)
            --                                   ELSE GETUTCDATE()
            --                                 END ,
            @FeedbackOnce = E.FeedbackOnce,
            @SendCaptureSMS = E.SendCaptureSMSAlert,
            @SendCaptureEmail = E.SendCaptureEmailAlert,
            @SendCaptureNotirication = E.SendOutNotificationAlertForAll,
            @NotificationStatus = UE.NotificationStatus
        FROM dbo.Establishment AS E
            INNER JOIN dbo.EstablishmentGroup AS Eg
                ON E.EstablishmentGroupId = Eg.Id
            INNER JOIN dbo.AppUserEstablishment AS UE
                ON E.Id = UE.EstablishmentId
        WHERE E.IsDeleted = 0
              AND UE.IsDeleted = 0
              AND AppUserId = @AppUserId
              AND E.Id = @EstablishmentId;
        --AND UE.NotificationStatus = 1  ---- FOR User Notification trun on then Send ~/by SUNIL

        SELECT @SmileType = IsPositive
        FROM dbo.SeenClientAnswerMaster
        WHERE Id = @SeenClientAnswerMasterId;

        SELECT @TimeOffSet = ISNULL(CAST(Data AS INT), 0) * 60
        FROM dbo.Split(@DelayTime, ':')
        WHERE Id = 1;

        SELECT @TimeOffSet += ISNULL(CAST(Data AS INT), 0)
        FROM dbo.Split(@DelayTime, ':')
        WHERE Id = 2;

        SELECT @SMSText = SMSText,
               @EmailText = EmailText,
               @Notification = NotificationText,
               @EmailSubject = EmailSubject,
               @CaptureEmailText = CaptureEmailText,
               @CaptureSmsText = CaptureSmsText,
               @CaptureNotificationText = CaptureNotification,
               @CaptureEmailSubject = CaptureEmailSubject
        FROM dbo.GetSeenClientAutoSMSEmailNotificationText(
                                                              @SeenClientAnswerMasterId,
                                                              @EncryptedId,
                                                              @SeenClientAnswerChildId
                                                          );

        DECLARE @MobileNo NVARCHAR(50),
                @Email NVARCHAR(50);

        IF @SendSMS = 1
           AND @SMSText <> ''
        BEGIN
            SELECT @MobileNo = Detail
            FROM dbo.SeenClientAnswers
            WHERE SeenClientAnswerMasterId = @SeenClientAnswerMasterId
                  AND (ISNULL(SeenClientAnswerChildId, 0) = ISNULL(@SeenClientAnswerChildId, 0))
                  AND IsDeleted = 0
                  AND QuestionTypeId = 11;

            IF @MobileNo <> ''
               AND @MobileNo IS NOT NULL
            BEGIN
                INSERT INTO dbo.PendingSMS
                (
                    ModuleId,
                    MobileNo,
                    SMSText,
                    IsSent,
                    ScheduleDateTime,
                    RefId,
                    CreatedOn,
                    CreatedBy
                )
                VALUES
                (   3,                                               -- ModuleId - bigint
                    @MobileNo,                                       -- MobileNo - nvarchar(1000)
                    @SMSText,                                        -- SMSText - nvarchar(1000)
                    0,                                               -- IsSent - bit
                    DATEADD(MINUTE, @TimeOffSet, @ScheduleDateTime), -- SentDate - datetime
                    @SeenClientAnswerMasterId,                       -- RefId - bigint
                    GETUTCDATE(),                                    -- CreatedOn - datetime
                    @AppUserId                                       -- CreatedBy - bigint
                );
                IF @RRules <> ''
                BEGIN
                    INSERT INTO dbo.PendingSMS
                    (
                        ModuleId,
                        MobileNo,
                        SMSText,
                        IsSent,
                        ScheduleDateTime,
                        RefId,
                        CreatedOn,
                        CreatedBy
                    )
                    SELECT 3,
                           @MobileNo,
                           @SMSText,
                           0,
                           DATEADD(MINUTE, -@FutureTimeOffSet, Data),
                           @SeenClientAnswerMasterId,
                           GETUTCDATE(),
                           @AppUserId
                    FROM dbo.Split(@RRules, ',')
                    WHERE Data <> '';

                    UPDATE dbo.SeenClientAnswerMaster
                    SET IsRecursion = 1
                    WHERE Id = @SeenClientAnswerMasterId;
                END;
            END;
        END;

        IF @SendEmail = 1
           AND @EmailText <> ''
        BEGIN
            SELECT @Email = Detail
            FROM dbo.SeenClientAnswers
            WHERE SeenClientAnswerMasterId = @SeenClientAnswerMasterId
                  AND (ISNULL(SeenClientAnswerChildId, 0) = ISNULL(@SeenClientAnswerChildId, 0))
                  AND IsDeleted = 0
                  AND QuestionTypeId = 10;
            IF @Email <> ''
               AND @Email IS NOT NULL
            BEGIN
                INSERT INTO dbo.PendingEmail
                (
                    ModuleId,
                    EmailId,
                    EmailText,
                    EmailSubject,
                    RefId,
                    Counter,
                    ScheduleDateTime,
                    CreatedBy,
                    ReplyTo
                )
                VALUES
                (   3,                                               -- ModuleId - bigint
                    @Email,                                          -- EmailId - nvarchar(1000)
                    @EmailText,                                      -- EmailText - nvarchar(max)
                    @EmailSubject,
                    @SeenClientAnswerMasterId,                       -- RefId - bigint
                    dbo.EmailBlackListCheck(@Email),
                    DATEADD(MINUTE, @TimeOffSet, @ScheduleDateTime), -- ScheduleDateTime - datetime
                    @AppUserId,                                      -- CreatedBy - bigint
                    @UserEmailId
                );
                IF @RRules <> ''
                BEGIN
                    INSERT INTO dbo.PendingEmail
                    (
                        ModuleId,
                        EmailId,
                        EmailText,
                        EmailSubject,
                        RefId,
                        Counter,
                        ScheduleDateTime,
                        CreatedBy,
                        ReplyTo
                    )
                    SELECT 3,
                           @Email,
                           @EmailText,
                           'Seenclient Form - Recursion',
                           @SeenClientAnswerMasterId,
                           dbo.EmailBlackListCheck(@Email),
                           DATEADD(MINUTE, -@FutureTimeOffSet, Data),
                           @AppUserId,
                           @UserEmailId
                    FROM dbo.Split(@RRules, ',')
                    WHERE Data <> '';

                    UPDATE dbo.SeenClientAnswerMaster
                    SET IsRecursion = 1
                    WHERE Id = @SeenClientAnswerMasterId;
                END;
            END;
        END;

        IF (@Notification <> '') --AND @Resend = 0)
        BEGIN
            IF (@IsManager = 0)
            BEGIN
                INSERT INTO dbo.PendingNotification
                (
                    ModuleId,
                    [Message],
                    TokenId,
                    [Status],
                    SentDate,
                    ScheduleDate,
                    RefId,
                    AppUserId,
                    DeviceType,
                    CreatedBy,
                    AppVersion
                )
                SELECT 3,
                       @Notification,
                       TokenId,
                       0,
                       NULL,
                       GETUTCDATE(),
                       @SeenClientAnswerMasterId,
                       T.AppUserId,
                       DeviceTypeId,
                       @AppUserId,
                       T.AppVersion
                FROM dbo.AppUserEstablishment AS UE
                    INNER JOIN dbo.AppUser AS U
                        ON UE.AppUserId = U.Id
                           AND U.IsDeleted = 0
                           AND U.IsActive = 1
                    INNER JOIN dbo.UserTokenDetails AS T
                        ON UE.AppUserId = T.AppUserId
                    INNER JOIN dbo.Establishment AS E
                        ON UE.EstablishmentId = E.Id
                WHERE UE.IsDeleted = 0
                      AND E.IsDeleted = 0
                      AND E.Id = @EstablishmentId
                      AND UE.NotificationStatus = 1 ---- FOR User Notification trun on then Send ~/by SUNIL
                      AND LEN(TokenId) > 10
                      AND IsAreaManager = 1
                      AND U.Id <> @AppUserId;

                INSERT INTO dbo.PendingNotificationWeb
                (
                    ModuleId,
                    [Message],
                    IsRead,
                    ScheduleDate,
                    RefId,
                    AppUserId,
                    CreatedOn,
                    CreatedBy
                )
                SELECT DISTINCT
                    3,
                    @Notification,
                    0,
                    GETUTCDATE(),
                    @SeenClientAnswerMasterId,
                    UE.AppUserId,
                    GETUTCDATE(),
                    @AppUserId
                FROM dbo.AppUserEstablishment AS UE
                    INNER JOIN dbo.AppUser AS U
                        ON UE.AppUserId = U.Id
                           AND U.IsDeleted = 0
                           AND U.IsActive = 1
                    INNER JOIN dbo.Establishment AS E
                        ON UE.EstablishmentId = E.Id
                WHERE UE.IsDeleted = 0
                      AND E.IsDeleted = 0
                      AND E.Id = @EstablishmentId
                      AND IsAreaManager = 1
                      AND U.Id <> @AppUserId
                      AND UE.NotificationStatus = 1; ---- FOR User Notification trun on then Send ~/by SUNIL
            END;
            ELSE
            BEGIN
                INSERT INTO dbo.PendingNotification
                (
                    ModuleId,
                    [Message],
                    TokenId,
                    [Status],
                    SentDate,
                    ScheduleDate,
                    RefId,
                    AppUserId,
                    DeviceType,
                    CreatedBy,
                    AppVersion
                )
                SELECT 3,
                       @Notification,
                       TokenId,
                       0,
                       NULL,
                       GETUTCDATE(),
                       @SeenClientAnswerMasterId,
                       T.AppUserId,
                       DeviceTypeId,
                       @AppUserId,
                       T.AppVersion
                FROM dbo.AppUserEstablishment AS UE
                    INNER JOIN dbo.AppUser AS U
                        ON UE.AppUserId = U.Id
                           AND U.IsActive = 1
                           AND U.IsDeleted = 0
                    INNER JOIN dbo.UserTokenDetails AS T
                        ON UE.AppUserId = T.AppUserId
                    INNER JOIN dbo.Establishment AS E
                        ON UE.EstablishmentId = E.Id
                    INNER JOIN dbo.AppManagerUserRights AS AM
                        ON AM.ManagerUserId = U.Id
                           AND AM.EstablishmentId = E.Id
                           AND AM.UserId = @AppUserId
                WHERE UE.IsDeleted = 0
                      AND E.IsDeleted = 0
                      AND E.Id = @EstablishmentId
                      AND UE.NotificationStatus = 1 ---- FOR User Notification trun on then Send ~/by VASU
                      AND LEN(TokenId) > 10
                      AND IsAreaManager = 1
                      AND U.Id <> @AppUserId
                      AND AM.IsDeleted = 0;

                INSERT INTO dbo.PendingNotificationWeb
                (
                    ModuleId,
                    [Message],
                    IsRead,
                    ScheduleDate,
                    RefId,
                    AppUserId,
                    CreatedOn,
                    CreatedBy
                )
                SELECT DISTINCT
                    3,
                    @Notification,
                    0,
                    GETUTCDATE(),
                    @SeenClientAnswerMasterId,
                    UE.AppUserId,
                    GETUTCDATE(),
                    @AppUserId
                FROM dbo.AppUserEstablishment AS UE
                    INNER JOIN dbo.AppUser AS U
                        ON UE.AppUserId = U.Id
                           AND U.IsActive = 1
                           AND U.IsDeleted = 0
                    INNER JOIN dbo.Establishment AS E
                        ON UE.EstablishmentId = E.Id
                    INNER JOIN dbo.AppManagerUserRights AS AM
                        ON AM.ManagerUserId = U.Id
                           AND AM.EstablishmentId = E.Id
                           AND AM.UserId = @AppUserId
                WHERE UE.IsDeleted = 0
                      AND E.IsDeleted = 0
                      AND E.Id = @EstablishmentId
                      AND IsAreaManager = 1
                      AND U.Id <> @AppUserId
                      AND AM.IsDeleted = 0
                      AND UE.NotificationStatus = 1; ---- FOR User Notification trun on then Send ~/by VASU
            END;

        END;

        IF (
               @SendEmail = 1
               OR @SendSMS = 1
           )
           AND @FeedbackOnce = 1
        BEGIN


            INSERT INTO dbo.FeedbackOnceHistory
            (
                EstablishmentId,
                AnswerMasterId,
                SeenClientAnswerMasterId,
                IsFeedBackSubmitted,
                SeenclientChildId
            )
            VALUES
            (   @EstablishmentId,          -- EstablishmentId - bigint
                NULL,                      -- AnswerMasterId - bigint
                @SeenClientAnswerMasterId, -- SeenClientAnswerMasterId - bigint
                0,                         -- IsFeedBackSubmitted - bit
                @SeenClientAnswerChildId
            );
        END;
        IF (ISNULL(
            (
                SELECT COUNT(1)
                FROM dbo.PendingEmail
                WHERE RefId = @SeenClientAnswerMasterId
                      AND CAST(ScheduleDateTime AS DATE) = CAST(GETUTCDATE() AS DATE)
                      AND EmailId IN (
                                         SELECT Data FROM dbo.Split(@EmailReceiver, ',')
                                     )
            ),
            0
                  ) = 0
           )
        BEGIN
            IF @SendCaptureEmail = 1
               AND @CaptureEmailText <> ''
            --AND @NotificationStatus = 1
            BEGIN
                IF @EmailReceiver <> ''
                   AND @EmailReceiver IS NOT NULL
                BEGIN
                    INSERT INTO dbo.PendingEmail
                    (
                        ModuleId,
                        EmailId,
                        EmailText,
                        EmailSubject,
                        RefId,
                        Counter,
                        ScheduleDateTime,
                        CreatedBy
                    )
                    SELECT 3,
                           Data,
                           @CaptureEmailText,
                           @CaptureEmailSubject,
                           @SeenClientAnswerMasterId,
                           dbo.EmailBlackListCheck(Data),
                           GETUTCDATE(),
                           @AppUserId
                    FROM dbo.Split(@EmailReceiver, ',')
                    WHERE Data <> ''
                          AND Data IN (
                                          SELECT U.Email
                                          FROM dbo.AppUserEstablishment AS UE
                                              INNER JOIN dbo.AppUser AS U
                                                  ON UE.AppUserId = U.Id
                                                     AND U.IsDeleted = 0
                                                     AND U.IsActive = 1
                                              INNER JOIN dbo.Establishment AS E
                                                  ON UE.EstablishmentId = E.Id
                                          WHERE UE.IsDeleted = 0
                                                AND E.IsDeleted = 0
                                                AND U.IsAreaManager = 1
                                                AND UE.NotificationStatus = 1 ---- FOR User Notification trun on then Send ~/by VASU
                                                AND E.Id = @EstablishmentId
                                      );
                END;
            END;
        END;
        IF @SendCaptureSMS = 1
           AND @CaptureSmsText <> ''
        --AND @NotificationStatus = 1
        BEGIN
            IF @SMSReceiver <> ''
               AND @SMSReceiver IS NOT NULL
            BEGIN
                INSERT INTO dbo.PendingSMS
                (
                    ModuleId,
                    MobileNo,
                    SMSText,
                    IsSent,
                    ScheduleDateTime,
                    RefId,
                    CreatedOn,
                    CreatedBy
                )
                SELECT 3,
                       Data,
                       @CaptureSmsText,
                       0,
                       GETUTCDATE(),
                       @SeenClientAnswerMasterId,
                       GETUTCDATE(),
                       @AppUserId
                FROM dbo.Split(@SMSReceiver, ',')
                WHERE Data <> ''
                      AND Data IN (
                                      SELECT U.Mobile
                                      FROM dbo.AppUserEstablishment AS UE
                                          INNER JOIN dbo.AppUser AS U
                                              ON UE.AppUserId = U.Id
                                                 AND U.IsDeleted = 0
                                                 AND U.IsActive = 1
                                          INNER JOIN dbo.Establishment AS E
                                              ON UE.EstablishmentId = E.Id
                                      WHERE UE.IsDeleted = 0
                                            AND E.IsDeleted = 0
                                            AND U.IsAreaManager = 1
                                            AND UE.NotificationStatus = 1 ---- FOR User Notification trun on then Send ~/by VASU
                                            AND E.Id = @EstablishmentId
                                  );
            END;

        END;

        IF (
               @SmileType = 'Negative'
               OR @SendCaptureNotirication = 1
           )
           AND @CaptureNotificationText <> ''
        --AND @NotificationStatus = 1
        --AND @Resend = 0
        BEGIN
            PRINT '2222';
            DECLARE @count1 BIGINT = 0;
            IF (@SeenClientAnswerChildId > 0)
            BEGIN
                DECLARE @userid1 BIGINT;
                SELECT @userid1 = UE.AppUserId
                FROM dbo.AppUserEstablishment AS UE
                    INNER JOIN dbo.AppUser AS U
                        ON UE.AppUserId = U.Id
                           AND U.IsActive = 1
                           AND U.IsDeleted = 0
                    INNER JOIN dbo.Establishment AS E
                        ON UE.EstablishmentId = E.Id
                WHERE UE.IsDeleted = 0
                      AND E.IsDeleted = 0
                      AND U.IsAreaManager = 1
                      AND E.Id = @EstablishmentId;
                SELECT @count1 = COUNT(*)
                FROM dbo.PendingNotificationWeb
                WHERE AppUserId IN (
                                       SELECT UE.AppUserId
                                       FROM dbo.AppUserEstablishment AS UE
                                           INNER JOIN dbo.AppUser AS U
                                               ON UE.AppUserId = U.Id
                                                  AND U.IsDeleted = 0
                                                  AND U.IsActive = 1
                                           INNER JOIN dbo.Establishment AS E
                                               ON UE.EstablishmentId = E.Id
                                       WHERE UE.IsDeleted = 0
                                             AND E.IsDeleted = 0
                                             AND U.IsAreaManager = 1
                                             AND UE.NotificationStatus = 1 ---- FOR User Notification trun on then Send ~/by VASU
                                             AND E.Id = @EstablishmentId
                                   )
                      AND RefId = @SeenClientAnswerMasterId;

                SELECT @count1;
            END;
            ELSE
            BEGIN
                SELECT @count1;
            END;
            IF (@count1 < 1)
            BEGIN
                IF (@IsManager = 0)
                BEGIN
                    INSERT INTO dbo.PendingNotification
                    (
                        ModuleId,
                        [Message],
                        TokenId,
                        [Status],
                        SentDate,
                        ScheduleDate,
                        RefId,
                        AppUserId,
                        DeviceType,
                        CreatedBy,
                        AppVersion
                    )
                    SELECT 3,
                           @CaptureNotificationText,
                           TokenId,
                           0,
                           NULL,
                           GETUTCDATE(),
                           @SeenClientAnswerMasterId,
                           T.AppUserId,
                           DeviceTypeId,
                           @AppUserId,
                           T.AppVersion
                    FROM dbo.AppUserEstablishment AS UE
                        INNER JOIN dbo.UserTokenDetails AS T
                            ON UE.AppUserId = T.AppUserId
                        INNER JOIN dbo.AppUser AS U
                            ON UE.AppUserId = U.Id
                               AND U.IsActive = 1
                               AND U.IsDeleted = 0
                        INNER JOIN dbo.Establishment AS E
                            ON UE.EstablishmentId = E.Id
                    WHERE UE.IsDeleted = 0
                          AND E.IsDeleted = 0
                          AND E.Id = @EstablishmentId
                          AND UE.NotificationStatus = 1 ---- FOR User Notification trun on then Send ~/by VASU
                          AND U.IsAreaManager = 1
                          AND LEN(TokenId) > 10;

                    INSERT INTO dbo.PendingNotificationWeb
                    (
                        ModuleId,
                        [Message],
                        IsRead,
                        ScheduleDate,
                        RefId,
                        AppUserId,
                        CreatedOn,
                        CreatedBy
                    )
                    SELECT DISTINCT
                        3,
                        @CaptureNotificationText,
                        0,
                        GETUTCDATE(),
                        @SeenClientAnswerMasterId,
                        UE.AppUserId,
                        GETUTCDATE(),
                        @AppUserId
                    FROM dbo.AppUserEstablishment AS UE
                        INNER JOIN dbo.AppUser AS U
                            ON UE.AppUserId = U.Id
                               AND U.IsActive = 1
                               AND U.IsDeleted = 0
                        INNER JOIN dbo.Establishment AS E
                            ON UE.EstablishmentId = E.Id
                    WHERE UE.IsDeleted = 0
                          AND E.IsDeleted = 0
                          AND U.IsAreaManager = 1
                          AND UE.NotificationStatus = 1 ---- FOR User Notification trun on then Send ~/by VASU
                          AND E.Id = @EstablishmentId;
                END;
                ELSE
                BEGIN
                    PRINT 123;
                    INSERT INTO dbo.PendingNotification
                    (
                        ModuleId,
                        [Message],
                        TokenId,
                        [Status],
                        SentDate,
                        ScheduleDate,
                        RefId,
                        AppUserId,
                        DeviceType,
                        CreatedBy,
                        AppVersion
                    )
                    SELECT 3,
                           @CaptureNotificationText,
                           TokenId,
                           0,
                           NULL,
                           GETUTCDATE(),
                           @SeenClientAnswerMasterId,
                           T.AppUserId,
                           DeviceTypeId,
                           @AppUserId,
                           T.AppVersion
                    FROM dbo.AppUserEstablishment AS UE
                        INNER JOIN dbo.UserTokenDetails AS T
                            ON UE.AppUserId = T.AppUserId
                        INNER JOIN dbo.AppUser AS U
                            ON UE.AppUserId = U.Id
                               AND U.IsActive = 1
                               AND U.IsDeleted = 0
                        INNER JOIN dbo.Establishment AS E
                            ON UE.EstablishmentId = E.Id
                        INNER JOIN dbo.AppManagerUserRights AS AM
                            ON AM.EstablishmentId = E.Id
                               AND AM.UserId = T.AppUserId
                               AND AM.ManagerUserId = @AppUserId
                    WHERE UE.IsDeleted = 0
                          AND E.IsDeleted = 0
                          AND E.Id = @EstablishmentId
                          AND UE.NotificationStatus = 1 ---- FOR User Notification trun on then Send ~/by VASU
                          AND U.IsAreaManager = 1
                          AND LEN(TokenId) > 10
                          AND U.Id <> @AppUserId
                          AND AM.IsDeleted = 0;

                    INSERT INTO dbo.PendingNotificationWeb
                    (
                        ModuleId,
                        [Message],
                        IsRead,
                        ScheduleDate,
                        RefId,
                        AppUserId,
                        CreatedOn,
                        CreatedBy
                    )
                    SELECT DISTINCT
                        3,
                        @CaptureNotificationText,
                        0,
                        GETUTCDATE(),
                        @SeenClientAnswerMasterId,
                        UE.AppUserId,
                        GETUTCDATE(),
                        @AppUserId
                    FROM dbo.AppUserEstablishment AS UE
                        INNER JOIN dbo.AppUser AS U
                            ON UE.AppUserId = U.Id
                               AND U.IsActive = 1
                               AND U.IsDeleted = 0
                        INNER JOIN dbo.Establishment AS E
                            ON UE.EstablishmentId = E.Id
                        INNER JOIN dbo.AppManagerUserRights AS AM
                            ON AM.EstablishmentId = E.Id
                               AND AM.UserId = UE.AppUserId
                               AND AM.ManagerUserId = @AppUserId
                    WHERE UE.IsDeleted = 0
                          AND E.IsDeleted = 0
                          AND U.IsAreaManager = 1
                          AND E.Id = @EstablishmentId
                          AND U.Id <> @AppUserId
                          AND AM.IsDeleted = 0
                          AND UE.NotificationStatus = 1; ---- FOR User Notification trun on then Send ~/by VASU
                END;
            END;
        END;
        SET @Counter = @Counter + 1;
        CONTINUE;
    END;

END;
