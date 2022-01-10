
-- =============================================
-- Author:		<Author,,ADMIN>
-- Create date: <Create Date,, 26 May 2015>
-- Description:	<Description,,GetSupplierAll>
-- Call SP    :	GetSupplierAll
-- =============================================
CREATE PROCEDURE [dbo].[GetSupplierAll]
AS
BEGIN
SELECT  dbo.[Supplier].[Id] AS Id , dbo.[Supplier].[SupplierTypeId] AS SupplierTypeId , dbo.[SupplierType].SupplierTypeName, dbo.[Supplier].[SupplierName] AS SupplierName , dbo.[Supplier].[SupplierAddress] AS SupplierAddress , dbo.[Supplier].[SupplierEmail] AS SupplierEmail , dbo.[Supplier].[SupplierMobile] AS SupplierMobile , dbo.[Supplier].[AboutSupplier] AS AboutSupplier  FROM dbo.[Supplier] 
INNER JOIN dbo.[SupplierType] ON dbo.[SupplierType].Id = dbo.[Supplier].SupplierTypeId  WHERE dbo.[Supplier].IsDeleted = 0
END