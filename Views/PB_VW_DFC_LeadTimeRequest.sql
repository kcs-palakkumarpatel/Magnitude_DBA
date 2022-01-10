CREATE VIEW dbo.PB_VW_DFC_LeadTimeRequest AS

WITH cte AS
(SELECT REPLACE(p.EstablishmentName,'Lead time Request - ','') AS EstablishmentName,CapturedDate,ReferenceNo,IsResolved,UserName,p.StatusName,p.RepeatCount,
[Customer Name],[Customer Purchase Order Number],[Customer Order Date],[Attachment of order],[Product Code],[Quantity]
from (
SELECT
E.EstablishmentName,cast(dateadd(MINUTE,AM.TimeOffSet,AM.CreatedOn) as DATETIME) as CapturedDate,AM.id as ReferenceNo,
AM.IsResolved,REPLACE(A.Detail,'-- Select --','') as Answer,Q.QuestionTitle AS Question,u.name as UserName,es.StatusName,A.RepeatCount
from dbo.[Group] G
inner join EstablishmentGroup EG on G.id=EG.groupid and g.id = 366 and eg.id=7809 
inner join Establishment E on  E.EstablishmentGroupId=EG.Id 
inner join SeenClientAnswerMaster AM on AM.EstablishmentId=E.id ANd (AM.IsDeleted=0 or AM.IsDeleted=null)
inner join [SeenClientAnswers] A on A.SeenclientAnswerMasterId=AM.id 
inner join SeenClientQuestions Q on Q.id=A.QuestionId and Q.Id IN (74307,74308,74309,81759,81848,81849)
left outer join dbo.[Appuser] u on u.id=AM.CreatedBy
left outer join StatusHistory SH on SH.id=AM.StatusHistoryId
left outer join establishmentstatus es on sh.establishmentstatusid=es.id
)s
pivot(
Max(Answer)
For  Question In (
[Customer Name],[Customer Purchase Order Number],[Customer Order Date],[Attachment of order],[Product Code],[Quantity]
))p
)

SELECT *,DATEDIFF(DAY,x.CapturedDate,y.ResponseDate) AS [ResponseTime (Days)] FROM 
(SELECT a.EstablishmentName,
       a.CapturedDate,
	   CAST(a.CapturedDate AS DATE) AS [Capture Date],
       a.ReferenceNo,
       a.IsResolved,
       a.UserName,
       a.StatusName,
       b.RepeatCount,
       a.[Customer Name],
       a.[Customer Purchase Order Number],
       a.[Customer Order Date],
       IIF(a.[Attachment of order] IS NULL OR a.[Attachment of order]='','N/A',CONCAT('https://webapi.magnitudefb.com/MGUploadData/SeenClient/',a.[Attachment of order])) AS [Attachment of order],
       b.[Product Code],
       b.Quantity       
	   FROM (SELECT * FROM cte WHERE cte.RepeatCount=0)a LEFT JOIN (SELECT * FROM cte WHERE cte.RepeatCount<>0)b ON a.ReferenceNo=b.ReferenceNo
)x
LEFT JOIN 

(select ResponseDate,SeenClientAnswerMasterId,ResponseNo,DirectRespondent,
[Order Entry Date:],[Customer Delivery Date:],[Manufacturing Date:],[Lead Time Given by:],[is there any risk?]
from (
select
E.EstablishmentName,dateadd(MINUTE,am.TimeOffSet,am.CreatedOn) as ResponseDate,am.id as ResponseNo,cam.Id as SeenClientAnswerMasterId,
a.Detail as Answer,q.Questiontitle AS Question,
(SELECT TOP 1 cd.Detail FROM ContactDetails CD WHERE   CD.ContactMasterId=(case when cam.IsSubmittedForGroup=1 then SAC.ContactMasterId else cam.ContactMasterId end) and CD.IsDeleted = 0 and CD.Detail<>'' 
and CD.contactQuestionId=2284
)+' '+(SELECT TOP 1 cd.Detail FROM ContactDetails CD WHERE   CD.ContactMasterId=(case when cam.IsSubmittedForGroup=1 then SAC.ContactMasterId else cam.ContactMasterId end) and CD.IsDeleted = 0 and CD.Detail<>'' 
and CD.contactQuestionId=2285
) as DirectRespondent
from dbo.[Group] g
inner join EstablishmentGroup eg on g.id=eg.groupid and g.id = 366 and eg.id=7809
inner join Establishment e on  e.EstablishmentGroupId=eg.Id 
inner join answermaster am on am.EstablishmentId=e.id and (am.IsDeleted=0 or am.IsDeleted=null)
inner join Answers a on a.AnswerMasterId=am.id 
inner join Questions q on q.id=a.QuestionId and q.id in (58990,58991,58992,58994,59046)
left join SeenClientAnswerMaster cam on cam.Id=am.SeenClientAnswerMasterId and (cam.IsDeleted=0 or cam.IsDeleted=null)
left outer join SeenclientAnswerChild SAC on SAC.Id=am.SeenClientAnswerChildId
) s
pivot(
Max(Answer)
For  Question In (
[Order Entry Date:],[Customer Delivery Date:],[Manufacturing Date:],[Lead Time Given by:],[is there any risk?]
))P
)y ON x.ReferenceNo=y.SeenClientAnswerMasterId

