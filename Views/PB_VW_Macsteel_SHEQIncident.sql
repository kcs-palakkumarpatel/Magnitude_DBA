CREATE VIEW dbo.PB_VW_Macsteel_SHEQIncident as
SELECT 
 --EstablishmentName,
 --CapturedDate,
 ReferenceNo,
 --[Month capturing for:],
 --[Year capturing for:],
 Month,
 Divison,
 [Sub-Divison],
 [Divison EstablishmentName],
 CONVERT(DECIMAL(18,2),CASE WHEN [row] > 1 THEN 0 ELSE [Monthly hours worked:] END) AS [Monthly hours worked:],
 CONVERT(DECIMAL(18,2),CASE WHEN [row] > 1 THEN 0 ELSE [Total overtime hours worked:] END) AS [Total overtime hours worked:],
 CONVERT(DECIMAL(18,2),CASE WHEN [row] > 1 THEN 0 ELSE [Total Hours Worked] END) AS [Total Hours Worked],
 CASE WHEN [row] > 1 THEN 0 ELSE [Number of employees] END AS [Number of employees],
 CONVERT(DECIMAL(18,2),CASE WHEN [row] > 1 THEN 0 ELSE [Number of days lost] END) AS [Number of days lost],
 inc_EstablishmentName,
 inc_CapturedDate,
 CONVERT(NVARCHAR(MAX),inc_ReferenceNo) as inc_ReferenceNo,
 Status,
 --UserName,
 --CustomerName,
 --CustomerMobile,
 --CustomerEmail,
 [Person criteria],
 [Name & surname],
 [ID Number],
 [Employee number],
 Occupation,
 [Description of incident],
 [Body part affected / environmental impact / impact of disease:],
 [Body part affected],
 [Incident category],
 [Safety health & property],
 --Quality,
 Department,
 [Environment & inspections / audits],
 [Level of incident],
 --[Expected period of disablement],
 --[Date & time of incident],
 CASE WHEN [Date & time of incident] IS NULL THEN convert(date, '1-' + Month) ELSE [Date & time of incident] END AS [Date & time of incident],
 IIF([time of incident] IS NULL,'00:00:00',[time of incident]) AS [time of incident],
 [Classification of incident],
 IIF([Total Incident Costing (ZAR)] IS NULL,0,[Total Incident Costing (ZAR)]) AS [Total Incident Costing (ZAR)],
 [Age Category],
 [Shift],
 [Years of Service],
 [Period in present job]

FROM (
SELECT ROW_NUMBER() OVER (PARTITION BY ReferenceNo,[Month],[Divison EstablishmentName],[Monthly hours worked:],[Total overtime hours worked:],[Total Hours Worked],[Number of days lost] ORDER BY ReferenceNo,[Month],[Divison EstablishmentName],[Monthly hours worked:],[Total overtime hours worked:],[Total Hours Worked],[Number of days lost]) AS [Row],* 
FROM (
SELECT EstablishmentName,CapturedDate,ReferenceNo,[Month capturing for:],[Year capturing for:],
CAST([month capturing for:] AS CHAR(3))+'-'+CAST([year capturing for:] AS CHAR(4)) AS 'Month',
[Divison],[Sub-Divison],[Divison EstablishmentName],
CONVERT(DECIMAL(18,2),REPLACE(ISNULL([Monthly hours worked:],0),'',0)) AS [Monthly hours worked:],
CONVERT(DECIMAL(18,2),REPLACE(ISNULL([Total overtime hours worked:],0),'',0)) AS [Total overtime hours worked:],
CONVERT(DECIMAL(18,2),(CONVERT(DECIMAL(18,2),REPLACE(ISNULL([Monthly hours worked:],0),'',0)) +CONVERT(DECIMAL(18,2),REPLACE(ISNULL([Total overtime hours worked:],0),'',0)))) AS [Total Hours Worked],
REPLACE(ISNULL([Number of employees],0),'',0) AS [Number of employees],
REPLACE(ISNULL([Number of days lost],0),'',0) AS [Number of days lost]
FROM (
SELECT AA.EstablishmentName,AA.CapturedDate,AA.ReferenceNo,AA.[Month capturing for:],AA.[Year capturing for:],AA.Divison,AA.[Sub-Divison],AA.[Divison EstablishmentName],AA.[Monthly hours worked:],BB.[Total overtime hours worked] AS [Total overtime hours worked:],AA.[Number of employees],BB.[Number of days lost]
FROM 
(SELECT EstablishmentName,CapturedDate,ReferenceNo,[Month capturing for:],[Year capturing for:],'Head Office' AS [Divison],'Head Office' AS [Sub-Divison],'SHEQ Incident Reporting - Head Office' as [Divison EstablishmentName],CONVERT(DECIMAL(18,2),[Monthly hours worked:]) AS [Monthly hours worked:],[Number of employees]
FROM (
SELECT E.EstablishmentName,dateadd(MINUTE,AM.TimeOffSet,AM.CreatedOn) as CapturedDate,AM.id as ReferenceNo,A.Detail as Answer,Q.Questiontitle as Question 
FROM dbo.[Group] G
inner join EstablishmentGroup EG on G.id=EG.groupid and g.id = 450 and eg.id=4615 
inner join Establishment E on  E.EstablishmentGroupId=EG.Id 
inner join SeenClientAnswerMaster AM on AM.EstablishmentId=E.id ANd (AM.IsDeleted=0 or AM.IsDeleted=null)
inner join [SeenClientAnswers] A on A.SeenclientAnswerMasterId=AM.id 
inner join SeenClientQuestions Q on Q.id=A.QuestionId and q.id in (37545,37546,37550,40048)
left outer join dbo.[Appuser] u on u.id=AM.CreatedBy
left outer join SeenClientAnswerChild SAC on AM.id=SAC.SeenClientAnswerMasterId 
)s
PIVOT(
MAX(Answer)
FOR  Question In (
[Month capturing for:],[Year capturing for:],[Monthly hours worked:],[Number of employees]
))p 
)AA
LEFT JOIN 
(
select SeenClientAnswerMasterId,CONVERT(DECIMAL(18,2),[Total overtime hours worked]) AS [Total overtime hours worked],[Number of days lost]
from (
select
E.EstablishmentName,cast(dateadd(MINUTE,cam.TimeOffSet,cam.CreatedOn) as date) as CapturedDate,dateadd(MINUTE,am.TimeOffSet,am.CreatedOn) as ResponseDate,am.id as ReferenceNo,cam.Id as SeenClientAnswerMasterId,am.IsPositive,am.IsResolved,a.Detail as Answer,q.Questiontitle as Question,u.id as UserId, u.name as UserName, am.Longitude ,am.Latitude
FROM dbo.[Group] g
inner join EstablishmentGroup eg on g.id=eg.groupid and g.id = 450 and eg.id=4615 
inner join Establishment e on  e.EstablishmentGroupId=eg.Id 
inner join answermaster am on am.EstablishmentId=e.id and (am.IsDeleted=0 or am.IsDeleted=null)
inner join Answers a on a.AnswerMasterId=am.id 
inner join Questions q on q.id=a.QuestionId and q.id in (28016,30203)
left outer join dbo.[Appuser] u on u.id=am.CreatedBy
left join SeenClientAnswerMaster cam on cam.Id=am.SeenClientAnswerMasterId and (cam.IsDeleted=0 or cam.IsDeleted=null)
left outer join SeenClientAnswerChild SAC on cam.id=SAC.SeenClientAnswerMasterId 
) s
pivot(
Max(Answer)
For  Question In (
[Total overtime hours worked],[Number of days lost]
))P
)BB ON AA.ReferenceNo=BB.SeenClientAnswerMasterId

UNION ALL

SELECT AA.EstablishmentName,AA.CapturedDate,AA.ReferenceNo,AA.[Month capturing for:],AA.[Year capturing for:],AA.Divison,AA.[Sub-Divison],AA.[Divison EstablishmentName],AA.[Monthly hours worked:],BB.[Total overtime hours worked] AS [Total overtime hours worked:],AA.[Number of employees],BB.[Number of days lost]
FROM 
(SELECT EstablishmentName,CapturedDate,ReferenceNo,[Month capturing for:],[Year capturing for:],'Exports' AS [Divison],'Exports' AS [Sub-Divison],'SHEQ Incident Reporting - Exports' as [Divison EstablishmentName],CONVERT(DECIMAL(18,2),[Monthly hours worked:]) AS [Monthly hours worked:],[Number of employees]
FROM (
SELECT E.EstablishmentName,dateadd(MINUTE,AM.TimeOffSet,AM.CreatedOn) as CapturedDate,AM.id as ReferenceNo,A.Detail as Answer,Q.Questiontitle as Question 
FROM dbo.[Group] G
inner join EstablishmentGroup EG on G.id=EG.groupid and g.id = 450 and eg.id=4615 
inner join Establishment E on  E.EstablishmentGroupId=EG.Id 
inner join SeenClientAnswerMaster AM on AM.EstablishmentId=E.id ANd (AM.IsDeleted=0 or AM.IsDeleted=null)
inner join [SeenClientAnswers] A on A.SeenclientAnswerMasterId=AM.id 
inner join SeenClientQuestions Q on Q.id=A.QuestionId and q.id in (37545,37546,37554,40055)
left outer join dbo.[Appuser] u on u.id=AM.CreatedBy
left outer join SeenClientAnswerChild SAC on AM.id=SAC.SeenClientAnswerMasterId 
)s
PIVOT(
MAX(Answer)
FOR  Question In (
[Month capturing for:],[Year capturing for:],[Monthly hours worked:],[Number of employees]
))p 
)AA
LEFT JOIN 
(
select SeenClientAnswerMasterId,CONVERT(DECIMAL(18,2),[Total overtime hours worked]) AS [Total overtime hours worked],[Number of days lost]
from (
select
E.EstablishmentName,cast(dateadd(MINUTE,cam.TimeOffSet,cam.CreatedOn) as date) as CapturedDate,dateadd(MINUTE,am.TimeOffSet,am.CreatedOn) as ResponseDate,am.id as ReferenceNo,cam.Id as SeenClientAnswerMasterId,am.IsPositive,am.IsResolved,a.Detail as Answer,q.Questiontitle as Question,u.id as UserId, u.name as UserName, am.Longitude ,am.Latitude
FROM dbo.[Group] g
inner join EstablishmentGroup eg on g.id=eg.groupid and g.id = 450 and eg.id=4615 
inner join Establishment e on  e.EstablishmentGroupId=eg.Id 
inner join answermaster am on am.EstablishmentId=e.id and (am.IsDeleted=0 or am.IsDeleted=null)
inner join Answers a on a.AnswerMasterId=am.id 
inner join Questions q on q.id=a.QuestionId and q.id in (28019,30205)
left outer join dbo.[Appuser] u on u.id=am.CreatedBy
left join SeenClientAnswerMaster cam on cam.Id=am.SeenClientAnswerMasterId and (cam.IsDeleted=0 or cam.IsDeleted=null)
left outer join SeenClientAnswerChild SAC on cam.id=SAC.SeenClientAnswerMasterId 
) s
pivot(
Max(Answer)
For  Question In (
[Total overtime hours worked],[Number of days lost]
))P
)BB ON AA.ReferenceNo=BB.SeenClientAnswerMasterId

UNION ALL

SELECT AA.EstablishmentName,AA.CapturedDate,AA.ReferenceNo,AA.[Month capturing for:],AA.[Year capturing for:],AA.Divison,AA.[Sub-Divison],AA.[Divison EstablishmentName],AA.[Monthly hours worked:],BB.[Total overtime hours worked] AS [Total overtime hours worked:],AA.[Number of employees],BB.[Number of days lost]
FROM 
(SELECT EstablishmentName,CapturedDate,ReferenceNo,[Month capturing for:],[Year capturing for:],'Fluid Control' AS [Divison],'Cape Town' AS [Sub-Divison],'SHEQ Incident Reporting - Fluid Control Cape Town' as [Divison EstablishmentName]
,CONVERT(DECIMAL(18,2),[Monthly hours worked:]) AS [Monthly hours worked:],[Number of employees]
FROM (
SELECT E.EstablishmentName,dateadd(MINUTE,AM.TimeOffSet,AM.CreatedOn) as CapturedDate,AM.id as ReferenceNo,A.Detail as Answer,Q.Questiontitle as Question 
FROM dbo.[Group] G
inner join EstablishmentGroup EG on G.id=EG.groupid and g.id = 450 and eg.id=4615 
inner join Establishment E on  E.EstablishmentGroupId=EG.Id 
inner join SeenClientAnswerMaster AM on AM.EstablishmentId=E.id ANd (AM.IsDeleted=0 or AM.IsDeleted=null)
inner join [SeenClientAnswers] A on A.SeenclientAnswerMasterId=AM.id 
inner join SeenClientQuestions Q on Q.id=A.QuestionId and q.id in (37545,37546,37558,40056)
left outer join dbo.[Appuser] u on u.id=AM.CreatedBy
left outer join SeenClientAnswerChild SAC on AM.id=SAC.SeenClientAnswerMasterId 
)s
PIVOT(
MAX(Answer)
FOR  Question In (
[Month capturing for:],[Year capturing for:],[Monthly hours worked:],[Number of employees]
))p 
)AA
LEFT JOIN 
(
select SeenClientAnswerMasterId,CONVERT(DECIMAL(18,2),[Total overtime hours worked]) AS [Total overtime hours worked],[Number of days lost]
from (
select
E.EstablishmentName,cast(dateadd(MINUTE,cam.TimeOffSet,cam.CreatedOn) as date) as CapturedDate,dateadd(MINUTE,am.TimeOffSet,am.CreatedOn) as ResponseDate,am.id as ReferenceNo,cam.Id as SeenClientAnswerMasterId,am.IsPositive,am.IsResolved,a.Detail as Answer,q.Questiontitle as Question,u.id as UserId, u.name as UserName, am.Longitude ,am.Latitude
FROM dbo.[Group] g
inner join EstablishmentGroup eg on g.id=eg.groupid and g.id = 450 and eg.id=4615 
inner join Establishment e on  e.EstablishmentGroupId=eg.Id 
inner join answermaster am on am.EstablishmentId=e.id and (am.IsDeleted=0 or am.IsDeleted=null)
inner join Answers a on a.AnswerMasterId=am.id 
inner join Questions q on q.id=a.QuestionId and q.id in (28022,30207)
left outer join dbo.[Appuser] u on u.id=am.CreatedBy
left join SeenClientAnswerMaster cam on cam.Id=am.SeenClientAnswerMasterId and (cam.IsDeleted=0 or cam.IsDeleted=null)
left outer join SeenClientAnswerChild SAC on cam.id=SAC.SeenClientAnswerMasterId 
) s
pivot(
Max(Answer)
For  Question In (
[Total overtime hours worked],[Number of days lost]
))P
)BB ON AA.ReferenceNo=BB.SeenClientAnswerMasterId

UNION ALL

SELECT AA.EstablishmentName,AA.CapturedDate,AA.ReferenceNo,AA.[Month capturing for:],AA.[Year capturing for:],AA.Divison,AA.[Sub-Divison],AA.[Divison EstablishmentName],AA.[Monthly hours worked:],BB.[Total overtime hours worked] AS [Total overtime hours worked:],AA.[Number of employees],BB.[Number of days lost]
FROM 
(SELECT EstablishmentName,CapturedDate,ReferenceNo,[Month capturing for:],[Year capturing for:],'Fluid Control' AS [Divison],'Durban/Richards Bay' AS [Sub-Divison],'SHEQ Incident Reporting - Fluid Control Durban/Richards Bay' as [Divison EstablishmentName]
,CONVERT(DECIMAL(18,2),[Monthly hours worked:]) AS [Monthly hours worked:],[Number of employees]
FROM (
SELECT E.EstablishmentName,dateadd(MINUTE,AM.TimeOffSet,AM.CreatedOn) as CapturedDate,AM.id as ReferenceNo,A.Detail as Answer,Q.Questiontitle as Question 
FROM dbo.[Group] G
inner join EstablishmentGroup EG on G.id=EG.groupid and g.id = 450 and eg.id=4615 
inner join Establishment E on  E.EstablishmentGroupId=EG.Id 
inner join SeenClientAnswerMaster AM on AM.EstablishmentId=E.id ANd (AM.IsDeleted=0 or AM.IsDeleted=null)
inner join [SeenClientAnswers] A on A.SeenclientAnswerMasterId=AM.id 
inner join SeenClientQuestions Q on Q.id=A.QuestionId and q.id in (37545,37546,37561,40057)
left outer join dbo.[Appuser] u on u.id=AM.CreatedBy
left outer join SeenClientAnswerChild SAC on AM.id=SAC.SeenClientAnswerMasterId 
)s
PIVOT(
MAX(Answer)
FOR  Question In (
[Month capturing for:],[Year capturing for:],[Monthly hours worked:],[Number of employees]
))p 
)AA
LEFT JOIN 
(
select SeenClientAnswerMasterId,CONVERT(DECIMAL(18,2),[Total overtime hours worked]) AS [Total overtime hours worked],[Number of days lost]
from (
select
E.EstablishmentName,cast(dateadd(MINUTE,cam.TimeOffSet,cam.CreatedOn) as date) as CapturedDate,dateadd(MINUTE,am.TimeOffSet,am.CreatedOn) as ResponseDate,am.id as ReferenceNo,cam.Id as SeenClientAnswerMasterId,am.IsPositive,am.IsResolved,a.Detail as Answer,q.Questiontitle as Question,u.id as UserId, u.name as UserName, am.Longitude ,am.Latitude
FROM dbo.[Group] g
inner join EstablishmentGroup eg on g.id=eg.groupid and g.id = 450 and eg.id=4615 
inner join Establishment e on  e.EstablishmentGroupId=eg.Id 
inner join answermaster am on am.EstablishmentId=e.id and (am.IsDeleted=0 or am.IsDeleted=null)
inner join Answers a on a.AnswerMasterId=am.id 
inner join Questions q on q.id=a.QuestionId and q.id in (28024,30209)
left outer join dbo.[Appuser] u on u.id=am.CreatedBy
left join SeenClientAnswerMaster cam on cam.Id=am.SeenClientAnswerMasterId and (cam.IsDeleted=0 or cam.IsDeleted=null)
left outer join SeenClientAnswerChild SAC on cam.id=SAC.SeenClientAnswerMasterId 
) s
pivot(
Max(Answer)
For  Question In (
[Total overtime hours worked],[Number of days lost]
))P
)BB ON AA.ReferenceNo=BB.SeenClientAnswerMasterId

UNION ALL

SELECT AA.EstablishmentName,AA.CapturedDate,AA.ReferenceNo,AA.[Month capturing for:],AA.[Year capturing for:],AA.Divison,AA.[Sub-Divison],AA.[Divison EstablishmentName],AA.[Monthly hours worked:],BB.[Total overtime hours worked] AS [Total overtime hours worked:],AA.[Number of employees],BB.[Number of days lost]
FROM 
(SELECT EstablishmentName,CapturedDate,ReferenceNo,[Month capturing for:],[Year capturing for:],'Fluid Control' AS [Divison],'Boksburg' AS [Sub-Divison],'SHEQ Incident Reporting - Fluid Control Boksburg' as [Divison EstablishmentName]
,CONVERT(DECIMAL(18,2),[Monthly hours worked:]) AS [Monthly hours worked:],[Number of employees]
FROM (
SELECT E.EstablishmentName,dateadd(MINUTE,AM.TimeOffSet,AM.CreatedOn) as CapturedDate,AM.id as ReferenceNo,A.Detail as Answer,Q.Questiontitle as Question 
FROM dbo.[Group] G
inner join EstablishmentGroup EG on G.id=EG.groupid and g.id = 450 and eg.id=4615 
inner join Establishment E on  E.EstablishmentGroupId=EG.Id 
inner join SeenClientAnswerMaster AM on AM.EstablishmentId=E.id ANd (AM.IsDeleted=0 or AM.IsDeleted=null)
inner join [SeenClientAnswers] A on A.SeenclientAnswerMasterId=AM.id 
inner join SeenClientQuestions Q on Q.id=A.QuestionId and q.id in (37545,37546,37564,40058)
left outer join dbo.[Appuser] u on u.id=AM.CreatedBy
left outer join SeenClientAnswerChild SAC on AM.id=SAC.SeenClientAnswerMasterId 
)s
PIVOT(
MAX(Answer)
FOR  Question In (
[Month capturing for:],[Year capturing for:],[Monthly hours worked:],[Number of employees]
))p 
)AA
LEFT JOIN 
(
select SeenClientAnswerMasterId,CONVERT(DECIMAL(18,2),[Total overtime hours worked]) AS [Total overtime hours worked],[Number of days lost]
from (
select
E.EstablishmentName,cast(dateadd(MINUTE,cam.TimeOffSet,cam.CreatedOn) as date) as CapturedDate,dateadd(MINUTE,am.TimeOffSet,am.CreatedOn) as ResponseDate,am.id as ReferenceNo,cam.Id as SeenClientAnswerMasterId,am.IsPositive,am.IsResolved,a.Detail as Answer,q.Questiontitle as Question,u.id as UserId, u.name as UserName, am.Longitude ,am.Latitude
FROM dbo.[Group] g
inner join EstablishmentGroup eg on g.id=eg.groupid and g.id = 450 and eg.id=4615 
inner join Establishment e on  e.EstablishmentGroupId=eg.Id 
inner join answermaster am on am.EstablishmentId=e.id and (am.IsDeleted=0 or am.IsDeleted=null)
inner join Answers a on a.AnswerMasterId=am.id 
inner join Questions q on q.id=a.QuestionId and q.id in (28026,30211)
left outer join dbo.[Appuser] u on u.id=am.CreatedBy
left join SeenClientAnswerMaster cam on cam.Id=am.SeenClientAnswerMasterId and (cam.IsDeleted=0 or cam.IsDeleted=null)
left outer join SeenClientAnswerChild SAC on cam.id=SAC.SeenClientAnswerMasterId 
) s
pivot(
Max(Answer)
For  Question In (
[Total overtime hours worked],[Number of days lost]
))P
)BB ON AA.ReferenceNo=BB.SeenClientAnswerMasterId

UNION ALL

SELECT AA.EstablishmentName,AA.CapturedDate,AA.ReferenceNo,AA.[Month capturing for:],AA.[Year capturing for:],AA.Divison,AA.[Sub-Divison],AA.[Divison EstablishmentName],AA.[Monthly hours worked:],BB.[Total overtime hours worked] AS [Total overtime hours worked:],AA.[Number of employees],BB.[Number of days lost]
FROM 
(SELECT EstablishmentName,CapturedDate,ReferenceNo,[Month capturing for:],[Year capturing for:],'Coil Processing' AS [Divison],'East London' AS [Sub-Divison],'SHEQ Incident Reporting - Coil Processing East London' as [Divison EstablishmentName],
CONVERT(DECIMAL(18,2),[Monthly hours worked:]) AS [Monthly hours worked:],[Number of employees]
FROM (
SELECT E.EstablishmentName,dateadd(MINUTE,AM.TimeOffSet,AM.CreatedOn) as CapturedDate,AM.id as ReferenceNo,A.Detail as Answer,Q.Questiontitle as Question 
FROM dbo.[Group] G
inner join EstablishmentGroup EG on G.id=EG.groupid and g.id = 450 and eg.id=4615 
inner join Establishment E on  E.EstablishmentGroupId=EG.Id 
inner join SeenClientAnswerMaster AM on AM.EstablishmentId=E.id ANd (AM.IsDeleted=0 or AM.IsDeleted=null)
inner join [SeenClientAnswers] A on A.SeenclientAnswerMasterId=AM.id 
inner join SeenClientQuestions Q on Q.id=A.QuestionId and q.id in (37545,37546,37568,40059)
left outer join dbo.[Appuser] u on u.id=AM.CreatedBy
left outer join SeenClientAnswerChild SAC on AM.id=SAC.SeenClientAnswerMasterId 
)s
PIVOT(
MAX(Answer)
FOR  Question In (
[Month capturing for:],[Year capturing for:],[Monthly hours worked:],[Number of employees]
))p 
)AA
LEFT JOIN 
(
select SeenClientAnswerMasterId,CONVERT(DECIMAL(18,2),[Total overtime hours worked]) AS [Total overtime hours worked],[Number of days lost]
from (
select
E.EstablishmentName,cast(dateadd(MINUTE,cam.TimeOffSet,cam.CreatedOn) as date) as CapturedDate,dateadd(MINUTE,am.TimeOffSet,am.CreatedOn) as ResponseDate,am.id as ReferenceNo,cam.Id as SeenClientAnswerMasterId,am.IsPositive,am.IsResolved,a.Detail as Answer,q.Questiontitle as Question,u.id as UserId, u.name as UserName, am.Longitude ,am.Latitude
FROM dbo.[Group] g
inner join EstablishmentGroup eg on g.id=eg.groupid and g.id = 450 and eg.id=4615 
inner join Establishment e on  e.EstablishmentGroupId=eg.Id 
inner join answermaster am on am.EstablishmentId=e.id and (am.IsDeleted=0 or am.IsDeleted=null)
inner join Answers a on a.AnswerMasterId=am.id 
inner join Questions q on q.id=a.QuestionId and q.id in (28029,30213)
left outer join dbo.[Appuser] u on u.id=am.CreatedBy
left join SeenClientAnswerMaster cam on cam.Id=am.SeenClientAnswerMasterId and (cam.IsDeleted=0 or cam.IsDeleted=null)
left outer join SeenClientAnswerChild SAC on cam.id=SAC.SeenClientAnswerMasterId 
) s
pivot(
Max(Answer)
For  Question In (
[Total overtime hours worked],[Number of days lost]
))P
)BB ON AA.ReferenceNo=BB.SeenClientAnswerMasterId

UNION ALL

SELECT AA.EstablishmentName,AA.CapturedDate,AA.ReferenceNo,AA.[Month capturing for:],AA.[Year capturing for:],AA.Divison,AA.[Sub-Divison],AA.[Divison EstablishmentName],AA.[Monthly hours worked:],BB.[Total overtime hours worked] AS [Total overtime hours worked:],AA.[Number of employees],BB.[Number of days lost]
FROM 
(SELECT EstablishmentName,CapturedDate,ReferenceNo,[Month capturing for:],[Year capturing for:],'Coil Processing' AS [Divison],'Pretoria' AS [Sub-Divison],'SHEQ Incident Reporting - Coil Processing Pretoria' as [Divison EstablishmentName],
CONVERT(DECIMAL(18,2),[Monthly hours worked:]) AS [Monthly hours worked:],[Number of employees]
FROM (
SELECT E.EstablishmentName,dateadd(MINUTE,AM.TimeOffSet,AM.CreatedOn) as CapturedDate,AM.id as ReferenceNo,A.Detail as Answer,Q.Questiontitle as Question 
FROM dbo.[Group] G
inner join EstablishmentGroup EG on G.id=EG.groupid and g.id = 450 and eg.id=4615 
inner join Establishment E on  E.EstablishmentGroupId=EG.Id 
inner join SeenClientAnswerMaster AM on AM.EstablishmentId=E.id ANd (AM.IsDeleted=0 or AM.IsDeleted=null)
inner join [SeenClientAnswers] A on A.SeenclientAnswerMasterId=AM.id 
inner join SeenClientQuestions Q on Q.id=A.QuestionId and q.id in (37545,37546,37571,40060)
left outer join dbo.[Appuser] u on u.id=AM.CreatedBy
left outer join SeenClientAnswerChild SAC on AM.id=SAC.SeenClientAnswerMasterId 
)s
PIVOT(
MAX(Answer)
FOR  Question In (
[Month capturing for:],[Year capturing for:],[Monthly hours worked:],[Number of employees]
))p 
)AA
LEFT JOIN 
(
select SeenClientAnswerMasterId,CONVERT(DECIMAL(18,2),[Total overtime hours worked]) AS [Total overtime hours worked],[Number of days lost]
from (
select
E.EstablishmentName,cast(dateadd(MINUTE,cam.TimeOffSet,cam.CreatedOn) as date) as CapturedDate,dateadd(MINUTE,am.TimeOffSet,am.CreatedOn) as ResponseDate,am.id as ReferenceNo,cam.Id as SeenClientAnswerMasterId,am.IsPositive,am.IsResolved,a.Detail as Answer,q.Questiontitle as Question,u.id as UserId, u.name as UserName, am.Longitude ,am.Latitude
FROM dbo.[Group] g
inner join EstablishmentGroup eg on g.id=eg.groupid and g.id = 450 and eg.id=4615 
inner join Establishment e on  e.EstablishmentGroupId=eg.Id 
inner join answermaster am on am.EstablishmentId=e.id and (am.IsDeleted=0 or am.IsDeleted=null)
inner join Answers a on a.AnswerMasterId=am.id 
inner join Questions q on q.id=a.QuestionId and q.id in (28031,30215)
left outer join dbo.[Appuser] u on u.id=am.CreatedBy
left join SeenClientAnswerMaster cam on cam.Id=am.SeenClientAnswerMasterId and (cam.IsDeleted=0 or cam.IsDeleted=null)
left outer join SeenClientAnswerChild SAC on cam.id=SAC.SeenClientAnswerMasterId 
) s
pivot(
Max(Answer)
For  Question In (
[Total overtime hours worked],[Number of days lost]
))P
)BB ON AA.ReferenceNo=BB.SeenClientAnswerMasterId

UNION ALL

SELECT AA.EstablishmentName,AA.CapturedDate,AA.ReferenceNo,AA.[Month capturing for:],AA.[Year capturing for:],AA.Divison,AA.[Sub-Divison],AA.[Divison EstablishmentName],AA.[Monthly hours worked:],BB.[Total overtime hours worked] AS [Total overtime hours worked:],AA.[Number of employees],BB.[Number of days lost]
FROM 
(SELECT EstablishmentName,CapturedDate,ReferenceNo,[Month capturing for:],[Year capturing for:],'Coil Processing' AS [Divison],'Lady Smith' AS [Sub-Divison],'SHEQ Incident Reporting - Coil Processing Lady Smith' as [Divison EstablishmentName],
CONVERT(DECIMAL(18,2),[Monthly hours worked:]) AS [Monthly hours worked:],[Number of employees]
FROM (
SELECT E.EstablishmentName,dateadd(MINUTE,AM.TimeOffSet,AM.CreatedOn) as CapturedDate,AM.id as ReferenceNo,A.Detail as Answer,Q.Questiontitle as Question 
FROM dbo.[Group] G
inner join EstablishmentGroup EG on G.id=EG.groupid and g.id = 450 and eg.id=4615 
inner join Establishment E on  E.EstablishmentGroupId=EG.Id 
inner join SeenClientAnswerMaster AM on AM.EstablishmentId=E.id ANd (AM.IsDeleted=0 or AM.IsDeleted=null)
inner join [SeenClientAnswers] A on A.SeenclientAnswerMasterId=AM.id 
inner join SeenClientQuestions Q on Q.id=A.QuestionId and q.id in (37545,37546,37574,40061)
left outer join dbo.[Appuser] u on u.id=AM.CreatedBy
left outer join SeenClientAnswerChild SAC on AM.id=SAC.SeenClientAnswerMasterId 
)s
PIVOT(
MAX(Answer)
FOR  Question In (
[Month capturing for:],[Year capturing for:],[Monthly hours worked:],[Number of employees]
))p 
)AA
LEFT JOIN 
(
select SeenClientAnswerMasterId,CONVERT(DECIMAL(18,2),[Total overtime hours worked]) AS [Total overtime hours worked],[Number of days lost]
from (
select
E.EstablishmentName,cast(dateadd(MINUTE,cam.TimeOffSet,cam.CreatedOn) as date) as CapturedDate,dateadd(MINUTE,am.TimeOffSet,am.CreatedOn) as ResponseDate,am.id as ReferenceNo,cam.Id as SeenClientAnswerMasterId,am.IsPositive,am.IsResolved,a.Detail as Answer,q.Questiontitle as Question,u.id as UserId, u.name as UserName, am.Longitude ,am.Latitude
FROM dbo.[Group] g
inner join EstablishmentGroup eg on g.id=eg.groupid and g.id = 450 and eg.id=4615 
inner join Establishment e on  e.EstablishmentGroupId=eg.Id 
inner join answermaster am on am.EstablishmentId=e.id and (am.IsDeleted=0 or am.IsDeleted=null)
inner join Answers a on a.AnswerMasterId=am.id 
inner join Questions q on q.id=a.QuestionId and q.id in (28033,30217)
left outer join dbo.[Appuser] u on u.id=am.CreatedBy
left join SeenClientAnswerMaster cam on cam.Id=am.SeenClientAnswerMasterId and (cam.IsDeleted=0 or cam.IsDeleted=null)
left outer join SeenClientAnswerChild SAC on cam.id=SAC.SeenClientAnswerMasterId 
) s
pivot(
Max(Answer)
For  Question In (
[Total overtime hours worked],[Number of days lost]
))P
)BB ON AA.ReferenceNo=BB.SeenClientAnswerMasterId

UNION ALL

SELECT AA.EstablishmentName,AA.CapturedDate,AA.ReferenceNo,AA.[Month capturing for:],AA.[Year capturing for:],AA.Divison,AA.[Sub-Divison],AA.[Divison EstablishmentName],AA.[Monthly hours worked:],BB.[Total overtime hours worked] AS [Total overtime hours worked:],AA.[Number of employees],BB.[Number of days lost]
FROM 
(SELECT EstablishmentName,CapturedDate,ReferenceNo,[Month capturing for:],[Year capturing for:],'Coil Processing' AS [Divison],'Wadeville' AS [Sub-Divison],'SHEQ Incident Reporting - Coil Processing Wadeville' as [Divison EstablishmentName],
CONVERT(DECIMAL(18,2),[Monthly hours worked:]) AS [Monthly hours worked:],[Number of employees]
FROM (
SELECT E.EstablishmentName,dateadd(MINUTE,AM.TimeOffSet,AM.CreatedOn) as CapturedDate,AM.id as ReferenceNo,A.Detail as Answer,Q.Questiontitle as Question 
FROM dbo.[Group] G
inner join EstablishmentGroup EG on G.id=EG.groupid and g.id = 450 and eg.id=4615 
inner join Establishment E on  E.EstablishmentGroupId=EG.Id 
inner join SeenClientAnswerMaster AM on AM.EstablishmentId=E.id ANd (AM.IsDeleted=0 or AM.IsDeleted=null)
inner join [SeenClientAnswers] A on A.SeenclientAnswerMasterId=AM.id 
inner join SeenClientQuestions Q on Q.id=A.QuestionId and q.id in (37545,37546,37577,40062)
left outer join dbo.[Appuser] u on u.id=AM.CreatedBy
left outer join SeenClientAnswerChild SAC on AM.id=SAC.SeenClientAnswerMasterId 
)s
PIVOT(
MAX(Answer)
FOR  Question In (
[Month capturing for:],[Year capturing for:],[Monthly hours worked:],[Number of employees]
))p 
)AA
LEFT JOIN 
(
select SeenClientAnswerMasterId,CONVERT(DECIMAL(18,2),[Total overtime hours worked]) AS [Total overtime hours worked],[Number of days lost]
from (
select
E.EstablishmentName,cast(dateadd(MINUTE,cam.TimeOffSet,cam.CreatedOn) as date) as CapturedDate,dateadd(MINUTE,am.TimeOffSet,am.CreatedOn) as ResponseDate,am.id as ReferenceNo,cam.Id as SeenClientAnswerMasterId,am.IsPositive,am.IsResolved,a.Detail as Answer,q.Questiontitle as Question,u.id as UserId, u.name as UserName, am.Longitude ,am.Latitude
FROM dbo.[Group] g
inner join EstablishmentGroup eg on g.id=eg.groupid and g.id = 450 and eg.id=4615 
inner join Establishment e on  e.EstablishmentGroupId=eg.Id 
inner join answermaster am on am.EstablishmentId=e.id and (am.IsDeleted=0 or am.IsDeleted=null)
inner join Answers a on a.AnswerMasterId=am.id 
inner join Questions q on q.id=a.QuestionId and q.id in (28035,30219)
left outer join dbo.[Appuser] u on u.id=am.CreatedBy
left join SeenClientAnswerMaster cam on cam.Id=am.SeenClientAnswerMasterId and (cam.IsDeleted=0 or cam.IsDeleted=null)
left outer join SeenClientAnswerChild SAC on cam.id=SAC.SeenClientAnswerMasterId 
) s
pivot(
Max(Answer)
For  Question In (
[Total overtime hours worked],[Number of days lost]
))P
)BB ON AA.ReferenceNo=BB.SeenClientAnswerMasterId

UNION ALL

SELECT AA.EstablishmentName,AA.CapturedDate,AA.ReferenceNo,AA.[Month capturing for:],AA.[Year capturing for:],AA.Divison,AA.[Sub-Divison],AA.[Divison EstablishmentName],AA.[Monthly hours worked:],BB.[Total overtime hours worked] AS [Total overtime hours worked:],AA.[Number of employees],BB.[Number of days lost]
FROM 
(SELECT EstablishmentName,CapturedDate,ReferenceNo,[Month capturing for:],[Year capturing for:],'Tube & Pipe' AS [Divison],'Head Office' AS [Sub-Divison],'SHEQ Incident Reporting - Tube & Pipe Head Office' as [Divison EstablishmentName],
CONVERT(DECIMAL(18,2),[Monthly hours worked:]) AS [Monthly hours worked:],[Number of employees]
FROM (
SELECT E.EstablishmentName,dateadd(MINUTE,AM.TimeOffSet,AM.CreatedOn) as CapturedDate,AM.id as ReferenceNo,A.Detail as Answer,Q.Questiontitle as Question 
FROM dbo.[Group] G
inner join EstablishmentGroup EG on G.id=EG.groupid and g.id = 450 and eg.id=4615 
inner join Establishment E on  E.EstablishmentGroupId=EG.Id 
inner join SeenClientAnswerMaster AM on AM.EstablishmentId=E.id ANd (AM.IsDeleted=0 or AM.IsDeleted=null)
inner join [SeenClientAnswers] A on A.SeenclientAnswerMasterId=AM.id 
inner join SeenClientQuestions Q on Q.id=A.QuestionId and q.id in (37545,37546,37581,40063)
left outer join dbo.[Appuser] u on u.id=AM.CreatedBy
left outer join SeenClientAnswerChild SAC on AM.id=SAC.SeenClientAnswerMasterId 
)s
PIVOT(
MAX(Answer)
FOR  Question In (
[Month capturing for:],[Year capturing for:],[Monthly hours worked:],[Number of employees]
))p 
)AA
LEFT JOIN 
(
select SeenClientAnswerMasterId,CONVERT(DECIMAL(18,2),[Total overtime hours worked]) AS [Total overtime hours worked],[Number of days lost]
from (
select
E.EstablishmentName,cast(dateadd(MINUTE,cam.TimeOffSet,cam.CreatedOn) as date) as CapturedDate,dateadd(MINUTE,am.TimeOffSet,am.CreatedOn) as ResponseDate,am.id as ReferenceNo,cam.Id as SeenClientAnswerMasterId,am.IsPositive,am.IsResolved,a.Detail as Answer,q.Questiontitle as Question,u.id as UserId, u.name as UserName, am.Longitude ,am.Latitude
FROM dbo.[Group] g
inner join EstablishmentGroup eg on g.id=eg.groupid and g.id = 450 and eg.id=4615 
inner join Establishment e on  e.EstablishmentGroupId=eg.Id 
inner join answermaster am on am.EstablishmentId=e.id and (am.IsDeleted=0 or am.IsDeleted=null)
inner join Answers a on a.AnswerMasterId=am.id 
inner join Questions q on q.id=a.QuestionId and q.id in (28038,30221)
left outer join dbo.[Appuser] u on u.id=am.CreatedBy
left join SeenClientAnswerMaster cam on cam.Id=am.SeenClientAnswerMasterId and (cam.IsDeleted=0 or cam.IsDeleted=null)
left outer join SeenClientAnswerChild SAC on cam.id=SAC.SeenClientAnswerMasterId 
) s
pivot(
Max(Answer)
For  Question In (
[Total overtime hours worked],[Number of days lost]
))P
)BB ON AA.ReferenceNo=BB.SeenClientAnswerMasterId

UNION ALL

SELECT AA.EstablishmentName,AA.CapturedDate,AA.ReferenceNo,AA.[Month capturing for:],AA.[Year capturing for:],AA.Divison,AA.[Sub-Divison],AA.[Divison EstablishmentName],AA.[Monthly hours worked:],BB.[Total overtime hours worked] AS [Total overtime hours worked:],AA.[Number of employees],BB.[Number of days lost]
FROM 
(SELECT EstablishmentName,CapturedDate,ReferenceNo,[Month capturing for:],[Year capturing for:],'Tube & Pipe' AS [Divison],'Rustenburg' AS [Sub-Divison],'SHEQ Incident Reporting - Tube & Pipe Rustenburg' as [Divison EstablishmentName],
CONVERT(DECIMAL(18,2),[Monthly hours worked:]) AS [Monthly hours worked:],[Number of employees]
FROM (
SELECT E.EstablishmentName,dateadd(MINUTE,AM.TimeOffSet,AM.CreatedOn) as CapturedDate,AM.id as ReferenceNo,A.Detail as Answer,Q.Questiontitle as Question 
FROM dbo.[Group] G
inner join EstablishmentGroup EG on G.id=EG.groupid and g.id = 450 and eg.id=4615 
inner join Establishment E on  E.EstablishmentGroupId=EG.Id 
inner join SeenClientAnswerMaster AM on AM.EstablishmentId=E.id ANd (AM.IsDeleted=0 or AM.IsDeleted=null)
inner join [SeenClientAnswers] A on A.SeenclientAnswerMasterId=AM.id 
inner join SeenClientQuestions Q on Q.id=A.QuestionId and q.id in (37545,37546,37584,40064)
left outer join dbo.[Appuser] u on u.id=AM.CreatedBy
left outer join SeenClientAnswerChild SAC on AM.id=SAC.SeenClientAnswerMasterId 
)s
PIVOT(
MAX(Answer)
FOR  Question In (
[Month capturing for:],[Year capturing for:],[Monthly hours worked:],[Number of employees]
))p 
)AA
LEFT JOIN 
(
select SeenClientAnswerMasterId,CONVERT(DECIMAL(18,2),[Total overtime hours worked]) AS [Total overtime hours worked],[Number of days lost]
from (
select
E.EstablishmentName,cast(dateadd(MINUTE,cam.TimeOffSet,cam.CreatedOn) as date) as CapturedDate,dateadd(MINUTE,am.TimeOffSet,am.CreatedOn) as ResponseDate,am.id as ReferenceNo,cam.Id as SeenClientAnswerMasterId,am.IsPositive,am.IsResolved,a.Detail as Answer,q.Questiontitle as Question,u.id as UserId, u.name as UserName, am.Longitude ,am.Latitude
FROM dbo.[Group] g
inner join EstablishmentGroup eg on g.id=eg.groupid and g.id = 450 and eg.id=4615 
inner join Establishment e on  e.EstablishmentGroupId=eg.Id 
inner join answermaster am on am.EstablishmentId=e.id and (am.IsDeleted=0 or am.IsDeleted=null)
inner join Answers a on a.AnswerMasterId=am.id 
inner join Questions q on q.id=a.QuestionId and q.id in (28040,30223)
left outer join dbo.[Appuser] u on u.id=am.CreatedBy
left join SeenClientAnswerMaster cam on cam.Id=am.SeenClientAnswerMasterId and (cam.IsDeleted=0 or cam.IsDeleted=null)
left outer join SeenClientAnswerChild SAC on cam.id=SAC.SeenClientAnswerMasterId 
) s
pivot(
Max(Answer)
For  Question In (
[Total overtime hours worked],[Number of days lost]
))P
)BB ON AA.ReferenceNo=BB.SeenClientAnswerMasterId

UNION ALL

SELECT AA.EstablishmentName,AA.CapturedDate,AA.ReferenceNo,AA.[Month capturing for:],AA.[Year capturing for:],AA.Divison,AA.[Sub-Divison],AA.[Divison EstablishmentName],AA.[Monthly hours worked:],BB.[Total overtime hours worked] AS [Total overtime hours worked:],AA.[Number of employees],BB.[Number of days lost]
FROM 
(SELECT EstablishmentName,CapturedDate,ReferenceNo,[Month capturing for:],[Year capturing for:],'Roofing' AS [Divison],'Head Office' AS [Sub-Divison],'SHEQ Incident Reporting - Roofing Head Office' as [Divison EstablishmentName],
CONVERT(DECIMAL(18,2),[Monthly hours worked:]) AS [Monthly hours worked:],[Number of employees]
FROM (
SELECT E.EstablishmentName,dateadd(MINUTE,AM.TimeOffSet,AM.CreatedOn) as CapturedDate,AM.id as ReferenceNo,A.Detail as Answer,Q.Questiontitle as Question 
FROM dbo.[Group] G
inner join EstablishmentGroup EG on G.id=EG.groupid and g.id = 450 and eg.id=4615 
inner join Establishment E on  E.EstablishmentGroupId=EG.Id 
inner join SeenClientAnswerMaster AM on AM.EstablishmentId=E.id ANd (AM.IsDeleted=0 or AM.IsDeleted=null)
inner join [SeenClientAnswers] A on A.SeenclientAnswerMasterId=AM.id 
inner join SeenClientQuestions Q on Q.id=A.QuestionId and q.id in (37545,37546,37588,40065)
left outer join dbo.[Appuser] u on u.id=AM.CreatedBy
left outer join SeenClientAnswerChild SAC on AM.id=SAC.SeenClientAnswerMasterId 
)s
PIVOT(
MAX(Answer)
FOR  Question In (
[Month capturing for:],[Year capturing for:],[Monthly hours worked:],[Number of employees]
))p 
)AA
LEFT JOIN 
(
select SeenClientAnswerMasterId,CONVERT(DECIMAL(18,2),[Total overtime hours worked]) AS [Total overtime hours worked],[Number of days lost]
from (
select
E.EstablishmentName,cast(dateadd(MINUTE,cam.TimeOffSet,cam.CreatedOn) as date) as CapturedDate,dateadd(MINUTE,am.TimeOffSet,am.CreatedOn) as ResponseDate,am.id as ReferenceNo,cam.Id as SeenClientAnswerMasterId,am.IsPositive,am.IsResolved,a.Detail as Answer,q.Questiontitle as Question,u.id as UserId, u.name as UserName, am.Longitude ,am.Latitude
FROM dbo.[Group] g
inner join EstablishmentGroup eg on g.id=eg.groupid and g.id = 450 and eg.id=4615 
inner join Establishment e on  e.EstablishmentGroupId=eg.Id 
inner join answermaster am on am.EstablishmentId=e.id and (am.IsDeleted=0 or am.IsDeleted=null)
inner join Answers a on a.AnswerMasterId=am.id 
inner join Questions q on q.id=a.QuestionId and q.id in (28043,30225)
left outer join dbo.[Appuser] u on u.id=am.CreatedBy
left join SeenClientAnswerMaster cam on cam.Id=am.SeenClientAnswerMasterId and (cam.IsDeleted=0 or cam.IsDeleted=null)
left outer join SeenClientAnswerChild SAC on cam.id=SAC.SeenClientAnswerMasterId 
) s
pivot(
Max(Answer)
For  Question In (
[Total overtime hours worked],[Number of days lost]
))P
)BB ON AA.ReferenceNo=BB.SeenClientAnswerMasterId

UNION ALL

SELECT AA.EstablishmentName,AA.CapturedDate,AA.ReferenceNo,AA.[Month capturing for:],AA.[Year capturing for:],AA.Divison,AA.[Sub-Divison],AA.[Divison EstablishmentName],AA.[Monthly hours worked:],BB.[Total overtime hours worked] AS [Total overtime hours worked:],AA.[Number of employees],BB.[Number of days lost]
FROM 
(SELECT EstablishmentName,CapturedDate,ReferenceNo,[Month capturing for:],[Year capturing for:],'Roofing' AS [Divison],'Queenstown' AS [Sub-Divison],'SHEQ Incident Reporting - Roofing Queenstown' as [Divison EstablishmentName],
CONVERT(DECIMAL(18,2),[Monthly hours worked:]) AS [Monthly hours worked:],[Number of employees]
FROM (
SELECT E.EstablishmentName,dateadd(MINUTE,AM.TimeOffSet,AM.CreatedOn) as CapturedDate,AM.id as ReferenceNo,A.Detail as Answer,Q.Questiontitle as Question 
FROM dbo.[Group] G
inner join EstablishmentGroup EG on G.id=EG.groupid and g.id = 450 and eg.id=4615 
inner join Establishment E on  E.EstablishmentGroupId=EG.Id 
inner join SeenClientAnswerMaster AM on AM.EstablishmentId=E.id ANd (AM.IsDeleted=0 or AM.IsDeleted=null)
inner join [SeenClientAnswers] A on A.SeenclientAnswerMasterId=AM.id 
inner join SeenClientQuestions Q on Q.id=A.QuestionId and q.id in (37545,37546,37591,40066)
left outer join dbo.[Appuser] u on u.id=AM.CreatedBy
left outer join SeenClientAnswerChild SAC on AM.id=SAC.SeenClientAnswerMasterId 
)s
PIVOT(
MAX(Answer)
FOR  Question In (
[Month capturing for:],[Year capturing for:],[Monthly hours worked:],[Number of employees]
))p 
)AA
LEFT JOIN 
(
select SeenClientAnswerMasterId,CONVERT(DECIMAL(18,2),[Total overtime hours worked]) AS [Total overtime hours worked],[Number of days lost]
from (
select
E.EstablishmentName,cast(dateadd(MINUTE,cam.TimeOffSet,cam.CreatedOn) as date) as CapturedDate,dateadd(MINUTE,am.TimeOffSet,am.CreatedOn) as ResponseDate,am.id as ReferenceNo,cam.Id as SeenClientAnswerMasterId,am.IsPositive,am.IsResolved,a.Detail as Answer,q.Questiontitle as Question,u.id as UserId, u.name as UserName, am.Longitude ,am.Latitude
FROM dbo.[Group] g
inner join EstablishmentGroup eg on g.id=eg.groupid and g.id = 450 and eg.id=4615 
inner join Establishment e on  e.EstablishmentGroupId=eg.Id 
inner join answermaster am on am.EstablishmentId=e.id and (am.IsDeleted=0 or am.IsDeleted=null)
inner join Answers a on a.AnswerMasterId=am.id 
inner join Questions q on q.id=a.QuestionId and q.id in (28045,30227)
left outer join dbo.[Appuser] u on u.id=am.CreatedBy
left join SeenClientAnswerMaster cam on cam.Id=am.SeenClientAnswerMasterId and (cam.IsDeleted=0 or cam.IsDeleted=null)
left outer join SeenClientAnswerChild SAC on cam.id=SAC.SeenClientAnswerMasterId 
) s
pivot(
Max(Answer)
For  Question In (
[Total overtime hours worked],[Number of days lost]
))P
)BB ON AA.ReferenceNo=BB.SeenClientAnswerMasterId

UNION ALL

SELECT AA.EstablishmentName,AA.CapturedDate,AA.ReferenceNo,AA.[Month capturing for:],AA.[Year capturing for:],AA.Divison,AA.[Sub-Divison],AA.[Divison EstablishmentName],AA.[Monthly hours worked:],BB.[Total overtime hours worked] AS [Total overtime hours worked:],AA.[Number of employees],BB.[Number of days lost]
FROM 
(SELECT EstablishmentName,CapturedDate,ReferenceNo,[Month capturing for:],[Year capturing for:],'Special Steels' AS [Divison],'Head office' AS [Sub-Divison],'SHEQ Incident Reporting - Special Steels Head Office' as [Divison EstablishmentName],
CONVERT(DECIMAL(18,2),[Monthly hours worked:]) AS [Monthly hours worked:],[Number of employees]
FROM (
SELECT E.EstablishmentName,dateadd(MINUTE,AM.TimeOffSet,AM.CreatedOn) as CapturedDate,AM.id as ReferenceNo,A.Detail as Answer,Q.Questiontitle as Question 
FROM dbo.[Group] G
inner join EstablishmentGroup EG on G.id=EG.groupid and g.id = 450 and eg.id=4615 
inner join Establishment E on  E.EstablishmentGroupId=EG.Id 
inner join SeenClientAnswerMaster AM on AM.EstablishmentId=E.id ANd (AM.IsDeleted=0 or AM.IsDeleted=null)
inner join [SeenClientAnswers] A on A.SeenclientAnswerMasterId=AM.id 
inner join SeenClientQuestions Q on Q.id=A.QuestionId and q.id in (37545,37546,37595,40067)
left outer join dbo.[Appuser] u on u.id=AM.CreatedBy
left outer join SeenClientAnswerChild SAC on AM.id=SAC.SeenClientAnswerMasterId 
)s
PIVOT(
MAX(Answer)
FOR  Question In (
[Month capturing for:],[Year capturing for:],[Monthly hours worked:],[Number of employees]
))p 
)AA
LEFT JOIN 
(
select SeenClientAnswerMasterId,CONVERT(DECIMAL(18,2),[Total overtime hours worked]) AS [Total overtime hours worked],[Number of days lost]
from (
select
E.EstablishmentName,cast(dateadd(MINUTE,cam.TimeOffSet,cam.CreatedOn) as date) as CapturedDate,dateadd(MINUTE,am.TimeOffSet,am.CreatedOn) as ResponseDate,am.id as ReferenceNo,cam.Id as SeenClientAnswerMasterId,am.IsPositive,am.IsResolved,a.Detail as Answer,q.Questiontitle as Question,u.id as UserId, u.name as UserName, am.Longitude ,am.Latitude
FROM dbo.[Group] g
inner join EstablishmentGroup eg on g.id=eg.groupid and g.id = 450 and eg.id=4615 
inner join Establishment e on  e.EstablishmentGroupId=eg.Id 
inner join answermaster am on am.EstablishmentId=e.id and (am.IsDeleted=0 or am.IsDeleted=null)
inner join Answers a on a.AnswerMasterId=am.id 
inner join Questions q on q.id=a.QuestionId and q.id in (28048,30229)
left outer join dbo.[Appuser] u on u.id=am.CreatedBy
left join SeenClientAnswerMaster cam on cam.Id=am.SeenClientAnswerMasterId and (cam.IsDeleted=0 or cam.IsDeleted=null)
left outer join SeenClientAnswerChild SAC on cam.id=SAC.SeenClientAnswerMasterId 
) s
pivot(
Max(Answer)
For  Question In (
[Total overtime hours worked],[Number of days lost]
))P
)BB ON AA.ReferenceNo=BB.SeenClientAnswerMasterId

UNION ALL

SELECT AA.EstablishmentName,AA.CapturedDate,AA.ReferenceNo,AA.[Month capturing for:],AA.[Year capturing for:],AA.Divison,AA.[Sub-Divison],AA.[Divison EstablishmentName],AA.[Monthly hours worked:],BB.[Total overtime hours worked] AS [Total overtime hours worked:],AA.[Number of employees],BB.[Number of days lost]
FROM 
(SELECT EstablishmentName,CapturedDate,ReferenceNo,[Month capturing for:],[Year capturing for:],'Special Steels' AS [Divison],'Meyerton' AS [Sub-Divison],'SHEQ Incident Reporting - Special Steels Meyerton' as [Divison EstablishmentName],
CONVERT(DECIMAL(18,2),[Monthly hours worked:]) AS [Monthly hours worked:],[Number of employees]
FROM (
SELECT E.EstablishmentName,dateadd(MINUTE,AM.TimeOffSet,AM.CreatedOn) as CapturedDate,AM.id as ReferenceNo,A.Detail as Answer,Q.Questiontitle as Question 
FROM dbo.[Group] G
inner join EstablishmentGroup EG on G.id=EG.groupid and g.id = 450 and eg.id=4615 
inner join Establishment E on  E.EstablishmentGroupId=EG.Id 
inner join SeenClientAnswerMaster AM on AM.EstablishmentId=E.id ANd (AM.IsDeleted=0 or AM.IsDeleted=null)
inner join [SeenClientAnswers] A on A.SeenclientAnswerMasterId=AM.id 
inner join SeenClientQuestions Q on Q.id=A.QuestionId and q.id in (37545,37546,37598,40068)
left outer join dbo.[Appuser] u on u.id=AM.CreatedBy
left outer join SeenClientAnswerChild SAC on AM.id=SAC.SeenClientAnswerMasterId 
)s
PIVOT(
MAX(Answer)
FOR  Question In (
[Month capturing for:],[Year capturing for:],[Monthly hours worked:],[Number of employees]
))p 
)AA
LEFT JOIN 
(
select SeenClientAnswerMasterId,CONVERT(DECIMAL(18,2),[Total overtime hours worked]) AS [Total overtime hours worked],[Number of days lost]
from (
select
E.EstablishmentName,cast(dateadd(MINUTE,cam.TimeOffSet,cam.CreatedOn) as date) as CapturedDate,dateadd(MINUTE,am.TimeOffSet,am.CreatedOn) as ResponseDate,am.id as ReferenceNo,cam.Id as SeenClientAnswerMasterId,am.IsPositive,am.IsResolved,a.Detail as Answer,q.Questiontitle as Question,u.id as UserId, u.name as UserName, am.Longitude ,am.Latitude
FROM dbo.[Group] g
inner join EstablishmentGroup eg on g.id=eg.groupid and g.id = 450 and eg.id=4615 
inner join Establishment e on  e.EstablishmentGroupId=eg.Id 
inner join answermaster am on am.EstablishmentId=e.id and (am.IsDeleted=0 or am.IsDeleted=null)
inner join Answers a on a.AnswerMasterId=am.id 
inner join Questions q on q.id=a.QuestionId and q.id in (28050,30232)
left outer join dbo.[Appuser] u on u.id=am.CreatedBy
left join SeenClientAnswerMaster cam on cam.Id=am.SeenClientAnswerMasterId and (cam.IsDeleted=0 or cam.IsDeleted=null)
left outer join SeenClientAnswerChild SAC on cam.id=SAC.SeenClientAnswerMasterId 
) s
pivot(
Max(Answer)
For  Question In (
[Total overtime hours worked],[Number of days lost]
))P
)BB ON AA.ReferenceNo=BB.SeenClientAnswerMasterId

UNION ALL

SELECT AA.EstablishmentName,AA.CapturedDate,AA.ReferenceNo,AA.[Month capturing for:],AA.[Year capturing for:],AA.Divison,AA.[Sub-Divison],AA.[Divison EstablishmentName],AA.[Monthly hours worked:],BB.[Total overtime hours worked] AS [Total overtime hours worked:],AA.[Number of employees],BB.[Number of days lost]
FROM 
(SELECT EstablishmentName,CapturedDate,ReferenceNo,[Month capturing for:],[Year capturing for:],'Special Steels' AS [Divison],'Durban' AS [Sub-Divison],'SHEQ Incident Reporting - Special Steels Durban' as [Divison EstablishmentName],
CONVERT(DECIMAL(18,2),[Monthly hours worked:]) AS [Monthly hours worked:],[Number of employees]
FROM (
SELECT E.EstablishmentName,dateadd(MINUTE,AM.TimeOffSet,AM.CreatedOn) as CapturedDate,AM.id as ReferenceNo,A.Detail as Answer,Q.Questiontitle as Question 
FROM dbo.[Group] G
inner join EstablishmentGroup EG on G.id=EG.groupid and g.id = 450 and eg.id=4615 
inner join Establishment E on  E.EstablishmentGroupId=EG.Id 
inner join SeenClientAnswerMaster AM on AM.EstablishmentId=E.id ANd (AM.IsDeleted=0 or AM.IsDeleted=null)
inner join [SeenClientAnswers] A on A.SeenclientAnswerMasterId=AM.id 
inner join SeenClientQuestions Q on Q.id=A.QuestionId and q.id in (37545,37546,37601,40069)
left outer join dbo.[Appuser] u on u.id=AM.CreatedBy
left outer join SeenClientAnswerChild SAC on AM.id=SAC.SeenClientAnswerMasterId 
)s
PIVOT(
MAX(Answer)
FOR  Question In (
[Month capturing for:],[Year capturing for:],[Monthly hours worked:],[Number of employees]
))p 
)AA
LEFT JOIN 
(
select SeenClientAnswerMasterId,CONVERT(DECIMAL(18,2),[Total overtime hours worked]) AS [Total overtime hours worked],[Number of days lost]
from (
select
E.EstablishmentName,cast(dateadd(MINUTE,cam.TimeOffSet,cam.CreatedOn) as date) as CapturedDate,dateadd(MINUTE,am.TimeOffSet,am.CreatedOn) as ResponseDate,am.id as ReferenceNo,cam.Id as SeenClientAnswerMasterId,am.IsPositive,am.IsResolved,a.Detail as Answer,q.Questiontitle as Question,u.id as UserId, u.name as UserName, am.Longitude ,am.Latitude
FROM dbo.[Group] g
inner join EstablishmentGroup eg on g.id=eg.groupid and g.id = 450 and eg.id=4615 
inner join Establishment e on  e.EstablishmentGroupId=eg.Id 
inner join answermaster am on am.EstablishmentId=e.id and (am.IsDeleted=0 or am.IsDeleted=null)
inner join Answers a on a.AnswerMasterId=am.id 
inner join Questions q on q.id=a.QuestionId and q.id in (28052,30233)
left outer join dbo.[Appuser] u on u.id=am.CreatedBy
left join SeenClientAnswerMaster cam on cam.Id=am.SeenClientAnswerMasterId and (cam.IsDeleted=0 or cam.IsDeleted=null)
left outer join SeenClientAnswerChild SAC on cam.id=SAC.SeenClientAnswerMasterId 
) s
pivot(
Max(Answer)
For  Question In (
[Total overtime hours worked],[Number of days lost]
))P
)BB ON AA.ReferenceNo=BB.SeenClientAnswerMasterId

UNION ALL

SELECT AA.EstablishmentName,AA.CapturedDate,AA.ReferenceNo,AA.[Month capturing for:],AA.[Year capturing for:],AA.Divison,AA.[Sub-Divison],AA.[Divison EstablishmentName],AA.[Monthly hours worked:],BB.[Total overtime hours worked] AS [Total overtime hours worked:],AA.[Number of employees],BB.[Number of days lost]
FROM 
(SELECT EstablishmentName,CapturedDate,ReferenceNo,[Month capturing for:],[Year capturing for:],'Trading' AS [Divison],'Head Office' AS [Sub-Divison],'SHEQ Incident Reporting - Trading Head Office' as [Divison EstablishmentName],
CONVERT(DECIMAL(18,2),[Monthly hours worked:]) AS [Monthly hours worked:],[Number of employees]
FROM (
SELECT E.EstablishmentName,dateadd(MINUTE,AM.TimeOffSet,AM.CreatedOn) as CapturedDate,AM.id as ReferenceNo,A.Detail as Answer,Q.Questiontitle as Question 
FROM dbo.[Group] G
inner join EstablishmentGroup EG on G.id=EG.groupid and g.id = 450 and eg.id=4615 
inner join Establishment E on  E.EstablishmentGroupId=EG.Id 
inner join SeenClientAnswerMaster AM on AM.EstablishmentId=E.id ANd (AM.IsDeleted=0 or AM.IsDeleted=null)
inner join [SeenClientAnswers] A on A.SeenclientAnswerMasterId=AM.id 
inner join SeenClientQuestions Q on Q.id=A.QuestionId and q.id in (37545,37546,37630,40070)
left outer join dbo.[Appuser] u on u.id=AM.CreatedBy
left outer join SeenClientAnswerChild SAC on AM.id=SAC.SeenClientAnswerMasterId 
)s
PIVOT(
MAX(Answer)
FOR  Question In (
[Month capturing for:],[Year capturing for:],[Monthly hours worked:],[Number of employees]
))p 
)AA
LEFT JOIN 
(
select SeenClientAnswerMasterId,CONVERT(DECIMAL(18,2),[Total overtime hours worked]) AS [Total overtime hours worked],[Number of days lost]
from (
select
E.EstablishmentName,cast(dateadd(MINUTE,cam.TimeOffSet,cam.CreatedOn) as date) as CapturedDate,dateadd(MINUTE,am.TimeOffSet,am.CreatedOn) as ResponseDate,am.id as ReferenceNo,cam.Id as SeenClientAnswerMasterId,am.IsPositive,am.IsResolved,a.Detail as Answer,q.Questiontitle as Question,u.id as UserId, u.name as UserName, am.Longitude ,am.Latitude
FROM dbo.[Group] g
inner join EstablishmentGroup eg on g.id=eg.groupid and g.id = 450 and eg.id=4615 
inner join Establishment e on  e.EstablishmentGroupId=eg.Id 
inner join answermaster am on am.EstablishmentId=e.id and (am.IsDeleted=0 or am.IsDeleted=null)
inner join Answers a on a.AnswerMasterId=am.id 
inner join Questions q on q.id=a.QuestionId and q.id in (28055,30250)
left outer join dbo.[Appuser] u on u.id=am.CreatedBy
left join SeenClientAnswerMaster cam on cam.Id=am.SeenClientAnswerMasterId and (cam.IsDeleted=0 or cam.IsDeleted=null)
left outer join SeenClientAnswerChild SAC on cam.id=SAC.SeenClientAnswerMasterId 
) s
pivot(
Max(Answer)
For  Question In (
[Total overtime hours worked],[Number of days lost]
))P
)BB ON AA.ReferenceNo=BB.SeenClientAnswerMasterId

UNION ALL

SELECT AA.EstablishmentName,AA.CapturedDate,AA.ReferenceNo,AA.[Month capturing for:],AA.[Year capturing for:],AA.Divison,AA.[Sub-Divison],AA.[Divison EstablishmentName],AA.[Monthly hours worked:],BB.[Total overtime hours worked] AS [Total overtime hours worked:],AA.[Number of employees],BB.[Number of days lost]
FROM 
(SELECT EstablishmentName,CapturedDate,ReferenceNo,[Month capturing for:],[Year capturing for:],'Trading' AS [Divison],'Bloemfontein' AS [Sub-Divison],'SHEQ Incident Reporting - Trading Bloemfontein' as [Divison EstablishmentName],
CONVERT(DECIMAL(18,2),[Monthly hours worked:]) AS [Monthly hours worked:],[Number of employees]
FROM (
SELECT E.EstablishmentName,dateadd(MINUTE,AM.TimeOffSet,AM.CreatedOn) as CapturedDate,AM.id as ReferenceNo,A.Detail as Answer,Q.Questiontitle as Question 
FROM dbo.[Group] G
inner join EstablishmentGroup EG on G.id=EG.groupid and g.id = 450 and eg.id=4615 
inner join Establishment E on  E.EstablishmentGroupId=EG.Id 
inner join SeenClientAnswerMaster AM on AM.EstablishmentId=E.id ANd (AM.IsDeleted=0 or AM.IsDeleted=null)
inner join [SeenClientAnswers] A on A.SeenclientAnswerMasterId=AM.id 
inner join SeenClientQuestions Q on Q.id=A.QuestionId and q.id in (37545,37546,37633,40071)
left outer join dbo.[Appuser] u on u.id=AM.CreatedBy
left outer join SeenClientAnswerChild SAC on AM.id=SAC.SeenClientAnswerMasterId 
)s
PIVOT(
MAX(Answer)
FOR  Question In (
[Month capturing for:],[Year capturing for:],[Monthly hours worked:],[Number of employees]
))p 
)AA
LEFT JOIN 
(
select SeenClientAnswerMasterId,CONVERT(DECIMAL(18,2),[Total overtime hours worked]) AS [Total overtime hours worked],[Number of days lost]
from (
select
E.EstablishmentName,cast(dateadd(MINUTE,cam.TimeOffSet,cam.CreatedOn) as date) as CapturedDate,dateadd(MINUTE,am.TimeOffSet,am.CreatedOn) as ResponseDate,am.id as ReferenceNo,cam.Id as SeenClientAnswerMasterId,am.IsPositive,am.IsResolved,a.Detail as Answer,q.Questiontitle as Question,u.id as UserId, u.name as UserName, am.Longitude ,am.Latitude
FROM dbo.[Group] g
inner join EstablishmentGroup eg on g.id=eg.groupid and g.id = 450 and eg.id=4615 
inner join Establishment e on  e.EstablishmentGroupId=eg.Id 
inner join answermaster am on am.EstablishmentId=e.id and (am.IsDeleted=0 or am.IsDeleted=null)
inner join Answers a on a.AnswerMasterId=am.id 
inner join Questions q on q.id=a.QuestionId and q.id in (28057,30251)
left outer join dbo.[Appuser] u on u.id=am.CreatedBy
left join SeenClientAnswerMaster cam on cam.Id=am.SeenClientAnswerMasterId and (cam.IsDeleted=0 or cam.IsDeleted=null)
left outer join SeenClientAnswerChild SAC on cam.id=SAC.SeenClientAnswerMasterId 
) s
pivot(
Max(Answer)
For  Question In (
[Total overtime hours worked],[Number of days lost]
))P
)BB ON AA.ReferenceNo=BB.SeenClientAnswerMasterId

UNION ALL

SELECT AA.EstablishmentName,AA.CapturedDate,AA.ReferenceNo,AA.[Month capturing for:],AA.[Year capturing for:],AA.Divison,AA.[Sub-Divison],AA.[Divison EstablishmentName],AA.[Monthly hours worked:],BB.[Total overtime hours worked] AS [Total overtime hours worked:],AA.[Number of employees],BB.[Number of days lost]
FROM 
(SELECT EstablishmentName,CapturedDate,ReferenceNo,[Month capturing for:],[Year capturing for:],'Trading' AS [Divison],'Cape Town' AS [Sub-Divison],'SHEQ Incident Reporting - Trading Cape Town' as [Divison EstablishmentName],
CONVERT(DECIMAL(18,2),[Monthly hours worked:]) AS [Monthly hours worked:],[Number of employees]
FROM (
SELECT E.EstablishmentName,dateadd(MINUTE,AM.TimeOffSet,AM.CreatedOn) as CapturedDate,AM.id as ReferenceNo,A.Detail as Answer,Q.Questiontitle as Question 
FROM dbo.[Group] G
inner join EstablishmentGroup EG on G.id=EG.groupid and g.id = 450 and eg.id=4615 
inner join Establishment E on  E.EstablishmentGroupId=EG.Id 
inner join SeenClientAnswerMaster AM on AM.EstablishmentId=E.id ANd (AM.IsDeleted=0 or AM.IsDeleted=null)
inner join [SeenClientAnswers] A on A.SeenclientAnswerMasterId=AM.id 
inner join SeenClientQuestions Q on Q.id=A.QuestionId and q.id in (37545,37546,37675,40072)
left outer join dbo.[Appuser] u on u.id=AM.CreatedBy
left outer join SeenClientAnswerChild SAC on AM.id=SAC.SeenClientAnswerMasterId 
)s
PIVOT(
MAX(Answer)
FOR  Question In (
[Month capturing for:],[Year capturing for:],[Monthly hours worked:],[Number of employees]
))p 
)AA
LEFT JOIN 
(
select SeenClientAnswerMasterId,CONVERT(DECIMAL(18,2),[Total overtime hours worked]) AS [Total overtime hours worked],[Number of days lost]
from (
select
E.EstablishmentName,cast(dateadd(MINUTE,cam.TimeOffSet,cam.CreatedOn) as date) as CapturedDate,dateadd(MINUTE,am.TimeOffSet,am.CreatedOn) as ResponseDate,am.id as ReferenceNo,cam.Id as SeenClientAnswerMasterId,am.IsPositive,am.IsResolved,a.Detail as Answer,q.Questiontitle as Question,u.id as UserId, u.name as UserName, am.Longitude ,am.Latitude
FROM dbo.[Group] g
inner join EstablishmentGroup eg on g.id=eg.groupid and g.id = 450 and eg.id=4615 
inner join Establishment e on  e.EstablishmentGroupId=eg.Id 
inner join answermaster am on am.EstablishmentId=e.id and (am.IsDeleted=0 or am.IsDeleted=null)
inner join Answers a on a.AnswerMasterId=am.id 
inner join Questions q on q.id=a.QuestionId and q.id in (28059,30252)
left outer join dbo.[Appuser] u on u.id=am.CreatedBy
left join SeenClientAnswerMaster cam on cam.Id=am.SeenClientAnswerMasterId and (cam.IsDeleted=0 or cam.IsDeleted=null)
left outer join SeenClientAnswerChild SAC on cam.id=SAC.SeenClientAnswerMasterId 
) s
pivot(
Max(Answer)
For  Question In (
[Total overtime hours worked],[Number of days lost]
))P
)BB ON AA.ReferenceNo=BB.SeenClientAnswerMasterId

UNION ALL

SELECT AA.EstablishmentName,AA.CapturedDate,AA.ReferenceNo,AA.[Month capturing for:],AA.[Year capturing for:],AA.Divison,AA.[Sub-Divison],AA.[Divison EstablishmentName],AA.[Monthly hours worked:],BB.[Total overtime hours worked] AS [Total overtime hours worked:],AA.[Number of employees],BB.[Number of days lost]
FROM 
(SELECT EstablishmentName,CapturedDate,ReferenceNo,[Month capturing for:],[Year capturing for:],'Trading' AS [Divison],'Durban' AS [Sub-Divison],'SHEQ Incident Reporting - Trading Durban' as [Divison EstablishmentName],
CONVERT(DECIMAL(18,2),[Monthly hours worked:]) AS [Monthly hours worked:],[Number of employees]
FROM (
SELECT E.EstablishmentName,dateadd(MINUTE,AM.TimeOffSet,AM.CreatedOn) as CapturedDate,AM.id as ReferenceNo,A.Detail as Answer,Q.Questiontitle as Question 
FROM dbo.[Group] G
inner join EstablishmentGroup EG on G.id=EG.groupid and g.id = 450 and eg.id=4615 
inner join Establishment E on  E.EstablishmentGroupId=EG.Id 
inner join SeenClientAnswerMaster AM on AM.EstablishmentId=E.id ANd (AM.IsDeleted=0 or AM.IsDeleted=null)
inner join [SeenClientAnswers] A on A.SeenclientAnswerMasterId=AM.id 
inner join SeenClientQuestions Q on Q.id=A.QuestionId and q.id in (37545,37546,37678,40073)
left outer join dbo.[Appuser] u on u.id=AM.CreatedBy
left outer join SeenClientAnswerChild SAC on AM.id=SAC.SeenClientAnswerMasterId 
)s
PIVOT(
MAX(Answer)
FOR  Question In (
[Month capturing for:],[Year capturing for:],[Monthly hours worked:],[Number of employees]
))p 
)AA
LEFT JOIN 
(
select SeenClientAnswerMasterId,CONVERT(DECIMAL(18,2),[Total overtime hours worked]) AS [Total overtime hours worked],[Number of days lost]
from (
select
E.EstablishmentName,cast(dateadd(MINUTE,cam.TimeOffSet,cam.CreatedOn) as date) as CapturedDate,dateadd(MINUTE,am.TimeOffSet,am.CreatedOn) as ResponseDate,am.id as ReferenceNo,cam.Id as SeenClientAnswerMasterId,am.IsPositive,am.IsResolved,a.Detail as Answer,q.Questiontitle as Question,u.id as UserId, u.name as UserName, am.Longitude ,am.Latitude
FROM dbo.[Group] g
inner join EstablishmentGroup eg on g.id=eg.groupid and g.id = 450 and eg.id=4615 
inner join Establishment e on  e.EstablishmentGroupId=eg.Id 
inner join answermaster am on am.EstablishmentId=e.id and (am.IsDeleted=0 or am.IsDeleted=null)
inner join Answers a on a.AnswerMasterId=am.id 
inner join Questions q on q.id=a.QuestionId and q.id in (28061,30253)
left outer join dbo.[Appuser] u on u.id=am.CreatedBy
left join SeenClientAnswerMaster cam on cam.Id=am.SeenClientAnswerMasterId and (cam.IsDeleted=0 or cam.IsDeleted=null)
left outer join SeenClientAnswerChild SAC on cam.id=SAC.SeenClientAnswerMasterId 
) s
pivot(
Max(Answer)
For  Question In (
[Total overtime hours worked],[Number of days lost]
))P
)BB ON AA.ReferenceNo=BB.SeenClientAnswerMasterId

UNION ALL

SELECT AA.EstablishmentName,AA.CapturedDate,AA.ReferenceNo,AA.[Month capturing for:],AA.[Year capturing for:],AA.Divison,AA.[Sub-Divison],AA.[Divison EstablishmentName],AA.[Monthly hours worked:],BB.[Total overtime hours worked] AS [Total overtime hours worked:],AA.[Number of employees],BB.[Number of days lost]
FROM 
(SELECT EstablishmentName,CapturedDate,ReferenceNo,[Month capturing for:],[Year capturing for:],'Trading' AS [Divison],'East London' AS [Sub-Divison],'SHEQ Incident Reporting - Trading East London' as [Divison EstablishmentName],
CONVERT(DECIMAL(18,2),[Monthly hours worked:]) AS [Monthly hours worked:],[Number of employees]
FROM (
SELECT E.EstablishmentName,dateadd(MINUTE,AM.TimeOffSet,AM.CreatedOn) as CapturedDate,AM.id as ReferenceNo,A.Detail as Answer,Q.Questiontitle as Question 
FROM dbo.[Group] G
inner join EstablishmentGroup EG on G.id=EG.groupid and g.id = 450 and eg.id=4615 
inner join Establishment E on  E.EstablishmentGroupId=EG.Id 
inner join SeenClientAnswerMaster AM on AM.EstablishmentId=E.id ANd (AM.IsDeleted=0 or AM.IsDeleted=null)
inner join [SeenClientAnswers] A on A.SeenclientAnswerMasterId=AM.id 
inner join SeenClientQuestions Q on Q.id=A.QuestionId and q.id in (37545,37546,37681,40074)
left outer join dbo.[Appuser] u on u.id=AM.CreatedBy
left outer join SeenClientAnswerChild SAC on AM.id=SAC.SeenClientAnswerMasterId 
)s
PIVOT(
MAX(Answer)
FOR  Question In (
[Month capturing for:],[Year capturing for:],[Monthly hours worked:],[Number of employees]
))p 
)AA
LEFT JOIN 
(
select SeenClientAnswerMasterId,CONVERT(DECIMAL(18,2),[Total overtime hours worked]) AS [Total overtime hours worked],[Number of days lost]
from (
select
E.EstablishmentName,cast(dateadd(MINUTE,cam.TimeOffSet,cam.CreatedOn) as date) as CapturedDate,dateadd(MINUTE,am.TimeOffSet,am.CreatedOn) as ResponseDate,am.id as ReferenceNo,cam.Id as SeenClientAnswerMasterId,am.IsPositive,am.IsResolved,a.Detail as Answer,q.Questiontitle as Question,u.id as UserId, u.name as UserName, am.Longitude ,am.Latitude
FROM dbo.[Group] g
inner join EstablishmentGroup eg on g.id=eg.groupid and g.id = 450 and eg.id=4615 
inner join Establishment e on  e.EstablishmentGroupId=eg.Id 
inner join answermaster am on am.EstablishmentId=e.id and (am.IsDeleted=0 or am.IsDeleted=null)
inner join Answers a on a.AnswerMasterId=am.id 
inner join Questions q on q.id=a.QuestionId and q.id in (28063,30254)
left outer join dbo.[Appuser] u on u.id=am.CreatedBy
left join SeenClientAnswerMaster cam on cam.Id=am.SeenClientAnswerMasterId and (cam.IsDeleted=0 or cam.IsDeleted=null)
left outer join SeenClientAnswerChild SAC on cam.id=SAC.SeenClientAnswerMasterId 
) s
pivot(
Max(Answer)
For  Question In (
[Total overtime hours worked],[Number of days lost]
))P
)BB ON AA.ReferenceNo=BB.SeenClientAnswerMasterId

UNION ALL

SELECT AA.EstablishmentName,AA.CapturedDate,AA.ReferenceNo,AA.[Month capturing for:],AA.[Year capturing for:],AA.Divison,AA.[Sub-Divison],AA.[Divison EstablishmentName],AA.[Monthly hours worked:],BB.[Total overtime hours worked] AS [Total overtime hours worked:],AA.[Number of employees],BB.[Number of days lost]
FROM 
(SELECT EstablishmentName,CapturedDate,ReferenceNo,[Month capturing for:],[Year capturing for:],'Trading' AS [Divison],'Kimberley' AS [Sub-Divison],'SHEQ Incident Reporting - Trading Kimberley' as [Divison EstablishmentName],
CONVERT(DECIMAL(18,2),[Monthly hours worked:]) AS [Monthly hours worked:],[Number of employees]
FROM (
SELECT E.EstablishmentName,dateadd(MINUTE,AM.TimeOffSet,AM.CreatedOn) as CapturedDate,AM.id as ReferenceNo,A.Detail as Answer,Q.Questiontitle as Question 
FROM dbo.[Group] G
inner join EstablishmentGroup EG on G.id=EG.groupid and g.id = 450 and eg.id=4615 
inner join Establishment E on  E.EstablishmentGroupId=EG.Id 
inner join SeenClientAnswerMaster AM on AM.EstablishmentId=E.id ANd (AM.IsDeleted=0 or AM.IsDeleted=null)
inner join [SeenClientAnswers] A on A.SeenclientAnswerMasterId=AM.id 
inner join SeenClientQuestions Q on Q.id=A.QuestionId and q.id in (37545,37546,37684,40075)
left outer join dbo.[Appuser] u on u.id=AM.CreatedBy
left outer join SeenClientAnswerChild SAC on AM.id=SAC.SeenClientAnswerMasterId 
)s
PIVOT(
MAX(Answer)
FOR  Question In (
[Month capturing for:],[Year capturing for:],[Monthly hours worked:],[Number of employees]
))p 
)AA
LEFT JOIN 
(
select SeenClientAnswerMasterId,CONVERT(DECIMAL(18,2),[Total overtime hours worked]) AS [Total overtime hours worked],[Number of days lost]
from (
select
E.EstablishmentName,cast(dateadd(MINUTE,cam.TimeOffSet,cam.CreatedOn) as date) as CapturedDate,dateadd(MINUTE,am.TimeOffSet,am.CreatedOn) as ResponseDate,am.id as ReferenceNo,cam.Id as SeenClientAnswerMasterId,am.IsPositive,am.IsResolved,a.Detail as Answer,q.Questiontitle as Question,u.id as UserId, u.name as UserName, am.Longitude ,am.Latitude
FROM dbo.[Group] g
inner join EstablishmentGroup eg on g.id=eg.groupid and g.id = 450 and eg.id=4615 
inner join Establishment e on  e.EstablishmentGroupId=eg.Id 
inner join answermaster am on am.EstablishmentId=e.id and (am.IsDeleted=0 or am.IsDeleted=null)
inner join Answers a on a.AnswerMasterId=am.id 
inner join Questions q on q.id=a.QuestionId and q.id in (28065,30255)
left outer join dbo.[Appuser] u on u.id=am.CreatedBy
left join SeenClientAnswerMaster cam on cam.Id=am.SeenClientAnswerMasterId and (cam.IsDeleted=0 or cam.IsDeleted=null)
left outer join SeenClientAnswerChild SAC on cam.id=SAC.SeenClientAnswerMasterId 
) s
pivot(
Max(Answer)
For  Question In (
[Total overtime hours worked],[Number of days lost]
))P
)BB ON AA.ReferenceNo=BB.SeenClientAnswerMasterId

UNION ALL

SELECT AA.EstablishmentName,AA.CapturedDate,AA.ReferenceNo,AA.[Month capturing for:],AA.[Year capturing for:],AA.Divison,AA.[Sub-Divison],AA.[Divison EstablishmentName],AA.[Monthly hours worked:],BB.[Total overtime hours worked] AS [Total overtime hours worked:],AA.[Number of employees],BB.[Number of days lost]
FROM 
(SELECT EstablishmentName,CapturedDate,ReferenceNo,[Month capturing for:],[Year capturing for:],'Trading' AS [Divison],'Klerksdorp' AS [Sub-Divison],'SHEQ Incident Reporting - Trading Klerksdorp' as [Divison EstablishmentName],
CONVERT(DECIMAL(18,2),[Monthly hours worked:]) AS [Monthly hours worked:],[Number of employees]
FROM (
SELECT E.EstablishmentName,dateadd(MINUTE,AM.TimeOffSet,AM.CreatedOn) as CapturedDate,AM.id as ReferenceNo,A.Detail as Answer,Q.Questiontitle as Question 
FROM dbo.[Group] G
inner join EstablishmentGroup EG on G.id=EG.groupid and g.id = 450 and eg.id=4615 
inner join Establishment E on  E.EstablishmentGroupId=EG.Id 
inner join SeenClientAnswerMaster AM on AM.EstablishmentId=E.id ANd (AM.IsDeleted=0 or AM.IsDeleted=null)
inner join [SeenClientAnswers] A on A.SeenclientAnswerMasterId=AM.id 
inner join SeenClientQuestions Q on Q.id=A.QuestionId and q.id in (37545,37546,37687,40076)
left outer join dbo.[Appuser] u on u.id=AM.CreatedBy
left outer join SeenClientAnswerChild SAC on AM.id=SAC.SeenClientAnswerMasterId 
)s
PIVOT(
MAX(Answer)
FOR  Question In (
[Month capturing for:],[Year capturing for:],[Monthly hours worked:],[Number of employees]
))p 
)AA
LEFT JOIN 
(
select SeenClientAnswerMasterId,CONVERT(DECIMAL(18,2),[Total overtime hours worked]) AS [Total overtime hours worked],[Number of days lost]
from (
select
E.EstablishmentName,cast(dateadd(MINUTE,cam.TimeOffSet,cam.CreatedOn) as date) as CapturedDate,dateadd(MINUTE,am.TimeOffSet,am.CreatedOn) as ResponseDate,am.id as ReferenceNo,cam.Id as SeenClientAnswerMasterId,am.IsPositive,am.IsResolved,a.Detail as Answer,q.Questiontitle as Question,u.id as UserId, u.name as UserName, am.Longitude ,am.Latitude
FROM dbo.[Group] g
inner join EstablishmentGroup eg on g.id=eg.groupid and g.id = 450 and eg.id=4615 
inner join Establishment e on  e.EstablishmentGroupId=eg.Id 
inner join answermaster am on am.EstablishmentId=e.id and (am.IsDeleted=0 or am.IsDeleted=null)
inner join Answers a on a.AnswerMasterId=am.id 
inner join Questions q on q.id=a.QuestionId and q.id in (28067,30256)
left outer join dbo.[Appuser] u on u.id=am.CreatedBy
left join SeenClientAnswerMaster cam on cam.Id=am.SeenClientAnswerMasterId and (cam.IsDeleted=0 or cam.IsDeleted=null)
left outer join SeenClientAnswerChild SAC on cam.id=SAC.SeenClientAnswerMasterId 
) s
pivot(
Max(Answer)
For  Question In (
[Total overtime hours worked],[Number of days lost]
))P
)BB ON AA.ReferenceNo=BB.SeenClientAnswerMasterId

UNION ALL

SELECT AA.EstablishmentName,AA.CapturedDate,AA.ReferenceNo,AA.[Month capturing for:],AA.[Year capturing for:],AA.Divison,AA.[Sub-Divison],AA.[Divison EstablishmentName],AA.[Monthly hours worked:],BB.[Total overtime hours worked] AS [Total overtime hours worked:],AA.[Number of employees],BB.[Number of days lost]
FROM 
(SELECT EstablishmentName,CapturedDate,ReferenceNo,[Month capturing for:],[Year capturing for:],'Trading' AS [Divison],'Nelspruit' AS [Sub-Divison],'SHEQ Incident Reporting - Trading Nelspruit' as [Divison EstablishmentName],
CONVERT(DECIMAL(18,2),[Monthly hours worked:]) AS [Monthly hours worked:],[Number of employees]
FROM (
SELECT E.EstablishmentName,dateadd(MINUTE,AM.TimeOffSet,AM.CreatedOn) as CapturedDate,AM.id as ReferenceNo,A.Detail as Answer,Q.Questiontitle as Question 
FROM dbo.[Group] G
inner join EstablishmentGroup EG on G.id=EG.groupid and g.id = 450 and eg.id=4615 
inner join Establishment E on  E.EstablishmentGroupId=EG.Id 
inner join SeenClientAnswerMaster AM on AM.EstablishmentId=E.id ANd (AM.IsDeleted=0 or AM.IsDeleted=null)
inner join [SeenClientAnswers] A on A.SeenclientAnswerMasterId=AM.id 
inner join SeenClientQuestions Q on Q.id=A.QuestionId and q.id in (37545,37546,37690,40077)
left outer join dbo.[Appuser] u on u.id=AM.CreatedBy
left outer join SeenClientAnswerChild SAC on AM.id=SAC.SeenClientAnswerMasterId 
)s
PIVOT(
MAX(Answer)
FOR  Question In (
[Month capturing for:],[Year capturing for:],[Monthly hours worked:],[Number of employees]
))p 
)AA
LEFT JOIN 
(
select SeenClientAnswerMasterId,CONVERT(DECIMAL(18,2),[Total overtime hours worked]) AS [Total overtime hours worked],[Number of days lost]
from (
select
E.EstablishmentName,cast(dateadd(MINUTE,cam.TimeOffSet,cam.CreatedOn) as date) as CapturedDate,dateadd(MINUTE,am.TimeOffSet,am.CreatedOn) as ResponseDate,am.id as ReferenceNo,cam.Id as SeenClientAnswerMasterId,am.IsPositive,am.IsResolved,a.Detail as Answer,q.Questiontitle as Question,u.id as UserId, u.name as UserName, am.Longitude ,am.Latitude
FROM dbo.[Group] g
inner join EstablishmentGroup eg on g.id=eg.groupid and g.id = 450 and eg.id=4615 
inner join Establishment e on  e.EstablishmentGroupId=eg.Id 
inner join answermaster am on am.EstablishmentId=e.id and (am.IsDeleted=0 or am.IsDeleted=null)
inner join Answers a on a.AnswerMasterId=am.id 
inner join Questions q on q.id=a.QuestionId and q.id in (28069,30257)
left outer join dbo.[Appuser] u on u.id=am.CreatedBy
left join SeenClientAnswerMaster cam on cam.Id=am.SeenClientAnswerMasterId and (cam.IsDeleted=0 or cam.IsDeleted=null)
left outer join SeenClientAnswerChild SAC on cam.id=SAC.SeenClientAnswerMasterId 
) s
pivot(
Max(Answer)
For  Question In (
[Total overtime hours worked],[Number of days lost]
))P
)BB ON AA.ReferenceNo=BB.SeenClientAnswerMasterId

UNION ALL

SELECT AA.EstablishmentName,AA.CapturedDate,AA.ReferenceNo,AA.[Month capturing for:],AA.[Year capturing for:],AA.Divison,AA.[Sub-Divison],AA.[Divison EstablishmentName],AA.[Monthly hours worked:],BB.[Total overtime hours worked] AS [Total overtime hours worked:],AA.[Number of employees],BB.[Number of days lost]
FROM 
(SELECT EstablishmentName,CapturedDate,ReferenceNo,[Month capturing for:],[Year capturing for:],'Trading' AS [Divison],'New Castle' AS [Sub-Divison],'SHEQ Incident Reporting - Trading New Castle' as [Divison EstablishmentName],
CONVERT(DECIMAL(18,2),[Monthly hours worked:]) AS [Monthly hours worked:],[Number of employees]
FROM (
SELECT E.EstablishmentName,dateadd(MINUTE,AM.TimeOffSet,AM.CreatedOn) as CapturedDate,AM.id as ReferenceNo,A.Detail as Answer,Q.Questiontitle as Question 
FROM dbo.[Group] G
inner join EstablishmentGroup EG on G.id=EG.groupid and g.id = 450 and eg.id=4615 
inner join Establishment E on  E.EstablishmentGroupId=EG.Id 
inner join SeenClientAnswerMaster AM on AM.EstablishmentId=E.id ANd (AM.IsDeleted=0 or AM.IsDeleted=null)
inner join [SeenClientAnswers] A on A.SeenclientAnswerMasterId=AM.id 
inner join SeenClientQuestions Q on Q.id=A.QuestionId and q.id in (37545,37546,37693,40088)
left outer join dbo.[Appuser] u on u.id=AM.CreatedBy
left outer join SeenClientAnswerChild SAC on AM.id=SAC.SeenClientAnswerMasterId 
)s
PIVOT(
MAX(Answer)
FOR  Question In (
[Month capturing for:],[Year capturing for:],[Monthly hours worked:],[Number of employees]
))p 
)AA
LEFT JOIN 
(
select SeenClientAnswerMasterId,CONVERT(DECIMAL(18,2),[Total overtime hours worked]) AS [Total overtime hours worked],[Number of days lost]
from (
select
E.EstablishmentName,cast(dateadd(MINUTE,cam.TimeOffSet,cam.CreatedOn) as date) as CapturedDate,dateadd(MINUTE,am.TimeOffSet,am.CreatedOn) as ResponseDate,am.id as ReferenceNo,cam.Id as SeenClientAnswerMasterId,am.IsPositive,am.IsResolved,a.Detail as Answer,q.Questiontitle as Question,u.id as UserId, u.name as UserName, am.Longitude ,am.Latitude
FROM dbo.[Group] g
inner join EstablishmentGroup eg on g.id=eg.groupid and g.id = 450 and eg.id=4615 
inner join Establishment e on  e.EstablishmentGroupId=eg.Id 
inner join answermaster am on am.EstablishmentId=e.id and (am.IsDeleted=0 or am.IsDeleted=null)
inner join Answers a on a.AnswerMasterId=am.id 
inner join Questions q on q.id=a.QuestionId and q.id in (28071,30258)
left outer join dbo.[Appuser] u on u.id=am.CreatedBy
left join SeenClientAnswerMaster cam on cam.Id=am.SeenClientAnswerMasterId and (cam.IsDeleted=0 or cam.IsDeleted=null)
left outer join SeenClientAnswerChild SAC on cam.id=SAC.SeenClientAnswerMasterId 
) s
pivot(
Max(Answer)
For  Question In (
[Total overtime hours worked],[Number of days lost]
))P
)BB ON AA.ReferenceNo=BB.SeenClientAnswerMasterId

UNION ALL

SELECT AA.EstablishmentName,AA.CapturedDate,AA.ReferenceNo,AA.[Month capturing for:],AA.[Year capturing for:],AA.Divison,AA.[Sub-Divison],AA.[Divison EstablishmentName],AA.[Monthly hours worked:],BB.[Total overtime hours worked] AS [Total overtime hours worked:],AA.[Number of employees],BB.[Number of days lost]
FROM 
(SELECT EstablishmentName,CapturedDate,ReferenceNo,[Month capturing for:],[Year capturing for:],'Trading' AS [Divison],'Phalaborwa' AS [Sub-Divison],'SHEQ Incident Reporting - Trading Phalaborwa' as [Divison EstablishmentName],
CONVERT(DECIMAL(18,2),[Monthly hours worked:]) AS [Monthly hours worked:],[Number of employees]
FROM (
SELECT E.EstablishmentName,dateadd(MINUTE,AM.TimeOffSet,AM.CreatedOn) as CapturedDate,AM.id as ReferenceNo,A.Detail as Answer,Q.Questiontitle as Question 
FROM dbo.[Group] G
inner join EstablishmentGroup EG on G.id=EG.groupid and g.id = 450 and eg.id=4615 
inner join Establishment E on  E.EstablishmentGroupId=EG.Id 
inner join SeenClientAnswerMaster AM on AM.EstablishmentId=E.id ANd (AM.IsDeleted=0 or AM.IsDeleted=null)
inner join [SeenClientAnswers] A on A.SeenclientAnswerMasterId=AM.id 
inner join SeenClientQuestions Q on Q.id=A.QuestionId and q.id in (37545,37546,37696,40089)
left outer join dbo.[Appuser] u on u.id=AM.CreatedBy
left outer join SeenClientAnswerChild SAC on AM.id=SAC.SeenClientAnswerMasterId 
)s
PIVOT(
MAX(Answer)
FOR  Question In (
[Month capturing for:],[Year capturing for:],[Monthly hours worked:],[Number of employees]
))p 
)AA
LEFT JOIN 
(
select SeenClientAnswerMasterId,CONVERT(DECIMAL(18,2),[Total overtime hours worked]) AS [Total overtime hours worked],[Number of days lost]
from (
select
E.EstablishmentName,cast(dateadd(MINUTE,cam.TimeOffSet,cam.CreatedOn) as date) as CapturedDate,dateadd(MINUTE,am.TimeOffSet,am.CreatedOn) as ResponseDate,am.id as ReferenceNo,cam.Id as SeenClientAnswerMasterId,am.IsPositive,am.IsResolved,a.Detail as Answer,q.Questiontitle as Question,u.id as UserId, u.name as UserName, am.Longitude ,am.Latitude
FROM dbo.[Group] g
inner join EstablishmentGroup eg on g.id=eg.groupid and g.id = 450 and eg.id=4615 
inner join Establishment e on  e.EstablishmentGroupId=eg.Id 
inner join answermaster am on am.EstablishmentId=e.id and (am.IsDeleted=0 or am.IsDeleted=null)
inner join Answers a on a.AnswerMasterId=am.id 
inner join Questions q on q.id=a.QuestionId and q.id in (28073,30259)
left outer join dbo.[Appuser] u on u.id=am.CreatedBy
left join SeenClientAnswerMaster cam on cam.Id=am.SeenClientAnswerMasterId and (cam.IsDeleted=0 or cam.IsDeleted=null)
left outer join SeenClientAnswerChild SAC on cam.id=SAC.SeenClientAnswerMasterId 
) s
pivot(
Max(Answer)
For  Question In (
[Total overtime hours worked],[Number of days lost]
))P
)BB ON AA.ReferenceNo=BB.SeenClientAnswerMasterId

UNION ALL

SELECT AA.EstablishmentName,AA.CapturedDate,AA.ReferenceNo,AA.[Month capturing for:],AA.[Year capturing for:],AA.Divison,AA.[Sub-Divison],AA.[Divison EstablishmentName],AA.[Monthly hours worked:],BB.[Total overtime hours worked] AS [Total overtime hours worked:],AA.[Number of employees],BB.[Number of days lost]
FROM 
(SELECT EstablishmentName,CapturedDate,ReferenceNo,[Month capturing for:],[Year capturing for:],'Trading' AS [Divison],'Polokwane' AS [Sub-Divison],'SHEQ Incident Reporting - Trading Polokwane' as [Divison EstablishmentName],
CONVERT(DECIMAL(18,2),[Monthly hours worked:]) AS [Monthly hours worked:],[Number of employees]
FROM (
SELECT E.EstablishmentName,dateadd(MINUTE,AM.TimeOffSet,AM.CreatedOn) as CapturedDate,AM.id as ReferenceNo,A.Detail as Answer,Q.Questiontitle as Question 
FROM dbo.[Group] G
inner join EstablishmentGroup EG on G.id=EG.groupid and g.id = 450 and eg.id=4615 
inner join Establishment E on  E.EstablishmentGroupId=EG.Id 
inner join SeenClientAnswerMaster AM on AM.EstablishmentId=E.id ANd (AM.IsDeleted=0 or AM.IsDeleted=null)
inner join [SeenClientAnswers] A on A.SeenclientAnswerMasterId=AM.id 
inner join SeenClientQuestions Q on Q.id=A.QuestionId and q.id in (37545,37546,37699,40090)
left outer join dbo.[Appuser] u on u.id=AM.CreatedBy
left outer join SeenClientAnswerChild SAC on AM.id=SAC.SeenClientAnswerMasterId 
)s
PIVOT(
MAX(Answer)
FOR  Question In (
[Month capturing for:],[Year capturing for:],[Monthly hours worked:],[Number of employees]
))p 
)AA
LEFT JOIN 
(
select SeenClientAnswerMasterId,CONVERT(DECIMAL(18,2),[Total overtime hours worked]) AS [Total overtime hours worked],[Number of days lost]
from (
select
E.EstablishmentName,cast(dateadd(MINUTE,cam.TimeOffSet,cam.CreatedOn) as date) as CapturedDate,dateadd(MINUTE,am.TimeOffSet,am.CreatedOn) as ResponseDate,am.id as ReferenceNo,cam.Id as SeenClientAnswerMasterId,am.IsPositive,am.IsResolved,a.Detail as Answer,q.Questiontitle as Question,u.id as UserId, u.name as UserName, am.Longitude ,am.Latitude
FROM dbo.[Group] g
inner join EstablishmentGroup eg on g.id=eg.groupid and g.id = 450 and eg.id=4615 
inner join Establishment e on  e.EstablishmentGroupId=eg.Id 
inner join answermaster am on am.EstablishmentId=e.id and (am.IsDeleted=0 or am.IsDeleted=null)
inner join Answers a on a.AnswerMasterId=am.id 
inner join Questions q on q.id=a.QuestionId and q.id in (28075,30260)
left outer join dbo.[Appuser] u on u.id=am.CreatedBy
left join SeenClientAnswerMaster cam on cam.Id=am.SeenClientAnswerMasterId and (cam.IsDeleted=0 or cam.IsDeleted=null)
left outer join SeenClientAnswerChild SAC on cam.id=SAC.SeenClientAnswerMasterId 
) s
pivot(
Max(Answer)
For  Question In (
[Total overtime hours worked],[Number of days lost]
))P
)BB ON AA.ReferenceNo=BB.SeenClientAnswerMasterId

UNION ALL

SELECT AA.EstablishmentName,AA.CapturedDate,AA.ReferenceNo,AA.[Month capturing for:],AA.[Year capturing for:],AA.Divison,AA.[Sub-Divison],AA.[Divison EstablishmentName],AA.[Monthly hours worked:],BB.[Total overtime hours worked] AS [Total overtime hours worked:],AA.[Number of employees],BB.[Number of days lost]
FROM 
(SELECT EstablishmentName,CapturedDate,ReferenceNo,[Month capturing for:],[Year capturing for:],'Trading' AS [Divison],'Port Elizabeth' AS [Sub-Divison],'SHEQ Incident Reporting - Trading Port Elizabeth' as [Divison EstablishmentName],
CONVERT(DECIMAL(18,2),[Monthly hours worked:]) AS [Monthly hours worked:],[Number of employees]
FROM (
SELECT E.EstablishmentName,dateadd(MINUTE,AM.TimeOffSet,AM.CreatedOn) as CapturedDate,AM.id as ReferenceNo,A.Detail as Answer,Q.Questiontitle as Question 
FROM dbo.[Group] G
inner join EstablishmentGroup EG on G.id=EG.groupid and g.id = 450 and eg.id=4615 
inner join Establishment E on  E.EstablishmentGroupId=EG.Id 
inner join SeenClientAnswerMaster AM on AM.EstablishmentId=E.id ANd (AM.IsDeleted=0 or AM.IsDeleted=null)
inner join [SeenClientAnswers] A on A.SeenclientAnswerMasterId=AM.id 
inner join SeenClientQuestions Q on Q.id=A.QuestionId and q.id in (37545,37546,37702,40091)
left outer join dbo.[Appuser] u on u.id=AM.CreatedBy
left outer join SeenClientAnswerChild SAC on AM.id=SAC.SeenClientAnswerMasterId 
)s
PIVOT(
MAX(Answer)
FOR  Question In (
[Month capturing for:],[Year capturing for:],[Monthly hours worked:],[Number of employees]
))p 
)AA
LEFT JOIN 
(
select SeenClientAnswerMasterId,CONVERT(DECIMAL(18,2),[Total overtime hours worked]) AS [Total overtime hours worked],[Number of days lost]
from (
select
E.EstablishmentName,cast(dateadd(MINUTE,cam.TimeOffSet,cam.CreatedOn) as date) as CapturedDate,dateadd(MINUTE,am.TimeOffSet,am.CreatedOn) as ResponseDate,am.id as ReferenceNo,cam.Id as SeenClientAnswerMasterId,am.IsPositive,am.IsResolved,a.Detail as Answer,q.Questiontitle as Question,u.id as UserId, u.name as UserName, am.Longitude ,am.Latitude
FROM dbo.[Group] g
inner join EstablishmentGroup eg on g.id=eg.groupid and g.id = 450 and eg.id=4615 
inner join Establishment e on  e.EstablishmentGroupId=eg.Id 
inner join answermaster am on am.EstablishmentId=e.id and (am.IsDeleted=0 or am.IsDeleted=null)
inner join Answers a on a.AnswerMasterId=am.id 
inner join Questions q on q.id=a.QuestionId and q.id in (28077,30261)
left outer join dbo.[Appuser] u on u.id=am.CreatedBy
left join SeenClientAnswerMaster cam on cam.Id=am.SeenClientAnswerMasterId and (cam.IsDeleted=0 or cam.IsDeleted=null)
left outer join SeenClientAnswerChild SAC on cam.id=SAC.SeenClientAnswerMasterId 
) s
pivot(
Max(Answer)
For  Question In (
[Total overtime hours worked],[Number of days lost]
))P
)BB ON AA.ReferenceNo=BB.SeenClientAnswerMasterId

UNION ALL

SELECT AA.EstablishmentName,AA.CapturedDate,AA.ReferenceNo,AA.[Month capturing for:],AA.[Year capturing for:],AA.Divison,AA.[Sub-Divison],AA.[Divison EstablishmentName],AA.[Monthly hours worked:],BB.[Total overtime hours worked] AS [Total overtime hours worked:],AA.[Number of employees],BB.[Number of days lost]
FROM 
(SELECT EstablishmentName,CapturedDate,ReferenceNo,[Month capturing for:],[Year capturing for:],'Trading' AS [Divison],'Port Shepstone' AS [Sub-Divison],'SHEQ Incident Reporting - Trading Port Shepstone' as [Divison EstablishmentName],
CONVERT(DECIMAL(18,2),[Monthly hours worked:]) AS [Monthly hours worked:],[Number of employees]
FROM (
SELECT E.EstablishmentName,dateadd(MINUTE,AM.TimeOffSet,AM.CreatedOn) as CapturedDate,AM.id as ReferenceNo,A.Detail as Answer,Q.Questiontitle as Question 
FROM dbo.[Group] G
inner join EstablishmentGroup EG on G.id=EG.groupid and g.id = 450 and eg.id=4615 
inner join Establishment E on  E.EstablishmentGroupId=EG.Id 
inner join SeenClientAnswerMaster AM on AM.EstablishmentId=E.id ANd (AM.IsDeleted=0 or AM.IsDeleted=null)
inner join [SeenClientAnswers] A on A.SeenclientAnswerMasterId=AM.id 
inner join SeenClientQuestions Q on Q.id=A.QuestionId and q.id in (37545,37546,37705,40092)
left outer join dbo.[Appuser] u on u.id=AM.CreatedBy
left outer join SeenClientAnswerChild SAC on AM.id=SAC.SeenClientAnswerMasterId 
)s
PIVOT(
MAX(Answer)
FOR  Question In (
[Month capturing for:],[Year capturing for:],[Monthly hours worked:],[Number of employees]
))p 
)AA
LEFT JOIN 
(
select SeenClientAnswerMasterId,CONVERT(DECIMAL(18,2),[Total overtime hours worked]) AS [Total overtime hours worked],[Number of days lost]
from (
select
E.EstablishmentName,cast(dateadd(MINUTE,cam.TimeOffSet,cam.CreatedOn) as date) as CapturedDate,dateadd(MINUTE,am.TimeOffSet,am.CreatedOn) as ResponseDate,am.id as ReferenceNo,cam.Id as SeenClientAnswerMasterId,am.IsPositive,am.IsResolved,a.Detail as Answer,q.Questiontitle as Question,u.id as UserId, u.name as UserName, am.Longitude ,am.Latitude
FROM dbo.[Group] g
inner join EstablishmentGroup eg on g.id=eg.groupid and g.id = 450 and eg.id=4615 
inner join Establishment e on  e.EstablishmentGroupId=eg.Id 
inner join answermaster am on am.EstablishmentId=e.id and (am.IsDeleted=0 or am.IsDeleted=null)
inner join Answers a on a.AnswerMasterId=am.id 
inner join Questions q on q.id=a.QuestionId and q.id in (28079,30262)
left outer join dbo.[Appuser] u on u.id=am.CreatedBy
left join SeenClientAnswerMaster cam on cam.Id=am.SeenClientAnswerMasterId and (cam.IsDeleted=0 or cam.IsDeleted=null)
left outer join SeenClientAnswerChild SAC on cam.id=SAC.SeenClientAnswerMasterId 
) s
pivot(
Max(Answer)
For  Question In (
[Total overtime hours worked],[Number of days lost]
))P
)BB ON AA.ReferenceNo=BB.SeenClientAnswerMasterId

UNION ALL

SELECT AA.EstablishmentName,AA.CapturedDate,AA.ReferenceNo,AA.[Month capturing for:],AA.[Year capturing for:],AA.Divison,AA.[Sub-Divison],AA.[Divison EstablishmentName],AA.[Monthly hours worked:],BB.[Total overtime hours worked] AS [Total overtime hours worked:],AA.[Number of employees],BB.[Number of days lost]
FROM 
(SELECT EstablishmentName,CapturedDate,ReferenceNo,[Month capturing for:],[Year capturing for:],'Trading' AS [Divison],'Richards Bay' AS [Sub-Divison],'SHEQ Incident Reporting - Trading Richards Bay' as [Divison EstablishmentName],
CONVERT(DECIMAL(18,2),[Monthly hours planned:]) AS [Monthly hours worked:],[Number of employees]
FROM (
SELECT E.EstablishmentName,dateadd(MINUTE,AM.TimeOffSet,AM.CreatedOn) as CapturedDate,AM.id as ReferenceNo,A.Detail as Answer,Q.Questiontitle as Question 
FROM dbo.[Group] G
inner join EstablishmentGroup EG on G.id=EG.groupid and g.id = 450 and eg.id=4615 
inner join Establishment E on  E.EstablishmentGroupId=EG.Id 
inner join SeenClientAnswerMaster AM on AM.EstablishmentId=E.id ANd (AM.IsDeleted=0 or AM.IsDeleted=null)
inner join [SeenClientAnswers] A on A.SeenclientAnswerMasterId=AM.id 
inner join SeenClientQuestions Q on Q.id=A.QuestionId and q.id in (37545,37546,37708,40093)
left outer join dbo.[Appuser] u on u.id=AM.CreatedBy
left outer join SeenClientAnswerChild SAC on AM.id=SAC.SeenClientAnswerMasterId 
)s
PIVOT(
MAX(Answer)
FOR  Question In (
[Month capturing for:],[Year capturing for:],[Monthly hours planned:],[Number of employees]
))p 
)AA
LEFT JOIN 
(
select SeenClientAnswerMasterId,CONVERT(DECIMAL(18,2),[Total overtime hours worked]) AS [Total overtime hours worked],[Number of days lost]
from (
select
E.EstablishmentName,cast(dateadd(MINUTE,cam.TimeOffSet,cam.CreatedOn) as date) as CapturedDate,dateadd(MINUTE,am.TimeOffSet,am.CreatedOn) as ResponseDate,am.id as ReferenceNo,cam.Id as SeenClientAnswerMasterId,am.IsPositive,am.IsResolved,a.Detail as Answer,q.Questiontitle as Question,u.id as UserId, u.name as UserName, am.Longitude ,am.Latitude
FROM dbo.[Group] g
inner join EstablishmentGroup eg on g.id=eg.groupid and g.id = 450 and eg.id=4615 
inner join Establishment e on  e.EstablishmentGroupId=eg.Id 
inner join answermaster am on am.EstablishmentId=e.id and (am.IsDeleted=0 or am.IsDeleted=null)
inner join Answers a on a.AnswerMasterId=am.id 
inner join Questions q on q.id=a.QuestionId and q.id in (28081,30263)
left outer join dbo.[Appuser] u on u.id=am.CreatedBy
left join SeenClientAnswerMaster cam on cam.Id=am.SeenClientAnswerMasterId and (cam.IsDeleted=0 or cam.IsDeleted=null)
left outer join SeenClientAnswerChild SAC on cam.id=SAC.SeenClientAnswerMasterId 
) s
pivot(
Max(Answer)
For  Question In (
[Total overtime hours worked],[Number of days lost]
))P
)BB ON AA.ReferenceNo=BB.SeenClientAnswerMasterId

UNION ALL

SELECT AA.EstablishmentName,AA.CapturedDate,AA.ReferenceNo,AA.[Month capturing for:],AA.[Year capturing for:],AA.Divison,AA.[Sub-Divison],AA.[Divison EstablishmentName],AA.[Monthly hours worked:],BB.[Total overtime hours worked] AS [Total overtime hours worked:],AA.[Number of employees],BB.[Number of days lost]
FROM 
(SELECT EstablishmentName,CapturedDate,ReferenceNo,[Month capturing for:],[Year capturing for:],'Trading' AS [Divison],'Pipes, Fittings & Flanges' AS [Sub-Divison],'SHEQ Incident Reporting - Trading Pipes, Fittings & Flanges' as [Divison EstablishmentName],
CONVERT(DECIMAL(18,2),[Monthly hours worked:]) AS [Monthly hours worked:],[Number of employees]
FROM (
SELECT E.EstablishmentName,dateadd(MINUTE,AM.TimeOffSet,AM.CreatedOn) as CapturedDate,AM.id as ReferenceNo,A.Detail as Answer,Q.Questiontitle as Question 
FROM dbo.[Group] G
inner join EstablishmentGroup EG on G.id=EG.groupid and g.id = 450 and eg.id=4615 
inner join Establishment E on  E.EstablishmentGroupId=EG.Id 
inner join SeenClientAnswerMaster AM on AM.EstablishmentId=E.id ANd (AM.IsDeleted=0 or AM.IsDeleted=null)
inner join [SeenClientAnswers] A on A.SeenclientAnswerMasterId=AM.id 
inner join SeenClientQuestions Q on Q.id=A.QuestionId and q.id in (37545,37546,37711,40094)
left outer join dbo.[Appuser] u on u.id=AM.CreatedBy
left outer join SeenClientAnswerChild SAC on AM.id=SAC.SeenClientAnswerMasterId 
)s
PIVOT(
MAX(Answer)
FOR  Question In (
[Month capturing for:],[Year capturing for:],[Monthly hours worked:],[Number of employees]
))p 
)AA
LEFT JOIN 
(
select SeenClientAnswerMasterId,CONVERT(DECIMAL(18,2),[Total overtime hours worked]) AS [Total overtime hours worked],[Number of days lost]
from (
select
E.EstablishmentName,cast(dateadd(MINUTE,cam.TimeOffSet,cam.CreatedOn) as date) as CapturedDate,dateadd(MINUTE,am.TimeOffSet,am.CreatedOn) as ResponseDate,am.id as ReferenceNo,cam.Id as SeenClientAnswerMasterId,am.IsPositive,am.IsResolved,a.Detail as Answer,q.Questiontitle as Question,u.id as UserId, u.name as UserName, am.Longitude ,am.Latitude
FROM dbo.[Group] g
inner join EstablishmentGroup eg on g.id=eg.groupid and g.id = 450 and eg.id=4615 
inner join Establishment e on  e.EstablishmentGroupId=eg.Id 
inner join answermaster am on am.EstablishmentId=e.id and (am.IsDeleted=0 or am.IsDeleted=null)
inner join Answers a on a.AnswerMasterId=am.id 
inner join Questions q on q.id=a.QuestionId and q.id in (28083,30264)
left outer join dbo.[Appuser] u on u.id=am.CreatedBy
left join SeenClientAnswerMaster cam on cam.Id=am.SeenClientAnswerMasterId and (cam.IsDeleted=0 or cam.IsDeleted=null)
left outer join SeenClientAnswerChild SAC on cam.id=SAC.SeenClientAnswerMasterId 
) s
pivot(
Max(Answer)
For  Question In (
[Total overtime hours worked],[Number of days lost]
))P
)BB ON AA.ReferenceNo=BB.SeenClientAnswerMasterId

UNION ALL

SELECT AA.EstablishmentName,AA.CapturedDate,AA.ReferenceNo,AA.[Month capturing for:],AA.[Year capturing for:],AA.Divison,AA.[Sub-Divison],AA.[Divison EstablishmentName],AA.[Monthly hours worked:],BB.[Total overtime hours worked] AS [Total overtime hours worked:],AA.[Number of employees],BB.[Number of days lost]
FROM 
(SELECT EstablishmentName,CapturedDate,ReferenceNo,[Month capturing for:],[Year capturing for:],'Trading' AS [Divison],'Welkom' AS [Sub-Divison],'SHEQ Incident Reporting - Trading Welkom' as [Divison EstablishmentName],
CONVERT(DECIMAL(18,2),[Monthly hours worked:]) AS [Monthly hours worked:],[Number of employees]
FROM (
SELECT E.EstablishmentName,dateadd(MINUTE,AM.TimeOffSet,AM.CreatedOn) as CapturedDate,AM.id as ReferenceNo,A.Detail as Answer,Q.Questiontitle as Question 
FROM dbo.[Group] G
inner join EstablishmentGroup EG on G.id=EG.groupid and g.id = 450 and eg.id=4615 
inner join Establishment E on  E.EstablishmentGroupId=EG.Id 
inner join SeenClientAnswerMaster AM on AM.EstablishmentId=E.id ANd (AM.IsDeleted=0 or AM.IsDeleted=null)
inner join [SeenClientAnswers] A on A.SeenclientAnswerMasterId=AM.id 
inner join SeenClientQuestions Q on Q.id=A.QuestionId and q.id in (37545,37546,37714,40095)
left outer join dbo.[Appuser] u on u.id=AM.CreatedBy
left outer join SeenClientAnswerChild SAC on AM.id=SAC.SeenClientAnswerMasterId 
)s
PIVOT(
MAX(Answer)
FOR  Question In (
[Month capturing for:],[Year capturing for:],[Monthly hours worked:],[Number of employees]
))p 
)AA
LEFT JOIN 
(
select SeenClientAnswerMasterId,CONVERT(DECIMAL(18,2),[Total overtime hours worked]) AS [Total overtime hours worked],[Number of days lost]
from (
select
E.EstablishmentName,cast(dateadd(MINUTE,cam.TimeOffSet,cam.CreatedOn) as date) as CapturedDate,dateadd(MINUTE,am.TimeOffSet,am.CreatedOn) as ResponseDate,am.id as ReferenceNo,cam.Id as SeenClientAnswerMasterId,am.IsPositive,am.IsResolved,a.Detail as Answer,q.Questiontitle as Question,u.id as UserId, u.name as UserName, am.Longitude ,am.Latitude
FROM dbo.[Group] g
inner join EstablishmentGroup eg on g.id=eg.groupid and g.id = 450 and eg.id=4615 
inner join Establishment e on  e.EstablishmentGroupId=eg.Id 
inner join answermaster am on am.EstablishmentId=e.id and (am.IsDeleted=0 or am.IsDeleted=null)
inner join Answers a on a.AnswerMasterId=am.id 
inner join Questions q on q.id=a.QuestionId and q.id in (28085,30265)
left outer join dbo.[Appuser] u on u.id=am.CreatedBy
left join SeenClientAnswerMaster cam on cam.Id=am.SeenClientAnswerMasterId and (cam.IsDeleted=0 or cam.IsDeleted=null)
left outer join SeenClientAnswerChild SAC on cam.id=SAC.SeenClientAnswerMasterId 
) s
pivot(
Max(Answer)
For  Question In (
[Total overtime hours worked],[Number of days lost]
))P
)BB ON AA.ReferenceNo=BB.SeenClientAnswerMasterId

UNION ALL

SELECT AA.EstablishmentName,AA.CapturedDate,AA.ReferenceNo,AA.[Month capturing for:],AA.[Year capturing for:],AA.Divison,AA.[Sub-Divison],AA.[Divison EstablishmentName],AA.[Monthly hours worked:],BB.[Total overtime hours worked] AS [Total overtime hours worked:],AA.[Number of employees],BB.[Number of days lost]
FROM 
(SELECT EstablishmentName,CapturedDate,ReferenceNo,[Month capturing for:],[Year capturing for:],'VRN' AS [Divison],'Head Office' AS [Sub-Divison],'SHEQ Incident Reporting - VRN Head Office' as [Divison EstablishmentName],
CONVERT(DECIMAL(18,2),[Monthly hours worked:]) AS [Monthly hours worked:],[Number of employees]
FROM (
SELECT E.EstablishmentName,dateadd(MINUTE,AM.TimeOffSet,AM.CreatedOn) as CapturedDate,AM.id as ReferenceNo,A.Detail as Answer,Q.Questiontitle as Question 
FROM dbo.[Group] G
inner join EstablishmentGroup EG on G.id=EG.groupid and g.id = 450 and eg.id=4615 
inner join Establishment E on  E.EstablishmentGroupId=EG.Id 
inner join SeenClientAnswerMaster AM on AM.EstablishmentId=E.id ANd (AM.IsDeleted=0 or AM.IsDeleted=null)
inner join [SeenClientAnswers] A on A.SeenclientAnswerMasterId=AM.id 
inner join SeenClientQuestions Q on Q.id=A.QuestionId and q.id in (37545,37546,37718,40096)
left outer join dbo.[Appuser] u on u.id=AM.CreatedBy
left outer join SeenClientAnswerChild SAC on AM.id=SAC.SeenClientAnswerMasterId 
)s
PIVOT(
MAX(Answer)
FOR  Question In (
[Month capturing for:],[Year capturing for:],[Monthly hours worked:],[Number of employees]
))p 
)AA
LEFT JOIN 
(
select SeenClientAnswerMasterId,CONVERT(DECIMAL(18,2),[Total overtime hours worked]) AS [Total overtime hours worked],[Number of days lost]
from (
select
E.EstablishmentName,cast(dateadd(MINUTE,cam.TimeOffSet,cam.CreatedOn) as date) as CapturedDate,dateadd(MINUTE,am.TimeOffSet,am.CreatedOn) as ResponseDate,am.id as ReferenceNo,cam.Id as SeenClientAnswerMasterId,am.IsPositive,am.IsResolved,a.Detail as Answer,q.Questiontitle as Question,u.id as UserId, u.name as UserName, am.Longitude ,am.Latitude
FROM dbo.[Group] g
inner join EstablishmentGroup eg on g.id=eg.groupid and g.id = 450 and eg.id=4615 
inner join Establishment e on  e.EstablishmentGroupId=eg.Id 
inner join answermaster am on am.EstablishmentId=e.id and (am.IsDeleted=0 or am.IsDeleted=null)
inner join Answers a on a.AnswerMasterId=am.id 
inner join Questions q on q.id=a.QuestionId and q.id in (28088,30277)
left outer join dbo.[Appuser] u on u.id=am.CreatedBy
left join SeenClientAnswerMaster cam on cam.Id=am.SeenClientAnswerMasterId and (cam.IsDeleted=0 or cam.IsDeleted=null)
left outer join SeenClientAnswerChild SAC on cam.id=SAC.SeenClientAnswerMasterId 
) s
pivot(
Max(Answer)
For  Question In (
[Total overtime hours worked],[Number of days lost]
))P
)BB ON AA.ReferenceNo=BB.SeenClientAnswerMasterId

UNION ALL

SELECT AA.EstablishmentName,AA.CapturedDate,AA.ReferenceNo,AA.[Month capturing for:],AA.[Year capturing for:],AA.Divison,AA.[Sub-Divison],AA.[Divison EstablishmentName],AA.[Monthly hours worked:],BB.[Total overtime hours worked] AS [Total overtime hours worked:],AA.[Number of employees],BB.[Number of days lost]
FROM 
(SELECT EstablishmentName,CapturedDate,ReferenceNo,[Month capturing for:],[Year capturing for:],'VRN' AS [Divison],'Cape Town' AS [Sub-Divison],'SHEQ Incident Reporting - VRN Cape Town' as [Divison EstablishmentName],
CONVERT(DECIMAL(18,2),[Monthly hours worked:]) AS [Monthly hours worked:],[Number of employees]
FROM (
SELECT E.EstablishmentName,dateadd(MINUTE,AM.TimeOffSet,AM.CreatedOn) as CapturedDate,AM.id as ReferenceNo,A.Detail as Answer,Q.Questiontitle as Question 
FROM dbo.[Group] G
inner join EstablishmentGroup EG on G.id=EG.groupid and g.id = 450 and eg.id=4615 
inner join Establishment E on  E.EstablishmentGroupId=EG.Id 
inner join SeenClientAnswerMaster AM on AM.EstablishmentId=E.id ANd (AM.IsDeleted=0 or AM.IsDeleted=null)
inner join [SeenClientAnswers] A on A.SeenclientAnswerMasterId=AM.id 
inner join SeenClientQuestions Q on Q.id=A.QuestionId and q.id in (37545,37546,37721,40097)
left outer join dbo.[Appuser] u on u.id=AM.CreatedBy
left outer join SeenClientAnswerChild SAC on AM.id=SAC.SeenClientAnswerMasterId 
)s
PIVOT(
MAX(Answer)
FOR  Question In (
[Month capturing for:],[Year capturing for:],[Monthly hours worked:],[Number of employees]
))p 
)AA
LEFT JOIN 
(
select SeenClientAnswerMasterId,CONVERT(DECIMAL(18,2),[Total overtime hours worked]) AS [Total overtime hours worked],[Number of days lost]
from (
select
E.EstablishmentName,cast(dateadd(MINUTE,cam.TimeOffSet,cam.CreatedOn) as date) as CapturedDate,dateadd(MINUTE,am.TimeOffSet,am.CreatedOn) as ResponseDate,am.id as ReferenceNo,cam.Id as SeenClientAnswerMasterId,am.IsPositive,am.IsResolved,a.Detail as Answer,q.Questiontitle as Question,u.id as UserId, u.name as UserName, am.Longitude ,am.Latitude
FROM dbo.[Group] g
inner join EstablishmentGroup eg on g.id=eg.groupid and g.id = 450 and eg.id=4615 
inner join Establishment e on  e.EstablishmentGroupId=eg.Id 
inner join answermaster am on am.EstablishmentId=e.id and (am.IsDeleted=0 or am.IsDeleted=null)
inner join Answers a on a.AnswerMasterId=am.id 
inner join Questions q on q.id=a.QuestionId and q.id in (28090,30278)
left outer join dbo.[Appuser] u on u.id=am.CreatedBy
left join SeenClientAnswerMaster cam on cam.Id=am.SeenClientAnswerMasterId and (cam.IsDeleted=0 or cam.IsDeleted=null)
left outer join SeenClientAnswerChild SAC on cam.id=SAC.SeenClientAnswerMasterId 
) s
pivot(
Max(Answer)
For  Question In (
[Total overtime hours worked],[Number of days lost]
))P
)BB ON AA.ReferenceNo=BB.SeenClientAnswerMasterId

UNION ALL

SELECT AA.EstablishmentName,AA.CapturedDate,AA.ReferenceNo,AA.[Month capturing for:],AA.[Year capturing for:],AA.Divison,AA.[Sub-Divison],AA.[Divison EstablishmentName],AA.[Monthly hours worked:],BB.[Total overtime hours worked] AS [Total overtime hours worked:],AA.[Number of employees],BB.[Number of days lost]
FROM 
(SELECT EstablishmentName,CapturedDate,ReferenceNo,[Month capturing for:],[Year capturing for:],'VRN' AS [Divison],'Durban' AS [Sub-Divison],'SHEQ Incident Reporting - VRN Durban' as [Divison EstablishmentName],
CONVERT(DECIMAL(18,2),[Monthly hours worked:]) AS [Monthly hours worked:],[Number of employees]
FROM (
SELECT E.EstablishmentName,dateadd(MINUTE,AM.TimeOffSet,AM.CreatedOn) as CapturedDate,AM.id as ReferenceNo,A.Detail as Answer,Q.Questiontitle as Question 
FROM dbo.[Group] G
inner join EstablishmentGroup EG on G.id=EG.groupid and g.id = 450 and eg.id=4615 
inner join Establishment E on  E.EstablishmentGroupId=EG.Id 
inner join SeenClientAnswerMaster AM on AM.EstablishmentId=E.id ANd (AM.IsDeleted=0 or AM.IsDeleted=null)
inner join [SeenClientAnswers] A on A.SeenclientAnswerMasterId=AM.id 
inner join SeenClientQuestions Q on Q.id=A.QuestionId and q.id in (37545,37546,37724,40098)
left outer join dbo.[Appuser] u on u.id=AM.CreatedBy
left outer join SeenClientAnswerChild SAC on AM.id=SAC.SeenClientAnswerMasterId 
)s
PIVOT(
MAX(Answer)
FOR  Question In (
[Month capturing for:],[Year capturing for:],[Monthly hours worked:],[Number of employees]
))p 
)AA
LEFT JOIN 
(
select SeenClientAnswerMasterId,CONVERT(DECIMAL(18,2),[Total overtime hours worked]) AS [Total overtime hours worked],[Number of days lost]
from (
select
E.EstablishmentName,cast(dateadd(MINUTE,cam.TimeOffSet,cam.CreatedOn) as date) as CapturedDate,dateadd(MINUTE,am.TimeOffSet,am.CreatedOn) as ResponseDate,am.id as ReferenceNo,cam.Id as SeenClientAnswerMasterId,am.IsPositive,am.IsResolved,a.Detail as Answer,q.Questiontitle as Question,u.id as UserId, u.name as UserName, am.Longitude ,am.Latitude
FROM dbo.[Group] g
inner join EstablishmentGroup eg on g.id=eg.groupid and g.id = 450 and eg.id=4615 
inner join Establishment e on  e.EstablishmentGroupId=eg.Id 
inner join answermaster am on am.EstablishmentId=e.id and (am.IsDeleted=0 or am.IsDeleted=null)
inner join Answers a on a.AnswerMasterId=am.id 
inner join Questions q on q.id=a.QuestionId and q.id in (28092,30279)
left outer join dbo.[Appuser] u on u.id=am.CreatedBy
left join SeenClientAnswerMaster cam on cam.Id=am.SeenClientAnswerMasterId and (cam.IsDeleted=0 or cam.IsDeleted=null)
left outer join SeenClientAnswerChild SAC on cam.id=SAC.SeenClientAnswerMasterId 
) s
pivot(
Max(Answer)
For  Question In (
[Total overtime hours worked],[Number of days lost]
))P
)BB ON AA.ReferenceNo=BB.SeenClientAnswerMasterId

UNION ALL

SELECT AA.EstablishmentName,AA.CapturedDate,AA.ReferenceNo,AA.[Month capturing for:],AA.[Year capturing for:],AA.Divison,AA.[Sub-Divison],AA.[Divison EstablishmentName],AA.[Monthly hours worked:],BB.[Total overtime hours worked] AS [Total overtime hours worked:],AA.[Number of employees],BB.[Number of days lost]
FROM 
(SELECT EstablishmentName,CapturedDate,ReferenceNo,[Month capturing for:],[Year capturing for:],'VRN' AS [Divison],'Kathu' AS [Sub-Divison],'SHEQ Incident Reporting - VRN Kathu' as [Divison EstablishmentName],
CONVERT(DECIMAL(18,2),[Monthly hours worked:]) AS [Monthly hours worked:],[Number of employees]
FROM (
SELECT E.EstablishmentName,dateadd(MINUTE,AM.TimeOffSet,AM.CreatedOn) as CapturedDate,AM.id as ReferenceNo,A.Detail as Answer,Q.Questiontitle as Question 
FROM dbo.[Group] G
inner join EstablishmentGroup EG on G.id=EG.groupid and g.id = 450 and eg.id=4615 
inner join Establishment E on  E.EstablishmentGroupId=EG.Id 
inner join SeenClientAnswerMaster AM on AM.EstablishmentId=E.id ANd (AM.IsDeleted=0 or AM.IsDeleted=null)
inner join [SeenClientAnswers] A on A.SeenclientAnswerMasterId=AM.id 
inner join SeenClientQuestions Q on Q.id=A.QuestionId and q.id in (37545,37546,37727,40099)
left outer join dbo.[Appuser] u on u.id=AM.CreatedBy
left outer join SeenClientAnswerChild SAC on AM.id=SAC.SeenClientAnswerMasterId 
)s
PIVOT(
MAX(Answer)
FOR  Question In (
[Month capturing for:],[Year capturing for:],[Monthly hours worked:],[Number of employees]
))p 
)AA
LEFT JOIN 
(
select SeenClientAnswerMasterId,CONVERT(DECIMAL(18,2),[Total overtime hours worked]) AS [Total overtime hours worked],[Number of days lost]
from (
select
E.EstablishmentName,cast(dateadd(MINUTE,cam.TimeOffSet,cam.CreatedOn) as date) as CapturedDate,dateadd(MINUTE,am.TimeOffSet,am.CreatedOn) as ResponseDate,am.id as ReferenceNo,cam.Id as SeenClientAnswerMasterId,am.IsPositive,am.IsResolved,a.Detail as Answer,q.Questiontitle as Question,u.id as UserId, u.name as UserName, am.Longitude ,am.Latitude
FROM dbo.[Group] g
inner join EstablishmentGroup eg on g.id=eg.groupid and g.id = 450 and eg.id=4615 
inner join Establishment e on  e.EstablishmentGroupId=eg.Id 
inner join answermaster am on am.EstablishmentId=e.id and (am.IsDeleted=0 or am.IsDeleted=null)
inner join Answers a on a.AnswerMasterId=am.id 
inner join Questions q on q.id=a.QuestionId and q.id in (28094,30280)
left outer join dbo.[Appuser] u on u.id=am.CreatedBy
left join SeenClientAnswerMaster cam on cam.Id=am.SeenClientAnswerMasterId and (cam.IsDeleted=0 or cam.IsDeleted=null)
left outer join SeenClientAnswerChild SAC on cam.id=SAC.SeenClientAnswerMasterId 
) s
pivot(
Max(Answer)
For  Question In (
[Total overtime hours worked],[Number of days lost]
))P
)BB ON AA.ReferenceNo=BB.SeenClientAnswerMasterId

UNION ALL

SELECT AA.EstablishmentName,AA.CapturedDate,AA.ReferenceNo,AA.[Month capturing for:],AA.[Year capturing for:],AA.Divison,AA.[Sub-Divison],AA.[Divison EstablishmentName],AA.[Monthly hours worked:],BB.[Total overtime hours worked] AS [Total overtime hours worked:],AA.[Number of employees],BB.[Number of days lost]
FROM 
(SELECT EstablishmentName,CapturedDate,ReferenceNo,[Month capturing for:],[Year capturing for:],'VRN' AS [Divison],'Klerksdorp' AS [Sub-Divison],'SHEQ Incident Reporting - VRN Klerksdorp' as [Divison EstablishmentName],
CONVERT(DECIMAL(18,2),[Monthly hours worked:]) AS [Monthly hours worked:],[Number of employees]
FROM (
SELECT E.EstablishmentName,dateadd(MINUTE,AM.TimeOffSet,AM.CreatedOn) as CapturedDate,AM.id as ReferenceNo,A.Detail as Answer,Q.Questiontitle as Question 
FROM dbo.[Group] G
inner join EstablishmentGroup EG on G.id=EG.groupid and g.id = 450 and eg.id=4615 
inner join Establishment E on  E.EstablishmentGroupId=EG.Id 
inner join SeenClientAnswerMaster AM on AM.EstablishmentId=E.id ANd (AM.IsDeleted=0 or AM.IsDeleted=null)
inner join [SeenClientAnswers] A on A.SeenclientAnswerMasterId=AM.id 
inner join SeenClientQuestions Q on Q.id=A.QuestionId and q.id in (37545,37546,37730,40100)
left outer join dbo.[Appuser] u on u.id=AM.CreatedBy
left outer join SeenClientAnswerChild SAC on AM.id=SAC.SeenClientAnswerMasterId 
)s
PIVOT(
MAX(Answer)
FOR  Question In (
[Month capturing for:],[Year capturing for:],[Monthly hours worked:],[Number of employees]
))p 
)AA
LEFT JOIN 
(
select SeenClientAnswerMasterId,CONVERT(DECIMAL(18,2),[Total overtime hours worked]) AS [Total overtime hours worked],[Number of days lost]
from (
select
E.EstablishmentName,cast(dateadd(MINUTE,cam.TimeOffSet,cam.CreatedOn) as date) as CapturedDate,dateadd(MINUTE,am.TimeOffSet,am.CreatedOn) as ResponseDate,am.id as ReferenceNo,cam.Id as SeenClientAnswerMasterId,am.IsPositive,am.IsResolved,a.Detail as Answer,q.Questiontitle as Question,u.id as UserId, u.name as UserName, am.Longitude ,am.Latitude
FROM dbo.[Group] g
inner join EstablishmentGroup eg on g.id=eg.groupid and g.id = 450 and eg.id=4615 
inner join Establishment e on  e.EstablishmentGroupId=eg.Id 
inner join answermaster am on am.EstablishmentId=e.id and (am.IsDeleted=0 or am.IsDeleted=null)
inner join Answers a on a.AnswerMasterId=am.id 
inner join Questions q on q.id=a.QuestionId and q.id in (30378,30281)
left outer join dbo.[Appuser] u on u.id=am.CreatedBy
left join SeenClientAnswerMaster cam on cam.Id=am.SeenClientAnswerMasterId and (cam.IsDeleted=0 or cam.IsDeleted=null)
left outer join SeenClientAnswerChild SAC on cam.id=SAC.SeenClientAnswerMasterId 
) s
pivot(
Max(Answer)
For  Question In (
[Total overtime hours worked],[Number of days lost]
))P
)BB ON AA.ReferenceNo=BB.SeenClientAnswerMasterId

UNION ALL

SELECT AA.EstablishmentName,AA.CapturedDate,AA.ReferenceNo,AA.[Month capturing for:],AA.[Year capturing for:],AA.Divison,AA.[Sub-Divison],AA.[Divison EstablishmentName],AA.[Monthly hours worked:],BB.[Total overtime hours worked] AS [Total overtime hours worked:],AA.[Number of employees],BB.[Number of days lost]
FROM 
(SELECT EstablishmentName,CapturedDate,ReferenceNo,[Month capturing for:],[Year capturing for:],'VRN' AS [Divison],'Lephalale' AS [Sub-Divison],'SHEQ Incident Reporting - VRN Lephalale' as [Divison EstablishmentName],
CONVERT(DECIMAL(18,2),[Monthly hours worked:]) AS [Monthly hours worked:],[Number of employees]
FROM (
SELECT E.EstablishmentName,dateadd(MINUTE,AM.TimeOffSet,AM.CreatedOn) as CapturedDate,AM.id as ReferenceNo,A.Detail as Answer,Q.Questiontitle as Question 
FROM dbo.[Group] G
inner join EstablishmentGroup EG on G.id=EG.groupid and g.id = 450 and eg.id=4615 
inner join Establishment E on  E.EstablishmentGroupId=EG.Id 
inner join SeenClientAnswerMaster AM on AM.EstablishmentId=E.id ANd (AM.IsDeleted=0 or AM.IsDeleted=null)
inner join [SeenClientAnswers] A on A.SeenclientAnswerMasterId=AM.id 
inner join SeenClientQuestions Q on Q.id=A.QuestionId and q.id in (37545,37546,37733,40101)
left outer join dbo.[Appuser] u on u.id=AM.CreatedBy
left outer join SeenClientAnswerChild SAC on AM.id=SAC.SeenClientAnswerMasterId 
)s
PIVOT(
MAX(Answer)
FOR  Question In (
[Month capturing for:],[Year capturing for:],[Monthly hours worked:],[Number of employees]
))p 
)AA
LEFT JOIN 
(
select SeenClientAnswerMasterId,CONVERT(DECIMAL(18,2),[Total overtime hours worked]) AS [Total overtime hours worked],[Number of days lost]
from (
select
E.EstablishmentName,cast(dateadd(MINUTE,cam.TimeOffSet,cam.CreatedOn) as date) as CapturedDate,dateadd(MINUTE,am.TimeOffSet,am.CreatedOn) as ResponseDate,am.id as ReferenceNo,cam.Id as SeenClientAnswerMasterId,am.IsPositive,am.IsResolved,a.Detail as Answer,q.Questiontitle as Question,u.id as UserId, u.name as UserName, am.Longitude ,am.Latitude
FROM dbo.[Group] g
inner join EstablishmentGroup eg on g.id=eg.groupid and g.id = 450 and eg.id=4615 
inner join Establishment e on  e.EstablishmentGroupId=eg.Id 
inner join answermaster am on am.EstablishmentId=e.id and (am.IsDeleted=0 or am.IsDeleted=null)
inner join Answers a on a.AnswerMasterId=am.id 
inner join Questions q on q.id=a.QuestionId and q.id in (28098,30282)
left outer join dbo.[Appuser] u on u.id=am.CreatedBy
left join SeenClientAnswerMaster cam on cam.Id=am.SeenClientAnswerMasterId and (cam.IsDeleted=0 or cam.IsDeleted=null)
left outer join SeenClientAnswerChild SAC on cam.id=SAC.SeenClientAnswerMasterId 
) s
pivot(
Max(Answer)
For  Question In (
[Total overtime hours worked],[Number of days lost]
))P
)BB ON AA.ReferenceNo=BB.SeenClientAnswerMasterId

UNION ALL

SELECT AA.EstablishmentName,AA.CapturedDate,AA.ReferenceNo,AA.[Month capturing for:],AA.[Year capturing for:],AA.Divison,AA.[Sub-Divison],AA.[Divison EstablishmentName],AA.[Monthly hours worked:],BB.[Total overtime hours worked] AS [Total overtime hours worked:],AA.[Number of employees],BB.[Number of days lost]
FROM 
(SELECT EstablishmentName,CapturedDate,ReferenceNo,[Month capturing for:],[Year capturing for:],'VRN' AS [Divison],'Port Elizabeth' AS [Sub-Divison],'SHEQ Incident Reporting - VRN Port Elizabeth' as [Divison EstablishmentName],
CONVERT(DECIMAL(18,2),[Monthly hours worked:]) AS [Monthly hours worked:],[Number of employees]
FROM (
SELECT E.EstablishmentName,dateadd(MINUTE,AM.TimeOffSet,AM.CreatedOn) as CapturedDate,AM.id as ReferenceNo,A.Detail as Answer,Q.Questiontitle as Question 
FROM dbo.[Group] G
inner join EstablishmentGroup EG on G.id=EG.groupid and g.id = 450 and eg.id=4615 
inner join Establishment E on  E.EstablishmentGroupId=EG.Id 
inner join SeenClientAnswerMaster AM on AM.EstablishmentId=E.id ANd (AM.IsDeleted=0 or AM.IsDeleted=null)
inner join [SeenClientAnswers] A on A.SeenclientAnswerMasterId=AM.id 
inner join SeenClientQuestions Q on Q.id=A.QuestionId and q.id in (37545,37546,37736,40102)
left outer join dbo.[Appuser] u on u.id=AM.CreatedBy
left outer join SeenClientAnswerChild SAC on AM.id=SAC.SeenClientAnswerMasterId 
)s
PIVOT(
MAX(Answer)
FOR  Question In (
[Month capturing for:],[Year capturing for:],[Monthly hours worked:],[Number of employees]
))p 
)AA
LEFT JOIN 
(
select SeenClientAnswerMasterId,CONVERT(DECIMAL(18,2),[Total overtime hours worked]) AS [Total overtime hours worked],[Number of days lost]
from (
select
E.EstablishmentName,cast(dateadd(MINUTE,cam.TimeOffSet,cam.CreatedOn) as date) as CapturedDate,dateadd(MINUTE,am.TimeOffSet,am.CreatedOn) as ResponseDate,am.id as ReferenceNo,cam.Id as SeenClientAnswerMasterId,am.IsPositive,am.IsResolved,a.Detail as Answer,q.Questiontitle as Question,u.id as UserId, u.name as UserName, am.Longitude ,am.Latitude
FROM dbo.[Group] g
inner join EstablishmentGroup eg on g.id=eg.groupid and g.id = 450 and eg.id=4615 
inner join Establishment e on  e.EstablishmentGroupId=eg.Id 
inner join answermaster am on am.EstablishmentId=e.id and (am.IsDeleted=0 or am.IsDeleted=null)
inner join Answers a on a.AnswerMasterId=am.id 
inner join Questions q on q.id=a.QuestionId and q.id in (28100,30283)
left outer join dbo.[Appuser] u on u.id=am.CreatedBy
left join SeenClientAnswerMaster cam on cam.Id=am.SeenClientAnswerMasterId and (cam.IsDeleted=0 or cam.IsDeleted=null)
left outer join SeenClientAnswerChild SAC on cam.id=SAC.SeenClientAnswerMasterId 
) s
pivot(
Max(Answer)
For  Question In (
[Total overtime hours worked],[Number of days lost]
))P
)BB ON AA.ReferenceNo=BB.SeenClientAnswerMasterId

UNION ALL

SELECT AA.EstablishmentName,AA.CapturedDate,AA.ReferenceNo,AA.[Month capturing for:],AA.[Year capturing for:],AA.Divison,AA.[Sub-Divison],AA.[Divison EstablishmentName],AA.[Monthly hours worked:],BB.[Total overtime hours worked] AS [Total overtime hours worked:],AA.[Number of employees],BB.[Number of days lost]
FROM 
(SELECT EstablishmentName,CapturedDate,ReferenceNo,[Month capturing for:],[Year capturing for:],'VRN' AS [Divison],'Pretoria' AS [Sub-Divison],'SHEQ Incident Reporting - VRN Pretoria' as [Divison EstablishmentName],
CONVERT(DECIMAL(18,2),[Monthly hours worked:]) AS [Monthly hours worked:],[Number of employees]
FROM (
SELECT E.EstablishmentName,dateadd(MINUTE,AM.TimeOffSet,AM.CreatedOn) as CapturedDate,AM.id as ReferenceNo,A.Detail as Answer,Q.Questiontitle as Question 
FROM dbo.[Group] G
inner join EstablishmentGroup EG on G.id=EG.groupid and g.id = 450 and eg.id=4615 
inner join Establishment E on  E.EstablishmentGroupId=EG.Id 
inner join SeenClientAnswerMaster AM on AM.EstablishmentId=E.id ANd (AM.IsDeleted=0 or AM.IsDeleted=null)
inner join [SeenClientAnswers] A on A.SeenclientAnswerMasterId=AM.id 
inner join SeenClientQuestions Q on Q.id=A.QuestionId and q.id in (37545,37546,37739,40078)
left outer join dbo.[Appuser] u on u.id=AM.CreatedBy
left outer join SeenClientAnswerChild SAC on AM.id=SAC.SeenClientAnswerMasterId 
)s
PIVOT(
MAX(Answer)
FOR  Question In (
[Month capturing for:],[Year capturing for:],[Monthly hours worked:],[Number of employees]
))p 
)AA
LEFT JOIN 
(
select SeenClientAnswerMasterId,CONVERT(DECIMAL(18,2),[Total overtime hours worked]) AS [Total overtime hours worked],[Number of days lost]
from (
select
E.EstablishmentName,cast(dateadd(MINUTE,cam.TimeOffSet,cam.CreatedOn) as date) as CapturedDate,dateadd(MINUTE,am.TimeOffSet,am.CreatedOn) as ResponseDate,am.id as ReferenceNo,cam.Id as SeenClientAnswerMasterId,am.IsPositive,am.IsResolved,a.Detail as Answer,q.Questiontitle as Question,u.id as UserId, u.name as UserName, am.Longitude ,am.Latitude
FROM dbo.[Group] g
inner join EstablishmentGroup eg on g.id=eg.groupid and g.id = 450 and eg.id=4615 
inner join Establishment e on  e.EstablishmentGroupId=eg.Id 
inner join answermaster am on am.EstablishmentId=e.id and (am.IsDeleted=0 or am.IsDeleted=null)
inner join Answers a on a.AnswerMasterId=am.id 
inner join Questions q on q.id=a.QuestionId and q.id in (28102,30284)
left outer join dbo.[Appuser] u on u.id=am.CreatedBy
left join SeenClientAnswerMaster cam on cam.Id=am.SeenClientAnswerMasterId and (cam.IsDeleted=0 or cam.IsDeleted=null)
left outer join SeenClientAnswerChild SAC on cam.id=SAC.SeenClientAnswerMasterId 
) s
pivot(
Max(Answer)
For  Question In (
[Total overtime hours worked],[Number of days lost]
))P
)BB ON AA.ReferenceNo=BB.SeenClientAnswerMasterId

UNION ALL

SELECT AA.EstablishmentName,AA.CapturedDate,AA.ReferenceNo,AA.[Month capturing for:],AA.[Year capturing for:],AA.Divison,AA.[Sub-Divison],AA.[Divison EstablishmentName],AA.[Monthly hours worked:],BB.[Total overtime hours worked] AS [Total overtime hours worked:],AA.[Number of employees],BB.[Number of days lost]
FROM 
(SELECT EstablishmentName,CapturedDate,ReferenceNo,[Month capturing for:],[Year capturing for:],'VRN' AS [Divison],'Rustenburg' AS [Sub-Divison],'SHEQ Incident Reporting - VRN Rustenburg' as [Divison EstablishmentName],
CONVERT(DECIMAL(18,2),[Monthly hours worked:]) AS [Monthly hours worked:],[Number of employees]
FROM (
SELECT E.EstablishmentName,dateadd(MINUTE,AM.TimeOffSet,AM.CreatedOn) as CapturedDate,AM.id as ReferenceNo,A.Detail as Answer,Q.Questiontitle as Question 
FROM dbo.[Group] G
inner join EstablishmentGroup EG on G.id=EG.groupid and g.id = 450 and eg.id=4615 
inner join Establishment E on  E.EstablishmentGroupId=EG.Id 
inner join SeenClientAnswerMaster AM on AM.EstablishmentId=E.id ANd (AM.IsDeleted=0 or AM.IsDeleted=null)
inner join [SeenClientAnswers] A on A.SeenclientAnswerMasterId=AM.id 
inner join SeenClientQuestions Q on Q.id=A.QuestionId and q.id in (37545,37546,37742,40103)
left outer join dbo.[Appuser] u on u.id=AM.CreatedBy
left outer join SeenClientAnswerChild SAC on AM.id=SAC.SeenClientAnswerMasterId 
)s
PIVOT(
MAX(Answer)
FOR  Question In (
[Month capturing for:],[Year capturing for:],[Monthly hours worked:],[Number of employees]
))p 
)AA
LEFT JOIN 
(
select SeenClientAnswerMasterId,CONVERT(DECIMAL(18,2),[Total overtime hours worked]) AS [Total overtime hours worked],[Number of days lost]
from (
select
E.EstablishmentName,cast(dateadd(MINUTE,cam.TimeOffSet,cam.CreatedOn) as date) as CapturedDate,dateadd(MINUTE,am.TimeOffSet,am.CreatedOn) as ResponseDate,am.id as ReferenceNo,cam.Id as SeenClientAnswerMasterId,am.IsPositive,am.IsResolved,a.Detail as Answer,q.Questiontitle as Question,u.id as UserId, u.name as UserName, am.Longitude ,am.Latitude
FROM dbo.[Group] g
inner join EstablishmentGroup eg on g.id=eg.groupid and g.id = 450 and eg.id=4615 
inner join Establishment e on  e.EstablishmentGroupId=eg.Id 
inner join answermaster am on am.EstablishmentId=e.id and (am.IsDeleted=0 or am.IsDeleted=null)
inner join Answers a on a.AnswerMasterId=am.id 
inner join Questions q on q.id=a.QuestionId and q.id in (28104,30285)
left outer join dbo.[Appuser] u on u.id=am.CreatedBy
left join SeenClientAnswerMaster cam on cam.Id=am.SeenClientAnswerMasterId and (cam.IsDeleted=0 or cam.IsDeleted=null)
left outer join SeenClientAnswerChild SAC on cam.id=SAC.SeenClientAnswerMasterId 
) s
pivot(
Max(Answer)
For  Question In (
[Total overtime hours worked],[Number of days lost]
))P
)BB ON AA.ReferenceNo=BB.SeenClientAnswerMasterId

UNION ALL

SELECT AA.EstablishmentName,AA.CapturedDate,AA.ReferenceNo,AA.[Month capturing for:],AA.[Year capturing for:],AA.Divison,AA.[Sub-Divison],AA.[Divison EstablishmentName],AA.[Monthly hours worked:],BB.[Total overtime hours worked] AS [Total overtime hours worked:],AA.[Number of employees],BB.[Number of days lost]
FROM 
(SELECT EstablishmentName,CapturedDate,ReferenceNo,[Month capturing for:],[Year capturing for:],'VRN' AS [Divison],'Springbok' AS [Sub-Divison],'SHEQ Incident Reporting - VRN Springbok' as [Divison EstablishmentName],
CONVERT(DECIMAL(18,2),[Monthly hours worked:]) AS [Monthly hours worked:],[Number of employees]
FROM (
SELECT E.EstablishmentName,dateadd(MINUTE,AM.TimeOffSet,AM.CreatedOn) as CapturedDate,AM.id as ReferenceNo,A.Detail as Answer,Q.Questiontitle as Question 
FROM dbo.[Group] G
inner join EstablishmentGroup EG on G.id=EG.groupid and g.id = 450 and eg.id=4615 
inner join Establishment E on  E.EstablishmentGroupId=EG.Id 
inner join SeenClientAnswerMaster AM on AM.EstablishmentId=E.id ANd (AM.IsDeleted=0 or AM.IsDeleted=null)
inner join [SeenClientAnswers] A on A.SeenclientAnswerMasterId=AM.id 
inner join SeenClientQuestions Q on Q.id=A.QuestionId and q.id in (37545,37546,37745,40104)
left outer join dbo.[Appuser] u on u.id=AM.CreatedBy
left outer join SeenClientAnswerChild SAC on AM.id=SAC.SeenClientAnswerMasterId 
)s
PIVOT(
MAX(Answer)
FOR  Question In (
[Month capturing for:],[Year capturing for:],[Monthly hours worked:],[Number of employees]
))p 
)AA
LEFT JOIN 
(
select SeenClientAnswerMasterId,CONVERT(DECIMAL(18,2),[Total overtime hours worked]) AS [Total overtime hours worked],[Number of days lost]
from (
select
E.EstablishmentName,cast(dateadd(MINUTE,cam.TimeOffSet,cam.CreatedOn) as date) as CapturedDate,dateadd(MINUTE,am.TimeOffSet,am.CreatedOn) as ResponseDate,am.id as ReferenceNo,cam.Id as SeenClientAnswerMasterId,am.IsPositive,am.IsResolved,a.Detail as Answer,q.Questiontitle as Question,u.id as UserId, u.name as UserName, am.Longitude ,am.Latitude
FROM dbo.[Group] g
inner join EstablishmentGroup eg on g.id=eg.groupid and g.id = 450 and eg.id=4615 
inner join Establishment e on  e.EstablishmentGroupId=eg.Id 
inner join answermaster am on am.EstablishmentId=e.id and (am.IsDeleted=0 or am.IsDeleted=null)
inner join Answers a on a.AnswerMasterId=am.id 
inner join Questions q on q.id=a.QuestionId and q.id in (28106,30286)
left outer join dbo.[Appuser] u on u.id=am.CreatedBy
left join SeenClientAnswerMaster cam on cam.Id=am.SeenClientAnswerMasterId and (cam.IsDeleted=0 or cam.IsDeleted=null)
left outer join SeenClientAnswerChild SAC on cam.id=SAC.SeenClientAnswerMasterId 
) s
pivot(
Max(Answer)
For  Question In (
[Total overtime hours worked],[Number of days lost]
))P
)BB ON AA.ReferenceNo=BB.SeenClientAnswerMasterId

UNION ALL

SELECT AA.EstablishmentName,AA.CapturedDate,AA.ReferenceNo,AA.[Month capturing for:],AA.[Year capturing for:],AA.Divison,AA.[Sub-Divison],AA.[Divison EstablishmentName],AA.[Monthly hours worked:],BB.[Total overtime hours worked] AS [Total overtime hours worked:],AA.[Number of employees],BB.[Number of days lost]
FROM 
(SELECT EstablishmentName,CapturedDate,ReferenceNo,[Month capturing for:],[Year capturing for:],'VRN' AS [Divison],'Stainless' AS [Sub-Divison],'SHEQ Incident Reporting - VRN Stainless' as [Divison EstablishmentName],
CONVERT(DECIMAL(18,2),[Monthly hours worked:]) AS [Monthly hours worked:],[Number of employees]
FROM (
SELECT E.EstablishmentName,dateadd(MINUTE,AM.TimeOffSet,AM.CreatedOn) as CapturedDate,AM.id as ReferenceNo,A.Detail as Answer,Q.Questiontitle as Question 
FROM dbo.[Group] G
inner join EstablishmentGroup EG on G.id=EG.groupid and g.id = 450 and eg.id=4615 
inner join Establishment E on  E.EstablishmentGroupId=EG.Id 
inner join SeenClientAnswerMaster AM on AM.EstablishmentId=E.id ANd (AM.IsDeleted=0 or AM.IsDeleted=null)
inner join [SeenClientAnswers] A on A.SeenclientAnswerMasterId=AM.id 
inner join SeenClientQuestions Q on Q.id=A.QuestionId and q.id in (37545,37546,37748,40105)
left outer join dbo.[Appuser] u on u.id=AM.CreatedBy
left outer join SeenClientAnswerChild SAC on AM.id=SAC.SeenClientAnswerMasterId 
)s
PIVOT(
MAX(Answer)
FOR  Question In (
[Month capturing for:],[Year capturing for:],[Monthly hours worked:],[Number of employees]
))p 
)AA
LEFT JOIN 
(
select SeenClientAnswerMasterId,CONVERT(DECIMAL(18,2),[Total overtime hours worked]) AS [Total overtime hours worked],[Number of days lost]
from (
select
E.EstablishmentName,cast(dateadd(MINUTE,cam.TimeOffSet,cam.CreatedOn) as date) as CapturedDate,dateadd(MINUTE,am.TimeOffSet,am.CreatedOn) as ResponseDate,am.id as ReferenceNo,cam.Id as SeenClientAnswerMasterId,am.IsPositive,am.IsResolved,a.Detail as Answer,q.Questiontitle as Question,u.id as UserId, u.name as UserName, am.Longitude ,am.Latitude
FROM dbo.[Group] g
inner join EstablishmentGroup eg on g.id=eg.groupid and g.id = 450 and eg.id=4615 
inner join Establishment e on  e.EstablishmentGroupId=eg.Id 
inner join answermaster am on am.EstablishmentId=e.id and (am.IsDeleted=0 or am.IsDeleted=null)
inner join Answers a on a.AnswerMasterId=am.id 
inner join Questions q on q.id=a.QuestionId and q.id in (28108,30287)
left outer join dbo.[Appuser] u on u.id=am.CreatedBy
left join SeenClientAnswerMaster cam on cam.Id=am.SeenClientAnswerMasterId and (cam.IsDeleted=0 or cam.IsDeleted=null)
left outer join SeenClientAnswerChild SAC on cam.id=SAC.SeenClientAnswerMasterId 
) s
pivot(
Max(Answer)
For  Question In (
[Total overtime hours worked],[Number of days lost]
))P
)BB ON AA.ReferenceNo=BB.SeenClientAnswerMasterId

UNION ALL

SELECT AA.EstablishmentName,AA.CapturedDate,AA.ReferenceNo,AA.[Month capturing for:],AA.[Year capturing for:],AA.Divison,AA.[Sub-Divison],AA.[Divison EstablishmentName],AA.[Monthly hours worked:],BB.[Total overtime hours worked] AS [Total overtime hours worked:],AA.[Number of employees],BB.[Number of days lost]
FROM 
(SELECT EstablishmentName,CapturedDate,ReferenceNo,[Month capturing for:],[Year capturing for:],'VRN' AS [Divison],'Witbank' AS [Sub-Divison],'SHEQ Incident Reporting - VRN Witbank' as [Divison EstablishmentName],
CONVERT(DECIMAL(18,2),[Monthly hours worked:]) AS [Monthly hours worked:],[Number of employees]
FROM (
SELECT E.EstablishmentName,dateadd(MINUTE,AM.TimeOffSet,AM.CreatedOn) as CapturedDate,AM.id as ReferenceNo,A.Detail as Answer,Q.Questiontitle as Question 
FROM dbo.[Group] G
inner join EstablishmentGroup EG on G.id=EG.groupid and g.id = 450 and eg.id=4615 
inner join Establishment E on  E.EstablishmentGroupId=EG.Id 
inner join SeenClientAnswerMaster AM on AM.EstablishmentId=E.id ANd (AM.IsDeleted=0 or AM.IsDeleted=null)
inner join [SeenClientAnswers] A on A.SeenclientAnswerMasterId=AM.id 
inner join SeenClientQuestions Q on Q.id=A.QuestionId and q.id in (37545,37546,37751,40106)
left outer join dbo.[Appuser] u on u.id=AM.CreatedBy
left outer join SeenClientAnswerChild SAC on AM.id=SAC.SeenClientAnswerMasterId 
)s
PIVOT(
MAX(Answer)
FOR  Question In (
[Month capturing for:],[Year capturing for:],[Monthly hours worked:],[Number of employees]
))p 
)AA
LEFT JOIN 
(
select SeenClientAnswerMasterId,CONVERT(DECIMAL(18,2),[Total overtime hours worked]) AS [Total overtime hours worked],[Number of days lost]
from (
select
E.EstablishmentName,cast(dateadd(MINUTE,cam.TimeOffSet,cam.CreatedOn) as date) as CapturedDate,dateadd(MINUTE,am.TimeOffSet,am.CreatedOn) as ResponseDate,am.id as ReferenceNo,cam.Id as SeenClientAnswerMasterId,am.IsPositive,am.IsResolved,a.Detail as Answer,q.Questiontitle as Question,u.id as UserId, u.name as UserName, am.Longitude ,am.Latitude
FROM dbo.[Group] g
inner join EstablishmentGroup eg on g.id=eg.groupid and g.id = 450 and eg.id=4615 
inner join Establishment e on  e.EstablishmentGroupId=eg.Id 
inner join answermaster am on am.EstablishmentId=e.id and (am.IsDeleted=0 or am.IsDeleted=null)
inner join Answers a on a.AnswerMasterId=am.id 
inner join Questions q on q.id=a.QuestionId and q.id in (28110,30201)
left outer join dbo.[Appuser] u on u.id=am.CreatedBy
left join SeenClientAnswerMaster cam on cam.Id=am.SeenClientAnswerMasterId and (cam.IsDeleted=0 or cam.IsDeleted=null)
left outer join SeenClientAnswerChild SAC on cam.id=SAC.SeenClientAnswerMasterId 
) s
pivot(
Max(Answer)
For  Question In (
[Total overtime hours worked],[Number of days lost]
))P
)BB ON AA.ReferenceNo=BB.SeenClientAnswerMasterId
)X WHERE x.[Month capturing for:]<>''
)AB

LEFT JOIN 
(
SELECT 
	   REPLACE(Z.EstablishmentName,'(Closed)','') AS inc_EstablishmentName,
       Z.CapturedDate AS inc_CapturedDate,
       Z.ReferenceNo AS inc_ReferenceNo,
       Z.Status,
       Z.UserName,
       --Z.CustomerName,
       --Z.CustomerMobile,
       --Z.CustomerEmail,
	   z.[Name & surname],
	   z.[ID Number],
	   z.[Employee number],
	   z.Occupation,
	   z.[Description of incident],
       Z.[Body part affected / environmental impact / impact of disease:],
	   x.Data AS [Body part affected],
       Z.[Incident category],
       Z.[Safety health & property],
       Z.Quality,
       Z.[Person criteria],
       Z.Department,
       Z.[Environment & inspections / audits],
       Z.[Level of incident],
       Z.[Expected period of disablement],
       cast(Z.[Date & time of incident] AS date) AS [Date & time of incident],
	   convert(varchar, Z.[Date & time of incident], 108) AS [time of incident],
       Z.[Classification of incident],
	   b.[Cost (ZAR)] AS 'Total Incident Costing (ZAR)',
	   z.[Age Category],
	   z.[Shift],
	   z.[Years of Service],
	   z.[Period in present job]
FROM
(
SELECT 
K.EstablishmentName,
K.CapturedDate,
K.ReferenceNo,
K.Status,
K.UserName,
--K.CustomerName,
--K.CustomerMobile,
--K.CustomerEmail,
J.[Name & surname],
J.[ID Number],
J.[Employee number],
K.[Description of incident],
j.[Body part affected / environmental impact / impact of disease:],
K.[Incident category],
K.[Safety health & property],
K.Quality,
J.[Person criteria],
J.Department,
J.Occupation,
K.[Environment & inspections / audits],
K.[Level of incident],
K.[Expected period of disablement],
CASE WHEN K.[Date & time of incident] IS NULL THEN CONCAT(k.[Date of incident],' ',k.[Time of incident]) ELSE K.[Date & time of incident] END AS [Date & time of incident], 
--K.[Date of incident],
--K.[Time of incident],
K.[Classification of incident],
j.[Age Category],
K.Shift,
j.[Years of Service],
j.[Period in present job] 
 FROM 
(SELECT EstablishmentName,CapturedDate,ReferenceNo,Status,UserName,--CustomerName,CustomerMobile,CustomerEmail,
RepeatCount,
[Name & surname],[ID Number],[Employee number],[Description of incident],[Body part affected / environmental impact / impact of disease:],[Incident category],[Safety health & property],[Quality],[Person criteria],[Department],[Occupation],[Environment & inspections / audits],[Level of incident],[Expected period of disablement],CAST([Date & time of incident] AS DATETIME) AS [Date & time of incident],[Date of incident],[Time of incident],[Classification of incident],[Age Category],[Shift],[Years of Service],[Period in present job]
FROM
(
SELECT
E.EstablishmentName,dateadd(MINUTE,AM.TimeOffSet,AM.CreatedOn) as CapturedDate,AM.id as ReferenceNo,
AM.IsPositive,AM.IsResolved as Status,
CONVERT(NVARCHAR(MAX),A.Detail) as Answer
,Q.Questiontitle as Question,U.id as UserId, u.name as UserName,A.RepeatCount,
AM.Longitude ,AM.Latitude
--(SELECT TOP 1 cd.Detail FROM ContactDetails CD WHERE   CD.ContactMasterId=(case when AM.IsSubmittedForGroup=1 then SAC.ContactMasterId  else AM.ContactMasterId end) and CD.IsDeleted = 0 and CD.Detail<>'' 
--and CD.contactQuestionId=2783
--) as CustomerEmail,
--(SELECT TOP 1 cd.Detail FROM ContactDetails CD WHERE   CD.ContactMasterId=(case when AM.IsSubmittedForGroup=1 then SAC.ContactMasterId  else AM.ContactMasterId end) and CD.IsDeleted = 0 and CD.Detail<>'' 
--and CD.contactQuestionId=2782
--) as CustomerMobile,
--(SELECT TOP 1 cd.Detail FROM ContactDetails CD WHERE   CD.ContactMasterId=(case when AM.IsSubmittedForGroup=1 then SAC.ContactMasterId  else AM.ContactMasterId end) and CD.IsDeleted = 0 and CD.Detail<>'' 
--and CD.contactQuestionId=2780
--)+' '+
--(SELECT TOP 1 cd.Detail FROM ContactDetails CD WHERE   CD.ContactMasterId=(case when AM.IsSubmittedForGroup=1 then SAC.ContactMasterId  else AM.ContactMasterId end) and CD.IsDeleted = 0 and CD.Detail<>'' 
--and CD.contactQuestionId=2781
--) as CustomerName
from dbo.[Group] G
inner join EstablishmentGroup EG on G.id=EG.groupid and g.id = 450 and eg.id=3671 
inner join Establishment E on  E.EstablishmentGroupId=EG.Id 
inner join SeenClientAnswerMaster AM on AM.EstablishmentId=E.id ANd (AM.IsDeleted=0 or AM.IsDeleted=null)
inner join [SeenClientAnswers] A on A.SeenclientAnswerMasterId=AM.id 
inner join SeenClientQuestions Q on Q.id=A.QuestionId and q.id in (34936,76166,33972,33973,33189,33190,33810,33192,34625,43991,43992,33195,28400,28401,33197,28404,33196,28429,28411,40120,40500,28407,28408,81760)
left outer join dbo.[Appuser] u on u.id=AM.CreatedBy
left outer join SeenClientAnswerChild SAC on AM.id=SAC.SeenClientAnswerMasterId 
WHERE A.RepeatCount <> 0 
)s 
pivot(
Max(Answer)
For  Question In (
[Name & surname],[ID Number],[Employee number],[Description of incident],[Body part affected / environmental impact / impact of disease:],[Incident category],[Safety health & property],[Quality],[Person criteria],[Department],[Occupation],[Environment & inspections / audits],[Level of incident],[Expected period of disablement],[Date & time of incident],[Date of incident],[Time of incident],[Classification of incident],[Age Category],[Shift],[Years of Service],[Period in present job]
))p ) J 

INNER JOIN 

(SELECT EstablishmentName,CapturedDate,ReferenceNo,Status,UserName,--CustomerName,CustomerMobile,CustomerEmail,
RepeatCount,
[Name & surname],[ID Number],[Employee number],[Description of incident],[Body part affected / environmental impact / impact of disease:],[Incident category],[Safety health & property],[Quality],[Person criteria],[Department],[Occupation],[Environment & inspections / audits],[Level of incident],[Expected period of disablement],CAST([Date & time of incident] AS DATETIME) AS [Date & time of incident],[Date of incident],[Time of incident],[Classification of incident],[Age Category],[Shift],[Years of Service],[Period in present job]
FROM
(
SELECT
E.EstablishmentName,dateadd(MINUTE,AM.TimeOffSet,AM.CreatedOn) as CapturedDate,AM.id as ReferenceNo,
AM.IsPositive,AM.IsResolved as Status,
CONVERT(NVARCHAR(MAX),A.Detail) as Answer
,Q.Questiontitle as Question,U.id as UserId, u.name as UserName,A.RepeatCount,
AM.Longitude ,AM.Latitude
--(SELECT TOP 1 cd.Detail FROM ContactDetails CD WHERE   CD.ContactMasterId=(case when AM.IsSubmittedForGroup=1 then SAC.ContactMasterId  else AM.ContactMasterId end) and CD.IsDeleted = 0 and CD.Detail<>'' 
--and CD.contactQuestionId=2783
--) as CustomerEmail,
--(SELECT TOP 1 cd.Detail FROM ContactDetails CD WHERE   CD.ContactMasterId=(case when AM.IsSubmittedForGroup=1 then SAC.ContactMasterId  else AM.ContactMasterId end) and CD.IsDeleted = 0 and CD.Detail<>'' 
--and CD.contactQuestionId=2782
--) as CustomerMobile,
--(SELECT TOP 1 cd.Detail FROM ContactDetails CD WHERE   CD.ContactMasterId=(case when AM.IsSubmittedForGroup=1 then SAC.ContactMasterId  else AM.ContactMasterId end) and CD.IsDeleted = 0 and CD.Detail<>'' 
--and CD.contactQuestionId=2780
--)+' '+
--(SELECT TOP 1 cd.Detail FROM ContactDetails CD WHERE   CD.ContactMasterId=(case when AM.IsSubmittedForGroup=1 then SAC.ContactMasterId  else AM.ContactMasterId end) and CD.IsDeleted = 0 and CD.Detail<>'' 
--and CD.contactQuestionId=2781
--) as CustomerName
from dbo.[Group] G
inner join EstablishmentGroup EG on G.id=EG.groupid and g.id = 450 and eg.id=3671 
inner join Establishment E on  E.EstablishmentGroupId=EG.Id 
inner join SeenClientAnswerMaster AM on AM.EstablishmentId=E.id ANd (AM.IsDeleted=0 or AM.IsDeleted=null)
inner join [SeenClientAnswers] A on A.SeenclientAnswerMasterId=AM.id 
inner join SeenClientQuestions Q on Q.id=A.QuestionId and q.id in (34936,76166,33972,33973,33189,33190,33810,33192,34625,43991,43992,33195,28400,28401,33197,28404,33196,28429,28411,40120,40500,28407,28408,81760)
left outer join dbo.[Appuser] u on u.id=AM.CreatedBy
left outer join SeenClientAnswerChild SAC on AM.id=SAC.SeenClientAnswerMasterId 
WHERE A.RepeatCount = 0 
)s
pivot(
Max(Answer)
For  Question In (
[Name & surname],[ID Number],[Employee number],[Description of incident],[Body part affected / environmental impact / impact of disease:],[Incident category],[Safety health & property],[Quality],[Person criteria],[Department],[Occupation],[Environment & inspections / audits],[Level of incident],[Expected period of disablement],[Date & time of incident],[Date of incident],[Time of incident],[Classification of incident],[Age Category],[Shift],[Years of Service],[Period in present job]
))p ) K ON j.ReferenceNo = k.ReferenceNo 
)Z
LEFT JOIN
(
SELECT w.ReferenceNo,w.[SHEQ incident reporting activity reference number] AS 'SHEQ ref no',SUM(CONVERT(DECIMAL(18,2),w.[Cost (ZAR)])) AS [Cost (ZAR)] FROM 
(SELECT K.ReferenceNo,J.RepeatCount,K.[SHEQ incident reporting activity reference number],J.[Cost (ZAR)],J.Id FROM 
(SELECT ReferenceNo,p.RepeatCount,[SHEQ incident reporting activity reference number],[Cost (ZAR)],p.Id FROM	
(SELECT AM.id as ReferenceNo,Q.Questiontitle as Question,A.Detail AS answer,A.RepeatCount,q.Id
from dbo.[Group] G
inner join EstablishmentGroup EG on G.id=EG.groupid and g.id = 450 and eg.id=4405 
inner join Establishment E on  E.EstablishmentGroupId=EG.Id 
inner join SeenClientAnswerMaster AM on AM.EstablishmentId=E.id AND AM.IsDeleted=0
inner join [SeenClientAnswers] A on A.SeenclientAnswerMasterId=AM.id AND A.IsDeleted=0
inner join SeenClientQuestions Q on Q.id=A.QuestionId and q.id in (34386,34456,34459,34462)
WHERE A.RepeatCount <> 0 
)s
pivot(
Max(answer)
For  Question In (
[SHEQ incident reporting activity reference number],[Cost (ZAR)]
))p
)J
INNER JOIN 
(SELECT ReferenceNo,p.RepeatCount,[SHEQ incident reporting activity reference number],[Cost (ZAR)],p.Id FROM	
(SELECT AM.id as ReferenceNo,Q.Questiontitle as Question,A.Detail AS answer,A.RepeatCount,q.Id
from dbo.[Group] G
inner join EstablishmentGroup EG on G.id=EG.groupid and g.id = 450 and eg.id=4405 
inner join Establishment E on  E.EstablishmentGroupId=EG.Id 
inner join SeenClientAnswerMaster AM on AM.EstablishmentId=E.id AND AM.IsDeleted=0
inner join [SeenClientAnswers] A on A.SeenclientAnswerMasterId=AM.id AND A.IsDeleted=0
inner join SeenClientQuestions Q on Q.id=A.QuestionId and q.id in (34386,34456,34459,34462)
WHERE A.RepeatCount = 0 
)s
pivot(
Max(answer)
For  Question In (
[SHEQ incident reporting activity reference number],[Cost (ZAR)]
))p
)K ON K.ReferenceNo = J.ReferenceNo
)w GROUP BY w.ReferenceNo,w.[SHEQ incident reporting activity reference number]
)b ON Z.ReferenceNo=b.[SHEQ ref no]
cross apply (select Data from dbo.Split(Z.[Body part affected / environmental impact / impact of disease:],',') ) x
)BA
ON AB.[Divison EstablishmentName] = BA.inc_EstablishmentName AND MONTH(CAST(CAST(05 AS VARCHAR(6))+'-'+AB.month AS DATE)) = MONTH(BA.[Date & time of incident])
AND YEAR(CAST(CAST(05 AS VARCHAR(6))+'-'+AB.month AS DATE)) = YEAR(BA.[Date & time of incident])
)Final;

