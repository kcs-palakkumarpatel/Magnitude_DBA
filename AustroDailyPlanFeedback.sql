
CREATE view AustroDailyPlanFeedback as
select 
EstablishmentName,CapturedDate,ReferenceNo,
IsPositive,Status,PI,
UserId,UserName,SeenClientAnswerMasterId,
Longitude,Latitude,RepeatCount,

[Achieve Plan],
[Comment:],
[Issues Today],
[If yes what were t],
[Company Name:],
[Time taken],
[Description of wor],

[Task Type Plan ],
[Task Kind],
[Actual Clients ],
[Actual non-client],
[Time Travelled ],
[If applicable, ple]
from(
select 
E.EstablishmentName,dateadd(MINUTE,AM.TimeOffSet,AM.CreatedOn) as CapturedDate,AM.id as ReferenceNo,
AM.SeenClientAnswerMasterId,AM.IsPositive,AM.IsResolved as Status,AM.PI,
A.Detail as Answer

,Q.ShortName as Question ,U.Id as UserId, u.name as UserName,A.RepeatCount,
AM.Longitude,AM.Latitude
from dbo.[Group] G
inner join EstablishmentGroup EG on G.id=EG.groupid
inner join Establishment E on  E.EstablishmentGroupId=EG.Id
inner join AnswerMaster AM on AM.EstablishmentId=E.id
inner join [Answers] A on A.AnswerMasterId=AM.id
inner join Questions Q on Q.id=A.QuestionId
left outer join dbo.[Appuser] u on u.id=AM.CreatedBy


Where (G.Id=462 and EG.Id =3833
ANd (AM.IsDeleted=0 or AM.IsDeleted=null)) and (AM.IsDisabled=0 or AM.IsDisabled is null) 
and Q.id in (18116,18117,20813,20821,20984,18119,18120,21025,20231,21023,20820,21022,20235)
and U.id<>3724
and convert(date,Am.createdon,104)>=convert(date,'16-07-2019',104)
) S
Pivot (
Max(Answer)
For  Question In (
[Achieve Plan],
[Comment:],
[Issues Today],
[If yes what were t],
[Company Name:],
[Time taken],
[Description of wor],

[Task Type Plan ],
[Task Kind],
[Actual Clients ],
[Actual non-client],
[Time Travelled ],
[If applicable, ple]
))P
