create view PB_VW_AA_Fact_ProjectTracking
as 




Select DISTINCT X.*,Y.ResponseDate,Y.ReferenceNo as ResponseReference,
Y.Department from(
select 
EstablishmentName,CapturedDate,ReferenceNo,Status,
UserName,
[Client name],
[Order Confirmation],
[Region | Client],
[Project Name],
[Num Learners],
[Client Status],
[Contact Person],
[Total Number of Le],
[Requirement],
[Venue],
[Qualification],
[Comments],
[Total Cost]
from(
select
E.EstablishmentName,dateadd(MINUTE,AM.TimeOffSet,AM.CreatedOn) as CapturedDate,AM.id as ReferenceNo,
A.Detail as Answer,AM.Isresolved as Status

,Q.shortname as Question , u.name as UserName,
(select top 1 detail from ContactDetails CD Where CD.ContactMasterId=AM.ContactMasterId and CD.ContactQuestionid=3086 and CD.IsDeleted=0)as [Total Beds in Room]

from dbo.[Group] G
inner join EstablishmentGroup EG on G.id=EG.groupid and G.Id=507 and EG.Id =5227
inner join Establishment E on  E.EstablishmentGroupId=EG.Id 
inner join SeenClientAnswerMaster AM on AM.EstablishmentId=E.id ANd (AM.IsDeleted=0 or AM.IsDeleted=null)
inner join [SeenClientAnswers] A on A.SeenclientAnswerMasterId=AM.id
inner join SeenClientQuestions Q on Q.id=A.QuestionId and  Q.id in (41557,41210,41211,41212,41213,42369,42370,42382,42383,42384,42385,42386,44342,64283,61329,69906)
left outer join dbo.[Appuser] u on u.id=AM.CreatedBy
)S
pivot(
Max(Answer)
For  Question In (
[Client name],
[Order Confirmation],
[Region | Client],
[Project Name],
[Num Learners],
[Client Status],
[Contact Person],
[Total Number of Le],
[Requirement],
[Venue],
[Qualification],
[Comments],
[Total Cost]
))P
) X
left outer join


(
select
E.EstablishmentName,dateadd(MINUTE,AM.TimeOffSet,AM.CreatedOn) as ResponseDate,AM.id as ReferenceNo,
AM.SeenClientAnswerMasterId,
A.Detail as Department,AM.Isresolved as Status

from dbo.[Group] G
inner join EstablishmentGroup EG on G.id=EG.groupid and G.Id=507 and EG.Id =5227
inner join Establishment E on  E.EstablishmentGroupId=EG.Id 
inner join AnswerMaster AM on AM.EstablishmentId=E.id ANd (AM.IsDeleted=0 or AM.IsDeleted=null)
inner join [Answers] A on A.AnswerMasterId=AM.id
inner join Questions Q on Q.id=A.QuestionId and  Q.id=27298

) Y on X.ReferenceNo=Y.SeenclientAnswerMasterid




