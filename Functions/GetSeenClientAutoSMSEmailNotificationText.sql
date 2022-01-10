-- =============================================
-- Author:			Sunil
-- Create date:	13-June-2017
-- Description:	<Description,,>
-- SELECT * FROM DBO.GetSeenClientAutoSMSEmailNotificationText(978951,'','')
-- =============================================
CREATE FUNCTION dbo.GetSeenClientAutoSMSEmailNotificationText
(
    @SeenClientAnswerMasterId BIGINT,
    @EncryptedId NVARCHAR(500),
    @SeenClientAnswerChildId BIGINT
)
RETURNS @Result TABLE
(
    SMSText NVARCHAR(MAX),
    EmailText NVARCHAR(MAX),
    NotificationText NVARCHAR(MAX),
    EmailSubject NVARCHAR(MAX),
    CaptureSmsText NVARCHAR(MAX),
    CaptureEmailText NVARCHAR(MAX),
    CaptureNotification NVARCHAR(MAX),
    CaptureEmailSubject NVARCHAR(MAX),
    ReleaseDateValidationMessage NVARCHAR(MAX),
    MobiExpiredValidationMessage NVARCHAR(MAX),
    CaptureReminderAlert NVARCHAR(MAX),
    FeedBackReminderAlert NVARCHAR(MAX)
)
AS
BEGIN
    DECLARE @EstablishmentName NVARCHAR(500),
            @UserName NVARCHAR(50),
            @UserEmail NVARCHAR(50),
            @UserMobile NVARCHAR(50),
            @UserProfileImage NVARCHAR(500),
            @Url NVARCHAR(100),
            @ConfigUrl NVARCHAR(200),
            @SMSText NVARCHAR(MAX),
            @EmailText NVARCHAR(MAX),
            @NotificationText NVARCHAR(MAX),
            @EI NVARCHAR(50),
            @PI NVARCHAR(50),
            @EmailSubject NVARCHAR(MAX),
            @DocURL NVARCHAR(100),
            @WebAppUrl NVARCHAR(100),
            @AnswerStatus NVARCHAR(50),
            @SmileType NVARCHAR(50),
            @CaptureDate NVARCHAR(50),
            @CaptureSMSText NVARCHAR(MAX),
            @CaptureEmailText NVARCHAR(MAX),
            @CaptureNotificationText NVARCHAR(MAX),
            @CaptureEmailSubject NVARCHAR(MAX),
            @ReleaseDateValidationMessage NVARCHAR(MAX),
            @MobiExpiredValidationMessage NVARCHAR(MAX),
            @CaptureReminderAlert NVARCHAR(MAX),
            @FeedBackReminderAlert NVARCHAR(MAX);


    SELECT @DocURL = KeyValue
    FROM dbo.AAAAConfigSettings
    WHERE KeyName = 'DocViewerRootFolderPathCMS';

    SELECT @WebAppUrl = KeyValue
    FROM dbo.AAAAConfigSettings
    WHERE KeyName = 'DocViewerRootFolderPathWebApp';

    SELECT @EstablishmentName = EstablishmentName,
           @UserName = U.Name,
           @EmailText = SeenClientAutoEmail,
           @SMSText = SeenClientAutoSMS,
           @NotificationText = SeenClientAutoNotification,
           @EI = Am.EI,
           @PI = CASE
                     WHEN (CAST(CAST(ROUND(Am.PI, 0) AS INT) AS NVARCHAR(10))) < 0 THEN
                         'N/A'
                     ELSE
                         CAST(CAST(ROUND(Am.PI, 0) AS INT) AS NVARCHAR(10)) + N'%'
                 END,
           @UserEmail = U.Email,
           @UserMobile = U.Mobile,
           @EmailSubject = E.SeenClientEmailSubject,
           @UserProfileImage = ISNULL(U.ImageName, ''),
           @AnswerStatus = Am.IsResolved,
           @SmileType = Am.IsPositive,
           @CaptureDate = dbo.ChangeDateFormat(DATEADD(MINUTE, Am.TimeOffSet, Am.CreatedOn), 'dd/MMM/yyyy hh:mm AM/PM'),
           @CaptureSMSText = E.CaptureSMSAlert,
           @CaptureEmailText = E.CaptureEmailAlert,
           @CaptureNotificationText = E.CaptureNotificationAlert,
           @ReleaseDateValidationMessage = E.ReleaseDateValidationMessage,
           @MobiExpiredValidationMessage = E.MobiExpiredValidationMessage,
           @CaptureReminderAlert = E.CaptureReminderAlert,
           @FeedBackReminderAlert = E.FeedBackReminderAlert
    FROM dbo.SeenClientAnswerMaster AS Am
        INNER JOIN dbo.AppUser AS U
            ON Am.AppUserId = U.Id
        INNER JOIN dbo.Establishment AS E
            ON Am.EstablishmentId = E.Id
    WHERE Am.Id = @SeenClientAnswerMasterId;

    DECLARE @Tbl TABLE
    (
        Id BIGINT IDENTITY(1, 1),
        QuestionId BIGINT,
        Detail NVARCHAR(MAX)
    );
    DECLARE @Start BIGINT = 1,
            @End BIGINT,
            @Id BIGINT,
            @Details NVARCHAR(MAX),
            @QuestionId NVARCHAR(10);

    INSERT INTO @Tbl
    (
        QuestionId,
        Detail
    )
    SELECT SA.QuestionId,
           CASE QuestionTypeId
               WHEN 8 THEN
                   dbo.ChangeDateFormat(Detail, 'dd/MMM/yyyy')
               WHEN 9 THEN
                   dbo.ChangeDateFormat(Detail, 'hh:mm AM/PM')
               WHEN 22 THEN
                   dbo.ChangeDateFormat(Detail, 'dd/MMM/yyyy HH:mm')
               WHEN 17 THEN
                   dbo.GetFileTypeQuestionImageString(Detail, 1, SA.QuestionId)
               WHEN 1 THEN
               (
                   SELECT Name FROM dbo.SeenClientOptions WHERE Id = SA.OptionId
               )
               ELSE
                   Detail
           END
    FROM dbo.SeenClientAnswers SA
    WHERE SeenClientAnswerMasterId = @SeenClientAnswerMasterId
          AND ISNULL(SeenClientAnswerChildId, 0) = ISNULL(@SeenClientAnswerChildId, 0);
    SELECT @End = COUNT(1)
    FROM @Tbl;
    IF @EmailText <> ''
       OR @NotificationText <> ''
       OR @SMSText <> ''
       OR @EmailSubject <> ''
       OR @CaptureEmailText <> ''
       OR @CaptureSMSText <> ''
       OR @CaptureNotificationText <> ''
       OR @CaptureEmailSubject <> ''
       OR @EmailText IS NOT NULL
       OR @NotificationText IS NOT NULL
       OR @SMSText IS NOT NULL
       OR @EmailSubject IS NOT NULL
       OR @CaptureEmailText IS NOT NULL
       OR @CaptureSMSText IS NOT NULL
       OR @CaptureNotificationText IS NOT NULL
       OR @ReleaseDateValidationMessage <> ''
       OR @MobiExpiredValidationMessage <> ''
       OR @CaptureReminderAlert <> ''
       OR @FeedBackReminderAlert <> ''
       OR @ReleaseDateValidationMessage IS NOT NULL
       OR @MobiExpiredValidationMessage IS NOT NULL
       OR @CaptureReminderAlert IS NOT NULL
       OR @FeedBackReminderAlert IS NOT NULL
    BEGIN
        WHILE @Start <= @End
        BEGIN
            SELECT @QuestionId = QuestionId,
                   @Details = Detail
            FROM @Tbl
            WHERE Id = @Start;

            SET @SMSText = REPLACE(@SMSText, '##[' + @QuestionId + ']##', ISNULL(@Details, ''));

            SET @EmailText = REPLACE(@EmailText, '##[' + @QuestionId + ']##', ISNULL(@Details, ''));

            SET @EmailSubject = REPLACE(@EmailSubject, '##[' + @QuestionId + ']##', ISNULL(@Details, ''));

            SET @NotificationText = REPLACE(@NotificationText, '##[' + @QuestionId + ']##', ISNULL(@Details, ''));

            SET @CaptureSMSText = REPLACE(@CaptureSMSText, '##[' + @QuestionId + ']##', ISNULL(@Details, ''));

            SET @CaptureEmailText = REPLACE(@CaptureEmailText, '##[' + @QuestionId + ']##', ISNULL(@Details, ''));

            SET @CaptureEmailSubject
                = REPLACE(@CaptureEmailSubject, '##[' + @QuestionId + ']##', ISNULL(@Details, ''));

            SET @CaptureNotificationText
                = REPLACE(@CaptureNotificationText, '##[' + @QuestionId + ']##', ISNULL(@Details, ''));

            SET @ReleaseDateValidationMessage
                = REPLACE(@ReleaseDateValidationMessage, '##[' + @QuestionId + ']##', ISNULL(@Details, ''));

            SET @MobiExpiredValidationMessage
                = REPLACE(@MobiExpiredValidationMessage, '##[' + @QuestionId + ']##', ISNULL(@Details, ''));

            SET @CaptureReminderAlert
                = REPLACE(@CaptureReminderAlert, '##[' + @QuestionId + ']##', ISNULL(@Details, ''));

            SET @FeedBackReminderAlert
                = REPLACE(@FeedBackReminderAlert, '##[' + @QuestionId + ']##', ISNULL(@Details, ''));

            SET @Start += 1;
        END;

        SELECT @UserProfileImage = KeyValue + N'AppUser/' + @UserProfileImage
        FROM dbo.AAAAConfigSettings
        WHERE KeyName = 'DocViewerRootFolderPathCMS';

        SELECT @Url = KeyValue + N'Fb?Sid=' + @EncryptedId
        FROM dbo.AAAAConfigSettings
        WHERE KeyName = 'DocViewerRootFolderPath';

        SELECT @ConfigUrl = KeyValue + N'Fb/index?Sid=' + @EncryptedId
        FROM dbo.AAAAConfigSettings
        WHERE KeyName = 'DocViewerRootFolderPath';

        SET @SMSText = REPLACE(@SMSText, '##[link]##', '$$' + @Url + '$$');
        SET @SMSText = REPLACE(@SMSText, '##[EI]##', @EI);
        SET @SMSText = REPLACE(@SMSText, '##[PI]##', @PI);
        SET @SMSText = REPLACE(@SMSText, '##[username]##', @UserName);
        SET @SMSText = REPLACE(@SMSText, '##[useremail]##', @UserEmail);
        SET @SMSText = REPLACE(@SMSText, '##[usermobile]##', @UserMobile);
        SET @SMSText = REPLACE(@SMSText, '##[establishment]##', @EstablishmentName);


        SET @CaptureSMSText = REPLACE(@CaptureSMSText, '##[EI]##', @EI);
        SET @CaptureSMSText = REPLACE(@CaptureSMSText, '##[PI]##', @PI);
        SET @CaptureSMSText = REPLACE(@CaptureSMSText, '##[username]##', @UserName);
        SET @CaptureSMSText = REPLACE(@CaptureSMSText, '##[useremail]##', @UserEmail);
        SET @CaptureSMSText = REPLACE(@CaptureSMSText, '##[usermobile]##', @UserMobile);
        SET @CaptureSMSText = REPLACE(@CaptureSMSText, '##[establishment]##', @EstablishmentName);

        -- added by mittal to resolve ? issue in link 
        SET @EmailText = REPLACE(@EmailText, '##[link]##?', '##[link]##');
        -- end
        SET @EmailText = REPLACE(@EmailText, '##[link]##', '$$' + @Url + '$$');
        SET @EmailText = REPLACE(@EmailText, '##[Configlink]##', @ConfigUrl);
        SET @EmailText = REPLACE(@EmailText, '##[EI]##', @EI);
        SET @EmailText = REPLACE(@EmailText, '##[PI]##', @PI);
        SET @EmailText = REPLACE(@EmailText, '##[username]##', @UserName);
        SET @EmailText = REPLACE(@EmailText, '##[useremail]##', @UserEmail);
        SET @EmailText = REPLACE(@EmailText, '##[usermobile]##', @UserMobile);
        SET @EmailText = REPLACE(@EmailText, '##[establishment]##', @EstablishmentName);
        SET @EmailText
            = REPLACE(
                         @EmailText,
                         '##[userprofilepicture]##',
                         '<img src=''' + @UserProfileImage + ''' alt=''' + @UserName + ''' style=''max-width:20%;'' />'
                     );
        SET @EmailText = REPLACE(   @EmailText,
                                    '##[bgcolor]##',
                                    CASE @AnswerStatus
                                        WHEN 'resolved' THEN
                                            'bg-green'
                                        ELSE
                                            ''
                                    END
                                );
        SET @EmailText = REPLACE(@EmailText, 'class="view-image"', 'style="max-width: 200px;max-height: 200px;"');
        SET @EmailText
            = REPLACE(
                         @EmailText,
                         '<div class="##[smiley]##">',
                         CASE @SmileType
                             WHEN 'Positive' THEN
                                 '<div style="width: 30px;height: 28px;display: inline-block;vertical-align: top;margin-right: 18px;position: initial;margin-top: 0;"><img src="'
                                 + @DocURL + 'Content/Image/icon-smiley.png" alt="Positive">'
                             WHEN 'Negative' THEN
                                 '<div style="width: 30px;height: 28px;display: inline-block;vertical-align: top;margin-right: 18px;position: initial;margin-top: 0;"><img src="'
                                 + @DocURL + 'Content/Image/icon-sad.png" alt="Negative">'
                             ELSE
                                 '<div style="width: 30px;height: 28px;display: inline-block;vertical-align: top;margin-right: 18px;position: initial;margin-top: 0;"><img src="'
                                 + @DocURL + 'Content/Image/icon-neutral.png" alt="Neutral">'
                         END
                     );
        SET @EmailText = REPLACE(@EmailText, '##[capturedate]##', @CaptureDate);


        SET @CaptureEmailText = REPLACE(@CaptureEmailText, '##[EI]##', @EI);
        SET @CaptureEmailText = REPLACE(@CaptureEmailText, '##[PI]##', @PI);
        SET @CaptureEmailText = REPLACE(@CaptureEmailText, '##[username]##', @UserName);
        SET @CaptureEmailText = REPLACE(@CaptureEmailText, '##[useremail]##', @UserEmail);
        SET @CaptureEmailText = REPLACE(@CaptureEmailText, '##[usermobile]##', @UserMobile);
        SET @CaptureEmailText = REPLACE(@CaptureEmailText, '##[establishment]##', @EstablishmentName);
        SET @CaptureEmailText
            = REPLACE(
                         @CaptureEmailText,
                         '##[userprofilepicture]##',
                         '<img src=''' + @UserProfileImage + ''' alt=''' + @UserName + ''' style=''max-width:20%;'' />'
                     );
        SET @CaptureEmailText = REPLACE(   @CaptureEmailText,
                                           '##[bgcolor]##',
                                           CASE @AnswerStatus
                                               WHEN 'resolved' THEN
                                                   'bg-green'
                                               ELSE
                                                   ''
                                           END
                                       );
        SET @CaptureEmailText
            = REPLACE(@CaptureEmailText, 'class="view-image"', 'style="max-width: 200px;max-height: 200px;"');
        SET @CaptureEmailText
            = REPLACE(
                         @CaptureEmailText,
                         '<div class="##[smiley]##">',
                         CASE @SmileType
                             WHEN 'Positive' THEN
                                 '<div style="width: 30px;height: 28px;display: inline-block;vertical-align: top;margin-right: 18px;position: initial;margin-top: 0;"><img src="'
                                 + @DocURL + 'Content/Image/icon-smiley.png" alt="Positive">'
                             WHEN 'Negative' THEN
                                 '<div style="width: 30px;height: 28px;display: inline-block;vertical-align: top;margin-right: 18px;position: initial;margin-top: 0;"><img src="'
                                 + @DocURL + 'Content/Image/icon-sad.png" alt="Negative">'
                             ELSE
                                 '<div style="width: 30px;height: 28px;display: inline-block;vertical-align: top;margin-right: 18px;position: initial;margin-top: 0;"><img src="'
                                 + @DocURL + 'Content/Image/icon-neutral.png" alt="Neutral">'
                         END
                     );
        SET @CaptureEmailText = REPLACE(@CaptureEmailText, '##[capturedate]##', @CaptureDate);

        SET @ReleaseDateValidationMessage = REPLACE(@ReleaseDateValidationMessage, '##[EI]##', @EI);
        SET @ReleaseDateValidationMessage = REPLACE(@ReleaseDateValidationMessage, '##[PI]##', @PI);
        SET @ReleaseDateValidationMessage = REPLACE(@ReleaseDateValidationMessage, '##[username]##', @UserName);
        SET @ReleaseDateValidationMessage = REPLACE(@ReleaseDateValidationMessage, '##[useremail]##', @UserEmail);
        SET @ReleaseDateValidationMessage = REPLACE(@ReleaseDateValidationMessage, '##[usermobile]##', @UserMobile);
        SET @ReleaseDateValidationMessage
            = REPLACE(@ReleaseDateValidationMessage, '##[establishment]##', @EstablishmentName);
        SET @ReleaseDateValidationMessage
            = REPLACE(
                         @ReleaseDateValidationMessage,
                         '##[userprofilepicture]##',
                         '<img src=''' + @UserProfileImage + ''' alt=''' + @UserName + ''' style=''max-width:20%;'' />'
                     );
        SET @ReleaseDateValidationMessage
            = REPLACE(   @ReleaseDateValidationMessage,
                         '##[bgcolor]##',
                         CASE @AnswerStatus
                             WHEN 'resolved' THEN
                                 'bg-green'
                             ELSE
                                 ''
                         END
                     );
        SET @ReleaseDateValidationMessage
            = REPLACE(
                         @ReleaseDateValidationMessage,
                         'class="view-image"',
                         'style="max-width: 200px;max-height: 200px;"'
                     );
        SET @ReleaseDateValidationMessage
            = REPLACE(
                         @ReleaseDateValidationMessage,
                         '<div class="##[smiley]##">',
                         CASE @SmileType
                             WHEN 'Positive' THEN
                                 '<div style="width: 30px;height: 28px;display: inline-block;vertical-align: top;margin-right: 18px;position: initial;margin-top: 0;"><img src="'
                                 + @DocURL + 'Content/Image/icon-smiley.png" alt="Positive">'
                             WHEN 'Negative' THEN
                                 '<div style="width: 30px;height: 28px;display: inline-block;vertical-align: top;margin-right: 18px;position: initial;margin-top: 0;"><img src="'
                                 + @DocURL + 'Content/Image/icon-sad.png" alt="Negative">'
                             ELSE
                                 '<div style="width: 30px;height: 28px;display: inline-block;vertical-align: top;margin-right: 18px;position: initial;margin-top: 0;"><img src="'
                                 + @DocURL + 'Content/Image/icon-neutral.png" alt="Neutral">'
                         END
                     );
        SET @ReleaseDateValidationMessage
            = REPLACE(
                         @ReleaseDateValidationMessage,
                         '##[capturedate]##',
                         FORMAT(CAST(@CaptureDate AS DATETIME), 'dd/MMM/yy HH:mm')
                     );

        SET @MobiExpiredValidationMessage = REPLACE(@MobiExpiredValidationMessage, '##[EI]##', @EI);
        SET @MobiExpiredValidationMessage = REPLACE(@MobiExpiredValidationMessage, '##[PI]##', @PI);
        SET @MobiExpiredValidationMessage = REPLACE(@MobiExpiredValidationMessage, '##[username]##', @UserName);
        SET @MobiExpiredValidationMessage = REPLACE(@MobiExpiredValidationMessage, '##[useremail]##', @UserEmail);
        SET @MobiExpiredValidationMessage = REPLACE(@MobiExpiredValidationMessage, '##[usermobile]##', @UserMobile);
        SET @MobiExpiredValidationMessage
            = REPLACE(@MobiExpiredValidationMessage, '##[establishment]##', @EstablishmentName);
        SET @MobiExpiredValidationMessage
            = REPLACE(
                         @MobiExpiredValidationMessage,
                         '##[userprofilepicture]##',
                         '<img src=''' + @UserProfileImage + ''' alt=''' + @UserName + ''' style=''max-width:20%;'' />'
                     );
        SET @MobiExpiredValidationMessage
            = REPLACE(   @MobiExpiredValidationMessage,
                         '##[bgcolor]##',
                         CASE @AnswerStatus
                             WHEN 'resolved' THEN
                                 'bg-green'
                             ELSE
                                 ''
                         END
                     );
        SET @MobiExpiredValidationMessage
            = REPLACE(
                         @MobiExpiredValidationMessage,
                         'class="view-image"',
                         'style="max-width: 200px;max-height: 200px;"'
                     );
        SET @MobiExpiredValidationMessage
            = REPLACE(
                         @MobiExpiredValidationMessage,
                         '<div class="##[smiley]##">',
                         CASE @SmileType
                             WHEN 'Positive' THEN
                                 '<div style="width: 30px;height: 28px;display: inline-block;vertical-align: top;margin-right: 18px;position: initial;margin-top: 0;"><img src="'
                                 + @DocURL + 'Content/Image/icon-smiley.png" alt="Positive">'
                             WHEN 'Negative' THEN
                                 '<div style="width: 30px;height: 28px;display: inline-block;vertical-align: top;margin-right: 18px;position: initial;margin-top: 0;"><img src="'
                                 + @DocURL + 'Content/Image/icon-sad.png" alt="Negative">'
                             ELSE
                                 '<div style="width: 30px;height: 28px;display: inline-block;vertical-align: top;margin-right: 18px;position: initial;margin-top: 0;"><img src="'
                                 + @DocURL + 'Content/Image/icon-neutral.png" alt="Neutral">'
                         END
                     );
        SET @MobiExpiredValidationMessage
            = REPLACE(
                         @MobiExpiredValidationMessage,
                         '##[capturedate]##',
                         FORMAT(CAST(@CaptureDate AS DATETIME), 'dd/MMM/yy HH:mm')
                     );

        SET @CaptureReminderAlert = REPLACE(@CaptureReminderAlert, '##[EI]##', @EI);
        SET @CaptureReminderAlert = REPLACE(@CaptureReminderAlert, '##[PI]##', @PI);
        SET @CaptureReminderAlert = REPLACE(@CaptureReminderAlert, '##[username]##', @UserName);
        SET @CaptureReminderAlert = REPLACE(@CaptureReminderAlert, '##[useremail]##', @UserEmail);
        SET @CaptureReminderAlert = REPLACE(@CaptureReminderAlert, '##[usermobile]##', @UserMobile);
        SET @CaptureReminderAlert = REPLACE(@CaptureReminderAlert, '##[establishment]##', @EstablishmentName);
        SET @CaptureReminderAlert
            = REPLACE(
                         @CaptureReminderAlert,
                         '##[userprofilepicture]##',
                         '<img src=''' + @UserProfileImage + ''' alt=''' + @UserName + ''' style=''max-width:20%;'' />'
                     );
        SET @CaptureReminderAlert = REPLACE(   @CaptureReminderAlert,
                                               '##[bgcolor]##',
                                               CASE @AnswerStatus
                                                   WHEN 'resolved' THEN
                                                       'bg-green'
                                                   ELSE
                                                       ''
                                               END
                                           );
        SET @CaptureReminderAlert
            = REPLACE(@CaptureReminderAlert, 'class="view-image"', 'style="max-width: 200px;max-height: 200px;"');
        SET @CaptureReminderAlert
            = REPLACE(
                         @CaptureReminderAlert,
                         '<div class="##[smiley]##">',
                         CASE @SmileType
                             WHEN 'Positive' THEN
                                 '<div style="width: 30px;height: 28px;display: inline-block;vertical-align: top;margin-right: 18px;position: initial;margin-top: 0;"><img src="'
                                 + @DocURL + 'Content/Image/icon-smiley.png" alt="Positive">'
                             WHEN 'Negative' THEN
                                 '<div style="width: 30px;height: 28px;display: inline-block;vertical-align: top;margin-right: 18px;position: initial;margin-top: 0;"><img src="'
                                 + @DocURL + 'Content/Image/icon-sad.png" alt="Negative">'
                             ELSE
                                 '<div style="width: 30px;height: 28px;display: inline-block;vertical-align: top;margin-right: 18px;position: initial;margin-top: 0;"><img src="'
                                 + @DocURL + 'Content/Image/icon-neutral.png" alt="Neutral">'
                         END
                     );
        SET @CaptureReminderAlert
            = REPLACE(
                         @CaptureReminderAlert,
                         '##[capturedate]##',
                         FORMAT(CAST(@CaptureDate AS DATETIME), 'dd/MMM/yy HH:mm')
                     );

        SET @FeedBackReminderAlert = REPLACE(@FeedBackReminderAlert, '##[EI]##', @EI);
        SET @FeedBackReminderAlert = REPLACE(@FeedBackReminderAlert, '##[PI]##', @PI);
        SET @FeedBackReminderAlert = REPLACE(@FeedBackReminderAlert, '##[username]##', @UserName);
        SET @FeedBackReminderAlert = REPLACE(@FeedBackReminderAlert, '##[useremail]##', @UserEmail);
        SET @FeedBackReminderAlert = REPLACE(@FeedBackReminderAlert, '##[usermobile]##', @UserMobile);
        SET @FeedBackReminderAlert = REPLACE(@FeedBackReminderAlert, '##[establishment]##', @EstablishmentName);
        SET @FeedBackReminderAlert
            = REPLACE(
                         @FeedBackReminderAlert,
                         '##[userprofilepicture]##',
                         '<img src=''' + @UserProfileImage + ''' alt=''' + @UserName + ''' style=''max-width:20%;'' />'
                     );
        SET @FeedBackReminderAlert = REPLACE(   @FeedBackReminderAlert,
                                                '##[bgcolor]##',
                                                CASE @AnswerStatus
                                                    WHEN 'resolved' THEN
                                                        'bg-green'
                                                    ELSE
                                                        ''
                                                END
                                            );
        SET @FeedBackReminderAlert
            = REPLACE(@FeedBackReminderAlert, 'class="view-image"', 'style="max-width: 200px;max-height: 200px;"');
        SET @FeedBackReminderAlert
            = REPLACE(
                         @FeedBackReminderAlert,
                         '<div class="##[smiley]##">',
                         CASE @SmileType
                             WHEN 'Positive' THEN
                                 '<div style="width: 30px;height: 28px;display: inline-block;vertical-align: top;margin-right: 18px;position: initial;margin-top: 0;"><img src="'
                                 + @DocURL + 'Content/Image/icon-smiley.png" alt="Positive">'
                             WHEN 'Negative' THEN
                                 '<div style="width: 30px;height: 28px;display: inline-block;vertical-align: top;margin-right: 18px;position: initial;margin-top: 0;"><img src="'
                                 + @DocURL + 'Content/Image/icon-sad.png" alt="Negative">'
                             ELSE
                                 '<div style="width: 30px;height: 28px;display: inline-block;vertical-align: top;margin-right: 18px;position: initial;margin-top: 0;"><img src="'
                                 + @DocURL + 'Content/Image/icon-neutral.png" alt="Neutral">'
                         END
                     );
        SET @FeedBackReminderAlert
            = REPLACE(
                         @FeedBackReminderAlert,
                         '##[capturedate]##',
                         FORMAT(CAST(@CaptureDate AS DATETIME), 'dd/MMM/yy HH:mm')
                     );


        SET @EmailSubject = REPLACE(@EmailSubject, '##[link]##', '$$' + @Url + '$$');
        SET @EmailSubject = REPLACE(@EmailSubject, '##[EI]##', @EI);
        SET @EmailSubject = REPLACE(@EmailSubject, '##[PI]##', @PI);
        SET @EmailSubject = REPLACE(@EmailSubject, '##[username]##', @UserName);
        SET @EmailSubject = REPLACE(@EmailSubject, '##[useremail]##', @UserEmail);
        SET @EmailSubject = REPLACE(@EmailSubject, '##[usermobile]##', @UserMobile);
        SET @EmailSubject = REPLACE(@EmailSubject, '##[establishment]##', @EstablishmentName);
        SET @EmailSubject
            = REPLACE(
                         @EmailSubject,
                         '##[refno]##',
                         CAST(LEFT(REPLICATE(0, 10 - LEN(@SeenClientAnswerMasterId))
                                   + CAST(@SeenClientAnswerMasterId AS VARCHAR(50)), 10) AS VARCHAR(50))
                     ); /* Disha - 21-OCT-2016 -- Added condition to replace refno in Email Subject */


        SET @CaptureEmailSubject = REPLACE(@CaptureEmailSubject, '##[EI]##', @EI);
        SET @CaptureEmailSubject = REPLACE(@CaptureEmailSubject, '##[PI]##', @PI);
        SET @CaptureEmailSubject = REPLACE(@CaptureEmailSubject, '##[username]##', @UserName);
        SET @CaptureEmailSubject = REPLACE(@CaptureEmailSubject, '##[useremail]##', @UserEmail);
        SET @CaptureEmailSubject = REPLACE(@CaptureEmailSubject, '##[usermobile]##', @UserMobile);
        SET @CaptureEmailSubject = REPLACE(@CaptureEmailSubject, '##[establishment]##', @EstablishmentName);
        SET @CaptureEmailSubject
            = REPLACE(
                         @CaptureEmailSubject,
                         '##[refno]##',
                         CAST(LEFT(REPLICATE(0, 10 - LEN(@SeenClientAnswerMasterId))
                                   + CAST(@SeenClientAnswerMasterId AS VARCHAR(50)), 10) AS VARCHAR(50))
                     ); /* Disha - 21-OCT-2016 -- Added condition to replace refno in Email Subject */


        SET @NotificationText = REPLACE(@NotificationText, '##[link]##', @Url);
        SET @NotificationText = REPLACE(@NotificationText, '##[EI]##', @EI);
        SET @NotificationText = REPLACE(@NotificationText, '##[PI]##', @PI);
        SET @NotificationText = REPLACE(@NotificationText, '##[username]##', @UserName);
        SET @NotificationText = REPLACE(@NotificationText, '##[useremail]##', @UserEmail);
        SET @NotificationText = REPLACE(@NotificationText, '##[usermobile]##', @UserMobile);
        SET @NotificationText = REPLACE(@NotificationText, '##[establishment]##', @EstablishmentName);


        SET @CaptureNotificationText = REPLACE(@CaptureNotificationText, '##[link]##', @Url);
        SET @CaptureNotificationText = REPLACE(@CaptureNotificationText, '##[EI]##', @EI);
        SET @CaptureNotificationText = REPLACE(@CaptureNotificationText, '##[PI]##', @PI);
        SET @CaptureNotificationText = REPLACE(@CaptureNotificationText, '##[username]##', @UserName);
        SET @CaptureNotificationText = REPLACE(@CaptureNotificationText, '##[useremail]##', @UserEmail);
        SET @CaptureNotificationText = REPLACE(@CaptureNotificationText, '##[usermobile]##', @UserMobile);
        SET @CaptureNotificationText = REPLACE(@CaptureNotificationText, '##[establishment]##', @EstablishmentName);

        --Maulik
        --WHILE CHARINDEX('##', @EmailText) > 0
        --BEGIN

        --    SET @EmailText
        --        = LEFT(@EmailText, CHARINDEX('##', @EmailText) - 1)
        --          + SUBSTRING(
        --                         @EmailText,
        --                         CHARINDEX('##', @EmailText, CHARINDEX('##', @EmailText) + 1) + 2,
        --                         LEN(@EmailText)
        --                     );
        --END;

        --WHILE CHARINDEX('##', @CaptureEmailText) > 0
        --BEGIN

        --    SET @CaptureEmailText
        --        = LEFT(@CaptureEmailText, CHARINDEX('##', @CaptureEmailText) - 1)
        --          + SUBSTRING(
        --                         @CaptureEmailText,
        --                         CHARINDEX('##', @CaptureEmailText, CHARINDEX('##', @CaptureEmailText) + 1) + 2,
        --                         LEN(@CaptureEmailText)
        --                     );
        --END;



    END;
    INSERT INTO @Result
    (
        SMSText,
        EmailText,
        NotificationText,
        EmailSubject,
        CaptureSmsText,
        CaptureEmailText,
        CaptureNotification,
        CaptureEmailSubject,
        ReleaseDateValidationMessage,
        MobiExpiredValidationMessage,
        CaptureReminderAlert,
        FeedBackReminderAlert
    )
    VALUES
    (   ISNULL(@SMSText, ''),                                                         -- SMSText - nvarchar(max)
        ISNULL(dbo.PatternReplace(@EmailText, '##[%' + '[0-9]' + '%]##', 'N/A'), ''), -- EmailText - nvarchar(max)
        ISNULL(dbo.PatternReplace(@NotificationText, '##[%' + '[0-9]' + '%]##', 'N/A'), ''),
        ISNULL(
                  REPLACE(@EmailSubject, CHAR(13) + CHAR(10), ' '), /* Disha - 20-OCT-2016 - Replace New line char as blank in subject */
                  'Seenclient Captured For ' + @EstablishmentName
              ),
        ISNULL(@CaptureSMSText, ''),                                                  -- SMSText - nvarchar(max)
        ISNULL(@CaptureEmailText, ''),                                                -- EmailText - nvarchar(max)
        ISNULL(@CaptureNotificationText, ''),                                         -- NotificationText - nvarchar(max)			        
        ISNULL(
                  REPLACE(@CaptureEmailSubject, CHAR(13) + CHAR(10), ' '), /* Disha - 20-OCT-2016 - Replace New line char as blank in subject */
                  'Captured Alert For ' + @EstablishmentName
              ),
        ISNULL(@ReleaseDateValidationMessage, ''),
        ISNULL(@MobiExpiredValidationMessage, ''),
        ISNULL(@CaptureReminderAlert, ''),
        ISNULL(@FeedBackReminderAlert, '')
    );

    RETURN;
END;





