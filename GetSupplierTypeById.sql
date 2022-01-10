
-- =============================================
-- Author:		<Author,,ADMIN>
-- Create date: <Create Date,, 27 May 2015>
-- Description:	<Description,,GetSupplierTypeById>
-- Call SP    :	GetSupplierTypeById
-- =============================================
CREATE PROCEDURE [dbo].[GetSupplierTypeById]
@Id BIGINT
AS
BEGIN
SELECT  [Id] AS Id, [SupplierTypeName] AS SupplierTypeName, [AboutSupplierType] AS AboutSupplierType FROM dbo.[SupplierType] WHERE [Id] = @Id
END