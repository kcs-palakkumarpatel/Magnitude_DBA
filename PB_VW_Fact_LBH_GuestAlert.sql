


CREATE View [dbo].[PB_VW_Fact_LBH_GuestAlert] as

select 
EstablishmentName,CapturedDate,ReferenceNo,
IsPositive,Status,PI,
[Room Number ],
[Experience ],
ResolvedDate,
SeenClientAnswerMasterId

from(
select
E.EstablishmentName,dateadd(MINUTE,AM.TimeOffSet,AM.CreatedOn) as CapturedDate,AM.id as ReferenceNo,
AM.IsPositive,AM.IsResolved as Status,AM.PI,AM.SeenClientAnswerMasterId,RD.ResolvedDate,
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
	
 Left Outer Join (
	Select CLA.AnswerMasterid as ReferenceNo,max(dateadd(MINUTE,TimeOffSet,CLA.CreatedOn)) as ResolvedDate from 
	CloseLoopAction CLA 
	right outer join answermaster SAM on SAM.Id=CLA.AnswerMasterId
	Where (Conversation Like '%Resolved - Ref#%' or Conversation Like 'Resolved')
	And Conversation Not Like '%UnResolve%' and SAM.Isresolved='Resolved'
	and SAM.isresolved='Resolved'
	group by CLA.AnswerMasterId
	) as RD on rD.ReferenceNo = Am.Id
Where (G.Id=498 and EG.Id =4981
ANd (AM.IsDeleted=0 or AM.IsDeleted=null))-- and (AM.IsDisabled=0 or AM.IsDisabled is null) 

and Q.id in(25692,25573,25558)
--Q.IsRequiredInBI=1



) S
Pivot (
Max(Answer)
For  Question In (	
[Room Number ],
[Experience ]))P

