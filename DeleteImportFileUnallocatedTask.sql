-- =============================================
-- Author:      Krishna Panchal
-- Create Date: 07-May-2021
-- Description: Delete unallocated task by import file
-- SP call : DeleteImportFileunallocatedTask 1246
-- =============================================
CREATE PROCEDURE dbo.DeleteImportFileUnallocatedTask
    @Ids VARCHAR(MAX),
    @AppUserId BIGINT,
    @IsDeleteFromFile BIT = 0
AS
BEGIN
    BEGIN TRY
        SET NOCOUNT ON;
        IF (@IsDeleteFromFile = 1)
        BEGIN
            UPDATE dbo.UnAllocatedTaskImportFileLog
            SET IsDeleted = 1,
                DeletedOn = GETUTCDATE(),
                DeletedBy = @AppUserId
            WHERE Id IN (
                            SELECT Data FROM dbo.Split(@Ids, ',')
                        );

            UPDATE dbo.SeenClientAnswerMaster
            SET IsDeleted = 1,
                DeletedBy = @AppUserId,
                DeletedOn = GETUTCDATE()
            WHERE ImportFileId IN (
                                      SELECT Data FROM dbo.Split(@Ids, ',')
                                  )
                  AND ISNULL(IsDeleted, 0) = 0;

            UPDATE dbo.RecurringSetting
            SET DeletedOn = GETUTCDATE(),
                IsDeleted = 1
            WHERE SeenClientAnswerMasterId IN (
                                                  SELECT Id
                                                  FROM dbo.SeenClientAnswerMaster
                                                  WHERE ImportFileId IN (
                                                                            SELECT Data FROM dbo.Split(@Ids, ',')
                                                                        )
                                              );

            UPDATE dbo.SeenClientAnswers
            SET IsDeleted = 1,
                DeletedBy = @AppUserId,
                DeletedOn = GETUTCDATE()
            WHERE SeenClientAnswerMasterId IN (
                                                  SELECT Id
                                                  FROM dbo.SeenClientAnswerMaster
                                                  WHERE ImportFileId IN (
                                                                            SELECT Data FROM dbo.Split(@Ids, ',')
                                                                        )
                                                        AND ISNULL(IsDeleted, 0) = 0
                                              );
        END;
        ELSE
        BEGIN
            UPDATE dbo.SeenClientAnswerMaster
            SET IsDeleted = 1,
                DeletedBy = @AppUserId,
                DeletedOn = GETUTCDATE()
            WHERE Id IN (
                            SELECT Data FROM dbo.Split(@Ids, ',')
                        )
                  AND ISNULL(IsDeleted, 0) = 0;

            UPDATE dbo.SeenClientAnswers
            SET IsDeleted = 1,
                DeletedBy = @AppUserId,
                DeletedOn = GETUTCDATE()
            WHERE SeenClientAnswerMasterId IN (
                                                  SELECT Data FROM dbo.Split(@Ids, ',')
                                              );

            UPDATE dbo.RecurringSetting
            SET DeletedOn = GETUTCDATE(),
                IsDeleted = 1
            WHERE SeenClientAnswerMasterId IN (
                                                  SELECT Data FROM dbo.Split(@Ids, ',')
                                              );

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
         'dbo.DeleteImportFileunallocatedTask',
         N'Database',
         ERROR_MESSAGE(),
         ('ERROR_NUMBER=' + CONVERT(VARCHAR(100), ERROR_NUMBER()) + ',ERROR_STATE='
          + CONVERT(VARCHAR(20), ERROR_STATE()) + ',ERROR_SEVERITY=' + CONVERT(VARCHAR(20), ERROR_SEVERITY())
         )  ,
         GETUTCDATE(),
         @AppUserId,
         N'',
         GETUTCDATE(),
         @AppUserId
        );
    END CATCH;
END;
