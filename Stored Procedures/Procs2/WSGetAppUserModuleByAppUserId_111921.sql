
-- =============================================
-- Author:		<Author,,GD>
-- Create date: <Create Date,,10 Jun 2015>
-- Description:	<Description,,>
-- Call SP:		WSGetAppUserModuleByAppUserId 1
-- =============================================
CREATE PROCEDURE [dbo].[WSGetAppUserModuleByAppUserId_111921] @AppUserId BIGINT
AS
    BEGIN
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
    END;
