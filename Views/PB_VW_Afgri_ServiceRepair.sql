CREATE VIEW PB_VW_Afgri_ServiceRepair AS

SELECT AA.EstablishmentName,
       CAST(AA.CapturedDate AS DATE) AS CapturedDate,
       AA.ReferenceNo,
       AA.IsPositive,
       AA.Status,
       AA.UserName,
	   AA.Latitude,
	   AA.Longitude,
       AA.CustomerEmail,
       AA.CustomerMobile,
       AA.CustomerName,
	   AA.Position,
	   AA.Area,
       AA.Customer,
       AA.[Unique ID],
       AA.[Serial number],
	   CONCAT(AA.[Unique ID],' ',AA.[Serial number]) AS [Uniqueid & Serial no.],
       AA.Hours,
       AA.Model,
       AA.[Work to be done],
       AA.[Description of work],
       AA.[Are there any unresolved Items?],
       AA.[If Yes, What are the unresolved item?],
       IIF(AA.[Unresolved Item Picture]='','N/A',CONCAT('https://webapi.magnitudefb.com/MGUploadData/SeenClient/',AA.[Unresolved Item Picture])) AS [Unresolved Item Picture],
       AA.[General comments],
       --BB.EstablishmentName,
       BB.ResponseDate,
       --BB.SeenClientAnswerMasterId,
       BB.ResponseNo,
       BB.[Over professionalism of our technician?],
       BB.[How can we improve?],
       BB.[Was the technician prepared to do the job?],
       BB.[How can we Improve1?],
       BB.[How likely are you to recommend Afgri?],
       BB.[How can we improve2?],
       BB.[Was the job completed successfully?],
       BB.[Why?],
       BB.[Do you approve/ Require additional work?],
       IIF(BB.[Signature of approval] IS NULL,'N/A',CONCAT('https://webapi.magnitudefb.com/MGUploadData/Feedback/',BB.[Signature of approval])) AS [Signature of approval],
       BB.[What work do you require?],
       BB.[Are you facing any issues?],
       BB.[What issues are you facing?],
       BB.[Do you need to be contacted?] FROM 
(select EstablishmentName,CapturedDate,ReferenceNo,IsPositive,Status,UserName,P.Latitude,P.Longitude,CustomerEmail,CustomerMobile,CustomerName,P.Position,P.Area,
[Customer],[Unique ID],[Serial number],[Hours],[Model],[Work to be done],[Description of work],[Are there any unresolved Items?],[If Yes, What are the unresolved item?],[Unresolved Item Picture],[General comments]
From(
select
E.EstablishmentName,dateadd(MINUTE,AM.TimeOffSet,AM.CreatedOn) as CapturedDate,AM.id as ReferenceNo,
AM.IsPositive,AM.IsResolved as Status,A.Detail as Answer,Q.QuestionTitle as Question ,U.Name as UserName,AM.Latitude,AM.Longitude,
(SELECT TOP 1 cd.Detail FROM ContactDetails CD WHERE   CD.ContactMasterId=(case when AM.IsSubmittedForGroup=1 then SAC.ContactMasterId  else AM.ContactMasterId end) and CD.IsDeleted = 0 and CD.Detail<>'' 
and CD.contactQuestionId=3454
) as Position,
(SELECT TOP 1 cd.Detail FROM ContactDetails CD WHERE   CD.ContactMasterId=(case when AM.IsSubmittedForGroup=1 then SAC.ContactMasterId  else AM.ContactMasterId end) and CD.IsDeleted = 0 and CD.Detail<>'' 
and CD.contactQuestionId=3455
) as Area,
(SELECT TOP 1 cd.Detail FROM ContactDetails CD WHERE   CD.ContactMasterId=(case when AM.IsSubmittedForGroup=1 then SAC.ContactMasterId  else AM.ContactMasterId end) and CD.IsDeleted = 0 and CD.Detail<>'' 
and CD.contactQuestionId=268
) as CustomerEmail,
(SELECT TOP 1 cd.Detail FROM ContactDetails CD WHERE   CD.ContactMasterId=(case when AM.IsSubmittedForGroup=1 then SAC.ContactMasterId  else AM.ContactMasterId end) and CD.IsDeleted = 0 and CD.Detail<>'' 
and CD.contactQuestionId=267
) as CustomerMobile,
(SELECT TOP 1 cd.Detail FROM ContactDetails CD WHERE   CD.ContactMasterId=(case when AM.IsSubmittedForGroup=1 then SAC.ContactMasterId  else AM.ContactMasterId end) and CD.IsDeleted = 0 and CD.Detail<>'' 
and CD.contactQuestionId=265
)+' '+
(SELECT TOP 1 cd.Detail FROM ContactDetails CD WHERE   CD.ContactMasterId=(case when AM.IsSubmittedForGroup=1 then SAC.ContactMasterId  else AM.ContactMasterId end) and CD.IsDeleted = 0 and CD.Detail<>'' 
and CD.contactQuestionId=266
) as CustomerName
from dbo.[Group] G
inner join EstablishmentGroup EG on G.id=EG.groupid and g.id = 27 and eg.id=6093
inner join Establishment E on  E.EstablishmentGroupId=EG.Id 
inner join SeenClientAnswerMaster AM on AM.EstablishmentId=E.id ANd (AM.IsDeleted=0 or AM.IsDeleted=null)
inner join [SeenClientAnswers] A on A.SeenclientAnswerMasterId=AM.id 
inner join SeenClientQuestions Q on Q.id=A.QuestionId and q.id in (50632,50603,50604,50605,50606,51407,50608,50609,50633,50610,50611)
LEFT outer join dbo.[Appuser] u on u.Id=AM.CreatedBy
left outer join SeenClientAnswerChild SAC on AM.id=SAC.SeenClientAnswerMasterId 
)S
pivot(
Max(Answer)
For  Question In (
[Customer],[Unique ID],[Serial number],[Hours],[Model],[Work to be done],[Description of work],[Are there any unresolved Items?],[If Yes, What are the unresolved item?],[Unresolved Item Picture],[General comments]
))P 
)AA

LEFT JOIN 

(select EstablishmentName,ResponseDate,SeenClientAnswerMasterId,ResponseNo,
[Over professionalism of our technician?],[How can we improve?],[Was the technician prepared to do the job?],[How can we Improve1?],[How likely are you to recommend Afgri?],[How can we improve2?],[Was the job completed successfully?],[Why?],[Do you approve/ Require additional work?],[Signature of approval],[What work do you require?],[Are you facing any issues?],[What issues are you facing?],[Do you need to be contacted?]
from (
select
E.EstablishmentName,dateadd(MINUTE,am.TimeOffSet,am.CreatedOn) as ResponseDate,am.id as ResponseNo,cam.Id as SeenClientAnswerMasterId,
a.Detail as Answer,
CASE WHEN q.id=35534 THEN 'How can we improve1?'
WHEN q.id=35536 THEN 'How can we improve2?' ELSE q.QuestionTitle END AS Question
from dbo.[Group] g
inner join EstablishmentGroup eg on g.id=eg.groupid and g.id = 27 and eg.id=6093
inner join Establishment e on  e.EstablishmentGroupId=eg.Id 
inner join answermaster am on am.EstablishmentId=e.id and (am.IsDeleted=0 or am.IsDeleted=null)
inner join Answers a on a.AnswerMasterId=am.id 
inner join Questions q on q.id=a.QuestionId and q.id in (37666,35532,37667,35534,37668,35536,35537,35538,35539,35540,35541,36224,36225,35542)
left outer join dbo.[Appuser] u on u.id=am.CreatedBy
left join SeenClientAnswerMaster cam on cam.Id=am.SeenClientAnswerMasterId and (cam.IsDeleted=0 or cam.IsDeleted=null)
) s
pivot(
Max(Answer)
For  Question In (
[Over professionalism of our technician?],[How can we improve?],[Was the technician prepared to do the job?],[How can we Improve1?],[How likely are you to recommend Afgri?],[How can we improve2?],[Was the job completed successfully?],[Why?],[Do you approve/ Require additional work?],[Signature of approval],[What work do you require?],[Are you facing any issues?],[What issues are you facing?],[Do you need to be contacted?]
))P
)BB ON AA.ReferenceNo=BB.SeenClientAnswerMasterId

