CREATE VIEW PB_VW_Toyota_CustomerComplaints AS

SELECT AA.EstablishmentName,
       AA.CapturedDate,
       AA.[Capture Date],
       AA.ReferenceNo,
       --AA.IsResolved,
       AA.StatusName,
	   AA.StatusDateTime,
	   CONVERT(DECIMAL(18,2),DATEDIFF(MINUTE,AA.CapturedDate,AA.StatusDateTime)/60.00) AS [TimeTaken (Hrs)],
       AA.UserName,
       AA.[Business unit:],
       AA.Department,
       AA.Customer,
       AA.[Contact person],
       AA.Email,
       AA.[Contact No],
       AA.[Dealt with by],
       AA.[Detail of complaints],
       AA.[Proposed action],
       AA.Attachments,
       BB.ResponseDate,
       --BB.SeenClientAnswerMasterId,
       BB.Responseno,
	   BB.Respondent,
       BB.[Are you closing off a Internal complaint or a non conformance?],
       BB.[Description of fix and customer comments],
       BB.[Corrective / Preventative Action],
       BB.Attachment,
       IIF(BB.[IC Signature]='' OR BB.[IC Signature] IS NULL,'N/A',CONCAT('https://webapi.magnitudefb.com/MGUploadData/Feedback/',BB.[IC Signature])) AS [IC Signature],
       BB.[Non Conformances],
       BB.[Why did this happen?],
       BB.[Root caused analysis],
       BB.[Root cause analysis],
       BB.[Investigation Attachment],
       BB.[HOW DO I CORRECT OR CONTAIN THE NON-CONFORMANCE NOW?],
       BB.[What else?],
       BB.[General comment/ Outcome of customer],
       BB.[SHEQ correction done],
       IIF(BB.[SHEQ Signature]='' OR BB.[SHEQ Signature] IS NULL,'N/A',CONCAT('https://webapi.magnitudefb.com/MGUploadData/Feedback/',BB.[SHEQ Signature])) AS [SHEQ Signature],
       BB.Date,
       BB.[SHEQ Attachment],
       BB.[Man is effectively trained],
       BB.[Machine repair was effectively made],
       BB.[Material replacement effectively done],
       BB.[Method updates have been effectively done],
       BB.[OTHER is now effective addressed],
       BB.[The NCR register has been updated],
       BB.[Name of Manger who sets the corrective action],
       IIF(BB.[Admin Signature]='' OR BB.[Admin Signature] IS NULL,'N/A',CONCAT('https://webapi.magnitudefb.com/MGUploadData/Feedback/',BB.[Admin Signature])) AS [Admin Signature],
       BB.[Admin Attachment] 
	   FROM 
(SELECT EstablishmentName,CapturedDate,CAST(CapturedDate AS DATE) AS [Capture Date],ReferenceNo,IsResolved,p.StatusName,p.StatusDateTime,UserName,
[Business unit:],[Department],[Customer],[Contact person],[Email],[Contact No],[Dealt with by],[Detail of complaints],[Proposed action],[Attachments]
from (
select
E.EstablishmentName,cast(dateadd(MINUTE,AM.TimeOffSet,AM.CreatedOn) as DATETIME) as CapturedDate,AM.id as ReferenceNo,
AM.IsResolved ,A.Detail as Answer,Q.QuestionTitle as Question,u.name as UserName,es.StatusName,sh.StatusDateTime
from dbo.[Group] G
inner join EstablishmentGroup EG on G.id=EG.groupid and g.id = 509 and eg.id=5819 
inner join Establishment E on  E.EstablishmentGroupId=EG.Id 
inner join SeenClientAnswerMaster AM on AM.EstablishmentId=E.id ANd (AM.IsDeleted=0 or AM.IsDeleted=null)
LEFT JOIN dbo.StatusHistory sh ON sh.Id=AM.StatusHistoryId
LEFT JOIN dbo.EstablishmentStatus es ON es.Id=sh.EstablishmentStatusId
inner join [SeenClientAnswers] A on A.SeenclientAnswerMasterId=AM.id 
inner join SeenClientQuestions Q on Q.id=A.QuestionId and Q.Id IN (70806,69573,69574,70899,70900,47678,47679,47680,47681,70411)
left outer join dbo.[Appuser] u on u.id=AM.CreatedBy
)s
pivot(
Max(Answer)
For  Question In (
[Business unit:],[Department],[Customer],[Contact person],[Email],[Contact No],[Dealt with by],[Detail of complaints],[Proposed action],[Attachments]
))p
)AA

LEFT JOIN 

(select ResponseDate,SeenClientAnswerMasterId,Responseno,Respondent,
[Are you closing off a Internal complaint or a non conformance?],[Description of fix and customer comments],[Corrective / Preventative Action],[Attachment],[IC Signature],[Non Conformances],[Why did this happen?],[Root caused analysis],[Root cause analysis],[Investigation Attachment],[HOW DO I CORRECT OR CONTAIN THE NON-CONFORMANCE NOW?],[What else?],[General comment/ Outcome of customer],[SHEQ correction done],[SHEQ Signature],[Date],[SHEQ Attachment],[Man is effectively trained],[Machine repair was effectively made],[Material replacement effectively done],[Method updates have been effectively done],[OTHER is now effective addressed],[The NCR register has been updated],[Name of Manger who sets the corrective action],[Admin Signature],[Admin Attachment]
from (
select
dateadd(MINUTE,am.TimeOffSet,am.CreatedOn) as ResponseDate,am.id as Responseno,cam.Id as SeenClientAnswerMasterId,
a.Detail as Answer,u.name as Respondent,
CASE
WHEN q.Id=32414 THEN 'IC Signature'
WHEN q.Id=53060 THEN 'Investigation Attachment'
WHEN q.Id=32435 THEN 'SHEQ Signature'
WHEN q.Id=53061 THEN 'SHEQ Attachment'
WHEN q.Id=32449 THEN 'Admin Signature'
WHEN q.Id=53062 THEN 'Admin Attachment' ELSE q.QuestionTitle END AS	Question
from dbo.[Group] g
inner join EstablishmentGroup eg on g.id=eg.groupid and g.id = 509 and eg.id=5819 
inner join Establishment e on  e.EstablishmentGroupId=eg.Id 
inner join answermaster am on am.EstablishmentId=e.id and (am.IsDeleted=0 or am.IsDeleted=null)
inner join Answers a on a.AnswerMasterId=am.id 
inner join Questions q on q.id=a.QuestionId and q.Id IN(32407,32411,32412,32413,32414,53805,32426,32430,53287,53060,53063,53064,32433,32437,32435,32439,53061,32441,32442,32443,32444,32445,32446,32448,32449,53062)
left outer join dbo.[Appuser] u on u.id=am.CreatedBy
left join SeenClientAnswerMaster cam on cam.Id=am.SeenClientAnswerMasterId and (cam.IsDeleted=0 or cam.IsDeleted=null)
) s
pivot(
Max(Answer)
For  Question In (
[Are you closing off a Internal complaint or a non conformance?],[Description of fix and customer comments],[Corrective / Preventative Action],[Attachment],[IC Signature],[Non Conformances],[Why did this happen?],[Root caused analysis],[Root cause analysis],[Investigation Attachment],[HOW DO I CORRECT OR CONTAIN THE NON-CONFORMANCE NOW?],[What else?],[General comment/ Outcome of customer],[SHEQ correction done],[SHEQ Signature],[Date],[SHEQ Attachment],[Man is effectively trained],[Machine repair was effectively made],[Material replacement effectively done],[Method updates have been effectively done],[OTHER is now effective addressed],[The NCR register has been updated],[Name of Manger who sets the corrective action],[Admin Signature],[Admin Attachment]
))P
)BB ON AA.ReferenceNo=BB.SeenClientAnswerMasterId

