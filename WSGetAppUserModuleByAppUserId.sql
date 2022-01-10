
-- =============================================
-- Author:		<Author,,GD>
-- Create date: <Create Date,,10 Jun 2015>
-- Description:	<Description,,>
-- Call SP:		WSGetAppUserModuleByAppUserId 1
-- =============================================
CREATE PROCEDURE [dbo].[WSGetAppUserModuleByAppUserId] @AppUserId BIGINT
AS
    BEGIN
	SET DEADLOCK_PRIORITY NORMAL;
	
	BEGIN TRY
        SELECT  AppModuleId AS ModuleId ,
                M.ModuleName ,
                UM.AliasName AS ModuleDisplayName ,
                UM.EstablishmentGroupId AS ActivityId ,
                dbo.ChangeDateFormat(UM.CreatedOn, 'yyyy-MM-dd hh:mm:ss AM/PM') AS CreatedOn ,
                dbo.ChangeDateFormat(UM.UpdatedOn, 'yyyy-MM-dd hh:mm:ss AM/PM') AS UpdatedOn
        FROM    dbo.AppUserModule AS UM
                INNER JOIN dbo.AppModule AS M ON UM.AppModuleId = M.Id
        WHERE   AppUserId = @AppUserId
                AND IsSelected = 1
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
         'dbo.WSGetAppUserModuleByAppUserId',
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
