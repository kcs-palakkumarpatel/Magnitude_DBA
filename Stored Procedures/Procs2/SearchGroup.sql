-- =============================================
-- Author:		<Author,,GD>
-- Create date: <Create Date,, 08 Jun 2015>
-- Description:	<Description,,GetGroupAll>
-- Call SP    :	SearchGroup 100, 1, '', ''
-- =============================================
CREATE PROCEDURE [dbo].[SearchGroup]
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
			@PageID bigint;

        SET @Start = ( ( @Page * @Rows ) - @Rows ) + 1;
        SET @End = @Start + @Rows - 1;

		SELECT TOP 1 @AdminRole = Id FROM [dbo].[Role] WHERE RoleName = 'Admin'
		SELECT TOP 1 @UserRole = RoleId FROM dbo.[User] WHERE Id = @UserId
		SELECT TOP 1 @PageID = Id FROM dbo.Page WHERE PageName = 'Group'

		
		IF @AdminRole = @UserRole
		BEGIN

			SELECT  RowNum ,
					ISNULL(Total, 0) AS Total ,
					Id ,
					IndustryId ,
					IndustryName ,
					GroupName ,
					AboutGroup ,
					ThemeId ,
					ThemeName ,
					ContactTitle
			FROM    ( SELECT    dbo.[Group].[Id] AS Id ,
								dbo.[Group].[IndustryId] AS IndustryId ,
								dbo.[Industry].IndustryName ,
								dbo.[Group].[GroupName] AS GroupName ,
								dbo.[Group].[AboutGroup] AS AboutGroup ,
								dbo.[Group].[ThemeId] AS ThemeId ,
								dbo.[Theme].ThemeName ,
								dbo.Contact.ContactTitle ,
								COUNT(*) OVER ( PARTITION BY 1 ) AS Total ,
								ROW_NUMBER() OVER ( ORDER BY CASE WHEN @Sort = 'Id Asc'
																  THEN dbo.[Group].[Id]
															 END ASC, CASE
																  WHEN @Sort = 'Id DESC'
																  THEN dbo.[Group].[Id]
																  END DESC, CASE
																  WHEN @Sort = 'IndustryName Asc'
																  THEN dbo.[Group].[IndustryId]
																  END ASC, CASE
																  WHEN @Sort = 'IndustryName DESC'
																  THEN dbo.[Group].[IndustryId]
																  END DESC, CASE
																  WHEN @Sort = 'GroupName Asc'
																  THEN dbo.[Group].[GroupName]
																  END ASC, CASE
																  WHEN @Sort = 'GroupName DESC'
																  THEN dbo.[Group].[GroupName]
																  END DESC, CASE
																  WHEN @Sort = 'CreatedOn Asc'
																  THEN dbo.[Group].CreatedOn
																  END ASC, CASE
																  WHEN @Sort = 'CreatedOn DESC'
																  THEN dbo.[Group].CreatedOn
																  END DESC, CASE
																  WHEN @Sort = 'ThemeName Asc'
																  THEN ThemeName
																  END ASC, CASE
																  WHEN @Sort = 'ThemeName DESC'
																  THEN ThemeName
																  END DESC, CASE
																  WHEN @Sort = 'ContactTitle Asc'
																  THEN ContactTitle
																  END ASC, CASE
																  WHEN @Sort = 'ContactTitle DESC'
																  THEN ContactTitle
																  END DESC ) AS RowNum
					  FROM      dbo.[Group]
								INNER JOIN dbo.[Industry] ON dbo.[Industry].Id = dbo.[Group].IndustryId
								INNER JOIN dbo.[Theme] ON dbo.[Theme].Id = dbo.[Group].ThemeId
								INNER JOIN dbo.Contact ON Contact.Id = [Group].ContactId
					  WHERE     dbo.[Group].IsDeleted = 0
								AND ( dbo.[Industry].IndustryName LIKE '%'
									  + @Search + '%'
									  OR ISNULL(dbo.[Group].[GroupName], '') LIKE '%'
									  + @Search + '%'
									  OR ISNULL(dbo.Contact.ContactTitle, '') LIKE '%'
									  + @Search + '%'
									  OR dbo.[Theme].ThemeName LIKE '%' + @Search
									  + '%'
									)
					) AS T
			WHERE   RowNum BETWEEN @Start AND @End;
		END
		ELSE
		BEGIN

						SELECT  RowNum ,
					ISNULL(Total, 0) AS Total ,
					Id ,
					IndustryId ,
					IndustryName ,
					GroupName ,
					AboutGroup ,
					ThemeId ,
					ThemeName ,
					ContactTitle
			FROM    ( SELECT    dbo.[Group].[Id] AS Id ,
								dbo.[Group].[IndustryId] AS IndustryId ,
								dbo.[Industry].IndustryName ,
								dbo.[Group].[GroupName] AS GroupName ,
								dbo.[Group].[AboutGroup] AS AboutGroup ,
								dbo.[Group].[ThemeId] AS ThemeId ,
								dbo.[Theme].ThemeName ,
								dbo.Contact.ContactTitle ,
								COUNT(*) OVER ( PARTITION BY 1 ) AS Total ,
								ROW_NUMBER() OVER ( ORDER BY CASE WHEN @Sort = 'Id Asc'
																  THEN dbo.[Group].[Id]
															 END ASC, CASE
																  WHEN @Sort = 'Id DESC'
																  THEN dbo.[Group].[Id]
																  END DESC, CASE
																  WHEN @Sort = 'IndustryName Asc'
																  THEN dbo.[Group].[IndustryId]
																  END ASC, CASE
																  WHEN @Sort = 'IndustryName DESC'
																  THEN dbo.[Group].[IndustryId]
																  END DESC, CASE
																  WHEN @Sort = 'GroupName Asc'
																  THEN dbo.[Group].[GroupName]
																  END ASC, CASE
																  WHEN @Sort = 'GroupName DESC'
																  THEN dbo.[Group].[GroupName]
																  END DESC, CASE
																  WHEN @Sort = 'CreatedOn Asc'
																  THEN dbo.[Group].CreatedOn
																  END ASC, CASE
																  WHEN @Sort = 'CreatedOn DESC'
																  THEN dbo.[Group].CreatedOn
																  END DESC, CASE
																  WHEN @Sort = 'ThemeName Asc'
																  THEN ThemeName
																  END ASC, CASE
																  WHEN @Sort = 'ThemeName DESC'
																  THEN ThemeName
																  END DESC, CASE
																  WHEN @Sort = 'ContactTitle Asc'
																  THEN ContactTitle
																  END ASC, CASE
																  WHEN @Sort = 'ContactTitle DESC'
																  THEN ContactTitle
																  END DESC ) AS RowNum
					  FROM      dbo.[Group]
								INNER JOIN dbo.[Industry] ON dbo.[Industry].Id = dbo.[Group].IndustryId
								INNER JOIN dbo.[Theme] ON dbo.[Theme].Id = dbo.[Group].ThemeId
								INNER JOIN dbo.Contact ON Contact.Id = [Group].ContactId
								INNER JOIN dbo.UserRolePermissions ON dbo.UserRolePermissions.PageID = @PageID
									AND dbo.UserRolePermissions.ActualID = dbo.[Group].Id
									AND dbo.UserRolePermissions.UserID = @UserID
					  WHERE     dbo.[Group].IsDeleted = 0
								AND ( dbo.[Industry].IndustryName LIKE '%'
									  + @Search + '%'
									  OR ISNULL(dbo.[Group].[GroupName], '') LIKE '%'
									  + @Search + '%'
									  OR ISNULL(dbo.Contact.ContactTitle, '') LIKE '%'
									  + @Search + '%'
									  OR dbo.[Theme].ThemeName LIKE '%' + @Search
									  + '%'
									)
					) AS T
			WHERE   RowNum BETWEEN @Start AND @End;

		END
    END;