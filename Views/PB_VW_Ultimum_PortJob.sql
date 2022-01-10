CREATE VIEW PB_VW_Ultimum_PortJob AS

SELECT AA.EstablishmentName,
       CAST(AA.CapturedDate AS DATE) AS CaptureDate,
       AA.ReferenceNo,
       AA.IsPositive,
       AA.Status,
       AA.UserName,
       AA.Longitude,
       AA.Latitude,
       AA.CustomerEmail,
       AA.CustomerMobile,
       AA.CustomerName,
       AA.[Job Reference Number],
       AA.Client,
       AA.Tonnage,
       AA.[Slot Number],
       AA.Commodity,
       AA.[Port Agent],
       AA.[Client Rate ($)],
       AA.[Port Agency Rate ($)],
       AA.[Port Rate ($)],
       AA.[CBR Requested Date],
       AA.[Model Of Transport],
       BB.ResponseDate,
       BB.ReferenceNo AS Responseno,
       BB.[Update],
       BB.[CBR Confirmed Number],
       BB.[Date Received],
       BB.[Vessel name],
       BB.Dates,
       BB.[Laycan Start Date],
       BB.[Laycan End Date],
       BB.[ETA Date],
       BB.[Port Agent] AS [Port Agent1],
       BB.[Slot Number] AS [Slot Number1],
       BB.[Port Rate ($)] AS [Port Rate ($)1],
       BB.[Client Rate ($)] AS [Client Rate ($)1],
       BB.[Model of Transport] AS [Model of Transport1],
       BB.[Amend tonnage],
       BB.[App/Job Reference Number #],
	   BB.[Port Agency Rate ($)] AS [Port Agency Rate ($)1],
	   BB.[CBR Request Date] AS [CBR Request Date1],
	   BB.[Date Vessel Sailed]
	   FROM 
(select EstablishmentName,CapturedDate,ReferenceNo,IsPositive,Status,UserName,Longitude,Latitude,CustomerEmail,CustomerMobile,CustomerName,
[Job Reference Number],[Client],[Tonnage],[Slot Number],[Commodity],[Port Agent],[Client Rate ($)],[Port Agency Rate ($)],[Port Rate ($)],[CBR Requested Date],[Model Of Transport]
From(
select
E.EstablishmentName,dateadd(MINUTE,AM.TimeOffSet,AM.CreatedOn) as CapturedDate,AM.id as ReferenceNo,
AM.IsPositive,AM.IsResolved as Status,A.Detail as Answer,Q.Questiontitle as Question ,U.Name as UserName,AM.Longitude ,AM.Latitude,
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
inner join EstablishmentGroup EG on G.id=EG.groupid and g.id = 537 and eg.id=5851 
inner join Establishment E on  E.EstablishmentGroupId=EG.Id 
inner join SeenClientAnswerMaster AM on AM.EstablishmentId=E.id ANd (AM.IsDeleted=0 or AM.IsDeleted=null)
inner join [SeenClientAnswers] A on A.SeenclientAnswerMasterId=AM.id 
inner join SeenClientQuestions Q on Q.id=A.QuestionId and q.id in (49737,47899,47900,47901,47902,47903,48230,49697,47905,47906,47907,52758)
LEFT outer join dbo.[Appuser] u on u.Id=AM.CreatedBy
left outer join SeenClientAnswerChild SAC on AM.id=SAC.SeenClientAnswerMasterId 
)S
pivot(
Max(Answer)
For  Question In (
[Job Reference Number],[Client],[Tonnage],[Slot Number],[Commodity],[Port Agent],[Client Rate ($)],[Port Agency Rate ($)],[Port Rate ($)],[CBR Requested Date],[Model Of Transport]
))P 
)AA

LEFT JOIN 

(select EstablishmentName,ResponseDate,SeenClientAnswerMasterId,ReferenceNo,
[Update],[CBR Confirmed Number],[Date Received],[Vessel name],[Dates],[Laycan Start Date],[Laycan End Date],[ETA Date],[Port Agent],[Slot Number],[Port Rate ($)],[Client Rate ($)],[Model of Transport],[Amend tonnage],[App/Job Reference Number #],[Port Agency Rate ($)],[CBR Request Date],[Date Vessel Sailed]
from (
select
E.EstablishmentName,dateadd(MINUTE,am.TimeOffSet,am.CreatedOn) as ResponseDate,am.id as ReferenceNo,cam.Id as SeenClientAnswerMasterId,
a.Detail as Answer,
CASE WHEN q.Id=33614 THEN 'Update'
	 WHEN q.Id=34618 THEN 'Update' 
	 WHEN q.Id=35449 THEN 'Update' 
	 WHEN q.Id=35450 THEN 'Update' ELSE q.QuestionTitle END AS Question
from dbo.[Group] g
inner join EstablishmentGroup eg on g.id=eg.groupid and g.id = 537 and eg.id=5851 
inner join Establishment e on  e.EstablishmentGroupId=eg.Id 
inner join answermaster am on am.EstablishmentId=e.id and (am.IsDeleted=0 or am.IsDeleted=null)
inner join Answers a on a.AnswerMasterId=am.id 
inner join Questions q on q.id=a.QuestionId and q.id in (40908,34618,35449,35450,32661,32738,33054,33614,32662,32663,33017,33615,33019,33020,33021,32664,33616,33618,33611,33612,33617,33859,34622,35451,40909,40910)
left outer join dbo.[Appuser] u on u.id=am.CreatedBy
left join SeenClientAnswerMaster cam on cam.Id=am.SeenClientAnswerMasterId and (cam.IsDeleted=0 or cam.IsDeleted=null)
) s
pivot(
Max(Answer)
For  Question In (
[Update],[CBR Confirmed Number],[Date Received],[Vessel name],[Dates],[Laycan Start Date],[Laycan End Date],[ETA Date],[Port Agent],[Slot Number],[Port Rate ($)],[Client Rate ($)],[Model of Transport],[Amend tonnage],[App/Job Reference Number #],[Port Agency Rate ($)],[CBR Request Date],[Date Vessel Sailed]
))P WHERE P.[Update] NOT LIKE '%,%' AND P.[Update] NOT LIKE '%Amend Tonnage%'
)BB ON AA.ReferenceNo=BB.SeenClientAnswerMasterId WHERE AA.UserName<>'Ultimum Admin'

