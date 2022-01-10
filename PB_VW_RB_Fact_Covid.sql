create view PB_VW_RB_Fact_Covid as
select 'COVID Health Tracker RB FANAKALO' as Activity,
Convert(date,ResponseDate) as ResponseDate,ResponseReferenceNo,
[Name] +' '+
[Surname] as [Name],
[Mobile],
[Employee Number],
[Contact W COVID] as [Contact With Covid],
[Lesotho],
[Swaziland],
[Mozambique],
[Botswana],
[Any Overseas Count] as [Trvalled in overseas country],
[Where],
[Out of Rustenburg],
[If question 3 is y] as[if yes],
[Fever (Lo fever)] as [Fever],
[Dry cough (Khohlel] as [Cough],
[Sore throat] as [Sore Throat],
[Difficulty in brea] as [ Difficulty in Breathing],
[Persistent headach]as [Persistent headache],
[Abnormal body and] as [Abnormal body and muscle pain],
[Diarrhea (Lo ku ba]as [Diarrhea],
[Blocked or running]as[Blocked or running nose],
[Do you have anythi] as [Anything else],
Latitude,Longitude,PI
from(
select E.EstablishmentName as Establishment,
dateadd(MINUTE,AM.TimeOffSet,AM.CreatedOn) as ResponseDate,AM.id as ResponseReferenceNo,AM.Latitude,AM.Longitude,
case when A.Detail='Yes (Vuma)' then 'Yes' when A.Detail='No (Nqaba)' then 'No' else A.Detail end  as Answer,
Q.shortname as Question ,AM.PI
from dbo.[Group] G
inner join EstablishmentGroup EG on G.id=EG.groupid and G.Id=534 and EG.Id =6109
inner join Establishment E on  E.EstablishmentGroupId=EG.Id 
inner join AnswerMaster AM on AM.EstablishmentId=E.id ANd (AM.IsDeleted=0 or AM.IsDeleted=null)
inner join [Answers] A on A.AnswerMasterId=AM.id
inner join Questions Q on Q.id=A.QuestionId and  Q.id in (35868,35869,35870,35871,35757,35759,35761,36231,35762,35763,35764,35765,35766,35767,35768,35769,35770,
35771,35949,35950,35951,35952,35960)
)S
pivot(
Max(Answer)
For  Question In (
[Name],
[Surname],
[Mobile],
[Employee Number],
[Contact W COVID],
[Lesotho],
[Swaziland],
[Mozambique],
[Botswana],
[Any Overseas Count],
[Where],
[Out of Rustenburg],
[If question 3 is y],
[Do you have any of],
[Fever (Lo fever)],
[Dry cough (Khohlel],
[Sore throat],
[Difficulty in brea],
[Persistent headach],
[Abnormal body and],
[Diarrhea (Lo ku ba],
[Blocked or running],
[Do you have anythi]
))P

union all

select 'COVID Health Tracker RB' as Activity,
Convert(date,ResponseDate) as ResponseDate,ResponseReferenceNo,
[Name] +' '+
[Surname] as [Name],
[Mobile],
[Employee Number],
[Contact W COVID] as [Contact With Covid],
[Lesotho],
[Swaziland],
[Mozambique],
[Botswana],
[Any Overseas Count] as [Trvalled in overseas country],
[Where],
[Out of Rustenburg],
[Where did you trav] as[if yes],
[Fever],
[Dry Cough] as [Cough],
[Sore Throat] as [Sore Throat],
[Difficulty Breath] as [Difficulty in Breathing],
'' as [Persistent headache],
'' as [Abnormal body and muscle pain],
'' as [Diarrhea],
'' as[Blocked or running nose],
[Anything else you ] as [Anything else],
Latitude,Longitude,PI
from(
select E.EstablishmentName as Establishment,
dateadd(MINUTE,AM.TimeOffSet,AM.CreatedOn) as ResponseDate,AM.id as ResponseReferenceNo,AM.Latitude,AM.Longitude,
A.Detail as Answer,
Q.shortname as Question ,AM.PI
from dbo.[Group] G
inner join EstablishmentGroup EG on G.id=EG.groupid and G.Id=534 and EG.Id =6103
inner join Establishment E on  E.EstablishmentGroupId=EG.Id 
inner join AnswerMaster AM on AM.EstablishmentId=E.id ANd (AM.IsDeleted=0 or AM.IsDeleted=null)
inner join [Answers] A on A.AnswerMasterId=AM.id
inner join Questions Q on Q.id=A.QuestionId --and  Q.id in (35868,35869,35870,35871,35757,35759,35761,36231,35762,35763,35764,35765,35766,35767,35768,35769,35770,
--35771,35949,35950,35951,35952,35960)
)S
pivot(
Max(Answer)
For  Question In (
[Name],
[Surname],
[Mobile],
[Employee Number],
[Contact W COVID],
[Lesotho],
[Swaziland],
[Mozambique],
[Botswana],
[Any Overseas Count],
[Where],
[Out of Rustenburg],
[Where did you trav],
[Fever],
[Dry Cough],
[Sore Throat],
[Difficulty Breath],
[Other Symptoms],
[Anything else you ]
))P

