-- =============================================
-- Author:		<Author,,GD>
-- Create date:	13-June-2016
-- Description:	<Description,,>
-- Call : select * from GetFeedBackAutoSMSEmailNotificationText(13500) -- 1772
-- =============================================
CREATE FUNCTION dbo.GetFeedBackAutoSMSEmailNotificationText (@AnswerMasterId BIGINT)
RETURNS @Result TABLE
(
    SMSText NVARCHAR(MAX),
    EmailText NVARCHAR(MAX),
    NotificationText NVARCHAR(MAX),
    EmailSubject NVARCHAR(MAX),
    FeedBackReminderAlert NVARCHAR(MAX)
)
AS
BEGIN
    DECLARE @EstablishmentName NVARCHAR(500),
            @UserName NVARCHAR(50),
            @UserEmail NVARCHAR(50),
            @UserMobile NVARCHAR(50),
            @SMSText NVARCHAR(MAX),
            @EmailText NVARCHAR(MAX),
            @FeedBackReminderAlert NVARCHAR(MAX),
            @NotificationText NVARCHAR(MAX),
            @EmailSubject NVARCHAR(MAX),
            @EI NVARCHAR(15),
            @PI NVARCHAR(15),
            @URL NVARCHAR(100),
            @WebAppUrl NVARCHAR(100),
            @AnswerStatus NVARCHAR(50),
            @SmileType NVARCHAR(50),
            @CaptureDate NVARCHAR(50),
            @FixdbenchMark INT,
            @TestResult NVARCHAR(10);

    DECLARE @Questionnierid BIGINT;

    SELECT @Questionnierid = QuestionnaireId
    FROM dbo.AnswerMaster
    WHERE Id = @AnswerMasterId;

    SELECT @FixdbenchMark = FixedBenchMark
    FROM dbo.Questionnaire
    WHERE Id = @Questionnierid;


    --SELECT  @URL = KeyValue
    --FROM    dbo.AAAAConfigSettings
    --WHERE   KeyName = 'DocViewerRootFolderPath';

    --SELECT  @WebAppUrl = KeyValue + 'UploadFiles/'
    --FROM    dbo.AAAAConfigSettings
    --WHERE   KeyName = 'WebAppUrl';


    SELECT @URL = KeyValue
    FROM dbo.AAAAConfigSettings
    WHERE KeyName = 'DocViewerRootFolderPathCMS';

    SELECT @WebAppUrl = KeyValue
    FROM dbo.AAAAConfigSettings
    WHERE KeyName = 'DocViewerRootFolderPathWebApp';

    DECLARE @ImagePath NVARCHAR(MAX);
    SELECT @ImagePath = KeyValue + N'SeenClient/'
    FROM dbo.AAAAConfigSettings
    WHERE KeyName = 'DocViewerRootFolderPathWebApp';

    SELECT @EstablishmentName = EstablishmentName,
           @UserName = ISNULL(U.Name, ''),
           @EmailSubject = E.FeedbackEmailSubject,
           @EmailText = FeedbackEmailAlert,
           @FeedBackReminderAlert = E.FeedBackReminderAlert,
           @SMSText = FeedbackSMSAlert,
           @NotificationText = FeedbackNotificationAlert,
           @EI = Am.EI,
           @PI = CASE
                     WHEN ((CAST(CAST(ROUND(Am.PI, 0) AS INT) AS NVARCHAR(10))) < 0) THEN
                         'N/A'
                     ELSE
           (CAST(CAST(ROUND(Am.PI, 0) AS INT) AS NVARCHAR(10))) + N'%'
                 END,
           @UserEmail = ISNULL(U.Email, ''),
           @UserMobile = ISNULL(U.Mobile, ''),
           @AnswerStatus = Am.IsResolved,
           @SmileType = Am.IsPositive,
           @CaptureDate = dbo.ChangeDateFormat(DATEADD(MINUTE, Am.TimeOffSet, Am.CreatedOn), 'dd/MMM/yyyy hh:mm AM/PM'),
           @TestResult = CASE
                             WHEN (CAST(ROUND(Am.PI, 0) AS INT)) >= @FixdbenchMark THEN
                                 'Pass'
                             ELSE
                                 'Fail'
                         END
    FROM dbo.AnswerMaster AS Am
        LEFT OUTER JOIN dbo.AppUser AS U
            ON Am.AppUserId = U.Id
        INNER JOIN dbo.Establishment AS E
            ON Am.EstablishmentId = E.Id
    WHERE Am.Id = @AnswerMasterId;
    DECLARE @Tbl TABLE
    (
        Id BIGINT IDENTITY(1, 1),
        QuestionId BIGINT,
        Detail NVARCHAR(MAX),
        QuestionTypeId BIGINT
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
    SELECT QuestionId,
           CASE QuestionTypeId
               WHEN 8 THEN
                   dbo.ChangeDateFormat(Detail, 'dd/MMM/yyyy')
               WHEN 9 THEN
                   dbo.ChangeDateFormat(Detail, 'hh:mm AM/PM')
               WHEN 22 THEN
                   dbo.ChangeDateFormat(Detail, 'dd/MMM/yyyy hh:mm AM/PM')
               WHEN 17 THEN
                   dbo.GetFileTypeQuestionImageString(Detail, 0, QuestionId)
               WHEN 10 THEN
                   ISNULL(Detail, 'Anonymous')
               WHEN 11 THEN
                   ISNULL(Detail, 'Anonymous')
               WHEN 1 THEN
               (
                   SELECT NAME FROM dbo.Options WHERE id = dbo.Answers.OptionId
               )
               ELSE
                   Detail
           END
    FROM dbo.Answers
    WHERE AnswerMasterId = @AnswerMasterId;
    SELECT @End = COUNT(1)
    FROM @Tbl;


    DECLARE @table TABLE
    (
        Id BIGINT IDENTITY(1, 1),
        SeenclientQuestionId BIGINT,
        QuestionId BIGINT
    );
    DECLARE @detailtable TABLE
    (
        Id BIGINT,
        details NVARCHAR(MAX)
    );

    INSERT @table
    (
        SeenclientQuestionId,
        QuestionId
    )
    SELECT SeenClientQuestionIdRef,
           Id
    FROM dbo.Questions
    WHERE QuestionnaireId = @Questionnierid
          AND SeenClientQuestionIdRef IS NOT NULL
          AND IsDeleted = 0
          AND IsActive = 0;

    SELECT @End = COUNT(*)
    FROM @table;
    WHILE (@Start <= @End)
    BEGIN
        SELECT @QuestionId = QuestionId
        FROM @table
        WHERE Id = @Start;
        INSERT INTO @Tbl
        (
            QuestionId,
            Detail
        )
        SELECT @QuestionId,
               CASE QuestionTypeId
                   WHEN 17 THEN
                       dbo.GetFileTypeQuestionImageString(Detail, 1, QuestionId)
                   ELSE
                       Detail
               END
        FROM dbo.SeenClientAnswers
        WHERE SeenClientAnswerMasterId =
        (
            SELECT SeenClientAnswerMasterId
            FROM dbo.AnswerMaster
            WHERE Id = @AnswerMasterId
        )
              AND QuestionId =
              (
                  SELECT SeenclientQuestionId FROM @table WHERE Id = @Start
              )
              /*-------------Added by Disha - 07-SEP-2016 - For comparing child id------------------*/
              AND ISNULL(SeenClientAnswerChildId, 0) =
              (
                  SELECT SeenClientAnswerChildId
                  FROM dbo.AnswerMaster
                  WHERE Id = @AnswerMasterId
              );
        /*-----------------------------------------------------------------------------------*/
        SET @Start = @Start + 1;
    END;

    SELECT @Start = 1,
           @End = COUNT(1)
    FROM @Tbl;

    IF @EmailText <> ''
       OR @NotificationText <> ''
       OR @SMSText <> ''
       OR @FeedBackReminderAlert <> ''
       OR @EmailSubject <> ''
       OR @EmailText IS NOT NULL
       OR @NotificationText IS NOT NULL
       OR @SMSText IS NOT NULL
       OR @EmailSubject IS NOT NULL
       OR @FeedBackReminderAlert IS NOT NULL
    BEGIN
        WHILE @Start <= @End
        BEGIN
            SELECT @QuestionId = QuestionId,
                   @Details = Detail
            FROM @Tbl
            WHERE Id = @Start;

            SET @SMSText = REPLACE(@SMSText, '##[' + @QuestionId + ']##', ISNULL(@Details, ''));

            SET @EmailSubject = REPLACE(@EmailSubject, '##[' + @QuestionId + ']##', ISNULL(@Details, ''));

            SET @EmailText = REPLACE(@EmailText, '##[' + @QuestionId + ']##', ISNULL(@Details, ''));

            SET @NotificationText = REPLACE(@NotificationText, '##[' + @QuestionId + ']##', ISNULL(@Details, ''));
            SET @FeedBackReminderAlert
                = REPLACE(@FeedBackReminderAlert, '##[' + @QuestionId + ']##', ISNULL(@Details, ''));
            SET @Start += 1;
        END;


        SET @SMSText = REPLACE(@SMSText, '##[username]##', @UserName);
        SET @SMSText = REPLACE(@SMSText, '##[useremail]##', @UserEmail);
        SET @SMSText = REPLACE(@SMSText, '##[usermobile]##', @UserMobile);
        SET @SMSText = REPLACE(@SMSText, '##[EI]##', @EI);
        SET @SMSText = REPLACE(@SMSText, '##[PI]##', @PI);
        SET @SMSText = REPLACE(@SMSText, '##[Result]##', @TestResult);
        SET @SMSText = REPLACE(@SMSText, '##[establishment]##', @EstablishmentName);

        SET @EmailText = REPLACE(@EmailText, '##[username]##', @UserName);
        SET @EmailText = REPLACE(@EmailText, '##[useremail]##', @UserEmail);
        SET @EmailText = REPLACE(@EmailText, '##[usermobile]##', @UserMobile);
        SET @EmailText = REPLACE(@EmailText, '##[EI]##', @EI);
        SET @EmailText = REPLACE(@EmailText, '##[PI]##', @PI);
        SET @EmailText = REPLACE(@EmailText, '##[Result]##', @TestResult);

        SET @EmailText = REPLACE(@EmailText, '##[establishment]##', @EstablishmentName);
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
                                 + @URL + 'Content/Image/icon-smiley.png" alt="Positive" >'
                             WHEN 'Negative' THEN
                                 '<div style="width: 30px;height: 28px;display: inline-block;vertical-align: top;margin-right: 18px;position: initial;margin-top: 0;"><img src="'
                                 + @URL + 'Content/Image/icon-sad.png" alt="Negative" >'
                             ELSE
                                 '<div style="width: 30px;height: 28px;display: inline-block;vertical-align: top;margin-right: 18px;position: initial;margin-top: 0;"><img src="'
                                 + @URL + 'Content/Image/icon-neutral.png" alt="Neutral">'
                         END
                     );
        SET @EmailText = REPLACE(@EmailText, '##[capturedate]##', @CaptureDate);

        SET @EmailSubject = REPLACE(@EmailSubject, '##[username]##', @UserName);
        SET @EmailSubject = REPLACE(@EmailSubject, '##[useremail]##', @UserEmail);
        SET @EmailSubject = REPLACE(@EmailSubject, '##[usermobile]##', @UserMobile);
        SET @EmailSubject = REPLACE(@EmailSubject, '##[EI]##', @EI);
        SET @EmailSubject = REPLACE(@EmailSubject, '##[PI]##', @PI);
        SET @EmailSubject = REPLACE(@EmailSubject, '##[establishment]##', @EstablishmentName);
        SET @EmailSubject
            = REPLACE(
                         @EmailSubject,
                         '##[refno]##',
                         CAST(LEFT(REPLICATE(0, 10 - LEN(@AnswerMasterId)) + CAST(@AnswerMasterId AS VARCHAR(50)), 10) AS VARCHAR(50))
                     ); /* Disha - 21-OCT-2016 -- Added condition to replace refno in Email Subject */

        SET @NotificationText = REPLACE(@NotificationText, '##[username]##', @UserName);
        SET @NotificationText = REPLACE(@NotificationText, '##[useremail]##', @UserEmail);
        SET @NotificationText = REPLACE(@NotificationText, '##[usermobile]##', @UserMobile);
        SET @NotificationText = REPLACE(@NotificationText, '##[EI]##', @EI);
        SET @NotificationText = REPLACE(@NotificationText, '##[PI]##', @PI);
        SET @NotificationText = REPLACE(@NotificationText, '##[Result]##', @TestResult);
        SET @NotificationText = REPLACE(@NotificationText, '##[establishment]##', @EstablishmentName);

        SET @FeedBackReminderAlert = REPLACE(@FeedBackReminderAlert, '##[username]##', @UserName);
        SET @FeedBackReminderAlert = REPLACE(@FeedBackReminderAlert, '##[useremail]##', @UserEmail);
        SET @FeedBackReminderAlert = REPLACE(@FeedBackReminderAlert, '##[usermobile]##', @UserMobile);
        SET @FeedBackReminderAlert = REPLACE(@FeedBackReminderAlert, '##[EI]##', @EI);
        SET @FeedBackReminderAlert = REPLACE(@FeedBackReminderAlert, '##[PI]##', @PI);
        SET @FeedBackReminderAlert = REPLACE(@FeedBackReminderAlert, '##[Result]##', @TestResult);

        SET @FeedBackReminderAlert = REPLACE(@FeedBackReminderAlert, '##[establishment]##', @EstablishmentName);
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
                                 + @URL + 'Content/Image/icon-smiley.png" alt="Positive" >'
                             WHEN 'Negative' THEN
                                 '<div style="width: 30px;height: 28px;display: inline-block;vertical-align: top;margin-right: 18px;position: initial;margin-top: 0;"><img src="'
                                 + @URL + 'Content/Image/icon-sad.png" alt="Negative" >'
                             ELSE
                                 '<div style="width: 30px;height: 28px;display: inline-block;vertical-align: top;margin-right: 18px;position: initial;margin-top: 0;"><img src="'
                                 + @URL + 'Content/Image/icon-neutral.png" alt="Neutral">'
                         END
                     );
        SET @FeedBackReminderAlert = REPLACE(@FeedBackReminderAlert, '##[capturedate]##', @CaptureDate);
        SET @FeedBackReminderAlert
            = REPLACE(
                         @FeedBackReminderAlert,
                         '##[refno]##',
                         CAST(LEFT(REPLICATE(0, 10 - LEN(@AnswerMasterId)) + CAST(@AnswerMasterId AS VARCHAR(50)), 10) AS VARCHAR(50))
                     );

    END;

    INSERT INTO @Result
    (
        SMSText,
        EmailText,
        NotificationText,
        EmailSubject,
        FeedBackReminderAlert
    )
    VALUES
    (   ISNULL(@SMSText, ''),                                                             -- SMSText - nvarchar(max)
                                                                                          --ISNULL(@EmailText, '') , -- EmailText - nvarchar(max)
        ISNULL(dbo.PatternReplace(@EmailText, '##[%' + '[0-9]' + '%]##', ''), ''),
                                                                                          --ISNULL(@NotificationText, '') ,  -- NotificationText - nvarchar(max)		        
        ISNULL(dbo.PatternReplace(@NotificationText, '##[%' + '[0-9]' + '%]##', ''), ''), -- NotificationText - nvarchar(max)
        ISNULL(REPLACE(@EmailSubject, CHAR(13) + CHAR(10), ' '), 'Feedback Email Alert'), /* Disha - 20-OCT-2016 - Replace New line char as blank in subject */
        ISNULL(REPLACE(@FeedBackReminderAlert, CHAR(13) + CHAR(10), ' '), 'Feedback Reminder Alert')
    );

    RETURN;
END;

