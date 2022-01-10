-- =============================================
-- Author:		<Author,,ADMIN>
-- Create date: <Create Date,, 28 May 2015>
-- Description:	<Description,,GetSeenClientAll>
-- Call SP    :	SearchSeenClient 1, 1, '', ''
-- =============================================
CREATE PROCEDURE dbo.SearchSeenClient
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
		SELECT TOP 1 @UserRole = RoleId FROM dbo.[User] WHERE Id = @UserID
		SELECT TOP 1 @PageID = Id FROM dbo.Page WHERE PageName = 'SeenClient'

        DECLARE @Sql NVARCHAR(MAX);

		IF @AdminRole = @UserRole
		BEGIN

			SELECT  RowNum ,
					ISNULL(Total, 0) AS Total ,
					Id ,
					SeenClientTitle ,
					Description
			FROM    ( SELECT    dbo.[SeenClient].[Id] AS Id ,
								dbo.[SeenClient].[SeenClientTitle] AS SeenClientTitle ,
								dbo.[SeenClient].[Description] AS Description ,
								COUNT(*) OVER ( PARTITION BY 1 ) AS Total ,
								ROW_NUMBER() OVER ( ORDER BY CASE WHEN @Sort = 'Id Asc'
																  THEN dbo.[SeenClient].[Id]
															 END ASC, CASE
																  WHEN @Sort = 'Id DESC'
																  THEN dbo.[SeenClient].[Id]
																  END DESC, CASE
																  WHEN @Sort = 'SeenClientTitle Asc'
																  THEN dbo.[SeenClient].[SeenClientTitle]
																  END ASC, CASE
																  WHEN @Sort = 'SeenClientTitle DESC'
																  THEN dbo.[SeenClient].[SeenClientTitle]
																  END DESC, CASE
																  WHEN @Sort = 'Description Asc'
																  THEN dbo.[SeenClient].[Description]
																  END ASC, CASE
																  WHEN @Sort = 'Description DESC'
																  THEN dbo.[SeenClient].[Description]
																  END DESC, CASE
																  WHEN @Sort = 'CreatedOn Asc'
																  THEN dbo.[SeenClient].CreatedOn
																  END ASC, CASE
																  WHEN @Sort = 'CreatedOn DESC'
																  THEN dbo.[SeenClient].CreatedOn
																  END DESC ) AS RowNum
					  FROM      dbo.[SeenClient]
					  WHERE     dbo.[SeenClient].IsDeleted = 0
								AND ( ISNULL(dbo.[SeenClient].[SeenClientTitle],
											 '') LIKE '%' + @Search + '%'
									  OR ISNULL(dbo.[SeenClient].[Description], '') LIKE '%'
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
					SeenClientTitle ,
					Description
			FROM    ( SELECT    dbo.[SeenClient].[Id] AS Id ,
								dbo.[SeenClient].[SeenClientTitle] AS SeenClientTitle ,
								dbo.[SeenClient].[Description] AS Description ,
								COUNT(*) OVER ( PARTITION BY 1 ) AS Total ,
								ROW_NUMBER() OVER ( ORDER BY CASE WHEN @Sort = 'Id Asc'
																  THEN dbo.[SeenClient].[Id]
															 END ASC, CASE
																  WHEN @Sort = 'Id DESC'
																  THEN dbo.[SeenClient].[Id]
																  END DESC, CASE
																  WHEN @Sort = 'SeenClientTitle Asc'
																  THEN dbo.[SeenClient].[SeenClientTitle]
																  END ASC, CASE
																  WHEN @Sort = 'SeenClientTitle DESC'
																  THEN dbo.[SeenClient].[SeenClientTitle]
																  END DESC, CASE
																  WHEN @Sort = 'Description Asc'
																  THEN dbo.[SeenClient].[Description]
																  END ASC, CASE
																  WHEN @Sort = 'Description DESC'
																  THEN dbo.[SeenClient].[Description]
																  END DESC, CASE
																  WHEN @Sort = 'CreatedOn Asc'
																  THEN dbo.[SeenClient].CreatedOn
																  END ASC, CASE
																  WHEN @Sort = 'CreatedOn DESC'
																  THEN dbo.[SeenClient].CreatedOn
																  END DESC ) AS RowNum
					  FROM      dbo.[SeenClient]
					  INNER JOIN dbo.UserRolePermissions ON dbo.UserRolePermissions.PageID = @PageID
						 AND dbo.UserRolePermissions.ActualID = dbo.SeenClient.Id
						 AND dbo.UserRolePermissions.UserID = @UserID
					  WHERE     dbo.[SeenClient].IsDeleted = 0 
								AND ( ISNULL(dbo.[SeenClient].[SeenClientTitle],
											 '') LIKE '%' + @Search + '%'
									  OR ISNULL(dbo.[SeenClient].[Description], '') LIKE '%'
									  + @Search + '%'
									)
					) AS T
			WHERE   RowNum BETWEEN @Start AND @End;

		END
    END;
