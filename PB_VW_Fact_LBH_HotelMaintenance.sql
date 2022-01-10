create View  PB_VW_Fact_LBH_HotelMaintenance as
select A.*,B.CapturedDate as ResponseDate,B.SeenClientAnswerMasterId,

B.[Time Acceptable],
B.[Good Quality]from (

select 
EstablishmentName,CapturedDate,ReferenceNo,Status,
UserName,
ResolvedDate,FirstResponseDate,FirstActionDate,
ProgressDate,JobDoneDate,
[What is broken],
[Room Number],
[Cause],
[Urgency],
[Category],
[Comments],
IsOutStanding

from(
select
E.EstablishmentName,dateadd(MINUTE,AM.TimeOffSet,AM.CreatedOn) as CapturedDate,AM.id as ReferenceNo,
AM.IsPositive,AM.IsResolved as Status,Am.IsOutStanding,
A.Detail as Answer

,Q.shortname as Question ,U.id as UserId, u.name as UserName,case when (RD.ResolvedDate is null and Am.Isresolved='Resolved') then AM.Createdon else Rd.ResolvedDate end as ResolvedDate ,FRD.FirstResponseDate,FAD.FirstActionDate,
PD.ProgressDate,case when Jd.JobDoneDate> PD.ProgressDate then NULL else JD.JobDoneDate end as JobDoneDate,


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
	select sh.ReferenceNo,max(sh.StatusDateTime) as Progressdate  from StatusHistory sh 
inner join establishmentstatus es on sh.establishmentstatusid=es.id
left outer join SeenClientAnswerMaster sam on sam.id=sh.ReferenceNo
Where (es.statusname Like '%Job commenced%' )
group by sh.referenceno
	) as PD on PD.ReferenceNo = Am.Id
	Left Outer Join (
	select sh.ReferenceNo,max(sh.StatusDateTime) as JobDoneDate  from StatusHistory sh 
inner join establishmentstatus es on sh.establishmentstatusid=es.id
left outer join SeenClientAnswerMaster sam on sam.id=sh.ReferenceNo
Where (es.statusname Like '%Passed inspection%' )
group by sh.referenceno
	) as JD on JD.ReferenceNo = Am.Id
	Left Outer Join (
	Select AM.SeenClientAnswerMasterid as ReferenceNo,min(dateadd(MINUTE,AM.TimeOffSet,AM.CreatedOn)) as FirstResponseDate from 
	AnswerMaster AM 
	right outer join seenclientanswermaster SAM on SAM.Id=AM.SeenClientAnswerMasterId
	group by AM.SeenClientAnswerMasterId
	) as FRD on FRD.ReferenceNo = AM.Id

	Left Outer Join (
	Select CLA.SeenClientAnswerMasterid as ReferenceNo,min(dateadd(MINUTE,TimeOffSet,CLA.CreatedOn)) as FirstActionDate from 
	CloseLoopAction CLA 
	right outer join seenclientanswermaster SAM on SAM.Id=CLA.SeenClientAnswerMasterId
	group by CLA.SeenClientAnswerMasterId
	) as FAD on FAD.ReferenceNo = AM.Id

Where (G.Id=498 and EG.Id =4973
ANd (AM.IsDeleted=0 or AM.IsDeleted=null)) --and (AM.IsDisabled=0 or AM.IsDisabled is null)
and  Q.id in (38074,41117,38076,38077,41118,38079,38122)

)S
pivot(
Max(Answer)
For  Question In (

[What is broken],
[Room Number],
[Cause],
[Urgency],
[Category],
[Comments]


))P
)A
left outer join 
(

select 
EstablishmentName,CapturedDate,ReferenceNo,
IsPositive,Status,PI,

[Time Acceptable],
[Good Quality],
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
Where (G.Id=498 and EG.Id =4973
ANd (AM.IsDeleted=0 or AM.IsDeleted=null))-- and (AM.IsDisabled=0 or AM.IsDisabled is null) 

and Q.id in(26516,26517,25508)



) S
Pivot (
Max(Answer)
For  Question In (
[Time Acceptable],
[Good Quality]
))P


) B on A.ReferenceNo=B.SeenClientAnswerMasterId

