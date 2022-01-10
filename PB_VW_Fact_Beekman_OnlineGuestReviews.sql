

CREATE View [dbo].[PB_VW_Fact_Beekman_OnlineGuestReviews] as
select A.*,

B.referenceno as ResponseReference,
B.[Was this an Issue],
B.[Type of Issue],
B.[Action Taken],
B.[Issue Fixed],
B.[Confidence in Fix],
B.[Deadline of fix],
B.[Comments]
from(
select EstablishmentName,CapturedDate,ReferenceNo,IsPositive,Status,PI,UserId,UserName,FirstActionDate,FirstResponseDate,ResolvedDate,CustomerName,Longitude,Latitude,AutoResolved,
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
[Service_Rating] from(
select
E.EstablishmentName,dateadd(MINUTE,AM.TimeOffSet,AM.CreatedOn) as CapturedDate,AM.id as ReferenceNo,
AM.IsPositive,AM.IsResolved as Status,AM.PI,

 case when (A.Detail='1-10' or A.detail='0-10' or A.Detail='01-10' or A.Detail= '11-20') then '1' when (A.Detail='21-30' or A.Detail= '31-40') then '2' when (A.Detail='41-50' or A.Detail= '51-60') then '3' when (A.Detail='61-70' or A.Detail= '71-80') then '4' when (A.Detail='81-90' or A.Detail= '91-100') then '5' else A.Detail end as Answer

,Q.ShortName as Question ,U.id as UserId, u.name as UserName,FAD.FirstActionDate,FRD.FirstResponseDate,case when AM.Narration like '%Auto Resolved %' then dateadd(MINUTE,AM.TimeOffSet,AM.CreatedOn) else  RD.ResolvedDate end As ResolvedDate,

(SELECT TOP 1 cd.Detail FROM ContactDetails CD WHERE   CD.ContactMasterId=AM.ContactMasterId  and CD.IsDeleted = 0 and CD.Detail<>'' 
and CD.contactQuestionId=2968
)  + ' '+
(SELECT TOP 1 cd.Detail FROM ContactDetails CD WHERE   CD.ContactMasterId=AM.ContactMasterId and CD.IsDeleted = 0 and CD.Detail<>'' 
and CD.contactQuestionId=2969
) as CustomerName,
AM.Longitude, AM.Latitude,case when AM.Narration is null then 0 else 1 end as AutoResolved

from dbo.[Group] G
inner join EstablishmentGroup EG on G.id=EG.groupid
inner join Establishment E on  E.EstablishmentGroupId=EG.Id --and E.id<>24180
inner join SeenClientAnswerMaster AM on AM.EstablishmentId=E.id
inner join [SeenClientAnswers] A on A.SeenclientAnswerMasterId=AM.id
inner join SeenClientQuestions Q on Q.id=A.QuestionId
left outer join dbo.[Appuser] u on u.id=AM.CreatedBy
--left outer join SeenClientAnswerChild SAC on AM.id=SAC.SeenClientAnswerMasterId 
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

	Left Outer Join (
	Select CLA.SeenClientAnswerMasterid as ReferenceNo,min(dateadd(MINUTE,TimeOffSet,CLA.CreatedOn)) as FirstActionDate from 
	CloseLoopAction CLA 
	right outer join seenclientanswermaster SAM on SAM.Id=CLA.SeenClientAnswerMasterId
	where Conversation Not Like '%Resolved%'
	group by CLA.SeenClientAnswerMasterId
	) as FAD on FAD.ReferenceNo = AM.Id

Where (G.Id=488 and EG.Id =4683
ANd (AM.IsDeleted=0 or AM.IsDeleted is null)) --and AM.IsDisabled is null

and Q.IsRequiredInBI=1--Q.id in (35575,35576,35581,35579,35580,35582,35588,35589,35590,35591,35592)
--and Convert(date,AM.CreatedOn,104)>=Convert(date,'01-08-2019',104) and Convert(date,AM.CreatedOn,104)<=Convert(date,'28-11-2019',104)
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
[Service_Rating]
))P
)A
left outer join
(select 
ReferenceNo,
SeenclientAnswerMasterid,
[Was this an Issue],
[Type of Issue],
[Action Taken],
[Issue Fixed],
[Confidence in Fix],
[Deadline of fix],
[Comments]
from(
select

E.EstablishmentName,dateadd(MINUTE,AM.TimeOffSet,AM.CreatedOn) as CapturedDate,AM.id as ReferenceNo,
AM.IsPositive,AM.IsResolved as Status,AM.PI,AM.SeenclientAnswerMasterid,Q.ShortName as Question,
A.Detail as Answer


from dbo.[Group] G
inner join EstablishmentGroup EG on G.id=EG.groupid
inner join Establishment E on  E.EstablishmentGroupId=EG.Id
inner join AnswerMaster AM on AM.EstablishmentId=E.id
inner join [Answers] A on A.AnswerMasterId=AM.id
inner join Questions Q on Q.id=A.QuestionId
left outer join dbo.[Appuser] u on u.id=AM.CreatedBy
left outer join SeenClientAnswerMaster SAM on SAM.id=AM.SeenClientAnswerMasterId
--	left outer join SeenClientAnswerChild SAC on SAM.id=SAC.SeenClientAnswerMasterId And SAC.Id=AM.SeenClientAnswerChildId
Where (G.Id=488 and EG.Id =4683
ANd (AM.IsDeleted=0 or AM.IsDeleted=null)) --and (AM.IsDisabled=0 or AM.IsDisabled is null) 

and Q.IsRequiredInBI=1--Q.id in(22893,22894,22908,22909,22910,22911,22913)
)S
pivot(
Max(Answer)
For  Question In (

[Was this an Issue],
[Type of Issue],
[Action Taken],
[Issue Fixed],
[Confidence in Fix],
[Deadline of fix],
[Comments]
))P

) B on A.referenceno=B.Seenclientanswermasterid 

