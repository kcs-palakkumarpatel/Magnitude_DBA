-- =============================================
-- Author:		GetEstablishmentByActivityId
-- Create date: 
-- Description:	
-- Call: GetEstablishmentByActivityIdForContactRole '427,429'
-- =============================================
CREATE PROCEDURE dbo.GetEstablishmentByActivityIdForContactRole
	-- Add the parameters for the stored procedure here
	@ActivityId NVARCHAR(500)
AS
BEGIN
	SELECT id,EstablishmentName FROM dbo.Establishment WHERE EstablishmentGroupId IN (SELECT data FROM dbo.Split(@ActivityId,',')) AND IsDeleted = 0
END