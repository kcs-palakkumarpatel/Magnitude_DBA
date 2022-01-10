CREATE VIEW PB_VW_Protek_BudgetTracker AS

SELECT * FROM dbo.Protek_BudgetData

UNION ALL

SELECT z.EstablishmentName,
       z.CapturedDate,
       z.ReferenceNo,
       z.Status,
       z.UserName,
       z.CustomerName,
       z.CustomerMobile,
       z.CustomerEmail,
       IIF(z.Area='' OR z.Area IS NULL OR z.Area='-- Select --','N/A',z.Area) AS Area,
       z.[Actual budget],
       z.[Date of budget],
       z.[Current sales (ZAR)],
	   IIF(z.[Actual budget]='0',0,CAST(z.[Current sales (ZAR)] AS DECIMAL)/CAST(z.[Actual budget] AS DECIMAL)) AS [Percentage of budget %],
       --z.[Percentage of budget %],
       z.[Cost (ZAR)],
       z.[Profit (ZAR)],
	   IIF(z.[Current sales (ZAR)]='0',0,CONVERT(DECIMAL,z.[Profit (ZAR)])/CONVERT(DECIMAL,z.[Current sales (ZAR)])) AS [Profit %]
       --z.[Profit %] 
	   FROM 
(select EstablishmentName,CapturedDate,ReferenceNo,Status,UserName,CustomerName,CustomerMobile,CustomerEmail,
[Area],
REPLACE(REPLACE([Actual budget],',','.'),CHAR(32),'') AS [Actual budget],
ISNULL(IIF([Date of budget]='',p.CapturedDate,p.[Date of budget]),p.CapturedDate) AS [Date of budget],
REPLACE(REPLACE([Current sales (ZAR)],',','.'),CHAR(32),'') AS [Current sales (ZAR)],
[Percentage of budget %],
REPLACE(REPLACE([Cost (ZAR)],',','.'),CHAR(32),'') AS [Cost (ZAR)],
REPLACE(REPLACE([Profit (ZAR)],',','.'),CHAR(32),'') AS [Profit (ZAR)],
[Profit %]
from (
select
E.EstablishmentName,cast(dateadd(MINUTE,AM.TimeOffSet,AM.CreatedOn) as date) as CapturedDate,AM.id as ReferenceNo,
AM.IsResolved as Status,
A.Detail as Answer
,Q.Questiontitle as Question,u.name as UserName,
(SELECT TOP 1 cd.Detail FROM ContactDetails CD WHERE   CD.ContactMasterId=(case when AM.IsSubmittedForGroup=1 then SAC.ContactMasterId  else AM.ContactMasterId end) and CD.IsDeleted = 0 and CD.Detail<>'' 
and CD.contactQuestionId=3060
) as CustomerEmail,
(SELECT TOP 1 cd.Detail FROM ContactDetails CD WHERE   CD.ContactMasterId=(case when AM.IsSubmittedForGroup=1 then SAC.ContactMasterId  else AM.ContactMasterId end) and CD.IsDeleted = 0 and CD.Detail<>'' 
and CD.contactQuestionId=3059
) as CustomerMobile,
(SELECT TOP 1 cd.Detail FROM ContactDetails CD WHERE   CD.ContactMasterId=(case when AM.IsSubmittedForGroup=1 then SAC.ContactMasterId  else AM.ContactMasterId end) and CD.IsDeleted = 0 and CD.Detail<>'' 
and CD.contactQuestionId=3057
)+' '+
(SELECT TOP 1 cd.Detail FROM ContactDetails CD WHERE   CD.ContactMasterId=(case when AM.IsSubmittedForGroup=1 then SAC.ContactMasterId  else AM.ContactMasterId end) and CD.IsDeleted = 0 and CD.Detail<>'' 
and CD.contactQuestionId=3058
) as CustomerName
from dbo.[Group] G
inner join EstablishmentGroup EG on G.id=EG.groupid and g.id = 505 and eg.id=5371 
inner join Establishment E on  E.EstablishmentGroupId=EG.Id 
inner join SeenClientAnswerMaster AM on AM.EstablishmentId=E.id ANd (AM.IsDeleted=0 or AM.IsDeleted=null)
inner join [SeenClientAnswers] A on A.SeenclientAnswerMasterId=AM.id 
inner join SeenClientQuestions Q on Q.id=A.QuestionId and q.id in (44855,43066,43067,43068,43069,43070,43071,46764,70250,83703)
left outer join dbo.[Appuser] u on u.id=AM.CreatedBy
left outer join SeenClientAnswerChild SAC on AM.id=SAC.SeenClientAnswerMasterId
)s
pivot(
Max(Answer)
For  Question In (
[Area],[Actual budget],[Date of budget],[Current sales (ZAR)],[Percentage of budget %],[Cost (ZAR)],[Profit (ZAR)],[Profit %]
))p
WHERE p.CustomerName IS NOT NULL AND p.CustomerName<>'Keagan Mitchell'
)z

