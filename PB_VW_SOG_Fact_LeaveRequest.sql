

create view PB_VW_SOG_Fact_LeaveRequest as
WITH DateRange
AS 
(
select 
EstablishmentName,CapturedDate,ReferenceNo,
IsPositive,Status,
UserId,UserName,

Convert(date,[Leave FROM]) as[Leave FROM] ,
Convert(date,[Leave TO]) as [Leave TO],
[Total Days],
[Take Over],
[Additional Comment],
ResponseReference,
[Total Leave Days],
[Replacement],
[Leave Approved],
ResponseComments  from(
select A.*,

B.referenceno as ResponseReference,
B.[Total Leave Days],
B.[Replacement],
B.[Leave Approved],
B.[Comments] as ResponseComments
from(
select * from(
select
E.EstablishmentName,dateadd(MINUTE,AM.TimeOffSet,AM.CreatedOn) as CapturedDate,AM.id as ReferenceNo,
AM.IsPositive,AM.IsResolved as Status,
A.Detail as Answer

,Q.QuestionTitle as Question ,U.id as UserId, u.name as UserName,

AM.Longitude, AM.Latitude

from dbo.[Group] G
inner join EstablishmentGroup EG on G.id=EG.groupid
inner join Establishment E on  E.EstablishmentGroupId=EG.Id
inner join SeenClientAnswerMaster AM on AM.EstablishmentId=E.id
inner join [SeenClientAnswers] A on A.SeenclientAnswerMasterId=AM.id
inner join SeenClientQuestions Q on Q.id=A.QuestionId
left outer join dbo.[Appuser] u on u.id=AM.CreatedBy
left outer join SeenClientAnswerChild SAC on AM.id=SAC.SeenClientAnswerMasterId 
Where (G.Id=487 and EG.Id =4957
ANd (AM.IsDeleted=0 or AM.IsDeleted=null)) 
and Q.id in (37791,37792,37793,37794,37795)
)S
pivot(
Max(Answer)
For  Question In (
[Leave FROM],
[Leave TO],
[Total Days],
[Take Over],
[Additional Comment]
))P 
)A 
left outer join
(select 
Max(ReferenceNo) as ReferenceNo,
SeenclientAnswerMasterid,
	max([Total Leave Days])as[Total Leave Days],
max([Replacement])as[Replacement],
max([Leave Approved])as[Leave Approved],
max([Comments])as[Comments]
from(
select

E.EstablishmentName,dateadd(MINUTE,AM.TimeOffSet,AM.CreatedOn) as CapturedDate,AM.id as ReferenceNo,
AM.IsPositive,AM.IsResolved as Status,AM.PI,AM.SeenclientAnswerMasterid,Q.Questiontitle as Question,
A.Detail as Answer


from dbo.[Group] G
inner join EstablishmentGroup EG on G.id=EG.groupid
inner join Establishment E on  E.EstablishmentGroupId=EG.Id
inner join AnswerMaster AM on AM.EstablishmentId=E.id
inner join [Answers] A on A.AnswerMasterId=AM.id
inner join Questions Q on Q.id=A.QuestionId
left outer join dbo.[Appuser] u on u.id=AM.CreatedBy
left outer join SeenClientAnswerMaster SAM on SAM.id=AM.SeenClientAnswerMasterId
	left outer join SeenClientAnswerChild SAC on SAM.id=SAC.SeenClientAnswerMasterId And SAC.Id=AM.SeenClientAnswerChildId
Where (G.Id=487 and EG.Id =4957
ANd (AM.IsDeleted=0 or AM.IsDeleted=null)) --and (AM.IsDisabled=0 or AM.IsDisabled is null) 

and Q.id in(25179,25180,25181,25182)
)S
pivot(
Max(Answer)
For  Question In (
[Total Leave Days],
[Replacement],
[Leave Approved],
[Comments]
))P 
group by SeenClientAnswerMasterId
) B on A.referenceno=B.Seenclientanswermasterid 
)X


 UNION ALL
 select
EstablishmentName,CapturedDate,ReferenceNo,
IsPositive,Status,
UserId,UserName,
dateadd(d,1,[Leave FROM]) ,
Convert(date,[Leave TO]) as [Leave TO],
[Total Days],
[Take Over],
[Additional Comment],
ResponseReference,
[Total Leave Days],
[Replacement],
[Leave Approved],
ResponseComments 
    FROM DateRange 
    WHERE [Leave FROM] < [Leave TO] 
	)
SELECT Distinct *
FROM DateRange where convert(date,[Leave FROM])<> convert(date,'1900-01-01') 
