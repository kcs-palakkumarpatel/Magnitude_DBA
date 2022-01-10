
CREATE VIEW [dbo].[PB_VW_WorkForceStaffing_Fact_FollowUp]
AS





SELECT X.*,Y.ResponseDate,Y.ReferenceNo AS ResponseRef,
[Happy With Service],
[Why are you unhapp],
[Requirements Met],
[Not Met]
FROM(

SELECT 
EstablishmentName,CapturedDate,ReferenceNo,Status,
UserName,[User],
[Type of Follow Up],
[Time taken],
[Type of account],
[Today you met with the],
[How is your relationship with the client?],
[Reason for the meeting?],
[Have you quoted the client?],
[If Yes, What amount was quoted per month],
[Company],
[Industry]
FROM(
SELECT
E.EstablishmentName,DATEADD(MINUTE,AM.TimeOffSet,AM.CreatedOn) AS CapturedDate,AM.id AS ReferenceNo,
A.Detail AS Answer,AM.Isresolved AS Status

,Q.QuestionTitle AS Question , u.name AS UserName,u.UserName AS [User]

FROM dbo.[Group] G
INNER JOIN EstablishmentGroup EG ON G.id=EG.groupid AND G.Id=494 AND EG.Id =5109
INNER JOIN Establishment E ON  E.EstablishmentGroupId=EG.Id --and E.id in (27195,27196,27200,27199)
INNER JOIN SeenClientAnswerMaster AM ON AM.EstablishmentId=E.id AND (AM.IsDeleted=0 OR AM.IsDeleted=NULL)
INNER JOIN [SeenClientAnswers] A ON A.SeenclientAnswerMasterId=AM.id
INNER JOIN SeenClientQuestions Q ON Q.id=A.QuestionId AND  Q.id IN 
(44233,40213,40214,40215,40216,40217,40218,41116,40210,50470)
LEFT OUTER JOIN dbo.[Appuser] u ON u.id=AM.CreatedBy
)S
PIVOT(
MAX(Answer)
FOR  Question IN (
[Type of Follow Up],
[Time taken],
[Type of account],
[Today you met with the],
[How is your relationship with the client?],
[Reason for the meeting?],
[Have you quoted the client?],
[If Yes, What amount was quoted per month],
[Company],
[Industry]
))P
) X
LEFT OUTER JOIN

(
SELECT 
EstablishmentName,ResponseDate,ReferenceNo,SeenClientAnswerMasterId,
[Happy With Service],
[Why are you unhapp],
[Requirements Met],
[Not Met]
FROM(
SELECT
E.EstablishmentName,DATEADD(MINUTE,AM.TimeOffSet,AM.CreatedOn) AS ResponseDate,AM.id AS ReferenceNo,
AM.SeenClientAnswerMasterId,
A.Detail AS Answer,

Q.shortname AS Question 
FROM dbo.[Group] G
INNER JOIN EstablishmentGroup EG ON G.id=EG.groupid AND G.Id=494 AND EG.Id =5109
INNER JOIN Establishment E ON  E.EstablishmentGroupId=EG.Id --and E.id in (27195,27196,27200,27199)
INNER JOIN AnswerMaster AM ON AM.EstablishmentId=E.id AND (AM.IsDeleted=0 OR AM.IsDeleted=NULL)
INNER JOIN [Answers] A ON A.AnswerMasterId=AM.id
INNER JOIN Questions Q ON Q.id=A.QuestionId AND  Q.id IN (26684,26685,26686,26687)
)S
PIVOT(
MAX(Answer)
FOR  Question IN (
[Happy With Service],
[Why are you unhapp],
[Requirements Met],
[Not Met]
))P
) Y ON X.ReferenceNo=Y.SeenclientAnswerMasterid



