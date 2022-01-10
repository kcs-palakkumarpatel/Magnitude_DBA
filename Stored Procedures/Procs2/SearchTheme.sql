
-- =============================================
-- Author:		<Author,,ADMIN>
-- Create date: <Create Date,, 02 Jun 2015>
-- Description:	<Description,,GetThemeAll>
-- Call SP    :	SearchTheme 1, 1, '', ''
-- =============================================
CREATE PROCEDURE [dbo].[SearchTheme]
    @Rows INT ,
    @Page INT ,
    @Search NVARCHAR(500) ,
    @Sort NVARCHAR(50) ,
	@UserID INT
AS
    BEGIN
        DECLARE @Start AS INT ,
            @End INT,
			@AdminRole bigint ,
			@UserRole bigint ,
			@PageID bigint

        SET @Start = ( ( @Page * @Rows ) - @Rows ) + 1;
        SET @End = @Start + @Rows - 1;

		SELECT TOP 1 @AdminRole = Id FROM [dbo].[Role] WHERE RoleName = 'Admin'
		SELECT TOP 1 @UserRole = RoleId FROM dbo.[User] WHERE Id = @UserID
		SELECT TOP 1 @PageID = Id FROM dbo.Page WHERE PageName = 'Theme'

        DECLARE @Sql NVARCHAR(MAX);

		IF @AdminRole = @UserRole
		BEGIN

			SELECT  RowNum ,
					ISNULL(Total, 0) Total ,
					Id ,
					ThemeName ,
					Description ,
					ThemeMDPI ,
					ThemeHDPI ,
					ThemeXHDPI ,
					ThemeXXHDPI ,
					Theme640x960 ,
					Theme640x1136 ,
					Theme768x1280
			FROM    ( SELECT    dbo.[Theme].[Id] AS Id ,
								dbo.[Theme].[ThemeName] AS ThemeName ,
								dbo.[Theme].[Description] AS Description ,
								dbo.[Theme].[ThemeMDPI] AS ThemeMDPI ,
								dbo.[Theme].[ThemeHDPI] AS ThemeHDPI ,
								dbo.[Theme].[ThemeXHDPI] AS ThemeXHDPI ,
								dbo.[Theme].[ThemeXXHDPI] AS ThemeXXHDPI ,
								dbo.[Theme].[Theme640x960] AS Theme640x960 ,
								dbo.[Theme].[Theme640x1136] AS Theme640x1136 ,
								dbo.[Theme].[Theme768x1280] AS Theme768x1280 ,
								COUNT(*) OVER ( PARTITION BY 1 ) AS Total ,
								ROW_NUMBER() OVER ( ORDER BY CASE WHEN @Sort = 'Id Asc'
																  THEN dbo.[Theme].[Id]
															 END ASC, CASE
																  WHEN @Sort = 'Id DESC'
																  THEN dbo.[Theme].[Id]
																  END DESC, CASE
																  WHEN @Sort = 'ThemeName Asc'
																  THEN dbo.[Theme].[ThemeName]
																  END ASC, CASE
																  WHEN @Sort = 'ThemeName DESC'
																  THEN dbo.[Theme].[ThemeName]
																  END DESC, CASE
																  WHEN @Sort = 'CreatedOn Asc'
																  THEN dbo.[Theme].CreatedOn
																  END ASC, CASE
																  WHEN @Sort = 'CreatedOn DESC'
																  THEN dbo.[Theme].CreatedOn
																  END DESC ) AS RowNum
					  FROM      dbo.[Theme]
					  WHERE     dbo.[Theme].IsDeleted = 0
								AND ( ISNULL(dbo.[Theme].[ThemeName], '') LIKE '%'
									  + @Search + '%'
									  OR ISNULL(dbo.[Theme].[Description], '') LIKE '%'
									  + @Search + '%'
									)
					) AS T
			WHERE   RowNum BETWEEN @Start AND @End;
		END
		ELSE
		BEGIN 
		
				SELECT  RowNum ,
					ISNULL(Total, 0) Total ,
					Id ,
					ThemeName ,
					Description ,
					ThemeMDPI ,
					ThemeHDPI ,
					ThemeXHDPI ,
					ThemeXXHDPI ,
					Theme640x960 ,
					Theme640x1136 ,
					Theme768x1280
			FROM    ( SELECT    dbo.[Theme].[Id] AS Id ,
								dbo.[Theme].[ThemeName] AS ThemeName ,
								dbo.[Theme].[Description] AS Description ,
								dbo.[Theme].[ThemeMDPI] AS ThemeMDPI ,
								dbo.[Theme].[ThemeHDPI] AS ThemeHDPI ,
								dbo.[Theme].[ThemeXHDPI] AS ThemeXHDPI ,
								dbo.[Theme].[ThemeXXHDPI] AS ThemeXXHDPI ,
								dbo.[Theme].[Theme640x960] AS Theme640x960 ,
								dbo.[Theme].[Theme640x1136] AS Theme640x1136 ,
								dbo.[Theme].[Theme768x1280] AS Theme768x1280 ,
								COUNT(*) OVER ( PARTITION BY 1 ) AS Total ,
								ROW_NUMBER() OVER ( ORDER BY CASE WHEN @Sort = 'Id Asc'
																  THEN dbo.[Theme].[Id]
															 END ASC, CASE
																  WHEN @Sort = 'Id DESC'
																  THEN dbo.[Theme].[Id]
																  END DESC, CASE
																  WHEN @Sort = 'ThemeName Asc'
																  THEN dbo.[Theme].[ThemeName]
																  END ASC, CASE
																  WHEN @Sort = 'ThemeName DESC'
																  THEN dbo.[Theme].[ThemeName]
																  END DESC, CASE
																  WHEN @Sort = 'CreatedOn Asc'
																  THEN dbo.[Theme].CreatedOn
																  END ASC, CASE
																  WHEN @Sort = 'CreatedOn DESC'
																  THEN dbo.[Theme].CreatedOn
																  END DESC ) AS RowNum
					  FROM      dbo.[Theme]
					  INNER JOIN dbo.UserRolePermissions ON dbo.UserRolePermissions.PageID = @PageID
						  AND dbo.UserRolePermissions.ActualID = dbo.Theme.Id
						  AND dbo.UserRolePermissions.UserID = @UserID
					  WHERE     dbo.[Theme].IsDeleted = 0
								AND ( ISNULL(dbo.[Theme].[ThemeName], '') LIKE '%'
									  + @Search + '%'
									  OR ISNULL(dbo.[Theme].[Description], '') LIKE '%'
									  + @Search + '%'
									)
					) AS T
			WHERE   RowNum BETWEEN @Start AND @End;

		END
    END;