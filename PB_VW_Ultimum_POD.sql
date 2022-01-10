CREATE VIEW	dbo.PB_VW_Ultimum_POD AS

SELECT DISTINCT AA.CapturedDate,
       AA.ReferenceNo,
       AA.UserName,
	   AA.RepeatCount,
	   AA.StatusName,
	   IIF(AA.[POD Received Date] IS NULL,CAST(AA.CapturedDate AS DATE),AA.[POD Received Date]) AS [POD Received Date],
       AA.[Client Name],
       AA.Transporter,
       AA.[Type of job],
       AA.[Order Number],
       --AA.[App Reference Number],
	   IIF(AA.[App Reference Number]=0 OR	AA.[App Reference Number] IS NULL,BB.AppRefNo,AA.[App Reference Number]) AS [App Reference Number],
       AA.[Net weight (Tons)],
       AA.[Rate type],
       AA.[Number of trips/units (if per load/container)],
       AA.[Please attach copy of the POD],
       AA.[Please Attach Recon],
	   AA.[Transporter Invoice Number],
	   AA.[Attach Transporter Invoice],
       --BB.SeenClientAnswerMasterId
       BB.ResponseNo,
       BB.AppRefNo,
	   BB.[Invoice Number],
	   BB.[Attach Invoice]
	   FROM 
(

SELECT DISTINCT K.CapturedDate,
       K.ReferenceNo,
       K.UserName,
       J.RepeatCount,
	   K.StatusName,
       K.[POD Received Date],
       K.[Client Name],
       K.Transporter,
       K.[Type of job],
       K.[Order Number],
       J.[App Reference Number],
       K.[Net weight (Tons)],
       K.[Rate type],
       K.[Number of trips/units (if per load/container)],
       K.[Please attach copy of the POD],
       K.[Please Attach Recon],
	   K.[Transporter Invoice Number],
	   K.[Attach Transporter Invoice]
FROM 
(SELECT DISTINCT CapturedDate,ReferenceNo,UserName,P.RepeatCount,StatusName,
[POD Received Date],[Client Name],[Transporter],[Type of job],[Order Number],[App Reference Number],[Net weight (Tons)],[Rate type],[Number of trips/units (if per load/container)],
IIF([Please attach copy of the POD]='','N/A',CONCAT('https://webapi.magnitudefb.com/MGUploadData/SeenClient/',P.[Please attach copy of the POD])) AS [Please attach copy of the POD],
IIF([Please Attach Recon]='' OR P.[Please Attach Recon] IS NULL,'N/A',CONCAT('https://webapi.magnitudefb.com/MGUploadData/SeenClient/',P.[Please Attach Recon])) AS [Please Attach Recon],
[Transporter Invoice Number],
IIF([Attach Transporter Invoice]='' OR P.[Attach Transporter Invoice] IS NULL,'N/A',CONCAT('https://webapi.magnitudefb.com/MGUploadData/SeenClient/',P.[Attach Transporter Invoice])) AS [Attach Transporter Invoice]
From(
select
E.EstablishmentName,dateadd(MINUTE,AM.TimeOffSet,AM.CreatedOn) as CapturedDate,AM.id as ReferenceNo,a.RepeatCount,
AM.IsPositive,AM.IsResolved as Status,A.Detail as Answer,Q.Questiontitle as Question ,U.Name as UserName,es.StatusName,
(SELECT TOP 1 cd.Detail FROM ContactDetails CD WHERE   CD.ContactMasterId=(case when AM.IsSubmittedForGroup=1 then SAC.ContactMasterId  else AM.ContactMasterId end) and CD.IsDeleted = 0 and CD.Detail<>'' 
and CD.contactQuestionId=3252
) as CustomerEmail,
(SELECT TOP 1 cd.Detail FROM ContactDetails CD WHERE   CD.ContactMasterId=(case when AM.IsSubmittedForGroup=1 then SAC.ContactMasterId  else AM.ContactMasterId end) and CD.IsDeleted = 0 and CD.Detail<>'' 
and CD.contactQuestionId=3251
) as CustomerMobile,
(SELECT TOP 1 cd.Detail FROM ContactDetails CD WHERE   CD.ContactMasterId=(case when AM.IsSubmittedForGroup=1 then SAC.ContactMasterId  else AM.ContactMasterId end) and CD.IsDeleted = 0 and CD.Detail<>'' 
and CD.contactQuestionId=3249
)+' '+
(SELECT TOP 1 cd.Detail FROM ContactDetails CD WHERE   CD.ContactMasterId=(case when AM.IsSubmittedForGroup=1 then SAC.ContactMasterId  else AM.ContactMasterId end) and CD.IsDeleted = 0 and CD.Detail<>'' 
and CD.contactQuestionId=3250
) as CustomerName
from dbo.[Group] G
inner join EstablishmentGroup EG on G.id=EG.groupid and g.id = 537 and eg.id=5861 
inner join Establishment E on  E.EstablishmentGroupId=EG.Id 
inner join SeenClientAnswerMaster AM on AM.EstablishmentId=E.id ANd (AM.IsDeleted=0 or AM.IsDeleted=null)
inner join [SeenClientAnswers] A on A.SeenclientAnswerMasterId=AM.id 
inner join SeenClientQuestions Q on Q.id=A.QuestionId and q.id in (50049,50038,50040,51406,52545,50041,58369,70643,70724,70644,73011,73012,73009,73010)
LEFT JOIN dbo.StatusHistory sh ON AM.StatusHistoryId=sh.Id
LEFT JOIN dbo.EstablishmentStatus es ON sh.EstablishmentStatusId=es.Id
LEFT outer join dbo.[Appuser] u on u.Id=AM.CreatedBy
left outer join SeenClientAnswerChild SAC on AM.id=SAC.SeenClientAnswerMasterId WHERE a.RepeatCount=0
)S
pivot(
Max(Answer)
For  Question In (
[POD Received Date],[Client Name],[Transporter],[Type of job],[Order Number],[App Reference Number],[Net weight (Tons)],[Rate type],[Number of trips/units (if per load/container)],[Please attach copy of the POD],[Please Attach Recon],[Transporter Invoice Number],[Attach Transporter Invoice]
))P --WHERE P.[Order Number] IS NOT NULL AND P.CapturedDate>='2020-09-23 00:00:00.000' --AND P.UserName<>'Ultimum Admin'
)K

FULL JOIN 

(SELECT DISTINCT CapturedDate,ReferenceNo,UserName,P.RepeatCount,StatusName,
[POD Received Date],[Client Name],[Transporter],[Type of job],[Order Number],[App Reference Number],[Net weight (Tons)],[Rate type],[Number of trips/units (if per load/container)],
IIF([Please attach copy of the POD]='','N/A',CONCAT('https://webapi.magnitudefb.com/MGUploadData/SeenClient/',P.[Please attach copy of the POD])) AS [Please attach copy of the POD],
IIF([Please Attach Recon]='' OR P.[Please Attach Recon] IS NULL,'N/A',CONCAT('https://webapi.magnitudefb.com/MGUploadData/SeenClient/',P.[Please Attach Recon])) AS [Please Attach Recon],
[Transporter Invoice Number],
IIF([Attach Transporter Invoice]='' OR P.[Attach Transporter Invoice] IS NULL,'N/A',CONCAT('https://webapi.magnitudefb.com/MGUploadData/SeenClient/',P.[Attach Transporter Invoice])) AS [Attach Transporter Invoice]
From(
select
E.EstablishmentName,dateadd(MINUTE,AM.TimeOffSet,AM.CreatedOn) as CapturedDate,AM.id as ReferenceNo,a.RepeatCount,
AM.IsPositive,AM.IsResolved as Status,A.Detail as Answer,Q.Questiontitle as Question ,U.Name as UserName,es.StatusName,
(SELECT TOP 1 cd.Detail FROM ContactDetails CD WHERE   CD.ContactMasterId=(case when AM.IsSubmittedForGroup=1 then SAC.ContactMasterId  else AM.ContactMasterId end) and CD.IsDeleted = 0 and CD.Detail<>'' 
and CD.contactQuestionId=3252
) as CustomerEmail,
(SELECT TOP 1 cd.Detail FROM ContactDetails CD WHERE   CD.ContactMasterId=(case when AM.IsSubmittedForGroup=1 then SAC.ContactMasterId  else AM.ContactMasterId end) and CD.IsDeleted = 0 and CD.Detail<>'' 
and CD.contactQuestionId=3251
) as CustomerMobile,
(SELECT TOP 1 cd.Detail FROM ContactDetails CD WHERE   CD.ContactMasterId=(case when AM.IsSubmittedForGroup=1 then SAC.ContactMasterId  else AM.ContactMasterId end) and CD.IsDeleted = 0 and CD.Detail<>'' 
and CD.contactQuestionId=3249
)+' '+
(SELECT TOP 1 cd.Detail FROM ContactDetails CD WHERE   CD.ContactMasterId=(case when AM.IsSubmittedForGroup=1 then SAC.ContactMasterId  else AM.ContactMasterId end) and CD.IsDeleted = 0 and CD.Detail<>'' 
and CD.contactQuestionId=3250
) as CustomerName
from dbo.[Group] G
inner join EstablishmentGroup EG on G.id=EG.groupid and g.id = 537 and eg.id=5861 
inner join Establishment E on  E.EstablishmentGroupId=EG.Id 
inner join SeenClientAnswerMaster AM on AM.EstablishmentId=E.id ANd (AM.IsDeleted=0 or AM.IsDeleted=null)
inner join [SeenClientAnswers] A on A.SeenclientAnswerMasterId=AM.id 
inner join SeenClientQuestions Q on Q.id=A.QuestionId and q.id in (50049,50038,50040,51406,52545,50041,58369,70643,70724,70644,73011,73012,73009,73010)
LEFT JOIN dbo.StatusHistory sh ON AM.StatusHistoryId=sh.Id
LEFT JOIN dbo.EstablishmentStatus es ON sh.EstablishmentStatusId=es.Id
LEFT outer join dbo.[Appuser] u on u.Id=AM.CreatedBy
left outer join SeenClientAnswerChild SAC on AM.id=SAC.SeenClientAnswerMasterId WHERE a.RepeatCount<>0
)S
pivot(
Max(Answer)
For  Question In (
[POD Received Date],[Client Name],[Transporter],[Type of job],[Order Number],[App Reference Number],[Net weight (Tons)],[Rate type],[Number of trips/units (if per load/container)],[Please attach copy of the POD],[Please Attach Recon],[Transporter Invoice Number],[Attach Transporter Invoice]
))P --WHERE P.[Order Number] IS NOT NULL AND P.CapturedDate>='2020-09-23 00:00:00.000' --AND P.UserName<>'Ultimum Admin'
)J ON J.ReferenceNo=K.ReferenceNo
WHERE K.CapturedDate>='2020-09-23 00:00:00.000'

UNION ALL

SELECT CapturedDate,ReferenceNo,UserName,P.RepeatCount,StatusName,
[POD Received Date],[Client Name],[Transporter],[Type of job],[Order Number],[App Reference Number],[Net weight (Tons)],[Rate type],[Number of trips/units (if per load/container)],
IIF([Please attach copy of the POD]='','N/A',CONCAT('https://webapi.magnitudefb.com/MGUploadData/SeenClient/',P.[Please attach copy of the POD])) AS [Please attach copy of the POD],
IIF([Please Attach Recon]='' OR P.[Please Attach Recon] IS NULL,'N/A',CONCAT('https://webapi.magnitudefb.com/MGUploadData/SeenClient/',P.[Please Attach Recon])) AS [Please Attach Recon],
[Transporter Invoice Number],
IIF([Attach Transporter Invoice]='' OR P.[Attach Transporter Invoice] IS NULL,'N/A',CONCAT('https://webapi.magnitudefb.com/MGUploadData/SeenClient/',P.[Attach Transporter Invoice])) AS [Attach Transporter Invoice]
From(
select
E.EstablishmentName,dateadd(MINUTE,AM.TimeOffSet,AM.CreatedOn) as CapturedDate,AM.id as ReferenceNo,a.RepeatCount,
AM.IsPositive,AM.IsResolved as Status,A.Detail as Answer,Q.Questiontitle as Question ,U.Name as UserName,es.StatusName,
(SELECT TOP 1 cd.Detail FROM ContactDetails CD WHERE   CD.ContactMasterId=(case when AM.IsSubmittedForGroup=1 then SAC.ContactMasterId  else AM.ContactMasterId end) and CD.IsDeleted = 0 and CD.Detail<>'' 
and CD.contactQuestionId=3252
) as CustomerEmail,
(SELECT TOP 1 cd.Detail FROM ContactDetails CD WHERE   CD.ContactMasterId=(case when AM.IsSubmittedForGroup=1 then SAC.ContactMasterId  else AM.ContactMasterId end) and CD.IsDeleted = 0 and CD.Detail<>'' 
and CD.contactQuestionId=3251
) as CustomerMobile,
(SELECT TOP 1 cd.Detail FROM ContactDetails CD WHERE   CD.ContactMasterId=(case when AM.IsSubmittedForGroup=1 then SAC.ContactMasterId  else AM.ContactMasterId end) and CD.IsDeleted = 0 and CD.Detail<>'' 
and CD.contactQuestionId=3249
)+' '+
(SELECT TOP 1 cd.Detail FROM ContactDetails CD WHERE   CD.ContactMasterId=(case when AM.IsSubmittedForGroup=1 then SAC.ContactMasterId  else AM.ContactMasterId end) and CD.IsDeleted = 0 and CD.Detail<>'' 
and CD.contactQuestionId=3250
) as CustomerName
from dbo.[Group] G
inner join EstablishmentGroup EG on G.id=EG.groupid and g.id = 537 and eg.id=5861 
inner join Establishment E on  E.EstablishmentGroupId=EG.Id 
inner join SeenClientAnswerMaster AM on AM.EstablishmentId=E.id ANd (AM.IsDeleted=0 or AM.IsDeleted=null)
inner join [SeenClientAnswers] A on A.SeenclientAnswerMasterId=AM.id 
inner join SeenClientQuestions Q on Q.id=A.QuestionId and q.id in (50049,50038,50040,51406,52545,50041,58369,70643,70724,70644,73011,73009,73010)
LEFT JOIN dbo.StatusHistory sh ON AM.StatusHistoryId=sh.Id
LEFT JOIN dbo.EstablishmentStatus es ON sh.EstablishmentStatusId=es.Id
LEFT outer join dbo.[Appuser] u on u.Id=AM.CreatedBy
left outer join SeenClientAnswerChild SAC on AM.id=SAC.SeenClientAnswerMasterId
)S
pivot(
Max(Answer)
For  Question In (
[POD Received Date],[Client Name],[Transporter],[Type of job],[Order Number],[App Reference Number],[Net weight (Tons)],[Rate type],[Number of trips/units (if per load/container)],[Please attach copy of the POD],[Please Attach Recon],[Transporter Invoice Number],[Attach Transporter Invoice]
))P WHERE P.[Order Number] IS NOT NULL AND P.CapturedDate<'2020-09-23 00:00:00.000' --AND P.UserName<>'Ultimum Admin'
)AA

LEFT JOIN

(SELECT a.SeenClientAnswerMasterId,
       a.ResponseNo,
	   a.[App Reference Number] AS [AppRefNo],
       a.[Invoice Number],
       IIF(aa.Data IS NULL OR aa.Data='','N/A',CONCAT('https://webapi.magnitudefb.com/MGUploadData/Feedback/',aa.Data)) AS [Attach Invoice]
	   FROM 
(select SeenClientAnswerMasterId,ResponseNo,[App Reference Number],[Invoice Number],P.[Attach Invoice]
from (
select
dateadd(MINUTE,am.TimeOffSet,am.CreatedOn) as ResponseDate,am.id as ResponseNo,cam.Id as SeenClientAnswerMasterId,
a.Detail as Answer,q.QuestionTitle AS Question
from dbo.[Group] g
inner join EstablishmentGroup eg on g.id=eg.groupid and g.id = 537 and eg.id=5861 
inner join Establishment e on  e.EstablishmentGroupId=eg.Id 
inner join answermaster am on am.EstablishmentId=e.id and (am.IsDeleted=0 or am.IsDeleted=null)
inner join Answers a on a.AnswerMasterId=am.id 
inner join Questions q on q.id=a.QuestionId and q.id in (53533,56555,56695)
left join SeenClientAnswerMaster cam on cam.Id=am.SeenClientAnswerMasterId and (cam.IsDeleted=0 or cam.IsDeleted=null)
) s
pivot(
Max(Answer)
For  Question In (
[App Reference Number],[Invoice Number],[Attach Invoice]
))P
)a CROSS APPLY (select Data from dbo.Split(a.[Attach Invoice],',')) aa
)BB ON	AA.ReferenceNo=BB.SeenClientAnswerMasterId WHERE AA.UserName<>'Ultimum Admin'

