-- =============================================
-- Author:      Krishna Panchal
-- Create Date: 08-Aug-2021
-- Description: Insert UnAllocatedTaskImportFileLog  
-- SP call:InsertUnAllocatedTaskImportFileLog 702930,32135,1
-- =============================================
CREATE PROCEDURE dbo.InsertUnAllocatedTaskImportFileLog
(
    @ActivityID BIGINT,
    @EstablishmentID BIGINT,
    @AppUserID BIGINT,
    @ImportFileName VARCHAR(1000)
)
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        INSERT INTO dbo.UnAllocatedTaskImportFileLog
        (
            FileName,
            EstablishmentGroupId,
            EstablishmentId,
            CreatedBy,
            CreatedOn
        )
        VALUES
        (   @ImportFileName,  -- FileName - varchar(200)
            @ActivityID,      -- EstablishmentGroupId - bigint
            @EstablishmentID, -- EstablishmentId - bigint
            @AppUserID,       -- CreatedBy - bigint
            GETUTCDATE()      -- CreatedOn - datetime
        );
        SELECT SCOPE_IDENTITY();
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
         'dbo.InsertUnAllocatedTaskImportFileLog',
         N'Database',
         ERROR_MESSAGE(),
         ('ERROR_NUMBER=' + CONVERT(VARCHAR(100), ERROR_NUMBER()) + ',ERROR_STATE='
          + CONVERT(VARCHAR(20), ERROR_STATE()) + ',ERROR_SEVERITY=' + CONVERT(VARCHAR(20), ERROR_SEVERITY())
         )  ,
         GETUTCDATE(),
         @AppUserID,
         N'',
         GETUTCDATE(),
         @AppUserID
        );
    END CATCH;

    SET NOCOUNT OFF;
END;
