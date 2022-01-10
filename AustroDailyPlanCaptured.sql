



CREATE view [dbo].[AustroDailyPlanCaptured] as
select 
EstablishmentName,CapturedDate,ReferenceNo,
IsPositive,Status,PI,
UserId,UserName,ResolvedDate,
Longitude,Latitude,RepeatCount,
[Name],
[Mobile],
[Email ],
[Company ],
[Company Name] as [Client Company],
[Name of person you],
[Position],
[Type of visit: ],
[Type of industry:], 
[Company Spend ],
[Contingency Commen],
[General Comment ],
[Requires Help],
[If yes, outline wh],
[Region],
[Co Name] as [NonClient Company],
[General Comments] as [NonClient Comment],
[Time Planned] as[Client Time Planned],
[Type of task] as [Client Type of Task],
[Planned Time] as [NonClient Time Planned],
[Clients today],
[Task Type] as [NonClient Task Type],
[Client Facing Time],
[Non-Client Time],
[If other, please s] as [Client Other Task Type],
[If other, please specify] as [Non Client Other Task Type]

from(
select 

E.EstablishmentName,dateadd(MINUTE,AM.TimeOffSet,AM.CreatedOn) as CapturedDate,AM.id as ReferenceNo,
A.SeenClientAnswerMasterId,A.SeenClientAnswerChildId,AM.IsPositive,AM.IsResolved as Status,AM.PI,
A.Detail as Answer

,Q.ShortName as Question ,U.Id as UserId, u.name as UserName,RD.ResolvedDate,A.RepeatCount,
AM.Longitude,AM.Latitude
from dbo.[Group] G
inner join EstablishmentGroup EG on G.id=EG.groupid
inner join Establishment E on  E.EstablishmentGroupId=EG.Id
inner join SeenClientAnswerMaster AM on AM.EstablishmentId=E.id
inner join [SeenClientAnswers] A on A.SeenclientAnswerMasterId=AM.id
inner join SeenClientQuestions Q on Q.id=A.QuestionId
left outer join dbo.[Appuser] u on u.id=AM.CreatedBy
Left Outer Join (
	Select CLA.SeenClientAnswerMasterid as ReferenceNo,max(dateadd(MINUTE,TimeOffSet,CLA.CreatedOn)) as ResolvedDate from 
	CloseLoopAction CLA 
	right outer join seenclientanswermaster SAM on SAM.Id=CLA.SeenClientAnswerMasterId
	Where (Conversation Like '%Resolved - Ref#%' or Conversation Like 'Resolved') And Conversation Not Like '%UnResolve%' and SAM.Isresolved='Resolved'
	group by CLA.SeenClientAnswerMasterId
) as RD on rD.ReferenceNo = Am.Id

Where (G.Id=462 and EG.Id =3833
ANd (AM.IsDeleted=0 or AM.IsDeleted=null)) and (AM.IsDisabled=0 or AM.IsDisabled is null) 
And Q.Id in(30049,30051,30052,30053,33340,30057,30058,30059,30060,30061,30062,30066,30067,30068,31699,33214,33341,32698,32811,33216,33217,33339,33326,33327,33333,33335,33560,33577)
and U.id<>3724
and convert(date,Am.createdon,104)>=convert(date,'16-07-2019',104)

 

) S
Pivot (
Max(Answer)
For  Question In (
[Name],
[Mobile],
[Email ],
[Company ],
[Company Name],
[Name of person you],
[Position],
[Type of visit: ],
[Type of industry:], 
[Company Spend ],
[Contingency Commen],
[General Comment ],
[Requires Help],
[If yes, outline wh],
[Region],
[Co Name],
[General Comments],
[Time Planned],
[Type of task],
[Planned Time],
[Clients today],
[Task Type],
[Client Facing Time],
[Non-Client Time],
[If other, please s],
[If other, please specify]
))P


