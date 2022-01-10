
-- =============================================
-- Author:		<Author,,ADMIN>
-- Create date: <Create Date,, 27 May 2015>
-- Description:	<Description,,CountSupplierType>
-- Call SP    :	CountSupplierType
-- =============================================
CREATE PROCEDURE [dbo].[CountSupplierType]
AS
BEGIN
SELECT COUNT(1) as Result FROM dbo.[SupplierType] 
 WHERE IsDeleted = 0
END