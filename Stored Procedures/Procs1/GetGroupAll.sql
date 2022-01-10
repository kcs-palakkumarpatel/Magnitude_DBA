
-- =============================================
-- Author:		<Author,,GD>
-- Create date: <Create Date,, 08 Jun 2015>
-- Description:	<Description,,GetGroupAll>
-- Call SP    :	GetGroupAll
-- =============================================
CREATE PROCEDURE [dbo].[GetGroupAll]
	@UserID INT
AS 
    BEGIN

		DECLARE @AdminRole bigint ,
		@UserRole bigint ,
		@PageID bigint

		SELECT TOP 1 @AdminRole = Id FROM [dbo].[Role] WHERE RoleName = 'Admin'
		SELECT TOP 1 @UserRole = RoleId FROM dbo.[User] WHERE Id = @UserId
		SELECT TOP 1 @PageID = Id FROM dbo.Page WHERE PageName = 'Group'

		
		IF @AdminRole = @UserRole
		BEGIN

			SELECT  dbo.[Group].[Id] AS Id ,
					dbo.[Group].[IndustryId] AS IndustryId ,
					dbo.[Industry].IndustryName ,
					dbo.[Group].[GroupName] AS GroupName ,
					dbo.[Group].[AboutGroup] AS AboutGroup ,
					dbo.[Group].[ThemeId] AS ThemeId ,
					dbo.[Theme].ThemeName
			FROM    dbo.[Group]
					INNER JOIN dbo.[Industry] ON dbo.[Industry].Id = dbo.[Group].IndustryId
					INNER JOIN dbo.[Theme] ON dbo.[Theme].Id = dbo.[Group].ThemeId
			WHERE   dbo.[Group].IsDeleted = 0 ORDER BY GroupName ASC
		END
		ELSE
		BEGIN

			SELECT  dbo.[Group].[Id] AS Id ,
					dbo.[Group].[IndustryId] AS IndustryId ,
					dbo.[Industry].IndustryName ,
					dbo.[Group].[GroupName] AS GroupName ,
					dbo.[Group].[AboutGroup] AS AboutGroup ,
					dbo.[Group].[ThemeId] AS ThemeId ,
					dbo.[Theme].ThemeName
			FROM    dbo.[Group]
					INNER JOIN dbo.[Industry] ON dbo.[Industry].Id = dbo.[Group].IndustryId
					INNER JOIN dbo.[Theme] ON dbo.[Theme].Id = dbo.[Group].ThemeId
					INNER JOIN dbo.UserRolePermissions ON dbo.UserRolePermissions.PageID = @PageID
						AND dbo.UserRolePermissions.ActualID = dbo.[Group].Id
						AND dbo.UserRolePermissions.UserID = @UserID
			WHERE   dbo.[Group].IsDeleted = 0 ORDER BY GroupName ASC

		END
    END;