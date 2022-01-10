

create view PB_VW_SOG_Fact_CCTVCheck as
select A.*,B.ResponseDate,
B.Satisfied
 from
(
select 
EstablishmentName,
CapturedDate,
Status,
ReferenceNo,
UserName,
[All Cameras Online],
[PTZ Wimpy OK],
[PTZ Gate 2 OK],
[PTZ Builders OK],
[Camera Comments],
[Workstation 1 OK],
[Workstation 2 OK],
[Server 1 OK],
[Server 2 OK],
[Server 3 OK],
[IT/Software],
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
Where (G.Id=487 and EG.Id =4845 --and u.id not in (3722,3973)
ANd (AM.IsDeleted=0 or AM.IsDeleted=null)) and (AM.IsDisabled=0 or AM.IsDisabled is null)
and Q.id in(36479,36480,36481,36482,36483,36484,36485,36486,36487,36488,36489)

) S
Pivot (
Max(Answer)
For  Question In (
[All Cameras Online],
[PTZ Wimpy OK],
[PTZ Gate 2 OK],
[PTZ Builders OK],
[Camera Comments],
[Workstation 1 OK],
[Workstation 2 OK],
[Server 1 OK],
[Server 2 OK],
[Server 3 OK],
[IT/Software]
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
Where (G.Id=487 and EG.Id =4845 --and u.id not in (3722,3973)
ANd (AM.IsDeleted=0 or AM.IsDeleted=null)) and (AM.IsDisabled=0 or AM.IsDisabled is null)
and Q.id =23895


) B on A.ReferenceNo=B.SeenClientAnswerMasterId

