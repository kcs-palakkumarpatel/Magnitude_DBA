
CREATE VIEW [dbo].[PB_VW_WorkForceStaffing_Fact_LeadAllocation]
AS


SELECT X.*,Y.ResponseDate,Y.ReferenceNo AS ResponseRef,
[Lead Status],
[Unqualified Reason],
[Meeting Date],
[Next Steps],
[Comments],
[Attachments]
FROM(

SELECT 
EstablishmentName,CapturedDate,ReferenceNo,Status,
UserName,[User],LeadRecievedByUser,
[Company Name],
[Contact details],
[Designation],
[Contact Person Full Name],
[E-Mail],
[Mobile],
[Landline],
[Preferred Communication],
[Staffing Requirement],
[Attach the Spec or PDF Export of the lead logged],
[Date Required (Start)],
[Date Required To (End)]
FROM(
SELECT
E.EstablishmentName,DATEADD(MINUTE,AM.TimeOffSet,AM.CreatedOn) AS CapturedDate,AM.id AS ReferenceNo,
A.Detail AS Answer,AM.Isresolved AS Status

,Q.QuestionTitle AS Question , u.name AS UserName,u.UserName AS [User],
(SELECT TOP 1 detail FROM ContactDetails CD WHERE CD.ContactMasterid=(CASE WHEN AM.IsSubmittedForGroup=1 THEN SAC.ContactMasterId ELSE AM.ContactMasterId END) AND CD.detail<>'' AND CD.Isdeleted=0 AND CD.ContactQuestionid=2997) +' '+ (SELECT TOP 1 detail FROM ContactDetails CD WHERE CD.ContactMasterid=(CASE WHEN AM.IsSubmittedForGroup=1 THEN SAC.ContactMasterId ELSE AM.ContactMasterId END) AND CD.detail<>'' AND CD.Isdeleted=0 AND CD.ContactQuestionid=2998)AS LeadRecievedByUser
FROM dbo.[Group] G
INNER JOIN EstablishmentGroup EG ON G.id=EG.groupid AND G.Id=494 AND EG.Id =4901
INNER JOIN Establishment E ON  E.EstablishmentGroupId=EG.Id --and E.id in (27195,27196,27200,27199)
INNER JOIN SeenClientAnswerMaster AM ON AM.EstablishmentId=E.id AND (AM.IsDeleted=0 OR AM.IsDeleted=NULL)
INNER JOIN [SeenClientAnswers] A ON A.SeenclientAnswerMasterId=AM.id
INNER JOIN SeenClientQuestions Q ON Q.id=A.QuestionId AND  Q.id IN (37124,37113,37117,37114,37115,37116,37119,37118,37120,37121,37122,37123)
LEFT OUTER JOIN SeenclientAnswerChild SAC ON SAC.SeenClientAnswerMasterId=AM.id
LEFT OUTER JOIN dbo.[Appuser] u ON u.id=AM.CreatedBy
)S
PIVOT(
MAX(Answer)
FOR  Question IN (
[Company Name],
[Contact details],
[Designation],
[Contact Person Full Name],
[E-Mail],
[Mobile],
[Landline],
[Preferred Communication],
[Staffing Requirement],
[Attach the Spec or PDF Export of the lead logged],
[Date Required (Start)],
[Date Required To (End)]
))P
) X
LEFT OUTER JOIN

(
SELECT 
EstablishmentName,ResponseDate,ReferenceNo,SeenClientAnswerMasterId,
[Lead Status],
[Unqualified Reason],
[Meeting Date],
[Next Steps],
[Comments],
[Attachments]
FROM(
SELECT
E.EstablishmentName,DATEADD(MINUTE,AM.TimeOffSet,AM.CreatedOn) AS ResponseDate,AM.id AS ReferenceNo,
AM.SeenClientAnswerMasterId,
A.Detail AS Answer,

Q.shortname AS Question 
FROM dbo.[Group] G
INNER JOIN EstablishmentGroup EG ON G.id=EG.groupid AND G.Id=494 AND EG.Id =4901
INNER JOIN Establishment E ON  E.EstablishmentGroupId=EG.Id --and E.id in (27195,27196,27200,27199)
INNER JOIN AnswerMaster AM ON AM.EstablishmentId=E.id AND (AM.IsDeleted=0 OR AM.IsDeleted=NULL)
INNER JOIN [Answers] A ON A.AnswerMasterId=AM.id
INNER JOIN Questions Q ON Q.id=A.QuestionId AND  Q.id IN (24584,24585,24587,24588,24591,24590)
)S
PIVOT(
MAX(Answer)
FOR  Question IN (
[Lead Status],
[Unqualified Reason],
[Meeting Date],
[Next Steps],
[Comments],
[Attachments]
))P
) Y ON X.ReferenceNo=Y.SeenclientAnswerMasterid



