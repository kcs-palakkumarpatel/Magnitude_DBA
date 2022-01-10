-- =============================================        
-- Author:  <Author,,Vasudev Patel>        
-- Create date: <Create Date,,02 Jan 2017>        
-- Last Update: <Vasu Patel on 07 Mar 2017>        
-- Description: <Add Close loop action with Attachment.>        
-- Call SP:  InsertCloseLoopActionV2_101120 1243,'vasudev (Vasudev@magnitude4u.com) test123',87272,1,'','','','155127$EU5B4psKTd41','COxuOTr8QDE1'
-- Call SP:  InsertCloseLoopActionV2_101120 1243,'@Anant Bhatt testt notification',87271,1,'','','','18438$EU5B4psKTd41','nnHvHoa9vc41' 
/*
drop procedure InsertCloseLoopActionV2_101120
*/
-- =============================================        
create PROCEDURE dbo.InsertCloseLoopActionV2_101120
	@AppUserId BIGINT,
	@Conversation NVARCHAR(MAX),
	@ReportId BIGINT,
	@IsOut BIT,
	@ReminderDate NVARCHAR(50),
	@AlertUserId NVARCHAR(500),
	@Attachment VARCHAR(MAX),
	@CustomerAlert VARCHAR(MAX),
	@encryptedID NVARCHAR(500) = NULL,
	@strSetActionDate NVARCHAR(50)
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @EstablishmentId BIGINT,
            @Id BIGINT,
            @TimeOfSet INT,
            @EstablishmentName NVARCHAR(500),
            @UserName NVARCHAR(50),
            @Message NVARCHAR(MAX),
            @ActivityId BIGINT,
            @SMSText NVARCHAR(MAX),
            @EmailText NVARCHAR(MAX),
            @UserEmailId NVARCHAR(500),
            @IsManager BIT,
            @Url NVARCHAR(MAX),
            @IsExternalType INT,
            @strTypeEmailSms INT,
            @DateTime NVARCHAR(50),
			@strActionDate DATETIME,
			@AndroidAppVersion INT;

	SET @AndroidAppVersion = (SELECT (CAST(KeyValue AS INT))
    FROM dbo.AAAAConfigSettings
    WHERE KeyName = 'androidVersion');

	IF (@strSetActionDate IS NOT NULL)
	BEGIN
		SET @strActionDate = CONVERT(DATETIME, @strSetActionDate);
	END;
	ELSE
	BEGIN
		SET @strActionDate = GETUTCDATE();
	END;
	
    IF (ISNULL(@Attachment, '') != '' AND ISNULL(@Conversation, '') = '')
    BEGIN
        SET @Conversation = 'Attachment Added.';
    END;
    DECLARE @CustomerDetails AS TABLE
    (
        ID INT IDENTITY(1, 1),
        ContactMasterId VARCHAR(50),
        CustomerEncryptedId NVARCHAR(500),
        MobileNo VARCHAR(50),
        EmailId VARCHAR(100),
        URL NVARCHAR(200) DEFAULT (NULL)
    );
    
	DECLARE @ContactMasterId VARCHAR(MAX);
    SET @ContactMasterId = '';
    IF (@CustomerAlert != '')
    BEGIN
        INSERT INTO @CustomerDetails
        EXEC STRINGTOTABLEFOREXTLINK @CustomerAlert, ',', '$';
        SET @strTypeEmailSms = 1;

        SELECT @ContactMasterId = @ContactMasterId + ContactMasterId + ','
        FROM @CustomerDetails;
        SELECT @ContactMasterId = SUBSTRING(@ContactMasterId, 0, LEN(@ContactMasterId));
    END;
    ELSE
    BEGIN
        SET @strTypeEmailSms = 0;
    END;
    IF (@IsOut = 1)
    BEGIN
        SELECT @EstablishmentId = EstablishmentId
        FROM SeenClientAnswerMaster
        WHERE Id = @ReportId;
    END;
    ELSE
    BEGIN
        SELECT @EstablishmentId = EstablishmentId
        FROM dbo.AnswerMaster
        WHERE Id = @ReportId;
    END;
    
	SELECT @ActivityId = EstablishmentGroupId
    FROM Vw_Establishment
    WHERE Id = @EstablishmentId;
    
	--PRINT @ActivityId;
    
	DECLARE @CustomerEmailAlert BIT,
            @CustomerSMSAlert BIT,
            @CustomerEmailSubject NVARCHAR(100),
            @CustomerEmailText NVARCHAR(MAX),
            @CustomerSMSText NVARCHAR(2000),
            @IncludeAttachment BIT = 0;
    
	IF (@strTypeEmailSms != 0)
    BEGIN
        SELECT @CustomerEmailAlert = CustomerEmailAlert,
               @CustomerSMSAlert = CustomerSMSAlert,
               @CustomerEmailSubject = CustomerEmailSubject,
               @CustomerEmailText = CustomerEmailText,
               @CustomerSMSText = CustomerSMSText,
               @IncludeAttachment = ISNULL(IncludeEmailAttachments, 0)
        FROM EstablishmentGroup
        WHERE Id = @ActivityId;
    END;
    IF (@CustomerEmailAlert = 1 AND @CustomerSMSAlert = 1)
    BEGIN
        SET @strTypeEmailSms = 3;
    END;
    ELSE IF (@CustomerEmailAlert = 1)
    BEGIN
        SET @strTypeEmailSms = 1;
    END;
    ELSE IF (@CustomerSMSAlert = 1)
    BEGIN
        SET @strTypeEmailSms = 2;
    END;
    ELSE
    BEGIN
        SET @strTypeEmailSms = 0;
    END;
    
	DECLARE @start INT = 0;
    DECLARE @end INT;
    
	SELECT @end = COUNT(1) FROM @CustomerDetails;

    DECLARE @meUserId INT;
    
	SELECT @meUserId = Data FROM dbo.Split(@AlertUserId, ',')
    WHERE Data = @AppUserId;

    DECLARE @AlertUserIdTable TABLE
    (
        NAME VARCHAR(500),
        [DATA] INT,
        UserName VARCHAR(500),
        Email VARCHAR(1000) DEFAULT NULL,
        Flag BIT DEFAULT ((0))
    );
    --IF(ISNULL(@AlertUserId,'') = '')        
    IF ((SELECT COUNT(1) FROM dbo.Split(@AlertUserId, ',') WHERE Data IN ( 0 ) AND Data != '') > 0)
    BEGIN
        INSERT INTO @AlertUserIdTable
        (
            NAME,
            [DATA],
            UserName,
            Email,
            Flag
        )
        EXEC dbo.WSGetActionAppUserByReportId @ActivityId,
                                              @ReportId,
                                              @IsOut,
                                              @AppUserId;
    END;
    ELSE
    BEGIN
        INSERT INTO @AlertUserIdTable
        (
            NAME,
            DATA,
            UserName
        )
        SELECT '',
               Data,
               ''
        FROM dbo.Split(@AlertUserId, ',');
    END;
    
	SET @DateTime = CONVERT(VARCHAR(8), GETDATE(), 114);
    SET @DateTime = REPLACE(@DateTime, ':', '');
    
	IF (@strTypeEmailSms != 0)
    BEGIN
        SELECT @Url
            = KeyValue + 'fb/CustomerFeedbackForm?rid=' + @encryptedID + '&IsOut=' + CONVERT(VARCHAR(2), @IsOut)
        FROM dbo.AAAAConfigSettings
        WHERE KeyName = 'DocViewerRootFolderPath';

    --SELECT  @Url = REPLACE(@Url, @Url,        
    --  '<a href=' + @Url + ' target="_blank">'        
    --                       + 'Click Here' + '</a>');        
    END;
    ELSE
    BEGIN
        SELECT @Url = '';
    END;

    WHILE (@end > @start)
    BEGIN
        --set @Url = @Url + '&Cid=' + (select CustomerEncryptedId from @CustomerDetails where ID = (@start + 1))       
        SELECT @Conversation
            = IIF(
                  (
                      ISNULL(MobileNo, '') = ''
                      AND ISNULL(EmailId, '') <> ''
                  ),
                  REPLACE(@Conversation, '(' + ISNULL(EmailId, '') + ')', ''),
                  IIF(
                      (
                          ISNULL(EmailId, '') = ''
                          AND ISNULL(MobileNo, '') <> ''
                      ),
                      REPLACE(@Conversation, '(' + ISNULL(MobileNo, '') + ')', ''),
                      REPLACE(@Conversation, '(' + ISNULL(EmailId, '') + ',' + ISNULL(MobileNo, '') + ')', '')))
        FROM @CustomerDetails;

        UPDATE @CustomerDetails
        SET URL = @Url + '&Cid=' + C.CustomerEncryptedId
        FROM @CustomerDetails AS C
        WHERE C.ID = (@start + 1);
        SET @start += 1;
    END;
    
	IF @IsOut = 1
    BEGIN
        SELECT @EstablishmentId = EstablishmentId,
               @TimeOfSet = TimeOffSet
        FROM dbo.SeenClientAnswerMaster
        WHERE Id = @ReportId;

        INSERT INTO dbo.CloseLoopAction
        (
            AnswerMasterId,
            SeenClientAnswerMasterId,
            AppUserId,
            [Conversation],
            Attachment,
            IsNote,
            IsExternalType,
            CustomerAppId,
			CreatedOn
        )
        VALUES
        (   NULL,          -- AnswerMasterId - bigint        
            @ReportId,     -- SeenClientAnswerMasterId - bigint        
            @AppUserId,    -- AppUserId - bigint        
            @Conversation, --+ ' ' + @Url , --(SELECT dbo.StripHTML(dbo.udf_StripHTML(@Conversation))),        
            @Attachment,
            CASE ISNULL(@meUserId, 0) WHEN @AppUserId THEN 1 ELSE 0 END,
            @IsExternalType,
            @ContactMasterId,
			@strActionDate
        );

        SELECT @Id = SCOPE_IDENTITY();
        UPDATE dbo.SeenClientAnswerMaster
        SET IsActioned = 1
        WHERE Id = @ReportId;
    END;
    ELSE
    BEGIN
        SELECT @EstablishmentId = EstablishmentId,
               @TimeOfSet = TimeOffSet
        FROM dbo.AnswerMaster
        WHERE Id = @ReportId;

        INSERT INTO dbo.CloseLoopAction
        (
            AnswerMasterId,
            SeenClientAnswerMasterId,
            AppUserId,
            [Conversation],
            Attachment,
            IsExternalType,
            CustomerAppId,
			CreatedOn
        )
        VALUES
        (   @ReportId,     -- AnswerMasterId - bigint        
            NULL,          -- SeenClientAnswerMasterId - bigint        
            @AppUserId,    -- AppUserId - bigint        
            @Conversation, --+ ' ' + @Url ,-- Conversation - nvarchar(2000)        
            @Attachment,
            @IsExternalType,
            @ContactMasterId,
			@strActionDate
        );

        SELECT @Id = SCOPE_IDENTITY();

        UPDATE dbo.AnswerMaster
        SET IsActioned = 1
        WHERE Id = @ReportId;

        UPDATE dbo.CloseLoopAction
        SET [Conversation] = REPLACE(REPLACE(@Conversation, '&nbsp;', ''), '‍ ', ' ')
        WHERE Id = @Id;
    END;
    SELECT @ActivityId = EstablishmentGroupId
    FROM dbo.Establishment
    WHERE Id = @EstablishmentId;

    IF @ReminderDate <> '' AND @ReminderDate IS NOT NULL
    BEGIN
		--PRINT 123
        UPDATE dbo.CloseLoopAction
        SET IsReminderSet = 1,
            Conversation = @Conversation + ' - Remind Me on ' + @ReminderDate
        WHERE Id = @Id;
        
		--PRINT 'remindr ' + @ReminderDate;
        
		SELECT TOP 1 @EstablishmentName = EstablishmentGroupName
        FROM dbo.Establishment
        INNER JOIN dbo.EstablishmentGroup ON EstablishmentGroup.Id = Establishment.EstablishmentGroupId
        WHERE dbo.Establishment.Id = @EstablishmentId;

        SELECT @UserName = UserName
        FROM dbo.AppUser
        WHERE Id = @AppUserId;

        SET @Message = 'Reminder ' + CHAR(13) + CHAR(10) + 'Activity: ' + @EstablishmentName + '; User: ' + @UserName
              + '; Action: ' +
              (
                  SELECT dbo.StripHTML(dbo.udf_StripHTML(@Conversation))
              );

        IF @strTypeEmailSms = 0
        BEGIN
			--PRINT 1;
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
            SELECT CASE @IsOut WHEN 0 THEN 5 ELSE 6 END AS MoudleId,
                   CASE WHEN LEN(@Message) > 197 THEN LEFT(@Message, 197) + '...' ELSE @Message END,
                   TokenId,
                   0,
                   NULL,
                   DATEADD(MINUTE, -@TimeOfSet, @ReminderDate),
                   @ReportId,
                   T.AppUserId,
                   DeviceTypeId,
                   @AppUserId,
			 	   T.AppVersion
				   --ISNULL(T.AppVersion, CASE WHEN DeviceTypeId = 'A' THEN @AndroidAppVersion ELSE T.AppVersion end)
            FROM @AlertUserIdTable AS UE
            INNER JOIN dbo.AppUser AS U ON UE.DATA = U.Id
            INNER JOIN dbo.UserTokenDetails AS T ON UE.DATA = T.AppUserId
            INNER JOIN dbo.AppUserEstablishment AS AUE ON AUE.AppUserId = U.Id
            INNER JOIN dbo.Vw_Establishment AS E
        ON E.Id = AUE.EstablishmentId
            WHERE LEN(TokenId) > 10
                  AND UE.DATA != 0
                  AND AUE.NotificationStatus = 1
                  AND E.Id = @EstablishmentId
                  AND AUE.IsDeleted = 0;
            --AND T.AppUserId != @AppUserId;

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
                CASE @IsOut
                    WHEN 0 THEN
                        5
                    ELSE
                        6
                END AS ModuleId,
                CASE
                    WHEN LEN(@Message) > 197 THEN
                        LEFT(@Message, 197) + '...'
                    ELSE
                        @Message
                END,
                0,
                DATEADD(MINUTE, -@TimeOfSet, @ReminderDate),
                @ReportId,
                AUE.AppUserId,
                GETUTCDATE(),
                @AppUserId
            FROM @AlertUserIdTable AS UE
                INNER JOIN dbo.AppUser AS U
                    ON UE.DATA = U.Id
                INNER JOIN dbo.AppUserEstablishment AS AUE
                    ON AUE.AppUserId = U.Id
                INNER JOIN dbo.Vw_Establishment AS E
                    ON E.Id = AUE.EstablishmentId
            WHERE AUE.NotificationStatus = 1
                  AND E.Id = @EstablishmentId
                  --AND U.Id != @AppUserId
                  AND UE.DATA != 0
                  AND AUE.IsDeleted = 0;

        --End @Me With Other User Reminder Notification

        END;
    END;
    ELSE
    BEGIN
        SELECT TOP 1
            @EstablishmentName = EstablishmentGroupName
        FROM dbo.Establishment
            INNER JOIN dbo.EstablishmentGroup
                ON EstablishmentGroup.Id = Establishment.EstablishmentGroupId
        WHERE dbo.Establishment.Id = @EstablishmentId;
        SELECT @UserName = UserName
        FROM dbo.AppUser
        WHERE Id = @AppUserId;
        SET @Message = 'Activity: ' + @EstablishmentName + '; User: ' + @UserName + '; Action: ' +
                       (
                           SELECT dbo.StripHTML(dbo.udf_StripHTML(@Conversation))
                       );
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
        SELECT DISTINCT
            CASE @IsOut
                WHEN 0 THEN
                    11
                ELSE
                    12
            END AS MoudleId,
            CASE
                WHEN LEN(@Message) > 197 THEN
                    LEFT(@Message, 197) + '...'
                ELSE
                    @Message
            END,
            TokenId,
            0,
            NULL,
            DATEADD(MINUTE, -@TimeOfSet, GETUTCDATE()),
            @ReportId,
            UE.DATA,
            DeviceTypeId,
            @AppUserId,
			T.AppVersion
        FROM --dbo.Split(ISNULL(@AlertUserId, ''), ',') AS UE        
            @AlertUserIdTable AS UE
            INNER JOIN dbo.AppUser AS U
                ON UE.DATA = U.Id
            INNER JOIN dbo.UserTokenDetails AS T
                ON UE.DATA = T.AppUserId
            INNER JOIN dbo.AppUserEstablishment AS AUE
                ON AUE.AppUserId = U.Id
            INNER JOIN dbo.Vw_Establishment AS E
                ON E.Id = AUE.EstablishmentId
        WHERE LEN(TokenId) > 10
              AND UE.DATA != 0
              AND AUE.NotificationStatus = 1
              AND E.Id = @EstablishmentId
              AND AUE.IsDeleted = 0;
        --AND T.AppUserId != @AppUserId;

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
            CASE @IsOut
                WHEN 0 THEN
                    11
                ELSE
                    12
            END AS ModuleId,
            @Conversation,
            0,
            DATEADD(MINUTE, -@TimeOfSet, GETUTCDATE()),
            @ReportId,
            UE.DATA,
            GETUTCDATE(),
            @AppUserId
        FROM --dbo.Split(ISNULL(@AlertUserId, ''), ',') AS UE        
            @AlertUserIdTable AS UE
            INNER JOIN dbo.AppUser AS U
                ON UE.DATA = U.Id
            INNER JOIN dbo.AppUserEstablishment AS AUE
                ON AUE.AppUserId = U.Id
            INNER JOIN dbo.Vw_Establishment AS E
                ON E.Id = AUE.EstablishmentId
        WHERE AUE.NotificationStatus = 1
              AND E.Id = @EstablishmentId
              --AND U.Id != @AppUserId
              AND UE.DATA != 0
              AND AUE.IsDeleted = 0;
        SELECT @UserEmailId = Email,
               @IsManager = IsAreaManager
        FROM dbo.AppUser
        WHERE Id = @AppUserId
              AND IsDeleted = 0
              AND IsActive = 1;
    END;
    IF @strTypeEmailSms = 0
    BEGIN
        RETURN 1;
    END;
    ELSE
    BEGIN
        --SET @CustomerSMSText = REPLACE(@CustomerSMSText, '[link]', @Url);    
        SET @CustomerSMSText = REPLACE(@CustomerSMSText, '[LastChat]', @Conversation);
        IF (ISNULL(@Attachment, '') != '')
        BEGIN
            SET @CustomerSMSText = CONCAT(@CustomerSMSText, ' You have attachment(s).');
        END;

        IF @strTypeEmailSms = 2
           AND @CustomerSMSText <> ''
        --AND @mobileNo IS NOT NULL  

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
            SELECT CASE @IsOut
                       WHEN 0 THEN
                           2
                       ELSE
                           3
                   END AS MoudleId,                                        -- ModuleId - bigint        
                   MobileNo,                                               -- MobileNo - nvarchar(1000)        
                   REPLACE(@CustomerSMSText, '[link]', '$$' + URL + '$$'), -- SMSText - nvarchar(1000)        
                   0,                                                      -- IsSent - bit        
                   GETUTCDATE(),                                           -- SentDate - datetime        
                   @ReportId,                                              -- RefId - bigint        
                   GETUTCDATE(),                                           -- CreatedOn - datetime        
                   @AppUserId                                              -- CreatedBy - bigint        
            FROM @CustomerDetails;
            SELECT @Id = SCOPE_IDENTITY();
        END;
        --SET @EmailText = ;           

        --SET @CustomerEmailText = REPLACE(@CustomerEmailText,'[Link]', @Url )    
        SET @CustomerEmailText = REPLACE(@CustomerEmailText, '[LastChat]', @Conversation);

        IF @IncludeAttachment = 1
        BEGIN
            IF ISNULL(@Attachment, '') != ''
            BEGIN
                DECLARE @AttachmentText NVARCHAR(MAX);
                SET @AttachmentText = dbo.EmailAttachment(@Attachment);

                SELECT @CustomerEmailText = CONCAT(@CustomerEmailText, @AttachmentText);
            END;
        END;

        IF @strTypeEmailSms = 1
           AND @CustomerEmailText <> ''
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
                Attachment
            )
            SELECT CASE @IsOut
                       WHEN 0 THEN
                           2
                       ELSE
                           3
                   END AS MoudleId,                                          -- ModuleId - bigint        
                   EmailId,                                                  -- EmailId - nvarchar(1000)        
                   REPLACE(@CustomerEmailText, '[Link]', '$$' + URL + '$$'), -- EmailText - nvarchar(max)        
                   @CustomerEmailSubject,
                   @ReportId,                                                -- RefId - bigint       
                   dbo.EmailBlackListCheck(EmailId),
                   GETUTCDATE(),                                             -- ScheduleDateTime - datetime        
                   @AppUserId,                                               -- CreatedBy - bigint        
                   @UserEmailId,
                   @Attachment
            FROM @CustomerDetails;
            SELECT @Id = SCOPE_IDENTITY();
        END;

        IF @strTypeEmailSms = 3
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
            SELECT CASE @IsOut
                       WHEN 0 THEN
                           2
                       ELSE
                           3
                   END AS MoudleId,                                                    -- ModuleId - bigint        
                   ISNULL(MobileNo, 0),                                                -- MobileNo - nvarchar(1000)        
                   REPLACE(ISNULL(@CustomerSMSText, ''), '[link]', '$$' + URL + '$$'), -- SMSText - nvarchar(1000)        
                   0,                                                                  -- IsSent - bit        
                   GETUTCDATE(),                                                       -- SentDate - datetime        
                   @ReportId,                                                          -- RefId - bigint        
                   GETUTCDATE(),                                                       -- CreatedOn - datetime        
                   @AppUserId                                                          -- CreatedBy - bigint        
            FROM @CustomerDetails;

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
                Attachment
            )
            SELECT CASE @IsOut
                       WHEN 0 THEN
                           2
                       ELSE
                           3
                   END AS MoudleId,                                                      -- ModuleId - bigint        
                   ISNULL(EmailId, ''),                                                  -- EmailId - nvarchar(1000)        
                   REPLACE(ISNULL(@CustomerEmailText, ''), '[Link]', '$$' + URL + '$$'), -- EmailText - nvarchar(max)        
					@CustomerEmailSubject,
                   @ReportId,                                                            -- RefId - bigint        
                   dbo.EmailBlackListCheck(EmailId),
                   GETUTCDATE(),                                                         -- ScheduleDateTime - datetime        
                   @AppUserId,                                                           -- CreatedBy - bigint        
                   @UserEmailId,
                   @Attachment
            FROM @CustomerDetails;
            SELECT @Id = SCOPE_IDENTITY();
        END;
    END;
    RETURN 1;
    SET NOCOUNT OFF;
END;
