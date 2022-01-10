
-- =============================================
-- Author:		<Author,,ADMIN>
-- Create date: <Create Date,, 27 May 2015>
-- Description:	<Description,,GetSupplierTypeAll>
-- Call SP    :	SearchSupplierType 1, 1, '', ''
-- =============================================
CREATE PROCEDURE [dbo].[SearchSupplierType]
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
        SET @End = @Start + @Rows - 1;

		SELECT TOP 1 @AdminRole = Id FROM [dbo].[Role] WHERE RoleName = 'Admin'
		SELECT TOP 1 @UserRole = RoleId FROM dbo.[User] WHERE Id = @UserId
		SELECT TOP 1 @PageID = Id FROM dbo.Page WHERE PageName = 'SupplierType'

        DECLARE @Sql NVARCHAR(MAX)

		IF @AdminRole = @UserRole
		BEGIN

			SELECT  RowNum ,
					ISNULL(Total, 0) Total ,
					Id ,
					SupplierTypeName ,
					AboutSupplierType
			FROM    ( SELECT    dbo.[SupplierType].[Id] AS Id ,
								dbo.[SupplierType].[SupplierTypeName] AS SupplierTypeName ,
								dbo.[SupplierType].[AboutSupplierType] AS AboutSupplierType ,
								COUNT(*) OVER ( PARTITION BY 1 ) AS Total ,
								ROW_NUMBER() OVER ( ORDER BY CASE WHEN @Sort = 'Id Asc'
																  THEN dbo.[SupplierType].[Id]
															 END ASC, CASE
																  WHEN @Sort = 'Id DESC'
																  THEN dbo.[SupplierType].[Id]
																  END DESC, CASE
																  WHEN @Sort = 'SupplierTypeName Asc'
																  THEN dbo.[SupplierType].[SupplierTypeName]
																  END ASC, CASE
																  WHEN @Sort = 'SupplierTypeName DESC'
																  THEN dbo.[SupplierType].[SupplierTypeName]
																  END DESC, CASE
																  WHEN @Sort = 'AboutSupplierType Asc'
																  THEN dbo.[SupplierType].[AboutSupplierType]
																  END ASC, CASE
																  WHEN @Sort = 'AboutSupplierType DESC'
																  THEN dbo.[SupplierType].[AboutSupplierType]
																  END DESC, CASE
																  WHEN @Sort = 'CreatedOn Asc'
																  THEN dbo.[SupplierType].CreatedOn
																  END ASC, CASE
																  WHEN @Sort = 'CreatedOn DESC'
																  THEN dbo.[SupplierType].CreatedOn
																  END DESC ) AS RowNum
					  FROM      dbo.[SupplierType]
					  WHERE     dbo.[SupplierType].IsDeleted = 0
								AND ( ISNULL(dbo.[SupplierType].[SupplierTypeName],
											 '') LIKE '%' + @Search + '%'
									  OR ISNULL(dbo.[SupplierType].[AboutSupplierType],
												'') LIKE '%' + @Search + '%'
									)
					) AS T
			WHERE   RowNum BETWEEN @Start AND @End
		END
		ELSE
		BEGIN

						SELECT  RowNum ,
					ISNULL(Total, 0) Total ,
					Id ,
					SupplierTypeName ,
					AboutSupplierType
			FROM    ( SELECT    dbo.[SupplierType].[Id] AS Id ,
								dbo.[SupplierType].[SupplierTypeName] AS SupplierTypeName ,
								dbo.[SupplierType].[AboutSupplierType] AS AboutSupplierType ,
								COUNT(*) OVER ( PARTITION BY 1 ) AS Total ,
								ROW_NUMBER() OVER ( ORDER BY CASE WHEN @Sort = 'Id Asc'
																  THEN dbo.[SupplierType].[Id]
															 END ASC, CASE
																  WHEN @Sort = 'Id DESC'
																  THEN dbo.[SupplierType].[Id]
																  END DESC, CASE
																  WHEN @Sort = 'SupplierTypeName Asc'
																  THEN dbo.[SupplierType].[SupplierTypeName]
																  END ASC, CASE
																  WHEN @Sort = 'SupplierTypeName DESC'
																  THEN dbo.[SupplierType].[SupplierTypeName]
																  END DESC, CASE
																  WHEN @Sort = 'AboutSupplierType Asc'
																  THEN dbo.[SupplierType].[AboutSupplierType]
																  END ASC, CASE
																  WHEN @Sort = 'AboutSupplierType DESC'
																  THEN dbo.[SupplierType].[AboutSupplierType]
																  END DESC, CASE
																  WHEN @Sort = 'CreatedOn Asc'
																  THEN dbo.[SupplierType].CreatedOn
																  END ASC, CASE
																  WHEN @Sort = 'CreatedOn DESC'
																  THEN dbo.[SupplierType].CreatedOn
																  END DESC ) AS RowNum
					  FROM      dbo.[SupplierType]
					  INNER JOIN dbo.UserRolePermissions ON dbo.UserRolePermissions.PageID = @PageID
						 AND dbo.UserRolePermissions.ActualID = dbo.SupplierType.Id
						 AND dbo.UserRolePermissions.UserID = @UserID
					  WHERE     dbo.[SupplierType].IsDeleted = 0
								AND ( ISNULL(dbo.[SupplierType].[SupplierTypeName],
											 '') LIKE '%' + @Search + '%'
									  OR ISNULL(dbo.[SupplierType].[AboutSupplierType],
												'') LIKE '%' + @Search + '%'
									)
					) AS T
			WHERE   RowNum BETWEEN @Start AND @End

		END
    END;