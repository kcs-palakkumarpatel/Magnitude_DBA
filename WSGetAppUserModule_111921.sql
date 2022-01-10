
-- =============================================
-- Author:			D#3
-- Create date:	06-Mar-2018
-- Description:	<Description,,>
-- Call SP:			dbo.WSGetAppUserModule 1337
-- =============================================
CREATE PROCEDURE [dbo].[WSGetAppUserModule_111921] ( @AppUserId BIGINT )
AS
    BEGIN
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
    END;
