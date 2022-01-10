
-- =============================================
-- Author:		<Author,,ADMIN>
-- Create date: <Create Date,, 26 May 2015>
-- Description:	<Description,,CountSupplier>
-- Call SP    :	CountSupplier
-- =============================================
CREATE PROCEDURE [dbo].[CountSupplier]
AS
BEGIN
SELECT COUNT(1) as Result FROM dbo.[Supplier] 
 WHERE IsDeleted = 0
END