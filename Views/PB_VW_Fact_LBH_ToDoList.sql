

CREATE view [dbo].[PB_VW_Fact_LBH_ToDoList] as
select A.*,B.CapturedDate as ResponseDate,B.SeenClientAnswerMasterId,

B.[Permanent fix],
B.[Time spent],
B.[Deadline met],
B.[Cost]from (

select 
EstablishmentName,CapturedDate,ReferenceNo,Status,
UserName,
ResolvedDate,FirstResponseDate,
[Task],
[Priority],
[Category],
[Deadline],
[Comment],
IsOutStanding

from(
select
E.EstablishmentName,dateadd(MINUTE,AM.TimeOffSet,AM.CreatedOn) as CapturedDate,AM.id as ReferenceNo,
AM.IsPositive,AM.IsResolved as Status,Am.IsOutStanding,
A.Detail as Answer

,Q.shortname as Question ,U.id as UserId, u.name as UserName,case when (RD.ResolvedDate is null and Am.Isresolved='Resolved') then AM.Createdon else Rd.ResolvedDate end as ResolvedDate ,FRD.FirstResponseDate,
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


Where (G.Id=498 and EG.Id =5005
ANd (AM.IsDeleted=0 or AM.IsDeleted=null)) --and (AM.IsDisabled=0 or AM.IsDisabled is null)
and  Q.IsRequiredInBI=1--Q.id in (38352,38354,38355,38356,38627)

)S
pivot(
Max(Answer)
For  Question In (
[Task],
[Priority],
[Category],
[Deadline],
[Comment]
))P
)A
left outer join 
(

select 
EstablishmentName,CapturedDate,ReferenceNo,
IsPositive,Status,PI,
[Permanent fix],
[Time spent],
[Deadline met],
[Cost],
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
Where (G.Id=498 and EG.Id =5005
ANd (AM.IsDeleted=0 or AM.IsDeleted=null))-- and (AM.IsDisabled=0 or AM.IsDisabled is null) 

and Q.IsRequiredInBI=1--Q.id in(25734,25735,25736,25737)



) S
Pivot (
Max(Answer)
For  Question In (
[Permanent fix],
[Time spent],
[Deadline met],
[Cost]
))P


) B on A.ReferenceNo=B.SeenClientAnswerMasterId

