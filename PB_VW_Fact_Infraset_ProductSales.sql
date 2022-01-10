

CREATE View [dbo].[PB_VW_Fact_Infraset_ProductSales]
as
select
EstablishmentName,CapturedDate,ReferenceNo,
IsPositive,Status,PI,
UserId,UserName,ResolvedDate,
Longitude,Latitude ,
[Name & Surname],
[Customer Company Name],
[Mobile Number],
[Email Address],
[Customer Type],
[Project Name],
[Product Type],
[Product List],
[Color],
[Project Value],
[Meeting Outcome],
[Delivery],
[Manager Assistance],
[Additional Comment],
[Product Specified],
[Meeting Purpose]

from
(

select 

E.EstablishmentName,dateadd(MINUTE,AM.TimeOffSet,AM.CreatedOn) as CapturedDate,AM.id as ReferenceNo,
AM.IsPositive,AM.IsResolved as Status,AM.PI,
A.detail as Answer

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

Where (G.Id=422 and EG.Id =4131
ANd (AM.IsDeleted=0 or AM.IsDeleted=null) and Q.IsActive=1) and (AM.IsDisabled=0 or AM.IsDisabled is null) 
and Q.IsRequiredInBI=1 --Q.id in (32439,32440,32441,32442,32443,32444,32447,32448,32451,32452,32453,32454,32528)
union all
select
EstablishmentName,CapturedDate,ReferenceNo,
IsPositive,Status,PI,
replace(replace(Split.a.value('.','varchar(100)'),'&amp;','&' ),'&quot;','"') as Answer

, Question ,UserId, UserName,ResolvedDate,
Longitude,Latitude
from(


select 

E.EstablishmentName,dateadd(MINUTE,AM.TimeOffSet,AM.CreatedOn) as CapturedDate,AM.id as ReferenceNo,
A.SeenClientAnswerMasterId,A.SeenClientAnswerChildId,AM.IsPositive,AM.IsResolved as Status,AM.PI,
CAST ('<M>' + REPLACE(replace(replace(A.detail,'&','&amp;'),'"','&quot;'), ',', '</M><M>') + '</M>' AS XML) AS Split_Detail

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

Where (G.Id=422 and EG.Id =4131
ANd (AM.IsDeleted=0 or AM.IsDeleted=null) and Q.IsActive=1) and (AM.IsDisabled=0 or AM.IsDisabled is null) 
and Q.id in (32445,32446,32565)
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
[Customer Type],
[Project Name],
[Product Type],
[Product List],
[Color],
[Project Value],
[Meeting Outcome],
[Delivery],
[Manager Assistance],
[Additional Comment],
[Product Specified],
[Meeting Purpose]
))p

