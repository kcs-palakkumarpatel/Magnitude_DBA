
-- =============================================
-- Author:		<Author,,ADMIN>
-- Create date: <Create Date,, 26 May 2015>
-- Description:	<Description,,GetSupplierById>
-- Call SP    :	GetSupplierById
-- =============================================
CREATE PROCEDURE [dbo].[GetSupplierById]
@Id BIGINT
AS
BEGIN
SELECT  [Id] AS Id, [SupplierTypeId] AS SupplierTypeId, [SupplierName] AS SupplierName, [SupplierAddress] AS SupplierAddress, [SupplierEmail] AS SupplierEmail, [SupplierMobile] AS SupplierMobile, [AboutSupplier] AS AboutSupplier FROM dbo.[Supplier] WHERE [Id] = @Id
END