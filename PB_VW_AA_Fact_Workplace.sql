create view  PB_VW_AA_Fact_Workplace 
as


with cte as(
Select distinct  EstablishmentName,CapturedDate,ReferenceNo,
Status,[Captured By],YEAR(CapturedDate) as'CapYear',
[Client name],
[Project Name],
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
inner join SeenClientQuestions Q on Q.id=A.QuestionId and Q.id in(41557,41212,44344,74115)
inner join dbo.[Appuser] u on u.id=AM.CreatedBy and U.IsActive=1
LEFT OUTER JOIN dbo.SeenClientAnswerChild SAC ON sac.SeenClientAnswerMasterId=am.id
) S
Pivot (
Max(Answer)
For  Question In (
[Client name],
[Project Name],
[Name of Learner],
[Learner ID]
))P 
)

select * , CASE WHEN MAX([Upload workplace a]) OVER (PARTITION BY [Key], ResponseReferenceNo) IS NOT NULL THEN 1 ELSE 0 END  AS IsUploaded 
from (
select * ,CONCAT(CapYear,[SelectedMonth]) as 'Key'
--,CASE WHEN MAX([Upload workplace a]) OVER (PARTITION BY [Key], ResponseReferenceNo) IS NOT NULL THEN 1 ELSE 0 END  AS IsUploaded 
from (

select *,iif([Please select mont]is null,datename(month,CapturedDate),[Please select mont])as [SelectedMonth]
 from

(select 
B.EstablishmentName,
B.CapturedDate,
B.CapYear,
A.RepeatCount,
B.ReferenceNo,
B.Status,
B.[Captured By],
B.[Client name],
B.[Project Name],
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
[Department],
[Please select mont],
[Upload workplace a],
[Response User]

from (
select
dateadd(MINUTE,AM.TimeOffSet,AM.CreatedOn) as ResponseDate,AM.id as ResponseReferenceNo,
AM.SeenClientAnswerMasterId,RepeatCount,
Q.ShortName as Question,A.Detail as Answer,
(SELECT TOP 1 detail FROM dbo.ContactDetails CD WHERE CD.ContactMasterId = (CASE WHEN SAM.IsSubmittedForGroup = 1 THEN SAC.ContactMasterId ELSE SAM.ContactMasterId END )AND CD.ContactQuestionid=3064) as  [Response User]
,AM.Latitude,AM.Longitude
from dbo.[Group] G
inner join EstablishmentGroup EG on G.id=EG.groupid and G.Id=507 and EG.Id =5227 
inner join Establishment E on  E.EstablishmentGroupId=EG.Id
inner join AnswerMaster AM on AM.EstablishmentId=E.id ANd AM.IsDeleted=0 
inner join [Answers] A on A.AnswerMasterId=AM.id
inner join Questions Q on Q.id=A.QuestionId AND q.Id IN (27298,59549,27788)

left outer join dbo.[Appuser] u on u.id=AM.CreatedBy and U.Isactive=1
LEFT OUTER JOIN dbo.SeenClientAnswerMaster SAM ON SAM.Id = AM.SeenClientAnswerMasterId
LEFT OUTER JOIN dbo.SeenClientAnswerChild SAC ON SAC.Id = (CASE WHEN SAM.IsSubmittedForGroup = 1 THEN AM.SeenClientAnswerChildId ELSE NULL END)



) S
Pivot (
Max(Answer)
For  Question In (
[Department],
[Please select mont],
[Upload workplace a]

))P where P.[Department]='Workplace Department'
)y on x.ReferenceNo=y.SeenClientAnswerMasterId and x.[Name of Learner]=y.[Response User])s)kk-- where ReferenceNo=1196463
--order by 2 desc



