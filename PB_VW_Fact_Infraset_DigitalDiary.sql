



CREATE View [dbo].[PB_VW_Fact_Infraset_DigitalDiary] 
as select
EstablishmentName,CapturedDate,ReferenceNo,
IsPositive,Status,PI,
UserId,UserName,ResolvedDate,
Longitude,Latitude ,
[Name & Surname],
[Customer Company Name],
[Mobile Number],
[Email Address],
[Digital Diary],
[Date of Meeting],
[Time of Meeting],
[Meeting Location],
[Meeting With],
[Your plan for this],
[Meeting Purpose],
[Customer Name],
[Company Name]

from
(

select 

E.EstablishmentName,dateadd(MINUTE,AM.TimeOffSet,AM.CreatedOn) as CapturedDate,AM.id as ReferenceNo,
AM.IsPositive,AM.IsResolved as Status,AM.PI,
A.Detail As Answer
,Q.ShortName as Question ,U.Id as UserId, u.name as UserName,RD.ResolvedDate,
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

Where (G.Id=422 and EG.Id =4135
ANd (AM.IsDeleted=0 or AM.IsDeleted=null) and Q.IsActive=1) and (AM.IsDisabled=0 or AM.IsDisabled is null) 
and Q.IsRequiredInBI=1--Q.id in (32457,32458,32459,32460,32462,32463,32464,32465,32466,33138,33139)
union all
select 
EstablishmentName,CapturedDate,ReferenceNo,
IsPositive,Status,PI,
Split.a.value('.','varchar(100)')  as Answer

, Question ,UserId, UserName,ResolvedDate,
Longitude,Latitude
from(
select 

E.EstablishmentName,dateadd(MINUTE,AM.TimeOffSet,AM.CreatedOn) as CapturedDate,AM.id as ReferenceNo,
A.SeenClientAnswerMasterId,A.SeenClientAnswerChildId,AM.IsPositive,AM.IsResolved as Status,AM.PI,
CAST ('<M>' + REPLACE(A.Detail, ',', '</M><M>') + '</M>' AS XML) AS Split_Detail

,Q.ShortName as Question ,U.Id as UserId, u.name as UserName,RD.ResolvedDate,
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

Where (G.Id=422 and EG.Id =4135
ANd (AM.IsDeleted=0 or AM.IsDeleted=null) and Q.IsActive=1) and (AM.IsDisabled=0 or AM.IsDisabled is null) 
and Q.id in(32564,33463)

) AS X
CROSS APPLY Split_Detail.nodes ('/M') AS Split(a)
) S
Pivot (
Max(Answer)
For  Question In (
[Name & Surname],
[Customer Company Name],
[Mobile Number],
[Email Address],
[Digital Diary],
[Date of Meeting],
[Time of Meeting],
[Meeting Location],
[Meeting With],
[Your plan for this],
[Meeting Purpose],
[Customer Name],
[Company Name]

))p



