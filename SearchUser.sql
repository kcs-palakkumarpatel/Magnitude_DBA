
-- =============================================
-- Author:		<Author,,ADMIN>
-- Create date: <Create Date,, 25 May 2015>
-- Description:	<Description,,GetUserAll>
-- Call SP    :	SearchUser 1, 1, '', ''
-- =============================================
CREATE PROCEDURE [dbo].[SearchUser]
    @Rows INT ,
    @Page INT ,
    @Search NVARCHAR(500) ,
    @Sort NVARCHAR(50) ,
	@UserID INT
AS 
    BEGIN
        DECLARE @Start AS INT ,
            @End INT ,
			@AdminRole bigint ,
			@UserRole bigint ,
			@PageID bigint

        SET @Start = ( ( @Page * @Rows ) - @Rows ) + 1
        SET @End = @Page + @Rows 

		SELECT TOP 1 @AdminRole = Id FROM [dbo].[Role] WHERE RoleName = 'Admin'
		SELECT TOP 1 @UserRole = RoleId FROM dbo.[User] WHERE Id = @UserId
		SELECT TOP 1 @PageID = Id FROM dbo.Page WHERE PageName = 'User'

        DECLARE @Sql NVARCHAR(MAX)

		IF @AdminRole = @UserRole
		BEGIN

			SELECT  RowNum ,
					ISNULL(Total, 0 ) AS Total ,
					Id ,
					Name ,
					SurName ,
					MobileNo ,
					EmailId ,
					UserName ,
					Address ,
					RoleId ,
					RoleName ,
					IsActive ,
					IsLogin
			FROM    ( SELECT    dbo.[User].[Id] AS Id ,
								dbo.[User].[Name] AS Name ,
								dbo.[User].[SurName] AS SurName ,
								dbo.[User].[MobileNo] AS MobileNo ,
								dbo.[User].[EmailId] AS EmailId ,
								dbo.[User].[UserName] AS UserName ,
								dbo.[User].[Address] AS Address ,
								dbo.[User].[RoleId] AS RoleId ,
								dbo.[Role].RoleName ,
								dbo.[User].[IsActive] AS IsActive ,
								dbo.[User].[IsLogin] AS IsLogin ,
								COUNT(*) OVER ( PARTITION BY 1 ) AS Total ,
								ROW_NUMBER() OVER ( ORDER BY CASE WHEN @Sort = 'Id Asc'
																  THEN dbo.[User].[Id]
															 END ASC, CASE
																  WHEN @Sort = 'Id DESC'
																  THEN dbo.[User].[Id]
																  END DESC, CASE
																  WHEN @Sort = 'Name Asc'
																  THEN dbo.[User].[Name]
																  END ASC, CASE
																  WHEN @Sort = 'Name DESC'
																  THEN dbo.[User].[Name]
																  END DESC, CASE
																  WHEN @Sort = 'SurName Asc'
																  THEN dbo.[User].[SurName]
																  END ASC, CASE
																  WHEN @Sort = 'SurName DESC'
																  THEN dbo.[User].[SurName]
																  END DESC, CASE
																  WHEN @Sort = 'MobileNo Asc'
																  THEN dbo.[User].[MobileNo]
																  END ASC, CASE
																  WHEN @Sort = 'MobileNo DESC'
																  THEN dbo.[User].[MobileNo]
																  END DESC, CASE
																  WHEN @Sort = 'EmailId Asc'
																  THEN dbo.[User].[EmailId]
																  END ASC, CASE
																  WHEN @Sort = 'EmailId DESC'
																  THEN dbo.[User].[EmailId]
																  END DESC, CASE
																  WHEN @Sort = 'UserName Asc'
																  THEN dbo.[User].[UserName]
																  END ASC, CASE
																  WHEN @Sort = 'UserName DESC'
																  THEN dbo.[User].[UserName]
																  END DESC, CASE
																  WHEN @Sort = 'Address Asc'
																  THEN dbo.[User].[Address]
																  END ASC, CASE
																  WHEN @Sort = 'Address DESC'
																  THEN dbo.[User].[Address]
																  END DESC, CASE
																  WHEN @Sort = 'RoleName Asc'
																  THEN dbo.[User].[RoleId]
																  END ASC, CASE
																  WHEN @Sort = 'RoleName DESC'
																  THEN dbo.[User].[RoleId]
																  END DESC, CASE
																  WHEN @Sort = 'IsActive Asc'
																  THEN dbo.[User].[IsActive]
																  END ASC, CASE
																  WHEN @Sort = 'IsActive DESC'
																  THEN dbo.[User].[IsActive]
																  END DESC, CASE
																  WHEN @Sort = 'IsLogin Asc'
																  THEN dbo.[User].[IsLogin]
																  END ASC, CASE
																  WHEN @Sort = 'IsLogin DESC'
																  THEN dbo.[User].[IsLogin]
																  END DESC ) AS RowNum
					  FROM      dbo.[User]
								INNER JOIN dbo.[Role] ON dbo.[Role].Id = dbo.[User].RoleId
					  WHERE     dbo.[User].IsDeleted = 0
								AND ( ISNULL(dbo.[User].[Name], '') LIKE '%'
									  + @Search + '%'
									  OR ISNULL(dbo.[User].[SurName], '') LIKE '%'
									  + @Search + '%'
									  OR ISNULL(dbo.[User].[MobileNo], '') LIKE '%'
									  + @Search + '%'
									  OR ISNULL(dbo.[User].[EmailId], '') LIKE '%'
									  + @Search + '%'
									  OR ISNULL(dbo.[User].[UserName], '') LIKE '%'
									  + @Search + '%'
									  OR ISNULL(dbo.[User].[Address], '') LIKE '%'
									  + @Search + '%'
									  OR dbo.[Role].RoleName LIKE '%' + @Search
									  + '%'
									  OR ISNULL(dbo.[User].[IsActive], '') LIKE '%'
									  + @Search + '%'
									  OR ISNULL(dbo.[User].[IsLogin], '') LIKE '%'
									  + @Search + '%'
									)
					) AS T
			WHERE   RowNum BETWEEN @Start AND @End
		END
		ELSE
		BEGIN

						SELECT  RowNum ,
					ISNULL(Total, 0 ) AS Total ,
					Id ,
					Name ,
					SurName ,
					MobileNo ,
					EmailId ,
					UserName ,
					Address ,
					RoleId ,
					RoleName ,
					IsActive ,
					IsLogin
			FROM    ( SELECT    dbo.[User].[Id] AS Id ,
								dbo.[User].[Name] AS Name ,
								dbo.[User].[SurName] AS SurName ,
								dbo.[User].[MobileNo] AS MobileNo ,
								dbo.[User].[EmailId] AS EmailId ,
								dbo.[User].[UserName] AS UserName ,
								dbo.[User].[Address] AS Address ,
								dbo.[User].[RoleId] AS RoleId ,
								dbo.[Role].RoleName ,
								dbo.[User].[IsActive] AS IsActive ,
								dbo.[User].[IsLogin] AS IsLogin ,
								COUNT(*) OVER ( PARTITION BY 1 ) AS Total ,
								ROW_NUMBER() OVER ( ORDER BY CASE WHEN @Sort = 'Id Asc'
																  THEN dbo.[User].[Id]
															 END ASC, CASE
																  WHEN @Sort = 'Id DESC'
																  THEN dbo.[User].[Id]
																  END DESC, CASE
																  WHEN @Sort = 'Name Asc'
																  THEN dbo.[User].[Name]
																  END ASC, CASE
																  WHEN @Sort = 'Name DESC'
																  THEN dbo.[User].[Name]
																  END DESC, CASE
																  WHEN @Sort = 'SurName Asc'
																  THEN dbo.[User].[SurName]
																  END ASC, CASE
																  WHEN @Sort = 'SurName DESC'
																  THEN dbo.[User].[SurName]
																  END DESC, CASE
																  WHEN @Sort = 'MobileNo Asc'
																  THEN dbo.[User].[MobileNo]
																  END ASC, CASE
																  WHEN @Sort = 'MobileNo DESC'
																  THEN dbo.[User].[MobileNo]
																  END DESC, CASE
																  WHEN @Sort = 'EmailId Asc'
																  THEN dbo.[User].[EmailId]
																  END ASC, CASE
																  WHEN @Sort = 'EmailId DESC'
																  THEN dbo.[User].[EmailId]
																  END DESC, CASE
																  WHEN @Sort = 'UserName Asc'
																  THEN dbo.[User].[UserName]
																  END ASC, CASE
																  WHEN @Sort = 'UserName DESC'
																  THEN dbo.[User].[UserName]
																  END DESC, CASE
																  WHEN @Sort = 'Address Asc'
																  THEN dbo.[User].[Address]
																  END ASC, CASE
																  WHEN @Sort = 'Address DESC'
																  THEN dbo.[User].[Address]
																  END DESC, CASE
																  WHEN @Sort = 'RoleName Asc'
																  THEN dbo.[User].[RoleId]
																  END ASC, CASE
																  WHEN @Sort = 'RoleName DESC'
																  THEN dbo.[User].[RoleId]
																  END DESC, CASE
																  WHEN @Sort = 'IsActive Asc'
																  THEN dbo.[User].[IsActive]
																  END ASC, CASE
																  WHEN @Sort = 'IsActive DESC'
																  THEN dbo.[User].[IsActive]
																  END DESC, CASE
																  WHEN @Sort = 'IsLogin Asc'
																  THEN dbo.[User].[IsLogin]
																  END ASC, CASE
																  WHEN @Sort = 'IsLogin DESC'
																  THEN dbo.[User].[IsLogin]
																  END DESC ) AS RowNum
					  FROM      dbo.[User]
								INNER JOIN dbo.[Role] ON dbo.[Role].Id = dbo.[User].RoleId
								INNER JOIN dbo.UserRolePermissions ON dbo.UserRolePermissions.PageID = @PageID
									AND dbo.UserRolePermissions.ActualID = dbo.[User].Id
									AND dbo.UserRolePermissions.UserID = @UserID
					  WHERE     dbo.[User].IsDeleted = 0
								AND ( ISNULL(dbo.[User].[Name], '') LIKE '%'
									  + @Search + '%'
									  OR ISNULL(dbo.[User].[SurName], '') LIKE '%'
									  + @Search + '%'
									  OR ISNULL(dbo.[User].[MobileNo], '') LIKE '%'
									  + @Search + '%'
									  OR ISNULL(dbo.[User].[EmailId], '') LIKE '%'
									  + @Search + '%'
									  OR ISNULL(dbo.[User].[UserName], '') LIKE '%'
									  + @Search + '%'
									  OR ISNULL(dbo.[User].[Address], '') LIKE '%'
									  + @Search + '%'
									  OR dbo.[Role].RoleName LIKE '%' + @Search
									  + '%'
									  OR ISNULL(dbo.[User].[IsActive], '') LIKE '%'
									  + @Search + '%'
									  OR ISNULL(dbo.[User].[IsLogin], '') LIKE '%'
									  + @Search + '%'
									)
					) AS T
			WHERE   RowNum BETWEEN @Start AND @End

		END
    END;