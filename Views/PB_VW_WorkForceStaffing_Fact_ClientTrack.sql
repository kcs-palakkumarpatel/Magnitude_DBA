CREATE VIEW [dbo].[PB_VW_WorkForceStaffing_Fact_ClientTrack]
AS




SELECT X.*,Y.ResponseDate,Y.ReferenceNo AS ResponseRef,
[What stage are we ],
[Comm. Credit App],
[Comments (Quote)],
[Quote],
[Movement Comments],
[Clients Needs],
[Needs Still Req.],
[Headcount Correct],
[Please explain],
[Assignee],
[Supply not on time],
[Client Credentials],
[Group Offerings],
[Comments Confirms],
[All Confirmed],
[Sign Confirmations],
[Closing Reason]
FROM(

SELECT 
EstablishmentName,CapturedDate,ReferenceNo,Status,
UserName,P.[User],
[Industry Sector],
[Company Name],
[Contact Person Name],
[Contact Number (Mobile)],
[Contact Number (Landline)],
[Contact E-Mail],
[Client Address],
[Date Engaged],
[Method of Engagement],
[Contractor Zone Category]
FROM(
SELECT
E.EstablishmentName,DATEADD(MINUTE,AM.TimeOffSet,AM.CreatedOn) AS CapturedDate,
AM.id AS ReferenceNo,
A.Detail AS Answer,AM.Isresolved AS Status

,Q.QuestionTitle AS Question , u.name AS UserName,u.UserName AS [User]

FROM dbo.[Group] G
INNER JOIN EstablishmentGroup EG ON G.id=EG.groupid AND G.Id=494 AND EG.Id =4903
INNER JOIN Establishment E ON  E.EstablishmentGroupId=EG.Id --and E.id in (27195,27196,27200,27199)
INNER JOIN SeenClientAnswerMaster AM ON AM.EstablishmentId=E.id AND (AM.IsDeleted=0 OR AM.IsDeleted=NULL)
INNER JOIN [SeenClientAnswers] A ON A.SeenclientAnswerMasterId=AM.id
INNER JOIN SeenClientQuestions Q ON Q.id=A.QuestionId AND  Q.id IN (37137,37135,37136,37138,37139,37140,37141,37142,37143,37144)
LEFT OUTER JOIN dbo.[Appuser] u ON u.id=AM.CreatedBy
)S
PIVOT(
MAX(Answer)
FOR  Question IN (
[Industry Sector],
[Company Name],
[Contact Person Name],
[Contact Number (Mobile)],
[Contact Number (Landline)],
[Contact E-Mail],
[Client Address],
[Date Engaged],
[Method of Engagement],
[Contractor Zone Category]
))P
) X
LEFT OUTER JOIN

(
SELECT 
EstablishmentName,ResponseDate,ReferenceNo,SeenClientAnswerMasterId,
[What stage are we ],
[Comm. Credit App],
[Comments (Quote)],
[Quote],
[Movement Comments],
[Clients Needs],
[Needs Still Req.],
[Headcount Correct],
[Please explain],
[Assignee],
[Supply not on time],
[Client Credentials],
[Group Offerings],
[Comments Confirms],
[All Confirmed],
[Sign Confirmations],
[Closing Reason]
FROM(
SELECT
E.EstablishmentName,DATEADD(MINUTE,AM.TimeOffSet,AM.CreatedOn) AS ResponseDate,AM.id AS ReferenceNo,
AM.SeenClientAnswerMasterId,
A.Detail AS Answer,

Q.shortname AS Question 
FROM dbo.[Group] G
INNER JOIN EstablishmentGroup EG ON G.id=EG.groupid AND G.Id=494 AND EG.Id =4903
INNER JOIN Establishment E ON  E.EstablishmentGroupId=EG.Id --and E.id in (27195,27196,27200,27199)
INNER JOIN AnswerMaster AM ON AM.EstablishmentId=E.id AND (AM.IsDeleted=0 OR AM.IsDeleted=NULL)
INNER JOIN [Answers] A ON A.AnswerMasterId=AM.id
INNER JOIN Questions Q ON Q.id=A.QuestionId AND  Q.id IN (24634,24635,4637,24638,24639,24640,24641,24642,24643,24644,24645,24646,24647,24648,24649,
24650,24653,24654)
)S
PIVOT(
MAX(Answer)
FOR  Question IN (
[What stage are we ],
[Comm. Credit App],
[Comments (Quote)],
[Quote],
[Movement Comments],
[Clients Needs],
[Needs Still Req.],
[Headcount Correct],
[Please explain],
[Assignee],
[Supply not on time],
[Client Credentials],
[Group Offerings],
[Comments Confirms],
[All Confirmed],
[Sign Confirmations],
[Closing Reason]
))P
) Y ON X.ReferenceNo=Y.SeenclientAnswerMasterid


