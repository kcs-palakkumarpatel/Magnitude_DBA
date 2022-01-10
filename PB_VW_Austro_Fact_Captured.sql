




CREATE view [dbo].[PB_VW_Austro_Fact_Captured] as


select Activity, CapturedDate,
ReferenceNo,
SalesPerson,
Longitude,
Latitude,
[Company Name:] as [Company Name],
	[Company tier],
	isnull([Brands Presented],'N/A') as[Brands Presented],
	isnull([Short Feedback:],'N/A') as [Short Feedback],
	isnull([Long feedback],'N/A') as [Long Feedback],
	isnull([Was Trevor with you during the meeting?],'N/A') as [Was Trevor with you during the meeting?]
from(
Select * from
(
select 
'Austro Machine Call' as Activity,dateadd(MINUTE,AM.TimeOffSet,AM.CreatedOn) as CapturedDate,AM.id as ReferenceNo,
 u.name as SalesPerson,AM.Longitude,AM.Latitude,Q.QuestionTitle,A.Detail
from dbo.[Group] G
inner join EstablishmentGroup EG on G.id=EG.groupid and G.Id=462
inner join Establishment E on  E.EstablishmentGroupId=EG.Id and EG.Id =4029
inner join SeenClientAnswerMaster AM on AM.EstablishmentId=E.id and isnull(AM.IsDeleted,0)=0 
inner join [SeenClientAnswers] A on A.SeenClientAnswerMasterId=AM.id
inner join SeenClientQuestions Q on Q.id=A.QuestionId and Q.IsDeleted=0
left outer join dbo.[Appuser] u on u.id=AM.CreatedBy
/*Where (G.Id=462 and EG.Id =4029
ANd (AM.IsDeleted=0 or AM.IsDeleted=null) )--and (AM.IsDisabled=0 or AM.IsDisabled is null) And Am.istransferred=0 and Q.IsDeleted=0) */
and U.id<>3724 
) S
Pivot (
	Max(Detail)
	For  QuestionTitle In (
	[Is this a Biesse callout?],
	[Company Name:],
	[Company tier],
	[Brands Presented],
	[Short Feedback:],
	[Long feedback],
	[Was Trevor with you during the meeting?]
	))P
where [Is this a Biesse callout?]='Yes'
)Z


union all


select Activity,CapturedDate,
ReferenceNo,
SalesPerson,
Longitude,
Latitude,
	[Company name:] as [Company Name],
	[Company tier:] as [Company tier],
	isnull([Brands presented:],'N/A') as[Brands Presented],
	isnull([Short feedback:],'N/A') as [Short Feedback],
	isnull([Long feedback:],'N/A') as [Long Feedback],
	'N/A' as [Was Trevor with you during the meeting?]
from(
Select * from
(
select 
'Austro Equipment Telesales' as Activity,dateadd(MINUTE,AM.TimeOffSet,AM.CreatedOn) as CapturedDate,AM.id as ReferenceNo,
 u.name as SalesPerson,AM.Longitude,AM.Latitude,Q.QuestionTitle,A.Detail
from dbo.[Group] G
inner join EstablishmentGroup EG on G.id=EG.groupid and G.Id=462 
inner join Establishment E on  E.EstablishmentGroupId=EG.Id and EG.Id =4853
inner join SeenClientAnswerMaster AM on AM.EstablishmentId=E.id and isnull(AM.IsDeleted,0)=0  
inner join [SeenClientAnswers] A on A.SeenClientAnswerMasterId=AM.id
inner join SeenClientQuestions Q on Q.id=A.QuestionId  
left outer join dbo.[Appuser] u on u.id=AM.CreatedBy
Where /*(G.Id=462 and EG.Id =4853
ANd (AM.IsDeleted=0 or AM.IsDeleted=null) )
and-- Q. IsRequiredInBI=1 
Q.id in (36616,36618,36619,36620,36621,36622)--and (AM.IsDisabled=0 or AM.IsDisabled is null) And Am.istransferred=0 and Q.IsDeleted=0) */
 U.id<>3724
) S
Pivot (
	Max(Detail)
	For  QuestionTitle In (
	[Is this a Biesse callout?],
	[Company name:],
	[Company tier:],
	[Brands presented:],
	[Short feedback:],
	[Long feedback:]
	))P
where [Is this a Biesse callout?]='Yes'
)Z

