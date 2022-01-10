-- =============================================
-- Author:		<Ankit,,GD>
-- Create date: <Create Date,, 17 Mar 2015>
-- Description:	<Description,,ResendUnresolvedSeenClientForm>
-- Call SP    :	ResendUnresolvedSeenClientForm
-- =============================================
CREATE PROCEDURE dbo.ResendUnresolvedSeenClientForm
    @ResendUnresolvedSeenClientFormTableType ResendUnresolvedSeenClientFormTypeTable READONLY
AS
BEGIN
    DECLARE @TempTable TABLE
    (
        Id BIGINT,
        SeenClientAnswerMasterId BIGINT,
        SeenClientAnswerChildId BIGINT,
        EstablishmentId BIGINT,
        AppuserId BIGINT,
        EncryptedId NVARCHAR(500)
    );

    INSERT INTO @TempTable
    (
        Id,
        SeenClientAnswerMasterId,
        SeenClientAnswerChildId,
        EstablishmentId,
        AppuserId,
        EncryptedId
    )
    SELECT Id,
           SeenClientAnswerMasterId,
           SeenClientAnswerChildId,
           EstablishmentId,
           AppuserId,
           EncryptedId
    FROM @ResendUnresolvedSeenClientFormTableType;


    SELECT *
    FROM @TempTable;

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
                @EstablishmentId BIGINT,
                @AppUserId BIGINT,
                @EncryptedId NVARCHAR(500);


        SELECT @SeenClientAnswerMasterId = SeenClientAnswerMasterId,
               @SeenClientAnswerChildId = SeenClientAnswerChildId,
               @EstablishmentId = EstablishmentId,
               @AppUserId = AppuserId,
               @EncryptedId = EncryptedId
        FROM @TempTable
        WHERE Id = @Counter;

        PRINT @SeenClientAnswerMasterId;
        PRINT @SeenClientAnswerChildId;
        PRINT @EstablishmentId;
        PRINT @AppUserId;
        PRINT @EncryptedId;

        DECLARE @SendSMS BIT,
                @SendEmail BIT,
                @SMSText NVARCHAR(MAX),
                @EmailText NVARCHAR(MAX),
                @UserEmailId NVARCHAR(500),
                @EmailSubject NVARCHAR(MAX),
                @MobileNo NVARCHAR(50),
                @Email NVARCHAR(50),
				@AuditComments NVARCHAR(MAX);
        --END;
        SELECT @UserEmailId = Email
        FROM dbo.AppUser
        WHERE Id = @AppUserId
              AND IsDeleted = 0
              AND IsActive = 1;
        PRINT @UserEmailId;
        SELECT TOP 1
            @SendSMS = SendSeenClientSMS,
            @SendEmail = SendSeenClientEmail
        FROM dbo.Establishment AS E
            INNER JOIN dbo.EstablishmentGroup AS Eg
                ON E.EstablishmentGroupId = Eg.Id
            INNER JOIN dbo.AppUserEstablishment AS UE
                ON E.Id = UE.EstablishmentId
        WHERE E.IsDeleted = 0
              AND UE.IsDeleted = 0
              AND AppUserId = @AppUserId
              AND E.Id = @EstablishmentId;

        PRINT @SendSMS;
        PRINT @SendEmail;

        SELECT @SMSText = SMSText,
               @EmailText = EmailText,
               @EmailSubject = EmailSubject
        FROM dbo.GetSeenClientAutoSMSEmailNotificationText(
                                                              @SeenClientAnswerMasterId,
                                                              @EncryptedId,
                                                              @SeenClientAnswerChildId
                                                          );


        PRINT @SMSText;
        PRINT @EmailText;
        PRINT @EmailSubject;

        IF @SendSMS = 1
           AND @SMSText <> ''
        BEGIN
			IF @SeenClientAnswerChildId <> 0
			BEGIN
				SELECT TOP 1 @MobileNo=CD.Detail 
				FROM dbo.SeenClientAnswers SCA
				INNER JOIN dbo.SeenClientAnswerChild SCAC ON SCAC.Id = @SeenClientAnswerChildId
				INNER JOIN dbo.ContactDetails CD ON CD.ContactMasterId = SCAC.ContactMasterId
				AND CD.QuestionTypeId=11 AND CD.IsDeleted=0
				WHERE SCA.SeenClientAnswerMasterId = @SeenClientAnswerMasterId;
				
					SET @AuditComments = 'SMS From contactDetails';

				IF @MobileNo = '' OR @MobileNo IS NULL
				BEGIN
					SELECT @MobileNo = Detail
					FROM dbo.SeenClientAnswers
					WHERE SeenClientAnswerMasterId = @SeenClientAnswerMasterId
					  AND (ISNULL(SeenClientAnswerChildId, 0) = ISNULL(@SeenClientAnswerChildId, 0))
					  AND IsDeleted = 0
					  AND QuestionTypeId = 11;

					SET @AuditComments = 'SMS From SeenClientAnswers';
				END
			END
			ELSE BEGIN
				SELECT TOP 1 @MobileNo=Detail 
				FROM dbo.SeenClientAnswerMaster SCM
					INNER JOIN ContactDetails CD 
					ON SCM.ContactMasterId=CD.ContactMasterId 
					AND CD.QuestionTypeId=11 
					AND CD.IsDeleted=0
				WHERE SCM.Id= @SeenClientAnswerMasterId ;
				SET @AuditComments = 'SMS From contactDetails';
			END
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
                    GETUTCDATE(),              -- SentDate - datetime
                    @SeenClientAnswerMasterId, -- RefId - bigint
                    GETUTCDATE(),              -- CreatedOn - datetime
                    @AppUserId                 -- CreatedBy - bigint
                );

				INSERT  INTO dbo.ActivityLog
                        ( UserId ,
                          PageId ,
                          AuditComments ,
                          TableName ,
                          RecordId ,
                          CreatedOn ,
                          CreatedBy ,
                          IsDeleted   
                        )
                VALUES  ( @AppUserId ,
                          1 ,
                          @AuditComments ,
                          'PendingSMS' ,
                          @SeenClientAnswerMasterId,
                          GETUTCDATE() ,
                           @AppUserId ,
                          0  
                        ) 

            END;
        END;

        IF @SendEmail = 1
           AND @EmailText <> ''
        BEGIN
			IF @SeenClientAnswerChildId <> 0
			BEGIN
				SELECT TOP 1 @Email=CD.Detail 
				FROM dbo.SeenClientAnswers SCA
				INNER JOIN dbo.SeenClientAnswerChild SCAC ON SCAC.Id = @SeenClientAnswerChildId
				INNER JOIN dbo.ContactDetails CD ON CD.ContactMasterId = SCAC.ContactMasterId
				AND CD.QuestionTypeId=10 
				AND CD.IsDeleted=0
				WHERE SCA.SeenClientAnswerMasterId = @SeenClientAnswerMasterId;
					SET @AuditComments = 'Email From contactDetails';
				IF @Email = '' OR @Email IS NULL
				BEGIN
					SELECT  @Email = Detail
					FROM dbo.SeenClientAnswers
					WHERE SeenClientAnswerMasterId = @SeenClientAnswerMasterId
						AND (ISNULL(SeenClientAnswerChildId, 0) = ISNULL(@SeenClientAnswerChildId, 0))
						AND IsDeleted = 0
						AND QuestionTypeId = 10;
						SET @AuditComments = 'Email From SeenClientAnswers';
				END
			END
			ELSE BEGIN
				SELECT TOP 1 @Email=Detail 
				FROM dbo.SeenClientAnswerMaster SCM
					INNER JOIN ContactDetails CD 
					ON SCM.ContactMasterId=CD.ContactMasterId 
					AND CD.QuestionTypeId=10 
					AND CD.IsDeleted=0
				WHERE SCM.Id= @SeenClientAnswerMasterId 
				SET @AuditComments = 'Email From contactDetails';
			END
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
                (   3,                         -- ModuleId - bigint
                    @Email,                    -- EmailId - nvarchar(1000)
                    @EmailText,                -- EmailText - nvarchar(max)
                    @EmailSubject,
                    @SeenClientAnswerMasterId, -- RefId - bigint
                    dbo.EmailBlackListCheck(@Email),
                    GETUTCDATE(),              -- ScheduleDateTime - datetime
                    @AppUserId,                -- CreatedBy - bigint
                    @UserEmailId
                );

				INSERT  INTO dbo.ActivityLog
                        ( UserId ,
                          PageId ,
                          AuditComments ,
                          TableName ,
                          RecordId ,
                          CreatedOn ,
                          CreatedBy ,
                          IsDeleted   
                        )
                VALUES  ( @AppUserId ,
                          1 ,
                          @AuditComments ,
                          'PendingEmail' ,
                          @SeenClientAnswerMasterId,
                          GETUTCDATE() ,
                           @AppUserId ,
                          0  
                        );

            END;
        END;
		SET @Email = ''
		SET @MobileNo = ''
		SET @AuditComments = ''
				
        SET @Counter = @Counter + 1;
        CONTINUE;
    END;
END;
