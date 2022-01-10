--Drop VIEW [PB_VW_RB_Fact_EmployeeScreening]
Create VIEW [PB_VW_RB_Fact_EmployeeScreening] as
SELECT  DISTINCT  * ,
'N/A' as [Who is this person],
'N/A' as [Where does this pe],
'N/A' as [Living with C19+],
'N/A' as [Do you have rednes],
'N/A' as [Do you have nausea],
'N/A' as [Have you travelled],
'N/A' as [Did you travel to:]
FROM(
select
E.EstablishmentName,dateadd(MINUTE,AM.TimeOffSet,AM.CreatedOn) as CapturedDate,AM.id as ReferenceNo,
AM.IsPositive,AM.IsResolved as [FormStatus],AM.PI,AM.SeenClientAnswerMasterId,
Q.ShortName as Question,cast(A.Detail as varchar(8000)) as Answer,
AM.Longitude,AM.Latitude
from [Group] G
inner join EstablishmentGroup EG on G.id=EG.groupid and G.Id=534 and EG.Id =6465 
inner join Establishment E on  E.EstablishmentGroupId=EG.Id
inner join AnswerMaster AM on AM.EstablishmentId=E.id ANd (AM.IsDeleted=0 or AM.IsDeleted=null)
inner join [Answers] A on A.AnswerMasterId=AM.id
inner join Questions Q on Q.Id=A.QuestionId and Q.id in (40884,40885,40886,40887,40889,40890,40891,40892,40893,40894,40895,40896,40897,40898,40899,40900,40901,40902,40903,40904,40905,40906)
) S
Pivot (Max(Answer)
FOR  Question In (
[Employee Number],
[Name],
[Surname],
[Mobile],
[Contact with Covid],
[Travelled],
[Where],
[Fever],
[Dry/Wet Cough],
[Sore Throat],
[Loss of Smell],
[Body Pain],
[Diarrhoea],
[Feeling Weak],
[Hard to Breathe],
[Other Symptoms],
[Please Explain],
[New Mask Needed],
[Sanitizer Needed],
[Left Rustenburg],
[When],
[Where travelled leaving rustenburg]
))P
