-----------------------------------------------------test
-- =============================================
-- Author:		<Author,,GD>
-- Create date: <Create Date,,26 Jun 2015>
-- Description:	<Description,,>
-- Call SP:		AdditionalRegisterSeenClientEmailSMS 363113,91292,609,23989,1243,'FWLyjjUBsBQ1&amp;Cid=cWiJrSElD941','',false
-- =============================================
CREATE PROCEDURE [dbo].[AdditionalRegisterSeenClientEmailSMS]
    @SeenClientAnswerMasterId BIGINT,
    @SeenClientAnswerChildId BIGINT = 0,
    @SeenClientId BIGINT,
    @EstablishmentId BIGINT,
    @AppUserId BIGINT,
    @EncryptedId NVARCHAR(500),
    @RRules NVARCHAR(MAX),
    @Resend BIT
AS
BEGIN
    SET NOCOUNT ON;
	SET DEADLOCK_PRIORITY NORMAL;
	BEGIN TRY
    DECLARE @EstablishmentName NVARCHAR(500),
            @UserName NVARCHAR(50),
            @UserEmail NVARCHAR(50),
            @UserMobile NVARCHAR(50),
            @UserProfileImage NVARCHAR(500),
            @Url NVARCHAR(100),
            @ConfigUrl NVARCHAR(200),
            @EI NVARCHAR(50),
            @PI NVARCHAR(50),
            @DocURL NVARCHAR(100),
            @WebAppUrl NVARCHAR(100),
            @AnswerStatus NVARCHAR(50),
            @SmileType NVARCHAR(50),
            @CaptureDate DATETIME,
            @DelayTime NVARCHAR(10),
            @TimeOffSet INT = 0,
            @UserEmailId NVARCHAR(500),
            @ISAdditionalCaptureEmail BIT,
            @AdditionalCaptureEmails NVARCHAR(2000),
            @AdditionalCaptureEmailSubject NVARCHAR(2000),
            @AdditionalCaptureEmailBody NVARCHAR(MAX),
            @ISAdditionalCaptureSMS BIT,
            @AdditionalCaptureMobile NVARCHAR(500),
            @AdditionalCaptureSMSBody NVARCHAR(MAX),
            @CaptureEmailSubject NVARCHAR(2000),
            @CaptureEmailBody NVARCHAR(MAX),
            @CaptureSMSBody NVARCHAR(MAX),
            @ScheduleDateTime DATETIME;

    SELECT TOP 1
        @DelayTime = CASE
                         WHEN Eg.AllowToChangeDelayTime = 1 THEN
                             ISNULL(UE.DelayTime, Eg.DelayTime)
                         ELSE
                             Eg.DelayTime
                     END,
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
              END
    FROM dbo.Establishment AS E WITH (NOLOCK)
        INNER JOIN dbo.EstablishmentGroup AS Eg WITH (NOLOCK)
            ON E.EstablishmentGroupId = Eg.Id
        INNER JOIN dbo.AppUserEstablishment AS UE WITH (NOLOCK)
            ON E.Id = UE.EstablishmentId
    WHERE E.IsDeleted = 0
          AND UE.IsDeleted = 0
          AND AppUserId = @AppUserId
          AND E.Id = @EstablishmentId;

    SELECT @EstablishmentName = EstablishmentName,
           @UserName = U.Name,
           @UserEmail = U.Email,
           @UserMobile = U.Mobile,
           @UserProfileImage = ISNULL(U.ImageName, ''),
           @EI = Am.EI,
           @PI = CAST(CAST(ROUND(Am.PI, 0) AS INT) AS NVARCHAR(10)) + '%',
           @AnswerStatus = Am.IsResolved,
           @SmileType = Am.IsPositive,
           @CaptureDate = dbo.ChangeDateFormat(DATEADD(MINUTE, Am.TimeOffSet, Am.CreatedOn), 'dd/MMM/yyyy hh:mm AM/PM'),
           @ISAdditionalCaptureEmail = E.ISAdditionalCaptureEmail,
           @AdditionalCaptureEmails = E.AdditionalCaptureEmails,
           @AdditionalCaptureEmailSubject = E.AdditionalCaptureEmailSubject,
           @AdditionalCaptureEmailBody = E.AdditionalCaptureEmailBody,
           @ISAdditionalCaptureSMS = E.ISAdditionalCaptureSMS,
           @AdditionalCaptureMobile = E.AdditionalCaptureMobile,
           @AdditionalCaptureSMSBody = E.AdditionalCaptureSMSBody
    FROM dbo.SeenClientAnswerMaster AS Am WITH (NOLOCK)
        INNER JOIN dbo.AppUser AS U WITH (NOLOCK)
            ON Am.AppUserId = U.Id
        INNER JOIN dbo.Establishment AS E
            ON Am.EstablishmentId = E.Id
    WHERE Am.Id = @SeenClientAnswerMasterId;



    IF OBJECT_ID('tempdb..#Tbl', 'U') IS NOT NULL
        DROP TABLE #ResultSet;

    CREATE TABLE #Tbl
    (
        Id BIGINT IDENTITY(1, 1),
        QuestionId BIGINT,
        Detail NVARCHAR(MAX)
    );

    CREATE CLUSTERED INDEX IX_CL_Tbl ON #Tbl (Id);
    CREATE NONCLUSTERED INDEX IX_NON_CL_Tbl ON #Tbl (QuestionId);


    DECLARE @Start BIGINT = 1,
            @End BIGINT,
            @Id BIGINT,
            @Details NVARCHAR(MAX),
            @QuestionId NVARCHAR(10);

    INSERT INTO #Tbl
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
                   dbo.ChangeDateFormat(Detail, 'dd/MMM/yyyy hh:mm AM/PM')
               WHEN 17 THEN
                   dbo.GetFileTypeQuestionImageString(Detail, 1 ,SA.QuestionId)
               WHEN 1 THEN
               (
                   SELECT Name FROM dbo.SeenClientOptions WHERE Id = SA.OptionId
               )
               ELSE
                   Detail
           END
    FROM dbo.SeenClientAnswers SA WITH (NOLOCK)
    WHERE SeenClientAnswerMasterId = @SeenClientAnswerMasterId
          AND ISNULL(SeenClientAnswerChildId, 0) = ISNULL(@SeenClientAnswerChildId, 0);

    SELECT *
    FROM #Tbl;

    SELECT @End = COUNT(1)
    FROM #Tbl;


    IF @AdditionalCaptureEmailSubject <> ''
       OR @AdditionalCaptureEmailBody <> ''
       OR @AdditionalCaptureSMSBody <> ''
       OR @AdditionalCaptureEmailSubject IS NOT NULL
       OR @AdditionalCaptureEmailBody IS NOT NULL
       OR @AdditionalCaptureSMSBody IS NOT NULL
    BEGIN
        WHILE @Start <= @End
        BEGIN
            SELECT @QuestionId = QuestionId,
                   @Details = Detail
            FROM #Tbl
            WHERE Id = @Start;

            SET @AdditionalCaptureEmailSubject
                = REPLACE(@AdditionalCaptureEmailSubject, '##[' + @QuestionId + ']##', ISNULL(@Details, ''));

            SET @AdditionalCaptureEmailBody
                = REPLACE(@AdditionalCaptureEmailBody, '##[' + @QuestionId + ']##', ISNULL(@Details, ''));

            SET @AdditionalCaptureSMSBody
                = REPLACE(@AdditionalCaptureSMSBody, '##[' + @QuestionId + ']##', ISNULL(@Details, ''));

            SET @Start += 1;
        END;

        SELECT @UserProfileImage = KeyValue + 'AppUser/' + @UserProfileImage
        FROM dbo.AAAAConfigSettings WITH (NOLOCK)
        WHERE KeyName = 'DocViewerRootFolderPathCMS';

        SELECT @Url = KeyValue + 'Fb?Sid=' + @EncryptedId
        FROM dbo.AAAAConfigSettings WITH (NOLOCK)
        WHERE KeyName = 'DocViewerRootFolderPath';

        SELECT @ConfigUrl = KeyValue + 'Fb/index?Sid=' + @EncryptedId
        FROM dbo.AAAAConfigSettings WITH (NOLOCK)
        WHERE KeyName = 'DocViewerRootFolderPath';

        SELECT @DocURL = KeyValue
        FROM dbo.AAAAConfigSettings WITH (NOLOCK)
        WHERE KeyName = 'DocViewerRootFolderPathCMS';

        SELECT @WebAppUrl = KeyValue
        FROM dbo.AAAAConfigSettings WITH (NOLOCK)
        WHERE KeyName = 'DocViewerRootFolderPathWebApp';

        SELECT @TimeOffSet = ISNULL(CAST(Data AS INT), 0) * 60
        FROM dbo.Split(@DelayTime, ':')
        WHERE Id = 1;

        SELECT @TimeOffSet += ISNULL(CAST(Data AS INT), 0)
        FROM dbo.Split(@DelayTime, ':')
        WHERE Id = 2;

        SELECT @UserEmailId = Email
        FROM dbo.AppUser WITH (NOLOCK)
        WHERE Id = @AppUserId
              AND IsDeleted = 0
              AND IsActive = 1;

        SET @AdditionalCaptureEmailBody = REPLACE(@AdditionalCaptureEmailBody, '##[link]##', '$$' + @Url + '$$');
        SET @AdditionalCaptureEmailBody = REPLACE(@AdditionalCaptureEmailBody, '##[Configlink]##', @ConfigUrl);
        SET @AdditionalCaptureEmailBody = REPLACE(@AdditionalCaptureEmailBody, '##[EI]##', @EI);
        SET @AdditionalCaptureEmailBody = REPLACE(@AdditionalCaptureEmailBody, '##[PI]##', @PI);
        SET @AdditionalCaptureEmailBody = REPLACE(@AdditionalCaptureEmailBody, '##[username]##', @UserName);
        SET @AdditionalCaptureEmailBody = REPLACE(@AdditionalCaptureEmailBody, '##[useremail]##', @UserEmail);
        SET @AdditionalCaptureEmailBody = REPLACE(@AdditionalCaptureEmailBody, '##[usermobile]##', @UserMobile);
        SET @AdditionalCaptureEmailBody
            = REPLACE(@AdditionalCaptureEmailBody, '##[establishment]##', @EstablishmentName);
        SET @AdditionalCaptureEmailBody
            = REPLACE(
                         @AdditionalCaptureEmailBody,
                         '##[userprofilepicture]##',
                         '<img src=''' + @UserProfileImage + ''' alt=''' + @UserName + ''' style=''max-width:20%;'' />'
                     );
        SET @AdditionalCaptureEmailBody
            = REPLACE(   @AdditionalCaptureEmailBody,
                         '##[bgcolor]##',
                         CASE @AnswerStatus
                             WHEN 'resolved' THEN
                                 'bg-green'
                             ELSE
                                 ''
                         END
                     );
        SET @AdditionalCaptureEmailBody
            = REPLACE(@AdditionalCaptureEmailBody, 'class="view-image"', 'style="max-width: 200px;max-height: 200px;"');
        SET @AdditionalCaptureEmailBody
            = REPLACE(
                         @AdditionalCaptureEmailBody,
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
        SET @AdditionalCaptureEmailBody = REPLACE(@AdditionalCaptureEmailBody, '##[capturedate]##', @CaptureDate);

        SET @AdditionalCaptureEmailSubject = REPLACE(@AdditionalCaptureEmailSubject, '##[link]##', '$$' + @Url + '$$');
        SET @AdditionalCaptureEmailSubject = REPLACE(@AdditionalCaptureEmailSubject, '##[EI]##', @EI);
        SET @AdditionalCaptureEmailSubject = REPLACE(@AdditionalCaptureEmailSubject, '##[PI]##', @PI);
        SET @AdditionalCaptureEmailSubject = REPLACE(@AdditionalCaptureEmailSubject, '##[username]##', @UserName);
        SET @AdditionalCaptureEmailSubject = REPLACE(@AdditionalCaptureEmailSubject, '##[useremail]##', @UserEmail);
        SET @AdditionalCaptureEmailSubject = REPLACE(@AdditionalCaptureEmailSubject, '##[usermobile]##', @UserMobile);
        SET @AdditionalCaptureEmailSubject
            = REPLACE(@AdditionalCaptureEmailSubject, '##[establishment]##', @EstablishmentName);
        SET @AdditionalCaptureEmailSubject
            = REPLACE(
                         @AdditionalCaptureEmailSubject,
                         '##[refno]##',
                         CAST(LEFT(REPLICATE(0, 10 - LEN(@SeenClientAnswerMasterId))
                                   + CAST(@SeenClientAnswerMasterId AS VARCHAR(50)), 10) AS VARCHAR(50))
                     );

        SET @AdditionalCaptureSMSBody = REPLACE(@AdditionalCaptureSMSBody, '##[link]##', '$$' + @Url + '$$');
        SET @AdditionalCaptureSMSBody = REPLACE(@AdditionalCaptureSMSBody, '##[EI]##', @EI);
        SET @AdditionalCaptureSMSBody = REPLACE(@AdditionalCaptureSMSBody, '##[PI]##', @PI);
        SET @AdditionalCaptureSMSBody = REPLACE(@AdditionalCaptureSMSBody, '##[username]##', @UserName);
        SET @AdditionalCaptureSMSBody = REPLACE(@AdditionalCaptureSMSBody, '##[useremail]##', @UserEmail);
        SET @AdditionalCaptureSMSBody = REPLACE(@AdditionalCaptureSMSBody, '##[usermobile]##', @UserMobile);
        SET @AdditionalCaptureSMSBody = REPLACE(@AdditionalCaptureSMSBody, '##[establishment]##', @EstablishmentName);

        WHILE CHARINDEX('##', @AdditionalCaptureEmailBody) > 0
        BEGIN

            SET @AdditionalCaptureEmailBody
                = LEFT(@AdditionalCaptureEmailBody, CHARINDEX('##', @AdditionalCaptureEmailBody) - 1)
                  + SUBSTRING(
                                 @AdditionalCaptureEmailBody,
                                 CHARINDEX(
                                              '##',
                                              @AdditionalCaptureEmailBody,
                                              CHARINDEX('##', @AdditionalCaptureEmailBody) + 1
                                          ) + 2,
                                 LEN(@AdditionalCaptureEmailBody)
                             );
        END;

    END;

    SET @CaptureEmailSubject
        = (ISNULL(
                     REPLACE(@AdditionalCaptureEmailSubject, CHAR(13) + CHAR(10), ' '),
                     'Seenclient Captured For ' + @EstablishmentName
                 )
          );
    SET @CaptureEmailBody
        = ISNULL(dbo.PatternReplace(@AdditionalCaptureEmailBody, '##[%' + '[0-9]' + '%]##', 'N/A'), '');
    SET @CaptureSMSBody = ISNULL(@AdditionalCaptureSMSBody, '');

    DECLARE @pos INT;
    DECLARE @len INT;
    DECLARE @MobileNumber VARCHAR(500);
    SET @pos = 0;
    SET @len = 0;

    SET @AdditionalCaptureMobile = @AdditionalCaptureMobile + ';';
    WHILE CHARINDEX(';', @AdditionalCaptureMobile, @pos + 1) > 0
    BEGIN
        SET @len = CHARINDEX(';', @AdditionalCaptureMobile, @pos + 1) - @pos;
        SET @MobileNumber = SUBSTRING(@AdditionalCaptureMobile, @pos, @len);

        IF @ISAdditionalCaptureSMS = 1
           AND @AdditionalCaptureSMSBody <> ''
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
            (   3,                                          -- ModuleId - bigint
                @MobileNumber,                              -- MobileNo - nvarchar(1000)
                @CaptureSMSBody,                            -- SMSText - nvarchar(1000)
                0,                                          -- IsSent - bit
                DATEADD(MINUTE, @TimeOffSet, GETUTCDATE()), -- SentDate - datetime
                @SeenClientAnswerMasterId,                  -- RefId - bigint
                GETUTCDATE(),                               -- CreatedOn - datetime
                @AppUserId                                  -- CreatedBy - bigint
            );

        END;
        SET @pos = CHARINDEX(';', @AdditionalCaptureMobile, @pos + @len) + 1;
    END;

    DECLARE @pos1 INT;
    DECLARE @len1 INT;
    DECLARE @EmailAddress VARCHAR(500);
    SET @pos1 = 0;
    SET @len1 = 0;
    SET @AdditionalCaptureEmails = @AdditionalCaptureEmails + ';';
    WHILE CHARINDEX(';', @AdditionalCaptureEmails, @pos1 + 1) > 0
    BEGIN
        SET @len1 = CHARINDEX(';', @AdditionalCaptureEmails, @pos1 + 1) - @pos1;
        SET @EmailAddress = SUBSTRING(@AdditionalCaptureEmails, @pos1, @len1);

        IF @ISAdditionalCaptureEmail = 1
           AND @AdditionalCaptureEmailBody <> ''
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
            (3,
             @EmailAddress,
             @CaptureEmailBody,
             @CaptureEmailSubject,
             @SeenClientAnswerMasterId,
             dbo.EmailBlackListCheck(@EmailAddress),
             DATEADD(MINUTE, @TimeOffSet, GETUTCDATE()),
             @AppUserId,
             @UserEmailId
            );

        END;
        SET @pos1 = CHARINDEX(';', @AdditionalCaptureEmails, @pos1 + @len1) + 1;
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
         'dbo.AdditionalRegisterSeenClientEmailSMS',
         N'Database',
         ERROR_MESSAGE(),
         ('ERROR_NUMBER=' + CONVERT(VARCHAR(100), ERROR_NUMBER()) + ',ERROR_STATE='
          + CONVERT(VARCHAR(20), ERROR_STATE()) + ',ERROR_SEVERITY=' + CONVERT(VARCHAR(20), ERROR_SEVERITY())
         )  ,
         GETUTCDATE(),
         ISNULL(@AppUserId,0),
         @SeenClientAnswerMasterId+','+
		 @SeenClientAnswerChildId+','+
		 @SeenClientId+','+
		 @EstablishmentId+','+
		 @AppUserId+','+
		 @EncryptedId+','+
		 @RRules+','+
		 @Resend,
         GETUTCDATE(),
         ISNULL(@AppUserId,0)
        );
	END CATCH
    SET NOCOUNT OFF;
	
END;
