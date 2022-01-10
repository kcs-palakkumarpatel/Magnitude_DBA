
-- =============================================
-- Author:		<Author,,ADMIN>
-- Create date: <Create Date,, 27 May 2015>
-- Description:	<Description,,GetSupplierTypeAll>
-- Call SP    :	GetSupplierTypeAll
-- =============================================
CREATE PROCEDURE [dbo].[GetSupplierTypeAll]
	@UserID INT
AS
BEGIN

		DECLARE	@AdminRole bigint ,
			@UserRole bigint ,
			@PageID bigint;

		SELECT TOP 1 @AdminRole = Id FROM [dbo].[Role] WHERE RoleName = 'Admin'
		SELECT TOP 1 @UserRole = RoleId FROM dbo.[User] WHERE Id = @UserId
		SELECT TOP 1 @PageID = Id FROM dbo.Page WHERE PageName = 'SupplierType'

		IF @AdminRole = @UserRole
		BEGIN

			SELECT  dbo.[SupplierType].[Id] AS Id , 
					dbo.[SupplierType].[SupplierTypeName] AS SupplierTypeName , 
					dbo.[SupplierType].[AboutSupplierType] AS AboutSupplierType  
			FROM dbo.[SupplierType] 
			 WHERE dbo.[SupplierType].IsDeleted = 0

		END
		ELSE
		BEGIN

			SELECT  dbo.[SupplierType].[Id] AS Id , 
					dbo.[SupplierType].[SupplierTypeName] AS SupplierTypeName , 
					dbo.[SupplierType].[AboutSupplierType] AS AboutSupplierType  
			FROM dbo.[SupplierType] 
			INNER JOIN dbo.UserRolePermissions ON dbo.UserRolePermissions.PageID = @PageID
				AND dbo.UserRolePermissions.ActualID = dbo.SupplierType.Id
				AND dbo.UserRolePermissions.UserID = @UserID
			WHERE dbo.[SupplierType].IsDeleted = 0
		END
END