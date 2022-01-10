
create view PB_VW_SOG_Fact_JobManager as
select A.*,B.ResponseDate,
B.[Task Title] as ResponseTaskTitle,
B.[Task Status],
B.[Comments] as ResponseComments,
B.[Deadline Met],
B.[If No - When Will ]
 from
(
select 
EstablishmentName,
CapturedDate,
Status,
ReferenceNo,
UserName,
[Task Title],
[Description],
[Deadline],
[Comments ],ResolvedDate


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
Where (G.Id=487 and EG.Id =4621 --and u.id not in (3722,3973)
ANd (AM.IsDeleted=0 or AM.IsDeleted=null)) and (AM.IsDisabled=0 or AM.IsDisabled is null)
and Q.id in(35379,35380,35381,35382)

) S
Pivot (
Max(Answer)
For  Question In (
[Site Name],
[Task Title],
[Description],
[Deadline],
[Comments ]
))P
) A
left outer join 
(
select 
EstablishmentName,
ResponseDate,
[Task Title],
[Task Status],
[Comments],
[Deadline Met],
[If No - When Will ],
SeenClientAnswerMasterId


from(
select  E.EstablishmentName,dateadd(MINUTE,AM.TimeOffSet,AM.CreatedOn) as ResponseDate,AM.id as ReferenceNo,
AM.IsPositive,AM.IsResolved as Status,AM.PI,Am.SeenClientAnswerMasterId,
A.Detail as Answer,Q.shortname as Question

from dbo.[Group] G
inner join EstablishmentGroup EG on G.id=EG.groupid
inner join Establishment E on  E.EstablishmentGroupId=EG.Id
inner join AnswerMaster AM on AM.EstablishmentId=E.id
inner join [Answers] A on A.AnswerMasterId=AM.id
inner join Questions Q on Q.id=A.QuestionId
Where (G.Id=487 and EG.Id =4621 --and u.id not in (3722,3973)
ANd (AM.IsDeleted=0 or AM.IsDeleted=null)) and (AM.IsDisabled=0 or AM.IsDisabled is null)
and Q.id in (22636,22637,22638,22639,22640)

) S
Pivot (
Max(Answer)
For  Question In (

[Task Title],
[Task Status],
[Comments],
[Deadline Met],
[If No - When Will ]))P

) B on A.ReferenceNo=B.SeenClientAnswerMasterId

