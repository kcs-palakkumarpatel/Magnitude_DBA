CREATE VIEW dbo.PB_VW_Masslift_NWTimesheet AS

SELECT AA.Branch,
       AA.CapturedDate,
       AA.ReferenceNo,
       AA.UserName,
       AA.RepeatCount,
       AA.Date,
       AA.Month,
       AA.Weekday,
       AA.[Start Time],
       AA.[End Time],
       AA.[Total Time],
       AA.[Start KM],
       AA.[End KM],
       AA.[Total KM],
       AA.[WIP Number],
       AA.[Type of Work],
       AA.[Comments on Entry],
       BB.ResponseDate,
       --BB.SeenClientAnswerMasterId,
       BB.ResponseNo,
       BB.Respondent,
       BB.[Timesheet Approved],
       BB.[Denied Reason] 
	   FROM 
(SELECT REPLACE(K.EstablishmentName,'ML New Timesheet - ','') AS Branch,
       CAST(K.CapturedDate AS DATE) AS CapturedDate,
       K.ReferenceNo,
       K.UserName,
       J.RepeatCount,
	   --K.Date,
       CAST(IIF(K.Date IS NULL OR K.Date='',K.CapturedDate,K.Date) AS DATE) AS [Date],
	   FORMAT(CAST(IIF(K.Date IS NULL OR K.Date='',K.CapturedDate,K.Date) AS DATE),'MMM-yyyy') AS [Month],
	   DATENAME(dw,CAST(K.Date AS DATE)) AS [Weekday],
       J.[Start Time],
       J.[End Time],
	   CONVERT(DECIMAL(18,2),DATEDIFF(MINUTE,J.[Start time],J.[End time]))/60 AS [Total Time],
       J.[Start KM],
       J.[End KM],
	   CAST(J.[End KM] AS BIGINT)-CAST(J.[Start KM] AS BIGINT) AS [Total KM],
       J.[WIP Number],
       J.[Type of Work],
       J.[Comments on Entry] 
	   FROM 
(SELECT EstablishmentName,CapturedDate,ReferenceNo,UserName,RepeatCount,
[Date],
IIF(P.[Start Time] LIKE '%,%',REPLACE(SUBSTRING([Start Time], CHARINDEX(',', [Start Time]), LEN([Start Time])), ',', ''),P.[Start Time]) AS [Start Time],
IIF(P.[End Time] LIKE '%,%',REPLACE(SUBSTRING([End Time], CHARINDEX(',', [End Time]), LEN([End Time])), ',', ''),P.[End Time]) AS [End Time],[Start KM],[End KM],[WIP Number],[Type of Work],[Comments on Entry]
From(
SELECT E.EstablishmentName,dateadd(MINUTE,AM.TimeOffSet,AM.CreatedOn) as CapturedDate,AM.id as ReferenceNo,
A.Detail as Answer,U.id as UserId, u.name as UserName,A.RepeatCount,
CASE WHEN q.Id IN (70636,70637,70810,71043,71073,70728) THEN 'Type of Work' ELSE Q.QuestionTitle END AS Question
from dbo.[Group] G
inner join EstablishmentGroup EG on G.id=EG.groupid and g.id = 463 and eg.id=7403 
inner join Establishment E on  E.EstablishmentGroupId=EG.Id 
inner join SeenClientAnswerMaster AM on AM.EstablishmentId=E.id ANd (AM.IsDeleted=0 or AM.IsDeleted=null)
inner join [SeenClientAnswers] A on A.SeenclientAnswerMasterId=AM.id 
inner join SeenClientQuestions Q on Q.id=A.QuestionId and q.id in (70624,70625,70628,70630,70631,70729,71127,73988,70636,70637,70810,71043,71073,70728)
left outer join dbo.[Appuser] u on u.id=AM.CreatedBy
left outer join SeenClientAnswerChild SAC on AM.id=SAC.SeenClientAnswerMasterId WHERE A.RepeatCount<>0
)S
pivot(
Max(Answer)
For  Question In (
[Date],[Start Time],[End Time],[Start KM],[End KM],[WIP Number],[Type of Work],[Comments on Entry]
))P
)J

FULL JOIN 

(SELECT EstablishmentName,CapturedDate,ReferenceNo,UserName,RepeatCount,
[Date],[Start Time],[End Time],[Start KM],[End KM],[WIP Number],[Type of Work],[Comments on Entry]
From(
SELECT E.EstablishmentName,dateadd(MINUTE,AM.TimeOffSet,AM.CreatedOn) as CapturedDate,AM.id as ReferenceNo,
A.Detail as Answer,U.id as UserId, u.name as UserName,A.RepeatCount,
CASE WHEN q.Id IN (70636,70637,70810,71043,71073,70728) THEN 'Type of Work' ELSE Q.QuestionTitle END AS Question
from dbo.[Group] G
inner join EstablishmentGroup EG on G.id=EG.groupid and g.id = 463 and eg.id=7403 
inner join Establishment E on  E.EstablishmentGroupId=EG.Id 
inner join SeenClientAnswerMaster AM on AM.EstablishmentId=E.id ANd (AM.IsDeleted=0 or AM.IsDeleted=null)
inner join [SeenClientAnswers] A on A.SeenclientAnswerMasterId=AM.id 
inner join SeenClientQuestions Q on Q.id=A.QuestionId and q.id in (70624,70625,70628,70630,70631,70729,71127,73988,70636,70637,70810,71043,71073,70728)
left outer join dbo.[Appuser] u on u.id=AM.CreatedBy
left outer join SeenClientAnswerChild SAC on AM.id=SAC.SeenClientAnswerMasterId WHERE A.RepeatCount=0
)S
pivot(
Max(Answer)
For  Question In (
[Date],[Start Time],[End Time],[Start KM],[End KM],[WIP Number],[Type of Work],[Comments on Entry]
))P
)K ON K.ReferenceNo = J.ReferenceNo
)AA

LEFT JOIN 

(SELECT CAST(ResponseDate AS DATE) AS ResponseDate,SeenClientAnswerMasterId,ResponseNo,P.Respondent,
[Timesheet Approved],[Denied Reason]
FROM (
SELECT
E.EstablishmentName,DATEADD(MINUTE,am.TimeOffSet,am.CreatedOn) AS ResponseDate,am.id AS ResponseNo,cam.Id AS SeenClientAnswerMasterId,
a.Detail AS Answer,q.ShortName AS Question,
(SELECT TOP 1 cd.Detail FROM ContactDetails CD WHERE   CD.ContactMasterId=(case when cam.IsSubmittedForGroup=1 then SAC.ContactMasterId  else cam.ContactMasterId end) and CD.IsDeleted = 0 and CD.Detail<>'' 
and CD.contactQuestionId=2839
)+' '+
(SELECT TOP 1 cd.Detail FROM ContactDetails CD WHERE   CD.ContactMasterId=(case when cam.IsSubmittedForGroup=1 then SAC.ContactMasterId  else cam.ContactMasterId end) and CD.IsDeleted = 0 and CD.Detail<>'' 
and CD.contactQuestionId=2840
) as Respondent
FROM dbo.[Group] g
INNER JOIN EstablishmentGroup eg ON g.id=eg.groupid AND g.id = 463 AND eg.id=7403
INNER JOIN Establishment e ON  e.EstablishmentGroupId=eg.Id 
INNER JOIN answermaster am ON am.EstablishmentId=e.id AND (am.IsDeleted=0 OR am.IsDeleted=NULL)
INNER JOIN Answers a ON a.AnswerMasterId=am.id 
INNER JOIN Questions q ON q.id=a.QuestionId AND q.id IN (56405,56406)
LEFT OUTER JOIN dbo.[Appuser] u ON u.id=am.CreatedBy
LEFT JOIN SeenClientAnswerMaster cam ON cam.Id=am.SeenClientAnswerMasterId AND (cam.IsDeleted=0 OR cam.IsDeleted=NULL)
LEFT JOIN dbo.SeenClientAnswerChild SAC ON SAC.Id=am.SeenClientAnswerChildId
) s
pivot(
Max(Answer)
For  Question In (
[Timesheet Approved],[Denied Reason]
))P 
)BB ON AA.ReferenceNo=BB.SeenClientAnswerMasterId
WHERE AA.UserName NOT IN ('Masslift Admin','Masslift Test User')

