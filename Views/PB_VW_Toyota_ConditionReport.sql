CREATE VIEW dbo.PB_VW_Toyota_ConditionReport AS

SELECT AA.Controller,
       AA.Region,
       AA.CapturedDate,
       AA.[Capture Date],
       AA.ReferenceNo,
       AA.IsResolved,
       AA.StatusName,
       AA.UserName,
       AA.Latitude,
       AA.Longitude,
       AA.PI,
       AA.Company,
       AA.Model,
       REPLACE(AA.[Date],'1900-01-01','') AS [Date],
       AA.[Serial number],
       AA.[Indent number],
       AA.Hours,
       AA.[Valid Load Test],
       REPLACE(AA.[Next load test],'1900-01-01','') AS [Next load test],
       AA.[General unit condi],
       REPLACE(AA.[Next service due],'1900-01-01','') AS [Next service due],
       AA.[Image of forklift],
       AA.Department,
       AA.[Contact email],
       AA.Environment,
       AA.[Floot Surface:],
       AA.Yard,
       AA.[Date plate Life Span:],
       AA.[Date plate Action Required],
       AA.[Date Plate Quote],
       AA.[Date Plat Comments],
       AA.[Tyres Life Span],
       AA.[Tyres Action Required],
       AA.[Tyres Quote],
       AA.[Tyres Comments],
       AA.[Forks Life Span:],
       AA.[Forks Action Required],
       AA.[Forks Quote],
       AA.[Forks Comments],
       AA.[Chains Life Span:],
       AA.[Chains Action Required],
       AA.[Chains Quote],
       AA.[Chains Comments],
       AA.[Brakes Life Span:],
       AA.[Brakes Action Required],
       AA.[Brakes Quote],
       AA.[Brakes Comments],
       AA.[Steering Life Span:],
       AA.[Steering Action Required],
       AA.[Steering Quote],
       AA.[Steering Comments],
       AA.[Upright Life Span:],
       AA.[Upright Action Required],
       AA.[Upright quote],
       AA.[Upright Comment],
       AA.[Carriage Life Span:],
       AA.[Carriage Action Required],
       AA.[Carriage Quote],
       AA.[Carriage Comments],
       AA.[Hooter Life Span:],
       AA.[Hooter Action Required],
       AA.[Hooter Quote],
       AA.[Hooter Comments],
       AA.[Lights Life Span:],
       AA.[Lights Action Required],
       AA.[Lights Quote],
       AA.[Lights Comments],
       AA.[Exhaust Life Span:],
       AA.[Exhaust Action Required],
       AA.[Exhaust Quote],
       AA.[Exhaust Comments],
       AA.[Safety Label Life Span:],
       AA.[Safety Label Action Required],
       AA.[Safety Label Quote],
       AA.[Safety Label Comments],
       AA.[Instrumentation Life Span:],
       AA.[Instrumentation Action Required],
       AA.[Instrumentation Quote],
       AA.[Instrumentation Comments],
       AA.[Load Guard Life Span:],
       AA.[Load Guard Action Required],
       AA.[Load Guard Quote],
       AA.[Load Guard Comment],
       AA.[Wheel Nut Life Span:],
       AA.[Wheel Nut Action Required],
       AA.[Wheel Nut Quote],
       AA.[Wheel Nut Comments],
       AA.[Seat Life Span:],
       AA.[Seat Action Required],
       AA.[Seat Quote],
       AA.[Seat Comments],
       AA.[Lift Life Span:],
       AA.[Lift Action Required],
       AA.[Lift Quote],
       AA.[Lift Comments],
       AA.[Tilt Life Span:],
       AA.[Tilt Action Required],
       AA.[Tilt Quote],
       AA.[Tilt Comments],
       AA.[Paintwork Life Span:],
       AA.[Paintwork Action Required],
       AA.[Paintwork Quote],
       AA.[Paintwork Comment],
       AA.[Attachment Life Span:],
       AA.[Attachment Action Required],
       AA.[Attachment Quote],
       AA.[Attachment Comment],
       AA.[Battery Life Span:],
       AA.[Battery Action Required],
       AA.[Battery Quote],
       AA.[Battery Comments],
       AA.[FMX Life Span:],
       AA.[FMX Action Required],
       AA.[FMX Quote],
       AA.[FMX Comments],
       AA.[General Life Span:],
       AA.[General Action Required],
       AA.[General Quote],
       AA.[General Unit Comments],
       AA.[Issues Present],
       AA.[Please attach photo],
       AA.[Are you happy with the service],
       AA.[General comments],
       AA.Uniqueid,
       BB.ResponseDate,
       BB.ReferenceNo AS Refno,
       BB.[Was the quote sent?],
	   BB.[Reason for quote not being sent],
	   BB.[Specify Other reason],
	   IIF(AA.StatusName='Quote Sent' OR BB.[Was the quote sent?]='Yes','Yes',IIF(AA.StatusName<>'Quote Sent' AND BB.[Was the quote sent?] IS NULL,'Outstanding Quote',IIF(BB.[Was the quote sent?]='No','No',''))) AS ABC
	   FROM
(SELECT 
IIF(p.EstablishmentName LIKE '%-%',RTRIM(LTRIM(LEFT(p.EstablishmentName,CHARINDEX('-',p.EstablishmentName)-1))),p.EstablishmentName) AS Controller,
--EstablishmentName,
IIF(p.EstablishmentName LIKE '%-%',RTRIM(LTRIM(RIGHT(p.EstablishmentName,LEN(p.EstablishmentName)-CHARINDEX('-',p.EstablishmentName)))),p.EstablishmentName) AS Region,
--IIF(p.EstablishmentName LIKE 'Controller%',REPLACE(p.EstablishmentName,'Controller - ',''),IIF(p.EstablishmentName LIKE 'Quoting Controller%',REPLACE(p.EstablishmentName,'Quoting Controller - ',''),p.EstablishmentName)) AS Controller,
CapturedDate,CAST(CapturedDate AS DATE) AS [Capture Date],ReferenceNo,IsResolved,RTRIM(LTRIM(StatusName)) AS StatusName,UserName,p.Latitude,p.Longitude,p.PI,
[Company],[Model],
CONVERT(DATE,[Date]) AS [Date],
[Serial number],[Indent number],[Hours],[Valid Load Test],
CONVERT(DATE,[Next load test]) AS [Next load test],
[General unit condi],
CONVERT(DATE,[Next service due]) AS [Next service due],
[Image of forklift],
[Department],[Contact email],[Environment],[Floot Surface:],[Yard],[Date plate Life Span:],[Date plate Action Required],[Date Plate Quote],[Date Plat Comments],[Tyres Life Span],[Tyres Action Required],[Tyres Quote],[Tyres Comments],[Forks Life Span:],[Forks Action Required],[Forks Quote],[Forks Comments],[Chains Life Span:],[Chains Action Required],[Chains Quote],[Chains Comments],[Brakes Life Span:],[Brakes Action Required],[Brakes Quote],[Brakes Comments],[Steering Life Span:],[Steering Action Required],[Steering Quote],[Steering Comments],[Upright Life Span:],[Upright Action Required],[Upright quote],[Upright Comment],[Carriage Life Span:],[Carriage Action Required],[Carriage Quote],[Carriage Comments],[Hooter Life Span:],[Hooter Action Required],[Hooter Quote],[Hooter Comments],[Lights Life Span:],[Lights Action Required],[Lights Quote],[Lights Comments],[Exhaust Life Span:],[Exhaust Action Required],[Exhaust Quote],[Exhaust Comments],[Safety Label Life Span:],[Safety Label Action Required],[Safety Label Quote],[Safety Label Comments],[Instrumentation Life Span:],[Instrumentation Action Required],[Instrumentation Quote],[Instrumentation Comments],[Load Guard Life Span:],[Load Guard Action Required],[Load Guard Quote],[Load Guard Comment],[Wheel Nut Life Span:],[Wheel Nut Action Required],[Wheel Nut Quote],[Wheel Nut Comments],[Seat Life Span:],[Seat Action Required],[Seat Quote],[Seat Comments],[Lift Life Span:],[Lift Action Required],[Lift Quote],[Lift Comments],[Tilt Life Span:],[Tilt Action Required],[Tilt Quote],[Tilt Comments],[Paintwork Life Span:],[Paintwork Action Required],[Paintwork Quote],[Paintwork Comment],[Attachment Life Span:],[Attachment Action Required],[Attachment Quote],[Attachment Comment],[Battery Life Span:],[Battery Action Required],[Battery Quote],[Battery Comments],[FMX Life Span:],[FMX Action Required],[FMX Quote],[FMX Comments],[General Life Span:],[General Action Required],[General Quote],[General Unit Comments],[Issues Present],
[Please attach photo],
[Are you happy with the service],[General comments],
CONCAT(p.Company,p.Model,p.[Serial number],p.[Indent number]) AS Uniqueid
from (
select
E.EstablishmentName,cast(dateadd(MINUTE,AM.TimeOffSet,AM.CreatedOn) as DATETIME) as CapturedDate,AM.id as ReferenceNo,
AM.IsResolved ,es.StatusName,A.Detail as Answer,u.name as UserName,AM.Latitude,AM.Longitude,AM.PI,
CASE 
WHEN Q.Id=74260 THEN 'Environment'
WHEN Q.Id=74261 THEN 'Floot Surface:'
WHEN Q.Id=61832	THEN 'Date plate Life Span:'
WHEN Q.Id=63350	THEN 'Date plate Action Required'
WHEN Q.Id=43420	THEN 'Date Plate Quote'
WHEN Q.Id=43421	THEN 'Date Plat Comments'
WHEN Q.Id=63538	THEN 'Tyres Life Span'
WHEN Q.Id=63560	THEN 'Tyres Action Required'
WHEN Q.Id=43424	THEN 'Tyres Quote'
WHEN Q.Id=43425	THEN 'Tyres Comments'
WHEN Q.Id=63539	THEN 'Forks Life Span:'
WHEN Q.Id=63561	THEN 'Forks Action Required'
WHEN Q.Id=43428	THEN 'Forks Quote'
WHEN Q.Id=43429	THEN 'Forks Comments'
WHEN Q.Id=63540	THEN 'Chains Life Span:'
WHEN Q.Id=63562	THEN 'Chains Action Required'
WHEN Q.Id=43432	THEN 'Chains Quote'
WHEN Q.Id=43433	THEN 'Chains Comments'
WHEN Q.Id=63541	THEN 'Brakes Life Span:'
WHEN Q.Id=63563	THEN 'Brakes Action Required'
WHEN Q.Id=43436	THEN 'Brakes Quote'
WHEN Q.Id=43437	THEN 'Brakes Comments'
WHEN Q.Id=63542	THEN 'Steering Life Span:'
WHEN Q.Id=63564	THEN 'Steering Action Required'
WHEN Q.Id=43443	THEN 'Steering Quote'
WHEN Q.Id=43441	THEN 'Steering Comments'
WHEN Q.Id=63543	THEN 'Upright Life Span:'
WHEN Q.Id=63565	THEN 'Upright Action Required'
WHEN Q.Id=43445	THEN 'Upright quote'
WHEN Q.Id=43446	THEN 'Upright Comment'
WHEN Q.Id=63544	THEN 'Carriage Life Span:'
WHEN Q.Id=63566	THEN 'Carriage Action Required'
WHEN Q.Id=43449	THEN 'Carriage Quote'
WHEN Q.Id=43450	THEN 'Carriage Comments'
WHEN Q.Id=63545	THEN 'Hooter Life Span:'
WHEN Q.Id=63567	THEN 'Hooter Action Required'
WHEN Q.Id=43453	THEN 'Hooter Quote'
WHEN Q.Id=43454	THEN 'Hooter Comments'
WHEN Q.Id=63546	THEN 'Lights Life Span:'
WHEN Q.Id=63568	THEN 'Lights Action Required'
WHEN Q.Id=43457	THEN 'Lights Quote'
WHEN Q.Id=43458	THEN 'Lights Comments'
WHEN Q.Id=63547	THEN 'Exhaust Life Span:'
WHEN Q.Id=63569	THEN 'Exhaust Action Required'
WHEN Q.Id=43461	THEN 'Exhaust Quote'
WHEN Q.Id=43462	THEN 'Exhaust Comments'
WHEN Q.Id=63548	THEN 'Safety Label Life Span:'
WHEN Q.Id=63570	THEN 'Safety Label Action Required'
WHEN Q.Id=43465	THEN 'Safety Label Quote'
WHEN Q.Id=43466	THEN 'Safety Label Comments'
WHEN Q.Id=63549	THEN 'Instrumentation Life Span:'
WHEN Q.Id=63571	THEN 'Instrumentation Action Required'
WHEN Q.Id=43469	THEN 'Instrumentation Quote'
WHEN Q.Id=43470	THEN 'Instrumentation Comments'
WHEN Q.Id=63550	THEN 'Load Guard Life Span:'
WHEN Q.Id=63572	THEN 'Load Guard Action Required'
WHEN Q.Id=43473	THEN 'Load Guard Quote'
WHEN Q.Id=43474	THEN 'Load Guard Comment'
WHEN Q.Id=63551	THEN 'Wheel Nut Life Span:'
WHEN Q.Id=63573	THEN 'Wheel Nut Action Required'
WHEN Q.Id=43477	THEN 'Wheel Nut Quote'
WHEN Q.Id=43478	THEN 'Wheel Nut Comments'
WHEN Q.Id=63552	THEN 'Seat Life Span:'
WHEN Q.Id=63574	THEN 'Seat Action Required'
WHEN Q.Id=43481	THEN 'Seat Quote'
WHEN Q.Id=43482	THEN 'Seat Comments'
WHEN Q.Id=63553	THEN 'Lift Life Span:'
WHEN Q.Id=63575	THEN 'Lift Action Required'
WHEN Q.Id=43485	THEN 'Lift Quote'
WHEN Q.Id=43486	THEN 'Lift Comments'
WHEN Q.Id=63554	THEN 'Tilt Life Span:'
WHEN Q.Id=63576	THEN 'Tilt Action Required'
WHEN Q.Id=43489	THEN 'Tilt Quote'
WHEN Q.Id=43490	THEN 'Tilt Comments'
WHEN Q.Id=63555	THEN 'Paintwork Life Span:'
WHEN Q.Id=63577	THEN 'Paintwork Action Required'
WHEN Q.Id=43493	THEN 'Paintwork Quote'
WHEN Q.Id=43494	THEN 'Paintwork Comment'
WHEN Q.Id=63556	THEN 'Attachment Life Span:'
WHEN Q.Id=63578	THEN 'Attachment Action Required'
WHEN Q.Id=43497	THEN 'Attachment Quote'
WHEN Q.Id=43498	THEN 'Attachment Comment'
WHEN Q.Id=63557	THEN 'Battery Life Span:'
WHEN Q.Id=63579	THEN 'Battery Action Required'
WHEN Q.Id=43501	THEN 'Battery Quote'
WHEN Q.Id=43502	THEN 'Battery Comments'
WHEN Q.Id=63558	THEN 'FMX Life Span:'
WHEN Q.Id=63580	THEN 'FMX Action Required'
WHEN Q.Id=43505	THEN 'FMX Quote'
WHEN Q.Id=43506	THEN 'FMX Comments'
WHEN Q.Id=63559	THEN 'General Life Span:'
WHEN Q.Id=63581	THEN 'General Action Required'
WHEN Q.Id=43509	THEN 'General Quote'
WHEN Q.Id=43510	THEN 'General Unit Comments'
WHEN Q.Id=43515	THEN 'Issues Present'
WHEN Q.Id=43516	THEN 'Please attach photo'
WHEN Q.Id=64521	THEN 'Are you happy with the service'
WHEN Q.Id=66299	THEN 'General comments' ELSE Q.ShortName END AS Question
from dbo.[Group] G
inner join EstablishmentGroup EG on G.id=EG.groupid and g.id = 509 and eg.id=5317 
inner join Establishment E on  E.EstablishmentGroupId=EG.Id 
inner join SeenClientAnswerMaster AM on AM.EstablishmentId=E.id ANd (AM.IsDeleted=0 or AM.IsDeleted=null)
LEFT JOIN dbo.StatusHistory sh ON sh.Id=AM.StatusHistoryId
LEFT JOIN dbo.EstablishmentStatus es ON es.Id=sh.EstablishmentStatusId
inner join [SeenClientAnswers] A on A.SeenclientAnswerMasterId=AM.id 
inner join SeenClientQuestions Q on Q.id=A.QuestionId and Q.Id IN (45114,43363,43367,43364,44319,43366,47004,43368,66300,43412,43413,43414,43415,64295,61783,61780,61781,61832,63350,43420,43421,63538,63560,43424,43425,63539,63561,43428,43429,63540,63562,43432,43433,63541,63563,43436,43437,63542,63564,43443,43441,63543,63565,43445,43446,63544,63566,43449,43450,63545,63567,43453,43454,63546,63568,43457,43458,63547,63569,43461,43462,63548,63570,43465,43466,63549,63571,43469,43470,63550,63572,43473,43474,63551,63573,43477,43478,63552,63574,43481,43482,63553,63575,43485,43486,63554,63576,43489,43490,63555,63577,43493,43494,63556,63578,43497,43498,63557,63579,43501,43502,63558,63580,43505,43506,63559,63581,43509,43510,43515,43516,64521,66299,72185,74260,74261)
left outer join dbo.[Appuser] u on u.id=AM.CreatedBy
)s
pivot(
Max(Answer)
For  Question In (
[Company],[Model],[Date],[Serial number],[Indent number],[Hours],[Valid Load Test],[Next load test],[General unit condi],[Next service due],[Image of forklift],[Department],[Contact email],[Environment],[Floot Surface:],[Yard],[Date plate Life Span:],[Date plate Action Required],[Date Plate Quote],[Date Plat Comments],[Tyres Life Span],[Tyres Action Required],[Tyres Quote],[Tyres Comments],[Forks Life Span:],[Forks Action Required],[Forks Quote],[Forks Comments],[Chains Life Span:],[Chains Action Required],[Chains Quote],[Chains Comments],[Brakes Life Span:],[Brakes Action Required],[Brakes Quote],[Brakes Comments],[Steering Life Span:],[Steering Action Required],[Steering Quote],[Steering Comments],[Upright Life Span:],[Upright Action Required],[Upright quote],[Upright Comment],[Carriage Life Span:],[Carriage Action Required],[Carriage Quote],[Carriage Comments],[Hooter Life Span:],[Hooter Action Required],[Hooter Quote],[Hooter Comments],[Lights Life Span:],[Lights Action Required],[Lights Quote],[Lights Comments],[Exhaust Life Span:],[Exhaust Action Required],[Exhaust Quote],[Exhaust Comments],[Safety Label Life Span:],[Safety Label Action Required],[Safety Label Quote],[Safety Label Comments],[Instrumentation Life Span:],[Instrumentation Action Required],[Instrumentation Quote],[Instrumentation Comments],[Load Guard Life Span:],[Load Guard Action Required],[Load Guard Quote],[Load Guard Comment],[Wheel Nut Life Span:],[Wheel Nut Action Required],[Wheel Nut Quote],[Wheel Nut Comments],[Seat Life Span:],[Seat Action Required],[Seat Quote],[Seat Comments],[Lift Life Span:],[Lift Action Required],[Lift Quote],[Lift Comments],[Tilt Life Span:],[Tilt Action Required],[Tilt Quote],[Tilt Comments],[Paintwork Life Span:],[Paintwork Action Required],[Paintwork Quote],[Paintwork Comment],[Attachment Life Span:],[Attachment Action Required],[Attachment Quote],[Attachment Comment],[Battery Life Span:],[Battery Action Required],[Battery Quote],[Battery Comments],[FMX Life Span:],[FMX Action Required],[FMX Quote],[FMX Comments],[General Life Span:],[General Action Required],[General Quote],[General Unit Comments],[Issues Present],[Please attach photo],[Are you happy with the service],[General comments]
))p
)AA
LEFT JOIN 

(select EstablishmentName,CapturedDate,ResponseDate,SeenClientAnswerMasterId,ReferenceNo,UserName,
[Was the quote sent?],[Reason for quote not being sent],[Specify Other reason]
from (
select
E.EstablishmentName,cast(dateadd(MINUTE,cam.TimeOffSet,cam.CreatedOn) as date) as CapturedDate,dateadd(MINUTE,am.TimeOffSet,am.CreatedOn) as ResponseDate,am.id as ReferenceNo,cam.Id as SeenClientAnswerMasterId,
a.Detail as Answer,u.name as UserName,
CASE WHEN q.id=52832 THEN 'Specify Other reason' ELSE q.Questiontitle END AS Question
from dbo.[Group] g
inner join EstablishmentGroup eg on g.id=eg.groupid and g.id = 509 and eg.id=5317 
inner join Establishment e on  e.EstablishmentGroupId=eg.Id 
inner join answermaster am on am.EstablishmentId=e.id and (am.IsDeleted=0 or am.IsDeleted=null)
inner join Answers a on a.AnswerMasterId=am.id 
inner join Questions q on q.id=a.QuestionId and q.Id IN(31923,52848,52832)
left outer join dbo.[Appuser] u on u.id=am.CreatedBy
left join SeenClientAnswerMaster cam on cam.Id=am.SeenClientAnswerMasterId and (cam.IsDeleted=0 or cam.IsDeleted=null)
left outer join SeenClientAnswerChild SAC on cam.id=SAC.SeenClientAnswerMasterId WHERE cam.Id IS NOT NULL
) s
pivot(
Max(Answer)
For  Question In (
[Was the quote sent?],[Reason for quote not being sent],[Specify Other reason]
))P
)BB ON AA.ReferenceNo=BB.SeenClientAnswerMasterId
WHERE AA.UserName NOT IN ('Salisha Naidoo','Toyota Forklift Admin')

