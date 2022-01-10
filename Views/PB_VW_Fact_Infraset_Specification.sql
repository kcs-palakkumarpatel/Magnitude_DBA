

CREATE View [dbo].[PB_VW_Fact_Infraset_Specification] 
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
[Project Name],
[Databuild Referenc],
[Product Type],
[Product Discussed],
[Product Color],
[Quantity],
[Project Value],
[Contractor Name],
[Project Start Date],
[Product Specified ],
[Meeting Notes]

from
(
select 
EstablishmentName,CapturedDate,ReferenceNo,
IsPositive,Status,PI,
replace (Split.a.value('.','varchar(100)')  ,'&amp;','&')as Answer

, Question ,UserId, UserName,ResolvedDate,
Longitude,Latitude
from(
select 

E.EstablishmentName,dateadd(MINUTE,AM.TimeOffSet,AM.CreatedOn) as CapturedDate,AM.id as ReferenceNo,AM.IsPositive,AM.IsResolved as Status,AM.PI,
CAST ('<M>' + REPLACE(replace(A.Detail,'&','&amp;'), ',', '</M><M>') + '</M>' AS XML) AS Split_Detail

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

Where (G.Id=422 and EG.Id =4213
ANd (AM.IsDeleted=0 or AM.IsDeleted=null) and Q.IsActive=1) and (AM.IsDisabled=0 or AM.IsDisabled is null) 
and Q.IsRequiredInBI=1 --Q.id in (32846,32847,32848,32849,32856,32857,32862,32863,32864,32865,32866,32868,32869,32870,32871)
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
[Project Name],
[Databuild Referenc],
[Product Type],
[Product Discussed],
[Product Color],
[Quantity],
[Project Value],
[Contractor Name],
[Project Start Date],
[Product Specified ],
[Meeting Notes]
))p
