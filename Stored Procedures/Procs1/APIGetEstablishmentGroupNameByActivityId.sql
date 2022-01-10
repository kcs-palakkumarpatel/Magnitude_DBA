-- =============================================
-- Author:		APIGetEstablishmentByActivityId
-- Create date: 
-- Description:	
-- =============================================
CREATE PROCEDURE [dbo].[APIGetEstablishmentGroupNameByActivityId] 
	-- Add the parameters for the stored procedure here
	@ActivityId BIGINT
AS
BEGIN
	Select EstablishmentGroupName from EstablishmentGroup where Id = @ActivityId
END