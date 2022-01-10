CREATE VIEW [dbo].[PB_VW_WorkForceStaffing_Fact_MonthlyPlan]
AS



WITH cte AS(

SELECT X.*,Y.ResponseDate,
Y.[Month] AS ResposneMonth,
[Getting Business],
[Client Engagement],
[Leads],
[Appointments],
[Quotes Submitted],
[Closed Deals],
Y.[Revenue] AS ResponseRevenue,
[Achieve Targets ],
[Please explain]

FROM(

SELECT 
EstablishmentName,CapturedDate,ReferenceNo,Status,RepeatCount,
UserName,[User],
[Month],
[Cold Calling],
[Getting Referrals],
[Getting leads from the company],
[Setting up appointments],
[Understanding client needs],
[Explaining the value proposition],
[Handling objections],
[Knowledge of group service offering],
[Passing Leads],
[Knowledge of T&Ci (Credit App)],
[Knowledge of T&Ci (Vetting Process)],
[Knowledge of bargaining councils/industry],
[Completing a costing template],
[Onboarding Efficiency],
[You vs Competition],
[How do you feel in general about deals lost?],
[Your issues addressed?],
[Getting on top of adhoc tasks],
[Planned Appointments],
[Quotes to be Submitted],
[Close Deals],
[Revenue],
[Product Knowledge],
[Confidence],
[Planning],
[Presentation Material],
[Training],
[Category],
[Planned Deadline],[Task],
[Meeting budget commitments]
FROM(
SELECT
E.EstablishmentName,DATEADD(MINUTE,AM.TimeOffSet,AM.CreatedOn) AS CapturedDate,AM.id AS ReferenceNo,
CASE WHEN A.Detail='High Risk' THEN '   High Risk' 
WHEN A.Detail='Looking Good' THEN ' Looking Good' 
WHEN A.Detail='Ok' THEN '  Ok' 
WHEN A.Detail='Concerned' THEN ' Concerned' 
ELSE A.Detail END AS Answer,AM.Isresolved AS Status,A.RepeatCount

,Q.QuestionTitle AS Question , u.name AS UserName,u.UserName AS [User]

FROM dbo.[Group] G
INNER JOIN EstablishmentGroup EG ON G.id=EG.groupid AND G.Id=494 AND EG.Id =4871
INNER JOIN Establishment E ON  E.EstablishmentGroupId=EG.Id --and E.id in (27195,27196,27200,27199)
INNER JOIN SeenClientAnswerMaster AM ON AM.EstablishmentId=E.id AND (AM.IsDeleted=0 OR AM.IsDeleted=NULL)
INNER JOIN [SeenClientAnswers] A ON A.SeenclientAnswerMasterId=AM.id
INNER JOIN SeenClientQuestions Q ON Q.id=A.QuestionId AND  Q.id IN (37472,37484,37485,37486,37489,37490,37491,37492,37495,37496,37500,37501,37502,37503,37504,37508,
37509,37512,37515,37540,37541,37542,37543,37521,37522,37523,37526,37527,37536,37538,37518,37537)
LEFT OUTER JOIN dbo.[Appuser] u ON u.id=AM.CreatedBy
)S
PIVOT(
MAX(Answer)
FOR  Question IN (
[Month],
[Cold Calling],
[Getting Referrals],
[Getting leads from the company],
[Setting up appointments],
[Understanding client needs],
[Explaining the value proposition],
[Handling objections],
[Knowledge of group service offering],
[Passing Leads],
[Knowledge of T&Ci (Credit App)],
[Knowledge of T&Ci (Vetting Process)],
[Knowledge of bargaining councils/industry],
[Completing a costing template],
[Onboarding Efficiency],
[You vs Competition],
[How do you feel in general about deals lost?],
[Your issues addressed?],
[Getting on top of adhoc tasks],
[Planned Appointments],
[Quotes to be Submitted],
[Close Deals],
[Revenue],
[Product Knowledge],
[Confidence],
[Planning],
[Presentation Material],
[Training],
[Category],
[Planned Deadline],
[Task],
[Meeting budget commitments]
))P
) X
LEFT OUTER JOIN

(
SELECT 
EstablishmentName,ResponseDate,ReferenceNo,SeenClientAnswerMasterId,
[Month],
[Getting Business],
[Client Engagement],
[Leads],
[Appointments],
[Quotes Submitted],
[Closed Deals],
[Revenue],
[Achieve Targets ],
[Please explain]
FROM(
SELECT
E.EstablishmentName,DATEADD(MINUTE,AM.TimeOffSet,AM.CreatedOn) AS ResponseDate,AM.id AS ReferenceNo,
AM.SeenClientAnswerMasterId,
A.Detail AS Answer,

Q.shortname AS Question 
FROM dbo.[Group] G
INNER JOIN EstablishmentGroup EG ON G.id=EG.groupid AND G.Id=494 AND EG.Id =4871
INNER JOIN Establishment E ON  E.EstablishmentGroupId=EG.Id --and E.id in (27195,27196,27200,27199)
INNER JOIN AnswerMaster AM ON AM.EstablishmentId=E.id AND (AM.IsDeleted=0 OR AM.IsDeleted=NULL)
INNER JOIN [Answers] A ON A.AnswerMasterId=AM.id
INNER JOIN Questions Q ON Q.id=A.QuestionId AND  Q.id IN (25128,24144,24145,24146,24179,24180,24181,24182,25130,25131)
)S
PIVOT(
MAX(Answer)
FOR  Question IN (
[Month],
[Getting Business],
[Client Engagement],
[Leads],
[Appointments],
[Quotes Submitted],
[Closed Deals],
[Revenue],
[Achieve Targets ],
[Please explain]
))P
) Y ON X.ReferenceNo=Y.SeenclientAnswerMasterid

)

SELECT 
B.EstablishmentName,B.CapturedDate,B.ReferenceNo,B.Status,A.RepeatCount,
B.UserName,B.[User],
B.[Month],
B.[Cold Calling],
B.[Getting Referrals],
B.[Getting leads from the company],
B.[Setting up appointments],
B.[Understanding client needs],
B.[Explaining the value proposition],
B.[Handling objections],
B.[Knowledge of group service offering],
B.[Passing Leads],
B.[Knowledge of T&Ci (Credit App)],
B.[Knowledge of T&Ci (Vetting Process)],
B.[Knowledge of bargaining councils/industry],
B.[Completing a costing template],
B.[Onboarding Efficiency],
B.[You vs Competition],
B.[How do you feel in general about deals lost?],
B.[Your issues addressed?],
B.[Getting on top of adhoc tasks],
B.[Planned Appointments],
B.[Quotes to be Submitted],
B.[Close Deals],
B.[Revenue],
B.[Product Knowledge],
B.[Confidence],
B.[Planning],
B.[Presentation Material],
B.[Training],
A.[Category],
A.[Planned Deadline],A.[Task],
B.[Meeting budget commitments],
B.ResponseDate,
B.ResposneMonth,
B.[Getting Business],
B.[Client Engagement],
B.[Leads],
B.[Appointments],
B.[Quotes Submitted],
B.[Closed Deals],
B.ResponseRevenue,
B.[Achieve Targets ],
B.[Please explain]
 FROM

(SELECT * FROM cte WHERE repeatcount=0) B LEFT OUTER JOIN (SELECT * FROM cte WHERE repeatcount<>0) A
ON A.ReferenceNo=B.ReferenceNo


