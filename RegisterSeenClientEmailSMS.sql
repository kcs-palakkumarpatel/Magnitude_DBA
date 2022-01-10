-- =============================================
-- Author:		<Author,,GD>
-- Create date: <Create Date,,26 Jun 2015>
-- Description:	<Description,,>
-- Call SP:RegisterSeenClientEmailSMS '<ClsAnswers><row><lgAnswerMasterId>984537</lgAnswerMasterId><SeenClientAnswerChildId /><lgSeenClientId>605</lgSeenClientId><lgEstablishmentId>11572</lgEstablishmentId><lgAppUserId>1246</lgAppUserId><EncryptedId>x3zNAfGfmAo1</EncryptedId><lstReoccurring /><Resend>false</Resend></row></ClsAnswers>'
-- =============================================
CREATE PROCEDURE [dbo].[RegisterSeenClientEmailSMS] @RegisterSeenClientEmailSMS XML
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
    SET NOCOUNT ON;
    DECLARE @SAnswerMasterId BIGINT;
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
    SELECT SeenClientAnswerMasterId = XTbl.XCol.value('(lgAnswerMasterId)[1]', 'varchar(25)'),
           SeenClientAnswerChildId = XTbl.XCol.value('(SeenClientAnswerChildId)[1]', 'varchar(100)'),
           SeenClientId = XTbl.XCol.value('(lgSeenClientId)[1]', 'varchar(100)'),
           EstablishmentId = XTbl.XCol.value('(lgEstablishmentId)[1]', 'varchar(100)'),
           AppUserId = XTbl.XCol.value('(lgAppUserId)[1]', 'varchar(100)'),
           EncryptedId = XTbl.XCol.value('(EncryptedId)[1]', 'NVARCHAR(MAX)'),
           RRules = XTbl.XCol.value('(lstReoccurring)[1]', 'NVARCHAR(MAX) '),
           Resend = XTbl.XCol.value('(Resend)[1]', 'bit')
    FROM @RegisterSeenClientEmailSMS.nodes('/ClsAnswers/row') AS XTbl(XCol);
    DECLARE @EmailReceiverTable TABLE
    (
        Id BIGINT IDENTITY(1, 1),
        EmailReceiver Nvarchar(MAX)
    );
    SELECT TOP 1
        @SAnswerMasterId = SeenClientAnswerMasterId
    FROM @TempTable;

    EXEC dbo.CalculatePerformanceIndex @ReportId = @SAnswerMasterId, -- bigint
                                       @IsOut = 1;                   -- bit

    EXEC dbo.SeenclientandFeedbackIspositiveUpdate @AnswerMasterId = @SAnswerMasterId, -- bigint
                                                   @Isout = 1;                         -- bit



    DECLARE @Counter INT,
            @TotalCount INT;
    SET @Counter = 1;
    SET @TotalCount =
    (
        SELECT COUNT(1) FROM @TempTable
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
                @TimeOffSetTender INT = 0,
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
                @NotificationStatus BIT,
                @UTCTime DATETIME,
                @TenderReminderDate DATETIME = '',
                @CaptureNotificationAlert VARCHAR(MAX) = '',
                @TenderDate DATETIME = '';

        SELECT TOP 1
            @TenderDate = ISNULL(SCA.Detail, '')
        FROM dbo.SeenClientAnswers SCA WITH (NOLOCK)
            INNER JOIN dbo.SeenClientQuestions SCQ WITH (NOLOCK)
                ON SCQ.Id = SCA.QuestionId
        WHERE SCA.SeenClientAnswerMasterId = @SeenClientAnswerMasterId
              AND SCA.QuestionTypeId = 22
              AND ISNULL(SCQ.TenderQuestionType, 0) = 1;

        SELECT TOP 1
            @TenderReminderDate = ISNULL(SCA.Detail, '')
        FROM dbo.SeenClientAnswers SCA WITH (NOLOCK)
            INNER JOIN dbo.SeenClientQuestions SCQ WITH (NOLOCK)
                ON SCQ.Id = SCA.QuestionId
        WHERE SCA.SeenClientAnswerMasterId = @SeenClientAnswerMasterId
              AND SCA.QuestionTypeId = 22
              AND ISNULL(SCQ.TenderQuestionType, 0) = 4;


        SELECT @EmailReceiver = COALESCE(@EmailReceiver, '') + Email + N',',
               @SMSReceiver = COALESCE(@SMSReceiver, '') + Mobile + N','
        FROM dbo.AppUser AS U WITH (NOLOCK)
            INNER JOIN dbo.AppUserEstablishment AS UE WITH (NOLOCK)
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
        DELETE FROM @EmailReceiverTable;

        INSERT INTO @EmailReceiverTable
        (
            EmailReceiver
        )
        SELECT Email
        FROM dbo.AppUser AS U WITH (NOLOCK)
            INNER JOIN dbo.AppUserEstablishment AS UE WITH (NOLOCK)
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
        WHERE UE.EstablishmentId = @EstablishmentId;
        --END;
        SELECT @UserEmailId = Email,
               @IsManager = IsAreaManager
        FROM dbo.AppUser WITH (NOLOCK)
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
                = (CASE E.SeenClientEscalationTime
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
                   END
                  ),
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
            @NotificationStatus = UE.NotificationStatus,
            @TimeOffSetTender = E.TimeOffSet
        FROM dbo.Establishment AS E WITH (NOLOCK)
            INNER JOIN dbo.EstablishmentGroup AS Eg WITH (NOLOCK)
                ON E.EstablishmentGroupId = Eg.Id
            INNER JOIN dbo.AppUserEstablishment AS UE WITH (NOLOCK)
                ON E.Id = UE.EstablishmentId
        WHERE E.IsDeleted = 0
              AND UE.IsDeleted = 0
              AND AppUserId = @AppUserId
              AND E.Id = @EstablishmentId;
        --AND UE.NotificationStatus = 1  ---- FOR User Notification trun on then Send ~/by SUNIL

        SELECT @SmileType = IsPositive
        FROM dbo.SeenClientAnswerMaster WITH (NOLOCK)
        WHERE Id = @SeenClientAnswerMasterId;

        SELECT @TimeOffSet = ISNULL(CAST(Data AS INT), 0) * 60
        FROM dbo.Split(@DelayTime, ':')
        WHERE Id = 1;

        SELECT @TimeOffSet += ISNULL(CAST(Data AS INT), 0)
        FROM dbo.Split(@DelayTime, ':')
        WHERE Id = 2;

        SELECT @SMSText = SMSText,
               @EmailText = REPLACE(EmailText, '$$?', '$$'),
               @Notification = NotificationText,
               @EmailSubject = EmailSubject,
               @CaptureEmailText = CaptureEmailText,
               @CaptureSmsText = CaptureSmsText,
               @CaptureNotificationText = CaptureNotification,
               @CaptureEmailSubject = CaptureEmailSubject,
               @CaptureNotificationAlert = CaptureReminderAlert
        FROM dbo.GetSeenClientAutoSMSEmailNotificationText(
                                                              @SeenClientAnswerMasterId,
                                                              @EncryptedId,
                                                              @SeenClientAnswerChildId
                                                          );
        IF (@TenderDate <> '' AND @TenderDate IS NOT NULL)
        BEGIN
            SET @UTCTime = DATEADD(MINUTE, -@TimeOffSetTender, @TenderDate);
            SET @ScheduleDateTime = DATEADD(MINUTE, -@TimeOffSetTender, @TenderDate);
        END;
        ELSE
        BEGIN
            SET @UTCTime = GETUTCDATE();
            SET @ScheduleDateTime = DATEADD(MINUTE, @TimeOffSet, @ScheduleDateTime);
        END;

        DECLARE @MobileNo NVARCHAR(50),
                @Email NVARCHAR(50);

        IF (@CaptureNotificationAlert = '')
        BEGIN
            SET @CaptureNotificationAlert = @CaptureNotificationText;
        END;

        IF (@TenderReminderDate <> '' AND @TenderReminderDate IS NOT NULL)
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
                AppVersion,
                CreatedOn
            )
            SELECT 3,
                   @CaptureNotificationAlert,
                   TokenId,
                   0,
                   NULL,
                   DATEADD(MINUTE, -@TimeOffSetTender, @TenderReminderDate),
                   @SeenClientAnswerMasterId,
                   T.AppUserId,
                   DeviceTypeId,
                   @AppUserId,
                   T.AppVersion,
                   DATEADD(MINUTE, -@TimeOffSetTender, @TenderReminderDate)
            FROM dbo.AppUserEstablishment AS UE WITH (NOLOCK)
                INNER JOIN dbo.AppUser AS U WITH (NOLOCK)
                    ON UE.AppUserId = U.Id
                       AND U.IsDeleted = 0
                       AND U.IsActive = 1
                INNER JOIN dbo.UserTokenDetails AS T WITH (NOLOCK)
                    ON UE.AppUserId = T.AppUserId
                INNER JOIN dbo.Establishment AS E WITH (NOLOCK)
                    ON UE.EstablishmentId = E.Id
            WHERE UE.IsDeleted = 0
                  AND E.IsDeleted = 0
                  AND E.Id = @EstablishmentId
                  AND UE.NotificationStatus = 1 ---- FOR User Notification trun on then Send ~/by SUNIL
                  AND LEN(TokenId) > 10
                  AND IsAreaManager = 1
                  AND U.Id <> @AppUserId
            UNION
            SELECT 3,
                   @CaptureNotificationAlert,
                   TokenId,
                   0,
                   NULL,
                   DATEADD(MINUTE, -@TimeOffSetTender, @TenderReminderDate),
                   @SeenClientAnswerMasterId,
                   AU.Id,
                   DeviceTypeId,
                   @AppUserId,
                   T.AppVersion,
                   DATEADD(MINUTE, -@TimeOffSetTender, @TenderReminderDate)
            FROM dbo.AppUser AU WITH (NOLOCK)
                INNER JOIN dbo.ContactDetails CD WITH (NOLOCK)
                    ON CD.Detail = AU.Email
                       AND CD.QuestionTypeId = 10
                       AND CD.ContactMasterId IN (
                                                     SELECT ISNULL(ContactMasterId, 0)
                                                     FROM dbo.SeenClientAnswerMaster
                                                     WHERE Id = @SeenClientAnswerMasterId
                                                 )
                       AND ISNULL(AU.IsDeleted, 0) = 0
                       AND ISNULL(CD.IsDeleted, 0) = 0
                INNER JOIN dbo.UserTokenDetails AS T WITH (NOLOCK)
                    ON AU.Id = T.AppUserId
            WHERE LEN(TokenId) > 10
                  AND AU.Id <> @AppUserId;


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
                @CaptureNotificationAlert,
                0,
                DATEADD(MINUTE, -@TimeOffSetTender, @TenderReminderDate),
                @SeenClientAnswerMasterId,
                UE.AppUserId,
                DATEADD(MINUTE, -@TimeOffSetTender, @TenderReminderDate),
                @AppUserId
            FROM dbo.AppUserEstablishment AS UE WITH (NOLOCK)
                INNER JOIN dbo.AppUser AS U WITH (NOLOCK)
                    ON UE.AppUserId = U.Id
                       AND U.IsDeleted = 0
                       AND U.IsActive = 1
                INNER JOIN dbo.Establishment AS E WITH (NOLOCK)
                    ON UE.EstablishmentId = E.Id
            WHERE UE.IsDeleted = 0
                  AND E.IsDeleted = 0
                  AND E.Id = @EstablishmentId
                  AND IsAreaManager = 1
                  AND U.Id <> @AppUserId
                  AND UE.NotificationStatus = 1
            UNION
            SELECT DISTINCT
                3,
                @CaptureNotificationAlert,
                0,
                DATEADD(MINUTE, -@TimeOffSetTender, @TenderReminderDate),
                @SeenClientAnswerMasterId,
                AU.Id,
                DATEADD(MINUTE, -@TimeOffSetTender, @TenderReminderDate),
                @AppUserId
            FROM dbo.AppUser AU WITH (NOLOCK)
                INNER JOIN dbo.ContactDetails CD WITH (NOLOCK)
                    ON CD.Detail = AU.Email
                       AND CD.QuestionTypeId = 10
                       AND CD.ContactMasterId IN (
                                                     SELECT ISNULL(ContactMasterId, 0)
                                                     FROM dbo.SeenClientAnswerMaster
                                                     WHERE Id = @SeenClientAnswerMasterId
                                                 )
                       AND ISNULL(AU.IsDeleted, 0) = 0
                       AND ISNULL(CD.IsDeleted, 0) = 0
            WHERE AU.Id <> @AppUserId;
        END;

        IF @SendSMS = 1
           AND @SMSText <> ''
        BEGIN
            SELECT @MobileNo = Detail
            FROM dbo.SeenClientAnswers WITH (NOLOCK)
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
                (   3,                         -- ModuleId - bigint
                    @MobileNo,                 -- MobileNo - nvarchar(1000)
                    @SMSText,                  -- SMSText - nvarchar(1000)
                    0,                         -- IsSent - bit
                    @ScheduleDateTime,         -- SentDate - datetime
                    @SeenClientAnswerMasterId, -- RefId - bigint
                    GETUTCDATE(),              -- CreatedOn - datetime
                    @AppUserId                 -- CreatedBy - bigint
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
                        CreatedBy,
                        IsRecursion
                    )
                    SELECT 3,
                           @MobileNo,
                           @SMSText,
                           0,
                           DATEADD(MINUTE, -@FutureTimeOffSet, Data),
                           @SeenClientAnswerMasterId,
                           GETUTCDATE(),
                           @AppUserId,
                           1
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
            FROM dbo.SeenClientAnswers WITH (NOLOCK)
            WHERE SeenClientAnswerMasterId = @SeenClientAnswerMasterId
                  AND (ISNULL(SeenClientAnswerChildId, 0) = ISNULL(@SeenClientAnswerChildId, 0))
                  AND IsDeleted = 0
                  AND QuestionTypeId = 10;
            IF @Email <> ''
               AND @Email IS NOT NULL
               AND LOWER(@Email) NOT IN (
                                            SELECT LOWER(EmailId) FROM dbo.BlackListEmail WHERE IsDeleted = 0
                                        )
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
                (   3,                         -- ModuleId - bigint
                    @Email,                    -- EmailId - nvarchar(1000)
                    @EmailText,                -- EmailText - nvarchar(max)
                    @EmailSubject,
                    @SeenClientAnswerMasterId, -- RefId - bigint
                    0,                         --dbo.EmailBlackListCheck(@Email),
                    @ScheduleDateTime,         -- ScheduleDateTime - datetime
                    @AppUserId,                -- CreatedBy - bigint
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
                        ReplyTo,
                        IsRecursion
                    )
                    SELECT 3,
                           @Email,
                           @EmailText,
                           @EmailSubject, --'Seenclient Form - Recursion',
                           @SeenClientAnswerMasterId,
                           0,             --dbo.EmailBlackListCheck(@Email),
                           DATEADD(MINUTE, -@FutureTimeOffSet, Data),
                           @AppUserId,
                           @UserEmailId,
                           1
                    FROM dbo.Split(@RRules, ',')
                    WHERE Data <> ''
                          AND Data NOT IN (
                                              SELECT EmailId FROM dbo.BlackListEmail WHERE IsDeleted = 0
                                          );

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
                       @UTCTime,
                       @SeenClientAnswerMasterId,
                       T.AppUserId,
                       DeviceTypeId,
                       @AppUserId,
                       T.AppVersion
                FROM dbo.AppUserEstablishment AS UE WITH (NOLOCK)
                    INNER JOIN dbo.AppUser AS U WITH (NOLOCK)
                        ON UE.AppUserId = U.Id
                           AND U.IsDeleted = 0
                           AND U.IsActive = 1
                    INNER JOIN dbo.UserTokenDetails AS T WITH (NOLOCK)
                        ON UE.AppUserId = T.AppUserId
                    INNER JOIN dbo.Establishment AS E WITH (NOLOCK)
                        ON UE.EstablishmentId = E.Id
                WHERE UE.IsDeleted = 0
                      AND E.IsDeleted = 0
                      AND E.Id = @EstablishmentId
                      AND UE.NotificationStatus = 1 ---- FOR User Notification trun on then Send ~/by SUNIL
                      AND LEN(TokenId) > 10
                      AND IsAreaManager = 1
                      AND U.Id <> @AppUserId
                UNION
                SELECT 3,
                       @Notification,
                       TokenId,
                       0,
                       NULL,
                       @UTCTime,
                       @SeenClientAnswerMasterId,
                       AU.Id,
                       DeviceTypeId,
                       @AppUserId,
                       T.AppVersion
                FROM dbo.AppUser AU WITH (NOLOCK)
                    INNER JOIN dbo.ContactDetails CD WITH (NOLOCK)
                        ON CD.Detail = AU.Email
                           AND CD.QuestionTypeId = 10
                           AND CD.ContactMasterId IN (
                                                         SELECT ISNULL(ContactMasterId, 0)
                                                         FROM dbo.SeenClientAnswerMaster
                                                         WHERE Id = @SeenClientAnswerMasterId
                                                     )
                           AND ISNULL(AU.IsDeleted, 0) = 0
                           AND ISNULL(CD.IsDeleted, 0) = 0
                    INNER JOIN dbo.UserTokenDetails AS T WITH (NOLOCK)
                        ON AU.Id = T.AppUserId
                WHERE LEN(TokenId) > 10
                      AND AU.Id <> @AppUserId;

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
                    @UTCTime,
                    @SeenClientAnswerMasterId,
                    UE.AppUserId,
                    @UTCTime,
                    @AppUserId
                FROM dbo.AppUserEstablishment AS UE WITH (NOLOCK)
                    INNER JOIN dbo.AppUser AS U WITH (NOLOCK)
                        ON UE.AppUserId = U.Id
                           AND U.IsDeleted = 0
                           AND U.IsActive = 1
                    INNER JOIN dbo.Establishment AS E WITH (NOLOCK)
                        ON UE.EstablishmentId = E.Id
                WHERE UE.IsDeleted = 0
                      AND E.IsDeleted = 0
                      AND E.Id = @EstablishmentId
                      AND IsAreaManager = 1
                      AND U.Id <> @AppUserId
                      AND UE.NotificationStatus = 1 ---- FOR User Notification trun on then Send ~/by SUNIL
                UNION
                SELECT DISTINCT
                    3,
                    @Notification,
                    0,
                    @UTCTime,
                    @SeenClientAnswerMasterId,
                    AU.Id,
                    @UTCTime,
                    @AppUserId
                FROM dbo.AppUser AU WITH (NOLOCK)
                    INNER JOIN dbo.ContactDetails CD WITH (NOLOCK)
                        ON CD.Detail = AU.Email
                           AND CD.QuestionTypeId = 10
                           AND CD.ContactMasterId IN (
                                                         SELECT ISNULL(ContactMasterId, 0)
                                                         FROM dbo.SeenClientAnswerMaster
                                                         WHERE Id = @SeenClientAnswerMasterId
                                                     )
                           AND ISNULL(AU.IsDeleted, 0) = 0
                           AND ISNULL(CD.IsDeleted, 0) = 0
                WHERE AU.Id <> @AppUserId;
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
                       @UTCTime,
                       @SeenClientAnswerMasterId,
                       T.AppUserId,
                       DeviceTypeId,
                       @AppUserId,
                       T.AppVersion
                FROM dbo.AppUserEstablishment AS UE WITH (NOLOCK)
                    INNER JOIN dbo.AppUser AS U WITH (NOLOCK)
                        ON UE.AppUserId = U.Id
                           AND U.IsActive = 1
                           AND U.IsDeleted = 0
                    INNER JOIN dbo.UserTokenDetails AS T WITH (NOLOCK)
                        ON UE.AppUserId = T.AppUserId
                    INNER JOIN dbo.Establishment AS E WITH (NOLOCK)
                        ON UE.EstablishmentId = E.Id
                    INNER JOIN dbo.AppManagerUserRights AS AM WITH (NOLOCK)
                        --commented by mittal
                        --ON AM.ManagerUserId = U.Id
                        --   AND AM.EstablishmentId = E.Id
                        --   AND AM.UserId = @AppUserId
                        ON AM.UserId = U.Id
                           AND AM.EstablishmentId = E.Id
                           AND AM.ManagerUserId = @AppUserId
                WHERE UE.IsDeleted = 0
                      AND E.IsDeleted = 0
                      AND E.Id = @EstablishmentId
                      AND UE.NotificationStatus = 1 ---- FOR User Notification trun on then Send ~/by VASU
                      AND LEN(TokenId) > 10
                      AND IsAreaManager = 1
                      AND U.Id <> @AppUserId
                      AND AM.IsDeleted = 0
					  UNION
                SELECT 3,
                       @Notification,
                       TokenId,
                       0,
                       NULL,
                       @UTCTime,
                       @SeenClientAnswerMasterId,
                       AU.Id,
                       DeviceTypeId,
                       @AppUserId,
                       T.AppVersion
                FROM dbo.AppUser AU WITH (NOLOCK)
                    INNER JOIN dbo.ContactDetails CD WITH (NOLOCK)
                        ON CD.Detail = AU.Email
                           AND CD.QuestionTypeId = 10
                           AND CD.ContactMasterId IN (
                                                         SELECT ISNULL(ContactMasterId, 0)
                                                         FROM dbo.SeenClientAnswerMaster
                                                         WHERE Id = @SeenClientAnswerMasterId
                                                     )
                           AND ISNULL(AU.IsDeleted, 0) = 0
                           AND ISNULL(CD.IsDeleted, 0) = 0
                    INNER JOIN dbo.UserTokenDetails AS T WITH (NOLOCK)
                        ON AU.Id = T.AppUserId
                WHERE LEN(TokenId) > 10
                      AND AU.Id <> @AppUserId;

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
                    @UTCTime,
                    @SeenClientAnswerMasterId,
                    UE.AppUserId,
                    @UTCTime,
                    @AppUserId
                FROM dbo.AppUserEstablishment AS UE WITH (NOLOCK)
                    INNER JOIN dbo.AppUser AS U WITH (NOLOCK)
                        ON UE.AppUserId = U.Id
                           AND U.IsActive = 1
                           AND U.IsDeleted = 0
                    INNER JOIN dbo.Establishment AS E WITH (NOLOCK)
                        ON UE.EstablishmentId = E.Id
                    INNER JOIN dbo.AppManagerUserRights AS AM WITH (NOLOCK)
                        --commented by mittal
                        --ON AM.ManagerUserId = U.Id
                        --   AND AM.EstablishmentId = E.Id
                        --   AND AM.UserId = @AppUserId
                        ON AM.UserId = U.Id
                           AND AM.EstablishmentId = E.Id
                           AND AM.ManagerUserId = @AppUserId
                WHERE UE.IsDeleted = 0
                      AND E.IsDeleted = 0
                      AND E.Id = @EstablishmentId
                      AND IsAreaManager = 1
                      AND U.Id <> @AppUserId
                      AND AM.IsDeleted = 0
                      AND UE.NotificationStatus = 1 ---- FOR User Notification trun on then Send ~/by VASU
                UNION
                SELECT DISTINCT
                    3,
                    @Notification,
                    0,
                    @UTCTime,
                    @SeenClientAnswerMasterId,
                    AU.Id,
                    @UTCTime,
                    @AppUserId
                FROM dbo.AppUser AU WITH (NOLOCK)
                    INNER JOIN dbo.ContactDetails CD WITH (NOLOCK)
                        ON CD.Detail = AU.Email
                           AND CD.QuestionTypeId = 10
                           AND CD.ContactMasterId IN (
                                                         SELECT ISNULL(ContactMasterId, 0)
                                                         FROM dbo.SeenClientAnswerMaster
                                                         WHERE Id = @SeenClientAnswerMasterId
                                                     )
                           AND ISNULL(AU.IsDeleted, 0) = 0
                           AND ISNULL(CD.IsDeleted, 0) = 0
                WHERE AU.Id <> @AppUserId;
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
                FROM dbo.PendingEmail WITH (NOLOCK)
                WHERE RefId = @SeenClientAnswerMasterId
                      AND CAST(ScheduleDateTime AS DATE) = CAST(GETUTCDATE() AS DATE)
                      AND EmailId IN (
                                         SELECT EmailReceiver FROM @EmailReceiverTable
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
                           EmailReceiver,
                           @CaptureEmailText,
                           @CaptureEmailSubject,
                           @SeenClientAnswerMasterId,
                           0, --dbo.EmailBlackListCheck(Data),
                           @UTCTime,
                           @AppUserId
                    FROM @EmailReceiverTable
                    WHERE EmailReceiver <> ''
                          AND EmailReceiver NOT IN (
                                                       SELECT EmailId FROM dbo.BlackListEmail WHERE IsDeleted = 0
                                                   )
                          AND EmailReceiver IN (
                                                   SELECT U.Email
                                                   FROM dbo.AppUserEstablishment AS UE WITH (NOLOCK)
                                                       INNER JOIN dbo.AppUser AS U WITH (NOLOCK)
                                                           ON UE.AppUserId = U.Id
                                                              AND U.IsDeleted = 0
                                                              AND U.IsActive = 1
                                                       INNER JOIN dbo.Establishment AS E WITH (NOLOCK)
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
                       @UTCTime,
                       @SeenClientAnswerMasterId,
                       GETUTCDATE(),
                       @AppUserId
                FROM dbo.Split(@SMSReceiver, ',')
                WHERE Data <> ''
                      AND Data IN (
                                      SELECT U.Mobile
                                      FROM dbo.AppUserEstablishment AS UE WITH (NOLOCK)
                                          INNER JOIN dbo.AppUser AS U WITH (NOLOCK)
                                              ON UE.AppUserId = U.Id
                                                 AND U.IsDeleted = 0
                                                 AND U.IsActive = 1
                                          INNER JOIN dbo.Establishment AS E WITH (NOLOCK)
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
                FROM dbo.AppUserEstablishment AS UE WITH (NOLOCK)
                    INNER JOIN dbo.AppUser AS U WITH (NOLOCK)
                        ON UE.AppUserId = U.Id
                           AND U.IsActive = 1
                           AND U.IsDeleted = 0
                    INNER JOIN dbo.Establishment AS E WITH (NOLOCK)
                        ON UE.EstablishmentId = E.Id
                WHERE UE.IsDeleted = 0
                      AND E.IsDeleted = 0
                      AND U.IsAreaManager = 1
                      AND E.Id = @EstablishmentId;
                SELECT @count1 = COUNT(1)
                FROM dbo.PendingNotificationWeb WITH (NOLOCK)
                WHERE AppUserId IN (
                                       SELECT UE.AppUserId
                                       FROM dbo.AppUserEstablishment AS UE WITH (NOLOCK)
                                           INNER JOIN dbo.AppUser AS U WITH (NOLOCK)
                                               ON UE.AppUserId = U.Id
                                                  AND U.IsDeleted = 0
                                                  AND U.IsActive = 1
                                           INNER JOIN dbo.Establishment AS E WITH (NOLOCK)
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
                           @UTCTime,
                           @SeenClientAnswerMasterId,
                           T.AppUserId,
                           DeviceTypeId,
                           @AppUserId,
                           T.AppVersion
                    FROM dbo.AppUserEstablishment AS UE WITH (NOLOCK)
                        INNER JOIN dbo.UserTokenDetails AS T WITH (NOLOCK)
                            ON UE.AppUserId = T.AppUserId
                        INNER JOIN dbo.AppUser AS U WITH (NOLOCK)
                            ON UE.AppUserId = U.Id
                               AND U.IsActive = 1
                               AND U.IsDeleted = 0
                        INNER JOIN dbo.Establishment AS E WITH (NOLOCK)
                            ON UE.EstablishmentId = E.Id
                    WHERE UE.IsDeleted = 0
                          AND E.IsDeleted = 0
                          AND E.Id = @EstablishmentId
                          AND UE.NotificationStatus = 1 ---- FOR User Notification trun on then Send ~/by VASU
                          AND U.IsAreaManager = 1
                          AND LEN(TokenId) > 10
						  UNION
                    SELECT 3,
                           @CaptureNotificationText,
                           TokenId,
                           0,
                           NULL,
                           @UTCTime,
                           @SeenClientAnswerMasterId,
                           AU.Id,
                           DeviceTypeId,
                           @AppUserId,
                           T.AppVersion
                    FROM dbo.AppUser AU WITH (NOLOCK)
                        INNER JOIN dbo.ContactDetails CD WITH (NOLOCK)
                            ON CD.Detail = AU.Email
                               AND CD.QuestionTypeId = 10
                               AND CD.ContactMasterId IN (
                                                             SELECT ISNULL(ContactMasterId, 0)
                                                             FROM dbo.SeenClientAnswerMaster
                                                             WHERE Id = @SeenClientAnswerMasterId
                                                         )
                               AND ISNULL(AU.IsDeleted, 0) = 0
                               AND ISNULL(CD.IsDeleted, 0) = 0
                        INNER JOIN dbo.UserTokenDetails AS T WITH (NOLOCK)
                            ON AU.Id = T.AppUserId
                    WHERE LEN(TokenId) > 10
                          AND AU.Id <> @AppUserId;

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
                        @UTCTime,
                        @SeenClientAnswerMasterId,
                        UE.AppUserId,
                        @UTCTime,
                        @AppUserId
                    FROM dbo.AppUserEstablishment AS UE WITH (NOLOCK)
                        INNER JOIN dbo.AppUser AS U WITH (NOLOCK)
                            ON UE.AppUserId = U.Id
                               AND U.IsActive = 1
                               AND U.IsDeleted = 0
                        INNER JOIN dbo.Establishment AS E WITH (NOLOCK)
                            ON UE.EstablishmentId = E.Id
                    WHERE UE.IsDeleted = 0
                          AND E.IsDeleted = 0
                          AND U.IsAreaManager = 1
                          AND UE.NotificationStatus = 1 ---- FOR User Notification trun on then Send ~/by VASU
                          AND E.Id = @EstablishmentId
                    UNION
                    SELECT DISTINCT
                        3,
                        @CaptureNotificationText,
                        0,
                        @UTCTime,
                        @SeenClientAnswerMasterId,
                        AU.Id,
                        @UTCTime,
                        @AppUserId
                    FROM dbo.AppUser AU WITH (NOLOCK)
                        INNER JOIN dbo.ContactDetails CD WITH (NOLOCK)
                            ON CD.Detail = AU.Email
                               AND CD.QuestionTypeId = 10
                               AND CD.ContactMasterId IN (
                                                             SELECT ISNULL(ContactMasterId, 0)
                                                             FROM dbo.SeenClientAnswerMaster
                                                             WHERE Id = @SeenClientAnswerMasterId
                                                         )
                               AND ISNULL(AU.IsDeleted, 0) = 0
                               AND ISNULL(CD.IsDeleted, 0) = 0
                    WHERE AU.Id <> @AppUserId;
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
                           @UTCTime,
                           @SeenClientAnswerMasterId,
                           T.AppUserId,
                           DeviceTypeId,
                           @AppUserId,
                           T.AppVersion
                    FROM dbo.AppUserEstablishment AS UE WITH (NOLOCK)
                        INNER JOIN dbo.UserTokenDetails AS T WITH (NOLOCK)
                            ON UE.AppUserId = T.AppUserId
                        INNER JOIN dbo.AppUser AS U WITH (NOLOCK)
                            ON UE.AppUserId = U.Id
                               AND U.IsActive = 1
                               AND U.IsDeleted = 0
                        INNER JOIN dbo.Establishment AS E WITH (NOLOCK)
                            ON UE.EstablishmentId = E.Id
                        INNER JOIN dbo.AppManagerUserRights AS AM WITH (NOLOCK)
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
                          AND AM.IsDeleted = 0
						  UNION
                    SELECT 3,
                           @CaptureNotificationText,
                           TokenId,
                           0,
                           NULL,
                           @UTCTime,
                           @SeenClientAnswerMasterId,
                           AU.Id,
                           DeviceTypeId,
                           @AppUserId,
                           T.AppVersion
                    FROM dbo.AppUser AU WITH (NOLOCK)
                        INNER JOIN dbo.ContactDetails CD WITH (NOLOCK)
                            ON CD.Detail = AU.Email
                               AND CD.QuestionTypeId = 10
                               AND CD.ContactMasterId IN (
                                                             SELECT ISNULL(ContactMasterId, 0)
                                                             FROM dbo.SeenClientAnswerMaster
                                                             WHERE Id = @SeenClientAnswerMasterId
                                                         )
                               AND ISNULL(AU.IsDeleted, 0) = 0
                               AND ISNULL(CD.IsDeleted, 0) = 0
                        INNER JOIN dbo.UserTokenDetails AS T WITH (NOLOCK)
                            ON AU.Id = T.AppUserId
                    WHERE LEN(TokenId) > 10
                          AND AU.Id <> @AppUserId;

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
                        @UTCTime,
                        @SeenClientAnswerMasterId,
                        UE.AppUserId,
                        @UTCTime,
                        @AppUserId
                    FROM dbo.AppUserEstablishment AS UE WITH (NOLOCK)
                        INNER JOIN dbo.AppUser AS U WITH (NOLOCK)
                            ON UE.AppUserId = U.Id
                               AND U.IsActive = 1
                               AND U.IsDeleted = 0
                        INNER JOIN dbo.Establishment AS E WITH (NOLOCK)
                            ON UE.EstablishmentId = E.Id
                        INNER JOIN dbo.AppManagerUserRights AS AM WITH (NOLOCK)
                            ON AM.EstablishmentId = E.Id
                               AND AM.UserId = UE.AppUserId
                               AND AM.ManagerUserId = @AppUserId
                    WHERE UE.IsDeleted = 0
                          AND E.IsDeleted = 0
                          AND U.IsAreaManager = 1
                          AND E.Id = @EstablishmentId
                          AND U.Id <> @AppUserId
                          AND AM.IsDeleted = 0
                          AND UE.NotificationStatus = 1 ---- FOR User Notification trun on then Send ~/by VASU
                    UNION
                    SELECT DISTINCT
                        3,
                        @CaptureNotificationText,
                        0,
                        @UTCTime,
                        @SeenClientAnswerMasterId,
                        AU.Id,
                        @UTCTime,
                        @AppUserId
                    FROM dbo.AppUser AU WITH (NOLOCK)
                        INNER JOIN dbo.ContactDetails CD WITH (NOLOCK)
                            ON CD.Detail = AU.Email
                               AND CD.QuestionTypeId = 10
                               AND CD.ContactMasterId IN (
                                                             SELECT ISNULL(ContactMasterId, 0)
                                                             FROM dbo.SeenClientAnswerMaster
                                                             WHERE Id = @SeenClientAnswerMasterId
                                                         )
                               AND ISNULL(AU.IsDeleted, 0) = 0
                               AND ISNULL(CD.IsDeleted, 0) = 0
                    WHERE AU.Id <> @AppUserId;
                END;
            END;
        END;
        SET @Counter = @Counter + 1;
        CONTINUE;
    END;

    --FOR Additional trigger START by ANANT 
    DECLARE @SeenClientAnswerMasterIdSeenClient BIGINT,
            @SeenClientAnswerChildIdSeenClient BIGINT = 0,
            @SeenClientIdSeenClient BIGINT,
            @EstablishmentIdSeenClient BIGINT,
            @AppUserIdSeenClient BIGINT,
            @EncryptedIdSeenClient NVARCHAR(500),
            @RRulesSeenClient NVARCHAR(MAX),
            @ResendSeenClient BIT,
            @IsAddtionalCaptureEmail BIT,
            @IsAddtionalCaptureSMS BIT,
            @IsEmail BIT,
            @IsSMS BIT;
    SELECT TOP 1
        @SeenClientAnswerMasterIdSeenClient = SeenClientAnswerMasterId,
        @SeenClientAnswerChildIdSeenClient = SeenClientAnswerChildId,
        @SeenClientIdSeenClient = SeenClientId,
        @EstablishmentIdSeenClient = EstablishmentId,
        @AppUserIdSeenClient = AppUserId,
        @EncryptedIdSeenClient = EncryptedId,
        @RRulesSeenClient = RRules,
        @ResendSeenClient = Resend
    FROM @TempTable;
    SET @IsEmail =
    (
        SELECT ISAdditionalCaptureEmail
        FROM dbo.Establishment WITH (NOLOCK)
        WHERE Id = @EstablishmentId
    );
    SET @IsSMS =
    (
        SELECT ISAdditionalCaptureSMS
        FROM dbo.Establishment WITH (NOLOCK)
        WHERE Id = @EstablishmentId
    );
    PRINT @IsEmail;
    PRINT @IsSMS;
    IF (@IsEmail = 1 OR @IsSMS = 1)
    BEGIN
        PRINT 3;
        EXEC dbo.AdditionalRegisterSeenClientEmailSMS @SeenClientAnswerMasterIdSeenClient, -- bigint
                                                      @SeenClientAnswerChildIdSeenClient,  -- bigint
                                                      @SeenClientIdSeenClient,             -- bigint
                                                      @EstablishmentIdSeenClient,          -- bigint
                                                      @AppUserIdSeenClient,                -- bigint
                                                      @EncryptedIdSeenClient,              -- nvarchar(500)
                                                      @RRulesSeenClient,                   -- nvarchar(max)
                                                      @ResendSeenClient;                   -- bit
    END;

    --FOR Additional trigger END by ANANT 
    SET NOCOUNT OFF;
END;

