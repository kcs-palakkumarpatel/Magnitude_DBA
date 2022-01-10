
-- =============================================
-- Author:      <Author, , Anant>
-- Create Date: <Create Date, 21-Sep-2020, >
-- Description: <Description, johndeer Api call, >
-- Sp call:InsertMapingWorkFlowData 680946,32109
-- =============================================
CREATE PROCEDURE [dbo].[InsertMapingWorkFlowData]
(
    @AnswerMasterId BIGINT,
    @EstablishmentId BIGINT
)
AS
BEGIN
	SET DEADLOCK_PRIORITY NORMAL;
	
	BEGIN TRY
    IF EXISTS
    (
        SELECT 1
        FROM dbo.MapingWorkFlowMaster
        WHERE FromEstablishnmentId = @EstablishmentId
    )
    BEGIN

        --johnDeer API call dyanamic setup
        DECLARE @DataCount INT;
        DECLARE @WorkflowMasterID BIGINT;
        DECLARE @ToEstablishnmentId BIGINT;
        SELECT @DataCount = COUNT(1),
               @WorkflowMasterID = Id,
               @ToEstablishnmentId = ToEstablishnmentId
        FROM dbo.MapingWorkFlowMaster
        WHERE FromEstablishnmentId = @EstablishmentId
        GROUP BY Id,
                 ToEstablishnmentId;
        SELECT @DataCount;
        SELECT @WorkflowMasterID;
        SELECT @ToEstablishnmentId;
        IF (@DataCount > 0)
        BEGIN
            IF (@ToEstablishnmentId = 0)
            BEGIN
                PRINT @ToEstablishnmentId;
                SELECT @ToEstablishnmentId = JE.EstablishmentID
                FROM dbo.AnswerMaster AS an
                    INNER JOIN dbo.Answers AS a
                        ON a.AnswerMasterId = an.Id
                    INNER JOIN dbo.JohnDeerEstablishmentSelection AS JE
                        ON JE.OptionId = a.OptionId
                WHERE an.EstablishmentId = @EstablishmentId
                      AND an.Id = @AnswerMasterId;
                PRINT @ToEstablishnmentId;
            END;
            SELECT @ToEstablishnmentId;
            IF NOT EXISTS
            (
                SELECT Id
                FROM MapingWorkFlowData
                WHERE fromReferenceNumber = @AnswerMasterId
            )
            BEGIN
                INSERT INTO dbo.MapingWorkFlowData
                (
                    WorkflowMasterID,
                    fromReferenceNumber,
                    ToEstablishnmentId,
                    isActioned,
                    ActionedOn,
                    CreatedOn,
                    UpdatedBy,
                    DeletedOn,
                    DeletedBy,
                    IsDeleted
                )
                VALUES
                (   @WorkflowMasterID,   -- WorkflowMasterID - bigint
                    @AnswerMasterId,     -- fromReferenceNumber - bigint
                    @ToEstablishnmentId, -- ToEstablishnmentId - bigint
                    0,                   -- isActioned - bit
                    GETDATE(),           -- ActionedOn - datetime
                    GETDATE(),           -- CreatedOn - datetime
                    0,                   -- UpdatedBy - bigint
                    NULL,                -- DeletedOn - datetime
                    0,                   -- DeletedBy - bigint
                    0                    -- IsDeleted - bit
                );
            END;
        END;
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
         'dbo.InsertMapingWorkFlowData',
         N'DATABASE',
         ERROR_MESSAGE(),
         ('ERROR_NUMBER=' + CONVERT(VARCHAR(100), ERROR_NUMBER()) + ',ERROR_STATE='
          + CONVERT(VARCHAR(20), ERROR_STATE()) + ',ERROR_SEVERITY=' + CONVERT(VARCHAR(20), ERROR_SEVERITY())
         )  ,
         GETUTCDATE(),
         N'',
         @AnswerMasterId+','+@EstablishmentId,
         GETUTCDATE(),
         N''
        );
END CATCH
END;
