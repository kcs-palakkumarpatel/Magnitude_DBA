-- =============================================
-- Author: Matthew Grinaker	
-- Create date:			2020/03/30
-- Description:		Find ContactMasterId using GroupID, Email, 
-- Call SP:			fn_IsContactGroupExistsByContactMasterIds 4557
-- =============================================
CREATE FUNCTION [dbo].[fn_IsContactGroupExistsByContactMasterIds]
(  
@strContactMasterID NVARCHAR(MAX)
)  
RETURNS BIGINT
AS  
BEGIN  
 DECLARE @NewContactGroupID BIGINT;
  DECLARE @GroupCount INT;
  SET @GroupCount = (SELECT COUNT(DATA )FROM  dbo.Split(@strContactMasterID, ','));

SET @NewContactGroupID = (SELECT TOP 1 ContactGroupId FROM ( 
Select ContactGroupId, count(ContactGroupId) AS AA from ContactGroupRelation where isdeleted = 0 and ContactGroupId IN (
Select DISTINCT ContactGroupId as CustGroupID from 
(
Select DISTINCT ContactGroupId, count(ContactGroupId) as GroupUserCount from ContactGroupRelation where IsDeleted = 0 group by ContactGroupId
) as A where GroupUserCount = @GroupCount and IsDeleted = 0 group by ContactGroupId
) AND ContactMasterID IN (SELECT DATA FROM  dbo.Split(@strContactMasterID, ',')) group by ContactGroupId  )  AS b WHERE AA = @GroupCount 
ORDER BY ContactGroupId DESC)

RETURN ISNULL(@NewContactGroupID,0);

END;
