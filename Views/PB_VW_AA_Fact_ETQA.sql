create view PB_VW_AA_Fact_ETQA


as 
select X.*,Y.*,
CASE WHEN MAX([Upload Final Schedule]) OVER (PARTITION BY [Key], ReferenceNo) IS NOT NULL THEN 1 ELSE 0 END  AS IsScheduled,
CASE WHEN MAX([Upload monthly feedback report]) OVER (PARTITION BY [Key], ReferenceNo) IS NOT NULL THEN 1 ELSE 0 END  AS IsMonthlyFeddback,
CASE WHEN MAX([Upload attendance register]) OVER (PARTITION BY [Key], ReferenceNo) IS NOT NULL THEN 1 ELSE 0 END  AS IsRegistered
from (
Select distinct  EstablishmentName,CapturedDate,CapYear,CONCAT(CapYear,[Please select the months in which class will be taking place (select multiple)]) as 'Key',ReferenceNo,
Status,[Captured By], 
[Client name],
[Project Name],
[Type of project],
[Total Number of Learners],
iif([Please select the months in which class will be taking place (select multiple)]is null,datename(month,captureddate),[Please select the months in which class will be taking place (select multiple)]) as [Please select the months in which class will be taking place (select multiple)]
--[Name of Learner],
--[Learner ID],

from(
Select distinct  EstablishmentName,CapturedDate,CapYear,ReferenceNo,
Status,[Captured By], 
[Client name],
[Project Name],
[Type of project],
[Total Number of Learners],
iif([Please select the months in which class will be taking place (select multiple)]is null,datename(month,captureddate),[Please select the months in which class will be taking place (select multiple)]) as [Please select the months in which class will be taking place (select multiple)]
--[Name of Learner],
--[Learner ID],

from(
Select distinct  EstablishmentName,CapturedDate,CapYear,ReferenceNo,
Status,[Captured By], 
[Client name],
[Project Name],
[Type of project],
[Total Number of Learners],
IIF(xx.data=''or xx.data='NULL','N/A',xx.data) AS [Please select the months in which class will be taking place (select multiple)]
--[Name of Learner],
--[Learner ID],

from(
Select distinct  EstablishmentName,CapturedDate,ReferenceNo,
Status,[Captured By],YEAR(captureddate) as'CapYear',
[Client name],
[Project Name],
[Type of project],
[Total Number of Learners],
[Please select the months in which class will be taking place (select multiple)]
--[Name of Learner],
--[Learner ID],

from(
select
E.EstablishmentName,
cast(dateadd(MINUTE,AM.TimeOffSet,AM.CreatedOn) as date)as CapturedDate,AM.id as ReferenceNo,
AM.IsResolved as Status,A.Detail as Answer,Q.QuestionTitle as Question ,u.name as [Captured By]
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
[Please select the months in which class will be taking place (select multiple)]
--[Name of Learner],
--[Learner ID]
))P )W CROSS APPLY (select Data from dbo.Split(W.[Please select the months in which class will be taking place (select multiple)],',') ) XX)x)zz)X
--where ReferenceNo=694786
left join

(select distinct
ResponseDate,
ResponseReferenceNo,
SeenClientAnswerMasterId,
[Select Your Department],
[Which Month are you uploading for],
[Final Schedule Approved and Confirmed with Client],
[Upload Final Schedule],
[Monthly Feedback Reports],
[Upload monthly feedback report],
[Attendance Registers],
[Upload attendance register],
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
inner join Questions Q on Q.id=A.QuestionId AND q.Id IN (27298,64540,64631,27310,27781,27312,27782,27313,27783)

left outer join dbo.[Appuser] u on u.id=AM.CreatedBy and U.Isactive=1
LEFT OUTER JOIN dbo.SeenClientAnswerMaster SAM ON SAM.Id = AM.SeenClientAnswerMasterId
LEFT OUTER JOIN dbo.SeenClientAnswerChild SAC ON SAC.Id = (CASE WHEN SAM.IsSubmittedForGroup = 1 THEN AM.SeenClientAnswerChildId ELSE NULL END)


) S
Pivot (
Max(Answer)
For  Question In (
[Select Your Department],
[Which Month are you uploading for],
[Final Schedule Approved and Confirmed with Client],
[Upload Final Schedule],
[Monthly Feedback Reports],
[Upload monthly feedback report],
[Attendance Registers],
[Upload attendance register]

))P where P.[Select Your Department]='ETQA Department'-- order by 1 desc
)y on x.ReferenceNo=y.SeenClientAnswerMasterId --and upper(x.[Name of Learner])=upper(y.StudentName)
--where ReferenceNo=516847


--order by 2 desc


