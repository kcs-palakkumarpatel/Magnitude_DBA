

create view PB_VW_SOG_Fact_TechnicalCommissioning as
with cte as(
select A.*,B.ResponseDate,
B.[Satisfied],
B.[Comments] as ResponseComments
from
(
select 
EstablishmentName,
CapturedDate,
Status,
ReferenceNo,
UserName,
RepeatCount,
[Client Name],
[Client Cell],
[Client Address],
[Equipment Type],
[Panel Make & Model],
[Radio Make & Type],
[Radio Code],
[SOG Warning Boards],
[Equipment],
[Comments],
[Zone #],
[Description],
[Tested & Ok],
[Signal to Control],
[Installation Bylaw],
ResolvedDate
from(
select  E.EstablishmentName,dateadd(MINUTE,AM.TimeOffSet,AM.CreatedOn) as CapturedDate,AM.id as ReferenceNo,
AM.IsPositive,AM.IsResolved as Status,AM.PI,
A.Detail as Answer
,Q.shortname as Question ,U.Id as UserId, u.name as UserName,Rd.ResolvedDate,
AM.Longitude,AM.Latitude,A.RepeatCount


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
Where (G.Id=487 and EG.Id =5179 --and u.id not in (3722,3973)
ANd (AM.IsDeleted=0 or AM.IsDeleted=null)) and (AM.IsDisabled=0 or AM.IsDisabled is null)
and Q.id in(40854,40855,40856,40857,40858,40859,40860,40872,40861,40862,40865,40866,40867,40868,40869)

) S
Pivot (
Max(Answer)
For  Question In (
[Client Name],
[Client Cell],
[Client Address],
[Equipment Type],
[Panel Make & Model],
[Radio Make & Type],
[Radio Code],
[SOG Warning Boards],
[Equipment],
[Comments],
[Zone #],
[Description],
[Tested & Ok],
[Signal to Control],
[Installation Bylaw]
))P
) A
left outer join 
(
select 
EstablishmentName,
ResponseDate,
[Satisfied],
[Comments],
SeenClientAnswerMasterId


from(
select  E.EstablishmentName,dateadd(MINUTE,AM.TimeOffSet,AM.CreatedOn) as ResponseDate,AM.id as ReferenceNo,
AM.IsPositive,AM.IsResolved as Status,AM.PI,Am.SeenClientAnswerMasterId,
A.Detail as Answer
,Q.shortname as Question ,U.Id as UserId, u.name as UserName,
AM.Longitude,AM.Latitude


from dbo.[Group] G
inner join EstablishmentGroup EG on G.id=EG.groupid
inner join Establishment E on  E.EstablishmentGroupId=EG.Id
inner join AnswerMaster AM on AM.EstablishmentId=E.id
inner join [Answers] A on A.AnswerMasterId=AM.id
inner join Questions Q on Q.id=A.QuestionId
left outer join dbo.[Appuser] u on u.id=AM.CreatedBy
Where (G.Id=487 and EG.Id =5179 --and u.id not in (3722,3973)
ANd (AM.IsDeleted=0 or AM.IsDeleted=null)) and (AM.IsDisabled=0 or AM.IsDisabled is null)
and Q.id in(27105,27106)

) S
Pivot (
Max(Answer)
For  Question In (
[Satisfied],
[Comments]
))P
) B on A.ReferenceNo=B.SeenClientAnswerMasterId
)


select 
B.EstablishmentName,
B.CapturedDate,
B.Status,
B.ReferenceNo,
B.UserName,
A.RepeatCount,
B.[Client Name],
B.[Client Cell],
B.[Client Address],
B.[Equipment Type],
B.[Panel Make & Model],
B.[Radio Make & Type],
B.[Radio Code],
B.[SOG Warning Boards],
B.[Equipment],
B.ResponseComments,
A.[Zone #],
A.[Description],
A.[Tested & Ok],
A.[Signal to Control],
A.[Installation Bylaw],
B.ResolvedDate,
B.ResponseDate,
B.[Satisfied],
B.[Comments]


 from 
(select * from cte where RepeatCount<>0 )A inner join (select * from cte where repeatcount=0)B on A.ReferenceNo=B.ReferenceNo
