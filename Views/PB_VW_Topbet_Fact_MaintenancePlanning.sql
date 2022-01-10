
Create View PB_VW_Topbet_Fact_MaintenancePlanning  as
with cte as(select 
EstablishmentName,CapturedDate,ReferenceNo,IsPositive,Status,
UserId,UserName,Longitude,Latitude,RepeatCount,
[Planned tasks],
[Surprise tasks],
[Made easier],
[Notes for the day],
[Locations visited],
[Type of task],
[Job overview],
[From request],
[Time Spent on task],
[Comments]

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
Where (G.Id=484 and EG.Id =4633
ANd (AM.IsDeleted=0 or AM.IsDeleted=null)) --and (AM.IsDisabled=0 or AM.IsDisabled is null)
and Q.id in (35435,46427,46428,35441,46431,46432,46433,46434,46435,46436)

)S
pivot(
Max(Answer)
For  Question In (
[Planned tasks],
[Surprise tasks],
[Made easier],
[Notes for the day],
[Locations visited],
[Type of task],
[Job overview],
[From request],
[Time Spent on task],
[Comments]
))P
)



select 
yy.EstablishmentName,yy.CapturedDate,yy.ReferenceNo,yy.IsPositive,yy.Status,
yy.UserId,yy.UserName,yy.Longitude,yy.Latitude,xx.RepeatCount,
yy.[Planned tasks],
yy.[Surprise tasks],
yy.[Made easier],
yy.[Notes for the day],
xx.[Locations visited],
xx.[Type of task],
xx.[Job overview],
xx.[From request],
xx.[Time Spent on task],
xx.[Comments]

from (select * from cte where RepeatCount<>0) xx inner join (select * from cte where RepeatCount=0)yy on xx.ReferenceNo=yy.ReferenceNo

