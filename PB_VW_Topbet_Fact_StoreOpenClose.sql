Create View PB_VW_Topbet_Fact_StoreOpenClose  as

with cte as(

select 
EstablishmentName,CapturedDate,ReferenceNo,
IsPositive,Status,PI,RepeatCount,
Name,

Email,Mobile,
[Maintain request],
[Pay & Rec Submit],
[Overtime Requested],
[General Comments],
[Incidents],
[incident detail],
[Adhoc Exp P/Cash],
[What did you buy],
SeenClientAnswerMasterId

from(
select
E.EstablishmentName,dateadd(MINUTE,AM.TimeOffSet,AM.CreatedOn) as CapturedDate,AM.id as ReferenceNo,
AM.IsPositive,AM.IsResolved as Status,AM.PI,AM.SeenClientAnswerMasterId,A.Repeatcount,
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
Where (G.Id=484 and EG.Id =4511
ANd (AM.IsDeleted=0 or AM.IsDeleted=null)) --and (AM.IsDisabled=0 or AM.IsDisabled is null) 

and Q.id in (25705,24183,22184,22180,22204,25704,22185,22190)



) S
Pivot (
Max(Answer)
For  Question In (
[Maintain request],
[Pay & Rec Submit],
[Overtime Requested],
[General Comments],
[Incidents],
[incident detail],
[Adhoc Exp P/Cash],
[What did you buy]
))P

)


select A.*,B.CapturedDate as ResponseDate,B.SeenClientAnswerMasterId,
B.Name as CustomerName,
B.[Maintain request],
B.[Pay & Rec Submit],
B.[Overtime Requested],
B.[General Comments] as [General Comments1],
B.[Incidents],
B.[incident detail],
B.[Adhoc Exp P/Cash],
B.[What did you buy] from (

select 
EstablishmentName,CapturedDate,ReferenceNo,IsPositive,Status,PI,
UserId,UserName,Longitude,Latitude,
[Branch manager],
[Turnstile count],
[Aircons],
[AC Not Working],
[TV],
[TV Comment],
[Cust. Monitors],
[Cust. Monitors Comment],
[Staff W/Stations],
[W/Stations Broken],
[Customer Wifi],
[BetGames Displays],
[BetGames Broken],
[Branch Clean],
[Customer Furniture],
[Customer Toilets],
[Staff Kitchen Area],
[Snake queues safe?],
[Comments],
[CCTV System],
[Door Security],
[G4S Scheduled],
[G4S Scheduled Time],
[All Staff On Duty],
[Who is not on duty],
[A4 Paper Quantity],
[Till Roll (Boxes)],
[General Comments]
from(
select
E.EstablishmentName,dateadd(MINUTE,AM.TimeOffSet,AM.CreatedOn) as CapturedDate,AM.id as ReferenceNo,
AM.IsPositive,AM.IsResolved as Status,AM.PI,
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
Where (G.Id=484 and EG.Id =4511
ANd (AM.IsDeleted=0 or AM.IsDeleted=null)) --and (AM.IsDisabled=0 or AM.IsDisabled is null)
and Q.id in (35687,37044,34829,34830,34831,34832,34833,34834,34835,34836,34837,34838,34839,34845,
34846,34847,34848,34849,34850,34852,34853,34854,35328,34855,34856,35663,35664,34871)

)S
pivot(
Max(Answer)
For  Question In (
[Branch manager],
[Turnstile count],
[Aircons],
[AC Not Working],
[TV],
[TV Comment],
[Cust. Monitors],
[Cust. Monitors Comment],
[Staff W/Stations],
[W/Stations Broken],
[Customer Wifi],
[BetGames Displays],
[BetGames Broken],
[Branch Clean],
[Customer Furniture],
[Customer Toilets],
[Staff Kitchen Area],
[Snake queues safe?],
[Comments],
[CCTV System],
[Door Security],
[G4S Scheduled],
[G4S Scheduled Time],
[All Staff On Duty],
[Who is not on duty],
[A4 Paper Quantity],
[Till Roll (Boxes)],
[General Comments]
))P
)A
left outer join 
(
select 
yy.EstablishmentName,yy.CapturedDate,yy.ReferenceNo,
yy.IsPositive,yy.Status,yy.PI,xx.RepeatCount,
yy.Name,
yy.[Maintain request],
yy.[Pay & Rec Submit],
yy.[Overtime Requested],
yy.[General Comments],
yy.[Incidents],
yy.[incident detail],
yy.[Adhoc Exp P/Cash],
xx.[What did you buy],
yy.SeenClientAnswerMasterId

from (select * from cte where RepeatCount<>0) xx inner join (select * from cte where RepeatCount=0)yy on xx.ReferenceNo=yy.ReferenceNo

) B on A.ReferenceNo=B.SeenClientAnswerMasterId
