


CREATE view [dbo].[PB_VW_Masslift_Fact_DailyPlanFeedback]
as

select X.EstablishmentName,X.CapturedDate,X.ReferenceNo,
X.IsPositive,X.Status,X.PI,
X.UserId,X.UserName,

X.[Have you achieved your goals for today?],
X.[Please explain why you did not achieve your goals:] as[If no, please explain what you didnt achieve and how you plan to rectify it:],
X.[Non-client facing tasks:],
X.[Who did you cold call?],
X.[If other, please state],
X.[Time taken:],
X.[Description of work:],
X.[Time travelled:],
X.[KM travelled:],X.[How many cold calls did you make?],PlanCapturedDate,X.SeenClientAnswerMasterId,Y.ReferenceNo as EngagementRef, Y.Activity,Y.Customer,Y.[Time Taken] as TimeTakenForEngagement,Y.[Type of task: ] as TypeOftaskForEngagement, Y.[What transpired in] as WhatTranspiredInEngagement
from
(



select 
EstablishmentName,CapturedDate,ReferenceNo,
IsPositive,Status,PI,
UserId,UserName,

[Have you achieved your goals for today?],
[Please explain why you did not achieve your goals:],
[Non-client facing tasks:],
[Who did you cold call?],
[If other, please state],
[Time taken:],
[Description of work:],
[Time travelled:],
[KM travelled:],SeenClientAnswerMasterId,PlanCapturedDate,[How many cold calls did you make?]
from(
select 

E.EstablishmentName,dateadd(MINUTE,AM.TimeOffSet,AM.CreatedOn) as CapturedDate,AM.id as ReferenceNo,
AM.IsPositive,AM.IsResolved as Status,AM.PI,
A.Detail as Answer

,Q.QuestionTitle as Question ,U.Id as UserId, u.name as UserName,A.RepeatCount,
AM.Longitude,AM.Latitude,AM.seenclientanswermasterid,SAM.CreatedOn as PlanCapturedDate
from dbo.[Group] G
inner join EstablishmentGroup EG on G.id=EG.groupid and G.Id=463 
inner join Establishment E on  E.EstablishmentGroupId=EG.Id and EG.Id =3837
inner join AnswerMaster AM on AM.EstablishmentId=E.id ANd isnull(AM.IsDeleted,0)=0
inner join [Answers] A on A.AnswerMasterId=AM.id
inner join Questions Q on Q.id=A.QuestionId and  Q.IsRequiredInBI=1
left outer join dbo.[Appuser] u on u.id=AM.CreatedBy
left outer join SeenClientAnswerMaster SAM on SAM.id=AM.SeenClientAnswerMasterId

--Where (G.Id=463 and EG.Id =3837
--ANd (AM.IsDeleted=0 or AM.IsDeleted=null)) and (AM.IsDisabled=0 or AM.IsDisabled is null) 
--And Q.IsRequiredInBI=1--Q.Id in(22347,22348,22352,22353,22358,22355,22359,23375,26224)

 

) S
Pivot (
Max(Answer)
For  Question In (
[Have you achieved your goals for today?],
[Please explain why you did not achieve your goals:],
[Non-client facing tasks:],
[Who did you cold call?],
[If other, please state],
[Time taken:],
[Description of work:],
[Time travelled:],
[KM travelled:],
[How many cold calls did you make?]
))P

)X
left outer join 
(
(select Activity,CapturedDate,ReferenceNo,UserId,UserName,Customer,[Time Taken],[Type of task: ],[What transpired in]
from
(
select 
EG.EstablishmentGroupName as Activity,dateadd(MINUTE,AM.TimeOffSet,AM.CreatedOn) as CapturedDate,
AM.Id as ReferenceNo,
A.Detail as Answer,

Q.ShortName as Question ,U.Id as UserId, u.name as UserName,
CD.Detail as Customer
from dbo.[Group] G
inner join EstablishmentGroup EG on G.id=EG.groupid and G.Id=463 
inner join Establishment E on  E.EstablishmentGroupId=EG.Id and EG.Id =3929
inner join SeenClientAnswerMaster AM on AM.EstablishmentId=E.id ANd isnull(AM.IsDeleted,0)=0 
inner join [SeenClientAnswers] A on A.SeenclientAnswerMasterId=AM.id
inner join SeenClientQuestions Q on Q.id=A.QuestionId and Q.id in(33803,34674,30866) 
left outer join dbo.[Appuser] u on u.id=AM.CreatedBy
left outer join SeenclientAnswerChild SAC on AM.Id=SAC.SeenClientAnswerMasterId
left outer join ContactDetails CD on CD.contactMasterid=(case when AM.IsSubmittedForGroup=1 then SAC.ContactMasterId else AM.ContactMasterid end) and CD.contactQuestionId=2843
/* Where (G.Id=463 and EG.Id =3929
ANd (AM.IsDeleted=0 or AM.IsDeleted=null)) --and (AM.IsDisabled=0 or AM.IsDisabled is null)and  
and Q.id in(33803,34674,30866) */
)S
pivot(
Max(Answer)
For  Question In (
[Time Taken],[Type of task: ],[What transpired in]
))P
union all
select Activity,CapturedDate,ReferenceNo,UserId,UserName,[Company Name] as Customer,[Time taken ] as [Time Taken],[Reason For Visit] as [Type of task: ],
[What transpired in]
from
(
select 
EG.EstablishmentGroupName as Activity,dateadd(MINUTE,AM.TimeOffSet,AM.CreatedOn) as CapturedDate,
AM.Id as ReferenceNo,
A.Detail as Answer,

Q.ShortName as Question ,U.Id as UserId, u.name as UserName,
CD.Detail as Customer
from dbo.[Group] G
inner join EstablishmentGroup EG on G.id=EG.groupid and G.Id=463 
inner join Establishment E on  E.EstablishmentGroupId=EG.Id and EG.Id =4933
inner join SeenClientAnswerMaster AM on AM.EstablishmentId=E.id ANd isnull(AM.IsDeleted,0)=0 
inner join [SeenClientAnswers] A on A.SeenclientAnswerMasterId=AM.id
inner join SeenClientQuestions Q on Q.id=A.QuestionId and Q.id in(37363,37368,39409,37362)
left outer join dbo.[Appuser] u on u.id=AM.CreatedBy
left outer join SeenclientAnswerChild SAC on AM.Id=SAC.SeenClientAnswerMasterId
left outer join ContactDetails CD on CD.contactMasterid=(case when AM.IsSubmittedForGroup=1 then SAC.ContactMasterId else AM.ContactMasterid end) and CD.contactQuestionId=2843
/*Where (G.Id=463 and EG.Id =4933
ANd (AM.IsDeleted=0 or AM.IsDeleted=null)) --and (AM.IsDisabled=0 or AM.IsDisabled is null)and  
and Q.id in(37363,37368,39409,37362)*/
)S
pivot(
Max(Answer)
For  Question In (
[Reason For Visit],
[What transpired in],
[Time taken ],
[Company Name]
))P
))Y on X.Userid=Y.userid and convert(date,X.PlanCapturedDate,104)=convert(date,Y.CapturedDate,104)

