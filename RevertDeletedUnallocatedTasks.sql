-- =============================================
-- Author:      Krishna Panchal
-- Create Date: 12-May-2021
-- Description: Revert Deleted unallocated task 
-- SP call : RevertDeletedUnallocatedTasks 1246
-- =============================================
CREATE PROCEDURE dbo.RevertDeletedUnallocatedTasks @Ids NVARCHAR(MAX)
AS
BEGIN
    BEGIN TRY
        SET NOCOUNT ON;

        UPDATE dbo.SeenClientAnswerMaster
        SET IsDeleted = 0,
            DeletedOn = NULL,
            DeletedBy = NULL
        WHERE Id IN (
                        SELECT Data FROM dbo.Split(@Ids, ',')
                    );

        UPDATE dbo.SeenClientAnswers
        SET IsDeleted = 0,
            DeletedOn = NULL,
            DeletedBy = NULL
        WHERE SeenClientAnswerMasterId IN (
                                              SELECT Data FROM dbo.Split(@Ids, ',')
                                          );
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
         'dbo.RevertDeletedUnallocatedTasks',
         N'Database',
         ERROR_MESSAGE(),
         ('ERROR_NUMBER=' + CONVERT(VARCHAR(100), ERROR_NUMBER()) + ',ERROR_STATE='
          + CONVERT(VARCHAR(20), ERROR_STATE()) + ',ERROR_SEVERITY=' + CONVERT(VARCHAR(20), ERROR_SEVERITY())
         )  ,
         GETUTCDATE(),
         0  ,
         N'',
         GETUTCDATE(),
         0
        );
    END CATCH;
END;
