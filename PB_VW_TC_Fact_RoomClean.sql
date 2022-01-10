

Create view PB_VW_TC_Fact_RoomClean as
select 
EstablishmentId,EstablishmentName,CapturedDate,ReferenceNo,Status,
UserName,
[Cleaner Name],
[Type of Clean],
[Planned Beds],
StatusTime,
StatusName,
[Total Beds in Room]
from(
select
E.id as EstablishmentId,E.EstablishmentName,dateadd(MINUTE,AM.TimeOffSet,AM.CreatedOn) as CapturedDate,AM.id as ReferenceNo,
A.Detail as Answer,AM.Isresolved as Status

,Q.shortname as Question , u.name as UserName,sh.StatusDateTime as StatusTime,es.StatusName,
(select top 1 detail from ContactDetails CD Where CD.ContactMasterId=AM.ContactMasterId and CD.ContactQuestionid=3086 and CD.IsDeleted=0)as [Total Beds in Room]

from dbo.[Group] G
inner join EstablishmentGroup EG on G.id=EG.groupid and G.Id=503 and EG.Id =5185
inner join Establishment E on  E.EstablishmentGroupId=EG.Id --and E.id in (27195,27196,27200,27199)
inner join SeenClientAnswerMaster AM on AM.EstablishmentId=E.id ANd (AM.IsDeleted=0 or AM.IsDeleted=null)
inner join [SeenClientAnswers] A on A.SeenclientAnswerMasterId=AM.id
inner join SeenClientQuestions Q on Q.id=A.QuestionId and  Q.id in (42124,44605,44892)
left outer join dbo.[Appuser] u on u.id=AM.CreatedBy
left outer join StatusHistory SH on SH.id=AM.StatusHistoryId
left outer join establishmentstatus es on sh.establishmentstatusid=es.id
 --and (AM.IsDisabled=0 or AM.IsDisabled is null)


)S
pivot(
Max(Answer)
For  Question In (
[Cleaner Name],
[Type of Clean],
[Planned Beds]
))P

