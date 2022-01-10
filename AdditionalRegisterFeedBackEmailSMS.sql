
-- =============================================
-- Author:		<Author,,GD>
-- Create date: <Create Date,,26 Jun 2015>
-- Description:	<Description,,>
-- Call SP:		AdditionalRegisterFeedBackEmailSMS 160086,1037,12856,1243
-- =============================================
CREATE PROCEDURE [dbo].[AdditionalRegisterFeedBackEmailSMS]
    @AnswerMasterId BIGINT,
    @QuestionnaireId BIGINT,
    @EstablishmentId BIGINT,
    @AppUserId BIGINT
AS
BEGIN
	SET DEADLOCK_PRIORITY NORMAL;
	BEGIN TRY
    
    DECLARE @EstablishmentName NVARCHAR(500),
            @UserName NVARCHAR(50),
            @UserEmail NVARCHAR(50),
            @UserMobile NVARCHAR(50),
            @UserProfileImage NVARCHAR(500),
            @Url NVARCHAR(100),
            @EI NVARCHAR(50),
            @PI NVARCHAR(50),
            @AnswerStatus NVARCHAR(50),
            @SmileType NVARCHAR(50),
            @TimeOffSet INT = 0,
            @UserEmailId NVARCHAR(500),
            @ISAdditionalFeedbackEmail BIT,
            @AdditionalFeedbackEmails NVARCHAR(MAX),
            @AdditionalFeedbackEmailSubject NVARCHAR(MAX),
            @AdditionalFeedbackEmailBody NVARCHAR(MAX),
            @ISAdditionalFeedbackSMS BIT,
            @AdditionalFeedbackMobile NVARCHAR(500),
            @AdditionalFeedbackSMSBody NVARCHAR(MAX),
            @FeedbackEmailSubject NVARCHAR(2000),
            @FeedbackEmailBody NVARCHAR(MAX),
            @FeedbackSMSBody NVARCHAR(MAX),
            @CaptureDate DATETIME,
            @TestResult NVARCHAR(10),
            @FixdbenchMark INT;


    SELECT @EstablishmentName = EstablishmentName,
           @UserName = ISNULL(U.Name, ''),
           @UserEmail = ISNULL(U.Email, ''),
           @UserMobile = ISNULL(U.Mobile, ''),
           @UserProfileImage = ISNULL(U.ImageName, ''),
           @EI = AM.EI,
           @PI = (CAST(CAST(ROUND(AM.PI, 0) AS INT) AS NVARCHAR(10))) + '%',
           @AnswerStatus = AM.IsResolved,
           @SmileType = AM.IsPositive,
           @CaptureDate = dbo.ChangeDateFormat(DATEADD(MINUTE, AM.TimeOffSet, AM.CreatedOn), 'dd/MMM/yyyy hh:mm AM/PM'),
           @ISAdditionalFeedbackEmail = E.ISAdditionalFeedbackEmail,
           @AdditionalFeedbackEmails = E.AdditionalFeedbackEmails,
           @AdditionalFeedbackEmailSubject = E.AdditionalFeedbackEmailSubject,
           @AdditionalFeedbackEmailBody = E.AdditionalFeedbackEmailBody,
           @ISAdditionalFeedbackSMS = E.ISAdditionalFeedbackSMS,
           @AdditionalFeedbackMobile = E.AdditionalFeedbackMobile,
           @AdditionalFeedbackSMSBody = E.AdditionalFeedbackSMSBody,
           @TimeOffSet = E.TimeOffSet,
           @TestResult = CASE
                             WHEN (CAST(ROUND(AM.PI, 0) AS INT)) >= @FixdbenchMark THEN
                                 'Pass'
                             ELSE
                                 'Fail'
                         END
    FROM dbo.AnswerMaster AS AM
        LEFT OUTER JOIN dbo.AppUser AS U
            ON AM.AppUserId = U.Id
        INNER JOIN dbo.Establishment AS E
            ON AM.EstablishmentId = E.Id
        INNER JOIN dbo.EstablishmentGroup AS Eg
            ON E.EstablishmentGroupId = Eg.Id
    WHERE E.IsDeleted = 0
          AND E.Id = @EstablishmentId
          AND AM.Id = @AnswerMasterId;


    --added by mittal
    --SELECT @AdditionalFeedbackSMSBody = SMSText,
    --       @AdditionalFeedbackEmailBody = EmailText,
    --       @AdditionalFeedbackEmailSubject = EmailSubject
    --FROM dbo.GetAdditionalFeedBackAutoSMSEmailText(@AnswerMasterId);
    --end

    PRINT @EstablishmentName;
    PRINT @UserName;
    PRINT @UserEmail;
    PRINT @UserMobile;
    PRINT @UserProfileImage;
    PRINT @EI;
    PRINT @PI;
    PRINT @AnswerStatus;
    PRINT @SmileType;
    PRINT @CaptureDate;
    PRINT @ISAdditionalFeedbackEmail;
    PRINT @AdditionalFeedbackEmails;
    PRINT @AdditionalFeedbackEmailSubject;
    PRINT @AdditionalFeedbackEmailBody;
    PRINT @ISAdditionalFeedbackSMS;
    PRINT @AdditionalFeedbackMobile;
    PRINT @AdditionalFeedbackSMSBody;

    DECLARE @Questionnierid BIGINT;

    SELECT @Questionnierid = QuestionnaireId
    FROM dbo.AnswerMaster
    WHERE Id = @AnswerMasterId;

    PRINT @Questionnierid;

    SELECT @FixdbenchMark = FixedBenchMark
    FROM dbo.Questionnaire
    WHERE Id = @Questionnierid;

    SELECT @Url = KeyValue
    FROM dbo.AAAAConfigSettings
    WHERE KeyName = 'DocViewerRootFolderPathCMS';


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
                   SELECT Name FROM dbo.Options WHERE Id = dbo.Answers.OptionId
               )
               ELSE
                   Detail
           END
    FROM dbo.Answers
    WHERE AnswerMasterId = @AnswerMasterId;
    SELECT @End = COUNT(1)
    FROM @Tbl;

    SELECT *
    FROM @Tbl;



    DECLARE @table TABLE
    (
        Id BIGINT IDENTITY(1, 1),
        SeenclientQuestionId BIGINT,
        QuestionId BIGINT
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
			   WHEN 17
			   THEN dbo.GetFileTypeQuestionImageString(Detail, 1 , QuestionId)
			   ELSE
			   Detail
			   END
        FROM dbo.SeenClientAnswers
        WHERE SeenClientAnswerMasterId =(
            SELECT SeenClientAnswerMasterId
            FROM dbo.AnswerMaster
            WHERE Id = @AnswerMasterId)
              AND QuestionId =(SELECT SeenclientQuestionId FROM @table WHERE Id = @Start)
              AND ISNULL(SeenClientAnswerChildId, 0) =
              (   SELECT SeenClientAnswerChildId
                  FROM dbo.AnswerMaster
                  WHERE Id = @AnswerMasterId
              );
        SET @Start = @Start + 1;
    END;


    SELECT @Start = 1,
           @End = COUNT(1)
    FROM @Tbl;

    PRINT @End;
    IF @AdditionalFeedbackEmailSubject <> ''
       OR @AdditionalFeedbackEmailBody <> ''
       OR @AdditionalFeedbackSMSBody <> ''
       OR @AdditionalFeedbackEmailSubject IS NOT NULL
       OR @AdditionalFeedbackEmailBody IS NOT NULL
       OR @AdditionalFeedbackSMSBody IS NOT NULL
    BEGIN
        WHILE @Start <= @End
        BEGIN
            SELECT @QuestionId = QuestionId,
                   @Details = Detail
            FROM @Tbl
            WHERE Id = @Start;

            SET @AdditionalFeedbackEmailSubject
                = REPLACE(@AdditionalFeedbackEmailSubject, '##[' + @QuestionId + ']##', ISNULL(@Details, ''));

            SET @AdditionalFeedbackEmailBody
                = REPLACE(@AdditionalFeedbackEmailBody, '##[' + @QuestionId + ']##', ISNULL(@Details, ''));

            SET @AdditionalFeedbackSMSBody
                = REPLACE(@AdditionalFeedbackSMSBody, '##[' + @QuestionId + ']##', ISNULL(@Details, ''));

            SET @Start += 1;
        END;


        SELECT @Url = KeyValue
        FROM dbo.AAAAConfigSettings
        WHERE KeyName = 'DocViewerRootFolderPathCMS';


        SET @AdditionalFeedbackEmailBody = REPLACE(@AdditionalFeedbackEmailBody, '##[username]##', @UserName);
        SET @AdditionalFeedbackEmailBody = REPLACE(@AdditionalFeedbackEmailBody, '##[useremail]##', @UserEmail);
        SET @AdditionalFeedbackEmailBody = REPLACE(@AdditionalFeedbackEmailBody, '##[usermobile]##', @UserMobile);
        SET @AdditionalFeedbackEmailBody = REPLACE(@AdditionalFeedbackEmailBody, '##[EI]##', @EI);
        SET @AdditionalFeedbackEmailBody = REPLACE(@AdditionalFeedbackEmailBody, '##[PI]##', @PI);
        SET @AdditionalFeedbackEmailBody = REPLACE(@AdditionalFeedbackEmailBody, '##[Result]##', @TestResult);
        SET @AdditionalFeedbackEmailBody
            = REPLACE(@AdditionalFeedbackEmailBody, '##[establishment]##', @EstablishmentName);
        SET @AdditionalFeedbackEmailBody
            = REPLACE(   @AdditionalFeedbackEmailBody,
                         '##[bgcolor]##',
                         CASE @AnswerStatus
                             WHEN 'resolved' THEN
                                 'bg-green'
                             ELSE
                                 ''
                         END
                     );
        SET @AdditionalFeedbackEmailBody
            = REPLACE(@AdditionalFeedbackEmailBody, 'class="view-image"', 'style="max-width: 200px;max-height: 200px;"');
        SET @AdditionalFeedbackEmailBody
            = REPLACE(
                         @AdditionalFeedbackEmailBody,
                         '<div class="##[smiley]##">',
                         CASE @SmileType
                             WHEN 'Positive' THEN
                                 '<div style="width: 30px;height: 28px;display: inline-block;vertical-align: top;margin-right: 18px;position: initial;margin-top: 0;"><img src="'
                                 + @Url + 'Content/Image/icon-smiley.png" alt="Positive" >'
                             WHEN 'Negative' THEN
                                 '<div style="width: 30px;height: 28px;display: inline-block;vertical-align: top;margin-right: 18px;position: initial;margin-top: 0;"><img src="'
                                 + @Url + 'Content/Image/icon-sad.png" alt="Negative" >'
                             ELSE
                                 '<div style="width: 30px;height: 28px;display: inline-block;vertical-align: top;margin-right: 18px;position: initial;margin-top: 0;"><img src="'
                                 + @Url + 'Content/Image/icon-neutral.png" alt="Neutral">'
                         END
                     );
        SET @AdditionalFeedbackEmailBody = REPLACE(@AdditionalFeedbackEmailBody, '##[capturedate]##', @CaptureDate);



        SET @AdditionalFeedbackEmailSubject = REPLACE(@AdditionalFeedbackEmailSubject, '##[username]##', @UserName);
        SET @AdditionalFeedbackEmailSubject = REPLACE(@AdditionalFeedbackEmailSubject, '##[useremail]##', @UserEmail);
        SET @AdditionalFeedbackEmailSubject
            = REPLACE(@AdditionalFeedbackEmailSubject, '##[usermobile]##', @UserMobile);
        SET @AdditionalFeedbackEmailSubject = REPLACE(@AdditionalFeedbackEmailSubject, '##[EI]##', @EI);
        SET @AdditionalFeedbackEmailSubject = REPLACE(@AdditionalFeedbackEmailSubject, '##[PI]##', @PI);
        SET @AdditionalFeedbackEmailSubject
            = REPLACE(@AdditionalFeedbackEmailSubject, '##[establishment]##', @EstablishmentName);
        SET @AdditionalFeedbackEmailSubject
            = REPLACE(
                         @AdditionalFeedbackEmailSubject,
                         '##[refno]##',
                         CAST(LEFT(REPLICATE(0, 10 - LEN(@AnswerMasterId)) + CAST(@AnswerMasterId AS VARCHAR(50)), 10) AS VARCHAR(50))
                     );



        SET @AdditionalFeedbackSMSBody = REPLACE(@AdditionalFeedbackSMSBody, '##[username]##', @UserName);
        SET @AdditionalFeedbackSMSBody = REPLACE(@AdditionalFeedbackSMSBody, '##[useremail]##', @UserEmail);
        SET @AdditionalFeedbackSMSBody = REPLACE(@AdditionalFeedbackSMSBody, '##[usermobile]##', @UserMobile);
        SET @AdditionalFeedbackSMSBody = REPLACE(@AdditionalFeedbackSMSBody, '##[EI]##', @EI);
        SET @AdditionalFeedbackSMSBody = REPLACE(@AdditionalFeedbackSMSBody, '##[PI]##', @PI);
        SET @AdditionalFeedbackSMSBody = REPLACE(@AdditionalFeedbackSMSBody, '##[Result]##', @TestResult);
        SET @AdditionalFeedbackSMSBody
            = REPLACE(@AdditionalFeedbackSMSBody, '##[establishment]##', @EstablishmentName);





    END;

    SET @FeedbackEmailBody
        = ISNULL(dbo.PatternReplace(@AdditionalFeedbackEmailBody, '##[%' + '[0-9]' + '%]##', ''), '');
    SET @FeedbackEmailSubject
        = ISNULL(REPLACE(@AdditionalFeedbackEmailSubject, CHAR(13) + CHAR(10), ' '), 'Feedback Email Alert');
    SET @FeedbackSMSBody = ISNULL(@AdditionalFeedbackSMSBody, '');

    PRINT @FeedbackEmailBody;
    PRINT @FeedbackEmailSubject;
    PRINT @FeedbackSMSBody;


    DECLARE @pos INT;
    DECLARE @len INT;
    DECLARE @MobileNumber VARCHAR(500);
    SET @pos = 0;
    SET @len = 0;

    SET @AdditionalFeedbackMobile = @AdditionalFeedbackMobile + ';';
    WHILE CHARINDEX(';', @AdditionalFeedbackMobile, @pos + 1) > 0
    BEGIN
        SET @len = CHARINDEX(';', @AdditionalFeedbackMobile, @pos + 1) - @pos;
        SET @MobileNumber = SUBSTRING(@AdditionalFeedbackMobile, @pos, @len);
        --PRINT @MobileNumber;

        IF @ISAdditionalFeedbackSMS = 1
           AND @AdditionalFeedbackSMSBody <> ''
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
            (   2,                -- ModuleId - bigint
                @MobileNumber,    -- MobileNo - nvarchar(1000)
                @FeedbackSMSBody, -- SMSText - nvarchar(1000)
                0,                -- IsSent - bit
                GETUTCDATE(),     -- SentDate - datetime
                @AnswerMasterId,  -- RefId - bigint
                GETUTCDATE(),     -- CreatedOn - datetime
                @AppUserId        -- CreatedBy - bigint
            );

        END;
        SET @pos = CHARINDEX(';', @AdditionalFeedbackMobile, @pos + @len) + 1;
    END;

    DECLARE @pos1 INT;
    DECLARE @len1 INT;
    DECLARE @EmailAddress VARCHAR(500);
    SET @pos1 = 0;
    SET @len1 = 0;
    SET @AdditionalFeedbackEmails = @AdditionalFeedbackEmails + ';';
    WHILE CHARINDEX(';', @AdditionalFeedbackEmails, @pos1 + 1) > 0
    BEGIN
        SET @len1 = CHARINDEX(';', @AdditionalFeedbackEmails, @pos1 + 1) - @pos1;
        SET @EmailAddress = SUBSTRING(@AdditionalFeedbackEmails, @pos1, @len1);

        --PRINT @EmailAddress; -- for debug porpose   

        IF @ISAdditionalFeedbackEmail = 1
           AND @AdditionalFeedbackEmailBody <> ''
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
            VALUES
            (2,
             @EmailAddress,
             @FeedbackEmailBody,
             @FeedbackEmailSubject,
             @AnswerMasterId,
             dbo.EmailBlackListCheck(@EmailAddress),
             GETUTCDATE(),
             @AppUserId
            );

        END;
        SET @pos1 = CHARINDEX(';', @AdditionalFeedbackEmails, @pos1 + @len1) + 1;
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
         'dbo.AdditionalRegisterFeedBackEmailSMS',
         N'Database',
         ERROR_MESSAGE(),
         ('ERROR_NUMBER=' + CONVERT(VARCHAR(100), ERROR_NUMBER()) + ',ERROR_STATE='
          + CONVERT(VARCHAR(20), ERROR_STATE()) + ',ERROR_SEVERITY=' + CONVERT(VARCHAR(20), ERROR_SEVERITY())
         )  ,
         GETUTCDATE(),
         ISNULL(@AppUserId,0),
         @AnswerMasterId+','+@QuestionnaireId+','+@EstablishmentId+','+@AppUserId,
         GETUTCDATE(),
         ISNULL(@AppUserId,0)
        );
END CATCH

END;

