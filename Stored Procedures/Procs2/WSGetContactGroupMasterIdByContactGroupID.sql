CREATE PROCEDURE [dbo].[WSGetContactGroupMasterIdByContactGroupID]   
(  
@ContactGroupId INT = NULL,
@ContactMasterId INT = NULL

)  
AS  
BEGIN  
  
  IF @ContactGroupId = 0
  SET @ContactGroupId = NULL
  IF @ContactMasterId = 0
  SET @ContactMasterId = NULL
  
SELECT CM.Id FROM dbo.ContactMaster CM  
INNER JOIN dbo.ContactGroupRelation  CGR ON CM.Id = CGR.ContactMasterId  
WHERE 
		CGR.ContactGroupId  =COALESCE(@ContactGroupId,cgr.ContactGroupId)
		AND CM.Id =COALESCE(@ContactMasterId,CM.Id)
  
  
END