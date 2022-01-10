/*
=============================================  
Author:  <Author,,Gd>  
Create date: <Create Date,, 09 Jun 2015>  
Description: <Description,,GetAppUserAll>  
Call SP    : SearchAppUser 10000, 1, '', '', '', 0,1  
=============================================  
*/
CREATE PROCEDURE [dbo].[SearchAppUser_0907]  
    @Rows INT ,  
    @Page INT ,  
    @Search NVARCHAR(500) ,  
    @Sort NVARCHAR(50) ,  
    @PasswordSearch NVARCHAR(100) ,  
    @GroupId BIGINT,  
	@UserID INT  
AS  
BEGIN  

	SET NOCOUNT ON

    DECLARE @Start AS INT 
    DECLARE @End INT 
	DECLARE @AdminRole bigint 
	DECLARE @UserRole bigint 
	DECLARE @PageID bigint  
    
	SET @Start = ((@Page * @Rows) - @Rows) + 1;  
    SET @End = @Start + @Rows - 1;  
  
	SELECT TOP 1 @AdminRole = Id FROM [dbo].[Role] WHERE RoleName = 'Admin'  
	SELECT TOP 1 @UserRole = RoleId FROM dbo.[User] WHERE Id = @UserID  
	SELECT TOP 1 @PageID = Id FROM dbo.Page WHERE PageName = 'AppUser'  
          
  
	IF @AdminRole = @UserRole  
		BEGIN  
			/*PRINT 'Hi'*/

			SELECT RowNum,ISNULL(Total, 0) AS Total,Id,Name,Email,Mobile,IsAreaManager,ISNULL(SupplierId, 0) AS SupplierId,UserName,GroupId,
			GroupName,[Password],ISNULL([TU].[EstablishmentNameStr], '') AS Establishment,IsActive 
			FROM (
				SELECT  RowNum,ISNULL(Total, 0) AS Total,Id,Name,Email,Mobile,IsAreaManager,ISNULL(SupplierId, 0) AS SupplierId,UserName,GroupId,
				GroupName,[Password],T.IsActive  
				FROM (
					SELECT dbo.[AppUser].[Id] AS Id,dbo.[AppUser].[Name] AS Name,dbo.[AppUser].[Email] AS Email,dbo.[AppUser].[Mobile] AS Mobile,
					dbo.[AppUser].[IsAreaManager] AS IsAreaManager,dbo.[AppUser].[SupplierId] AS SupplierId,dbo.[AppUser].[UserName] AS UserName,
					dbo.[AppUser].[GroupId] AS GroupId,dbo.[Group].GroupName,[Password],'' AS Establishment,dbo.[AppUser].IsActive AS IsActive,  
					COUNT(1) OVER (PARTITION BY 1) AS Total,
					ROW_NUMBER() OVER (ORDER BY CASE WHEN @Sort = 'Id Asc' THEN dbo.[AppUser].[Id] END ASC, 
					CASE WHEN @Sort = 'Id DESC'  THEN dbo.[AppUser].[Id] END DESC, 
					CASE WHEN @Sort = 'Name Asc' THEN dbo.[AppUser].[Name] END ASC, 
					CASE WHEN @Sort = 'Name DESC' THEN dbo.[AppUser].[Name] END DESC, 
					CASE WHEN @Sort = 'Email Asc' THEN dbo.[AppUser].[Email] END ASC, 
					CASE WHEN @Sort = 'Email DESC' THEN dbo.[AppUser].[Email] END DESC, 
					CASE WHEN @Sort = 'Mobile Asc' THEN dbo.[AppUser].[Mobile] END ASC, 
					CASE WHEN @Sort = 'Mobile DESC' THEN dbo.[AppUser].[Mobile] END DESC, 
					CASE WHEN @Sort = 'IsAreaManager Asc' THEN dbo.[AppUser].[IsAreaManager] END ASC, 
					CASE WHEN @Sort = 'IsAreaManager DESC' THEN dbo.[AppUser].[IsAreaManager] END DESC, 
					CASE WHEN @Sort = 'IsActive Asc' THEN dbo.[AppUser].[IsActive] END ASC, 
					CASE WHEN @Sort = 'IsActive DESC' THEN dbo.[AppUser].[IsActive] END DESC, 
					CASE WHEN @Sort = 'CreatedOn Asc' THEN dbo.[AppUser].CreatedOn END ASC, 
					CASE WHEN @Sort = 'CreatedOn DESC' THEN dbo.[AppUser].CreatedOn END DESC, 
					CASE WHEN @Sort = 'UserName Asc' THEN dbo.[AppUser].[UserName] END ASC, 
					CASE WHEN @Sort = 'UserName DESC' THEN dbo.[AppUser].[UserName] END DESC) AS RowNum         
					FROM dbo.[AppUser]  
					INNER JOIN dbo.AppUserEstablishment AS UE ON dbo.AppUser.Id = UE.AppUserId  
					INNER JOIN dbo.Establishment AS E ON UE.EstablishmentId = E.Id  
					LEFT OUTER JOIN dbo.[Group] ON dbo.[Group].Id = dbo.[AppUser].GroupId  
					WHERE dbo.[AppUser].IsDeleted = 0  
					AND (ISNULL(dbo.[AppUser].[Name], '') LIKE '%' + @Search + '%'  
						OR ISNULL(dbo.[AppUser].[Email], '') LIKE '%' + @Search + '%'  
						OR ISNULL(dbo.[AppUser].[Mobile], '') LIKE '%' + @Search + '%'  
						OR ISNULL(dbo.[AppUser].[UserName], '') LIKE '%' + @Search + '%' 
						OR ISNULL(dbo.[AppUser].[Password], '') LIKE '%' + @Search + '%'   
						OR ISNULL(E.EstablishmentName, '') LIKE '%' + @Search + '%')  
					AND (AppUser.GroupId = @GroupId OR @GroupId = 0)  
					GROUP BY  dbo.[AppUser].[Id],dbo.[AppUser].[Name],dbo.[AppUser].[Email],dbo.[AppUser].[Mobile],dbo.[AppUser].[IsAreaManager],
					dbo.[AppUser].[SupplierId],dbo.[AppUser].[UserName],dbo.[AppUser].[GroupId],dbo.[AppUser].CreatedOn,dbo.[Group].GroupName,dbo.[AppUser].IsActive,  
					[Password]
				) AS T  
				WHERE RowNum BETWEEN @Start AND @End
			) A
			LEFT JOIN dbo.tblUserEstablishment AS TU ON TU.AppUserId = A.Id				  
		END  
	ELSE  
		BEGIN  
			/*PRINT 'Hello'*/

			SELECT RowNum,ISNULL(Total, 0) AS Total,Id,Name,Email,Mobile,IsAreaManager,ISNULL(SupplierId, 0) AS SupplierId,UserName,GroupId,GroupName,[Password],
			ISNULL([TU].[EstablishmentNameStr], '') AS Establishment,IsActive  
			FROM (
				SELECT RowNum,ISNULL(Total, 0) AS Total,Id,Name,Email,Mobile,IsAreaManager,ISNULL(SupplierId, 0) AS SupplierId,UserName,GroupId,GroupName,[Password],
				T.IsActive  
				FROM (
					SELECT DISTINCT dbo.[AppUser].[Id] AS Id,dbo.[AppUser].[Name] AS Name,dbo.[AppUser].[Email] AS Email,dbo.[AppUser].[Mobile] AS Mobile,
					dbo.[AppUser].[IsAreaManager] AS IsAreaManager,dbo.[AppUser].[SupplierId] AS SupplierId,dbo.[AppUser].[UserName] AS UserName,
					dbo.[AppUser].[GroupId] AS GroupId,dbo.[Group].GroupName,[Password],'' AS Establishment,dbo.[AppUser].IsActive AS IsActive,  
					COUNT(1) OVER (PARTITION BY 1) AS Total,
					ROW_NUMBER() OVER (ORDER BY CASE WHEN @Sort = 'Id Asc' THEN dbo.[AppUser].[Id] END ASC, 
					CASE WHEN @Sort = 'Id DESC' THEN dbo.[AppUser].[Id] END DESC, 
					CASE WHEN @Sort = 'Name Asc' THEN dbo.[AppUser].[Name] END ASC, 
					CASE WHEN @Sort = 'Name DESC' THEN dbo.[AppUser].[Name] END DESC, 
					CASE WHEN @Sort = 'Email Asc' THEN dbo.[AppUser].[Email] END ASC, 
					CASE WHEN @Sort = 'Email DESC' THEN dbo.[AppUser].[Email] END DESC, 
					CASE WHEN @Sort = 'Mobile Asc' THEN dbo.[AppUser].[Mobile] END ASC, 
					CASE WHEN @Sort = 'Mobile DESC' THEN dbo.[AppUser].[Mobile] END DESC, 
					CASE WHEN @Sort = 'IsAreaManager Asc' THEN dbo.[AppUser].[IsAreaManager] END ASC, 
					CASE WHEN @Sort = 'IsAreaManager DESC' THEN dbo.[AppUser].[IsAreaManager] END DESC, 
					CASE WHEN @Sort = 'IsActive Asc' THEN dbo.[AppUser].[IsActive] END ASC, 
					CASE WHEN @Sort = 'IsActive DESC' THEN dbo.[AppUser].[IsActive] END DESC, 
					CASE WHEN @Sort = 'CreatedOn Asc' THEN dbo.[AppUser].CreatedOn END ASC, 
					CASE WHEN @Sort = 'CreatedOn DESC' THEN dbo.[AppUser].CreatedOn END DESC, 
					CASE WHEN @Sort = 'UserName Asc' THEN dbo.[AppUser].[UserName] END ASC, 
					CASE WHEN @Sort = 'UserName DESC' THEN dbo.[AppUser].[UserName] END DESC) AS RowNum  
					FROM dbo.[AppUser]  
					INNER JOIN dbo.AppUserEstablishment AS UE ON dbo.AppUser.Id = UE.AppUserId  
					INNER JOIN dbo.Establishment AS E ON UE.EstablishmentId = E.Id  
					LEFT OUTER JOIN dbo.[Group] ON dbo.[Group].Id = dbo.[AppUser].GroupId  
					INNER JOIN dbo.UserRolePermissions ON dbo.UserRolePermissions.PageID = @PageID  
						AND dbo.UserRolePermissions.ActualID = dbo.AppUser.Id  
						AND dbo.UserRolePermissions.UserID = @UserID  
					WHERE dbo.[AppUser].IsDeleted = 0  
					AND (ISNULL(dbo.[AppUser].[Name], '') LIKE '%' + @Search + '%' 
						OR ISNULL(dbo.[AppUser].[Email], '') LIKE '%' + @Search + '%'  
						OR ISNULL(dbo.[AppUser].[Mobile], '') LIKE '%' + @Search + '%'  
						OR ISNULL(dbo.[AppUser].[UserName], '') LIKE '%' + @Search + '%'  
						OR ISNULL(dbo.[AppUser].[Password], '') LIKE '%' + @Search + '%'  
						OR ISNULL(E.EstablishmentName, '') LIKE '%' + @Search + '%')  
					AND (AppUser.GroupId = @GroupId OR @GroupId = 0)  
					GROUP BY  dbo.[AppUser].[Id],dbo.[AppUser].[Name],dbo.[AppUser].[Email],dbo.[AppUser].[Mobile],dbo.[AppUser].[IsAreaManager],
					dbo.[AppUser].[SupplierId],dbo.[AppUser].[UserName],dbo.[AppUser].[GroupId],dbo.[AppUser].CreatedOn,dbo.[Group].GroupName,
					dbo.[AppUser].IsActive,[Password] 
				) AS T  
				WHERE RowNum BETWEEN @Start AND @End
			) A 
			LEFT JOIN dbo.tblUserEstablishment AS TU ON TU.AppUserId = A.Id;
		END  
	
	SET NOCOUNT OFF
END;
