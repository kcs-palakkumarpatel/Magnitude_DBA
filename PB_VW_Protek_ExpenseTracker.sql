CREATE VIEW PB_VW_Protek_ExpenseTracker AS

SELECT AA.CapturedDate,
       AA.ReferenceNo,
       AA.Status,
       AA.UserName,
       AA.Longitude,
       AA.Latitude,
       AA.[Day of purchase],
       AA.[Title of receipt],
       AA.[Description of receipt],
       AA.Amount,
       AA.[Expense category],
	   AA.[Attach receipt],
	   AA.[Please sign],     
       BB.ResponseDate,       
       BB.ReferenceNo AS Refno, 
       BB.[Have you acknowledged the expense claim?] FROM 
(
SELECT w.CapturedDate,
       w.ReferenceNo,
       w.Status,
       w.UserName,
       w.Longitude,
       w.Latitude,
       w.[Day of purchase],
       w.[Title of receipt],
       w.[Description of receipt],
       w.Amount,
       w.[Expense category],
       IIF(x.Data='' OR x.Data IS NULL,'N/A',CONCAT('https://webapi.magnitudefb.com/MGUploadData/SeenClient/',x.Data)) AS [Attach receipt],
       IIF(w.[Please sign]='' OR w.[Please sign] IS NULL,'N/A',CONCAT('https://webapi.magnitudefb.com/MGUploadData/SeenClient/',w.[Please sign])) AS [Please sign]
       FROM 
(SELECT CapturedDate,ReferenceNo,Status,UserName,Longitude,Latitude,
[Day of purchase],[Title of receipt],[Description of receipt],REPLACE([Amount],',','.') AS [Amount],[Expense category],[Attach receipt],[Please sign]
from (
select
cast(dateadd(MINUTE,AM.TimeOffSet,AM.CreatedOn) as date) as CapturedDate,AM.id as ReferenceNo,
AM.IsResolved as Status,
A.Detail as Answer
,Q.Questiontitle as Question,u.name as UserName,
AM.Longitude ,AM.Latitude
from dbo.[Group] G
inner join EstablishmentGroup EG on G.id=EG.groupid and g.id = 505 and eg.id=5377
inner join Establishment E on  E.EstablishmentGroupId=EG.Id 
inner join SeenClientAnswerMaster AM on AM.EstablishmentId=E.id ANd (AM.IsDeleted=0 or AM.IsDeleted=null)
inner join [SeenClientAnswers] A on A.SeenclientAnswerMasterId=AM.id 
inner join SeenClientQuestions Q on Q.id=A.QuestionId and q.id in (43113,43114,43115,43116,43117,46050,43118,43119)
left outer join dbo.[Appuser] u on u.id=AM.CreatedBy
left outer join SeenClientAnswerChild SAC on AM.id=SAC.SeenClientAnswerMasterId
)s
pivot(
Max(Answer)
For  Question In (
[Day of purchase],[Title of receipt],[Description of receipt],[Amount],[Expense category],[Attach receipt],[Please sign]
))p
)w CROSS APPLY (select Data from dbo.Split(w.[Attach receipt],',') ) x
)AA

LEFT JOIN

(select EstablishmentName,ResponseDate,SeenClientAnswerMasterId,ReferenceNo,
[Have you acknowledged the expense claim?]
from (
select
E.EstablishmentName,dateadd(MINUTE,am.TimeOffSet,am.CreatedOn) as ResponseDate,am.id as ReferenceNo,cam.Id as SeenClientAnswerMasterId,
a.Detail as Answer,q.Questiontitle as Question
from dbo.[Group] g
inner join EstablishmentGroup eg on g.id=eg.groupid and g.id = 505 and eg.id=5377 
inner join Establishment e on  e.EstablishmentGroupId=eg.Id 
inner join answermaster am on am.EstablishmentId=e.id and (am.IsDeleted=0 or am.IsDeleted=null)
inner join Answers a on a.AnswerMasterId=am.id 
inner join Questions q on q.id=a.QuestionId and q.id in (31725)
left outer join dbo.[Appuser] u on u.id=am.CreatedBy
left join SeenClientAnswerMaster cam on cam.Id=am.SeenClientAnswerMasterId and (cam.IsDeleted=0 or cam.IsDeleted=null)
left outer join SeenClientAnswerChild SAC on cam.id=SAC.SeenClientAnswerMasterId 
) s
pivot(
Max(Answer)
For  Question In (
[Have you acknowledged the expense claim?]
))P
)BB ON AA.ReferenceNo=BB.SeenClientAnswerMasterId

