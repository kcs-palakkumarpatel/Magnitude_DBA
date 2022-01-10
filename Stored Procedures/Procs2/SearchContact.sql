-- =============================================
-- Author:		<Author,,GD>
-- Create date: <Create Date,, 15 Jun 2015>
-- Description:	<Description,,GetContactAll>
-- Call SP    :	SearchContact 1, 1, '', ''
-- =============================================
CREATE PROCEDURE dbo.SearchContact
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
			@PageID bigint;
		--SET @Rows = 10000;  ---- by default 10000 record requier
        SET @Start = ( ( @Page * @Rows ) - @Rows ) + 1;
        SET @End = @Start + @Rows - 1;
		 
		SELECT TOP 1 @AdminRole = Id FROM [dbo].[Role] WHERE RoleName = 'Admin'
		SELECT TOP 1 @UserRole = RoleId FROM dbo.[User] WHERE Id = @UserID
		SELECT TOP 1 @PageID = Id FROM dbo.Page WHERE PageName = 'Contact'

		IF @AdminRole = @UserRole
		BEGIN

			SELECT  RowNum ,
					ISNULL(Total, 0) AS Total ,
					Id ,
					ContactTitle ,
					Description
			FROM    ( SELECT    dbo.[Contact].[Id] AS Id ,
								dbo.[Contact].[ContactTitle] AS ContactTitle ,
								dbo.[Contact].[Description] AS Description ,
								COUNT(*) OVER ( PARTITION BY 1 ) AS Total ,
								ROW_NUMBER() OVER ( ORDER BY CASE WHEN @Sort = 'Id Asc'
																  THEN dbo.[Contact].[Id]
															 END ASC, CASE
																  WHEN @Sort = 'Id DESC'
																  THEN dbo.[Contact].[Id]
																  END DESC, CASE
																  WHEN @Sort = 'ContactTitle Asc'
																  THEN dbo.[Contact].[ContactTitle]
																  END ASC, CASE
																  WHEN @Sort = 'ContactTitle DESC'
																  THEN dbo.[Contact].[ContactTitle]
																  END DESC, CASE
																  WHEN @Sort = 'Description Asc'
																  THEN dbo.[Contact].[Description]
																  END ASC, CASE
																  WHEN @Sort = 'Description DESC'
																  THEN dbo.[Contact].[Description]
																  END DESC, CASE
																  WHEN @Sort = 'CreatedOn Asc'
																  THEN dbo.[Contact].CreatedOn
																  END ASC, CASE
																  WHEN @Sort = 'CreatedOn DESC'
																  THEN dbo.[Contact].CreatedOn
																  END DESC ) AS RowNum
					  FROM      dbo.[Contact]
					  WHERE     dbo.[Contact].IsDeleted = 0
								AND ( ISNULL(dbo.[Contact].[ContactTitle], '') LIKE '%'
									  + @Search + '%'
									  OR ISNULL(dbo.[Contact].[Description], '') LIKE '%'
									  + @Search + '%'
									)
					) AS T
			WHERE   RowNum BETWEEN @Start AND @End;
		END
		ELSE
		BEGIN

			SELECT  RowNum ,
					ISNULL(Total, 0) AS Total ,
					Id ,
					ContactTitle ,
					Description
			FROM    ( SELECT    dbo.[Contact].[Id] AS Id ,
								dbo.[Contact].[ContactTitle] AS ContactTitle ,
								dbo.[Contact].[Description] AS Description ,
								COUNT(*) OVER ( PARTITION BY 1 ) AS Total ,
								ROW_NUMBER() OVER ( ORDER BY CASE WHEN @Sort = 'Id Asc'
																  THEN dbo.[Contact].[Id]
															 END ASC, CASE
																  WHEN @Sort = 'Id DESC'
																  THEN dbo.[Contact].[Id]
																  END DESC, CASE
																  WHEN @Sort = 'ContactTitle Asc'
																  THEN dbo.[Contact].[ContactTitle]
																  END ASC, CASE
																  WHEN @Sort = 'ContactTitle DESC'
																  THEN dbo.[Contact].[ContactTitle]
																  END DESC, CASE
																  WHEN @Sort = 'Description Asc'
																  THEN dbo.[Contact].[Description]
																  END ASC, CASE
																  WHEN @Sort = 'Description DESC'
																  THEN dbo.[Contact].[Description]
																  END DESC, CASE
																  WHEN @Sort = 'CreatedOn Asc'
																  THEN dbo.[Contact].CreatedOn
																  END ASC, CASE
																  WHEN @Sort = 'CreatedOn DESC'
																  THEN dbo.[Contact].CreatedOn
																  END DESC ) AS RowNum
					  FROM      dbo.[Contact]
					  INNER JOIN dbo.UserRolePermissions ON dbo.UserRolePermissions.PageID = @PageID
							AND dbo.UserRolePermissions.ActualID = dbo.Contact.Id
							AND dbo.UserRolePermissions.UserID = @UserID
					  WHERE     dbo.[Contact].IsDeleted = 0
								AND ( ISNULL(dbo.[Contact].[ContactTitle], '') LIKE '%'
									  + @Search + '%'
									  OR ISNULL(dbo.[Contact].[Description], '') LIKE '%'
									  + @Search + '%'
									)
					) AS T
			WHERE   RowNum BETWEEN @Start AND @End;

		END
	END;
