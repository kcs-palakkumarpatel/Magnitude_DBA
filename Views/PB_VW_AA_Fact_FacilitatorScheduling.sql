create view PB_VW_AA_Fact_FacilitatorScheduling
as 



SELECT DISTINCT  X.*,Y.ResponseDate,Y.ReferenceNo as ResponseReference,
Y.[Students In class],
Y.[students absent] from(
select 
EstablishmentName,CapturedDate,ReferenceNo,Status,
UserName,
[Date Time of class],
[Location],
[Project name/Level],
[No. of students],
StatusDateTime, StatusName
from(
select
E.EstablishmentName,dateadd(MINUTE,AM.TimeOffSet,AM.CreatedOn) as CapturedDate,AM.id as ReferenceNo,
A.Detail as Answer,AM.Isresolved as Status

,Q.shortname as Question , u.name as UserName,
(select top 1 detail from ContactDetails CD Where CD.ContactMasterId=AM.ContactMasterId and CD.ContactQuestionid=3086 and CD.IsDeleted=0)as [Total Beds in Room]
,SH.StatusDateTime,  es.StatusName
from dbo.[Group] G
inner join EstablishmentGroup EG on G.id=EG.groupid and G.Id=507 and EG.Id =5907
inner join Establishment E on  E.EstablishmentGroupId=EG.Id 
inner join SeenClientAnswerMaster AM on AM.EstablishmentId=E.id ANd (AM.IsDeleted=0 or AM.IsDeleted=null)
inner join [SeenClientAnswers] A on A.SeenclientAnswerMasterId=AM.id
inner join SeenClientQuestions Q on Q.id=A.QuestionId and  Q.id in (48855,48856,48857,48858)
left outer join dbo.[Appuser] u on u.id=AM.CreatedBy
left outer join StatusHistory SH on SH.id=AM.StatusHistoryId
left outer join establishmentstatus es on sh.establishmentstatusid=es.id
)S
pivot(
Max(Answer)
For  Question In (
[Date Time of class],
[Location],
[Project name/Level],
[No. of students]
))P
) X
left outer join
(select * from

(
select
E.EstablishmentName,dateadd(MINUTE,AM.TimeOffSet,AM.CreatedOn) as ResponseDate,AM.id as ReferenceNo,
AM.SeenClientAnswerMasterId,
A.Detail as Answer,Q.shortname as Question, AM.Isresolved as Status

from dbo.[Group] G
inner join EstablishmentGroup EG on G.id=EG.groupid and G.Id=507 and EG.Id =5907
inner join Establishment E on  E.EstablishmentGroupId=EG.Id 
inner join AnswerMaster AM on AM.EstablishmentId=E.id ANd (AM.IsDeleted=0 or AM.IsDeleted=null)
inner join [Answers] A on A.AnswerMasterId=AM.id
inner join Questions Q on Q.id=A.QuestionId and  Q.id in(33540,33541)
)S
pivot(
Max(Answer)
For  Question In (
[Students In class],
[students absent]
))P
) Y on X.ReferenceNo=Y.SeenclientAnswerMasterid



