-- =============================================
-- Author:			Mitesh Kachhadiya
-- Create date:		29-DEC-2021
-- Description:		Description,,SaveAppUserModuleRights>
-- Call SP    :		[SaveAppUserModuleRights] '182692,182693,182690', '154873,154874,154875', 2
-- =============================================

CREATE PROCEDURE dbo.SaveAppUserModuleRights
    @SelectedModuleIds NVARCHAR(MAX),
    @NotSelectedModuleIds NVARCHAR(MAX),
    @UserId BIGINT
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY

        UPDATE dbo.AppUserModule
        SET IsSelected = 1,
            UpdatedBy = @UserId,
            UpdatedOn = GETUTCDATE()
        WHERE Id IN (
                        SELECT Data FROM dbo.Split(@SelectedModuleIds, ',')
                    );

        UPDATE dbo.AppUserModule
        SET IsSelected = 0,
            UpdatedBy = @UserId,
            UpdatedOn = GETUTCDATE()
        WHERE Id IN (
                        SELECT Data FROM dbo.Split(@NotSelectedModuleIds, ',')
                    );

        PRINT ('Success');
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
         'dbo.SaveAppUserModuleRights',
         N'Database',
         ERROR_MESSAGE(),
         ('ERROR_NUMBER=' + CONVERT(VARCHAR(100), ERROR_NUMBER()) + ',ERROR_STATE='
          + CONVERT(VARCHAR(20), ERROR_STATE()) + ',ERROR_SEVERITY=' + CONVERT(VARCHAR(20), ERROR_SEVERITY())
         )  ,
         GETUTCDATE(),
         0  ,
         N'' + @UserId,
         GETUTCDATE(),
         0
        );
    END CATCH;
    SET NOCOUNT OFF;
END;

-- SELECT TOP 20    * FROM dbo.ErrorLog ORDER BY 1 DESC;
