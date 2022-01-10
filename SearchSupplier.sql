
-- =============================================
-- Author:		<Author,,ADMIN>
-- Create date: <Create Date,, 26 May 2015>
-- Description:	<Description,,GetSupplierAll>
-- Call SP    :	SearchSupplier 1, 1, '', ''
-- =============================================
CREATE PROCEDURE [dbo].[SearchSupplier]
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

        SET @Start = ( ( @Page * @Rows ) - @Rows ) + 1;
        SET @End = @Start + @Rows - 1;

		SELECT TOP 1 @AdminRole = Id FROM [dbo].[Role] WHERE RoleName = 'Admin'
		SELECT TOP 1 @UserRole = RoleId FROM dbo.[User] WHERE Id = @UserId
		SELECT TOP 1 @PageID = Id FROM dbo.Page WHERE PageName = 'Supplier'

        DECLARE @Sql NVARCHAR(MAX);

				
		IF @AdminRole = @UserRole
		BEGIN

			SELECT  RowNum ,
					ISNULL(Total, 0) Total ,
					Id ,
					SupplierTypeId ,
					SupplierTypeName ,
					SupplierName ,
					SupplierAddress ,
					SupplierEmail ,
					SupplierMobile ,
					AboutSupplier
			FROM    ( SELECT    dbo.[Supplier].[Id] AS Id ,
								dbo.[Supplier].[SupplierTypeId] AS SupplierTypeId ,
								dbo.[SupplierType].SupplierTypeName ,
								dbo.[Supplier].[SupplierName] AS SupplierName ,
								dbo.[Supplier].[SupplierAddress] AS SupplierAddress ,
								dbo.[Supplier].[SupplierEmail] AS SupplierEmail ,
								dbo.[Supplier].[SupplierMobile] AS SupplierMobile ,
								dbo.[Supplier].[AboutSupplier] AS AboutSupplier ,
								COUNT(*) OVER ( PARTITION BY 1 ) AS Total ,
								ROW_NUMBER() OVER ( ORDER BY CASE WHEN @Sort = 'Id Asc'
																  THEN dbo.[Supplier].[Id]
															 END ASC, CASE
																  WHEN @Sort = 'Id DESC'
																  THEN dbo.[Supplier].[Id]
																  END DESC, CASE
																  WHEN @Sort = 'SupplierTypeName Asc'
																  THEN dbo.[Supplier].[SupplierTypeId]
																  END ASC, CASE
																  WHEN @Sort = 'SupplierTypeName DESC'
																  THEN dbo.[Supplier].[SupplierTypeId]
																  END DESC, CASE
																  WHEN @Sort = 'SupplierName Asc'
																  THEN dbo.[Supplier].[SupplierName]
																  END ASC, CASE
																  WHEN @Sort = 'SupplierName DESC'
																  THEN dbo.[Supplier].[SupplierName]
																  END DESC, CASE
																  WHEN @Sort = 'SupplierMobile Asc'
																  THEN dbo.[Supplier].[SupplierMobile]
																  END ASC, CASE
																  WHEN @Sort = 'SupplierMobile DESC'
																  THEN dbo.[Supplier].[SupplierMobile]
																  END DESC, CASE
																  WHEN @Sort = 'CreatedOn Asc'
																  THEN dbo.[Supplier].CreatedOn
																  END ASC, CASE
																  WHEN @Sort = 'CreatedOn DESC'
																  THEN dbo.[Supplier].CreatedOn
																  END DESC ) AS RowNum
					  FROM      dbo.[Supplier]
								INNER JOIN dbo.[SupplierType] ON dbo.[SupplierType].Id = dbo.[Supplier].SupplierTypeId
					  WHERE     dbo.[Supplier].IsDeleted = 0
								AND ( dbo.[SupplierType].SupplierTypeName LIKE '%'
									  + @Search + '%'
									  OR ISNULL(dbo.[Supplier].[SupplierName], '') LIKE '%'
									  + @Search + '%'
									  OR ISNULL(dbo.[Supplier].[SupplierMobile],
												'') LIKE '%' + @Search + '%'
									)
					) AS T
			WHERE   RowNum BETWEEN @Start AND @End;
		END
		ELSE
		BEGIN

						SELECT  RowNum ,
					ISNULL(Total, 0) Total ,
					Id ,
					SupplierTypeId ,
					SupplierTypeName ,
					SupplierName ,
					SupplierAddress ,
					SupplierEmail ,
					SupplierMobile ,
					AboutSupplier
			FROM    ( SELECT    dbo.[Supplier].[Id] AS Id ,
								dbo.[Supplier].[SupplierTypeId] AS SupplierTypeId ,
								dbo.[SupplierType].SupplierTypeName ,
								dbo.[Supplier].[SupplierName] AS SupplierName ,
								dbo.[Supplier].[SupplierAddress] AS SupplierAddress ,
								dbo.[Supplier].[SupplierEmail] AS SupplierEmail ,
								dbo.[Supplier].[SupplierMobile] AS SupplierMobile ,
								dbo.[Supplier].[AboutSupplier] AS AboutSupplier ,
								COUNT(*) OVER ( PARTITION BY 1 ) AS Total ,
								ROW_NUMBER() OVER ( ORDER BY CASE WHEN @Sort = 'Id Asc'
																  THEN dbo.[Supplier].[Id]
															 END ASC, CASE
																  WHEN @Sort = 'Id DESC'
																  THEN dbo.[Supplier].[Id]
																  END DESC, CASE
																  WHEN @Sort = 'SupplierTypeName Asc'
																  THEN dbo.[Supplier].[SupplierTypeId]
																  END ASC, CASE
																  WHEN @Sort = 'SupplierTypeName DESC'
																  THEN dbo.[Supplier].[SupplierTypeId]
																  END DESC, CASE
																  WHEN @Sort = 'SupplierName Asc'
																  THEN dbo.[Supplier].[SupplierName]
																  END ASC, CASE
																  WHEN @Sort = 'SupplierName DESC'
																  THEN dbo.[Supplier].[SupplierName]
																  END DESC, CASE
																  WHEN @Sort = 'SupplierMobile Asc'
																  THEN dbo.[Supplier].[SupplierMobile]
																  END ASC, CASE
																  WHEN @Sort = 'SupplierMobile DESC'
																  THEN dbo.[Supplier].[SupplierMobile]
																  END DESC, CASE
																  WHEN @Sort = 'CreatedOn Asc'
																  THEN dbo.[Supplier].CreatedOn
																  END ASC, CASE
																  WHEN @Sort = 'CreatedOn DESC'
																  THEN dbo.[Supplier].CreatedOn
																  END DESC ) AS RowNum
					  FROM      dbo.[Supplier]
								INNER JOIN dbo.[SupplierType] ON dbo.[SupplierType].Id = dbo.[Supplier].SupplierTypeId
								INNER JOIN dbo.UserRolePermissions ON dbo.UserRolePermissions.PageID = @PageID
									AND dbo.UserRolePermissions.ActualID = dbo.Supplier.Id
									AND dbo.UserRolePermissions.UserID = @UserID
					  WHERE     dbo.[Supplier].IsDeleted = 0
								AND ( dbo.[SupplierType].SupplierTypeName LIKE '%'
									  + @Search + '%'
									  OR ISNULL(dbo.[Supplier].[SupplierName], '') LIKE '%'
									  + @Search + '%'
									  OR ISNULL(dbo.[Supplier].[SupplierMobile],
												'') LIKE '%' + @Search + '%'
									)
					) AS T
			WHERE   RowNum BETWEEN @Start AND @End;

		END
    END;