

-- =============================================
-- Author:		<Author,,ADMIN>
-- Create date: <Create Date,, 18 Oct 2014>
-- Description:	<Description,,GetRoleAll>
-- Call SP    :	GetRoleAll
-- =============================================
CREATE PROCEDURE [dbo].[GetRoleAll]
	@UserID INT
AS 
    BEGIN

		DECLARE @AdminRole bigint ,
		@UserRole bigint ,
		@PageID bigint

		SELECT TOP 1 @AdminRole = Id FROM [dbo].[Role] WHERE RoleName = 'Admin'
		SELECT TOP 1 @UserRole = RoleId FROM dbo.[User] WHERE Id = @UserId
		SELECT TOP 1 @PageID = Id FROM dbo.Page WHERE PageName = 'Role'
		
		IF @AdminRole = @UserRole
		BEGIN
			SELECT  dbo.[Role].[Id] AS Id ,
					dbo.[Role].[RoleName] AS RoleName ,
					dbo.[Role].[Description] AS Description
			FROM    dbo.[Role]
			WHERE   dbo.[Role].IsDeleted = 0
		END
		ELSE
		BEGIN
			SELECT  dbo.[Role].[Id] AS Id ,
					dbo.[Role].[RoleName] AS RoleName ,
					dbo.[Role].[Description] AS Description
			FROM    dbo.[Role]
			WHERE   dbo.[Role].IsDeleted = 0
			AND RoleName <> 'Admin'
		END
    END