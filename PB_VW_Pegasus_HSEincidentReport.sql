CREATE VIEW PB_VW_Pegasus_HSEincidentReport AS

SELECT --sZ.Row,
       Z.CapturedDate,
       Z.ReferenceNo,   
       Z.Monthh,
       CONVERT(DECIMAL(18,2),CASE WHEN [row] > 1 THEN 0 ELSE Z.[Number of employees] END) AS [Number of employees],
       CONVERT(DECIMAL(18,2),CASE WHEN [row] > 1 THEN 0 ELSE Z.[Monthly hours worked] END) AS [Monthly hours worked],
       CONVERT(DECIMAL(18,2),CASE WHEN [row] > 1 THEN 0 ELSE Z.[Monthly overtime worked] END) AS [Monthly overtime worked],
       CONVERT(DECIMAL(18,2),CASE WHEN [row] > 1 THEN 0 ELSE Z.[Total hours worked] END) AS [Total hours worked],
	   --Z.EstablishmentName,
	   Z.inc_captureddate,
	   Z.inc_Refno,
	   Z.Status,
	   --Z.UserId,
	   Z.UserName,
       --Z.Longitude,
       --Z.Latitude,
       --Z.CustomerName,
       --Z.CustomerMobile,
       --Z.CustomerEmail,
       Z.[Incident type:],
       Z.[Classification / severity level:],
       Z.[Place/ Area/ Unit/ Site Name:],
       CASE WHEN Z.[Exact area in business unit:]='Other' THEN Z.[If other area, please state:] ELSE Z.[Exact area in business unit:] END AS [Exact area in business unit:],
       Z.[If other area, please state:],
       Z.[Name of relevant area 16(2) manager:],
       Z.[Specify work activity/process:],
       Z.[HSEQ officer responsible:],
	   --Z.[Date & time of incident / accident:],
       CAST(Z.[Date & time of incident / accident:] AS DATE) AS [Date of incident / accident:],
	   CAST(Z.[Date & time of incident / accident:] AS TIME(0)) AS [Time of incident / accident:],
       Z.[Equipment involved (if applicable):],
       CASE WHEN Z.[Operation type:]='Other' THEN Z.[If other type, please state:] ELSE Z.[Operation type:] END AS [Operation type:],
       Z.[If other type, please state:],
       Z.[Number of injured parties:],
       Z.[Number of workers involved in the process/accident:],
       Z.[Description of incident (What happened?):],
       Z.[Consequences:],
       Z.[Nature of injuries or hospitalisation:],
       Z.[Where were the supervisors during the incident/accident?],
       Z.[Preliminary cause of incident:],
       Z.[Immediate corrective action:],
       Z.RepeatCount,
       Z.[Full name of injured/effected person(s):],
       Z.[Persons ID number],
       Z.[Employee number:],
       Z.[Age:],
       Z.[Job description:],
       Z.[Years in current position:] FROM 
(
SELECT 
ROW_NUMBER() OVER (PARTITION BY ReferenceNo,[Monthh],[Monthly hours worked],[Monthly overtime worked],[Total hours worked] ORDER BY ReferenceNo,[Monthh],[Monthly hours worked],[Monthly overtime worked],[Total hours worked]) AS [Row],* 
FROM 
(SELECT --q.EstablishmentName,
       q.CapturedDate,
       q.ReferenceNo,
       --q.Status,
       --q.UserId,
       --q.UserName,
       --q.Longitude,
       --q.Latitude,
       --q.CustomerName,
       --q.CustomerMobile,
       --q.CustomerEmail,
       --q.Month,
       --q.Year,
	   CAST(q.Month AS CHAR(3))+'-'+CAST(q.Year AS CHAR(4)) AS 'Monthh',
       q.[Number of employees],
       CONVERT(DECIMAL(18,2),REPLACE(ISNULL(q.[Monthly hours worked],0),'',0)) AS [Monthly hours worked],
       CONVERT(DECIMAL(18,2),REPLACE(ISNULL(q.[Monthly overtime worked],0),'',0)) AS [Monthly overtime worked],
       CONVERT(DECIMAL(18,2),REPLACE(ISNULL(q.[Total hours worked],0),'',0)) AS [Total hours worked] 
	   FROM 
(SELECT EstablishmentName,CapturedDate,ReferenceNo,Status,UserId,UserName,Longitude,Latitude,CustomerName,CustomerMobile,CustomerEmail,
[Month],[Year],[Number of employees],[Monthly hours worked],[Monthly overtime worked],[Total hours worked]
from (
select
E.EstablishmentName,cast(dateadd(MINUTE,AM.TimeOffSet,AM.CreatedOn) as date) as CapturedDate,AM.id as ReferenceNo,
AM.IsResolved as Status,
A.Detail as Answer
,Q.Questiontitle as Question,U.id as UserId, u.name as UserName, 
AM.Longitude ,AM.Latitude,
(SELECT TOP 1 cd.Detail FROM ContactDetails CD WHERE   CD.ContactMasterId=(case when AM.IsSubmittedForGroup=1 then SAC.ContactMasterId  else AM.ContactMasterId end) and CD.IsDeleted = 0 and CD.Detail<>'' 
and CD.contactQuestionId=2913
) as CustomerEmail,
(SELECT TOP 1 cd.Detail FROM ContactDetails CD WHERE   CD.ContactMasterId=(case when AM.IsSubmittedForGroup=1 then SAC.ContactMasterId  else AM.ContactMasterId end) and CD.IsDeleted = 0 and CD.Detail<>'' 
and CD.contactQuestionId=2912
) as CustomerMobile,
(SELECT TOP 1 cd.Detail FROM ContactDetails CD WHERE   CD.ContactMasterId=(case when AM.IsSubmittedForGroup=1 then SAC.ContactMasterId  else AM.ContactMasterId end) and CD.IsDeleted = 0 and CD.Detail<>'' 
and CD.contactQuestionId=2910
)+' '+
(SELECT TOP 1 cd.Detail FROM ContactDetails CD WHERE   CD.ContactMasterId=(case when AM.IsSubmittedForGroup=1 then SAC.ContactMasterId  else AM.ContactMasterId end) and CD.IsDeleted = 0 and CD.Detail<>'' 
and CD.contactQuestionId=2911
) as CustomerName
from dbo.[Group] G
inner join EstablishmentGroup EG on G.id=EG.groupid and g.id = 477 and eg.id=5383 
inner join Establishment E on  E.EstablishmentGroupId=EG.Id 
inner join SeenClientAnswerMaster AM on AM.EstablishmentId=E.id ANd (AM.IsDeleted=0 or AM.IsDeleted=null)
inner join [SeenClientAnswers] A on A.SeenclientAnswerMasterId=AM.id 
inner join SeenClientQuestions Q on Q.id=A.QuestionId and q.id in (43206,43227,43208,43209,43210,43211)
left outer join dbo.[Appuser] u on u.id=AM.CreatedBy
left outer join SeenClientAnswerChild SAC on AM.id=SAC.SeenClientAnswerMasterId 
)s
pivot(
Max(Answer)
For  Question In (
[Month],[Year],[Number of employees],[Monthly hours worked],[Monthly overtime worked],[Total hours worked]
))p)q)AA

LEFT JOIN 

(SELECT 
	   k.EstablishmentName,
       k.CapturedDate AS inc_captureddate,
       k.ReferenceNo AS inc_Refno,
       k.Status,
       k.UserId,
       k.UserName,
       k.Longitude,
       k.Latitude,
       k.CustomerName,
       k.CustomerMobile,
       k.CustomerEmail,
       k.[Incident type:],
       k.[Classification / severity level:],
       k.[Place/ Area/ Unit/ Site Name:],
       k.[Exact area in business unit:],
       k.[If other area, please state:],
       k.[Name of relevant area 16(2) manager:],
       k.[Specify work activity/process:],
       k.[HSEQ officer responsible:],
       k.[Date & time of incident / accident:],
       k.[Equipment involved (if applicable):],
       k.[Operation type:],
       k.[If other type, please state:],
       k.[Number of injured parties:],
       k.[Number of workers involved in the process/accident:],
       k.[Description of incident (What happened?):],
       k.[Consequences:],
       k.[Nature of injuries or hospitalisation:],
       k.[Where were the supervisors during the incident/accident?],
       k.[Preliminary cause of incident:],
       k.[Immediate corrective action:],
       j.RepeatCount,
       j.[Full name of injured/effected person(s):],
       j.[Persons ID number],
       j.[Employee number:],
       j.[Age:],
       j.[Job description:],
       j.[Years in current position:] FROM 
(select EstablishmentName,CapturedDate,ReferenceNo,Status,UserId,UserName,Longitude,Latitude,CustomerName,CustomerMobile,CustomerEmail,
[Incident type:],[Classification / severity level:],[Place/ Area/ Unit/ Site Name:],[Exact area in business unit:],[If other area, please state:],[Name of relevant area 16(2) manager:],[Specify work activity/process:],[HSEQ officer responsible:],[Date & time of incident / accident:],[Equipment involved (if applicable):],[Operation type:],[If other type, please state:],[Number of injured parties:],[Number of workers involved in the process/accident:],[Description of incident (What happened?):],[Consequences:],[Nature of injuries or hospitalisation:],[Where were the supervisors during the incident/accident?],[Preliminary cause of incident:],[Immediate corrective action:],RepeatCount,[Full name of injured/effected person(s):],[Persons ID number],[Employee number:],[Age:],[Job description:],[Years in current position:]
from (
select
E.EstablishmentName,cast(dateadd(MINUTE,AM.TimeOffSet,AM.CreatedOn) as date) as CapturedDate,AM.id as ReferenceNo,
AM.IsResolved as Status,
A.Detail as Answer
,Q.Questiontitle as Question,U.id as UserId, u.name as UserName,a.RepeatCount,
AM.Longitude ,AM.Latitude,
(SELECT TOP 1 cd.Detail FROM ContactDetails CD WHERE   CD.ContactMasterId=(case when AM.IsSubmittedForGroup=1 then SAC.ContactMasterId  else AM.ContactMasterId end) and CD.IsDeleted = 0 and CD.Detail<>'' 
and CD.contactQuestionId=2913
) as CustomerEmail,
(SELECT TOP 1 cd.Detail FROM ContactDetails CD WHERE   CD.ContactMasterId=(case when AM.IsSubmittedForGroup=1 then SAC.ContactMasterId  else AM.ContactMasterId end) and CD.IsDeleted = 0 and CD.Detail<>'' 
and CD.contactQuestionId=2912
) as CustomerMobile,
(SELECT TOP 1 cd.Detail FROM ContactDetails CD WHERE   CD.ContactMasterId=(case when AM.IsSubmittedForGroup=1 then SAC.ContactMasterId  else AM.ContactMasterId end) and CD.IsDeleted = 0 and CD.Detail<>'' 
and CD.contactQuestionId=2910
)+' '+
(SELECT TOP 1 cd.Detail FROM ContactDetails CD WHERE   CD.ContactMasterId=(case when AM.IsSubmittedForGroup=1 then SAC.ContactMasterId  else AM.ContactMasterId end) and CD.IsDeleted = 0 and CD.Detail<>'' 
and CD.contactQuestionId=2911
) as CustomerName
from dbo.[Group] G
inner join EstablishmentGroup EG on G.id=EG.groupid and g.id = 477 and eg.id=4705 
inner join Establishment E on  E.EstablishmentGroupId=EG.Id 
inner join SeenClientAnswerMaster AM on AM.EstablishmentId=E.id ANd (AM.IsDeleted=0 or AM.IsDeleted=null)
inner join [SeenClientAnswers] A on A.SeenclientAnswerMasterId=AM.id 
inner join SeenClientQuestions Q on Q.id=A.QuestionId and q.id in (36715,36716,35556,36717,36718,35557,35559,35560,35561,35562,35563,35564,35565,35690,35691,35693,35694,35695,35696,35697,35699,43005,35700,35701,35702,35703)
left outer join dbo.[Appuser] u on u.id=AM.CreatedBy
left outer join SeenClientAnswerChild SAC on AM.id=SAC.SeenClientAnswerMasterId WHERE a.RepeatCount <> 0
)s
pivot(
Max(Answer)
For  Question In (
[Incident type:],[Classification / severity level:],[Place/ Area/ Unit/ Site Name:],[Exact area in business unit:],[If other area, please state:],[Name of relevant area 16(2) manager:],[Specify work activity/process:],[HSEQ officer responsible:],[Date & time of incident / accident:],[Equipment involved (if applicable):],[Operation type:],[If other type, please state:],[Number of injured parties:],[Number of workers involved in the process/accident:],[Description of incident (What happened?):],[Consequences:],[Nature of injuries or hospitalisation:],[Where were the supervisors during the incident/accident?],[Preliminary cause of incident:],[Immediate corrective action:],[Full name of injured/effected person(s):],[Persons ID number],[Employee number:],[Age:],[Job description:],[Years in current position:]
))p)j

INNER JOIN 

(select EstablishmentName,CapturedDate,ReferenceNo,Status,UserId,UserName,Longitude,Latitude,CustomerName,CustomerMobile,CustomerEmail,
[Incident type:],[Classification / severity level:],[Place/ Area/ Unit/ Site Name:],[Exact area in business unit:],[If other area, please state:],[Name of relevant area 16(2) manager:],[Specify work activity/process:],[HSEQ officer responsible:],[Date & time of incident / accident:],[Equipment involved (if applicable):],[Operation type:],[If other type, please state:],[Number of injured parties:],[Number of workers involved in the process/accident:],[Description of incident (What happened?):],[Consequences:],[Nature of injuries or hospitalisation:],[Where were the supervisors during the incident/accident?],[Preliminary cause of incident:],[Immediate corrective action:],RepeatCount,[Full name of injured/effected person(s):],[Persons ID number],[Employee number:],[Age:],[Job description:],[Years in current position:]
from (
select
E.EstablishmentName,cast(dateadd(MINUTE,AM.TimeOffSet,AM.CreatedOn) as date) as CapturedDate,AM.id as ReferenceNo,
AM.IsResolved as Status,
A.Detail as Answer
,Q.Questiontitle as Question,U.id as UserId, u.name as UserName,a.RepeatCount,
AM.Longitude ,AM.Latitude,
(SELECT TOP 1 cd.Detail FROM ContactDetails CD WHERE   CD.ContactMasterId=(case when AM.IsSubmittedForGroup=1 then SAC.ContactMasterId  else AM.ContactMasterId end) and CD.IsDeleted = 0 and CD.Detail<>'' 
and CD.contactQuestionId=2913
) as CustomerEmail,
(SELECT TOP 1 cd.Detail FROM ContactDetails CD WHERE   CD.ContactMasterId=(case when AM.IsSubmittedForGroup=1 then SAC.ContactMasterId  else AM.ContactMasterId end) and CD.IsDeleted = 0 and CD.Detail<>'' 
and CD.contactQuestionId=2912
) as CustomerMobile,
(SELECT TOP 1 cd.Detail FROM ContactDetails CD WHERE   CD.ContactMasterId=(case when AM.IsSubmittedForGroup=1 then SAC.ContactMasterId  else AM.ContactMasterId end) and CD.IsDeleted = 0 and CD.Detail<>'' 
and CD.contactQuestionId=2910
)+' '+
(SELECT TOP 1 cd.Detail FROM ContactDetails CD WHERE   CD.ContactMasterId=(case when AM.IsSubmittedForGroup=1 then SAC.ContactMasterId  else AM.ContactMasterId end) and CD.IsDeleted = 0 and CD.Detail<>'' 
and CD.contactQuestionId=2911
) as CustomerName
from dbo.[Group] G
inner join EstablishmentGroup EG on G.id=EG.groupid and g.id = 477 and eg.id=4705 
inner join Establishment E on  E.EstablishmentGroupId=EG.Id 
inner join SeenClientAnswerMaster AM on AM.EstablishmentId=E.id ANd (AM.IsDeleted=0 or AM.IsDeleted=null)
inner join [SeenClientAnswers] A on A.SeenclientAnswerMasterId=AM.id 
inner join SeenClientQuestions Q on Q.id=A.QuestionId and q.id in (36715,36716,35556,36717,36718,35557,35559,35560,35561,35562,35563,35564,35565,35690,35691,35693,35694,35695,35696,35697,35699,43005,35700,35701,35702,35703)
left outer join dbo.[Appuser] u on u.id=AM.CreatedBy
left outer join SeenClientAnswerChild SAC on AM.id=SAC.SeenClientAnswerMasterId WHERE a.RepeatCount = 0
)s
pivot(
Max(Answer)
For  Question In (
[Incident type:],[Classification / severity level:],[Place/ Area/ Unit/ Site Name:],[Exact area in business unit:],[If other area, please state:],[Name of relevant area 16(2) manager:],[Specify work activity/process:],[HSEQ officer responsible:],[Date & time of incident / accident:],[Equipment involved (if applicable):],[Operation type:],[If other type, please state:],[Number of injured parties:],[Number of workers involved in the process/accident:],[Description of incident (What happened?):],[Consequences:],[Nature of injuries or hospitalisation:],[Where were the supervisors during the incident/accident?],[Preliminary cause of incident:],[Immediate corrective action:],[Full name of injured/effected person(s):],[Persons ID number],[Employee number:],[Age:],[Job description:],[Years in current position:]
))p)k ON j.ReferenceNo=k.ReferenceNo
)BB ON MONTH(CAST(CAST(05 AS VARCHAR(6))+'-'+AA.Monthh AS DATE)) = MONTH(BB.[Date & time of incident / accident:])
AND YEAR(CAST(CAST(05 AS VARCHAR(6))+'-'+AA.Monthh AS DATE)) = YEAR(BB.[Date & time of incident / accident:])
)Z

UNION ALL

SELECT TRY_CONVERT(DATE,CapturedDate,103) AS CapDate,
CAST(ReferenceNo AS bigint) AS RefNo,
CAST(Monthh AS varchar) AS Monthh,
CAST([Number_of_employees] AS decimal) AS [No. Emp],
CAST([Monthly_hours_worked] AS decimal) AS [MHW],
CAST([Monthly_overtime_worked] AS decimal) AS [MOW],
CAST([Total_hours_worked] AS decimal) AS [THW],
TRY_CONVERT(DATE,[inc_captureddate],103) AS [inc_date],
CAST([inc_Refno] AS	bigint) AS [inc_refno],
'Resolved' as Status,
CAST(UserName AS nvarchar) AS Username,
CAST([Incident_type_] AS nvarchar) as [Incidenttype],
CAST([Classification___severity_level_] AS nvarchar) AS Classification,
CAST([Place__Area__Unit__Site_Name_] AS	nvarchar) as [Place/Area],
CAST([Exact_area_in_business_unit_] AS	nvarchar) as [ExactArea],
CAST([_If_other_area__please_state__] AS nvarchar) as [otherarea],
CAST([Name_of_relevant_area_16_2__manager_] as nvarchar) as [areamanager],
CAST([Specify_work_activity_process_] as nvarchar) as [specifywork],
CAST([HSEQ_officer_responsible_] as nvarchar) as [HSEQofficer],
TRY_CONVERT(DATE,[Date_of_incident___accident_],103) as [Dateofincident],
CAST([Time_of_incident___accident_] as time) as [Timeofincident],
CAST([Equipment_involved__if_applicable__] as nvarchar) as [Equipment],
CAST([Operation_type_] as nvarchar) as [Operation],
CAST([_If_other_type__please_state__] as nvarchar) as [otheroperation],
CAST([Number_of_injured_parties_] as nvarchar) as [injuredparty],
CAST([Number_of_workers_involved_in_the_process_accident_] as nvarchar) as [numberofworker],
CAST([Description_of_incident__What_happened___] as nvarchar) as [Description],
CAST([Consequences_] as nvarchar) as [Consequences],
CAST([Nature_of_injuries_or_hospitalisation_] as nvarchar) as [natureofinuries],
CAST([Where_were_the_supervisors_during_the_incident_accident_] as nvarchar) as [wherewere],
CAST([Preliminary_cause_of_incident_] as nvarchar) as [preliminary],
CAST([Immediate_corrective_action_] as nvarchar) as [action],
CAST([RepeatCount] as int) as [RepeatCount],
CAST([Full_name_of_injured_effected_person_s__] as nvarchar) as [Fullname],
CAST([Persons_ID_number] as nvarchar) as [PersonID],
CAST([Employee_number_] as nvarchar) as [Empnumber],
CAST([Age_] as nvarchar) as [Age],
CAST([Job_description_] as nvarchar) as [Jobdesc],
CAST([Years_in_current_position_] as nvarchar) as [Years] FROM dbo.PegasusHSE_2019_Incidents

