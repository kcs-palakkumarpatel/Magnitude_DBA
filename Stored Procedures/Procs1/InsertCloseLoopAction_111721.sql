
-- =============================================  
-- Author:  <Author,,GD>  
-- Create date: <Create Date,,02 Jul 2015>  
-- Description: <Description,,>  
-- Call SP:  InsertCloseLoopAction 1,'Hello GOODHelll',37055,0,'','','35480','ananttestIN' 
-- =============================================  
CREATE PROCEDURE [dbo].[InsertCloseLoopAction_111721]
    @AppUserId BIGINT,
    @Conversation NVARCHAR(2000),
    @ReportId BIGINT,
    @IsOut BIT,
    @ReminderDate NVARCHAR(50),
    @Attachment VARCHAR(MAX),
    @lgCustomerUserId BIGINT,
    @CustomerName NVARCHAR(MAX)
AS
BEGIN
    DECLARE @EstablishmentId BIGINT,
            @Id BIGINT,
            @TimeOfSet INT,
            @EstablishmentName NVARCHAR(100),
            @UserName NVARCHAR(50),
            @Message NVARCHAR(500),
            @IsExternaltype INT,
            @CurrentUser BIGINT;

    SELECT @CurrentUser = AppUserId
    FROM dbo.SeenClientAnswerMaster
    WHERE Id = @ReportId;  

    DECLARE @LatestAppVersion INT;
    SELECT @LatestAppVersion = CAST(KeyValue AS INT)
    FROM dbo.AAAAConfigSettings
    WHERE KeyName = 'androidVersion';

    SELECT @CurrentUser = AppUserId
    FROM dbo.SeenClientAnswerMaster
    WHERE Id = @ReportId;

    SELECT TOP (1)
        @IsExternaltype = IsExternalType
    FROM dbo.CloseLoopAction
    WHERE SeenClientAnswerMasterId = @ReportId
          AND AppUserId = @CurrentUser
    ORDER BY Id DESC;


    IF @IsExternaltype != 0
    BEGIN
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
                IsExternalType,
                Attachment,
                CustomerAppId,
                CustomerName
            )
            VALUES
            (   NULL,          -- AnswerMasterId - bigint      
                @ReportId,     -- SeenClientAnswerMasterId - bigint      
                @AppUserId,    -- AppUserId - bigint      
                @Conversation, -- Conversation - nvarchar(2000)      
                2,
                @Attachment,
                @lgCustomerUserId,
                @CustomerName
            );

            SELECT @Id = SCOPE_IDENTITY();

            UPDATE dbo.SeenClientAnswerMaster
            SET IsActioned = 1
            WHERE Id = @ReportId;
        END;
        ELSE
        BEGIN
            IF @IsExternaltype != 0
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
                    IsExternalType,
                    Attachment,
                    CustomerAppId,
                    CustomerName
                )
                VALUES
                (   @ReportId,          -- AnswerMasterId - bigint      
                    NULL,     -- SeenClientAnswerMasterId - bigint      
                    @AppUserId,    -- AppUserId - bigint      
                    @Conversation, -- Conversation - nvarchar(2000)      
                    2,
                    @Attachment,
                    @lgCustomerUserId,
                    @CustomerName
                );
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
                    IsExternalType,
                    Attachment,
                    CustomerAppId,
                    CustomerName
                )
                VALUES
                (   @ReportId,     -- AnswerMasterId - bigint      
                    NULL,          -- SeenClientAnswerMasterId - bigint      
                    @AppUserId,    -- AppUserId - bigint      
                    @Conversation, -- Conversation - nvarchar(2000)      
                    2,
                    @Attachment,
                    @lgCustomerUserId,
                    @CustomerName
                );
            END;
            SELECT @Id = SCOPE_IDENTITY();

            UPDATE dbo.AnswerMaster
            SET IsActioned = 1
            WHERE Id = @ReportId;
        END;
    END;
    ELSE
    BEGIN
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
                IsExternalType,
                Attachment,
                CustomerAppId,
                CustomerName
            )
            VALUES
            (   NULL,          -- AnswerMasterId - bigint      
                @ReportId,     -- SeenClientAnswerMasterId - bigint      
                @AppUserId,    -- AppUserId - bigint      
                @Conversation, -- Conversation - nvarchar(2000)      
                2,
                @Attachment,
                @lgCustomerUserId,
                @CustomerName
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
                IsExternalType,
                Attachment,
                CustomerAppId,
                CustomerName
            )
            VALUES
            (   @ReportId,         -- AnswerMasterId - bigint      
                NULL,              -- SeenClientAnswerMasterId - bigint      
                @AppUserId,        -- AppUserId - bigint      
                @Conversation,
                2,
                @Attachment,
                @lgCustomerUserId, -- Conversation - nvarchar(2000)      
                @CustomerName
            );

            SELECT @Id = SCOPE_IDENTITY();

            UPDATE dbo.AnswerMaster
            SET IsActioned = 1
            WHERE Id = @ReportId;
        END;
    END;

    --  IF @ReminderDate <> ''      
    --      AND @ReminderDate IS NOT NULL      
    --      BEGIN      

    SELECT @EstablishmentName = EstablishmentName
    FROM dbo.Establishment
    WHERE Id = @EstablishmentId;
    SELECT @UserName = UserName
    FROM dbo.AppUser
    WHERE Id = @CurrentUser;
    IF ((SELECT CHARINDEX('esolved - Ref#', @Conversation)) = 0)
    BEGIN
        IF (@IsOut = 0)
        BEGIN
		PRINT 'IN'
		SET @Message = 'Activity: ' + @EstablishmentName + '; User: ' + @CustomerName + '; Action: ' +
                   (
                       @Conversation
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
            SELECT 
			DISTINCT CASE @IsOut
                       WHEN 0 THEN
                           11
                       ELSE
                           12
                   END AS MoudleId,
                   -- CASE
                      --  WHEN LEN(@Message) > 197 THEN
                         --  LEFT(@Message, 197) + '...'
                       -- ELSE
                          -- @Message
                   --END,
                   @Conversation,      
                   TokenId,
                   0,
                   NULL,
                   DATEADD(MINUTE, -@TimeOfSet, GETUTCDATE()),
                   @ReportId,
                   T.AppUserId,
                   DeviceTypeId,
                   @AppUserId,
				   T.AppVersion
                   --ISNULL(T.AppVersion, @LatestAppVersion)
            FROM dbo.AppUserEstablishment AS UE
                INNER JOIN dbo.AppUser AS U
                    ON UE.AppUserId = U.Id
                INNER JOIN dbo.UserTokenDetails AS T
                    ON UE.AppUserId = T.AppUserId
                INNER JOIN dbo.Establishment AS E
                    ON UE.EstablishmentId = E.Id
            WHERE UE.IsDeleted = 0
                  AND E.IsDeleted = 0
                  AND E.Id = @EstablishmentId
                  AND UE.NotificationStatus = 1
                  AND LEN(TokenId) > 10

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
                UE.AppUserId,
                GETUTCDATE(),
                @AppUserId,
                @CustomerName
            FROM dbo.AppUserEstablishment AS UE
                INNER JOIN dbo.AppUser AS U
                    ON UE.AppUserId = U.Id
                INNER JOIN dbo.Establishment AS E
                    ON UE.EstablishmentId = E.Id
            WHERE UE.IsDeleted = 0
                  AND E.IsDeleted = 0
                  AND E.Id = @EstablishmentId
				 
        END;
        ELSE
        BEGIN
		SET @Message = 'Activity: ' + @EstablishmentName + '; User: ' + @CustomerName + '; Action: ' +
                   (
                       @Conversation
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
            SELECT CASE @IsOut
                       WHEN 0 THEN
                           11
                       ELSE
                           12
                   END AS MoudleId,
                   --  CASE
                      --  WHEN LEN(@Message) > 197 THEN
                       --     LEFT(@Message, 197) + '...'
                     --   ELSE
                   --         @Message
                  --  END,
                   @Conversation,      
                   TokenId,
                   0,
                   NULL,
                   DATEADD(MINUTE, -@TimeOfSet, GETUTCDATE()),
                   @ReportId,
                   T.AppUserId,
                   DeviceTypeId,
                   @AppUserId,
                   T.AppVersion
				   --ISNULL(T.AppVersion, @LatestAppVersion)
            FROM dbo.AppUserEstablishment AS UE
                INNER JOIN dbo.AppUser AS U
                    ON UE.AppUserId = U.Id
                INNER JOIN dbo.UserTokenDetails AS T
                    ON UE.AppUserId = T.AppUserId
                INNER JOIN dbo.Establishment AS E
                    ON UE.EstablishmentId = E.Id
            WHERE UE.IsDeleted = 0
                  AND E.IsDeleted = 0
                  AND E.Id = @EstablishmentId
                  AND UE.NotificationStatus = 1
                  AND LEN(TokenId) > 10
                  AND T.AppUserId = @CurrentUser;
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
                UE.AppUserId,
                GETUTCDATE(),
                @AppUserId,
                @CustomerName
            FROM dbo.AppUserEstablishment AS UE
                INNER JOIN dbo.AppUser AS U
                    ON UE.AppUserId = U.Id
                INNER JOIN dbo.Establishment AS E
                    ON UE.EstablishmentId = E.Id
            WHERE UE.IsDeleted = 0
                  AND E.IsDeleted = 0
                  AND E.Id = @EstablishmentId
                  AND U.Id = @CurrentUser;
        END;
        RETURN 1;
    END;
    ELSE
    BEGIN
        RETURN 1;
    END;
END;


