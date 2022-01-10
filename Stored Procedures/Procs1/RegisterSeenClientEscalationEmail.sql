-- =============================================
-- Author:		<Author,,GD>
-- Create date: <Create Date,,02 Sep 2015>
-- Description:	<Description,,>
-- Call:	RegisterSeenClientEscalationEmail
-- =============================================
CREATE PROCEDURE dbo.RegisterSeenClientEscalationEmail
AS
BEGIN
    SET DEADLOCK_PRIORITY NORMAL;

    BEGIN TRY
        DECLARE @ResultSet TABLE
        (
            Id BIGINT IDENTITY(1, 1),
            AnswerMasterId BIGINT,
            EstablishmentId BIGINT,
            QuestionnaireId BIGINT,
            AppUserId BIGINT,
            DateCreated DATETIME,
            EscalationEmailAddress NVARCHAR(MAX),
            EscalationMobileNumber NVARCHAR(MAX),
            EstablishmentName NVARCHAR(500),
            Answerstatus NVARCHAR(50),
            ScheduleTime DATETIME,
            TimeOffSet INT,
            AppUserName NVARCHAR(500),
            [PI] BIGINT,
            ThemeId NVARCHAR(10),
            EmailSubject NVARCHAR(500),
            AppUserMobile NVARCHAR(50),
            AppUserEmail NVARCHAR(50),
            SeenClientAnswerMasterId BIGINT,
            InEscalationOnce BIT,
            OutEscalationOnce BIT,
            ScheduledTime INT,
            ActivityName NVARCHAR(500),
            ActivityID BIGINT
        );
        --------- For Feedback -------
        INSERT INTO @ResultSet
        (
            AnswerMasterId,
            EstablishmentId,
            QuestionnaireId,
            AppUserId,
            DateCreated,
            EscalationEmailAddress,
            EscalationMobileNumber,
            EstablishmentName,
            Answerstatus,
            ScheduleTime,
            TimeOffSet,
            AppUserName,
            [PI],
            ThemeId,
            EmailSubject,
            AppUserMobile,
            AppUserEmail,
            SeenClientAnswerMasterId,
            InEscalationOnce,
            OutEscalationOnce,
            ScheduledTime,
            ActivityName,
            ActivityID
        )
        SELECT Am.Id,
               Am.EstablishmentId,
               Am.QuestionnaireId,
               Am.AppUserId,
               Am.CreatedOn,
               E.EscalationEmails,
               E.EscalationMobile,
               E.EstablishmentName,
               Am.IsResolved,
               DATEADD(
                          MINUTE,
                          dbo.ConvertTimeIntervalStringToMinute(E.EscalationSchedulerTimeString),
                          ISNULL(Am.EscalationSendDate, GETUTCDATE())
                      ),
               E.TimeOffSet,
               U.Name,
               ROUND(Am.PI, 0),
               G.ThemeId,
               E.EscalationEmailSubject,
               U.Mobile,
               U.Email,
               0,
               E.InEscalationOnce,
               E.OutEscalationOnce,
               dbo.ConvertTimeIntervalStringToMinute(E.EscalationSchedulerTimeString),
               EG.EstablishmentGroupName,
               EG.Id
        FROM dbo.AnswerMaster AS Am
            INNER JOIN dbo.Establishment AS E
                ON E.Id = Am.EstablishmentId
            INNER JOIN dbo.[Group] AS G
                ON G.Id = E.GroupId
            LEFT OUTER JOIN dbo.AppUser AS U
                ON Am.AppUserId = U.Id
            INNER JOIN dbo.AppUserEstablishment AUE
                ON AUE.AppUserId = Am.AppUserId
                   AND AUE.EstablishmentId = Am.EstablishmentId
                   AND AUE.IsDeleted = 0
                   AND AUE.NotificationStatus = 1
            INNER JOIN dbo.EstablishmentGroup EG
                ON EG.Id = E.EstablishmentGroupId
        WHERE IsResolved = 'Unresolved'
              --AND SeenClientAnswerMasterId > 0
              AND Am.IsDeleted = 0
              AND E.EscalationTime = 0
              AND (
                      EscalationSendDate IS NULL
                      OR DATEDIFF(MINUTE, Am.EscalationSendDate, GETUTCDATE()) > dbo.ConvertTimeIntervalStringToMinute(E.EscalationSchedulerTimeString)
                  )
              AND ISNULL(Am.EscalationSendDate, GETUTCDATE())
              BETWEEN (GETUTCDATE() - 1) AND GETUTCDATE();

        INSERT INTO @ResultSet
        (
            AnswerMasterId,
            EstablishmentId,
            QuestionnaireId,
            AppUserId,
            DateCreated,
            EscalationEmailAddress,
            EscalationMobileNumber,
            EstablishmentName,
            Answerstatus,
            ScheduleTime,
            TimeOffSet,
            AppUserName,
            [PI],
            ThemeId,
            EmailSubject,
            AppUserMobile,
            AppUserEmail,
            SeenClientAnswerMasterId,
            InEscalationOnce,
            OutEscalationOnce,
            ScheduledTime,
            ActivityName,
            ActivityID
        )
        SELECT Am.Id,
               Am.EstablishmentId,
               Am.QuestionnaireId,
               Am.AppUserId,
               Am.CreatedOn,
               E.EscalationEmails,
               E.EscalationMobile,
               E.EstablishmentName,
               Am.IsResolved,
               ----DATEADD(HOUR,
               ----        DATEPART(HOUR, E.SeenClientSchedulerTime),
               ----        DATEADD(MINUTE,
               ----                DATEPART(MINUTE,
               ----                         E.SeenClientSchedulerTime)
               ----                - E.TimeOffSet,
               ----                CAST(CAST(GETUTCDATE() AS DATE) AS DATETIME))) ,
               DATEADD(
                          HOUR,
                          DATEPART(HOUR, E.EscalationSchedulerTime),
                          DATEADD(
                                     MINUTE,
                                     DATEPART(MINUTE, E.EscalationSchedulerTime) - E.TimeOffSet,
                                     CAST(CAST(GETUTCDATE() AS DATE) AS DATETIME)
                                 )
                      ),
               Am.TimeOffSet,
               U.Name,
               ROUND(Am.PI, 0),
               G.ThemeId,
               E.EscalationEmailSubject,
               U.Mobile,
               U.Email,
               0,
               E.InEscalationOnce,
               E.OutEscalationOnce,
               dbo.ConvertTimeIntervalStringToMinute(E.EscalationSchedulerTime),
               EG.EstablishmentGroupName,
               EG.Id
        FROM dbo.AnswerMaster AS Am
            INNER JOIN dbo.Establishment AS E
                ON E.Id = Am.EstablishmentId
            INNER JOIN dbo.[Group] AS G
                ON G.Id = E.GroupId
            LEFT OUTER JOIN dbo.AppUser AS U
                ON Am.AppUserId = U.Id
            INNER JOIN dbo.AppUserEstablishment AUE
                ON AUE.AppUserId = Am.AppUserId
                   AND AUE.EstablishmentId = Am.EstablishmentId
                   AND AUE.IsDeleted = 0
                   AND AUE.NotificationStatus = 1
            INNER JOIN dbo.EstablishmentGroup EG
                ON EG.Id = E.EstablishmentGroupId
        WHERE IsResolved = 'Unresolved'
              --AND SeenClientAnswerMasterId > 0
              AND Am.IsDeleted = 0
              AND E.EscalationTime = 1
              AND CAST(GETUTCDATE() AS TIME) > CAST(DATEADD(MINUTE, -Am.TimeOffSet, E.EscalationSchedulerTime) AS TIME)
              AND (
                      CAST(Am.EscalationSendDate AS DATE) <> CAST(GETUTCDATE() AS DATE)
                      OR Am.EscalationSendDate IS NULL
                  )
              AND ISNULL(Am.EscalationSendDate, GETUTCDATE())
              BETWEEN (GETUTCDATE() - 1) AND GETUTCDATE();

        INSERT INTO @ResultSet
        (
            AnswerMasterId,
            am.EstablishmentId,
            QuestionnaireId,
            AppUserId,
            DateCreated,
            EscalationEmailAddress,
            EscalationMobileNumber,
            EstablishmentName,
            Answerstatus,
            ScheduleTime,
            TimeOffSet,
            AppUserName,
            [PI],
            ThemeId,
            EmailSubject,
            AppUserMobile,
            AppUserEmail,
            SeenClientAnswerMasterId,
            InEscalationOnce,
            OutEscalationOnce,
            ScheduledTime,
            ActivityName,
            ActivityID
        )
        SELECT Am.Id,
               Am.EstablishmentId,
               Am.QuestionnaireId,
               Am.AppUserId,
               Am.CreatedOn,
               E.EscalationEmails,
               E.EscalationMobile,
               E.EstablishmentName,
               Am.IsResolved,
               GETUTCDATE(),
               Am.TimeOffSet,
               U.Name,
               ROUND(Am.PI, 0),
               G.ThemeId,
               E.EscalationEmailSubject,
               U.Mobile,
               U.Email,
               0,
               E.InEscalationOnce,
               E.OutEscalationOnce,
               dbo.ConvertTimeIntervalStringToMinute(E.EscalationSchedulerTime),
               EG.EstablishmentGroupName,
               EG.Id
        FROM dbo.AnswerMaster AS Am
            INNER JOIN dbo.Establishment AS E
                ON E.Id = Am.EstablishmentId
            INNER JOIN dbo.[Group] AS G
                ON G.Id = E.GroupId
            LEFT OUTER JOIN dbo.AppUser AS U
                ON Am.AppUserId = U.Id
            INNER JOIN dbo.AppUserEstablishment AUE
                ON AUE.AppUserId = Am.AppUserId
                   AND AUE.EstablishmentId = Am.EstablishmentId
                   AND AUE.IsDeleted = 0
                   AND AUE.NotificationStatus = 1
            INNER JOIN dbo.EstablishmentGroup EG
                ON EG.Id = E.EstablishmentGroupId
        WHERE IsResolved = 'Unresolved'
              --AND SeenClientAnswerMasterId > 0
              AND Am.IsDeleted = 0
              AND E.EscalationTime = 2
              AND CAST(GETUTCDATE() AS TIME) > CAST(DATEADD(MINUTE, -Am.TimeOffSet, E.EscalationSchedulerTime) AS TIME)
              AND (
                      CAST(Am.EscalationSendDate AS DATE) <> CAST(GETUTCDATE() AS DATE)
                      OR Am.EscalationSendDate IS NULL
                  )
              AND DATENAME(WEEKDAY, DATEADD(MINUTE, -Am.TimeOffSet, GETUTCDATE())) = E.EscalationSchedulerDay
              AND ISNULL(Am.EscalationSendDate, GETUTCDATE())
              BETWEEN (GETUTCDATE() - 1) AND GETUTCDATE();

        --------- For Feedback -------

        --------- For Capture -------
        INSERT INTO @ResultSet
        (
            AnswerMasterId,
            EstablishmentId,
            QuestionnaireId,
            AppUserId,
            DateCreated,
            EscalationEmailAddress,
            EscalationMobileNumber,
            EstablishmentName,
            Answerstatus,
            ScheduleTime,
            TimeOffSet,
            AppUserName,
            [PI],
            ThemeId,
            EmailSubject,
            AppUserMobile,
            AppUserEmail,
            SeenClientAnswerMasterId,
            InEscalationOnce,
            OutEscalationOnce,
            ScheduledTime,
            ActivityName,
            ActivityID
        )
        SELECT 0,
               Am.EstablishmentId,
               Am.SeenClientId,
               Am.AppUserId,
               Am.CreatedOn,
               E.OutEscalationEmails,
               E.OutEscalationMobile,
               E.EstablishmentName,
               Am.IsResolved,
               DATEADD(
                          MINUTE,
                          dbo.ConvertTimeIntervalStringToMinute(E.OutEscalationSchedulerTimeString),
                          ISNULL(Am.EscalationSendDate, GETUTCDATE())
                      ),
               E.TimeOffSet,
               U.Name,
               ROUND(Am.PI, 0),
               G.ThemeId,
               E.OutEscalationEmailSubject,
               U.Mobile,
               U.Email,
               Am.Id,
               E.InEscalationOnce,
               E.OutEscalationOnce,
               dbo.ConvertTimeIntervalStringToMinute(E.OutEscalationSchedulerTimeString),
               EG.EstablishmentGroupName,
               EG.Id
        FROM dbo.SeenClientAnswerMaster AS Am
            INNER JOIN dbo.Establishment AS E
                ON E.Id = Am.EstablishmentId
            INNER JOIN dbo.[Group] AS G
                ON G.Id = E.GroupId
            LEFT OUTER JOIN dbo.AppUser AS U
                ON Am.AppUserId = U.Id
            INNER JOIN dbo.AppUserEstablishment AUE
                ON AUE.AppUserId = Am.AppUserId
                   AND AUE.EstablishmentId = Am.EstablishmentId
                   AND AUE.IsDeleted = 0
                   AND AUE.NotificationStatus = 1
            INNER JOIN dbo.EstablishmentGroup EG
                ON EG.Id = E.EstablishmentGroupId
        WHERE IsResolved = 'Unresolved'
              --AND SeenClientAnswerMasterId > 0
              AND Am.IsDeleted = 0
              AND E.OutEscalationTime = 0
              AND EscalationSendDate IS NULL
              AND (
                      EscalationSendDate IS NULL
                      OR DATEDIFF(MINUTE, Am.EscalationSendDate, GETUTCDATE()) > dbo.ConvertTimeIntervalStringToMinute(E.OutEscalationSchedulerTimeString)
                  )
              AND ISNULL(Am.EscalationSendDate, GETUTCDATE())
              BETWEEN (GETUTCDATE() - 1) AND GETUTCDATE();

        INSERT INTO @ResultSet
        (
            AnswerMasterId,
            EstablishmentId,
            QuestionnaireId,
            AppUserId,
            DateCreated,
            EscalationEmailAddress,
            EscalationMobileNumber,
            EstablishmentName,
            Answerstatus,
            ScheduleTime,
            TimeOffSet,
            AppUserName,
            [PI],
            ThemeId,
            EmailSubject,
            AppUserMobile,
            AppUserEmail,
            SeenClientAnswerMasterId,
            InEscalationOnce,
            OutEscalationOnce,
            ScheduledTime,
            ActivityName,
            ActivityID
        )
        SELECT 0,
               Am.EstablishmentId,
               Am.SeenClientId,
               Am.AppUserId,
               Am.CreatedOn,
               E.OutEscalationEmails,
               E.OutEscalationMobile,
               E.EstablishmentName,
               Am.IsResolved,
               ----DATEADD(HOUR,
               ----        DATEPART(HOUR, E.SeenClientSchedulerTime),
               ----        DATEADD(MINUTE,
               ----                DATEPART(MINUTE,
               ----                         E.SeenClientSchedulerTime)
               ----                - E.TimeOffSet,
               ----                CAST(CAST(GETUTCDATE() AS DATE) AS DATETIME))) ,
               DATEADD(
                          HOUR,
                          DATEPART(HOUR, E.OutEscalationSchedulerTime),
                          DATEADD(
                                     MINUTE,
                                     DATEPART(MINUTE, E.OutEscalationSchedulerTime) - E.TimeOffSet,
                                     CAST(CAST(GETUTCDATE() AS DATE) AS DATETIME)
                                 )
                      ),
               Am.TimeOffSet,
               U.Name,
               ROUND(Am.PI, 0),
               G.ThemeId,
               E.OutEscalationEmailSubject,
               U.Mobile,
               U.Email,
               Am.Id,
               E.InEscalationOnce,
               E.OutEscalationOnce,
               dbo.ConvertTimeIntervalStringToMinute(E.OutEscalationSchedulerTime),
               EG.EstablishmentGroupName,
               EG.Id
        FROM dbo.SeenClientAnswerMaster AS Am
            INNER JOIN dbo.Establishment AS E
                ON E.Id = Am.EstablishmentId
            INNER JOIN dbo.[Group] AS G
                ON G.Id = E.GroupId
            LEFT OUTER JOIN dbo.AppUser AS U
                ON Am.AppUserId = U.Id
            INNER JOIN dbo.AppUserEstablishment AUE
                ON AUE.AppUserId = Am.AppUserId
                   AND AUE.EstablishmentId = Am.EstablishmentId
                   AND AUE.IsDeleted = 0
                   AND AUE.NotificationStatus = 1
            INNER JOIN dbo.EstablishmentGroup EG
                ON EG.Id = E.EstablishmentGroupId
        WHERE IsResolved = 'Unresolved'
              --AND SeenClientAnswerMasterId > 0
              AND Am.IsDeleted = 0
              AND E.OutEscalationTime = 1
              AND CAST(GETUTCDATE() AS TIME) > CAST(DATEADD(MINUTE, -Am.TimeOffSet, E.OutEscalationSchedulerTime) AS TIME)
              AND (
                      CAST(Am.EscalationSendDate AS DATE) <> CAST(GETUTCDATE() AS DATE)
                      OR EscalationSendDate IS NULL
                  )
              AND ISNULL(Am.EscalationSendDate, GETUTCDATE())
              BETWEEN (GETUTCDATE() - 1) AND GETUTCDATE();

        INSERT INTO @ResultSet
        (
            AnswerMasterId,
            EstablishmentId,
            QuestionnaireId,
            AppUserId,
            DateCreated,
            EscalationEmailAddress,
            EscalationMobileNumber,
            EstablishmentName,
            Answerstatus,
            ScheduleTime,
            TimeOffSet,
            AppUserName,
            [PI],
            ThemeId,
            EmailSubject,
            AppUserMobile,
            AppUserEmail,
            SeenClientAnswerMasterId,
            InEscalationOnce,
            OutEscalationOnce,
            ScheduledTime,
            ActivityName,
            ActivityID
        )
        SELECT 0,
               Am.EstablishmentId,
               Am.SeenClientId,
               Am.AppUserId,
               Am.CreatedOn,
               E.OutEscalationEmails,
               E.OutEscalationMobile,
               E.EstablishmentName,
               Am.IsResolved,
               GETUTCDATE(),
               Am.TimeOffSet,
               U.Name,
               ROUND(Am.PI, 0),
               G.ThemeId,
               E.EscalationEmailSubject,
               U.Mobile,
               U.Email,
               Am.Id,
               E.InEscalationOnce,
               E.OutEscalationOnce,
               dbo.ConvertTimeIntervalStringToMinute(E.OutEscalationSchedulerTime),
               EG.EstablishmentGroupName,
               EG.Id
        FROM dbo.SeenClientAnswerMaster AS Am
            INNER JOIN dbo.Establishment AS E
                ON E.Id = Am.EstablishmentId
            INNER JOIN dbo.[Group] AS G
                ON G.Id = E.GroupId
            LEFT OUTER JOIN dbo.AppUser AS U
                ON Am.AppUserId = U.Id
            INNER JOIN dbo.AppUserEstablishment AUE
                ON AUE.AppUserId = Am.AppUserId
                   AND AUE.EstablishmentId = Am.EstablishmentId
                   AND AUE.IsDeleted = 0
                   AND AUE.NotificationStatus = 1
            INNER JOIN dbo.EstablishmentGroup EG
                ON EG.Id = E.EstablishmentGroupId
        WHERE IsResolved = 'Unresolved'
              --AND SeenClientAnswerMasterId > 0
              AND Am.IsDeleted = 0
              AND E.OutEscalationTime = 2
              AND CAST(GETUTCDATE() AS TIME) > CAST(DATEADD(MINUTE, -Am.TimeOffSet, E.OutEscalationSchedulerTime) AS TIME)
              AND (
                      CAST(Am.EscalationSendDate AS DATE) <> CAST(GETUTCDATE() AS DATE)
                      OR EscalationSendDate IS NULL
                  )
              AND DATENAME(WEEKDAY, DATEADD(MINUTE, -Am.TimeOffSet, GETUTCDATE())) = E.OutEscalationSchedulerDay
              AND ISNULL(Am.EscalationSendDate, GETUTCDATE())
              BETWEEN (GETUTCDATE() - 1) AND GETUTCDATE();
        --------- For Capture -------

        DECLARE @Start INT = 1,
                @End INT;

        SELECT @End = COUNT(1)
        FROM @ResultSet;

        DECLARE @AnswerMasterId BIGINT,
                @DateCreated DATETIME,
                @EscalationEmailAddress NVARCHAR(MAX),
                @EscalationMobileNumber NVARCHAR(MAX),
                @EstablishmentName NVARCHAR(100),
                -- Maulik
                @EstablishmentId INT,
                @EstablishmentGroupId INT,
                @ScheduleTime DATETIME,
                @ScheduledTime INT,
                @TimeOffSet INT,
                @AppUserName NVARCHAR(500),
                @EI DECIMAL(18, 0),
                @ThemeId NVARCHAR(10),
                @QuestionAnswers NVARCHAR(MAX),
                @CustomerNumber NVARCHAR(20),
                @AppUserMobile NVARCHAR(50),
                @AppUserEmail NVARCHAR(50),
                @SeenClientAnswerMasterId BIGINT,
                @InEscalationOnce BIT,
                @OutEscalationOnce BIT,
                @ActivityName NVARCHAR(500),
                @ActivityID BIGINT,
                @HeaderValue VARCHAR(50);

        DECLARE @EmailBody VARCHAR(MAX),
                @EmailSubject NVARCHAR(500),
                @SmsBody NVARCHAR(300),
                @Url NVARCHAR(50);

        SELECT @Url = KeyValue + 'Themes/' --/ThemeMDPI/CMSLogo.png
        FROM dbo.AAAAConfigSettings
        WHERE KeyName = 'DocViewerRootFolderPathCMS';

        SET @EmailBody
            = N'<html><head><meta http-equiv="Content-Type" content="text/html; charset=utf-8" /><title>Untitled Document</title></head>';
        SET @EmailBody += N'<body><div><table width="1250" border="0" align="center" cellpadding="0" cellspacing="0" style="padding: 0px; font-family: Verdana; font-size: 12px; color: #000000; line-height: 18px"><tr><td><table width="100%" border="0" cellspacing="0" cellpadding="0"><tr><td colspan="2"></td></tr><tr><td height="10" colspan="2" align="left" valign="top"></td></tr>';
        SET @EmailBody += N'<tr><td valign="top" align="center"><table width="95%" cellspacing="0" cellpadding="0" border="0"><tbody><tr><td>Good day,<br /><br /></td></tr><tr><td>This is an escalation notification from <b>Magnitude</b>.<br /><br /></td></tr><tr><td align="left">An item or issue has received zero attention within your organization for beyond the prescribed time limit.  <br /><br />  Key details:<br /><br /></td></tr>';
        SET @EmailBody += N'<tr><td align="left"><ul><li>Time elapsed: [[TD]]</li><li>Activity name: [[ActivityName]]</li><li>Establishment name: [[EstablishmentName]]</li><li>Unique reference: [[Reference No]] - [[HeaderValue]]</li></ul></td></tr><tr></tr></tbody></table></td></tr><tr><td align="center" valign="top"><table width="95%" border="0" cellspacing="0" cellpadding="0"><tr><td height="15" align="left" valign="top" style="font-family: Verdana;font-size: 12px; color: #000000; font-weight: normal; line-height: 18px"></td></tr>';
        SET @EmailBody += N'<tr><td align="left" valign="top" style="font-family: Verdana; font-size: 12px;color: #000000; font-weight: normal; line-height: 18px"><span style="font-family: Verdana; font-size: 12px; color: #004E90;font-weight: bold; line-height: 18px">Thank you,<br />Team at <b>MagnitudeApps.com</b></span></br></br>[Please note that this is an auto-generated email. Do not reply to this email]</br></br></td></tr></tr>';
        SET @EmailBody += N'<tr><td style="height: 65px; border-color: #28B3FF"><table width="100%" border="0" cellspacing="0" cellpadding="0"><tr><td></td><td align="left"><img src=[LogoUrl] style="margin: 5px 0px;" height="15%" width="15%" /></td><td></td></tr></table></td></tr><tr><td height="15" align="left" valign="top" style="font-family: Verdana;font-size: 12px; color: #000000; font-weight: normal; line-height: 18px"></td></tr></table></td></tr>';
        SET @EmailBody += N'<td height="15" align="left" valign="top" style="font-family: Verdana;font-size: 12px; color: #000000; font-weight: normal; line-height: 18px"></td></tr></table></td></tr></table></td></tr></table></div></body></html>';

        SET @SmsBody = N'Issue not resolved from [TD] for [EstablishmentName]. Client Mobile: [CustomerNumber]';

        WHILE @Start <= @End
        BEGIN
            SELECT @AnswerMasterId = AnswerMasterId,
                   @DateCreated = DATEADD(MINUTE, TimeOffSet, DateCreated),
                   @EscalationEmailAddress = EscalationEmailAddress,
                   @EscalationMobileNumber = EscalationMobileNumber,
                   @ScheduleTime = DATEADD(MINUTE, TimeOffSet * -1, ScheduleTime),
                   @EstablishmentName = EstablishmentName,
                   @EstablishmentId = EstablishmentId,
                   @TimeOffSet = TimeOffSet,
                   @AppUserName = ISNULL(AppUserName, ''),
                   @EI = [PI],
                   @ThemeId = ThemeId,
                   @QuestionAnswers = NULL,
                   @CustomerNumber = NULL,
                   @EmailSubject = EmailSubject,
                   @AppUserEmail = ISNULL(AppUserEmail, 'info@magnitudefb.com'),
                   @AppUserMobile = ISNULL(AppUserMobile, ''),
                   @SeenClientAnswerMasterId = SeenClientAnswerMasterId,
                   @InEscalationOnce = InEscalationOnce,
                   @OutEscalationOnce = OutEscalationOnce,
                   @ScheduledTime = ScheduledTime,
                   @ActivityName = ActivityName,
                   @ActivityID = ActivityID
            FROM @ResultSet
            WHERE Id = @Start;

            SELECT @HeaderValue = ISNULL(HT.HeaderValue, 'OUT')
            FROM dbo.HeaderSetting HT
            WHERE HT.EstablishmentGroupId = @ActivityID
                  AND ISNULL(HT.IsDeleted, 0) = 0
                  AND HT.HeaderId = (CASE
                                         WHEN @AnswerMasterId > 0 THEN
                                             10
                                         ELSE
                                             11
                                     END
                                    );
            SELECT @EstablishmentGroupId = ISNULL(EstablishmentGroupId, 0)
            FROM dbo.EstablishmentGroup
            WHERE Id =
            (
                SELECT EstablishmentGroupId
                FROM dbo.Establishment
                WHERE Id = @EstablishmentId
            );

            IF (ISNULL(@EstablishmentGroupId, 0) = 0)
            BEGIN
                SET @EmailBody = REPLACE(@EmailBody, '(Captured form)', '(Tell Us Form)');

                SET @EmailBody = REPLACE(@EmailBody, 'Capture Date:', 'Tell Us Date');
            END;

            IF (@AnswerMasterId > 0)
            BEGIN
                SELECT @CustomerNumber = A.Detail
                FROM dbo.Answers AS A
                WHERE AnswerMasterId = @AnswerMasterId
                      AND A.QuestionTypeId = 11
                      AND A.IsDeleted = 0;
            END;
            ELSE
            BEGIN
                SELECT @CustomerNumber = A.Detail
                FROM dbo.SeenClientAnswers AS A
                WHERE A.SeenClientAnswerMasterId = @SeenClientAnswerMasterId
                      AND A.QuestionTypeId = 11
                      AND A.IsDeleted = 0;
            END;


            IF @EscalationEmailAddress <> ''
               AND @EscalationEmailAddress IS NOT NULL
            BEGIN

                IF (@AnswerMasterId > 0)
                BEGIN
                    SELECT @QuestionAnswers = COALESCE(@QuestionAnswers + '<br />', '') + ans.QueAns
                    FROM
                    (
                        SELECT DISTINCT
                            Q.Id,
                            Q.ShortName + ': ' + A.Detail AS QueAns
                        FROM dbo.Answers AS A
                            INNER JOIN dbo.Questions AS Q
                                ON Q.Id = A.QuestionId
                        WHERE AnswerMasterId = @AnswerMasterId
                              AND A.QuestionTypeId IN ( 1, 5, 6, 7, 18, 21 )
                              AND Q.IsDisplayInSummary = 1
                              AND A.IsDeleted = 0
                    ) ans;
                END;
                ELSE
                BEGIN

                    SELECT @QuestionAnswers = COALESCE(@QuestionAnswers + '<br />', '') + ans.QueAns
                    FROM
                    (
                        SELECT DISTINCT
                            Q.Id,
                            Q.ShortName + ': ' + A.Detail AS QueAns
                        FROM dbo.SeenClientAnswers AS A
                            INNER JOIN dbo.SeenClientQuestions AS Q
                                ON Q.Id = A.QuestionId
                        WHERE A.SeenClientAnswerMasterId = @SeenClientAnswerMasterId
                              AND A.QuestionTypeId IN ( 1, 5, 6, 7, 18, 21 )
                              AND Q.IsDisplayInSummary = 1
                              AND A.IsDeleted = 0
                    ) ans;
                END;


                SET @EmailBody = REPLACE(@EmailBody, '[TD]', dbo.MinutesToDuration(@ScheduledTime));


                SET @EmailBody = REPLACE(@EmailBody, '[EstablishmentName]', @EstablishmentName);

                SET @EmailBody = REPLACE(@EmailBody, '[ActivityName]', LTRIM(RTRIM(@ActivityName)));
                SET @EmailBody = REPLACE(@EmailBody, '[HeaderValue]', @HeaderValue);

                IF (@AnswerMasterId > 0) /* Disha - 21-OCT-2016 -- Added condition to replace refno in Email Subject */
                BEGIN

                    SET @EmailBody
                        = REPLACE(   @EmailBody,
                                     '[Reference No]',
                          (
                              SELECT CAST(REPLACE(LTRIM(REPLACE(@AnswerMasterId, '0', ' ')), ' ', '0') AS VARCHAR(50))
                          )
                                 );
                END;
                ELSE
                BEGIN

                    SET @EmailBody
                        = REPLACE(
                                     @EmailBody,
                                     '[Reference No]',
                          (
                              SELECT CAST(REPLACE(LTRIM(REPLACE(@SeenClientAnswerMasterId, '0', ' ')), ' ', '0') AS VARCHAR(50))
                          )
                                 );
                END;

                SET @EmailBody = REPLACE(@EmailBody, '[ManagerName]', @AppUserName);

                SET @EmailBody = REPLACE(@EmailBody, '[CustomerNumber]', ISNULL(@CustomerNumber, ''));

                SET @EmailBody
                    = REPLACE(@EmailBody, '[ComplaintDate]', dbo.ChangeDateFormat(@DateCreated, 'MM/dd/yyyy'));

                SET @EmailBody = REPLACE(@EmailBody, '[QuestionAnswer]', ISNULL(@QuestionAnswers, ''));

                IF (@EI = '-1.00')
                BEGIN
                    SET @EmailBody = REPLACE(@EmailBody, '[PI] %', 'N/A');
                END;
                ELSE
                BEGIN
                    SET @EmailBody = REPLACE(@EmailBody, '[PI]', ISNULL(@EI, ''));
                END;
                --SET @EmailBody = REPLACE(@EmailBody, '[PI]', ISNULL(@EI, ''));

                SET @EmailBody = REPLACE(@EmailBody, '[LogoUrl]', @Url + @ThemeId + '/ThemeMDPI/CMSLogo.png');

                SET @EmailSubject = REPLACE(@EmailSubject, '##[username]##', @AppUserName);
                SET @EmailSubject = REPLACE(@EmailSubject, '##[useremail]##', @AppUserEmail);
                SET @EmailSubject = REPLACE(@EmailSubject, '##[usermobile]##', @AppUserMobile);
                SET @EmailSubject = REPLACE(@EmailSubject, '##[establishment]##', @EstablishmentName);

                SET @EmailSubject = ISNULL(@EmailSubject, 'Escalation Notification for ' + @EstablishmentName);

                IF (@AnswerMasterId > 0) /* Disha - 21-OCT-2016 -- Added condition to replace refno in Email Subject */
                BEGIN

                    SET @EmailSubject
                        = REPLACE(   @EmailSubject,
                                     '##[refno]##',
                          (
                              SELECT CAST(REPLACE(LTRIM(REPLACE(@AnswerMasterId, '0', ' ')), ' ', '0') AS VARCHAR(50))
                          )
                                 );
                END;
                ELSE
                BEGIN

                    SET @EmailSubject
                        = REPLACE(
                                     @EmailSubject,
                                     '##[refno]##',
                          (
                              SELECT CAST(REPLACE(LTRIM(REPLACE(@SeenClientAnswerMasterId, '0', ' ')), ' ', '0') AS VARCHAR(50))
                          )
                                 );
                END;

                INSERT INTO dbo.PendingEmail
                (
                    ModuleId,
                    EmailId,
                    EmailSubject,
                    EmailText,
                    IsSent,
                    SentDate,
                    RefId,
                    Counter,
                    ScheduleDateTime,
                    ReplyTo,
                    CreatedOn,
                    CreatedBy,
                    UpdatedOn,
                    UpdatedBy,
                    DeletedOn,
                    DeletedBy,
                    IsDeleted
                )
                VALUES
                (   10,                      -- ModuleId - bigint
                    @EscalationEmailAddress, -- EmailId - nvarchar(1000)
                    @EmailSubject,           -- EmailSubject - nvarchar(500)
                    @EmailBody,              -- EmailText - nvarchar(max)
                    0,                       -- IsSent - bit
                    NULL,                    -- SentDate - datetime
                    CASE
                        WHEN @AnswerMasterId = 0 THEN
                            @SeenClientAnswerMasterId
                        ELSE
                            @AnswerMasterId
                    END,                     -- RefId - bigint
                    dbo.EmailBlackListCheck(@EscalationEmailAddress),
                    @ScheduleTime,           -- ScheduleDateTime - datetime
                    @AppUserEmail,
                    GETUTCDATE(),            -- CreatedOn - datetime
                    1,                       -- CreatedBy - bigint
                    NULL,                    -- UpdatedOn - datetime
                    NULL,                    -- UpdatedBy - bigint
                    NULL,                    -- DeletedOn - datetime
                    NULL,                    -- DeletedBy - bigint
                    0                        -- IsDeleted - bit
                );
            END;

            IF @EscalationMobileNumber <> ''
               AND @EscalationMobileNumber IS NOT NULL
            BEGIN
                PRINT 'Mobile';
                SET @SmsBody = REPLACE(@SmsBody, '[TD]', dbo.MinutesToDuration(@ScheduledTime));

                SET @SmsBody = REPLACE(@SmsBody, '[EstablishmentName]', @EstablishmentName);

                SET @SmsBody = REPLACE(@SmsBody, '[CustomerNumber]', ISNULL(@CustomerNumber, ''));

                INSERT INTO dbo.PendingSMS
                (
                    ModuleId,
                    MobileNo,
                    SMSText,
                    IsSent,
                    SentDate,
                    RefId,
                    ScheduleDateTime,
                    CreatedOn,
                    CreatedBy,
                    IsDeleted
                )
                SELECT 10,
                       Data,
                       @SmsBody,
                       0,
                       NULL,
                       CASE
                           WHEN @AnswerMasterId = 0 THEN
                               @SeenClientAnswerMasterId
                           ELSE
                               @AnswerMasterId
                       END,
                       @ScheduleTime,
                       GETUTCDATE(),
                       1,
                       0
                FROM dbo.Split(@EscalationMobileNumber, ';');
            END;

            IF (@AnswerMasterId > 0)
            BEGIN
                UPDATE dbo.AnswerMaster
                SET EscalationSendDate = GETUTCDATE()
                WHERE Id = @AnswerMasterId;

                --start
                IF (@InEscalationOnce = 1)
                BEGIN
                    UPDATE dbo.AnswerMaster
                    SET EscalationSendDate = '01 JAN 2098'
                    WHERE Id = @AnswerMasterId;
                END;
                --end						
                ELSE
                BEGIN
                    IF (
                           @EscalationEmailAddress IS NULL
                           OR @EscalationEmailAddress = ''
                       )
                       AND (
                               @EscalationMobileNumber IS NULL
                               OR @EscalationMobileNumber = ''
                           )
                    BEGIN
                        UPDATE dbo.AnswerMaster
                        SET EscalationSendDate = '01 JAN 2099'
                        WHERE Id = @AnswerMasterId;
                    END;
                END;
            END;
            ELSE
            BEGIN
                UPDATE dbo.SeenClientAnswerMaster
                SET EscalationSendDate = GETUTCDATE()
                WHERE Id = @SeenClientAnswerMasterId;

                --start
                IF (@OutEscalationOnce = 1)
                BEGIN
                    UPDATE dbo.SeenClientAnswerMaster
                    SET EscalationSendDate = '01 JAN 2098'
                    WHERE Id = @SeenClientAnswerMasterId;
                END;
                --end						
                ELSE
                BEGIN
                    IF (
                           @EscalationEmailAddress IS NULL
                           OR @EscalationEmailAddress = ''
                       )
                       AND (
                               @EscalationMobileNumber IS NULL
                               OR @EscalationMobileNumber = ''
                           )
                    BEGIN
                        UPDATE dbo.SeenClientAnswerMaster
                        SET EscalationSendDate = '01 JAN 2099'
                        WHERE Id = @SeenClientAnswerMasterId;
                    END;
                END;
            END;

            SET @EmailBody
                = N'<html><head><meta http-equiv="Content-Type" content="text/html; charset=utf-8" /><title>Untitled Document</title></head>';
            SET @EmailBody += N'<body><div><table width="1250" border="0" align="center" cellpadding="0" cellspacing="0" style="padding: 0px; font-family: Verdana; font-size: 12px; color: #000000; line-height: 18px"><tr><td><table width="100%" border="0" cellspacing="0" cellpadding="0"><tr><td colspan="2"></td></tr><tr><td height="10" colspan="2" align="left" valign="top"></td></tr>';
            SET @EmailBody += N'<tr><td valign="top" align="center"><table width="95%" cellspacing="0" cellpadding="0" border="0"><tbody><tr><td>Good day,<br /><br /></td></tr><tr><td>This is an escalation notification from <b>Magnitude</b>.<br /><br /></td></tr><tr><td align="left">An item or issue has received zero attention within your organization for beyond the prescribed time limit.  <br /><br />  Key details:<br /><br /></td></tr>';
            SET @EmailBody += N'<tr><td align="left"><ul><li>Time elapsed: [[TD]]</li><li>Activity name: [[ActivityName]]</li><li>Establishment name: [[EstablishmentName]]</li><li>Unique reference: [[Reference No]] - [[HeaderValue]]</li></ul></td></tr><tr></tr></tbody></table></td></tr><tr><td align="center" valign="top"><table width="95%" border="0" cellspacing="0" cellpadding="0"><tr><td height="15" align="left" valign="top" style="font-family: Verdana;font-size: 12px; color: #000000; font-weight: normal; line-height: 18px"></td></tr>';
            SET @EmailBody += N'<tr><td align="left" valign="top" style="font-family: Verdana; font-size: 12px;color: #000000; font-weight: normal; line-height: 18px"><span style="font-family: Verdana; font-size: 12px; color: #004E90;font-weight: bold; line-height: 18px">Thank you,<br />Team at <b>MagnitudeApps.com</b></span></br></br>[Please note that this is an auto-generated email. Do not reply to this email]</br></br></td></tr></tr>';
            SET @EmailBody += N'<tr><td style="height: 65px; border-color: #28B3FF"><table width="100%" border="0" cellspacing="0" cellpadding="0"><tr><td></td><td align="left"><img src=[LogoUrl] style="margin: 5px 0px;" height="15%" width="15%" /></td><td></td></tr></table></td></tr><tr><td height="15" align="left" valign="top" style="font-family: Verdana;font-size: 12px; color: #000000; font-weight: normal; line-height: 18px"></td></tr></table></td></tr>';
            SET @EmailBody += N'<td height="15" align="left" valign="top" style="font-family: Verdana;font-size: 12px; color: #000000; font-weight: normal; line-height: 18px"></td></tr></table></td></tr></table></td></tr></table></div></body></html>';

            SET @SmsBody = N'Issue not resolved from [TD] for [EstablishmentName]. Client Mobile: [CustomerNumber]';

            SET @Start += 1;

        END;
    END TRY
    BEGIN CATCH
        INSERT INTO dbo.ErrorLog
        (
            PageId,
            MethodName,
            ErrorType,
            ErrorMessage,
            ErrorDetails,
            ErrorDate,
            UserId,
            Solution,
            CreatedOn,
            CreatedBy
        )
        VALUES
        (ERROR_LINE(),
         'dbo.RegisterSeenClientEscalationEmail',
         N'DATABASE',
         ERROR_MESSAGE(),
         ('ERROR_NUMBER=' + CONVERT(VARCHAR(100), ERROR_NUMBER()) + ',ERROR_STATE='
          + CONVERT(VARCHAR(20), ERROR_STATE()) + ',ERROR_SEVERITY=' + CONVERT(VARCHAR(20), ERROR_SEVERITY())
         )  ,
         GETUTCDATE(),
         N'',
         N'',
         GETUTCDATE(),
         N''
        );
    END CATCH;
END;
