-- =============================================
-- Author:		GetEstablishmentByActivityId
-- Create date: 
-- Description:	
-- =============================================
CREATE PROCEDURE [dbo].[GetActivityNameByGroupIdForContactRole]
	-- Add the parameters for the stored procedure here
	@GroupId BIGINT
AS
BEGIN
    	SELECT  Id, EstablishmentGroupName, EstablishmentGroupType
			FROM    dbo.EstablishmentGroup
			WHERE   GroupId = @GroupId AND EstablishmentGroupId IS NOT NULL
					AND IsDeleted = 0
END