
-- =============================================
-- Author:		<Author,,GD>
-- Create date: <Create Date,, 15 Jun 2015>
-- Description:	<Description,,GetContactAll>
-- Call SP    :	GetContactAll 1
-- =============================================
CREATE PROCEDURE [dbo].[GetContactAll]
	@UserID INT
AS 

    BEGIN

		DECLARE @AdminRole bigint ,
			@UserRole bigint ,
			@PageID bigint

		SELECT TOP 1 @AdminRole = Id FROM [dbo].[Role] WHERE RoleName = 'Admin'
		SELECT TOP 1 @UserRole = RoleId FROM dbo.[User] WHERE Id = @UserId
		SELECT TOP 1 @PageID = Id FROM dbo.Page WHERE PageName = 'Contact'

		
		IF @AdminRole = @UserRole
		BEGIN
			SELECT  dbo.[Contact].[Id] AS Id ,
					dbo.[Contact].[ContactTitle] AS ContactTitle ,
					dbo.[Contact].[Description] AS Description
			FROM    dbo.[Contact]
			WHERE   dbo.[Contact].IsDeleted = 0 ORDER BY ContactTitle
		END
		ELSE
		BEGIN

			SELECT  dbo.[Contact].[Id] AS Id ,
					dbo.[Contact].[ContactTitle] AS ContactTitle ,
					dbo.[Contact].[Description] AS Description
			FROM    dbo.[Contact]
			INNER JOIN dbo.UserRolePermissions ON dbo.UserRolePermissions.PageID = @PageID
				AND dbo.UserRolePermissions.ActualID = dbo.Contact.Id
				AND dbo.UserRolePermissions.UserID = @UserID
			WHERE   dbo.[Contact].IsDeleted = 0 ORDER BY ContactTitle

		END
	END