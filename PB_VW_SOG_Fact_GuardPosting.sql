
create view PB_VW_SOG_Fact_GuardPosting as
select A.*,B.ResponseDate,
B.[Client Invoiced],
B.[Invoice No],
B.[Invoice Amount],
B.[Reason],
B.[Additional Comment]
 from
(
select 
EstablishmentName,
CapturedDate,
Status,
ReferenceNo,
UserName,
[Site Name],
[Site Address],
[Site Contact Name],
[Site Contact Cell ],
[Site Contact Posit],
[Requested Via],
[Prices Quoted],
[Comments],
[Payment],
[If Other - Please ],
[Shifts Day],
[Shifts Night],
[Start Date],
[Guard Booked Name],
[Guard Co No],
[Guard Booked Name2],
[Guard Co No2],
[Easyroster]


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
Where (G.Id=487 and EG.Id =4823 --and u.id not in (3722,3973)
ANd (AM.IsDeleted=0 or AM.IsDeleted=null)) and (AM.IsDisabled=0 or AM.IsDisabled is null)
and Q.id in(36352,36353,36354,36355,36356,36357,36358,36359,36360,36361,36362,36363,36364,36365,36366,36367,36368,36369)

) S
Pivot (
Max(Answer)
For  Question In (
[Site Name],
[Site Address],
[Site Contact Name],
[Site Contact Cell ],
[Site Contact Posit],
[Requested Via],
[Prices Quoted],
[Comments],
[Payment],
[If Other - Please ],
[Shifts Day],
[Shifts Night],
[Start Date],
[Guard Booked Name],
[Guard Co No],
[Guard Booked Name2],
[Guard Co No2],
[Easyroster]
))P
) A
left outer join 
(
select 
EstablishmentName,
ResponseDate,
[Client Invoiced],
[Invoice No],
[Invoice Amount],
[Reason],
[Additional Comment],
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
Where (G.Id=487 and EG.Id =4823 --and u.id not in (3722,3973)
ANd (AM.IsDeleted=0 or AM.IsDeleted=null)) and (AM.IsDisabled=0 or AM.IsDisabled is null)
and Q.id in (23793,23794,23795,23796,23797)

) S
Pivot (
Max(Answer)
For  Question In (

[Client Invoiced],
[Invoice No],
[Invoice Amount],
[Reason],
[Additional Comment]))P

) B on A.ReferenceNo=B.SeenClientAnswerMasterId

