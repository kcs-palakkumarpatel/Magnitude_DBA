

-- =============================================
-- Author:		<Author,,ADMIN>
-- Create date: <Create Date,, 18 Oct 2014>
-- Description:	<Description,,GetRolePermissionsAll>
-- Call SP    :	GetRolePermissionsAll
-- =============================================
CREATE PROCEDURE [dbo].[GetRolePermissionsAll]
AS 
    BEGIN
        SELECT  dbo.[RolePermissions].[Id] AS Id ,
                dbo.[RolePermissions].[RoleId] AS RoleId ,
                dbo.[Role].RoleName ,
                dbo.[RolePermissions].[PageId] AS PageId ,
                dbo.[Page].PageName ,
                dbo.[RolePermissions].[View_Right] AS View_Right ,
                dbo.[RolePermissions].[Add_Right] AS Add_Right ,
                dbo.[RolePermissions].[Edit_Right] AS Edit_Right ,
                dbo.[RolePermissions].[Delete_Right] AS Delete_Right ,
                dbo.[RolePermissions].[Export_Right] AS Export_Right
        FROM    dbo.[RolePermissions]
                INNER JOIN dbo.[Page] ON dbo.[Page].Id = dbo.[RolePermissions].PageId
                INNER JOIN dbo.[Role] ON dbo.[Role].Id = dbo.[RolePermissions].RoleId
        WHERE   dbo.[RolePermissions].IsDeleted = 0
    END