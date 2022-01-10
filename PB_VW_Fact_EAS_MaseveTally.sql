

create view PB_VW_Fact_EAS_MaseveTally as


select 
EstablishmentName,CapturedDate,ReferenceNo,
UserName,
[Date],
[WALL FILL (cbm)],
[LINED AREA (sqm)],
[DRAIN (m)],
[PEN-STOCK PIPE (m)],
[PEN-STOCK LIFT(no)],
[Any issues],
[Provide Details],
[Issue Category]
from(
select
E.EstablishmentName,dateadd(MINUTE,AM.TimeOffSet,AM.CreatedOn) as CapturedDate,AM.id as ReferenceNo,
A.Detail as Answer

,Q.shortname as Question ,U.id as UserId, u.name as UserName

from dbo.[Group] G
inner join EstablishmentGroup EG on G.id=EG.groupid
inner join Establishment E on  E.EstablishmentGroupId=EG.Id
inner join SeenClientAnswerMaster AM on AM.EstablishmentId=E.id
inner join [SeenClientAnswers] A on A.SeenclientAnswerMasterId=AM.id
inner join SeenClientQuestions Q on Q.id=A.QuestionId
left outer join dbo.[Appuser] u on u.id=AM.CreatedBy
Where (G.Id=512 and EG.Id =5413
ANd (AM.IsDeleted=0 or AM.IsDeleted=null)) --and (AM.IsDisabled=0 or AM.IsDisabled is null)
and  Q.id in (43740,43741,43920,43742,43743,43744,43745,44609,44610)

)S
pivot(
Max(Answer)
For  Question In (
[Date],
[WALL FILL (cbm)],
[LINED AREA (sqm)],
[DRAIN (m)],
[PEN-STOCK PIPE (m)],
[PEN-STOCK LIFT(no)],
[Any issues],
[Provide Details],
[Issue Category]
))P
