
create view PB_VW_SOG_Fact_WeeklyCheck as
select A.*,B.ResponseDate,
B.Satisfied from
(
select 
EstablishmentName,
CapturedDate,
Status,
ReferenceNo,
UserName,
[Sprinkler Jockey],
[Sprinkler Pump],
[Diesel level OK],
[Fire Panel 1 OK],
[Fire Panel 2 OK],
[Fire Panel 3 OK],
[Electric Fence OK],
[Fire Equipment],
[Fire Equipment Out],
[F.E Service >30],
[Comment],
[Panic System Test],
[Change Rooms Neat],
[Fire Passages],
[Fire Doors In Tact],
[Additional Comment],
ResolvedDate

from(
select  E.EstablishmentName,dateadd(MINUTE,AM.TimeOffSet,AM.CreatedOn) as CapturedDate,AM.id as ReferenceNo,
AM.IsPositive,AM.IsResolved as Status,AM.PI,
A.Detail as Answer
,Q.shortname as Question ,U.Id as UserId, u.name as UserName,RD.ResolvedDate


from dbo.[Group] G
inner join EstablishmentGroup EG on G.id=EG.groupid
inner join Establishment E on  E.EstablishmentGroupId=EG.Id
inner join SeenClientAnswerMaster AM on AM.EstablishmentId=E.id
inner join [SeenClientAnswers] A on A.SeenclientAnswerMasterId=AM.id
inner join SeenClientQuestions Q on Q.id=A.QuestionId
left outer join dbo.[Appuser] u on u.id=AM.CreatedBy
Left Outer Join (
	Select CLA.SeenClientAnswerMasterid as ReferenceNo,max(dateadd(MINUTE,TimeOffSet,CLA.CreatedOn)) as ResolvedDate from 
	CloseLoopAction CLA 
	right outer join seenclientanswermaster SAM on SAM.Id=CLA.SeenClientAnswerMasterId
	Where (Conversation Like '%Resolved - Ref#%' or Conversation Like 'Resolved')
	And Conversation Not Like '%UnResolve%' and SAM.Isresolved='Resolved'
	and SAM.isresolved='Resolved'
	group by CLA.SeenClientAnswerMasterId
	) as RD on rD.ReferenceNo = Am.Id
Where (G.Id=487 and EG.Id =4843 --and u.id not in (3722,3973)
ANd (AM.IsDeleted=0 or AM.IsDeleted=null)) and (AM.IsDisabled=0 or AM.IsDisabled is null)
and Q.id in(36454,36455,36456,36457,36458,36459,36460,36462,36463,36464,36465,36466,36467,36468,36470,36471)

) S
Pivot (
Max(Answer)
For  Question In (
[Sprinkler Jockey],
[Sprinkler Pump],
[Diesel level OK],
[Fire Panel 1 OK],
[Fire Panel 2 OK],
[Fire Panel 3 OK],
[Electric Fence OK],
[Fire Equipment],
[Fire Equipment Out],
[F.E Service >30],
[Comment],
[Panic System Test],
[Change Rooms Neat],
[Fire Passages],
[Fire Doors In Tact],
[Additional Comment]
))P
) A
left outer join 
(


select  E.EstablishmentName,dateadd(MINUTE,AM.TimeOffSet,AM.CreatedOn) as ResponseDate,AM.id as ReferenceNo,
AM.IsPositive,AM.IsResolved as Status,AM.PI,Am.SeenClientAnswerMasterId,
A.Detail as Satisfied
from dbo.[Group] G
inner join EstablishmentGroup EG on G.id=EG.groupid
inner join Establishment E on  E.EstablishmentGroupId=EG.Id
inner join AnswerMaster AM on AM.EstablishmentId=E.id
inner join [Answers] A on A.AnswerMasterId=AM.id
inner join Questions Q on Q.id=A.QuestionId
Where (G.Id=487 and EG.Id =4843 --and u.id not in (3722,3973)
ANd (AM.IsDeleted=0 or AM.IsDeleted=null)) and (AM.IsDisabled=0 or AM.IsDisabled is null)
and Q.id =23886


) B on A.ReferenceNo=B.SeenClientAnswerMasterId

