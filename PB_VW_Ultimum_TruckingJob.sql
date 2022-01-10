CREATE VIEW PB_VW_Ultimum_TruckingJob AS

SELECT AA.EstablishmentName,
       CAST(AA.CapturedDate AS DATE) AS CaptureDate,
       AA.ReferenceNo,
       AA.IsPositive,
       AA.Status,
       AA.UserName,
       AA.Longitude,
       AA.Latitude,
       --AA.CustomerEmail,
       --AA.CustomerMobile,
       --AA.CustomerName,
       AA.[Job Reference Number],
       AA.[Load Confirmation Number],
       AA.Date,
       AA.Client,
       AA.[Client reference / order number],
       AA.Transporter,
       AA.Commodity,
       AA.[Rate type],
       AA.[Tonnage, Volume or Loads (New Field)] AS [Tonnage, Volume or Loads],
       AA.[Type of Move],
       AA.[Load Point],
       AA.Loading,
       AA.[Loading Start Time],
       AA.[Loading End Time],
       AA.Offloading,
       AA.[Off Loading Point],
       AA.[Off Loading Start Time],
       AA.[Off Loading End Time],
       AA.[Contact Person],
       AA.[Max Los Tolerance %],
       AA.[Transporter Rate Excluding VAT],
       AA.[GIT Value (ZAR)],
       AA.[Terms of Payment],
       AA.[Cut off date and descriptions],
       AA.[Invoicing Terms],
       AA.[Special Instructions],
       AA.[ULT Rate (ZAR)],
       AA.[Number of Vehicles],
       AA.[Number of Trips],
       AA.[Ave Load],
       AA.[Loading number],
       AA.[Offloading number],
	   BB.ResponseDate,
       BB.ReferenceNo AS Responseno,
       BB.[Signed at],
       BB.[Date signed],
       BB.Designation,
       IIF(BB.[Please sign]='' OR BB.[Please sign] IS NULL,'N/A',CONCAT('https://webapi.magnitudefb.com/MGUploadData/Feedback/',BB.[Please sign])) AS [Please sign]
	   FROM 
(select EstablishmentName,CapturedDate,ReferenceNo,IsPositive,Status,UserName,Longitude,Latitude,--CustomerEmail,CustomerMobile,CustomerName,
[Job Reference Number],[Load Confirmation Number],[Date],[Client],[Client reference / order number],[Transporter],[Commodity],[Rate type],[Tonnage, Volume or Loads (New Field)],[Type of Move],[Load Point],[Loading],[Loading Start Time],[Loading End Time],[Offloading],[Off Loading Point],[Off Loading Start Time],[Off Loading End Time],[Contact Person],[Max Los Tolerance %],[Transporter Rate Excluding VAT],[GIT Value (ZAR)],[Terms of Payment],[Cut off date and descriptions],[Invoicing Terms],[Special Instructions],[ULT Rate (ZAR)],[Number of Vehicles],[Number of Trips],[Ave Load],[Loading number],[Offloading number]
From(
select
E.EstablishmentName,dateadd(MINUTE,AM.TimeOffSet,AM.CreatedOn) as CapturedDate,AM.id as ReferenceNo,
AM.IsPositive,AM.IsResolved as Status,A.Detail as Answer,Q.Questiontitle as Question ,U.Name as UserName,AM.Longitude ,AM.Latitude
--(SELECT TOP 1 cd.Detail FROM ContactDetails CD WHERE   CD.ContactMasterId=(case when AM.IsSubmittedForGroup=1 then SAC.ContactMasterId  else AM.ContactMasterId end) and CD.IsDeleted = 0 and CD.Detail<>'' 
--and CD.contactQuestionId=3252
--) as CustomerEmail,
--(SELECT TOP 1 cd.Detail FROM ContactDetails CD WHERE   CD.ContactMasterId=(case when AM.IsSubmittedForGroup=1 then SAC.ContactMasterId  else AM.ContactMasterId end) and CD.IsDeleted = 0 and CD.Detail<>'' 
--and CD.contactQuestionId=3251
--) as CustomerMobile,
--(SELECT TOP 1 cd.Detail FROM ContactDetails CD WHERE   CD.ContactMasterId=(case when AM.IsSubmittedForGroup=1 then SAC.ContactMasterId  else AM.ContactMasterId end) and CD.IsDeleted = 0 and CD.Detail<>'' 
--and CD.contactQuestionId=3249
--)+' '+
--(SELECT TOP 1 cd.Detail FROM ContactDetails CD WHERE   CD.ContactMasterId=(case when AM.IsSubmittedForGroup=1 then SAC.ContactMasterId  else AM.ContactMasterId end) and CD.IsDeleted = 0 and CD.Detail<>'' 
--and CD.contactQuestionId=3250
--) as CustomerName
from dbo.[Group] G
inner join EstablishmentGroup EG on G.id=EG.groupid and g.id = 537 and eg.id=5865 
inner join Establishment E on  E.EstablishmentGroupId=EG.Id 
inner join SeenClientAnswerMaster AM on AM.EstablishmentId=E.id ANd (AM.IsDeleted=0 or AM.IsDeleted=null)
inner join [SeenClientAnswers] A on A.SeenclientAnswerMasterId=AM.id 
inner join SeenClientQuestions Q on Q.id=A.QuestionId and q.id in (49736,48180,48181,48182,48689,48183,48184,48464,48185,48186,48187,48571,48188,48189,48572,48190,48191,48192,48193,48194,48575,48197,48198,49288,48502,48199,48200,48202,48203,48204,48234,48235,49968,51459,51692)
LEFT outer join dbo.[Appuser] u on u.Id=AM.CreatedBy
left outer join SeenClientAnswerChild SAC on AM.id=SAC.SeenClientAnswerMasterId 
)S
pivot(
Max(Answer)
For  Question In (
[Job Reference Number],[Load Confirmation Number],[Date],[Client],[Client reference / order number],[Transporter],[Commodity],[Rate type],[Tonnage, Volume or Loads (New Field)],[Type of Move],[Load Point],[Loading],[Loading Start Time],[Loading End Time],[Offloading],[Off Loading Point],[Off Loading Start Time],[Off Loading End Time],[Contact Person],[Max Los Tolerance %],[Transporter Rate Excluding VAT],[GIT Value (ZAR)],[Terms of Payment],[Cut off date and descriptions],[Invoicing Terms],[Special Instructions],[ULT Rate (ZAR)],[Number of Vehicles],[Number of Trips],[Ave Load],[Loading number],[Offloading number]
))P 
)AA

LEFT JOIN 

(select EstablishmentName,ResponseDate,SeenClientAnswerMasterId,ReferenceNo,
[Signed at],[Date signed],[Designation],[Please sign to approve the details of the Job] AS [Please sign]
from (
select
E.EstablishmentName,dateadd(MINUTE,am.TimeOffSet,am.CreatedOn) as ResponseDate,am.id as ReferenceNo,cam.Id as SeenClientAnswerMasterId,
a.Detail as Answer,q.QuestionTitle as Question
from dbo.[Group] g
inner join EstablishmentGroup eg on g.id=eg.groupid and g.id = 537 and eg.id=5865 
inner join Establishment e on  e.EstablishmentGroupId=eg.Id 
inner join answermaster am on am.EstablishmentId=e.id and (am.IsDeleted=0 or am.IsDeleted=null)
inner join Answers a on a.AnswerMasterId=am.id 
inner join Questions q on q.id=a.QuestionId and q.id in (32739,32740,32741,32722)
left outer join dbo.[Appuser] u on u.id=am.CreatedBy
left join SeenClientAnswerMaster cam on cam.Id=am.SeenClientAnswerMasterId and (cam.IsDeleted=0 or cam.IsDeleted=null)
) s
pivot(
Max(Answer)
For  Question In (
[Signed at],[Date signed],[Designation],[Please sign to approve the details of the Job]
))P
)BB ON AA.ReferenceNo=BB.SeenClientAnswerMasterId WHERE AA.UserName<>'Ultimum Admin'

