
-- =============================================
-- Author:		<Author,,ADMIN>
-- Create date: <Create Date,, 25 May 2015>
-- Description:	<Description,,GetUserById>
-- Call SP    :	GetUserById
-- =============================================
CREATE PROCEDURE [dbo].[GetUserById]
@Id BIGINT
AS
BEGIN
SELECT  [Id] AS Id, [Name] AS Name, [SurName] AS SurName, [MobileNo] AS MobileNo, [EmailId] AS EmailId, [UserName] AS UserName, [Password] AS Password, [Address] AS Address, [RoleId] AS RoleId, [IsActive] AS IsActive, [IsLogin] AS IsLogin FROM dbo.[User] WHERE [Id] = @Id
END