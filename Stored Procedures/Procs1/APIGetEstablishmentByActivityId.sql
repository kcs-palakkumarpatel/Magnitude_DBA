-- =============================================
-- Author:		APIGetEstablishmentByActivityId
-- Create date: 
-- Description:	
-- =============================================
CREATE PROCEDURE [dbo].[APIGetEstablishmentByActivityId] 
	-- Add the parameters for the stored procedure here
	@ActivityId BIGINT
AS
BEGIN
	SELECT id as EstablishmentId,EstablishmentName FROM dbo.Establishment WHERE EstablishmentGroupId = @ActivityId
END
