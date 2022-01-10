CREATE view PB_VW_Fact_LBH_OnlineReviews as
select A.*,B.CapturedDate as ResponseDate,B.SeenClientAnswerMasterId,
B.[Was this an issue?],
B.[Type of Issue],
B.[Action taken],
B.[Is the issue fixed],
B.[Confidence],
B.[Deadline of fix],
B.[Comments]
from (

select 
EstablishmentName,CapturedDate,ReferenceNo,Status,
UserName,
ResolvedDate,AutoResolved,FirstResponseDate,
[Reviewer],
[Source],
[Good_Comments],
[Bad_Comments],
[General_Comments],
[Manager_Comments],
[Overall_Rating],
[Room_Rating],
[Cleanliness_Rating],
[Facilities_Rating],
[Service_Rating],
IsOutStanding

from(
select
E.EstablishmentName,dateadd(MINUTE,AM.TimeOffSet,AM.CreatedOn) as CapturedDate,AM.id as ReferenceNo,
AM.IsPositive,AM.IsResolved as Status,Am.IsOutStanding,
 case when (A.Detail='01-10' or A.detail='0-10') then '1' when A.Detail= '11-20' then '2' when A.Detail='21-30' then '3' when  A.Detail= '31-40' then '4' when A.Detail='41-50' then '5'when A.Detail= '51-60' then '6' when A.Detail='61-70' then '7' when A.Detail= '71-80' then '8' when A.Detail='81-90' then '9' when  A.Detail= '91-100' then '10' else A.Detail end as Answer
,Q.shortname as Question ,U.id as UserId, u.name as UserName,
case when AM.Narration like '%Auto Resolved %' then dateadd(MINUTE,AM.TimeOffSet,AM.CreatedOn) else (case when Rd.ResolvedDate is null and AM.IsResolved='Resolved' then dateadd(MINUTE,AM.TimeOffSet,AM.CreatedOn) else RD.ResolvedDate end )   end As ResolvedDate,
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


Where (G.Id=498 and EG.Id =4983
ANd (AM.IsDeleted=0 or AM.IsDeleted=null)) --and (AM.IsDisabled=0 or AM.IsDisabled is null)
and  Q.id in (38128,38129,38131,38132,38133,38135,38140,38141,38142,38143,38144)
--and AM.id=430765
)S
pivot(
Max(Answer)
For  Question In (
[Reviewer],
[Source],
[Good_Comments],
[Bad_Comments],
[General_Comments],
[Manager_Comments],
[Overall_Rating],
[Room_Rating],
[Cleanliness_Rating],
[Facilities_Rating],
[Service_Rating]))P
)A
left outer join 
(

select 
EstablishmentName,CapturedDate,ReferenceNo,
IsPositive,Status,PI,
[Was this an issue?],
[Type of Issue],
[Action taken],
[Is the issue fixed],
[Confidence],
[Deadline of fix],
[Comments],
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
Where (G.Id=498 and EG.Id =4983
ANd (AM.IsDeleted=0 or AM.IsDeleted=null))-- and (AM.IsDisabled=0 or AM.IsDisabled is null) 

and Q.id in(25565,25572,25566,25567,25568,25569,25571)



) S
Pivot (
Max(Answer)
For  Question In (
[Was this an issue?],
[Type of Issue],
[Action taken],
[Is the issue fixed],
[Confidence],
[Deadline of fix],
[Comments]))P


) B on A.ReferenceNo=B.SeenClientAnswerMasterId

