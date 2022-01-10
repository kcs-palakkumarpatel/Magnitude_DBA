create view PB_VW_AA_Fact_Recruitment

as 


with cte as(
Select distinct  EstablishmentName,CapturedDate,ReferenceNo,
Status,[Captured By],
[Client name],
[Project Name],
[Type of project],
[Total Number of Learners],
[Please select the months in which class will be taking place (select multiple)],
[Name of Learner],
[Learner ID],
RepeatCount
from(
select
E.EstablishmentName,
cast(dateadd(MINUTE,AM.TimeOffSet,AM.CreatedOn) as date)as CapturedDate,AM.id as ReferenceNo,
AM.IsResolved as Status,A.Detail as Answer,Q.QuestionTitle as Question ,u.name as [Captured By],RepeatCount
from dbo.[Group] G
inner join EstablishmentGroup EG on G.id=EG.groupid and G.Id=507 and EG.Id =5227 
inner join Establishment E on  E.EstablishmentGroupId=EG.Id
inner join SeenClientAnswerMaster AM on AM.EstablishmentId=E.id ANd AM.IsDeleted=0 
inner join [SeenClientAnswers] A on A.SeenclientAnswerMasterId=AM.id
inner join SeenClientQuestions Q on Q.id=A.QuestionId and Q.id in(41557,41212,69952,42382,80067,44344,74115)
inner join dbo.[Appuser] u on u.id=AM.CreatedBy and U.IsActive=1
LEFT OUTER JOIN dbo.SeenClientAnswerChild SAC ON sac.SeenClientAnswerMasterId=am.id
) S
Pivot (
Max(Answer)
For  Question In (
[Client name],
[Project Name],
[Type of project],
[Total Number of Learners],
[Please select the months in which class will be taking place (select multiple)],
[Name of Learner],
[Learner ID]
))P 
)


select * from

(select 
B.EstablishmentName,
B.CapturedDate,
A.RepeatCount,
B.ReferenceNo,
B.Status,
B.[Captured By],
B.[Client name],
B.[Project Name],
B.[Type of project],
B.[Total Number of Learners],
B.[Please select the months in which class will be taking place (select multiple)],
A.[Name of Learner],
A.[Learner ID]
  FROM 
(Select * from cte where RepeatCount=0)B left outer join (Select * from cte where RepeatCount<>0)A on A.ReferenceNo=B.ReferenceNo --where B.ReferenceNo=1020842
)x

left join

(select distinct
ResponseDate,
ResponseReferenceNo,
SeenClientAnswerMasterId,
[Type of Project] as [ResponseTypeof Project],
[Select Your Department],
[Please give us YOUR name],
REVERSE(PARSENAME(REPLACE(REVERSE([Recruitment Required (If Yes - Student Name)]), ',', '.'), 1)) AS [RecruitmentRequired],
REVERSE(PARSENAME(REPLACE(REVERSE([Recruitment Required (If Yes - Student Name)]), ',', '.'), 2)) AS [StudentName],
[Recruitment Required (If Yes - Student Name)],
[Upload CV],
[Upload ID],
[Employed?],
[Upload Bank Confirmation],
[Upload Learnership],
[Upload NQF],
[Upload Highest Qualification],
[Upload SARS],
[Disability],
[Upload Disability Letter],
[Response User]

from (
select
dateadd(MINUTE,AM.TimeOffSet,AM.CreatedOn) as ResponseDate,AM.id as ResponseReferenceNo,
AM.SeenClientAnswerMasterId,RepeatCount,
Q.QuestionTitle as Question,A.Detail as Answer,
(SELECT TOP 1 detail FROM dbo.ContactDetails CD WHERE CD.ContactMasterId = (CASE WHEN SAM.IsSubmittedForGroup = 1 THEN SAC.ContactMasterId ELSE SAM.ContactMasterId END )AND CD.ContactQuestionid=3064) as  [Response User]
,AM.Latitude,AM.Longitude
from dbo.[Group] G
inner join EstablishmentGroup EG on G.id=EG.groupid and G.Id=507 and EG.Id =5227 
inner join Establishment E on  E.EstablishmentGroupId=EG.Id
inner join AnswerMaster AM on AM.EstablishmentId=E.id ANd AM.IsDeleted=0 
inner join [Answers] A on A.AnswerMasterId=AM.id
inner join Questions Q on Q.id=A.QuestionId AND q.Id IN (58166,27298,31555,27299,27300,27500,55916,27503,27777,27779,55917,27504,27502,55918,27505,27501)

left outer join dbo.[Appuser] u on u.id=AM.CreatedBy and U.Isactive=1
LEFT OUTER JOIN dbo.SeenClientAnswerMaster SAM ON SAM.Id = AM.SeenClientAnswerMasterId
LEFT OUTER JOIN dbo.SeenClientAnswerChild SAC ON SAC.Id = (CASE WHEN SAM.IsSubmittedForGroup = 1 THEN AM.SeenClientAnswerChildId ELSE NULL END)



) S
Pivot (
Max(Answer)
For  Question In (
[Type of Project],
[Select Your Department],
[Please give us YOUR name],
[Recruitment Required (If Yes - Student Name)],
[Upload CV],
[Upload ID],
[Employed?],
[Upload Bank Confirmation],
[Upload Learnership],
[Upload NQF],
[Upload Highest Qualification],
[Upload SARS],
[Disability],
[Upload Disability Letter]

))P where P.[Select Your Department]='Recruitment'
)y on x.ReferenceNo=y.SeenClientAnswerMasterId and upper(x.[Name of Learner])=upper(y.StudentName)
--order by 2 desc


