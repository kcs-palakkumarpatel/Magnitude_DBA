
create view PB_VW_Fact_AustroDailyPlanFeedback as

select X.*,Y.Activity,Y.Customer,Y.[Time Taken] as TimeTakenForEngagement,Y.[Type of Task:] as TypeOftaskForEngagement, Y.[Description of wor] as EngagementDescription
from
(
Select 

A.EstablishmentName,A.CapturedDate,A.ReferenceNo,
A.IsPositive,A.Status,A.PI,
A.UserId,A.UserName,A.SeenClientAnswerMasterId,
A.Longitude,A.Latitude,A.RepeatCount,

B.[Achieve Plan],
B.[Comment:],
B.[Issues Today],
B.[If yes what were t],
A.[Company Name:],
A.[Time taken],
A.[Description of wor],
A.[Task Type Plan ],
A.[Task Kind],
B.[Actual Clients ],
B.[Actual non-client],
B.[Time Travelled ],
B.[If applicable, ple]

From (
	Select * 
	from AustroDailyPlanFeedback
	where repeatcount <> 0
) A
inner Join (
	Select * 
	from AustroDailyPlanFeedback
	where repeatcount = 0
) B On A.referenceno=B.referenceno
)X
inner join 
(
(select Activity,CapturedDate,UserId,UserName,Customer,[Time Taken],[Consume Task] as [Type of Task:],[Description of wor]
from
(
select 
EG.EstablishmentGroupName as Activity,dateadd(MINUTE,AM.TimeOffSet,AM.CreatedOn) as CapturedDate,
A.Detail as Answer,

Q.ShortName as Question ,U.Id as UserId, u.name as UserName,
CD.Detail as Customer
from dbo.[Group] G
inner join EstablishmentGroup EG on G.id=EG.groupid
inner join Establishment E on  E.EstablishmentGroupId=EG.Id
inner join SeenClientAnswerMaster AM on AM.EstablishmentId=E.id
inner join [SeenClientAnswers] A on A.SeenclientAnswerMasterId=AM.id
inner join SeenClientQuestions Q on Q.id=A.QuestionId
left outer join dbo.[Appuser] u on u.id=AM.CreatedBy
left outer join ContactDetails CD on CD.contactMasterid=AM.ContactMasterid and CD.contactQuestionId=2838
Where (G.Id=462 and EG.Id =3835
ANd (AM.IsDeleted=0 or AM.IsDeleted=null)) --and (AM.IsDisabled=0 or AM.IsDisabled is null)and  
and Q.id in(33272,33334,33210)
)S
pivot(
Max(Answer)
For  Question In (
[Time Taken],
[Consume Task],
[Description of wor]
))P


union all
select Activity,CapturedDate,UserId,UserName,Customer,[Time Taken],[Equipment Task] as [Type of Task:],[Description of wor]
from
(

select 

EG.EstablishmentGroupName as Activity,dateadd(MINUTE,AM.TimeOffSet,AM.CreatedOn) as CapturedDate,
A.Detail as Answer,

Q.ShortName as Question ,U.Id as UserId, u.name as UserName,
CD.Detail as Customer
from dbo.[Group] G
inner join EstablishmentGroup EG on G.id=EG.groupid
inner join Establishment E on  E.EstablishmentGroupId=EG.Id
inner join SeenClientAnswerMaster AM on AM.EstablishmentId=E.id
inner join [SeenClientAnswers] A on A.SeenclientAnswerMasterId=AM.id
inner join SeenClientQuestions Q on Q.id=A.QuestionId
left outer join dbo.[Appuser] u on u.id=AM.CreatedBy
left outer join ContactDetails CD on CD.contactMasterid=AM.ContactMasterid and CD.contactQuestionId=2838
Where (G.Id=462 and EG.Id =4029
ANd (AM.IsDeleted=0 or AM.IsDeleted=null)) and (AM.IsDisabled=0 or AM.IsDisabled is null) 

and Q.id in (33330,33274,33205)
)S
pivot(
Max(Answer)
For  Question In (
[Time Taken],
[Equipment Task],
[Description of wor]
))P
))Y on X.Userid=Y.userid and convert(date,X.CapturedDate,104)=convert(date,Y.CapturedDate,104)
