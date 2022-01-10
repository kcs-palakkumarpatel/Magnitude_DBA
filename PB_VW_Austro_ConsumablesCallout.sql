CREATE VIEW PB_VW_Austro_ConsumablesCallout AS

WITH cte AS
(select REPLACE(EstablishmentName,'Austro Sales Consumables - ','') AS EstablishmentName,CAST(CapturedDate AS DATE) AS CapturedDate,ReferenceNo,Status,UserName,P.StatusName,P.Latitude,P.Longitude,CustomerName,CustomerCompany,CustomerEmail,CustomerMobile,P.RepeatCount,
[Client type:],[Type of Visit],[Industry:],[Is another OEM is involved?],[Type of task:],[If other, please state],[General Comments],[Product Family],[Have you spotted an additional Machine opportunity?],[If yes, please outline the additional opportunity],[Products Using:],[Picture of operations area:],[Branded Products],[Is this a Biesse callout?],[Company tier],[Brands Presented],[Short Feedback:],[Long feedback],[Do you need a quote to be sent?],[Type:],[Products],[Quantity],[Pictures | Videos | Documents],[Comments]
From(
select
E.EstablishmentName,dateadd(MINUTE,AM.TimeOffSet,AM.CreatedOn) as CapturedDate,AM.id as ReferenceNo,
AM.IsResolved as Status,A.Detail as Answer,U.Name as UserName,AM.Latitude,AM.Longitude,A.RepeatCount,es.StatusName,q.QuestionTitle AS Question,
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
inner join EstablishmentGroup EG on G.id=EG.groupid and g.id = 462 and eg.id=3835
inner join Establishment E on  E.EstablishmentGroupId=EG.Id 
inner join SeenClientAnswerMaster AM on AM.EstablishmentId=E.id ANd (AM.IsDeleted=0 or AM.IsDeleted=null)
LEFT JOIN dbo.StatusHistory sh ON sh.Id=AM.StatusHistoryId
LEFT JOIN dbo.EstablishmentStatus es ON es.Id=sh.EstablishmentStatusId
inner join [SeenClientAnswers] A on A.SeenclientAnswerMasterId=AM.id 
inner join SeenClientQuestions Q on Q.id=A.QuestionId and q.id in (70833,72669,33574,36883,33332,33210,32566,32568,32569,30075,30077,32571,72636,72638,72639,72652,72653,70834,71315,32828,30090,30091,30092,74374)
LEFT outer join dbo.[Appuser] u on u.Id=AM.CreatedBy
left outer join SeenClientAnswerChild SAC on AM.id=SAC.SeenClientAnswerMasterId 
)S
pivot(
Max(Answer)
For  Question In (
[Client type:],[Type of Visit],[Industry:],[Is another OEM is involved?],[Type of task:],[If other, please state],[General Comments],[Product Family],[Have you spotted an additional Machine opportunity?],[If yes, please outline the additional opportunity],[Products Using:],[Picture of operations area:],[Branded Products],[Is this a Biesse callout?],[Company tier],[Brands Presented],[Short Feedback:],[Long feedback],[Do you need a quote to be sent?],[Type:],[Products],[Quantity],[Pictures | Videos | Documents],[Comments]
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
       AA.[Type of task:],
       AA.[If other, please state],
       AA.[General Comments],
       AA.[Product Family],
       AA.[Have you spotted an additional Machine opportunity?],
       AA.[If yes, please outline the additional opportunity],
       AA.[Products Using:],
       AA.[Picture of operations area:],
       AA.[Branded Products],
       AA.[Is this a Biesse callout?],
       AA.[Company tier],
       AA.[Brands Presented],
       AA.[Short Feedback:],
       AA.[Long feedback],
       AA.[Do you need a quote to be sent?],
       AA.[Type:],
       AA.Products,
       AA.Quantity,
       AA.[Pictures | Videos | Documents],
       AA.Comments,
       BB.ResponseDate,
       --BB.SeenClientAnswerMasterId,
       BB.Responseno,
       BB.[Rate the overall service provided by the salesmen],
       BB.[Rate the professionalism provided by the salesmen?],
       BB.[Are you satisfied with the overall service provided by Austro?],
       BB.[Are you experiencing any issues?],
       BB.Comment FROM 
(SELECT B.EstablishmentName,
       B.CapturedDate,
       B.ReferenceNo,
       B.Status,
       B.UserName,
       B.StatusName,
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
       B.[Type of task:],
       B.[If other, please state],
       B.[General Comments],
       B.[Product Family],
       B.[Have you spotted an additional Machine opportunity?],
       B.[If yes, please outline the additional opportunity],
       B.[Products Using:],
       B.[Picture of operations area:],
       B.[Branded Products],
       B.[Is this a Biesse callout?],
       B.[Company tier],
       B.[Brands Presented],
       B.[Short Feedback:],
       B.[Long feedback],
       B.[Do you need a quote to be sent?],
       A.[Type:],
       A.Products,
       A.Quantity,
       A.[Pictures | Videos | Documents],
       A.Comments FROM 
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
inner join EstablishmentGroup eg on g.id=eg.groupid and g.id = 462 and eg.id=3835 
inner join Establishment e on  e.EstablishmentGroupId=eg.Id 
inner join answermaster am on am.EstablishmentId=e.id and (am.IsDeleted=0 or am.IsDeleted=null)
inner join Answers a on a.AnswerMasterId=am.id 
inner join Questions q on q.id=a.QuestionId and q.Id IN(53835,53836,53837,53838,53839)
left join SeenClientAnswerMaster cam on cam.Id=am.SeenClientAnswerMasterId and (cam.IsDeleted=0 or cam.IsDeleted=null)
) s
pivot(
Max(Answer)
For  Question In (
[Rate the overall service provided by the salesmen],[Rate the professionalism provided by the salesmen?],[Are you satisfied with the overall service provided by Austro?],[Are you experiencing any issues?],[Comment]
))P
)BB ON AA.ReferenceNo=BB.SeenClientAnswerMasterId

