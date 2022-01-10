
-- =============================================
-- Author:		<Author,,ADMIN>
-- Create date: <Create Date,, 02 Jun 2015>
-- Description:	<Description,,GetThemeAll>
-- Call SP    :	GetThemeAll
-- =============================================
CREATE PROCEDURE [dbo].[GetThemeAll]
	@UserID INT
AS 
    BEGIN

		DECLARE @AdminRole bigint ,
		@UserRole bigint ,
		@PageID bigint

		SELECT TOP 1 @AdminRole = Id FROM [dbo].[Role] WHERE RoleName = 'Admin'
		SELECT TOP 1 @UserRole = RoleId FROM dbo.[User] WHERE Id = @UserId
		SELECT TOP 1 @PageID = Id FROM dbo.Page WHERE PageName = 'Theme'

		IF @AdminRole = @UserRole
		BEGIN

			SELECT  dbo.[Theme].[Id] AS Id ,
					dbo.[Theme].[ThemeName] AS ThemeName ,
					dbo.[Theme].[Description] AS Description ,
					dbo.[Theme].[ThemeMDPI] AS ThemeMDPI ,
					dbo.[Theme].[ThemeHDPI] AS ThemeHDPI ,
					dbo.[Theme].[ThemeXHDPI] AS ThemeXHDPI ,
					dbo.[Theme].[ThemeXXHDPI] AS ThemeXXHDPI ,
					dbo.[Theme].[Theme640x960] AS Theme640x960 ,
					dbo.[Theme].[Theme640x1136] AS Theme640x1136 ,
					dbo.[Theme].[Theme768x1280] AS Theme768x1280
			FROM    dbo.[Theme]
			WHERE   dbo.[Theme].IsDeleted = 0

		END
		ELSE
		BEGIN

			SELECT  dbo.[Theme].[Id] AS Id ,
					dbo.[Theme].[ThemeName] AS ThemeName ,
					dbo.[Theme].[Description] AS Description ,
					dbo.[Theme].[ThemeMDPI] AS ThemeMDPI ,
					dbo.[Theme].[ThemeHDPI] AS ThemeHDPI ,
					dbo.[Theme].[ThemeXHDPI] AS ThemeXHDPI ,
					dbo.[Theme].[ThemeXXHDPI] AS ThemeXXHDPI ,
					dbo.[Theme].[Theme640x960] AS Theme640x960 ,
					dbo.[Theme].[Theme640x1136] AS Theme640x1136 ,
					dbo.[Theme].[Theme768x1280] AS Theme768x1280
			FROM    dbo.[Theme]
			INNER JOIN dbo.UserRolePermissions ON dbo.UserRolePermissions.PageID = @PageID
				AND dbo.UserRolePermissions.ActualID = dbo.Theme.Id
				AND dbo.UserRolePermissions.UserID = @UserID
			WHERE   dbo.[Theme].IsDeleted = 0

		END
    END