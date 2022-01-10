
-- =============================================
-- Author:		<Author,,ADMIN>
-- Create date: <Create Date,, 25 May 2015>
-- Description:	<Description,,GetUserAll>
-- Call SP    :	GetUserAll
-- =============================================
CREATE PROCEDURE [dbo].[GetUserAll]
AS
BEGIN
SELECT  dbo.[User].[Id] AS Id , dbo.[User].[Name] AS Name , dbo.[User].[SurName] AS SurName , dbo.[User].[MobileNo] AS MobileNo , dbo.[User].[EmailId] AS EmailId , dbo.[User].[UserName] AS UserName , dbo.[User].[Password] AS Password , dbo.[User].[Address] AS Address , dbo.[User].[RoleId] AS RoleId , dbo.[Role].RoleName, dbo.[User].[IsActive] AS IsActive , dbo.[User].[IsLogin] AS IsLogin  FROM dbo.[User] 
INNER JOIN dbo.[Role] ON dbo.[Role].Id = dbo.[User].RoleId  WHERE dbo.[User].IsDeleted = 0
END