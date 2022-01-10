
-- =============================================
-- Author:		<Mittal,,GD>
-- Create date: <Create Date,, 19 May 2021>
-- Description:	<Description,,UpdateFormStatus>
-- Call SP    :	UpdateFormStatus
-- =============================================
CREATE PROCEDURE [dbo].[UpdateFormStatus]
    @AppUserId BIGINT,
    @UpdateFormStatusTableType UpdateStatusTableType READONLY
AS
BEGIN
	SET DEADLOCK_PRIORITY NORMAL;
	
	BEGIN TRY
    DECLARE @TotalCount INT = 0;
    DECLARE @Counter INT = 1;

    IF OBJECT_ID('tempdb..#TempUpdateStatus', 'U') IS NOT NULL
        DROP TABLE #TempUpdateStatus;

    CREATE TABLE #TempUpdateStatus
    (
        Id INT IDENTITY(1, 1),
        ReportId BIGINT NULL,
        Status VARCHAR(20) NULL,
        IsOut BIT NULL,
        ResolveStatusChangeTime DATETIME2 NULL
    );

    INSERT INTO #TempUpdateStatus
    (
        ReportId,
        Status,
        IsOut,
        ResolveStatusChangeTime
    )
    SELECT ReportId,
           Status,
           IsOut,
           ResolveStatusChangeTime
    FROM @UpdateFormStatusTableType;

    SET @TotalCount =
    (
        SELECT COUNT(*) FROM #TempUpdateStatus
    );

    WHILE @Counter <= @TotalCount
    BEGIN
        DECLARE @ReportId BIGINT,
                @Status VARCHAR(20),
                @IsOut BIT,
                @ResolveStatusChangeTime DATETIME,
                @Conversation VARCHAR(50),
                @EstablishmentStatusId BIGINT;

        SELECT @ReportId = ReportId,
               @Status = Status,
               @IsOut = IsOut,
               @ResolveStatusChangeTime = ResolveStatusChangeTime
        FROM #TempUpdateStatus
        WHERE Id = @Counter;

        IF (@IsOut = 1)
        BEGIN

            --Get Status Id
            IF (@Status = 'Resolved' OR @Status = 'resolved')
            BEGIN
                (SELECT @EstablishmentStatusId = es.Id
                 FROM dbo.EstablishmentStatus AS es
                     INNER JOIN dbo.SeenClientAnswerMaster AS SA
                         ON es.EstablishmentId = SA.EstablishmentId
                 WHERE SA.Id = @ReportId
                       AND DefaultEndStatus = 1
                       AND es.IsDeleted = 0);
            END;
            ELSE
            BEGIN
                (SELECT @EstablishmentStatusId = Es.Id
                 FROM dbo.EstablishmentStatus AS es
                     INNER JOIN dbo.SeenClientAnswerMaster AS SA
                         ON es.EstablishmentId = SA.EstablishmentId
                 WHERE SA.Id = @ReportId
                       AND es.DefaultStartStatus = 1
                       AND es.isdeleted = 0);
            END;

            --Insert Status History
            EXEC dbo.InsertStatusHistoryForUpdateStatus @ReferenceNo = @ReportId,                        -- bigint
                                         @EstablishmentStatusId = @EstablishmentStatusId, -- bigint
                                         @UserId = @AppUserId,                            -- bigint
                                         @Latitude = '0.00',                              -- nvarchar(50)
                                         @Longitude = '0.00',                             -- nvarchar(50)
                                         @StatusDateTime = @ResolveStatusChangeTime,      -- datetime
                                         @isWeb = NULL;


            UPDATE dbo.SeenClientAnswerMaster
            SET IsResolved = @Status,
                UpdatedOn = GETUTCDATE(),
                UpdatedBy = @AppUserId
            WHERE Id = @ReportId;

            UPDATE dbo.SeenClientAnswerMaster
            SET StatusHistoryId =
                (
                    SELECT TOP 1
                        Id
                    FROM dbo.StatusHistory
                    WHERE ReferenceNo = @ReportId
                    ORDER BY StatusDateTime desc
                )
            WHERE Id = @ReportId;

            SET @Conversation = @Status + ' - Ref# ' + CONVERT(VARCHAR(50), @ReportId);

            INSERT INTO dbo.CloseLoopAction
            (
                AnswerMasterId,
                SeenClientAnswerMasterId,
                AppUserId,
                CONVERSATION,
                IsReminderSet,
                CreatedOn,
                DeletedOn,
                DeletedBy,
                IsDeleted,
                Attachment,
                IsNote,
                IsExternalType,
                CustomerAppId,
                CustomerName
            )
            VALUES
            (   NULL,          -- AnswerMasterId - bigint
                @ReportId,     -- SeenClientAnswerMasterId - bigint
                @AppUserId,    -- AppUserId - bigint
                @Conversation, -- Conversation - nvarchar(max)
                0,             -- IsReminderSet - bit
                @ResolveStatusChangeTime,     -- CreatedOn - datetime
                NULL,          -- DeletedOn - datetime
                NULL,          -- DeletedBy - bigint
                0,             -- IsDeleted - bit
                '',            -- Attachment - varchar(max)
                0,             -- IsNote - bit
                2,             -- IsExternalType - int
                NULL,          -- CustomerAppId - varchar(1000)
                NULL           -- CustomerName - nvarchar(max)
            );

        END;
        ELSE
        BEGIN
            UPDATE dbo.AnswerMaster
            SET IsResolved = @Status,
                UpdatedOn = GETUTCDATE(),
                UpdatedBy = @AppUserId
            WHERE Id = @ReportId;

            SET @Conversation = @Status + ' - Ref# ' + CONVERT(VARCHAR(50), @ReportId);

            INSERT INTO dbo.CloseLoopAction
            (
                AnswerMasterId,
                SeenClientAnswerMasterId,
                AppUserId,
                CONVERSATION,
                IsReminderSet,
                CreatedOn,
                DeletedOn,
                DeletedBy,
                IsDeleted,
                Attachment,
                IsNote,
                IsExternalType,
                CustomerAppId,
                CustomerName
            )
            VALUES
            (   @ReportId,     -- AnswerMasterId - bigint
                NULL,          -- SeenClientAnswerMasterId - bigint
                @AppUserId,    -- AppUserId - bigint
                @Conversation, -- Conversation - nvarchar(max)
                0,             -- IsReminderSet - bit
                @ResolveStatusChangeTime,     -- CreatedOn - datetime
                NULL,          -- DeletedOn - datetime
                NULL,          -- DeletedBy - bigint
                0,             -- IsDeleted - bit
                '',            -- Attachment - varchar(max)
                0,             -- IsNote - bit
                2,             -- IsExternalType - int
                NULL,          -- CustomerAppId - varchar(1000)
                NULL           -- CustomerName - nvarchar(max)
            );

        END;

        SET @Counter = @Counter + 1;
        CONTINUE;
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
         'dbo.UpdateFormStatus',
         N'DATABASE',
         ERROR_MESSAGE(),
         ('ERROR_NUMBER=' + CONVERT(VARCHAR(100), ERROR_NUMBER()) + ',ERROR_STATE='
          + CONVERT(VARCHAR(20), ERROR_STATE()) + ',ERROR_SEVERITY=' + CONVERT(VARCHAR(20), ERROR_SEVERITY())
         )  ,
         GETUTCDATE(),
         ISNULL(@AppUserId,0),
         @AppUserId,
         GETUTCDATE(),
         ISNULL(@AppUserId,0)
        );
END CATCH
END;
