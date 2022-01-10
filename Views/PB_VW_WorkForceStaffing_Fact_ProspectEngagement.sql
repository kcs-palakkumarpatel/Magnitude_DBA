CREATE VIEW [dbo].[PB_VW_WorkForceStaffing_Fact_ProspectEngagement]
AS




SELECT X.*,Y.ResponseDate,Y.ReferenceNo AS ResponseRef,
[Salesman Rating],
[How can we improve],
[What impressed you],
[Happy with service],
[Why are you unhapp],
[Meet Requirements],
[What did we not me],
[Experience],
[Experience Notes],
[All Solutions],
[Solutions Needed],
[Like Most]
FROM(

SELECT 
EstablishmentName,CapturedDate,ReferenceNo,Status,
UserName,[User],Longitude,Latitude,
[Time taken],
[Today you met with the],
[Meeting perception],
[Have you spotted any additional gaps ?],
[What additional gaps have been spotted?],
[Do you believe you have portrayed the value proposition],
[Validate the above answers],
[Are you facing any resistance?],
[Reasons for resistance],
[Explain the resistance],
[Was the price discussed?],
[What was discussed],
[What transpired in the meeting and next steps agreed?],
[Date for next milestone],
[Company],
[Industry],
[Headcount Estimate]
FROM(
SELECT
E.EstablishmentName,DATEADD(MINUTE,AM.TimeOffSet,AM.CreatedOn) AS CapturedDate,AM.id AS ReferenceNo,
A.Detail AS Answer,AM.Isresolved AS Status

,Q.QuestionTitle AS Question , u.name AS UserName,u.UserName AS [User],AM.Longitude,AM.Latitude

FROM dbo.[Group] G
INNER JOIN EstablishmentGroup EG ON G.id=EG.groupid AND G.Id=494 AND EG.Id =5107
INNER JOIN Establishment E ON  E.EstablishmentGroupId=EG.Id --and E.id in (27195,27196,27200,27199)
INNER JOIN SeenClientAnswerMaster AM ON AM.EstablishmentId=E.id AND (AM.IsDeleted=0 OR AM.IsDeleted=NULL)
INNER JOIN [SeenClientAnswers] A ON A.SeenclientAnswerMasterId=AM.id
INNER JOIN SeenClientQuestions Q ON Q.id=A.QuestionId AND  Q.id IN
 (40188,40189,40190,40191,40192,40193,40194,40195,40196,40197,40198,
 40199,44232,40203,40185,50471,69256,52419)
LEFT OUTER JOIN dbo.[Appuser] u ON u.id=AM.CreatedBy
)S
PIVOT(
MAX(Answer)
FOR  Question IN (
[Time taken],
[Today you met with the],
[Meeting perception],
[Have you spotted any additional gaps ?],
[What additional gaps have been spotted?],
[Do you believe you have portrayed the value proposition],
[Validate the above answers],
[Are you facing any resistance?],
[Reasons for resistance],
[Explain the resistance],
[Was the price discussed?],
[What was discussed],
[What transpired in the meeting and next steps agreed?],
[Date for next milestone],
[Company],
[Industry],
[Headcount Estimate]
))P
) X
LEFT OUTER JOIN

(
SELECT 
EstablishmentName,ResponseDate,ReferenceNo,SeenClientAnswerMasterId,
[Salesman Rating],
[How can we improve],
[What impressed you],
[Happy with service],
[Why are you unhapp],
[Meet Requirements],
[What did we not me],
[Experience],
[Experience Notes],
[All Solutions],
[Solutions Needed],
[Like Most]
FROM(
SELECT
E.EstablishmentName,DATEADD(MINUTE,AM.TimeOffSet,AM.CreatedOn) AS ResponseDate,AM.id AS ReferenceNo,
AM.SeenClientAnswerMasterId,
A.Detail AS Answer,

Q.shortname AS Question 
FROM dbo.[Group] G
INNER JOIN EstablishmentGroup EG ON G.id=EG.groupid AND G.Id=494 AND EG.Id =5107
INNER JOIN Establishment E ON  E.EstablishmentGroupId=EG.Id --and E.id in (27195,27196,27200,27199)
INNER JOIN AnswerMaster AM ON AM.EstablishmentId=E.id AND (AM.IsDeleted=0 OR AM.IsDeleted=NULL)
INNER JOIN [Answers] A ON A.AnswerMasterId=AM.id
INNER JOIN Questions Q ON Q.id=A.QuestionId AND  Q.id IN (29309,29310,29311,26673,26674,26675,26676,29303,29304,29305,29306,29307)
)S
PIVOT(
MAX(Answer)
FOR  Question IN (
[Salesman Rating],
[How can we improve],
[What impressed you],
[Happy with service],
[Why are you unhapp],
[Meet Requirements],
[What did we not me],
[Experience],
[Experience Notes],
[All Solutions],
[Solutions Needed],
[Like Most]
))P
) Y ON X.ReferenceNo=Y.SeenclientAnswerMasterid











