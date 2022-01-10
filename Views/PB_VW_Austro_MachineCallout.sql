CREATE VIEW PB_VW_Austro_MachineCallout AS

WITH cte AS
(select REPLACE(EstablishmentName,'Austro Machine Callout - ','') AS EstablishmentName,CAST(CapturedDate AS DATE) AS CapturedDate,ReferenceNo,Status,UserName,P.StatusName,P.Latitude,P.Longitude,CustomerName,CustomerCompany,CustomerEmail,CustomerMobile,P.RepeatCount,
[Client type:],[Type of Visit],[Industry:],[Is another OEM is involved?],[Have you spotted any additional potential opportunities?],[If yes, what is it? And how do you plan to bring this to your prospect's attention?],[Product],[General Comments],[Send Quote],[Machine],[Quote Description],[Attachments],[Com Machine],[Quantity],[Com Attachment],[Comments],[Is this a Biesse callout?],[Company tier],[Brands Presented],[Short Feedback:],[Long feedback]
From(
select
E.EstablishmentName,dateadd(MINUTE,AM.TimeOffSet,AM.CreatedOn) as CapturedDate,AM.id as ReferenceNo,
AM.IsResolved as Status,A.Detail as Answer,U.Name as UserName,AM.Latitude,AM.Longitude,A.RepeatCount,es.StatusName,
CASE
WHEN q.id=71229 THEN 'Com Machine'
WHEN q.id=71231 THEN 'Com Attachment' ELSE q.QuestionTitle END AS Question,
(SELECT TOP 1 cd.Detail FROM ContactDetails CD WHERE   CD.ContactMasterId=(case when AM.IsSubmittedForGroup=1 then SAC.ContactMasterId  else AM.ContactMasterId end) and CD.IsDeleted = 0 and CD.Detail<>'' 
and CD.contactQuestionId=2928
) as CustomerCompany,
(SELECT TOP 1 cd.Detail FROM ContactDetails CD WHERE   CD.ContactMasterId=(case when AM.IsSubmittedForGroup=1 then SAC.ContactMasterId  else AM.ContactMasterId end) and CD.IsDeleted = 0 and CD.Detail<>'' 
and CD.contactQuestionId=2837
) as CustomerEmail,
(SELECT TOP 1 cd.Detail FROM ContactDetails CD WHERE   CD.ContactMasterId=(case when AM.IsSubmittedForGroup=1 then SAC.ContactMasterId  else AM.ContactMasterId end) and CD.IsDeleted = 0 and CD.Detail<>'' 
and CD.contactQuestionId=2836
) as CustomerMobile,
(SELECT TOP 1 cd.Detail FROM ContactDetails CD WHERE   CD.ContactMasterId=(case when AM.IsSubmittedForGroup=1 then SAC.ContactMasterId  else AM.ContactMasterId end) and CD.IsDeleted = 0 and CD.Detail<>'' 
and CD.contactQuestionId=2834
) as CustomerName
from dbo.[Group] G
inner join EstablishmentGroup EG on G.id=EG.groupid and g.id = 462 and eg.id=4029
inner join Establishment E on  E.EstablishmentGroupId=EG.Id 
inner join SeenClientAnswerMaster AM on AM.EstablishmentId=E.id ANd (AM.IsDeleted=0 or AM.IsDeleted=null)
LEFT JOIN dbo.StatusHistory sh ON sh.Id=AM.StatusHistoryId
LEFT JOIN dbo.EstablishmentStatus es ON es.Id=sh.EstablishmentStatusId
inner join [SeenClientAnswers] A on A.SeenclientAnswerMasterId=AM.id 
inner join SeenClientQuestions Q on Q.id=A.QuestionId and q.id in (70858,72668,33575,31674,31675,32631,31698,31692,70850,32095,32096,71229,71230,71231,71232,32053,32056,32186,32187,32057,33205,74375)
LEFT outer join dbo.[Appuser] u on u.Id=AM.CreatedBy
left outer join SeenClientAnswerChild SAC on AM.id=SAC.SeenClientAnswerMasterId 
)S
pivot(
Max(Answer)
For  Question In (
[Client type:],[Type of Visit],[Industry:],[Is another OEM is involved?],[Have you spotted any additional potential opportunities?],[If yes, what is it? And how do you plan to bring this to your prospect's attention?],[Product],[General Comments],[Send Quote],[Machine],[Quote Description],[Attachments],[Com Machine],[Quantity],[Com Attachment],[Comments],[Is this a Biesse callout?],[Company tier],[Brands Presented],[Short Feedback:],[Long feedback]
))P
)

SELECT AA.EstablishmentName,
       AA.CapturedDate,
       AA.ReferenceNo,
       AA.Status,
       AA.StatusName,
       AA.UserName,
       AA.Latitude,
       AA.Longitude,
       AA.CustomerName,
       AA.CustomerCompany,
       AA.CustomerEmail,
       AA.CustomerMobile,
       AA.RepeatCount,
       AA.[Client type:],
       AA.[Type of Visit],
       AA.[Industry:],
	   AA.[Is another OEM is involved?],
       AA.[Have you spotted any additional potential opportunities?],
       AA.[If yes, what is it? And how do you plan to bring this to your prospect's attention?],
       AA.Product,
       AA.[General Comments],
       AA.[Send Quote],
       AA.Machine,
       AA.[Quote Description],
       AA.Attachments,
       AA.[Com Machine],
       AA.Quantity,
       AA.[Com Attachment],
       AA.Comments,
       AA.[Is this a Biesse callout?],
       AA.[Company tier],
       AA.[Brands Presented],
       AA.[Short Feedback:],
       AA.[Long feedback],
       BB.ResponseDate,
       --BB.SeenClientAnswerMasterId,
       BB.Responseno,
       BB.[Rate the overall service provided by the salesmen],
       BB.[Rate the professionalism provided by the salesmen?],
       BB.[Are you satisfied with the overall service provided by Austro?],
       BB.[Are you experiencing any issues?],
       BB.Comment 
	   FROM 
(SELECT B.EstablishmentName,
       B.CapturedDate,
       B.ReferenceNo,
       B.Status,
	   B.StatusName,
       B.UserName,
       B.Latitude,
       B.Longitude,
       B.CustomerName,
       B.CustomerCompany,
       B.CustomerEmail,
       B.CustomerMobile,
       A.RepeatCount,
       B.[Client type:],
       B.[Type of Visit],
       B.[Industry:],
	   B.[Is another OEM is involved?],
       B.[Have you spotted any additional potential opportunities?],
       B.[If yes, what is it? And how do you plan to bring this to your prospect's attention?],
       B.Product,
       B.[General Comments],
       B.[Send Quote],
       B.Machine,
       B.[Quote Description],
       B.Attachments,
       A.[Com Machine],
       A.Quantity,
       A.[Com Attachment],
       A.Comments,
       B.[Is this a Biesse callout?],
       B.[Company tier],
       B.[Brands Presented],
       B.[Short Feedback:],
       B.[Long feedback] FROM 
(SELECT * FROM cte WHERE RepeatCount <> 0)A RIGHT OUTER JOIN (SELECT * FROM cte WHERE RepeatCount = 0)B 
ON A.ReferenceNo = B.ReferenceNo
)AA

LEFT JOIN 

(select ResponseDate,SeenClientAnswerMasterId,Responseno,
[Rate the overall service provided by the salesmen],[Rate the professionalism provided by the salesmen?],[Are you satisfied with the overall service provided by Austro?],[Are you experiencing any issues?],[Comment]
from (
select
dateadd(MINUTE,am.TimeOffSet,am.CreatedOn) as ResponseDate,am.id as Responseno,cam.Id as SeenClientAnswerMasterId,
a.Detail as Answer,q.QuestionTitle AS Question
from dbo.[Group] g
inner join EstablishmentGroup eg on g.id=eg.groupid and g.id = 462 and eg.id=4029 
inner join Establishment e on  e.EstablishmentGroupId=eg.Id 
inner join answermaster am on am.EstablishmentId=e.id and (am.IsDeleted=0 or am.IsDeleted=null)
inner join Answers a on a.AnswerMasterId=am.id 
inner join Questions q on q.id=a.QuestionId and q.Id IN(53876,53877,53878,53879,53880)
left outer join dbo.[Appuser] u on u.id=am.CreatedBy
left join SeenClientAnswerMaster cam on cam.Id=am.SeenClientAnswerMasterId and (cam.IsDeleted=0 or cam.IsDeleted=null)
) s
pivot(
Max(Answer)
For  Question In (
[Rate the overall service provided by the salesmen],[Rate the professionalism provided by the salesmen?],[Are you satisfied with the overall service provided by Austro?],[Are you experiencing any issues?],[Comment]
))P
)BB ON AA.ReferenceNo=BB.SeenClientAnswerMasterId

