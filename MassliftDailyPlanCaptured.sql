


CREATE view [dbo].[MassliftDailyPlanCaptured]
as
select 
EstablishmentName,CapturedDate,ReferenceNo,
IsPositive,Status,PI,
UserId,UserName,RepeatCount,
[Time planned today],
[Productivity %],
[Require Assistance],
[Description: ],
[General Descriptio],
[Customer name: ],
[Whats The Plan],
[Time planned ]

from(
select 

E.EstablishmentName,dateadd(MINUTE,AM.TimeOffSet,AM.CreatedOn) as CapturedDate,AM.id as ReferenceNo,
A.SeenClientAnswerMasterId,A.SeenClientAnswerChildId,AM.IsPositive,AM.IsResolved as Status,AM.PI,
A.Detail as Answer

,Q.ShortName as Question ,U.Id as UserId, u.name as UserName,A.RepeatCount,
AM.Longitude,AM.Latitude
from dbo.[Group] G
inner join EstablishmentGroup EG on G.id=EG.groupid
inner join Establishment E on  E.EstablishmentGroupId=EG.Id
inner join SeenClientAnswerMaster AM on AM.EstablishmentId=E.id
inner join [SeenClientAnswers] A on A.SeenclientAnswerMasterId=AM.id
inner join SeenClientQuestions Q on Q.id=A.QuestionId
left outer join dbo.[Appuser] u on u.id=AM.CreatedBy
Where (G.Id=463 and EG.Id =3837
ANd (AM.IsDeleted=0 or AM.IsDeleted=null)) and (AM.IsDisabled=0 or AM.IsDisabled is null) 
And Q.IsRequiredInBI=1

 

) S
Pivot (
Max(Answer)
For  Question In (
[Time planned today],
[Productivity %],
[Require Assistance],
[Description: ],
[General Descriptio],
[Customer name: ],
[Whats The Plan],
[Time planned ]
))P

/*3833

3835

4029
*/

