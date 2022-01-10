
-- =============================================
-- Author:		<Author,,GD>
-- Create date: <Create Date,,06 Jul 2015>
-- Description:	<Description,,>
-- Call SP:		RegisterFeedBackEmailSMS 63448,4005,20174,0
-- =============================================

CREATE PROCEDURE [dbo].[RegisterFeedBackEmailSMS]
    @AnswerMasterId BIGINT,
    @QuestionnaireId BIGINT,
    @EstablishmentId BIGINT,
    @AppUserId BIGINT
AS
BEGIN
	SET DEADLOCK_PRIORITY NORMAL;
	
	BEGIN TRY
    DECLARE @SendSMS BIT,
            @SendEmail BIT,
            @SMSText NVARCHAR(MAX),
            @EmailText NVARCHAR(MAX),
            @Notification NVARCHAR(MAX),
            @NotificationForAll BIT,
            @SmileType NVARCHAR(10),
            @TimeOffSet INT = 0,
            @SendThankYouSMS BIT,
            @ThankYouSMS NVARCHAR(MAX),
            @EmailSubject NVARCHAR(500),
            @Result NVARCHAR(500),
            @ThankYouSMSType NVARCHAR(20),
            @FeedbackOnce BIT,
            @SeenClientAnswerMasterId BIGINT = NULL;

    EXEC @ThankYouSMSType = SendThankYouMessageByMultipleRouting @AnswerMasterId;

    DECLARE @EmailReceiver NVARCHAR(MAX),
            @SMSReceiver NVARCHAR(MAX);

    IF @AppUserId > 0
    BEGIN
        SELECT @EmailReceiver = Email,
               @SMSReceiver = Mobile
        FROM dbo.AppUser AS AU
            INNER JOIN dbo.AppUserEstablishment AS AUE
                ON AUE.AppUserId = AU.Id
                   AND AUE.IsDeleted = 0
                   AND AUE.EstablishmentId = @EstablishmentId
        WHERE AU.Id = @AppUserId
              AND AUE.NotificationStatus = 1
              AND AU.IsActive = 1;
    END;
    ELSE
    BEGIN
        SELECT @EmailReceiver = COALESCE(@EmailReceiver, '') + Email + N',',
               @SMSReceiver = COALESCE(@SMSReceiver, '') + Mobile + N','
        FROM dbo.AppUser AS U
            INNER JOIN dbo.AppUserEstablishment AS UE
                ON UE.AppUserId = U.Id
                   AND UE.IsDeleted = 0
        WHERE UE.EstablishmentId = @EstablishmentId
              AND UE.NotificationStatus = 1
              AND U.IsActive = 1;
    END;

    SELECT TOP 1
           @SendSMS = SendFeedbackSMSAlert,
           @SendEmail = E.SendFeedbackEmailAlert,
           @NotificationForAll = SendNotificationAlertForAll,
           @TimeOffSet = E.TimeOffSet,
           @SmileType = IsPositive,
           @SendThankYouSMS = E.SendThankYouSMS,
           @ThankYouSMS = CASE @ThankYouSMSType
                              WHEN 'negative' THEN
                                  E.ThankyoumessageforLessthanPI
                              ELSE
                                  CASE @ThankYouSMSType
                                      WHEN 'positive' THEN
                                          E.ThankyoumessageforGretareThanPI
                                      ELSE
                                          E.ThankYouMessage
                                  END
                          END,
           @Result = AM.PI,
           @FeedbackOnce = E.FeedbackOnce,
           @SeenClientAnswerMasterId = AM.SeenClientAnswerMasterId
    FROM dbo.AnswerMaster AS AM
        INNER JOIN dbo.Establishment AS E
            ON AM.EstablishmentId = E.Id
        INNER JOIN dbo.EstablishmentGroup AS Eg
            ON E.EstablishmentGroupId = Eg.Id
    WHERE E.IsDeleted = 0
          AND E.Id = @EstablishmentId
          AND AM.Id = @AnswerMasterId;

    SET @ThankYouSMS = REPLACE(@ThankYouSMS, '[refno]', CONVERT(NVARCHAR(10), @AnswerMasterId));

    SET @ThankYouSMS = REPLACE(@ThankYouSMS, '[pi]', CONVERT(NVARCHAR(10), @Result));

    /*-------------------- Disha - 03-OCT-2016 -----------------------*/
    SET @ThankYouSMS = REPLACE(@ThankYouSMS, '&nbsp;', ' ');
    /*----------------------------------------------------------------*/
    DECLARE @TenderReminderDate DATETIME = '',
            @FeedBackNotificationAlert VARCHAR(MAX) = '',
            @IsGrayOut BIT = 0;

    SELECT @SMSText = SMSText,
           @EmailText = EmailText,
           @Notification = NotificationText,
           @EmailSubject = EmailSubject,
           @FeedBackNotificationAlert = FeedBackReminderAlert
    FROM dbo.GetFeedBackAutoSMSEmailNotificationText(@AnswerMasterId);

    DECLARE @MobileNo NVARCHAR(50),
            @Email NVARCHAR(50);

    IF @SendSMS = 1
       AND @SMSText <> ''
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
            SELECT 2,
                   Data,
                   @SMSText,
                   0,
                   GETUTCDATE(),
                   @AnswerMasterId,
                   GETUTCDATE(),
                   @AppUserId
            FROM dbo.Split(@SMSReceiver, ',')
            WHERE Data <> '';
        END;

        PRINT @MobileNo;

    END;

    SELECT @MobileNo = Detail
    FROM dbo.Answers
    WHERE AnswerMasterId = @AnswerMasterId
          AND IsDeleted = 0
          AND QuestionTypeId = 11;
    PRINT @MobileNo;
    PRINT @SendThankYouSMS;
    PRINT @ThankYouSMS;
    IF @MobileNo <> ''
       AND @MobileNo IS NOT NULL
       AND @SendThankYouSMS = 1
       AND @ThankYouSMS <> ''
       AND @ThankYouSMS IS NOT NULL
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
        (   2,                             -- ModuleId - bigint
            @MobileNo,                     -- MobileNo - nvarchar(1000)
            (
                SELECT dbo.udf_StripHTML(@ThankYouSMS)
            ),                             -- SMSText - nvarchar(1000)
            0,                             -- IsSent - bit
            GETUTCDATE(), @AnswerMasterId, -- RefId - bigint
            GETUTCDATE(),                  -- CreatedOn - datetime
            @AppUserId                     -- CreatedBy - bigint
            );
    END;
    IF @SendEmail = 1
       AND @EmailText <> ''
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
                [Counter],
                ScheduleDateTime,
                CreatedBy
            )
            SELECT 2,
                   Data,
                   REPLACE(@EmailText, '##', ''),
                   @EmailSubject,
                   @AnswerMasterId,
                   0, --dbo.EmailBlackListCheck(Data),
                   GETUTCDATE(),
                   @AppUserId
            FROM dbo.Split(@EmailReceiver, ',')
            WHERE Data <> ''
                  AND Data NOT IN
                      (
                          SELECT EmailId FROM BlackListEmail WHERE IsDeleted = 0
                      );
        END;

    --SELECT  @Email = Detail
    --FROM    dbo.Answers
    --WHERE   AnswerMasterId = @AnswerMasterId
    --        AND IsDeleted = 0
    --        AND QuestionTypeId = 10;
    --IF @Email <> ''
    --    AND @Email IS NOT NULL
    --    BEGIN
    --        INSERT  INTO dbo.PendingEmail
    --                ( ModuleId ,
    --                  EmailId ,
    --                  EmailText ,
    --                  EmailSubject ,
    --                  RefId ,
    --                  ScheduleDateTime ,
    --                  CreatedBy 						        
    --                )
    --        VALUES  ( 2 , -- ModuleId - bigint
    --                  @Email , -- EmailId - nvarchar(1000)
    --                  @EmailText , -- EmailText - nvarchar(max)
    --                  'Feedback' ,
    --                  @AnswerMasterId , -- RefId - bigint
    --                  GETUTCDATE() , -- ScheduleDateTime - datetime
    --                  @AppUserId  -- CreatedBy - bigint						        
    --                );
    --    END;
    END;

    PRINT @SendSMS;
    PRINT @SendEmail;
    PRINT @FeedbackOnce;
    DECLARE @SeenclientAnaserChilidId BIGINT;
    SELECT @SeenclientAnaserChilidId = ISNULL(SeenClientAnswerChildId, 0)
    FROM dbo.AnswerMaster
    WHERE Id = @AnswerMasterId;
    IF NOT EXISTS
    (
        SELECT *
        FROM dbo.FeedbackOnceHistory
        WHERE EstablishmentId = @EstablishmentId
              AND SeenClientAnswerMasterId = @SeenClientAnswerMasterId
              AND SeenclientChildId = @SeenclientAnaserChilidId
    ) /* Added by Disha - 03-NOV-2016 - Added condition for SeenClientAnswerMasterId to Resolve Feedback Once issue for link with Sid */
    BEGIN
        IF --( @SendEmail = 1                    ////// Comment By Vasu For FeedbackOnce not effected when not configur on Feedback SMS and Email on Establishment Screen
        --   OR @SendSMS = 1				  /////  Date :- 27 Sep 2016 SPrint - B September ( Point No - # 17	URL/.mobi review from Assembla)  	
        --	 )AND 
        @FeedbackOnce = 1
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
                @AnswerMasterId,           -- AnswerMasterId - bigint
                @SeenClientAnswerMasterId, -- SeenClientAnswerMasterId - bigint /* Added by Disha - 03-NOV-2016 - Resolve Feedback Once issue for link with Sid */
                1,                         -- IsFeedBackSubmitted - bit,
                @SeenclientAnaserChilidId);
        END;
    END;

    DECLARE @CreatedBy INT = 0;
    SELECT @CreatedBy = ISNULL(Id, 0)
    FROM dbo.AnswerMaster
    WHERE Id = @AnswerMasterId;

    IF (
           @SmileType = 'Negative'
           OR @NotificationForAll = 1
       )
       AND @Notification <> ''
    BEGIN
        -------GetCustomerName------------------------
        DECLARE @TempTable TABLE
        (
            ContactId BIGINT,
            GroupId BIGINT,
            ContactQuestionId BIGINT,
            ContactOptionId BIGINT,
            QuestionTypeId BIGINT,
            Detail NVARCHAR(500)
        );
        INSERT INTO @TempTable
        (
            ContactId,
            GroupId,
            ContactQuestionId,
            ContactOptionId,
            QuestionTypeId,
            Detail
        )
        --SELECT CQ.ContactId,
        --       E.GroupId,
        --       CQ.Id,
        --       CO.Id,
        --       CQ.QuestionTypeId,
        --       A.Detail
        --FROM dbo.Questions AS Q
        --    INNER JOIN dbo.Answers AS A
        --        ON A.QuestionId = Q.Id
        --    INNER JOIN dbo.ContactQuestions AS CQ
        --        ON CQ.Id = Q.ContactQuestionIdRef
        --    INNER JOIN dbo.AnswerMaster AS AM
        --        ON AM.Id = A.AnswerMasterId
        --    INNER JOIN dbo.Establishment AS E
        --        ON E.Id = AM.EstablishmentId
        --    LEFT OUTER JOIN dbo.ContactOptions AS CO
        --        ON CO.ContactQuestionId = CQ.Id
        --    LEFT OUTER JOIN dbo.Options AS o
        --        ON o.Id = A.OptionId
        --WHERE A.AnswerMasterId = @AnswerMasterId
        --      AND Q.ContactQuestionIdRef IS NOT NULL
        --      AND ISNULL(CO.Position, 0) = ISNULL(o.Position, 0);
        SELECT CQ.ContactId,
               E.GroupId,
               CQ.Id,
               ISNULL(CO.Id, 0) AS ID,
               CQ.QuestionTypeId,
               A.Detail
        FROM dbo.Questions AS Q
            INNER JOIN dbo.Answers AS A
                ON A.QuestionId = Q.Id
            INNER JOIN dbo.ContactQuestions AS CQ
                ON CQ.Id = Q.ContactQuestionIdRef
            INNER JOIN dbo.AnswerMaster AS AM
                ON AM.Id = A.AnswerMasterId
            INNER JOIN dbo.Establishment AS E
                ON E.Id = AM.EstablishmentId
            LEFT OUTER JOIN dbo.ContactOptions AS CO
                ON CO.ContactQuestionId = CQ.Id
            LEFT OUTER JOIN dbo.Options AS o
                --ON o.Id = A.OptionId
                ON o.QuestionId = A.QuestionId
        WHERE A.AnswerMasterId = @AnswerMasterId
              AND Q.ContactQuestionIdRef IS NOT NULL
              AND ISNULL(CO.Position, 0) = ISNULL(o.Position, 0)
              AND A.Detail NOT LIKE '%,%'
        UNION
        SELECT CQ.ContactId,
               E.GroupId,
               CQ.Id,
               CO.Id AS ID,
               CQ.QuestionTypeId,
               CASE
                   WHEN ISNULL(o.Name, '') = '' THEN
                       ''
                   ELSE
                       o.Name
               END AS Detail
        FROM dbo.Questions AS Q
            INNER JOIN dbo.Answers AS A
                ON A.QuestionId = Q.Id
            INNER JOIN dbo.ContactQuestions AS CQ
                ON CQ.Id = Q.ContactQuestionIdRef
            INNER JOIN dbo.AnswerMaster AS AM
                ON AM.Id = A.AnswerMasterId
            INNER JOIN dbo.Establishment AS E
                ON E.Id = AM.EstablishmentId
            LEFT OUTER JOIN dbo.ContactOptions AS CO
                ON CO.ContactQuestionId = CQ.Id
            LEFT OUTER JOIN dbo.Options AS o
                ON o.QuestionId = A.QuestionId
        WHERE A.AnswerMasterId = @AnswerMasterId
              AND o.Name IN
                  (
                      SELECT Data FROM Split(A.Detail, ',')
                  )
              AND Q.ContactQuestionIdRef IS NOT NULL
              AND ISNULL(CO.Position, 0) = ISNULL(o.Position, 0);

        DECLARE @EmailIdCustomer NVARCHAR(50),
                @Mobile NVARCHAR(20),
                @CustomerName NVARCHAR(100),
                @FinalName NVARCHAR(100);
        SELECT TOP 1
               @CustomerName = Detail
        FROM @TempTable
        WHERE QuestionTypeId = 4;
        SELECT @EmailIdCustomer = Detail
        FROM @TempTable
        WHERE QuestionTypeId = 10;
        SELECT @Mobile = Detail
        FROM @TempTable
        WHERE QuestionTypeId = 11;
        IF (@CustomerName != '')
        BEGIN
            PRINT 1;
            SET @FinalName = (ISNULL(@CustomerName, ''));

        END;
        ELSE IF (@EmailIdCustomer != '')
        BEGIN
            PRINT 2;
            SET @FinalName = LEFT(@EmailIdCustomer, (CHARINDEX('@', @EmailIdCustomer) - 1));
        END;
        ELSE
        BEGIN
            SET @FinalName = ISNULL(RTRIM(LTRIM(@Mobile)), '');
        END;
        PRINT '@FinalName' + @FinalName;
        ---------GetCustomerName------------------------
        DECLARE @EstablishmentGroupId BIGINT;
        DECLARE @ActivityType NVARCHAR(100);
        SET @EstablishmentGroupId =
        (
            SELECT EstablishmentGroupId
            FROM dbo.Establishment
            WHERE Id = @EstablishmentId
        );

        SET @ActivityType =
        (
            SELECT EstablishmentGroupType
            FROM dbo.EstablishmentGroup
            WHERE Id = @EstablishmentGroupId
        );

        SELECT @IsGrayOut
            = (CASE
                   WHEN ISNULL(
                        (
                            SELECT TOP 1
                                   ISNULL(SCA.Detail, '')
                            FROM dbo.SeenClientQuestions SCQ
                                INNER JOIN dbo.SeenClientAnswers SCA
                                    ON SCQ.Id = SCA.QuestionId
                                       AND SCQ.TenderQuestionType = 3
                                INNER JOIN dbo.AnswerMaster AM
                                    ON AM.Id = @AnswerMasterId
                                       AND AM.SeenClientAnswerMasterId = SCA.SeenClientAnswerMasterId
                        ),
                        ''
                              ) != '' THEN
                       CASE
                           WHEN
        (
            SELECT TOP 1
                   CAST(ISNULL(SCA.Detail, '1900-01-01') AS DATETIME)
            FROM dbo.SeenClientQuestions SCQ
                INNER JOIN dbo.SeenClientAnswers SCA
                    ON SCQ.Id = SCA.QuestionId
                       AND SCQ.TenderQuestionType = 3
                INNER JOIN dbo.AnswerMaster AM
                    ON AM.Id = @AnswerMasterId
                       AND AM.SeenClientAnswerMasterId = SCA.SeenClientAnswerMasterId
        )   < DATEADD(MINUTE, @TimeOffSet, GETUTCDATE()) THEN
                               0
                           ELSE
                               1
                       END
                   ELSE
                       0
               END
              );

        SELECT TOP 1
               @TenderReminderDate = ISNULL(A.Detail, '')
        FROM dbo.Answers A
            INNER JOIN dbo.Questions Q
                ON Q.Id = A.QuestionId
        WHERE A.AnswerMasterId = @AnswerMasterId
              AND A.QuestionTypeId = 22
              AND ISNULL(Q.IsForReminder, 0) = 1;

        IF (@FeedBackNotificationAlert = '')
        BEGIN
            SET @FeedBackNotificationAlert = @Notification;
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
                CreatedBy
            )
            SELECT 2,
                   @FeedBackNotificationAlert,
                   TokenId,
                   0,
                   NULL,
                   DATEADD(MINUTE, -@TimeOffSet, @TenderReminderDate),
                   @AnswerMasterId,
                   UserTokenDetails.AppUserId,
                   DeviceTypeId,
                   @AppUserId
            FROM dbo.AnswerMaster SA
                INNER JOIN dbo.AppUser A
                    ON SA.CreatedBy = A.Id
                       AND A.IsActive = 1
                INNER JOIN dbo.UserTokenDetails
                    ON UserTokenDetails.AppUserId = SA.CreatedBy
                       AND SA.Id = @AnswerMasterId
            UNION
            SELECT 2,
                   @FeedBackNotificationAlert,
                   TokenId,
                   0,
                   NULL,
                   DATEADD(MINUTE, -@TimeOffSet, @TenderReminderDate),
                   @AnswerMasterId,
                   T.AppUserId,
                   DeviceTypeId,
                   @AppUserId
            FROM dbo.AppUserEstablishment AS AUE
                INNER JOIN dbo.AppUser AS U
                    ON AUE.AppUserId = U.Id
                       AND U.IsActive = 1
                       AND U.IsDeleted = 0
                INNER JOIN dbo.UserTokenDetails AS T
                    ON AUE.AppUserId = T.AppUserId
                INNER JOIN dbo.Establishment AS E
                    ON AUE.EstablishmentId = E.Id
                INNER JOIN dbo.AppManagerUserRights AS AM
                    ON AM.UserId = U.Id
                       AND AM.EstablishmentId = E.Id
                       AND AM.ManagerUserId = @AppUserId
            WHERE AUE.IsDeleted = 0
                  AND E.Id = @EstablishmentId
                  AND AUE.NotificationStatus = 1
                  AND LEN(TokenId) > 10
                  AND U.IsActive = 1
                  AND IsAreaManager = 1
                  AND U.Id <> @AppUserId
                  AND AM.IsDeleted = 0;
            INSERT INTO dbo.PendingNotificationWeb
            (
                ModuleId,
                [Message],
                IsRead,
                ScheduleDate,
                RefId,
                AppUserId,
                CreatedOn,
                CreatedBy,
                CustomerName
            )
            SELECT DISTINCT
                   2,
                   @FeedBackNotificationAlert,
                   0,
                   DATEADD(MINUTE, -@TimeOffSet, @TenderReminderDate),
                   @AnswerMasterId,
                   A.Id,
                   DATEADD(MINUTE, -@TimeOffSet, @TenderReminderDate),
                   @AppUserId,
                   @FinalName
            FROM dbo.AnswerMaster SA
                INNER JOIN dbo.AppUser A
                    ON SA.CreatedBy = A.Id
                       AND A.IsActive = 1
                       AND SA.Id = @AnswerMasterId
            UNION
            SELECT DISTINCT
                   2,
                   @FeedBackNotificationAlert,
                   0,
                   DATEADD(MINUTE, -@TimeOffSet, @TenderReminderDate),
                   @AnswerMasterId,
                   ISNULL(AM.UserId, U.Id),
                   DATEADD(MINUTE, -@TimeOffSet, @TenderReminderDate),
                   @AppUserId,
                   @FinalName
            FROM dbo.AppUserEstablishment AS AUE
                INNER JOIN dbo.AppUser AS U
                    ON AUE.AppUserId = U.Id
                       AND U.IsActive = 1
                       AND U.IsDeleted = 0
                INNER JOIN dbo.Establishment AS E
                    ON AUE.EstablishmentId = E.Id
                INNER JOIN dbo.AppManagerUserRights AS AM
                    ON AM.UserId = U.Id
                       AND AM.EstablishmentId = E.Id
                       AND AM.ManagerUserId = @AppUserId
            WHERE AUE.IsDeleted = 0
                  AND E.Id = @EstablishmentId
                  AND AUE.NotificationStatus = 1
                  AND U.IsActive = 1
                  AND IsAreaManager = 1
                  AND U.Id <> @AppUserId
                  AND AM.IsDeleted = 0;
        END;

        IF (@ActivityType = 'Sales')
        BEGIN
            PRINT 'Sales';
            IF (@IsGrayOut = 0)
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
                    CreatedBy
                )
                SELECT 2,
                       @Notification,
                       TokenId,
                       0,
                       NULL,
                       GETUTCDATE(),
                       @AnswerMasterId,
                       UserTokenDetails.AppUserId,
                       DeviceTypeId,
                       @CreatedBy
                FROM dbo.AnswerMaster SA
                    INNER JOIN dbo.AppUser A
                        ON SA.CreatedBy = A.Id
                           AND A.IsActive = 1
                    INNER JOIN dbo.UserTokenDetails
                        ON UserTokenDetails.AppUserId = SA.CreatedBy
                           AND SA.Id = @AnswerMasterId
                UNION
                SELECT 2,
                       @Notification,
                       TokenId,
                       0,
                       NULL,
                       GETUTCDATE(),
                       @AnswerMasterId,
                       T.AppUserId,
                       DeviceTypeId,
                       @CreatedBy
                FROM dbo.AppUserEstablishment AS AUE
                    INNER JOIN dbo.AppUser AS U
                        ON AUE.AppUserId = U.Id
                           AND U.IsActive = 1
                           AND U.IsDeleted = 0
                    INNER JOIN dbo.UserTokenDetails AS T
                        ON AUE.AppUserId = T.AppUserId
                    INNER JOIN dbo.Establishment AS E
                        ON AUE.EstablishmentId = E.Id
                    INNER JOIN dbo.AppManagerUserRights AS AM
                        ON AM.UserId = U.Id
                           AND AM.EstablishmentId = E.Id
                           AND AM.ManagerUserId = @AppUserId
                WHERE AUE.IsDeleted = 0
                      AND E.Id = @EstablishmentId
                      AND AUE.NotificationStatus = 1
                      AND LEN(TokenId) > 10
                      AND U.IsActive = 1
                      AND IsAreaManager = 1
                      AND U.Id <> @AppUserId
                      AND AM.IsDeleted = 0;
            END;
            INSERT INTO dbo.PendingNotificationWeb
            (
                ModuleId,
                [Message],
                IsRead,
                ScheduleDate,
                RefId,
                AppUserId,
                CreatedOn,
                CreatedBy,
                CustomerName
            )
            SELECT DISTINCT
                   2,
                   @Notification,
                   0,
                   GETUTCDATE(),
                   @AnswerMasterId,
                   A.Id,
                   GETUTCDATE(),
                   @CreatedBy,
                   @FinalName
            FROM dbo.AnswerMaster SA
                INNER JOIN dbo.AppUser A
                    ON SA.CreatedBy = A.Id
                       AND A.IsActive = 1
                       AND SA.Id = @AnswerMasterId
            UNION
            SELECT DISTINCT
                   2,
                   @Notification,
                   0,
                   GETUTCDATE(),
                   @AnswerMasterId,
                   ISNULL(AM.UserId, U.Id),
                   GETUTCDATE(),
                   @CreatedBy,
                   @FinalName
            FROM dbo.AppUserEstablishment AS AUE
                INNER JOIN dbo.AppUser AS U
                    ON AUE.AppUserId = U.Id
                       AND U.IsActive = 1
                       AND U.IsDeleted = 0
                INNER JOIN dbo.Establishment AS E
                    ON AUE.EstablishmentId = E.Id
                INNER JOIN dbo.AppManagerUserRights AS AM
                    ON AM.UserId = U.Id
                       AND AM.EstablishmentId = E.Id
                       AND AM.ManagerUserId = @AppUserId
            WHERE AUE.IsDeleted = 0
                  AND E.Id = @EstablishmentId
                  AND AUE.NotificationStatus = 1
                  AND U.IsActive = 1
                  AND IsAreaManager = 1
                  AND U.Id <> @AppUserId
                  AND AM.IsDeleted = 0;

        END;
        ELSE
        BEGIN
            PRINT 'Customer';
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
                CreatedBy
            )
            SELECT 2,
                   @Notification,
                   TokenId,
                   0,
                   NULL,
                   GETUTCDATE(),
                   @AnswerMasterId,
                   UserTokenDetails.AppUserId,
                   DeviceTypeId,
                   @CreatedBy
            FROM dbo.AnswerMaster SA
                INNER JOIN dbo.AppUser A
                    ON SA.CreatedBy = A.Id
                       AND A.IsActive = 1
                INNER JOIN dbo.UserTokenDetails
                    ON UserTokenDetails.AppUserId = SA.CreatedBy
                       AND SA.Id = @AnswerMasterId
            UNION
            SELECT 2,
                   @Notification,
                   TokenId,
                   0,
                   NULL,
                   GETUTCDATE(),
                   @AnswerMasterId,
                   T.AppUserId,
                   DeviceTypeId,
                   @CreatedBy
            FROM dbo.AppUserEstablishment AS AUE
                INNER JOIN dbo.AnswerMaster AS SCA
                    ON SCA.Id = @AnswerMasterId --22536 
                LEFT JOIN dbo.AppManagerUserRights AS amu
                    ON amu.EstablishmentId = SCA.EstablishmentId
                       AND amu.EstablishmentId = AUE.EstablishmentId
                       AND amu.ManagerUserId = SCA.CreatedBy
                       AND amu.IsDeleted = 0
                       AND amu.UserId = AUE.AppUserId
                INNER JOIN dbo.UserTokenDetails AS T
                    ON T.AppUserId = ISNULL(amu.UserId, AUE.AppUserId)
                       AND AUE.EstablishmentId = SCA.EstablishmentId
                INNER JOIN dbo.AppUser AS U
                    ON U.Id = T.AppUserId
                       AND U.IsActive = 1
            WHERE AUE.IsDeleted = 0
                  AND AUE.NotificationStatus = 1
                  AND U.IsDeleted = 0
                  AND U.IsActive = 1
                  AND
                  (
                      SCA.CreatedBy = U.Id
                      OR U.IsAreaManager = 1
                  )
                  AND LEN(TokenId) > 10
            GROUP BY T.AppUserId,
                     T.TokenId,
                     T.DeviceTypeId;
            INSERT INTO dbo.PendingNotificationWeb
            (
                ModuleId,
                [Message],
                IsRead,
                ScheduleDate,
                RefId,
                AppUserId,
                CreatedOn,
                CreatedBy,
                CustomerName
            )
            SELECT DISTINCT
                   2,
                   @Notification,
                   0,
                   GETUTCDATE(),
                   @AnswerMasterId,
                   A.Id,
                   GETUTCDATE(),
                   @CreatedBy,
                   @FinalName
            FROM dbo.AnswerMaster SA
                INNER JOIN dbo.AppUser A
                    ON SA.CreatedBy = A.Id
                       AND A.IsActive = 1
                       AND SA.Id = @AnswerMasterId
            UNION
            SELECT DISTINCT
                   2,
                   @Notification,
                   0,
                   GETUTCDATE(),
                   @AnswerMasterId,
                   ISNULL(amu.UserId, U.Id),
                   GETUTCDATE(),
                   @CreatedBy,
                   @FinalName
            FROM dbo.AppUserEstablishment AS AUE
                INNER JOIN dbo.AnswerMaster AS SCA
                    ON SCA.Id = @AnswerMasterId --22536 
                LEFT JOIN dbo.AppManagerUserRights AS amu
                    ON amu.EstablishmentId = SCA.EstablishmentId
                       AND amu.EstablishmentId = AUE.EstablishmentId
                       AND amu.ManagerUserId = SCA.CreatedBy
                       AND amu.IsDeleted = 0
                       AND amu.UserId = AUE.AppUserId
                INNER JOIN dbo.AppUser AS U
                    ON U.Id = ISNULL(amu.UserId, AUE.AppUserId)
                       AND AUE.EstablishmentId = SCA.EstablishmentId
                       AND U.IsActive = 1
            WHERE AUE.IsDeleted = 0
                  AND AUE.NotificationStatus = 1
                  AND U.IsDeleted = 0
                  AND U.IsActive = 1
                  AND
                  (
                      SCA.CreatedBy = U.Id
                      OR U.IsAreaManager = 1
                  )
            GROUP BY amu.UserId,
                     U.Id;
        END;
    END;
    PRINT 'Phase 1';
    DECLARE @IsEmail BIT,
            @IsSMS BIT;
    SET @IsEmail =
    (
        SELECT ISAdditionalFeedbackEmail
        FROM dbo.Establishment
        WHERE Id = @EstablishmentId
    );
    SET @IsSMS =
    (
        SELECT ISAdditionalFeedbackSMS
        FROM dbo.Establishment
        WHERE Id = @EstablishmentId
    );
    PRINT @IsEmail;
    PRINT @IsSMS;
    PRINT 'Phase 2';
    IF (@IsEmail = 1 OR @IsSMS = 1)
    BEGIN
        PRINT 'Phase 3';
        PRINT 3;
        EXEC dbo.AdditionalRegisterFeedBackEmailSMS @AnswerMasterId,
                                                    @QuestionnaireId,
                                                    @EstablishmentId,
                                                    @AppUserId;

    END;
    PRINT 'Phase 4';
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
         'dbo.RegisterFeedBackEmailSMS',
         N'DATABASE',
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
--END;
