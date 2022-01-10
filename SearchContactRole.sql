
-- =============================================
-- Author:		<Vasu Patel>
-- Create date: <07 Oct 2016>
-- Description:	<Search Contact Role>
-- Call SP    :	SearchContactRole 100, 1, '', 'ID Desc', 220,74
-- =============================================
CREATE PROCEDURE [dbo].[SearchContactRole]
    @Rows INT ,
    @Page INT ,
    @Search NVARCHAR(500) ,
    @Sort NVARCHAR(50) ,
    @GroupId BIGINT,
	@UserID INT
AS
    BEGIN
        DECLARE @Start AS INT ,
            @End INT ,
			@AdminRole bigint ,
			@UserRole bigint ,
			@PageID bigint;

        SET @Start = ( ( @Page * @Rows ) - @Rows ) + 1;
        SET @End = @Start + @Rows - 1;

		
		SELECT TOP 1 @AdminRole = Id FROM [dbo].[Role] WHERE RoleName = 'Admin'
		SELECT TOP 1 @UserRole = RoleId FROM dbo.[User] WHERE Id = @UserId
		SELECT TOP 1 @PageID = Id FROM dbo.Page WHERE PageName = 'ContactRole'

		IF @AdminRole = @UserRole
		BEGIN
		PRINT '1'

			SELECT  RowNum ,
					ISNULL(Total, 0) AS Total ,
					Id ,
					GroupId ,
					GroupName ,
					RoleName,
					Descriptions
			FROM    ( SELECT  DISTINCT  dbo.[ContactRole].[Id] AS Id ,
								dbo.[ContactRole].[GroupId] AS GroupId ,
								dbo.[Group].GroupName ,
								dbo.[ContactRole].[RoleName] AS RoleName,
								dbo.[ContactRole].[Descriptions] AS Descriptions,
								COUNT(*) OVER ( PARTITION BY 1 ) AS Total ,
								row_number() over ( order by case when @sort = 'id asc'
																  then dbo.[contactrole].[id]
															 end asc, case
																  when @sort = 'id desc'
																  then dbo.[contactrole].[id]
																  end desc, case
																  when @sort = 'rolename asc'
																  then dbo.[contactrole].rolename
																  end asc, case
																  when @sort = 'rolename desc'
																  then dbo.[contactrole].rolename
																  end desc, case
																  when @sort = 'groupname asc'
																  then dbo.[group].[groupname]
																  end asc, case
																  when @sort = 'groupname desc'
																  then dbo.[group].[groupname]
																  end desc, case
																  when @sort = 'descriptions asc'
																  then dbo.[contactrole].descriptions
																  end asc, case
																  when @sort = 'descriptions desc'
																  then dbo.[contactrole].descriptions
																  end desc) as rownum
					  FROM      dbo.[ContactRole]
								INNER JOIN dbo.[Group] ON dbo.ContactRole.GroupId = dbo.[Group].Id
					  WHERE     dbo.[Group].IsDeleted = 0
								AND dbo.[ContactRole].IsDeleted = 0
								AND ( RoleName LIKE '%' + @Search + '%'
									  OR Descriptions LIKE '%' + @Search
									  + '%'
									  OR GroupName LIKE '%' + @Search + '%'
									)
								AND ( ContactRole.GroupId = @GroupId
									  OR @GroupId = 0
									)
					) AS T
			WHERE   RowNum BETWEEN @Start AND @End;
		END
		ELSE
		BEGIN
		PRINT '2'
			SELECT  RowNum ,
					ISNULL(Total, 0) AS Total ,
					Id ,
					GroupId ,
					GroupName ,
					RoleName,
					Descriptions
			FROM    ( SELECT DISTINCT  dbo.[ContactRole].[Id] AS Id ,
								dbo.[ContactRole].[GroupId] AS GroupId ,
								dbo.[Group].GroupName ,
								dbo.[ContactRole].[RoleName] AS RoleName,
								dbo.[ContactRole].[Descriptions] AS Descriptions,
								COUNT(*) OVER ( PARTITION BY 1 ) AS Total ,
								--ROW_NUMBER() OVER ( ORDER BY dbo.[ContactRole].[Id] DESC) AS RowNum
								ROW_NUMBER() OVER ( ORDER BY CASE WHEN @Sort = 'Id Asc'
																  THEN dbo.[ContactRole].[Id]
															 END ASC, CASE
																  WHEN @Sort = 'Id DESC'
																  THEN dbo.[ContactRole].[Id]
																  END DESC, CASE
																  WHEN @Sort = 'RoleName Asc'
																  THEN dbo.[ContactRole].RoleName
																  END ASC, CASE
																  WHEN @Sort = 'RoleName DESC'
																  THEN dbo.[ContactRole].RoleName
																  END DESC, CASE
																  WHEN @Sort = 'GroupName Asc'
																  THEN dbo.[Group].[GroupName]
																  END ASC, CASE
																  WHEN @Sort = 'GroupName DESC'
																  THEN dbo.[Group].[GroupName]
																  END DESC, CASE
																  WHEN @Sort = 'Descriptions Asc'
																  THEN dbo.[ContactRole].Descriptions
																  END ASC, CASE
																  WHEN @Sort = 'Descriptions DESC'
																  THEN dbo.[ContactRole].Descriptions
																  END DESC) AS RowNum
					  FROM      dbo.[ContactRole]
								INNER JOIN dbo.[Group] ON dbo.ContactRole.GroupId = dbo.[Group].Id
								INNER JOIN dbo.UserRolePermissions ON dbo.UserRolePermissions.PageID = @PageID 
								INNER JOIN dbo.AppUser A ON A.id = UserRolePermissions.ActualID
								--INNER JOIN dbo.ContactRoleEstablishment  ON dbo.ContactRole.Id = dbo.ContactRoleEstablishment.ContactRoleId
								AND dbo.UserRolePermissions.ActualID = dbo.ContactRole.Id
									AND dbo.UserRolePermissions.UserID = @UserID
					  WHERE     dbo.[Group].IsDeleted = 0
								AND dbo.[ContactRole].IsDeleted = 0
								AND ( RoleName LIKE '%' + @Search + '%'
									  OR Descriptions LIKE '%' + @Search
									  + '%'
									  OR GroupName LIKE '%' + @Search + '%'
									)
								AND ( ContactRole.GroupId = @GroupId
									  OR @GroupId = 0
									)
					) AS T
			WHERE   RowNum BETWEEN @Start AND @End;

		END
    END;




	--SELECT * FROM UserRolePermissions ORDER BY id DESC