
CREATE VIEW [dbo].[PB_VW_LG_Fact_SiteVisitCaptured] AS
SELECT 
EstablishmentName,CapturedDate,ReferenceNo,Status,
UserName,
[Client Name],
[Site address],
[Lead Technician],
[Day of week],
CASE WHEN [Day of week]='Monday' THEN 1 WHEN [Day of week]='Tuesday' THEN 2 WHEN [Day of week]='Wednesday' THEN 1
WHEN [Day of week]='Thursday' THEN 1 WHEN [Day of week]='Friday' THEN 1 ELSE 0 END AS DaySort,
[Which week],
P.Latitude,
P.Longitude
FROM(
SELECT
E.EstablishmentName,DATEADD(MINUTE,AM.TimeOffSet,AM.CreatedOn) AS CapturedDate,AM.id AS ReferenceNo,
A.Detail AS Answer,AM.Isresolved AS Status,AM.Latitude,AM.Longitude

,Q.shortname AS Question ,U.id AS UserId, u.name AS UserName

FROM dbo.[Group] G
INNER JOIN EstablishmentGroup EG ON G.id=EG.groupid AND G.Id=514 AND EG.Id =5829
INNER JOIN Establishment E ON  E.EstablishmentGroupId=EG.Id AND E.id IN (27195,27196,27200,27199)
INNER JOIN SeenClientAnswerMaster AM ON AM.EstablishmentId=E.id
INNER JOIN [SeenClientAnswers] A ON A.SeenclientAnswerMasterId=AM.id
INNER JOIN SeenClientQuestions Q ON Q.id=A.QuestionId
LEFT OUTER JOIN dbo.[Appuser] u ON u.id=AM.CreatedBy
WHERE (G.Id=514 AND EG.Id =5829
AND (AM.IsDeleted=0 OR AM.IsDeleted=NULL)) --and (AM.IsDisabled=0 or AM.IsDisabled is null)
AND  Q.id IN (47708,47709,48363,47711,47712)

)S
PIVOT(
MAX(Answer)
FOR  Question IN (
[Client Name],
[Site address],
[Lead Technician],
[Day of week],
[Which week]
))P
