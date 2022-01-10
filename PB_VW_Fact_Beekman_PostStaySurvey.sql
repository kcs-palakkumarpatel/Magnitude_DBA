﻿


CREATE View [dbo].[PB_VW_Fact_Beekman_PostStaySurvey] as

select EstablishmentName,CapturedDate,ReferenceNo,IsPositive,Status,PI,FirstActionDate,ResolvedDate,Longitude,Latitude,AutoResolved,
[Overall],
[Staff],
[Do you want to men],
[Facilities],
[Areas],
[We would like to h],
[Cleanliness],
[Comfort],
[Contact],
isnull([Please comment on],'') as[Please comment on],
isnull([Full Name],'') as [Full Name] from(
select
E.EstablishmentName,dateadd(MINUTE,AM.TimeOffSet,AM.CreatedOn) as CapturedDate,AM.id as ReferenceNo,
AM.IsPositive,AM.IsResolved as Status,AM.PI,

 case when (A.Detail='Poor') then '1' when (A.Detail='Average') then '2' when (A.Detail='Good') then '3' when (A.Detail='Very Good') then '4' when (A.Detail='Excellent' ) then '5' else A.Detail end as Answer

,Q.ShortName as Question ,--U.id as UserId, u.name as UserName,
FAD.FirstActionDate,case when AM.Narration like '%Auto Resolved %' then dateadd(MINUTE,AM.TimeOffSet,AM.CreatedOn) else  RD.ResolvedDate end As ResolvedDate,


AM.Longitude, AM.Latitude,case when AM.Narration is null then 0 else 1 end as AutoResolved

from dbo.[Group] G
inner join EstablishmentGroup EG on G.id=EG.groupid
inner join Establishment E on  E.EstablishmentGroupId=EG.Id
inner join AnswerMaster AM on AM.EstablishmentId=E.id
inner join [Answers] A on A.AnswerMasterId=AM.id
inner join Questions Q on Q.id=A.QuestionId
--left outer join dbo.[Appuser] u on u.id=AM.CreatedBy
--left outer join SeenClientAnswerChild SAC on AM.id=SAC.SeenClientAnswerMasterId 
Left Outer Join (
	Select CLA.AnswerMasterid as ReferenceNo,max(dateadd(MINUTE,TimeOffSet,CLA.CreatedOn)) as ResolvedDate from 
	CloseLoopAction CLA 
	right outer join answermaster SAM on SAM.Id=CLA.AnswerMasterId
	Where (Conversation Like '%Resolved - Ref#%' or Conversation Like 'Resolved')
	And Conversation Not Like '%UnResolve%' and SAM.Isresolved='Resolved'
	and SAM.isresolved='Resolved'
	group by CLA.AnswerMasterId
	) as RD on rD.ReferenceNo = Am.Id


	Left Outer Join (
	Select CLA.AnswerMasterid as ReferenceNo,min(dateadd(MINUTE,TimeOffSet,CLA.CreatedOn)) as FirstActionDate from 
	CloseLoopAction CLA 
	right outer join answermaster SAM on SAM.Id=CLA.AnswerMasterId
	where Conversation Not Like '%Resolved%'
	group by CLA.AnswerMasterId
	) as FAD on FAD.ReferenceNo = AM.Id

Where (G.Id=488 and EG.Id =4801
ANd (AM.IsDeleted=0 or AM.IsDeleted=null)) 
and Q.IsRequiredInBI=1--Q.id in (23799,23800,23811,23801,23812,23813,23802,23803,23838,23809,23677)
)S
pivot(
Max(Answer)
For  Question In (
[Overall],
[Staff],
[Do you want to men],
[Facilities],
[Areas],
[We would like to h],
[Cleanliness],
[Comfort],
[Contact],
[Please comment on],
[Full Name]
))P
