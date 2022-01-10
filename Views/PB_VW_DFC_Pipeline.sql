CREATE VIEW dbo.PB_VW_DFC_Pipeline AS

WITH cte AS 
(
SELECT EstablishmentName,CapturedDate,CAST(CapturedDate AS DATE) AS [Capture Date],ReferenceNo,IsResolved,UserName,p.RepeatCount,
[Customer type:],[Company],[Salesperson Name],[Surname],[Mobile],[Customer Email],[End Customer],[Lead type],[Anticipated Close date],[Brand type],[If other, provide details],[Rand Value],
IIF([Is this in Pipeline or Forecasted] IS NULL OR [Is this in Pipeline or Forecasted]='','N/A',IIF([Is this in Pipeline or Forecasted]='Budget','Pipeline (Less than 50%)',IIF([Is this in Pipeline or Forecasted]='Forecast','Forecast (More than 80%)',[Is this in Pipeline or Forecasted]))) AS [Is this in Pipeline or Forecasted]
from (
SELECT
E.EstablishmentName,cast(dateadd(MINUTE,AM.TimeOffSet,AM.CreatedOn) as DATETIME) as CapturedDate,AM.id as ReferenceNo,
AM.IsResolved,A.Detail as Answer,
CASE WHEN q.Id=68028 THEN 'Is this in Pipeline or Forecasted' ELSE Q.QuestionTitle END AS Question,u.name as UserName,a.RepeatCount
from dbo.[Group] G
inner join EstablishmentGroup EG on G.id=EG.groupid and g.id = 366 and eg.id=6603 
inner join Establishment E on  E.EstablishmentGroupId=EG.Id 
inner join SeenClientAnswerMaster AM on AM.EstablishmentId=E.id ANd (AM.IsDeleted=0 or AM.IsDeleted=null)
inner join [SeenClientAnswers] A on A.SeenclientAnswerMasterId=AM.id 
inner join SeenClientQuestions Q on Q.id=A.QuestionId and Q.Id IN (57643,57518,57644,57519,57520,57521,57523,57524,57525,57526,57527,57528,68028,69440)
left outer join dbo.[Appuser] u on u.id=AM.CreatedBy
)s
pivot(
Max(Answer)
For  Question In (
[Customer type:],[Company],[Salesperson Name],[Surname],[Mobile],[Customer Email],[End Customer],[Lead type],[Anticipated Close date],[Brand type],[If other, provide details],[Rand Value],[Is this in Pipeline or Forecasted]
))p 
)

SELECT q.*,
CASE WHEN q.Status='Quote Sent' THEN 1
	 WHEN q.Status='Qualified' THEN 2
	 WHEN q.Status='Follow up' THEN 3
	 WHEN q.Status='Stalled in decision making' THEN 4
	 WHEN q.Status='In negotiation' THEN 5
	 WHEN q.Status='PO Received' THEN 6
	 WHEN q.Status='Lost deal' THEN 7
	 ELSE 8 END AS Sortorder
FROM 
(SELECT AA.EstablishmentName,
       AA.[Capture Date],
       AA.ReferenceNo,
       AA.IsResolved,
       AA.UserName,
       AA.RepeatCount,
       AA.[Customer type:],
       AA.Company,
       AA.[Salesperson Name],
       AA.Surname,
       AA.Mobile,
       AA.[Customer Email],
       AA.[End Customer],
       AA.[Lead type],
       AA.[Anticipated Close date],
       AA.[Brand type],
       AA.[If other, provide details],
       AA.[Rand Value],
	   AA.[Is this in Pipeline or Forecasted],
       BB.ResponseDate,
       BB.ResponseNo,
       BB.Status,
       --BB.[Type of follow up],
	   LTRIM(RTrim(Replace(Replace(Replace(Replace(Replace(Replace(BB.[Type of follow up],'"',''),'[',''),']',''),char(9),''),char(10),''),char(13),''))) AS [Type of follow up],
	   BB.[Reason for re quoted],
	   BB.[Deviation in price],
       BB.[Reason for lost deal],
       BB.[What was wrong with the pricing?],
       BB.[Who was the competitor?],
       BB.[How will you better your relationship with this customer?] FROM 
(SELECT 
B.EstablishmentName,
B.[Capture Date],
B.ReferenceNo,
B.IsResolved,
B.UserName,
A.RepeatCount,
B.[Customer type:],
B.Company,
B.[Salesperson Name],
B.Surname,
B.Mobile,
B.[Customer Email],
B.[End Customer],
B.[Lead type],
B.[Anticipated Close date],
A.[Brand type],
A.[If other, provide details],
A.[Rand Value],
B.[Is this in Pipeline or Forecasted]

FROM 

(SELECT * FROM cte WHERE RepeatCount <> 0)A RIGHT OUTER JOIN (SELECT * FROM cte WHERE RepeatCount = 0)B 
ON A.ReferenceNo = B.ReferenceNo
)AA

LEFT JOIN 

(select EstablishmentName,ResponseDate,SeenClientAnswerMasterId,ResponseNo,
LTRIM(RTrim(Replace(Replace(Replace(Replace(Replace(Replace(Status,'"',''),'[',''),']',''),char(9),''),char(10),''),char(13),''))) AS Status,
[Type of follow up],[Reason for re quoted],[Deviation in price],[Reason for lost deal],[What was wrong with the pricing?],[Who was the competitor?],[How will you better your relationship with this customer?]
from (
select
E.EstablishmentName,dateadd(MINUTE,am.TimeOffSet,am.CreatedOn) as ResponseDate,am.id as ResponseNo,cam.Id as SeenClientAnswerMasterId,
a.Detail as Answer,
CASE WHEN q.id=42527 THEN 'Status' ELSE q.Questiontitle END	AS Question
from dbo.[Group] g
inner join EstablishmentGroup eg on g.id=eg.groupid and g.id = 366 and eg.id=6603
inner join Establishment e on  e.EstablishmentGroupId=eg.Id 
inner join answermaster am on am.EstablishmentId=e.id and (am.IsDeleted=0 or am.IsDeleted=null)
inner join Answers a on a.AnswerMasterId=am.id 
inner join Questions q on q.id=a.QuestionId and q.id in (42527,50684,42529,42530,42531,42532,42533,50685,50686)
left join SeenClientAnswerMaster cam on cam.Id=am.SeenClientAnswerMasterId and (cam.IsDeleted=0 or cam.IsDeleted=null)
) s
pivot(
Max(Answer)
For  Question In (
[Status],[Type of follow up],[Reason for re quoted],[Deviation in price],[Reason for lost deal],[What was wrong with the pricing?],[Who was the competitor?],[How will you better your relationship with this customer?]
))P
)BB ON AA.ReferenceNo=BB.SeenClientAnswerMasterId

UNION ALL

SELECT 
B.EstablishmentName,
B.[Capture Date],
B.ReferenceNo,
B.IsResolved,
B.UserName,
A.RepeatCount,
B.[Customer type:],
B.Company,
B.[Salesperson Name],
B.Surname,
B.Mobile,
B.[Customer Email],
B.[End Customer],
B.[Lead type],
B.[Anticipated Close date],
A.[Brand type],
A.[If other, provide details],
A.[Rand Value],
B.[Is this in Pipeline or Forecasted],
NULL AS ResponseDate,
NULL AS ResponseNo,
'Quote Sent' AS Status,
NULL AS [Type of follow up],
NULL AS [Reason for re quoted],
NULL AS [Deviation in price],
NULL AS [Reason for lost deal],
NULL AS [What was wrong with the pricing?],
NULL AS [Who was the competitor?],
NULL AS [How will you better your relationship with this customer?]

FROM 

(SELECT * FROM cte WHERE RepeatCount <> 0)A RIGHT OUTER JOIN (SELECT * FROM cte WHERE RepeatCount = 0)B 
ON A.ReferenceNo = B.ReferenceNo
)q WHERE q.Status IS NOT NULL

