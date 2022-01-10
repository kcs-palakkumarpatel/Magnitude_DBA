
create view PB_VW_Fact_LBH_GuestFeedback as
select A.*,B.CapturedDate as ResponseDate,B.SeenClientAnswerMasterId,
B.[Genuine Problem],
B.[What problem],
B.[Permanently fixed],
B.[Describe]
from (

select 
EstablishmentName,CapturedDate,ReferenceNo,IsPositive,Status,
UserId,UserName,
ResolvedDate,AutoResolved,FirstResponseDate,
[Guest Name:],
[Room Number],
[What is the issue?],
[Issue Type],
[Urgency],
[Comment],
IsOutStanding

from(
select
E.EstablishmentName,dateadd(MINUTE,AM.TimeOffSet,AM.CreatedOn) as CapturedDate,AM.id as ReferenceNo,
AM.IsPositive,AM.IsResolved as Status,Am.IsOutStanding,
A.Detail as Answer

,Q.shortname as Question ,U.id as UserId, u.name as UserName,
case when AM.Narration like '%Auto Resolved %' then dateadd(MINUTE,AM.TimeOffSet,AM.CreatedOn) else  RD.ResolvedDate end As ResolvedDate,
case when AM.Narration is null then 0 else 1 end as AutoResolved,
FRD.FirstResponseDate,
--PD.ProgressDate,case when Jd.JobDoneDate> PD.ProgressDate then NULL else JD.JobDoneDate end as JobDoneDate,


AM.Longitude, AM.Latitude

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
	
	Left Outer Join (
	Select AM.SeenClientAnswerMasterid as ReferenceNo,min(dateadd(MINUTE,AM.TimeOffSet,AM.CreatedOn)) as FirstResponseDate from 
	AnswerMaster AM 
	right outer join seenclientanswermaster SAM on SAM.Id=AM.SeenClientAnswerMasterId
	group by AM.SeenClientAnswerMasterId
	) as FRD on FRD.ReferenceNo = AM.Id


Where (G.Id=498 and EG.Id =5003
ANd (AM.IsDeleted=0 or AM.IsDeleted=null)) --and (AM.IsDisabled=0 or AM.IsDisabled is null)
and  Q.id in (38340,38341,38342,38344,38345,38346,38626)

)S
pivot(
Max(Answer)
For  Question In (
[Guest Name:],
[Room Number],
[What is the issue?],
[Issue Type],
[Urgency],
[Comment]))P
)A
left outer join 
(

select 
EstablishmentName,CapturedDate,ReferenceNo,
IsPositive,Status,PI,
[Genuine Problem],
[What problem],
[Permanently fixed],
[Describe],
SeenClientAnswerMasterId

from(
select
E.EstablishmentName,dateadd(MINUTE,AM.TimeOffSet,AM.CreatedOn) as CapturedDate,AM.id as ReferenceNo,
AM.IsPositive,AM.IsResolved as Status,AM.PI,AM.SeenClientAnswerMasterId,
A.Detail as Answer
,Q.ShortName as Question ,

AM.Longitude,AM.Latitude


from dbo.[Group] G
inner join EstablishmentGroup EG on G.id=EG.groupid
inner join Establishment E on  E.EstablishmentGroupId=EG.Id
inner join AnswerMaster AM on AM.EstablishmentId=E.id
inner join [Answers] A on A.AnswerMasterId=AM.id
inner join Questions Q on Q.id=A.QuestionId
left outer join dbo.[Appuser] u on u.id=AM.CreatedBy
left outer join SeenClientAnswerMaster SAM on SAM.id=AM.SeenClientAnswerMasterId
	left outer join SeenClientAnswerChild SAC on SAM.id=SAC.SeenClientAnswerMasterId And SAC.Id=AM.SeenClientAnswerChildId
Where (G.Id=498 and EG.Id =5003
ANd (AM.IsDeleted=0 or AM.IsDeleted=null))-- and (AM.IsDisabled=0 or AM.IsDisabled is null) 

and Q.id in(25725,25726,25727,25728)



) S
Pivot (
Max(Answer)
For  Question In (
[Genuine Problem],
[What problem],
[Permanently fixed],
[Describe]))P


) B on A.ReferenceNo=B.SeenClientAnswerMasterId

