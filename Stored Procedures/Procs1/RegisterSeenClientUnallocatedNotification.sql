-- =============================================
-- Author:		Krishna Panchal	
-- Create date: 05-Aug-2020
-- Description:	Register SeenClient Unallocated Notification
-- =============================================
CREATE PROCEDURE [dbo].[RegisterSeenClientUnallocatedNotification]
    @RegisterSeenClientEmailSMS RegisterSeenClientEmailSMSTableType READONLY
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
    SELECT lgAnswerMasterId,
           SeenClientAnswerChildId,
           lgSeenClientId,
           lgEstablishmentId,
           lgAppUserId,
           EncryptedId,
           lstReoccurring,
           Resend
    FROM @RegisterSeenClientEmailSMS;

    SELECT TOP 1
        @SAnswerMasterId = SeenClientAnswerMasterId
    FROM @TempTable;

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

        DECLARE @Notification NVARCHAR(MAX),
                @DelayTime NVARCHAR(10),
                @TimeOffSet INT = 0,
                @TimeOffSetTender INT = 0,
                @FutureTimeOffSet INT = 0,
                @ScheduleDateTime DATETIME,
                @SeenClientEscalationType INT,
                @UserEmailId NVARCHAR(500),
                @FeedbackOnce BIT,
                @SendCaptureNotirication BIT,
                @CaptureNotificationText NVARCHAR(MAX),
                @CaptureNotificationForAll BIT,
                @SmileType NVARCHAR(10),
                @IsManager BIT,
                @NotificationStatus BIT,
                @UTCTime DATETIME,
                @CaptureNotificationAlert VARCHAR(MAX) = '';


        --END;
        SELECT @UserEmailId = Email,
               @IsManager = IsAreaManager
        FROM dbo.AppUser WITH (NOLOCK)
        WHERE Id = @AppUserId
              AND IsDeleted = 0
              AND IsActive = 1;
        SELECT TOP 1
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
            @FeedbackOnce = E.FeedbackOnce,
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

        SELECT @SmileType = IsPositive
        FROM dbo.SeenClientAnswerMaster WITH (NOLOCK)
        WHERE Id = @SeenClientAnswerMasterId;

        SELECT @TimeOffSet = ISNULL(CAST(Data AS INT), 0) * 60
        FROM dbo.Split(@DelayTime, ':')
        WHERE Id = 1;

        SELECT @TimeOffSet += ISNULL(CAST(Data AS INT), 0)
        FROM dbo.Split(@DelayTime, ':')
        WHERE Id = 2;

        SELECT @Notification = CaptureUnallocatedNotificationAlert
        FROM dbo.GetSeenClientUnallocatedNotificationText(
                                                             @SeenClientAnswerMasterId,
                                                             @EncryptedId,
                                                             @SeenClientAnswerChildId
                                                         );

        SET @UTCTime = GETUTCDATE();
        SET @ScheduleDateTime = DATEADD(MINUTE, @TimeOffSet, @ScheduleDateTime);

        IF (@Notification <> '')
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
        SET @Counter = @Counter + 1;
        CONTINUE;
    END;
    SET NOCOUNT OFF;
END;
