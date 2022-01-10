
create view PB_VW_SOG_Fact_ControlHandover as
select A.*,B.ResponseDate,B.[Issue Resolved] from
(
select 
EstablishmentName,
CapturedDate,
Status,
ReferenceNo,
UserName,
[Dogs Fed],
[Dogs Water],
[Kitchen Clean],
[Toilet Clean],
[Control Room Neat ],
[Off-Site CCTV ],
[Tracking On-Line],
[New Market CCTV On],
[SOP File On Desk],
[FTT Handed Over],
[Acknowledge Tech ],
[Issues Logged],
[All Guarding Issue],
[Alarms Cleared]

from(
select  E.EstablishmentName,dateadd(MINUTE,AM.TimeOffSet,AM.CreatedOn) as CapturedDate,AM.id as ReferenceNo,
AM.IsPositive,AM.IsResolved as Status,AM.PI,
A.Detail as Answer
,Q.shortname as Question ,U.Id as UserId, u.name as UserName


from dbo.[Group] G
inner join EstablishmentGroup EG on G.id=EG.groupid
inner join Establishment E on  E.EstablishmentGroupId=EG.Id
inner join SeenClientAnswerMaster AM on AM.EstablishmentId=E.id
inner join [SeenClientAnswers] A on A.SeenclientAnswerMasterId=AM.id
inner join SeenClientQuestions Q on Q.id=A.QuestionId
left outer join dbo.[Appuser] u on u.id=AM.CreatedBy
Where (G.Id=487 and EG.Id =4697 --and u.id not in (3722,3973)
ANd (AM.IsDeleted=0 or AM.IsDeleted=null)) and (AM.IsDisabled=0 or AM.IsDisabled is null)
and Q.id in(35597,35598,35599,35600,35601,35602,37813,35603,35604,35605,35606,35607,35608,35609)

) S
Pivot (
Max(Answer)
For  Question In (
[Dogs Fed],
[Dogs Water],
[Kitchen Clean],
[Toilet Clean],
[Control Room Neat ],
[Off-Site CCTV ],
[Tracking On-Line],
[New Market CCTV On],
[SOP File On Desk],
[FTT Handed Over],
[Acknowledge Tech ],
[Issues Logged],
[All Guarding Issue],
[Alarms Cleared]
))P
) A
left outer join 
(

select  E.EstablishmentName,dateadd(MINUTE,AM.TimeOffSet,AM.CreatedOn) as ResponseDate,AM.id as ReferenceNo,
AM.IsPositive,AM.IsResolved as Status,AM.PI,Am.SeenClientAnswerMasterId,
A.Detail as [Issue Resolved]

from dbo.[Group] G
inner join EstablishmentGroup EG on G.id=EG.groupid
inner join Establishment E on  E.EstablishmentGroupId=EG.Id
inner join AnswerMaster AM on AM.EstablishmentId=E.id
inner join [Answers] A on A.AnswerMasterId=AM.id
inner join Questions Q on Q.id=A.QuestionId
Where (G.Id=487 and EG.Id =4697 --and u.id not in (3722,3973)
ANd (AM.IsDeleted=0 or AM.IsDeleted=null)) and (AM.IsDisabled=0 or AM.IsDisabled is null)
and Q.id =22930

) B on A.ReferenceNo=B.SeenClientAnswerMasterId

