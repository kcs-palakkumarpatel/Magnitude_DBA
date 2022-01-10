

CREATE view [dbo].[MassliftDailyPlanFeedback]
as
select 
EstablishmentName,CapturedDate,ReferenceNo,
IsPositive,Status,PI,
UserId,UserName,RepeatCount,
[Accomplish Goal],
[Company Name],
[Description of wor],
[If applicable: Rea],
[Improvements],
[Not achieve goals],
[Progress],
[Time taken],
[Time Travelled ],
[Type of task:],
SeenClientAnswerMasterId
from(
select 

E.EstablishmentName,dateadd(MINUTE,AM.TimeOffSet,AM.CreatedOn) as CapturedDate,AM.id as ReferenceNo,
AM.IsPositive,AM.IsResolved as Status,AM.PI,
A.Detail as Answer

,Q.ShortName as Question ,U.Id as UserId, u.name as UserName,A.RepeatCount,
AM.Longitude,AM.Latitude,AM.seenclientanswermasterid
from dbo.[Group] G
inner join EstablishmentGroup EG on G.id=EG.groupid
inner join Establishment E on  E.EstablishmentGroupId=EG.Id
inner join AnswerMaster AM on AM.EstablishmentId=E.id
inner join [Answers] A on A.AnswerMasterId=AM.id
inner join Questions Q on Q.id=A.QuestionId
left outer join dbo.[Appuser] u on u.id=AM.CreatedBy

Where (G.Id=463 and EG.Id =3837
ANd (AM.IsDeleted=0 or AM.IsDeleted=null)) and (AM.IsDisabled=0 or AM.IsDisabled is null) 
And Q.IsRequiredInBI=1 
 

) S
Pivot (
Max(Answer)
For  Question In (
[Accomplish Goal],
[Company Name],
[Description of wor],
[If applicable: Rea],
[Improvements],
[Not achieve goals],
[Progress],
[Time taken],
[Time Travelled ],
[Type of task:]
))P

/*3833

3835

4029
*/

