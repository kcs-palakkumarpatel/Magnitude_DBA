





CREATE view [dbo].[PB_VW_Fact_AustroDailyPlanFeedbackNew] as


select X.*,Y.Referenceno as EngagementRef, Y.Activity,Y.Customer,Y.[Time Taken] as TimeTakenForEngagement,Y.[Type of Task:] as TypeOftaskForEngagement, Y.[Description of wor] as EngagementDescription
from
(

select 
EstablishmentName,CapturedDate,ReferenceNo,
IsPositive,Status,PI,
UserId,UserName,SeenClientAnswerMasterId,
Longitude,Latitude,

[Achieve Plan],
[Comment:],
[Non-Client Time],
[If other, please s],
[Time taken:],
[Description fo wor],
[Time travelled: ]

from(
select 
E.EstablishmentName,dateadd(MINUTE,AM.TimeOffSet,AM.CreatedOn) as CapturedDate,AM.id as ReferenceNo,
AM.SeenClientAnswerMasterId,AM.IsPositive,AM.IsResolved as Status,AM.PI,
A.Detail as Answer

,Q.ShortName as Question ,U.Id as UserId, u.name as UserName,A.RepeatCount,
AM.Longitude,AM.Latitude
from dbo.[Group] G
inner join EstablishmentGroup EG on G.id=EG.groupid and G.Id=462 
inner join Establishment E on  E.EstablishmentGroupId=EG.Id and EG.Id =3833
inner join AnswerMaster AM on AM.EstablishmentId=E.id and isnull(Am.isdeleted,0)=0 and  convert(date,Am.createdon,104)>=convert(date,'07-08-2019',104)
inner join [Answers] A on A.AnswerMasterId=AM.id
inner join Questions Q on Q.id=A.QuestionId and Q.IsRequiredInBI=1
left outer join dbo.[Appuser] u on u.id=AM.CreatedBy


Where /*(G.Id=462 and EG.Id =3833
ANd (AM.IsDeleted=0 or AM.IsDeleted=null)) --and (AM.IsDisabled=0 or AM.IsDisabled is null) 
and Q.IsRequiredInBI=1
--Q.id in (18116,18117,22336,22337,22338,22339,22340)
and */U.id<>3724

) S
Pivot (
Max(Answer)
For  Question In (
[Achieve Plan],
[Comment:],
[Non-Client Time],
[If other, please s],
[Time taken:],
[Description fo wor],
[Time travelled: ]
))P


)X
left join 
(
(select Activity,Referenceno,CapturedDate,UserId,UserName,Customer,[Time Taken],[Consume Task] as [Type of Task:],[Description of wor]
from
(
select 
EG.EstablishmentGroupName as Activity,AM.Id as Referenceno, dateadd(MINUTE,AM.TimeOffSet,AM.CreatedOn) as CapturedDate,
A.Detail as Answer,

Q.ShortName as Question ,U.Id as UserId, u.name as UserName,
CD.Detail as Customer
from dbo.[Group] G
inner join EstablishmentGroup EG on G.id=EG.groupid and G.Id=462 
inner join Establishment E on  E.EstablishmentGroupId=EG.Id and EG.Id =3835
inner join SeenClientAnswerMaster AM on AM.EstablishmentId=E.id and isnull(AM.IsDeleted,0)=0
inner join [SeenClientAnswers] A on A.SeenclientAnswerMasterId=AM.id
inner join SeenClientQuestions Q on Q.id=A.QuestionId and Q.id in(33272,36883,33210)
left outer join dbo.[Appuser] u on u.id=AM.CreatedBy
left join SeenClientAnswerChild SAC on SAC.SeenClientAnswerMasterId=AM.Id
left outer join ContactDetails CD on CD.contactMasterid=(case when AM.IsSubmittedForGroup=1 then SAC.ContactMasterId else  AM.ContactMasterid end) and CD.contactQuestionId=2928
/*Where (G.Id=462 and EG.Id =3835
ANd (AM.IsDeleted=0 or AM.IsDeleted=null)) --and (AM.IsDisabled=0 or AM.IsDisabled is null)and  
and Q.IsRequiredInBI=1
--Q.id in(33272,33334,33210)*/
)S
pivot(
Max(Answer)
For  Question In (
[Time Taken],
[Consume Task],
[Description of wor]
))P


union all
select Activity,Referenceno,CapturedDate,UserId,UserName,Customer,[Time Taken],[Equipment Task] as [Type of Task:],[Description of wor]
from
(

select 

EG.EstablishmentGroupName as Activity,AM.Id as Referenceno,dateadd(MINUTE,AM.TimeOffSet,AM.CreatedOn) as CapturedDate,
A.Detail as Answer,

Q.ShortName as Question ,U.Id as UserId, u.name as UserName,
CD.Detail as Customer
from dbo.[Group] G
inner join EstablishmentGroup EG on G.id=EG.groupid and G.Id=462 
inner join Establishment E on  E.EstablishmentGroupId=EG.Id and EG.Id =4029
inner join SeenClientAnswerMaster AM on AM.EstablishmentId=E.id and isnull(AM.isdeleted,0)=0
inner join [SeenClientAnswers] A on A.SeenclientAnswerMasterId=AM.id
inner join SeenClientQuestions Q on Q.id=A.QuestionId and Q.id in (33330,33274,33205)
left outer join dbo.[Appuser] u on u.id=AM.CreatedBy
left outer join ContactDetails CD on CD.contactMasterid=AM.ContactMasterid and CD.contactQuestionId=2928
/*Where (G.Id=462 and EG.Id =4029
ANd (AM.IsDeleted=0 or AM.IsDeleted=null)) --and (AM.IsDisabled=0 or AM.IsDisabled is null) 

and Q.IsRequiredInBI=1
-- Q.id in (33330,33274,33205)*/
)S
pivot(
Max(Answer)
For  Question In (
[Time Taken],
[Equipment Task],
[Description of wor]
))P
))Y on X.Userid=Y.userid and convert(date,X.CapturedDate,104)=convert(date,Y.CapturedDate,104)
