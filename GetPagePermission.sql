


-- =============================================
-- Author:  <Author,,GD>
-- Create date: <Create Date,,24 Apr 2014>
-- Description: <Description,,Get Rights Details by Page and Role>
-- Call SP    : GetPagePermission 1, 1, 1
-- =============================================
CREATE PROCEDURE [dbo].[GetPagePermission]
    @PageId BIGINT ,
    @UserId BIGINT ,
    @RoleId BIGINT
AS 
    BEGIN
        DECLARE @IsActive BIT  
        SET @IsActive = 0
        IF @UserId > 0 
            BEGIN  
                SELECT  @RoleId = RoleId ,
                        @IsActive = IsActive
                FROM    dbo.[User]
                WHERE   Id = @UserId
            END
        SELECT  ISNULL(RP.Id, 0) AS Id ,
                PM.Id AS PageId ,
                ISNULL(RoleId, 0) AS RoleId ,
                ModuleName ,
                PageName ,
                DispalyName ,
                ISNULL(View_Right, 0) AS View_Right ,
                ISNULL(Add_Right, 0) AS Add_Right ,
                ISNULL(Edit_Right, 0) AS Edit_Right ,
                ISNULL(Delete_Right, 0) AS Delete_Right ,
                ISNULL(Export_Right, 0) AS Export_Right ,
                ISNULL(@IsActive, 0) AS IsActive
        FROM    dbo.Page AS PM
                LEFT OUTER JOIN dbo.Module AS MM ON PM.ModuleId = MM.ID
                LEFT OUTER JOIN dbo.RolePermissions AS RP ON RP.PageId = PM.Id
                                                             AND RoleId = @RoleId
                                                             AND ( PageId = @PageId
                                                              OR @PageId = 0
                                                              )
        WHERE   ( PM.Id = @PageId
                  OR @PageId = 0
                )
                AND PM.IsDeleted = 0
        ORDER BY MM.Sequence ,
                PM.Sequence
 
    END