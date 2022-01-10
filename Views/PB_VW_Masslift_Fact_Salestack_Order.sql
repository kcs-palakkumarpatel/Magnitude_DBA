Create view PB_VW_Masslift_Fact_Salestack_Order
as
Select Year,Month,[Order Intake by Truck Type],[Target],Count From Masslift_SalesStack_Order

union all


SELECT Year,Month,[ORDER INTAKE BY TR] as [Order Intake by Truck Type],CASE WHEN [P].[ORDER INTAKE BY TR]='IC' THEN 475 WHEN P.[ORDER INTAKE BY TR]='CB ELECTRIC' THEN 75
WHEN P.[ORDER INTAKE BY TR]='WHE' THEN 50 WHEN P.[ORDER INTAKE BY TR]='OTHER' THEN 10 ELSE 0 END AS[Target],COUNT(P.ReferenceNo) AS [Count]


FROM(
SELECT
E.EstablishmentName,YEAR(DATEADD(MINUTE,AM.TimeOffSet,AM.CreatedOn) )AS [Year],DATENAME(MONTH,DATEADD(MINUTE,AM.TimeOffSet,AM.CreatedOn)) AS [Month],MONTH(DATEADD(MINUTE,AM.TimeOffSet,AM.CreatedOn) ) AS [Mn],DATEADD(MINUTE,AM.TimeOffSet,AM.CreatedOn) AS CapturedDate,AM.id AS ReferenceNo,
AM.IsPositive,AM.IsResolved AS Status,AM.PI,
A.Detail AS 'ORDER INTAKE BY TR'
, U.Id AS UserId, u.name AS UserName,
AM.Longitude,AM.Latitude


FROM dbo.[Group] G
INNER JOIN EstablishmentGroup EG ON G.id=EG.groupid AND G.Id=463 AND EG.Id =3997
INNER JOIN Establishment E ON  E.EstablishmentGroupId=EG.Id
INNER JOIN SeenClientAnswerMaster AM ON AM.EstablishmentId=E.id AND (AM.IsDeleted=0 OR AM.IsDeleted=NULL) AND (AM.IsDisabled=0 OR AM.IsDisabled IS NULL) 
INNER JOIN [SeenClientAnswers] A ON A.SeenclientAnswerMasterId=AM.id
INNER JOIN SeenClientQuestions Q ON Q.id=A.QuestionId  and Q.id =64741
LEFT OUTER JOIN dbo.[Appuser] u ON u.id=AM.CreatedBy
LEFT OUTER JOIN ContactDetails CD ON CD.contactMasterid=AM.ContactMasterid AND CD.contactQuestionId=2843





) P

GROUP BY [Year],[Month],[ORDER INTAKE BY TR]
