create view PB_VW_AA_Fact_PTGroupRepetitivecapture
as 

WITH cte AS(
Select Establishment,
CapturedDate,
ReferenceNo,
IsPositive,
FormStatus,
UserName,
Longitude,
Latitude,
RepeatCount,
[Client name],
[Order Confirmation],
[Region | Client],
[Project Name],
[Num Learners],
[Learner ID],
[Learnership] as [Student Name],
[NQF],
[Cost per learner ],
[Comments on above],
[Distance learning/]
 from(

 


select E.EstablishmentName as Establishment,
dateadd(MINUTE,AM.TimeOffSet,AM.CreatedOn) as CapturedDate,AM.id as ReferenceNo,
AM.IsPositive,AM.IsResolved as FormStatus,
A.Detail as Answer,Q.ShortName as Question , u.name as UserName,
AM.Longitude,AM.Latitude,A.RepeatCount

 

from dbo.[Group] G
inner join EstablishmentGroup EG on G.id=EG.groupid
inner join Establishment E on  E.EstablishmentGroupId=EG.Id
inner join SeenClientAnswerMaster AM on AM.EstablishmentId=E.id and E.isdeleted=0
inner join [SeenClientAnswers] A on A.SeenclientAnswerMasterId=AM.id
inner join SeenClientQuestions Q on Q.id=A.QuestionId
inner join dbo.[Appuser] u on u.id=AM.CreatedBy

 

where G.id=507
and EG.id=5227 and Q.id in(41557,41210,41211,41212,41213,44343,44344,44345,44346,44348,69616)
and (AM.isdeleted is null or AM.isdeleted=0)

 

)S 
pivot(Max(Answer)
for Question in
([Client name],
[Order Confirmation],
[Region | Client],
[Project Name],
[Num Learners],
[Learner ID],
[Learnership],
[NQF],
[Cost per learner ],
[Comments on above],
[Distance learning/]
))P
 )

 
 SELECT 
B.Establishment,
B.CapturedDate,
B.ReferenceNo,
B.IsPositive,
B.FormStatus,
B.UserName,
B.Longitude,
B.Latitude,
A.RepeatCount,
B.[Client name],
B.[Order Confirmation],
B.[Region | Client],
B.[Project Name],
B.[Num Learners],
A.[Learner ID],
A.[Student Name],
A.[NQF],
A.[Cost per learner ],
A.[Comments on above],
A.[Distance learning/]
 FROM
 (SELECT * FROM cte WHERE cte.RepeatCount<>0)A 
 RIGHT OUTER JOIN
  ( SELECT * FROM cte WHERE cte.RepeatCount=0)B ON A.ReferenceNo=B.ReferenceNo



