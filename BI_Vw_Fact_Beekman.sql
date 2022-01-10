


CREATE view [dbo].[BI_Vw_Fact_Beekman]
as
select 
G.GroupName as Survey,EG.EstablishmentGroupName ,Substring(E.EstablishmentName,15,len(EstablishmentName)-14) as EstablishmentName,AM.CreatedOn as CapturedDate,AM.id as ReferenceNo,AM.IsPositive,AM.IsResolved as Status,AM.PI,A.Detail,
case when A.detail='Fair' then 'Good' when A.detail='Good' then 'Very Good' else A.detail end as Answer,Q.Id as QuestionId,Q.ShortName as Question 
from dbo.[Group] G
inner join EstablishmentGroup EG on G.id=EG.groupid
inner join Establishment E on  E.EstablishmentGroupId=EG.Id
inner join AnswerMaster AM on AM.EstablishmentId=E.id
inner join [Answers] A on A.AnswerMasterId=AM.id
inner join Questions Q on Q.id=A.QuestionId
where (G.Id=151 and EG.Id =765 and
 Q.IsRequiredInBI=1 AND (AM.IsDeleted=0 or AM.isdeleted is null)And AM.Istransferred=0)

union all

select 
G.GroupName as Survey,EG.EstablishmentGroupName ,substring(E.EstablishmentName,1,len(EstablishmentName)-19) as EstablishmentName,AM.CreatedOn as CapturedDate,AM.id as ReferenceNo,AM.IsPositive,AM.IsResolved as Status,AM.PI,A.Detail ,
case when A. Detail='1' then 'Poor'
when A. Detail='2' then 'Average' 
when A. Detail='3' then 'Good' 
when A. Detail='4' then 'Very Good' 
when A. Detail='5' then 'Excellent' end as Answer,Q.Id as QuestionId,Q.ShortName as Question 
from dbo.[Group] G
inner join EstablishmentGroup EG on G.id=EG.groupid
inner join Establishment E on  E.EstablishmentGroupId=EG.Id
inner join AnswerMaster AM on AM.EstablishmentId=E.id
inner join [Answers] A on A.AnswerMasterId=AM.id
inner join Questions Q on Q.id=A.QuestionId
where (G.Id=210 and EG.Id =1737 and
 Q.IsRequiredInBI=1 and (AM.IsDeleted=0 or AM.isdeleted is null)And AM.Istransferred=0)

union all

select Distinct
G.GroupName as Survey,EG.EstablishmentGroupName,
(Case When CharIndex(' at ',E.EstablishmentName) > 0 then substring(E.EstablishmentName,CharIndex(' at ',E.EstablishmentName)+4,1000) 
	  When CharIndex(' Food and Beverages',E.EstablishmentName) > 0 then substring(E.EstablishmentName,1, CharIndex(' Food and Beverages',E.EstablishmentName))
Else
E.EstablishmentName
End) as EstablishmentName,
AM.CreatedOn as CapturedDate,AM.id as ReferenceNo,AM.IsPositive,AM.IsResolved as Status,AM.PI,A.Detail ,
case when A.detail='Fair' then 'Good' when A.detail='Good' then 'Very Good' else A.detail end as Answer,Q.Id as QuestionId,Q.ShortName as Question
from dbo.[Group] G
inner join EstablishmentGroup EG on G.id=EG.groupid
inner join Establishment E on  E.EstablishmentGroupId=EG.Id
inner join AnswerMaster AM on AM.EstablishmentId=E.id
inner join [Answers] A on A.AnswerMasterId=AM.id
inner join Questions Q on Q.id=A.QuestionId
where (G.Id=97 and EG.Id =653 and
 Q.IsRequiredInBI=1  and (AM.IsDeleted=0 or AM.isdeleted is null)And AM.Istransferred=0)

union all

select 
GroupName as Survey,EG.EstablishmentGroupName ,case when E.EstablishmentName like '%Service%' then substring(EstablishmentName,1,len(EstablishmentName)-8) else EstablishmentName end as EstablishmentName ,AM.CreatedOn as CapturedDate,AM.id as ReferenceNo,AM.IsPositive,AM.IsResolved as Status,AM.PI,A.Detail,A.detail as Answer,Q.Id as QuestionId,Q.ShortName as Question 
from dbo.[Group] G
inner join EstablishmentGroup EG on G.id=EG.groupid
inner join Establishment E on  E.EstablishmentGroupId=EG.Id
inner join AnswerMaster AM on AM.EstablishmentId=E.id
inner join [Answers] A on A.AnswerMasterId=AM.id
inner join Questions Q on Q.id=A.QuestionId
where (G.Id=250 and EG.Id in (2411,1551)  and 
 Q.IsRequiredInBI=1 and (AM.IsDeleted=0 or AM.isdeleted is null) And AM.Istransferred=0)


union all

select
G.GroupName as Survey,EG.EstablishmentGroupName ,E.EstablishmentName,AM.CreatedOn as CapturedDate,AM.id as ReferenceNo,AM.IsPositive,AM.IsResolved as Status,AM.PI,A.Detail ,A.detail as Answer,Q.Id as QuestionId,Q.ShortName as Question 
from dbo.[Group] G
inner join EstablishmentGroup EG on G.id=EG.groupid
inner join Establishment E on  E.EstablishmentGroupId=EG.Id
inner join AnswerMaster AM on AM.EstablishmentId=E.id
inner join [Answers] A on A.AnswerMasterId=AM.id
inner join Questions Q on Q.id=A.QuestionId
where (G.Id=347 and EG.Id in (2533,2537,2539,2541,2543,2545,2547,2549,2551,2553,2555,2557,2559,2561,2563) and
 Q.IsRequiredInBI=1
  and (AM.IsDeleted=0 or AM.isdeleted is null)And AM.Istransferred=0)
