

CREATE view [dbo].[PB_VW_Fact_Pegasus_DailyPlan] as

select A.EstablishmentName,A.CapturedDate,A.ReferenceNo,
A.IsPositive,A.Status,
A.UserName,
A.[Clients Today],
A.[Client Time],
A.[Non-Client Time],
A.[What is the plan:] as [What is the plan],
A.[Area ] as [Area],
B.ReferenceNo as ResponseReference,
B.[Time travelled: ] as [Time travelled],
B.[KM travelled:] as [KM travelled],
B.[Time taken:] as [Response Time Taken],
B.[Description of wor] as [Response Description of Work],
B.[Achieved Goals  ] as [Achieved Goals],
B.[If no, please expl] as [If no,Explain],
B.[If other, please s] as [If Other,specify],
B.[Non-client tasks],
B.Activity,
B.Customer,
B.TimeTakenForEngagement,
B.[Meeting Summary]
 from
(
select 
EstablishmentName,CapturedDate,ReferenceNo,
IsPositive,Status,
UserName,
[Clients Today],
[Client Time],
[Non-Client Time],
[What is the plan:],
[Area ]
from(
select
E.EstablishmentName,dateadd(MINUTE,AM.TimeOffSet,AM.CreatedOn) as CapturedDate,AM.id as ReferenceNo,
AM.IsPositive,AM.IsResolved as Status,
A.Detail as Answer
,Q.ShortName as Question , u.name as UserName

from dbo.[Group] G
inner join EstablishmentGroup EG on G.id=EG.groupid and G.Id=477 and EG.Id =4205
inner join Establishment E on  E.EstablishmentGroupId=EG.Id
inner join SeenClientAnswerMaster AM on AM.EstablishmentId=E.id ANd (AM.IsDeleted=0 or AM.IsDeleted=null)
inner join [SeenClientAnswers] A on A.SeenclientAnswerMasterId=AM.id
inner join SeenClientQuestions Q on Q.id=A.QuestionId and Q.IsRequiredInBI=1
left outer join dbo.[Appuser] u on u.id=AM.CreatedBy and U.id<>4163
left outer join ContactDetails CD on CD.contactMasterid=AM.ContactMasterid and CD.contactQuestionId=2843
Where /*(G.Id=477 and EG.Id =4205
ANd (AM.IsDeleted=0 or AM.IsDeleted=null))-- and (AM.IsDisabled=0 or AM.IsDisabled is null) 

and Q.id in(34777,34778,34779,34780,34860)
and */ convert(date,Am.createdon,104)>=convert(date,'08-08-2019',104)
) S
Pivot (
Max(Answer)
For  Question In (
[Clients Today],
[Client Time],
[Non-Client Time],
[What is the plan:],
[Area ]
))P
) A


left outer join 

(
select X.*,Y.Activity,Y.Customer,Y.[Time Taken] as TimeTakenForEngagement,
Y.[Meeting Summary]
from
(

select 
EstablishmentName,CapturedDate,ReferenceNo,
IsPositive,Status,
UserId,UserName,SeenClientAnswerMasterId,
[Time travelled: ],
[KM travelled:],
[Non Client Facing ],
[Time taken:],
[Description of wor],
[Achieved Goals  ],
[If no, please expl],
[If other, please s],
[Non-client tasks]
from(
select 
E.EstablishmentName,dateadd(MINUTE,SAM.TimeOffSet,AM.CreatedOn) as CapturedDate,AM.id as ReferenceNo,
AM.SeenClientAnswerMasterId,AM.IsPositive,AM.IsResolved as Status,
A.Detail as Answer

,Q.ShortName as Question ,U.id as UserId, u.name as UserName
from dbo.[Group] G
inner join EstablishmentGroup EG on G.id=EG.groupid and G.Id=477 and EG.Id =4205
inner join Establishment E on  E.EstablishmentGroupId=EG.Id
inner join AnswerMaster AM on AM.EstablishmentId=E.id ANd (AM.IsDeleted=0 or AM.IsDeleted=null)
inner join [Answers] A on A.AnswerMasterId=AM.id
inner join Questions Q on Q.id=A.QuestionId and  Q.IsRequiredInBI=1
left outer join dbo.[Appuser] u on u.id=AM.CreatedBy and U.id<>4163
left outer join SeenClientAnswerMaster SAM on SAM.id=AM.SeenClientAnswerMasterId


/*Where (G.Id=477 and EG.Id =4205
ANd (AM.IsDeleted=0 or AM.IsDeleted=null)) --and (AM.IsDisabled=0 or AM.IsDisabled is null) 
and Q.id in (22102,22103,22104,22106,22107,22141,22142,22144,22166)*/

and convert(date,Am.createdon,104)>=convert(date,'08-08-2019',104)
) S
Pivot (
Max(Answer)
For  Question In (
[Time travelled: ],
[KM travelled:],
[Non Client Facing ],
[Time taken:],
[Description of wor],
[Achieved Goals  ],
[If no, please expl],
[If other, please s],
[Non-client tasks]
))P


)X
left outer join 
(
(select Activity,CapturedDate,UserId,UserName,case when Customer is null or Customer ='' then Company else Customer end as Customer,[Time taken] as [Time Taken],[Meeting Summary] 
from
(
select

EG.EstablishmentGroupName as Activity,dateadd(MINUTE,AM.TimeOffSet,AM.CreatedOn) as CapturedDate,
A.Detail as Answer,
Q.ShortName as Question ,U.id as UserId, u.name as UserName,
CD.Detail as Customer 
from dbo.[Group] G
inner join EstablishmentGroup EG on G.id=EG.groupid and G.Id=477 and EG.Id =4289
inner join Establishment E on  E.EstablishmentGroupId=EG.Id
inner join SeenClientAnswerMaster AM on AM.EstablishmentId=E.id ANd (AM.IsDeleted=0 or AM.IsDeleted=null)
inner join [SeenClientAnswers] A on A.SeenclientAnswerMasterId=AM.id
inner join SeenClientQuestions Q on Q.id=A.QuestionId and Q.id in(33623,33453,35008)
left outer join dbo.[Appuser] u on u.id=AM.CreatedBy and U.id<>4163

left outer join SeenClientAnswerChild SAC on SAC.SeenClientAnswerMasterId=AM.Id
left outer join ContactDetails CD on CD.contactMasterid= (case when AM.IsSubmittedForGroup=1 then SAC.ContactMasterId else AM.ContactMasterid end) and CD.contactQuestionId=2929
/*Where (G.Id=477 and EG.Id =4289
ANd (AM.IsDeleted=0 or AM.IsDeleted=null)) --and (AM.IsDisabled=0 or AM.IsDisabled is null)and  
and Q.id in(33623,33453,35008)  */
)S
pivot(
Max(Answer)
For  Question In (
[Time taken],
[Meeting Summary],
[Company]
))P


union all
select Activity,CapturedDate,UserId,UserName,case when Customer is null or Customer ='' then [Company ] else Customer end as Customer,[Time Taken],[Meeting Summary]
from
(

select 

EG.EstablishmentGroupName as Activity,dateadd(MINUTE,AM.TimeOffSet,AM.CreatedOn) as CapturedDate,
A.Detail as Answer,

Q.ShortName as Question ,U.id as UserId, u.name as UserName,
CD.Detail as Customer 
from dbo.[Group] G
inner join EstablishmentGroup EG on G.id=EG.groupid and G.Id=477 and EG.Id =4305
inner join Establishment E on  E.EstablishmentGroupId=EG.Id
inner join SeenClientAnswerMaster AM on AM.EstablishmentId=E.id ANd (AM.IsDeleted=0 or AM.IsDeleted=null)
inner join [SeenClientAnswers] A on A.SeenclientAnswerMasterId=AM.id
inner join SeenClientQuestions Q on Q.id=A.QuestionId and  Q.id in (33863,33492,35007)
left outer join dbo.[Appuser] u on u.id=AM.CreatedBy and U.id<>4163
left outer join SeenClientAnswerChild SAC on SAC.SeenClientAnswerMasterId=AM.Id
left outer join ContactDetails CD on CD.contactMasterid= (case when AM.IsSubmittedForGroup=1 then SAC.ContactMasterId else AM.ContactMasterid end) and CD.contactQuestionId=2929
/*Where (G.Id=477 and EG.Id =4305
ANd (AM.IsDeleted=0 or AM.IsDeleted=null))-- and (AM.IsDisabled=0 or AM.IsDisabled is null) 

and Q.id in (33863,33492,35007)*/
)S
pivot(
Max(Answer)
For  Question In (
[Meeting Summary],
[Time Taken],
[Company ]
))P
))Y on X.Userid=Y.userid and convert(date,X.CapturedDate,104)=convert(date,Y.CapturedDate,104)
) B
on A.referenceno=B.SeenClientAnswerMasterId



