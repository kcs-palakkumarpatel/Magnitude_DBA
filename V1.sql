CREATE VIEW V1
As
SELECT DISTINCT CD.ContactMasterId, ISNULL(CD.Detail,'') AS Detail,CQ.Position
FROM (
	SELECT  Id,CreatedBy FROM dbo.ContactMaster
	UNION ALL
	SELECT  Id,UpdatedBy FROM dbo.ContactMaster  WHERE UpdatedBy IS NOT NULL
) AS CM 
INNER JOIN dbo.ContactDetails AS CD ON CD.ContactMasterId = CM.Id
INNER JOIN dbo.ContactQuestions	AS CQ ON CQ.Id = CD.ContactQuestionId
INNER JOIN dbo.AppUserContactRole AS ac ON CM.CreatedBy = ac.AppUserId AND ac.AppUserId = 551 AND ac.IsDeleted = 0
INNER JOIN dbo.ContactRoleDetails AS crd ON crd.ContactRoleId = ac.ContactRoleId AND  crd.AppEstablishmentUserId = CM.CreatedBy
WHERE CM.CreatedBy = 551
AND CD.IsDeleted = 0
AND CQ.IsDeleted = 0
AND CQ.IsDisplayInSummary = 1
AND CD.Detail <> ''
