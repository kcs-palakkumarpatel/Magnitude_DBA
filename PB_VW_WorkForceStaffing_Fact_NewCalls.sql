CREATE VIEW [dbo].[PB_VW_WorkForceStaffing_Fact_NewCalls]
AS





SELECT X.*,Y.ResponseDate,Y.ReferenceNo AS ResponseRef,
[Understand Value],
[Value Not Clear],
[Met Requirements],
[Why not]
FROM(

SELECT 
EstablishmentName,CapturedDate,ReferenceNo,Status,
UserName,[User],
[Call Type],
[Who have you spoken with?],
[Do they need staff],
[If yes, what staff do they need?],
[Do they belong to a council?],
[Which council do they belong to?],
[Estimate Monthly Revenue],
[Did you secure an appointment],
[Company],
[Industry]
FROM(
SELECT
E.EstablishmentName,DATEADD(MINUTE,AM.TimeOffSet,AM.CreatedOn) AS CapturedDate,AM.id AS ReferenceNo,
A.Detail AS Answer,AM.Isresolved AS Status

,Q.QuestionTitle AS Question , u.name AS UserName,u.UserName AS [User]

FROM dbo.[Group] G
INNER JOIN EstablishmentGroup EG ON G.id=EG.groupid AND G.Id=494 AND EG.Id =5111
INNER JOIN Establishment E ON  E.EstablishmentGroupId=EG.Id --and E.id in (27195,27196,27200,27199)
INNER JOIN SeenClientAnswerMaster AM ON AM.EstablishmentId=E.id AND (AM.IsDeleted=0 OR AM.IsDeleted=NULL)
INNER JOIN [SeenClientAnswers] A ON A.SeenclientAnswerMasterId=AM.id
INNER JOIN SeenClientQuestions Q ON Q.id=A.QuestionId AND  Q.id IN 
(41114,40233,40234,40235,40236,40237,41115,44234,50469,40230,40241,50263)
LEFT OUTER JOIN dbo.[Appuser] u ON u.id=AM.CreatedBy
)S
PIVOT(
MAX(Answer)
FOR  Question IN (
[Call Type],
[Who have you spoken with?],
[Do they need staff],
[If yes, what staff do they need?],
[Do they belong to a council?],
[Which council do they belong to?],
[Estimate Monthly Revenue],
[Did you secure an appointment],
[Company],
[Industry]
))P
) X
LEFT OUTER JOIN

(
SELECT 
EstablishmentName,ResponseDate,ReferenceNo,SeenClientAnswerMasterId,
[Understand Value],
[Value Not Clear],
[Met Requirements],
[Why not]
FROM(
SELECT
E.EstablishmentName,DATEADD(MINUTE,AM.TimeOffSet,AM.CreatedOn) AS ResponseDate,AM.id AS ReferenceNo,
AM.SeenClientAnswerMasterId,
A.Detail AS Answer,

Q.shortname AS Question 
FROM dbo.[Group] G
INNER JOIN EstablishmentGroup EG ON G.id=EG.groupid AND G.Id=494 AND EG.Id =5111
INNER JOIN Establishment E ON  E.EstablishmentGroupId=EG.Id --and E.id in (27195,27196,27200,27199)
INNER JOIN AnswerMaster AM ON AM.EstablishmentId=E.id AND (AM.IsDeleted=0 OR AM.IsDeleted=NULL)
INNER JOIN [Answers] A ON A.AnswerMasterId=AM.id
INNER JOIN Questions Q ON Q.id=A.QuestionId AND  Q.id IN (26695,27281,26697,26696)
)S
PIVOT(
MAX(Answer)
FOR  Question IN (
[Understand Value],
[Value Not Clear],
[Met Requirements],
[Why not]
))P
) Y ON X.ReferenceNo=Y.SeenclientAnswerMasterid



