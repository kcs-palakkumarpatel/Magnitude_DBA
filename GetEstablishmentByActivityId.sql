-- =============================================
-- Author:		GetEstablishmentByActivityId
-- Create date: 
-- Description:	
-- =============================================
CREATE PROCEDURE [dbo].[GetEstablishmentByActivityId] 
	-- Add the parameters for the stored procedure here
	@ActivityId BIGINT
AS
BEGIN
	SELECT id,EstablishmentName FROM dbo.Establishment WHERE EstablishmentGroupId = @ActivityId
END