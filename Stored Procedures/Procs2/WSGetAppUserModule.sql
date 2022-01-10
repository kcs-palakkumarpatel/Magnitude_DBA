
-- =============================================
-- Author:			D#3
-- Create date:	06-Mar-2018
-- Description:	<Description,,>
-- Call SP:			dbo.WSGetAppUserModule 1337
-- =============================================
CREATE PROCEDURE [dbo].[WSGetAppUserModule] ( @AppUserId BIGINT )
AS
    BEGIN
	SET DEADLOCK_PRIORITY NORMAL;
	
	BEGIN TRY
        SELECT  AppModuleId AS ModuleId ,
                M.ModuleName ,
                UM.AliasName AS ModuleDisplayName ,
                UM.EstablishmentGroupId AS ActivityId ,
                dbo.ChangeDateFormat(UM.CreatedOn, 'yyyy-MM-dd hh:mm:ss AM/PM') AS CreatedOn ,
                dbo.ChangeDateFormat(UM.UpdatedOn, 'yyyy-MM-dd hh:mm:ss AM/PM') AS UpdatedOn ,
                CAST(IIF(UM.IsSelected = 1, 0, 1) AS BIT) AS IsDeleted
        FROM    dbo.AppUserModule AS UM
                INNER JOIN dbo.AppModule AS M ON UM.AppModuleId = M.Id
        WHERE   AppUserId = @AppUserId
                AND UM.IsDeleted = 0
                AND M.IsDeleted = 0;
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
         'dbo.WSGetAppUserModule',
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
