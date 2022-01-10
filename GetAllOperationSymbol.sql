-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[GetAllOperationSymbol] 
	
AS
BEGIN
	SET NOCOUNT ON;
    -- Insert statements for procedure here
	SELECT Id,Symbol FROM dbo.Operation WHERE IsDeleted = 0
END
