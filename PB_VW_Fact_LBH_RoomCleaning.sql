


CREATE view [dbo].[PB_VW_Fact_LBH_RoomCleaning] as
/*select A.*,B.CapturedDate as ResponseDate,B.SeenClientAnswerMasterId,

B.[Door & DnD & Service],
B.[Door & DnD & Service Comment],
B.[Light & Room Temp.],
B.[Light & Room Temp Comment],
B.[Sandbag],
B.[Sandbag Comment],
B.[Coffee Station],
B.[Coffee Station Comment],
B.[Cupboard Stocked],
B.[Cupboard Stocked Comment],
B.[Bed Standard],
B.[Bed Standard Comment],
B.[Bedside Tables],
B.[Bedside Tables Comment],
B.[Bed & Headboard],
B.[Bed & Headboard Comment],
B.[Couch & C/Table],
B.[Couch & C/Table Comment],
B.[Curtains],
B.[Curtains Comment],
B.[Balcony],
B.[Balcony Comment],
B.[Desk Stocked],
B.[Desk Stoked Comment],
B.[Bathroom Door ],
B.[Bathroom Door Comment],
B.[Shower Standard],
B.[Shower Standard Comment],
B.[Bath Tub Standard],
B.[Bath Tub Standard Comment],
B.[Bathroom Towels],
B.[Bathroom towels Comment],
B.[Toilets Clear],
B.[Toilets Clear Comment],
B.[Toilet Paper],
B.[Toilets Paper Comment],
B.[Stainless Bin],
B.[Stainless Bin Comment],
B.[Vanity Standard],
B.[Vanity Standard Comment]
from ( */

select 
EstablishmentName,CapturedDate,ReferenceNo,Status,
UserName,
ResolvedDate,FirstResponseDate,
CleanStartDate,CleanEndDate,FailedDate,InspectionDate,ResolvedBy,
[Room Number],
[Guest Name],
[Room Status],
[Check-in date],
[Check-out date],
[Bed],
[Duties (Traces)],
[Task of the Day],
IsOutStanding

from(
select
E.EstablishmentName,dateadd(MINUTE,AM.TimeOffSet,AM.CreatedOn) as CapturedDate,AM.id as ReferenceNo,
AM.IsPositive,AM.IsResolved as Status,Am.IsOutStanding,
A.Detail as Answer

,Q.shortname as Question ,U.id as UserId, u.name as UserName,case when (RD.ResolvedDate is null and Am.Isresolved='Resolved') then AM.Createdon else Rd.ResolvedDate end as ResolvedDate ,FRD.FirstResponseDate,
CS.CleanStartDate,CE.CleanEndDate,RF.FailedDate,Id.InspectionDate,RD.ResolvedBy,


AM.Longitude, AM.Latitude

from dbo.[Group] G
inner join EstablishmentGroup EG on G.id=EG.groupid
inner join Establishment E on  E.EstablishmentGroupId=EG.Id
inner join SeenClientAnswerMaster AM on AM.EstablishmentId=E.id
inner join [SeenClientAnswers] A on A.SeenclientAnswerMasterId=AM.id
inner join SeenClientQuestions Q on Q.id=A.QuestionId
left outer join dbo.[Appuser] u on u.id=AM.CreatedBy
 Left Outer Join (
 select AA.ReferenceNo,AA.ResolvedDate,BB.ResolvedBy from
	(Select CLA.SeenClientAnswerMasterid as ReferenceNo,max(dateadd(MINUTE,TimeOffSet,CLA.CreatedOn)) as ResolvedDate from 
	CloseLoopAction CLA 
	right outer join seenclientanswermaster SAM on SAM.Id=CLA.SeenClientAnswerMasterId
	Where (Conversation Like '%Resolved - Ref#%' or Conversation Like 'Resolved')
	And Conversation Not Like '%UnResolve%' and SAM.Isresolved='Resolved'
	and SAM.isresolved='Resolved'
	group by CLA.SeenClientAnswerMasterId)AA
	inner join (
	Select CLA.SeenClientAnswerMasterid as ReferenceNo,dateadd(MINUTE,120,CLA.CreatedOn) as ResolvedDate,AU.Name as ResolvedBy  from 
	CloseLoopAction CLA left outer join AppUser AU on AU.id=CLA.AppUserId)BB on AA.ReferenceNo=BB.ReferenceNo and BB.resolveddate=AA.ResolvedDate


	) as RD on rD.ReferenceNo = Am.Id
	
	Left Outer Join (
	Select AM.SeenClientAnswerMasterid as ReferenceNo,min(dateadd(MINUTE,AM.TimeOffSet,AM.CreatedOn)) as FirstResponseDate from 
	AnswerMaster AM 
	right outer join seenclientanswermaster SAM on SAM.Id=AM.SeenClientAnswerMasterId
	group by AM.SeenClientAnswerMasterId
	) as FRD on FRD.ReferenceNo = AM.Id
	Left Outer Join (
	select sh.ReferenceNo,min(sh.StatusDateTime) as CleanStartDate  from StatusHistory sh 
inner join establishmentstatus es on sh.establishmentstatusid=es.id
left outer join SeenClientAnswerMaster sam on sam.id=sh.ReferenceNo
Where (es.statusname Like '%Cleaning commenced%' )
group by sh.referenceno
	) as CS on CS.ReferenceNo = Am.Id
	Left Outer Join (
	select sh.ReferenceNo,max(sh.StatusDateTime) as CleanEndDate  from StatusHistory sh 
inner join establishmentstatus es on sh.establishmentstatusid=es.id
left outer join SeenClientAnswerMaster sam on sam.id=sh.ReferenceNo
Where (es.statusname Like '%Room clean & ready for inspection%' )
group by sh.referenceno
	) as CE on CE.ReferenceNo = Am.Id

	Left Outer Join (
	select sh.ReferenceNo,min(sh.StatusDateTime) as FailedDate  from StatusHistory sh 
inner join establishmentstatus es on sh.establishmentstatusid=es.id
left outer join SeenClientAnswerMaster sam on sam.id=sh.ReferenceNo
Where (es.statusname Like '%Room failed, please return to fix issues%' )
group by sh.referenceno
	) as RF on RF.ReferenceNo = Am.Id
	Left Outer Join (
	select sh.ReferenceNo,min(sh.StatusDateTime) as InspectionDate  from StatusHistory sh 
inner join establishmentstatus es on sh.establishmentstatusid=es.id
left outer join SeenClientAnswerMaster sam on sam.id=sh.ReferenceNo
Where (es.statusname Like '%Room failed, please return to fix issues%'  or es.statusname Like '%Room inspection passed')
group by sh.referenceno
	) as ID on ID.ReferenceNo = Am.Id
Where (G.Id=498 and EG.Id =4993 
ANd (AM.IsDeleted=0 or AM.IsDeleted=null)) --and (AM.IsDisabled=0 or AM.IsDisabled is null)
and  Q.IsRequiredInBI=1--Q.id in (38264,41939,41119,38266,38267,38280,38281,38269)
)S
pivot(
Max(Answer)
For  Question In (
[Room Number],
[Guest Name],
[Room Status],
[Check-in date],
[Check-out date],
[Bed],
[Duties (Traces)],
[Task of the Day]))P
/*)A
left outer join 
(

select 
EstablishmentName,CapturedDate,ReferenceNo,
IsPositive,Status,PI,
[Door & DnD & Service],
[Door & DnD & Service Comment],
[Light & Room Temp.],
[Light & Room Temp Comment],
[Sandbag],
[Sandbag Comment],
[Coffee Station],
[Coffee Station Comment],
[Cupboard Stocked],
[Cupboard Stocked Comment],
[Bed Standard],
[Bed Standard Comment],
[Bedside Tables],
[Bedside Tables Comment],
[Bed & Headboard],
[Bed & Headboard Comment],
[Couch & C/Table],
[Couch & C/Table Comment],
[Curtains],
[Curtains Comment],
[Balcony],
[Balcony Comment],
[Desk Stocked],
[Desk Stoked Comment],
[Bathroom Door ],
[Bathroom Door Comment],
[Shower Standard],
[Shower Standard Comment],
[Bath Tub Standard],
[Bath Tub Standard Comment],
[Bathroom Towels],
[Bathroom towels Comment],
[Toilets Clear],
[Toilets Clear Comment],
[Toilet Paper],
[Toilets Paper Comment],
[Stainless Bin],
[Stainless Bin Comment],
[Vanity Standard],
[Vanity Standard Comment],
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
Where (G.Id=498 and EG.Id =4993
ANd (AM.IsDeleted=0 or AM.IsDeleted=null))-- and (AM.IsDisabled=0 or AM.IsDisabled is null) 

and Q.id in(25627,26298,25628,26299,25629,26300,25630,26301,25631,26302,25632,26303,25633,26304,25634,26305,25635,26306,
25636,26307,25637,26308,25638,26309,25639,26310,25640,26311,25641,26312,25642,26313,25643,26314,25644,26315,25645,26316,
25646,26317)



) S
Pivot (
Max(Answer)
For  Question In (
[Door & DnD & Service],
[Door & DnD & Service Comment],
[Light & Room Temp.],
[Light & Room Temp Comment],
[Sandbag],
[Sandbag Comment],
[Coffee Station],
[Coffee Station Comment],
[Cupboard Stocked],
[Cupboard Stocked Comment],
[Bed Standard],
[Bed Standard Comment],
[Bedside Tables],
[Bedside Tables Comment],
[Bed & Headboard],
[Bed & Headboard Comment],
[Couch & C/Table],
[Couch & C/Table Comment],
[Curtains],
[Curtains Comment],
[Balcony],
[Balcony Comment],
[Desk Stocked],
[Desk Stoked Comment],
[Bathroom Door ],
[Bathroom Door Comment],
[Shower Standard],
[Shower Standard Comment],
[Bath Tub Standard],
[Bath Tub Standard Comment],
[Bathroom Towels],
[Bathroom towels Comment],
[Toilets Clear],
[Toilets Clear Comment],
[Toilet Paper],
[Toilets Paper Comment],
[Stainless Bin],
[Stainless Bin Comment],
[Vanity Standard],
[Vanity Standard Comment]
))P


) B on A.ReferenceNo=B.SeenClientAnswerMasterId

*/


