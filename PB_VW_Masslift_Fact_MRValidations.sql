Create view PB_VW_Masslift_Fact_MRValidations as
Select Year,Month,[MR value] from Masslift_MR_Validation
union all


Select 
Year([Date]) as Year, case when MONTH(Date)=1 then 'Jan' when MONTH(Date)=2 then 'Feb' when MONTH(Date)=3 then 'Mar'when MONTH(Date)=4 then 'Apr'
when MONTH(Date)=5 then 'May' when MONTH(Date)=6 then 'Jun' when MONTH(Date)=7 then 'Jul' when MONTH(Date)=8 then 'Aug' when MONTH(Date)=9 then 'Sep'
when MONTH(Date)=10 then 'Oct' when MONTH(Date)=11 then 'Nov' when MONTH(Date)=12 then 'Dec' end as Month,
[Total sales] as [MR value]
from(

select  E.EstablishmentName,dateadd(MINUTE,AM.TimeOffSet,AM.CreatedOn) as CapturedDate,AM.id as ReferenceNo,
AM.IsPositive,AM.IsResolved as Status,AM.PI,
A.Detail as Answer
,Q.QuestionTitle as Question ,U.Id as UserId, u.name as UserName,
AM.Longitude,AM.Latitude,A.RepeatCount


from dbo.[Group] G
inner join EstablishmentGroup EG on G.id=EG.groupid and G.Id=463
inner join Establishment E on  E.EstablishmentGroupId=EG.Id  and EG.Id =5135
inner join SeenClientAnswerMaster AM on AM.EstablishmentId=E.id ANd isnull(AM.IsDeleted,0)=0 and isnull(AM.IsDisabled,0)=0
inner join [SeenClientAnswers] A on A.SeenclientAnswerMasterId=AM.id
inner join SeenClientQuestions Q on Q.id=A.QuestionId 
left outer join dbo.[Appuser] u on u.id=AM.CreatedBy

Where Q.id in(64743,64745)

) S
Pivot (
Max(Answer)
For  Question In (
[Date],
[Total sales]))P
