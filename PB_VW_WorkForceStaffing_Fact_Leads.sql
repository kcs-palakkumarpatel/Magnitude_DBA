Create view PB_VW_WorkForceStaffing_Fact_Leads
as






with cte as(
select 
EstablishmentName,CapturedDate,ReferenceNo,Status,RepeatCount,
[Name],
[Surname],
[Mobile],
[Landline],
[Email],
[Company],
[Your Designation/Title],
[Department],
[Preferred method of communication],
[Industry],
[Agricultural Role],
[Aviation Role],
[Construction Role],
[Food Manufacturing Role],
[Hospitality Role],
[Logistics Role],
[Manufacturing Role],
[Mining Sector],
[Mining Role],
[Office Support Role],
[Power, Oil or Gas Role],
[Print Media Role],
[Retail Role],
[Renewable Energy Solutions],
[Telecommunications Role],
[Waste Management Role],
[(OTHER) - Detail or Description],
[Quantity],
[Address or Location where the staff are required],
[Special Requests or Notes we should consider],
[Attach a copy of the job specification (Optional)],
[Date Required (Start)],
[Date Required (End)]
from(
select
E.EstablishmentName,dateadd(MINUTE,AM.TimeOffSet,AM.CreatedOn) as CapturedDate,AM.id as ReferenceNo,
A.Detail as Answer,AM.Isresolved as Status,A.RepeatCount,

Q.QuestionTitle as Question  

from dbo.[Group] G
inner join EstablishmentGroup EG on G.id=EG.groupid and G.Id=494 and EG.Id =4875
inner join Establishment E on  E.EstablishmentGroupId=EG.Id --and E.id in (27195,27196,27200,27199)
inner join AnswerMaster AM on AM.EstablishmentId=E.id ANd (AM.IsDeleted=0 or AM.IsDeleted=null)
inner join [Answers] A on A.AnswerMasterId=AM.id
inner join Questions Q on Q.id=A.QuestionId and  Q.id in (24244,24245,24246,24303,24247,24248,24301,24302,24304,24309,24347,24357,24358,24359,24360,
24361,24362,24364,24363,24365,24366,24367,24368,24369,24371,24372,24373,24348,24386,24349,
24370,24387,24388)
)S
pivot(
Max(Answer)
For  Question In (
[Name],
[Surname],
[Mobile],
[Landline],
[Email],
[Company],
[Your Designation/Title],
[Department],
[Preferred method of communication],
[Industry],
[Agricultural Role],
[Aviation Role],
[Construction Role],
[Food Manufacturing Role],
[Hospitality Role],
[Logistics Role],
[Manufacturing Role],
[Mining Sector],
[Mining Role],
[Office Support Role],
[Power, Oil or Gas Role],
[Print Media Role],
[Retail Role],
[Renewable Energy Solutions],
[Telecommunications Role],
[Waste Management Role],
[(OTHER) - Detail or Description],
[Quantity],
[Address or Location where the staff are required],
[Special Requests or Notes we should consider],
[Attach a copy of the job specification (Optional)],
[Date Required (Start)],
[Date Required (End)]
))P
)

select 
B.EstablishmentName,B.CapturedDate,B.ReferenceNo,B.Status,A.RepeatCount,
B.[Name],
B.[Surname],
B.[Mobile],
B.[Landline],
B.[Email],
B.[Company],
B.[Your Designation/Title],
B.[Department],
B.[Preferred method of communication],
A.[Industry],
A.[Agricultural Role],
A.[Aviation Role],
A.[Construction Role],
A.[Food Manufacturing Role],
A.[Hospitality Role],
A.[Logistics Role],
A.[Manufacturing Role],
A.[Mining Sector],
A.[Mining Role],
A.[Office Support Role],
A.[Power, Oil or Gas Role],
A.[Print Media Role],
A.[Retail Role],
A.[Renewable Energy Solutions],
A.[Telecommunications Role],
A.[Waste Management Role],
A.[(OTHER) - Detail or Description],
A.[Quantity],
A.[Address or Location where the staff are required],
A.[Special Requests or Notes we should consider],
A.[Attach a copy of the job specification (Optional)],
A.[Date Required (Start)],
A.[Date Required (End)]
 from
(select * from cte where RepeatCount=0) B left outer join
(select * from cte where RepeatCount<>0) A on A.ReferenceNo=B.ReferenceNo

