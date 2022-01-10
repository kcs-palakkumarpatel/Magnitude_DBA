
create view PB_VW_SOG_Fact_DamageReport as
select A.*,B.ResponseDate,
B.[Repair | Replace],
B.[Sent To Supplier],
B.[Equipment Replaced],
B.[Name of Supplier],
B.[Estimated Cost R],
B.[Loss/Damage Billed],
B.[Who Is Responsible] from
(
select 
EstablishmentName,
CapturedDate,
Status,
ReferenceNo,
UserName,
[Equipment Type],
[Site Name],
[Make & Model],
[Serial Number],
[Asset No],
[Damage Reported By],
[Date & Time Report],
[Date & Time ],
[How Did Damage Occ],
[Description],
[How Can This Be Pr]

from(
select  E.EstablishmentName,dateadd(MINUTE,AM.TimeOffSet,AM.CreatedOn) as CapturedDate,AM.id as ReferenceNo,
AM.IsPositive,AM.IsResolved as Status,AM.PI,
A.Detail as Answer
,Q.shortname as Question ,U.Id as UserId, u.name as UserName,
AM.Longitude,AM.Latitude,A.RepeatCount


from dbo.[Group] G
inner join EstablishmentGroup EG on G.id=EG.groupid
inner join Establishment E on  E.EstablishmentGroupId=EG.Id
inner join SeenClientAnswerMaster AM on AM.EstablishmentId=E.id
inner join [SeenClientAnswers] A on A.SeenclientAnswerMasterId=AM.id
inner join SeenClientQuestions Q on Q.id=A.QuestionId
left outer join dbo.[Appuser] u on u.id=AM.CreatedBy
Where (G.Id=487 and EG.Id =4975 --and u.id not in (3722,3973)
ANd (AM.IsDeleted=0 or AM.IsDeleted=null)) and (AM.IsDisabled=0 or AM.IsDisabled is null)
and Q.id in(38085,38086,38087,38088,38089,38090,38091,38092,38093,38094,38096)

) S
Pivot (
Max(Answer)
For  Question In (
[Equipment Type],
[Site Name],
[Make & Model],
[Serial Number],
[Asset No],
[Damage Reported By],
[Date & Time Report],
[Date & Time ],
[How Did Damage Occ],
[Description],
[How Can This Be Pr]
))P
) A
left outer join 
(
select 
EstablishmentName,
ResponseDate,
[Repair | Replace],
[Sent To Supplier],
[Equipment Replaced],
[Name of Supplier],
[Estimated Cost R],
[Loss/Damage Billed],
[Who Is Responsible],
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
Where (G.Id=487 and EG.Id =4975 --and u.id not in (3722,3973)
ANd (AM.IsDeleted=0 or AM.IsDeleted=null)) and (AM.IsDisabled=0 or AM.IsDisabled is null)
and Q.id in(25519,25520,25521,25522,25523,25524,25525)

) S
Pivot (
Max(Answer)
For  Question In (
[Repair | Replace],
[Sent To Supplier],
[Equipment Replaced],
[Name of Supplier],
[Estimated Cost R],
[Loss/Damage Billed],
[Who Is Responsible]
))P
) B on A.ReferenceNo=B.SeenClientAnswerMasterId

