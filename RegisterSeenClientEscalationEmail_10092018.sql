-- =============================================
-- Author:		<Author,,GD>
-- Create date: <Create Date,,02 Sep 2015>
-- Description:	<Description,,>
-- Call:	RegisterSeenClientEscalationEmail
-- =============================================
CREATE PROCEDURE dbo.RegisterSeenClientEscalationEmail_10092018
AS
    BEGIN
        DECLARE @ResultSet TABLE
            (
              Id BIGINT IDENTITY(1, 1) ,
              AnswerMasterId BIGINT ,
              EstablishmentId BIGINT ,
              QuestionnaireId BIGINT ,
              AppUserId BIGINT ,
              DateCreated DATETIME ,
              EscalationEmailAddress NVARCHAR(MAX) ,
              EscalationMobileNumber NVARCHAR(MAX) ,
              EstablishmentName NVARCHAR(100) ,
              Answerstatus NVARCHAR(50) ,
              ScheduleTime DATETIME ,
              TimeOffSet INT ,
              AppUserName NVARCHAR(500) ,
              [PI] BIGINT ,
              ThemeId NVARCHAR(10) ,
              EmailSubject NVARCHAR(500) ,
              AppUserMobile NVARCHAR(50) ,
              AppUserEmail NVARCHAR(50) ,
              SeenClientAnswerMasterId BIGINT
            );

--------- For Feedback -------

        INSERT  INTO @ResultSet
                ( AnswerMasterId ,
                  EstablishmentId ,
                  QuestionnaireId ,
                  AppUserId ,
                  DateCreated ,
                  EscalationEmailAddress ,
                  EscalationMobileNumber ,
                  EstablishmentName ,
                  Answerstatus ,
                  ScheduleTime ,
                  TimeOffSet ,
                  AppUserName ,
                  [PI] ,
                  ThemeId ,
                  EmailSubject ,
                  AppUserMobile ,
                  AppUserEmail ,
                  SeenClientAnswerMasterId
			    )
                SELECT  Am.Id ,
                        Am.EstablishmentId ,
                        QuestionnaireId ,
                        Am.AppUserId ,
                        Am.CreatedOn ,
                        E.EscalationEmails ,
                        E.EscalationMobile ,
                        E.EstablishmentName ,
                        Am.IsResolved ,
                        DATEADD(MINUTE,
                                dbo.ConvertTimeIntervalStringToMinute(E.EscalationSchedulerTimeString),
                                ISNULL(Am.EscalationSendDate, GETUTCDATE())) ,
                        E.TimeOffSet ,
                        U.Name ,
                        ROUND(Am.PI, 0) ,
                        G.ThemeId ,
                        E.EscalationEmailSubject ,
                        U.Mobile ,
                        U.Email ,
                        0
                FROM    dbo.AnswerMaster AS Am
                        INNER JOIN dbo.Establishment AS E ON E.Id = Am.EstablishmentId
                        INNER JOIN dbo.[Group] AS G ON G.Id = E.GroupId
                        LEFT OUTER JOIN dbo.AppUser AS U ON Am.AppUserId = U.Id
						INNER JOIN dbo.AppUserEstablishment AUE ON AUE.AppUserId = Am.AppUserId AND AUE.EstablishmentId = Am.EstablishmentId
																	AND AUE.IsDeleted = 0 AND AUE.NotificationStatus = 1
                WHERE   IsResolved = 'Unresolved'
                        --AND SeenClientAnswerMasterId > 0
                        AND Am.IsDeleted = 0
                        AND E.EscalationTime = 0
                        AND ( EscalationSendDate IS NULL
                              OR DATEDIFF(MINUTE, Am.EscalationSendDate,
                                          GETUTCDATE()) > dbo.ConvertTimeIntervalStringToMinute(E.EscalationSchedulerTimeString)
                            );

        INSERT  INTO @ResultSet
                ( AnswerMasterId ,
                  EstablishmentId ,
                  QuestionnaireId ,
                  AppUserId ,
                  DateCreated ,
                  EscalationEmailAddress ,
                  EscalationMobileNumber ,
                  EstablishmentName ,
                  Answerstatus ,
                  ScheduleTime ,
                  TimeOffSet ,
                  AppUserName ,
                  [PI] ,
                  ThemeId ,
                  EmailSubject ,
                  AppUserMobile ,
                  AppUserEmail ,
                  SeenClientAnswerMasterId
			    )
                SELECT  Am.Id ,
                        am.EstablishmentId ,
                        QuestionnaireId ,
                        Am.AppUserId ,
                        Am.CreatedOn ,
                        E.EscalationEmails ,
                        E.EscalationMobile ,
                        E.EstablishmentName ,
                        Am.IsResolved ,
                        ----DATEADD(HOUR,
                        ----        DATEPART(HOUR, E.SeenClientSchedulerTime),
                        ----        DATEADD(MINUTE,
                        ----                DATEPART(MINUTE,
                        ----                         E.SeenClientSchedulerTime)
                        ----                - E.TimeOffSet,
                        ----                CAST(CAST(GETUTCDATE() AS DATE) AS DATETIME))) ,
                        DATEADD(HOUR,
                                DATEPART(HOUR, E.EscalationSchedulerTime),
                                DATEADD(MINUTE,
                                        DATEPART(MINUTE,
                                                 E.EscalationSchedulerTime)
                                        - E.TimeOffSet,
                                        CAST(CAST(GETUTCDATE() AS DATE) AS DATETIME))) ,
                        Am.TimeOffSet ,
                        U.Name ,
                        ROUND(Am.PI, 0) ,
                        G.ThemeId ,
                        E.EscalationEmailSubject ,
                        U.Mobile ,
                        U.Email ,
                        0
                FROM    dbo.AnswerMaster AS Am
                        INNER JOIN dbo.Establishment AS E ON E.Id = Am.EstablishmentId
                        INNER JOIN dbo.[Group] AS G ON G.Id = E.GroupId
                        LEFT OUTER JOIN dbo.AppUser AS U ON Am.AppUserId = U.Id
												INNER JOIN dbo.AppUserEstablishment AUE ON AUE.AppUserId = Am.AppUserId AND AUE.EstablishmentId = Am.EstablishmentId
																	AND AUE.IsDeleted = 0 AND AUE.NotificationStatus = 1

                WHERE   IsResolved = 'Unresolved'
                        --AND SeenClientAnswerMasterId > 0
                        AND Am.IsDeleted = 0
                        AND E.EscalationTime = 1
                        AND CAST(GETUTCDATE() AS TIME) > CAST(DATEADD(MINUTE,
                                                              -Am.TimeOffSet,
                                                              E.EscalationSchedulerTime) AS TIME)
                        AND ( CAST(Am.EscalationSendDate AS DATE) <> CAST(GETUTCDATE() AS DATE)
                              OR Am.EscalationSendDate IS NULL
                            );

        INSERT  INTO @ResultSet
                ( AnswerMasterId ,
                  am.EstablishmentId ,
                  QuestionnaireId ,
                  AppUserId ,
                  DateCreated ,
                  EscalationEmailAddress ,
                  EscalationMobileNumber ,
                  EstablishmentName ,
                  Answerstatus ,
                  ScheduleTime ,
                  TimeOffSet ,
                  AppUserName ,
                  [PI] ,
                  ThemeId ,
                  EmailSubject ,
                  AppUserMobile ,
                  AppUserEmail ,
                  SeenClientAnswerMasterId
			    )
                SELECT  Am.Id ,
                        Am.EstablishmentId ,
                        QuestionnaireId ,
                        Am.AppUserId ,
                        Am.CreatedOn ,
                        E.EscalationEmails ,
                        E.EscalationMobile ,
                        E.EstablishmentName ,
                        Am.IsResolved ,
                        GETUTCDATE() ,
                        Am.TimeOffSet ,
                        U.Name ,
                        ROUND(Am.PI, 0) ,
                        G.ThemeId ,
                        E.EscalationEmailSubject ,
                        U.Mobile ,
                        U.Email ,
                        0
                FROM    dbo.AnswerMaster AS Am
                        INNER JOIN dbo.Establishment AS E ON E.Id = Am.EstablishmentId
                        INNER JOIN dbo.[Group] AS G ON G.Id = E.GroupId
                        LEFT OUTER JOIN dbo.AppUser AS U ON Am.AppUserId = U.Id
												INNER JOIN dbo.AppUserEstablishment AUE ON AUE.AppUserId = Am.AppUserId AND AUE.EstablishmentId = Am.EstablishmentId
																	AND AUE.IsDeleted = 0 AND AUE.NotificationStatus = 1

                WHERE   IsResolved = 'Unresolved'
                        --AND SeenClientAnswerMasterId > 0
                        AND Am.IsDeleted = 0
                        AND E.EscalationTime = 2
                        AND CAST(GETUTCDATE() AS TIME) > CAST(DATEADD(MINUTE,
                                                              -Am.TimeOffSet,
                                                              E.EscalationSchedulerTime) AS TIME)
                        AND ( CAST(Am.EscalationSendDate AS DATE) <> CAST(GETUTCDATE() AS DATE)
                              OR Am.EscalationSendDate IS NULL
                            )
                        AND DATENAME(WEEKDAY,
                                     DATEADD(MINUTE, -Am.TimeOffSet,
                                             GETUTCDATE())) = E.EscalationSchedulerDay;

--------- For Feedback -------

--------- For Capture -------

        INSERT  INTO @ResultSet
                ( AnswerMasterId ,
                  EstablishmentId ,
                  QuestionnaireId ,
                  AppUserId ,
                  DateCreated ,
                  EscalationEmailAddress ,
                  EscalationMobileNumber ,
                  EstablishmentName ,
                  Answerstatus ,
                  ScheduleTime ,
                  TimeOffSet ,
                  AppUserName ,
                  [PI] ,
                  ThemeId ,
                  EmailSubject ,
                  AppUserMobile ,
                  AppUserEmail ,
                  SeenClientAnswerMasterId
			    )
                SELECT  0 ,
                        Am.EstablishmentId ,
                        Am.SeenClientId ,
                        Am.AppUserId ,
                        Am.CreatedOn ,
                        E.OutEscalationEmails ,
                        E.OutEscalationMobile ,
                        E.EstablishmentName ,
                        Am.IsResolved ,
                        DATEADD(MINUTE,
                                dbo.ConvertTimeIntervalStringToMinute(E.OutEscalationSchedulerTimeString),
                                ISNULL(Am.EscalationSendDate, GETUTCDATE())) ,
                        E.TimeOffSet ,
                        U.Name ,
                        ROUND(Am.PI, 0) ,
                        G.ThemeId ,
                        E.OutEscalationEmailSubject ,
                        U.Mobile ,
                        U.Email ,
                        Am.Id
                FROM    dbo.SeenClientAnswerMaster AS Am
                        INNER JOIN dbo.Establishment AS E ON E.Id = Am.EstablishmentId
                        INNER JOIN dbo.[Group] AS G ON G.Id = E.GroupId
                        LEFT OUTER JOIN dbo.AppUser AS U ON Am.AppUserId = U.Id
												INNER JOIN dbo.AppUserEstablishment AUE ON AUE.AppUserId = Am.AppUserId AND AUE.EstablishmentId = Am.EstablishmentId
																	AND AUE.IsDeleted = 0 AND AUE.NotificationStatus = 1

                WHERE   IsResolved = 'Unresolved'
                        --AND SeenClientAnswerMasterId > 0
                        AND Am.IsDeleted = 0
                        AND E.OutEscalationTime = 0
                        AND ( EscalationSendDate IS NULL
                              OR DATEDIFF(MINUTE, Am.EscalationSendDate,
                                          GETUTCDATE()) > dbo.ConvertTimeIntervalStringToMinute(E.OutEscalationSchedulerTimeString)
                            );

        INSERT  INTO @ResultSet
                ( AnswerMasterId ,
                  EstablishmentId ,
                  QuestionnaireId ,
                  AppUserId ,
                  DateCreated ,
                  EscalationEmailAddress ,
                  EscalationMobileNumber ,
                  EstablishmentName ,
                  Answerstatus ,
                  ScheduleTime ,
                  TimeOffSet ,
                  AppUserName ,
                  [PI] ,
                  ThemeId ,
                  EmailSubject ,
                  AppUserMobile ,
                  AppUserEmail ,
                  SeenClientAnswerMasterId
			    )
                SELECT  0 ,
                        Am.EstablishmentId ,
                        Am.SeenClientId ,
                        Am.AppUserId ,
                        Am.CreatedOn ,
                        E.OutEscalationEmails ,
                        E.OutEscalationMobile ,
                        E.EstablishmentName ,
                        Am.IsResolved ,
                        ----DATEADD(HOUR,
                        ----        DATEPART(HOUR, E.SeenClientSchedulerTime),
                        ----        DATEADD(MINUTE,
                        ----                DATEPART(MINUTE,
                        ----                         E.SeenClientSchedulerTime)
                        ----                - E.TimeOffSet,
                        ----                CAST(CAST(GETUTCDATE() AS DATE) AS DATETIME))) ,
                        DATEADD(HOUR,
                                DATEPART(HOUR, E.OutEscalationSchedulerTime),
                                DATEADD(MINUTE,
                                        DATEPART(MINUTE,
                                                 E.OutEscalationSchedulerTime)
                                        - E.TimeOffSet,
                                        CAST(CAST(GETUTCDATE() AS DATE) AS DATETIME))) ,
                        Am.TimeOffSet ,
                        U.Name ,
                        ROUND(Am.PI, 0) ,
                        G.ThemeId ,
                        E.OutEscalationEmailSubject ,
                        U.Mobile ,
                        U.Email ,
                        Am.Id
                FROM    dbo.SeenClientAnswerMaster AS Am
                        INNER JOIN dbo.Establishment AS E ON E.Id = Am.EstablishmentId
                        INNER JOIN dbo.[Group] AS G ON G.Id = E.GroupId
                        LEFT OUTER JOIN dbo.AppUser AS U ON Am.AppUserId = U.Id
												INNER JOIN dbo.AppUserEstablishment AUE ON AUE.AppUserId = Am.AppUserId AND AUE.EstablishmentId = Am.EstablishmentId
																	AND AUE.IsDeleted = 0 AND AUE.NotificationStatus = 1

                WHERE   IsResolved = 'Unresolved'
                        --AND SeenClientAnswerMasterId > 0
                        AND Am.IsDeleted = 0
                        AND E.OutEscalationTime = 1
                        AND CAST(GETUTCDATE() AS TIME) > CAST(DATEADD(MINUTE,
                                                              -Am.TimeOffSet,
                                                              E.OutEscalationSchedulerTime) AS TIME)
                        AND ( CAST(Am.EscalationSendDate AS DATE) <> CAST(GETUTCDATE() AS DATE)
                              OR Am.EscalationSendDate IS NULL
                            );

        INSERT  INTO @ResultSet
                ( AnswerMasterId ,
                  EstablishmentId ,
                  QuestionnaireId ,
                  AppUserId ,
                  DateCreated ,
                  EscalationEmailAddress ,
                  EscalationMobileNumber ,
                  EstablishmentName ,
                  Answerstatus ,
                  ScheduleTime ,
                  TimeOffSet ,
                  AppUserName ,
                  [PI] ,
                  ThemeId ,
                  EmailSubject ,
                  AppUserMobile ,
                  AppUserEmail ,
                  SeenClientAnswerMasterId
			    )
                SELECT  0 ,
                        Am.EstablishmentId ,
                        Am.SeenClientId ,
                        Am.AppUserId ,
                        Am.CreatedOn ,
                        E.OutEscalationEmails ,
                        E.OutEscalationMobile ,
                        E.EstablishmentName ,
                        Am.IsResolved ,
                        GETUTCDATE() ,
                        Am.TimeOffSet ,
                        U.Name ,
                        ROUND(Am.PI, 0) ,
                        G.ThemeId ,
                        E.EscalationEmailSubject ,
                        U.Mobile ,
                        U.Email ,
                        Am.Id
                FROM    dbo.SeenClientAnswerMaster AS Am
                        INNER JOIN dbo.Establishment AS E ON E.Id = Am.EstablishmentId
                        INNER JOIN dbo.[Group] AS G ON G.Id = E.GroupId
                        LEFT OUTER JOIN dbo.AppUser AS U ON Am.AppUserId = U.Id
												INNER JOIN dbo.AppUserEstablishment AUE ON AUE.AppUserId = Am.AppUserId AND AUE.EstablishmentId = Am.EstablishmentId
																	AND AUE.IsDeleted = 0 AND AUE.NotificationStatus = 1

                WHERE   IsResolved = 'Unresolved'
                        --AND SeenClientAnswerMasterId > 0
                        AND Am.IsDeleted = 0
                        AND E.OutEscalationTime = 2
                        AND CAST(GETUTCDATE() AS TIME) > CAST(DATEADD(MINUTE,
                                                              -Am.TimeOffSet,
                                                              E.OutEscalationSchedulerTime) AS TIME)
                        AND ( CAST(Am.EscalationSendDate AS DATE) <> CAST(GETUTCDATE() AS DATE)
                              OR Am.EscalationSendDate IS NULL
                            )
                        AND DATENAME(WEEKDAY,
                                     DATEADD(MINUTE, -Am.TimeOffSet,
                                             GETUTCDATE())) = E.OutEscalationSchedulerDay;

--------- For Capture -------



        DECLARE @Start INT = 1 ,
            @End INT;

        SELECT  @End = COUNT(1)
        FROM    @ResultSet;

        DECLARE @AnswerMasterId BIGINT ,
            @DateCreated DATETIME ,
            @EscalationEmailAddress NVARCHAR(MAX) ,
            @EscalationMobileNumber NVARCHAR(MAX) ,
            @EstablishmentName NVARCHAR(100) ,
			-- Maulik
            @EstablishmentId INT ,
            @EstablishmentGroupId INT ,
            @ScheduleTime DATETIME ,
            @TimeOffSet INT ,
            @AppUserName NVARCHAR(500) ,
            @EI DECIMAL(18, 0) ,
            @ThemeId NVARCHAR(10) ,
            @QuestionAnswers NVARCHAR(MAX) ,
            @CustomerNumber NVARCHAR(20) ,
            @AppUserMobile NVARCHAR(50) ,
            @AppUserEmail NVARCHAR(50) ,
            @SeenClientAnswerMasterId BIGINT;

        DECLARE @EmailBody VARCHAR(MAX) ,
            @EmailSubject NVARCHAR(500) ,
            @SmsBody NVARCHAR(300) ,
            @Url NVARCHAR(50);

        SELECT  @Url = KeyValue + '/UploadFiles/Themes/' --/ThemeMDPI/CMSLogo.png
        FROM    dbo.AAAAConfigSettings
        WHERE   KeyName = 'DocViewerRootFolderPath';

        IF ( @AnswerMasterId > 0 )
            BEGIN
                SET @EmailBody = N'<html><head><meta http-equiv="Content-Type" content="text/html; charset=utf-8" /><title>Untitled Document</title></head>';
                SET @EmailBody += N'<body><div><table width="1250" border="0" align="center" cellpadding="0" cellspacing="0" style="padding: 0px; font-family: Verdana; font-size: 12px; color: #000000; line-height: 18px"><tr><td><table width="100%" border="0" cellspacing="0" cellpadding="0"><tr><td colspan="2"></td></tr><tr><td height="10" colspan="2" align="left" valign="top"></td></tr>';
                SET @EmailBody += N'<tr><td valign="top" align="center"><table width="95%" cellspacing="0" cellpadding="0" border="0"><tbody><tr><td>To whom it may concern<br /><br /></td></tr><tr><td align="left">This is an escalation notification to notify you of';
                SET @EmailBody += N' not been attended to for ([TD]).  <br />  Please kindly attend to the issue below:<br /><br /></td></tr><tr><td align="left">Reference #: [Reference No]</td></tr><tr></tr><tr><td align="left">Establishment Name: [EstablishmentName] [ManagerName]<br />Customer Number: [CustomerNumber]<br />Complaint Date: [ComplaintDate]<br />[QuestionAnswer]<br />Performance Index : [PI] %<br /><br />Note: This is an auto generated response. Please do not respond to this mail.</td></tr></tbody></table></td></tr>';
                SET @EmailBody += N'<tr><td align="center" valign="top"><table width="95%" border="0" cellspacing="0" cellpadding="0"><tr><td height="15" align="left" valign="top" style="font-family: Verdana;font-size: 12px; color: #000000; font-weight: normal; line-height: 18px"></td></tr><tr><td align="left" valign="top" style="font-family: Verdana; font-size: 12px;color: #000000; font-weight: normal; line-height: 18px"><span style="font-family: Verdana; font-size: 12px; color: #004E90;font-weight: bold; line-height: 18px">Thanks,<br />[EstablishmentName]</span></td></tr>';
                SET @EmailBody += N'<tr><td style="height: 65px; border-color: #28B3FF"><table width="100%" border="0" cellspacing="0" cellpadding="0"><tr><td></td><td align="left"><img src=[LogoUrl] style="margin: 5px 0px;" height="25%" width="25%" /></td><td></td></tr></table></td></tr><tr><td height="15" align="left" valign="top" style="font-family: Verdana;font-size: 12px; color: #000000; font-weight: normal; line-height: 18px"></td></tr></table></td></tr>';
                SET @EmailBody += N'</table></td></tr></table></div></body></html>';
            END;
        ELSE
            BEGIN
                SET @EmailBody = N'<html><head><meta http-equiv="Content-Type" content="text/html; charset=utf-8" /><title>Untitled Document</title></head>';
                SET @EmailBody += N'<body><div><table width="1250" border="0" align="center" cellpadding="0" cellspacing="0" style="padding: 0px; font-family: Verdana; font-size: 12px; color: #000000; line-height: 18px"><tr><td><table width="100%" border="0" cellspacing="0" cellpadding="0"><tr><td colspan="2"></td></tr><tr><td height="10" colspan="2" align="left" valign="top"></td></tr>';
                SET @EmailBody += N'<tr><td valign="top" align="center"><table width="95%" cellspacing="0" cellpadding="0" border="0"><tbody><tr><td>To whom it may concern<br /><br /></td></tr><tr><td align="left">This is an escalation notification to notify you for a user case (Captured form) that has';
                SET @EmailBody += N' not been attended to for ([TD]).  <br />  Please kindly attend to the issue below:<br /><br /></td></tr><tr><td align="left">Reference #: [Reference No]</td></tr><tr></tr><tr><td align="left">Establishment Name: [EstablishmentName] User Name: [ManagerName]<br />Customer Number: [CustomerNumber]<br />Capture Date: [ComplaintDate]<br />[QuestionAnswer]<br />Performance Index : [PI] %<br /><br />Note: This is an auto generated response. Please do not respond to this mail.</td></tr></tbody></table></td></tr>';
                SET @EmailBody += N'<tr><td align="center" valign="top"><table width="95%" border="0" cellspacing="0" cellpadding="0"><tr><td height="15" align="left" valign="top" style="font-family: Verdana;font-size: 12px; color: #000000; font-weight: normal; line-height: 18px"></td></tr><tr><td align="left" valign="top" style="font-family: Verdana; font-size: 12px;color: #000000; font-weight: normal; line-height: 18px"><span style="font-family: Verdana; font-size: 12px; color: #004E90;font-weight: bold; line-height: 18px">Thanks,<br />[EstablishmentName]</span></td></tr>';
                SET @EmailBody += N'<tr><td style="height: 65px; border-color: #28B3FF"><table width="100%" border="0" cellspacing="0" cellpadding="0"><tr><td></td><td align="left"><img src=[LogoUrl] style="margin: 5px 0px;" height="25%" width="25%" /></td><td></td></tr></table></td></tr><tr><td height="15" align="left" valign="top" style="font-family: Verdana;font-size: 12px; color: #000000; font-weight: normal; line-height: 18px"></td></tr></table></td></tr>';
                SET @EmailBody += N'</table></td></tr></table></div></body></html>';
            END;
        
        SET @SmsBody = N'Issue not resolved from [TD] for [EstablishmentName]. Client Mobile: [CustomerNumber]';

        WHILE @Start <= @End
            BEGIN
                SELECT  @AnswerMasterId = AnswerMasterId ,
                        @DateCreated = DATEADD(MINUTE, TimeOffSet, DateCreated) ,
                        @EscalationEmailAddress = EscalationEmailAddress ,
                        @EscalationMobileNumber = EscalationMobileNumber ,
                        @ScheduleTime = DATEADD(MINUTE, TimeOffSet * -1,
                                                ScheduleTime) ,
                        @EstablishmentName = EstablishmentName ,
                        @EstablishmentId = EstablishmentId ,
                        @TimeOffSet = TimeOffSet ,
                        @AppUserName = ISNULL(AppUserName, '') ,
                        @EI = [PI] ,
                        @ThemeId = ThemeId ,
                        @QuestionAnswers = NULL ,
                        @CustomerNumber = NULL ,
                        @EmailSubject = EmailSubject ,
                        @AppUserEmail = ISNULL(AppUserEmail,
                                               'info@magnitudefb.com') ,
                        @AppUserMobile = ISNULL(AppUserMobile, '') ,
                        @SeenClientAnswerMasterId = SeenClientAnswerMasterId
                FROM    @ResultSet
                WHERE   Id = @Start;

                SELECT  @EstablishmentGroupId = ISNULL(EstablishmentGroupId, 0)
                FROM    dbo.EstablishmentGroup
                WHERE   Id = ( SELECT   EstablishmentGroupId
                               FROM     dbo.Establishment
                               WHERE    Id = @EstablishmentId
                             )

                IF ( ISNULL(@EstablishmentGroupId, 0) = 0 )
                    BEGIN
                        SET @EmailBody = REPLACE(@EmailBody, '(Captured form)',
                                                 '(Tell Us Form)');

                        SET @EmailBody = REPLACE(@EmailBody, 'Capture Date:',
                                                 'Tell Us Date');
                    END 
				
                IF ( @AnswerMasterId > 0 )
                    BEGIN
                        SELECT  @CustomerNumber = A.Detail
                        FROM    dbo.Answers AS A
                        WHERE   AnswerMasterId = @AnswerMasterId
                                AND A.QuestionTypeId = 11
                                AND A.IsDeleted = 0;
                    END;
                ELSE
                    BEGIN
                        SELECT  @CustomerNumber = A.Detail
                        FROM    dbo.SeenClientAnswers AS A
                        WHERE   A.SeenClientAnswerMasterId = @SeenClientAnswerMasterId
                                AND A.QuestionTypeId = 11
                                AND A.IsDeleted = 0;
                    END;

                
                IF @EscalationEmailAddress <> ''
                    AND @EscalationEmailAddress IS NOT NULL
                    BEGIN
                        
                        IF ( @AnswerMasterId > 0 )
                            BEGIN
                                SELECT  @QuestionAnswers = COALESCE(@QuestionAnswers
                                                              + '<br />', '')
                                        + Q.ShortName + ': ' + A.Detail
                                FROM    dbo.Answers AS A
                                        INNER JOIN dbo.Questions AS Q ON Q.Id = A.QuestionId
                                WHERE   AnswerMasterId = @AnswerMasterId
                                        AND A.QuestionTypeId IN ( 1, 5, 6, 7,
                                                              18, 21 )
                                        AND A.IsDeleted = 0;
                            END;
                        ELSE
                            BEGIN

                                SELECT  @QuestionAnswers = COALESCE(@QuestionAnswers
                                                              + '<br />', '')
                                        + Q.ShortName + ': ' + A.Detail
                                FROM    dbo.SeenClientAnswers AS A
                                        INNER JOIN dbo.SeenClientQuestions AS Q ON Q.Id = A.QuestionId
                                WHERE   A.SeenClientAnswerMasterId = @SeenClientAnswerMasterId
                                        AND A.QuestionTypeId IN ( 1, 5, 6, 7,
                                                              18, 21 )
                                        AND A.IsDeleted = 0;
                            END;
                        

                        SET @EmailBody = REPLACE(@EmailBody, '[TD]',
                                                 dbo.MinutesToDuration(ABS(DATEDIFF(mi,
                                                              CONVERT(DATETIME, DATEADD(MINUTE,
                                                              @TimeOffSet,
                                                              GETUTCDATE())),
                                                              CONVERT(DATETIME, @DateCreated)))));
                        
                        SET @EmailBody = REPLACE(@EmailBody,
                                                 '[EstablishmentName]',
                                                 @EstablishmentName);

                        SET @EmailBody = REPLACE(@EmailBody, '[Reference No]',
                                                 CAST(LEFT(REPLICATE(0,
                                                              10
                                                              - LEN(@AnswerMasterId))
                                                           + CAST(@AnswerMasterId AS VARCHAR(50)),
                                                           10) AS VARCHAR(50)));
                        
                        SET @EmailBody = REPLACE(@EmailBody, '[ManagerName]',
                                                 @AppUserName);
                        
                        SET @EmailBody = REPLACE(@EmailBody,
                                                 '[CustomerNumber]',
                                                 ISNULL(@CustomerNumber, ''));
                        
                        SET @EmailBody = REPLACE(@EmailBody, '[ComplaintDate]',
                                                 dbo.ChangeDateFormat(@DateCreated,
                                                              'MM/dd/yyyy'));
                        
                        SET @EmailBody = REPLACE(@EmailBody,
                                                 '[QuestionAnswer]',
                                                 @QuestionAnswers);
                        
                        SET @EmailBody = REPLACE(@EmailBody, '[PI]', @EI);
                        
                        SET @EmailBody = REPLACE(@EmailBody, '[LogoUrl]',
                                                 @Url + @ThemeId
                                                 + '/ThemeMDPI/CMSLogo.png');

                        SET @EmailSubject = REPLACE(@EmailSubject,
                                                    '##[username]##',
                                                    @AppUserName);
                        SET @EmailSubject = REPLACE(@EmailSubject,
                                                    '##[useremail]##',
                                                    @AppUserEmail);
                        SET @EmailSubject = REPLACE(@EmailSubject,
                                                    '##[usermobile]##',
                                                    @AppUserMobile);
                        SET @EmailSubject = REPLACE(@EmailSubject,
                                                    '##[establishment]##',
                                                    @EstablishmentName);

                        SET @EmailSubject = ISNULL(@EmailSubject,
                                                   'Escalation Notification for '
                                                   + @EstablishmentName);

                        IF ( @AnswerMasterId > 0 ) /* Disha - 21-OCT-2016 -- Added condition to replace refno in Email Subject */
                            BEGIN
                                SET @EmailSubject = REPLACE(@EmailSubject,
                                                            '##[refno]##',
                                                            CAST(LEFT(REPLICATE(0,
                                                              10
                                                              - LEN(@AnswerMasterId))
                                                              + CAST(@AnswerMasterId AS VARCHAR(50)),
                                                              10) AS VARCHAR(50)));
                            END
                        ELSE
                            BEGIN
                                SET @EmailSubject = REPLACE(@EmailSubject,
                                                            '##[refno]##',
                                                            CAST(LEFT(REPLICATE(0,
                                                              10
                                                              - LEN(@SeenClientAnswerMasterId))
                                                              + CAST(@SeenClientAnswerMasterId AS VARCHAR(50)),
                                                              10) AS VARCHAR(50)));
                            END
                    
                        INSERT  INTO dbo.PendingEmail
                                ( ModuleId ,
                                  EmailId ,
                                  EmailSubject ,
                                  EmailText ,
                                  IsSent ,
                                  SentDate ,
                                  RefId ,
                                  ScheduleDateTime ,
                                  ReplyTo ,
                                  CreatedOn ,
                                  CreatedBy ,
                                  UpdatedOn ,
                                  UpdatedBy ,
                                  DeletedOn ,
                                  DeletedBy ,
                                  IsDeleted
					            )
                        VALUES  ( 10 , -- ModuleId - bigint
                                  @EscalationEmailAddress , -- EmailId - nvarchar(1000)
                                  @EmailSubject , -- EmailSubject - nvarchar(500)
                                  @EmailBody , -- EmailText - nvarchar(max)
                                  0 , -- IsSent - bit
                                  NULL , -- SentDate - datetime
                                  @AnswerMasterId , -- RefId - bigint
                                  @ScheduleTime , -- ScheduleDateTime - datetime
                                  @AppUserEmail ,
                                  GETUTCDATE() , -- CreatedOn - datetime
                                  1 , -- CreatedBy - bigint
                                  NULL , -- UpdatedOn - datetime
                                  NULL , -- UpdatedBy - bigint
                                  NULL , -- DeletedOn - datetime
                                  NULL , -- DeletedBy - bigint
                                  0  -- IsDeleted - bit
					            );
                    END;

                IF @EscalationMobileNumber <> ''
                    AND @EscalationMobileNumber IS NOT NULL
                    BEGIN
                        PRINT 'Mobile';
                        SET @SmsBody = REPLACE(@SmsBody, '[TD]',
                                               dbo.MinutesToDuration(ABS(DATEDIFF(mi,
                                                              CONVERT(DATETIME, DATEADD(MINUTE,
                                                              @TimeOffSet,
                                                              GETUTCDATE())),
                                                              CONVERT(DATETIME, @DateCreated)))));
                        
                        SET @SmsBody = REPLACE(@SmsBody, '[EstablishmentName]',
                                               @EstablishmentName);
                        
                        SET @SmsBody = REPLACE(@SmsBody, '[CustomerNumber]',
                                               ISNULL(@CustomerNumber, ''));

                        INSERT  INTO dbo.PendingSMS
                                ( ModuleId ,
                                  MobileNo ,
                                  SMSText ,
                                  IsSent ,
                                  SentDate ,
                                  RefId ,
                                  ScheduleDateTime ,
                                  CreatedOn ,
                                  CreatedBy ,
                                  IsDeleted
											
                                )
                                SELECT  10 ,
                                        Data ,
                                        @SmsBody ,
                                        0 ,
                                        NULL ,
                                        @AnswerMasterId ,
                                        @ScheduleTime ,
                                        GETUTCDATE() ,
                                        1 ,
                                        0
                                FROM    dbo.Split(@EscalationMobileNumber, ';');
                    END;

                IF ( @AnswerMasterId > 0 )
                    BEGIN
                        UPDATE  dbo.AnswerMaster
                        SET     EscalationSendDate = GETUTCDATE()
                        WHERE   Id = @AnswerMasterId;

                        IF ( @EscalationEmailAddress IS NULL
                             OR @EscalationEmailAddress = ''
                           )
                            AND ( @EscalationMobileNumber IS NULL
                                  OR @EscalationMobileNumber = ''
                                )
                            BEGIN
                                UPDATE  dbo.AnswerMaster
                                SET     EscalationSendDate = '01 JAN 2099'
                                WHERE   Id = @AnswerMasterId;
                            END;
                    END;
                ELSE
                    BEGIN
                        UPDATE  dbo.SeenClientAnswerMaster
                        SET     EscalationSendDate = GETUTCDATE()
                        WHERE   Id = @SeenClientAnswerMasterId;

                        IF ( @EscalationEmailAddress IS NULL
                             OR @EscalationEmailAddress = ''
                           )
                            AND ( @EscalationMobileNumber IS NULL
                                  OR @EscalationMobileNumber = ''
                                )
                            BEGIN
                                UPDATE  dbo.SeenClientAnswerMaster
                                SET     EscalationSendDate = '01 JAN 2099'
                                WHERE   Id = @SeenClientAnswerMasterId;
                            END;
                    END;

                IF ( @AnswerMasterId > 0 )
                    BEGIN
                        SET @EmailBody = N'<html><head><meta http-equiv="Content-Type" content="text/html; charset=utf-8" /><title>Untitled Document</title></head>';
                        SET @EmailBody += N'<body><div><table width="1250" border="0" align="center" cellpadding="0" cellspacing="0" style="padding: 0px; font-family: Verdana; font-size: 12px; color: #000000; line-height: 18px"><tr><td><table width="100%" border="0" cellspacing="0" cellpadding="0"><tr><td colspan="2"></td></tr><tr><td height="10" colspan="2" align="left" valign="top"></td></tr>';
                        SET @EmailBody += N'<tr><td valign="top" align="center"><table width="95%" cellspacing="0" cellpadding="0" border="0"><tbody><tr><td>To whom it may concern<br /><br /></td></tr><tr><td align="left">This is an escalation notification to notify you of';
                        SET @EmailBody += N' not been attended to for ([TD]).  <br />  Please kindly attend to the issue below:<br /><br /></td></tr><tr><td align="left">Reference #: [Reference No]</td></tr><tr></tr><tr><td align="left">Establishment Name: [EstablishmentName] [ManagerName]<br />Customer Number: [CustomerNumber]<br />Complaint Date: [ComplaintDate]<br />[QuestionAnswer]<br />Performance Index : [PI] %<br /><br />Note: This is an auto generated response. Please do not respond to this mail.</td></tr></tbody></table></td></tr>';
                        SET @EmailBody += N'<tr><td align="center" valign="top"><table width="95%" border="0" cellspacing="0" cellpadding="0"><tr><td height="15" align="left" valign="top" style="font-family: Verdana;font-size: 12px; color: #000000; font-weight: normal; line-height: 18px"></td></tr><tr><td align="left" valign="top" style="font-family: Verdana; font-size: 12px;color: #000000; font-weight: normal; line-height: 18px"><span style="font-family: Verdana; font-size: 12px; color: #004E90;font-weight: bold; line-height: 18px">Thanks,<br />[EstablishmentName]</span></td></tr>';
                        SET @EmailBody += N'<tr><td style="height: 65px; border-color: #28B3FF"><table width="100%" border="0" cellspacing="0" cellpadding="0"><tr><td></td><td align="left"><img src=[LogoUrl] style="margin: 5px 0px;" height="25%" width="25%" /></td><td></td></tr></table></td></tr><tr><td height="15" align="left" valign="top" style="font-family: Verdana;font-size: 12px; color: #000000; font-weight: normal; line-height: 18px"></td></tr></table></td></tr>';
                        SET @EmailBody += N'</table></td></tr></table></div></body></html>';
                    END;
                ELSE
                    BEGIN
                        SET @EmailBody = N'<html><head><meta http-equiv="Content-Type" content="text/html; charset=utf-8" /><title>Untitled Document</title></head>';
                        SET @EmailBody += N'<body><div><table width="1250" border="0" align="center" cellpadding="0" cellspacing="0" style="padding: 0px; font-family: Verdana; font-size: 12px; color: #000000; line-height: 18px"><tr><td><table width="100%" border="0" cellspacing="0" cellpadding="0"><tr><td colspan="2"></td></tr><tr><td height="10" colspan="2" align="left" valign="top"></td></tr>';
                        SET @EmailBody += N'<tr><td valign="top" align="center"><table width="95%" cellspacing="0" cellpadding="0" border="0"><tbody><tr><td>To whom it may concern<br /><br /></td></tr><tr><td align="left">This is an escalation notification to notify you for a user case (Captured form) that has';
                        SET @EmailBody += N' not been attended to for ([TD]).  <br />  Please kindly attend to the issue below:<br /><br /></td></tr><tr><td align="left">Reference #: [Reference No]</td></tr><tr></tr><tr><td align="left">Establishment Name: [EstablishmentName] User Name: [ManagerName]<br />Customer Number: [CustomerNumber]<br />Capture Date: [ComplaintDate]<br />[QuestionAnswer]<br />Performance Index : [PI] %<br /><br />Note: This is an auto generated response. Please do not respond to this mail.</td></tr></tbody></table></td></tr>';
                        SET @EmailBody += N'<tr><td align="center" valign="top"><table width="95%" border="0" cellspacing="0" cellpadding="0"><tr><td height="15" align="left" valign="top" style="font-family: Verdana;font-size: 12px; color: #000000; font-weight: normal; line-height: 18px"></td></tr><tr><td align="left" valign="top" style="font-family: Verdana; font-size: 12px;color: #000000; font-weight: normal; line-height: 18px"><span style="font-family: Verdana; font-size: 12px; color: #004E90;font-weight: bold; line-height: 18px">Thanks,<br />[EstablishmentName]</span></td></tr>';
                        SET @EmailBody += N'<tr><td style="height: 65px; border-color: #28B3FF"><table width="100%" border="0" cellspacing="0" cellpadding="0"><tr><td></td><td align="left"><img src=[LogoUrl] style="margin: 5px 0px;" height="25%" width="25%" /></td><td></td></tr></table></td></tr><tr><td height="15" align="left" valign="top" style="font-family: Verdana;font-size: 12px; color: #000000; font-weight: normal; line-height: 18px"></td></tr></table></td></tr>';
                        SET @EmailBody += N'</table></td></tr></table></div></body></html>';
                    END;
        
                SET @SmsBody = N'Issue not resolved from [TD] for [EstablishmentName]. Client Mobile: [CustomerNumber]';

                SET @Start += 1;

            END;

    END;
