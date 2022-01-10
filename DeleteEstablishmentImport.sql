-- =============================================
-- Author:		<Vasu Patel>
-- Create date: <07 Sep 2016>
-- Description:	<Delete Record from EstablishmentImport and start Idntity from 1>
-- =============================================
CREATE PROCEDURE [dbo].[DeleteEstablishmentImport] 
	
AS
BEGIN
		DELETE FROM establishmentimport 
		DBCC CHECKIDENT ('establishmentimport', RESEED, 0)
END