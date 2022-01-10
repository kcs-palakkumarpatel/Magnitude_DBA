﻿
Create View PB_VW_Topbet_Fact_TrainingRequest  as
with cte as(
select A.*,B.CapturedDate as ResponseDate,B.SeenClientAnswerMasterId,
B.Name as CustomerName,
B.[Training success],
B.[Training],
B.[When can this be d],
B.[Time taken]from (

select 
EstablishmentName,CapturedDate,ReferenceNo,IsPositive,Status,
UserId,UserName,Longitude,Latitude,RepeatCount,

[Branch manager],
[Branch / Location],
[Type of Training],
[Training Needs],
[Who needs this Tra],
[Name],
[Surname],
[Mobile],
[E-Mail]

from(
select
E.EstablishmentName,dateadd(MINUTE,AM.TimeOffSet,AM.CreatedOn) as CapturedDate,AM.id as ReferenceNo,
AM.IsPositive,AM.IsResolved as Status,
A.Detail as Answer

,Q.shortname as Question ,U.id as UserId, u.name as UserName,A.RepeatCount,


AM.Longitude, AM.Latitude

from dbo.[Group] G
inner join EstablishmentGroup EG on G.id=EG.groupid
inner join Establishment E on  E.EstablishmentGroupId=EG.Id
inner join SeenClientAnswerMaster AM on AM.EstablishmentId=E.id
inner join [SeenClientAnswers] A on A.SeenclientAnswerMasterId=AM.id
inner join SeenClientQuestions Q on Q.id=A.QuestionId
left outer join dbo.[Appuser] u on u.id=AM.CreatedBy
--left outer join SeenClientAnswerChild SAC on AM.id=SAC.SeenClientAnswerMasterId 
Where (G.Id=484 and EG.Id =4703
ANd (AM.IsDeleted=0 or AM.IsDeleted=null)) --and (AM.IsDisabled=0 or AM.IsDisabled is null)
and Q.id in (35689,35678,35679,35680,35681,35683,35684,35685,35686)

)S
pivot(
Max(Answer)
For  Question In (

[Branch manager],
[Branch / Location],
[Type of Training],
[Training Needs],
[Who needs this Tra],
[Name],
[Surname],
[Mobile],
[E-Mail]
))P
)A
left outer join 
(

select 
EstablishmentName,CapturedDate,ReferenceNo,
IsPositive,Status,PI,
Name,
Email,Mobile,
[Training success],
[Training],
[When can this be d],
[Time taken],
SeenClientAnswerMasterId

from(
select
E.EstablishmentName,dateadd(MINUTE,AM.TimeOffSet,AM.CreatedOn) as CapturedDate,AM.id as ReferenceNo,
AM.IsPositive,AM.IsResolved as Status,AM.PI,AM.SeenClientAnswerMasterId,
A.Detail as Answer
,Q.ShortName as Question ,
(SELECT TOP 1 cd.Detail FROM ContactDetails CD WHERE   CD.ContactMasterId=(case when SAM.IsSubmittedForGroup=1 then SAC.ContactMasterId  else SAM.ContactMasterId end) and CD.IsDeleted = 0 and CD.Detail<>'' 
and CD.contactQuestionId=2947
) as Email,
(SELECT TOP 1 cd.Detail FROM ContactDetails CD WHERE   CD.ContactMasterId=(case when SAM.IsSubmittedForGroup=1 then SAC.ContactMasterId  else SAM.ContactMasterId end) and CD.IsDeleted = 0 and CD.Detail<>'' 
and CD.contactQuestionId=2946
) as Mobile,
(SELECT TOP 1 cd.Detail FROM ContactDetails CD WHERE   CD.ContactMasterId=(case when SAM.IsSubmittedForGroup=1 then SAC.ContactMasterId  else SAM.ContactMasterId end) and CD.IsDeleted = 0 and CD.Detail<>'' 
and CD.contactQuestionId=2944
) +' '+
(SELECT TOP 1 cd.Detail FROM ContactDetails CD WHERE   CD.ContactMasterId=(case when SAM.IsSubmittedForGroup=1 then SAC.ContactMasterId  else SAM.ContactMasterId end) and CD.IsDeleted = 0 and CD.Detail<>'' 
and CD.contactQuestionId=2945
)  as Name,
AM.Longitude,AM.Latitude


from dbo.[Group] G
inner join EstablishmentGroup EG on G.id=EG.groupid
inner join Establishment E on  E.EstablishmentGroupId=EG.Id
inner join AnswerMaster AM on AM.EstablishmentId=E.id
inner join [Answers] A on A.AnswerMasterId=AM.id
inner join Questions Q on Q.id=A.QuestionId
left outer join dbo.[Appuser] u on u.id=AM.CreatedBy
left outer join SeenClientAnswerMaster SAM on SAM.id=AM.SeenClientAnswerMasterId
	left outer join SeenClientAnswerChild SAC on SAM.id=SAC.SeenClientAnswerMasterId And SAC.Id=AM.SeenClientAnswerChildId
Where (G.Id=484 and EG.Id =4703
ANd (AM.IsDeleted=0 or AM.IsDeleted=null))-- and (AM.IsDisabled=0 or AM.IsDisabled is null) 

and Q.id in(23013,23014,23015,23016)



) S
Pivot (
Max(Answer)
For  Question In (
[Training success],
[Training],
[When can this be d],
[Time taken]
))P


) B on A.ReferenceNo=B.SeenClientAnswerMasterId
)

select 
yy.EstablishmentName,yy.CapturedDate,yy.ReferenceNo,yy.IsPositive,yy.Status,
yy.UserId,yy.UserName,yy.Longitude,yy.Latitude,xx.RepeatCount,

yy.[Branch manager],
yy.[Branch / Location],
yy.[Type of Training],
yy.[Training Needs],
yy.[Who needs this Tra],
xx.[Name],
xx.[Surname],
xx.[Mobile],
xx.[E-Mail],
yy.ResponseDate,
yy.CustomerName,
yy.[Training success],
yy.[Training],
yy.[When can this be d],
yy.[Time taken]

from (select * from cte where RepeatCount<>0) xx inner join (select * from cte where RepeatCount=0)yy on xx.ReferenceNo=yy.ReferenceNo

