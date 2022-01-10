CREATE VIEW [dbo].[PB_VW_WorkForceStaffing_Fact_Quotes]
AS





SELECT X.*,Y.ResponseDate,Y.ReferenceNo AS ResponseRef,
Y.[Status] AS ResponseStatus,
[Purchase Order Number],
[Documentation Sign],
[Outstanding],
[Price (ZAR)],
[Reason for requote],
[Why you re-quoted],
[lost sale],
[wrong with the pri],
[complaint type],
[What other reasons],
[competitors?],
[met requirement ?],
[got the deal?],
[Monthly revenue],
[Start],
[End],
[Total revenue],
[GP (%)],
[PO number],
[Expected Month Rev],
[Expected GP%],
[Duration],
[Estimate Headcount],
[Project Duration],
Y.[Total Sale Value] AS [Response Total Sale Value],
CASE WHEN Y.Status='Update' THEN 2 WHEN Y.Status='Quote Sent' THEN 3 WHEN Y.Status='Acceptance of Quote' THEN 4 
WHEN Y.Status='Order Confirmation' THEN 5
WHEN Y.Status='Re-Quote' THEN 6 WHEN Y.Status='Deal Made' THEN 7 WHEN Y.Status='Update' THEN 1 WHEN Y.Status='Lost deal' THEN 8 END AS StatusSort
,0 AS Dummyrow FROM(

SELECT 
EstablishmentName,CapturedDate,ReferenceNo,Status,
UserName,[User],
[Is this a new or existing client?],
[Did this come of a prospect engagement, courtesy call or cold call?],
[Industry],
[Company Name]AS[Company],
[Company Size],

[Company registration number from quote],
[Contract Type],
[If Bargaining Council, Please select below],
[Expected Monthly Revenue],
[Expected GP (%)],
[Order or Project Duration (Months)],
[Total Sale Value],
[Are we facing competition?]
FROM(
SELECT
E.EstablishmentName,DATEADD(MINUTE,AM.TimeOffSet,AM.CreatedOn) AS CapturedDate,AM.id AS ReferenceNo,
A.Detail AS Answer,AM.Isresolved AS Status

,Q.QuestionTitle AS Question , u.name AS UserName,u.UserName AS [User]

FROM dbo.[Group] G
INNER JOIN EstablishmentGroup EG ON G.id=EG.groupid AND G.Id=494 AND EG.Id =5129
INNER JOIN Establishment E ON  E.EstablishmentGroupId=EG.Id --and E.id in (27195,27196,27200,27199)
LEFT OUTER JOIN SeenClientAnswerMaster AM ON AM.EstablishmentId=E.id AND (AM.IsDeleted=0 OR AM.IsDeleted=NULL)
LEFT OUTER JOIN [SeenClientAnswers] A ON A.SeenclientAnswerMasterId=AM.id
LEFT OUTER JOIN SeenClientQuestions Q ON Q.id=A.QuestionId AND  Q.id IN 
(40465,40466,40462,40467,44235,44236,40470,40471,46640,46641,40472,
 54125,54019,54126,69255)
LEFT OUTER JOIN dbo.[Appuser] u ON u.id=AM.CreatedBy
)S
PIVOT(
MAX(Answer)
FOR  Question IN (
[Is this a new or existing client?],
[Did this come of a prospect engagement, courtesy call or cold call?],
[Industry],
[Company Name],
[Company Size],
[Company registration number from quote],
[Contract Type],
[If Bargaining Council, Please select below],
[Expected Monthly Revenue],
[Expected GP (%)],
[Order or Project Duration (Months)],
[Total Sale Value],
[Are we facing competition?]
))P
) X
LEFT OUTER JOIN

(
SELECT 
EstablishmentName,ResponseDate,ReferenceNo,SeenClientAnswerMasterId,
[Status],
[Purchase Order Number],
[Documentation Sign],
[Outstanding],
[Price (ZAR)],
[Reason for requote],
[Why you re-quoted],
[lost sale],
[wrong with the pri],
[complaint type],
[What other reasons],
[competitors?],
[met requirement ?],
[got the deal?],
[Monthly revenue],
[Start],
[End],
[Total revenue],
[GP (%)],
[PO number],
[Expected Month Rev],
[Expected GP%],
[Duration],
[Estimate Headcount],
[Project Duration],
[Total Sale Value]
FROM(
SELECT
E.EstablishmentName,DATEADD(MINUTE,AM.TimeOffSet,AM.CreatedOn) AS ResponseDate,AM.id AS ReferenceNo,
AM.SeenClientAnswerMasterId,
A.Detail AS Answer,

Q.shortname AS Question 
FROM dbo.[Group] G
INNER JOIN EstablishmentGroup EG ON G.id=EG.groupid AND G.Id=494 AND EG.Id =5129
INNER JOIN Establishment E ON  E.EstablishmentGroupId=EG.Id --and E.id in (27195,27196,27200,27199)
INNER JOIN AnswerMaster AM ON AM.EstablishmentId=E.id AND (AM.IsDeleted=0 OR AM.IsDeleted=NULL)
INNER JOIN [Answers] A ON A.AnswerMasterId=AM.id
INNER JOIN Questions Q ON Q.id=A.QuestionId AND  Q.id IN (29312,29319,26803,26804,26806,26807,26808,26809,26810,26811,26812,26813,26814,26815,26816,
26818,26819,26820,26821,26822,29313,29314,29315,29316,29317,29318)
)S
PIVOT(
MAX(Answer)
FOR  Question IN (
[Status],
[Purchase Order Number],
[Documentation Sign],
[Outstanding],
[Price (ZAR)],
[Reason for requote],
[Why you re-quoted],
[lost sale],
[wrong with the pri],
[complaint type],
[What other reasons],
[competitors?],
[met requirement ?],
[got the deal?],
[Monthly revenue],
[Start],
[End],
[Total revenue],
[GP (%)],
[PO number],
[Expected Month Rev],
[Expected GP%],
[Duration],
[Estimate Headcount],
[Project Duration],
[Total Sale Value]
))P
) Y ON X.ReferenceNo=Y.SeenclientAnswerMasterid
UNION ALL
SELECT 
EstablishmentName,CapturedDate,ReferenceNo,Status,
UserName,[User],
[Is this a new or existing client?],
[Did this come of a prospect engagement, courtesy call or cold call?],
[Industry],
[Company Name]AS[Company],
[Company Size],
[Company registration number from quote],
[Contract Type],
[If Bargaining Council, Please select below],
[Expected Monthly Revenue],
[Expected GP (%)],
[Order or Project Duration (Months)],
[Total Sale Value],
[Are we facing competition?],
NULL AS ResponseDate,
NULL AS ResponseRef,
'Captured' AS ResponseStatus,
''AS [Purchase Order Number],
'' AS [Documentation Sign],
'' AS [Outstanding],
'' AS [Price (ZAR)],
'' AS [Reason for requote],
'' AS [Why you re-quoted],
'' AS [lost sale],
'' AS [wrong with the pri],
'' AS [complaint type],
'' AS [What other reasons],
'' AS [competitors?],
'' AS [met requirement ?],
'' AS [got the deal?],
'' AS [Monthly revenue],
'' AS [Start],
'' AS [End],
'' AS [Total revenue],
'' AS [GP (%)],
'' AS [PO number],
'' AS [Expected Month Rev],
'' AS [Expected GP%],
'' AS [Duration],
'' AS [Estimate Headcount],
'' AS [Project Duration],
'' AS [Response Total Sale Value],
1 AS StatusSort,
1 AS DummyRow
FROM(
SELECT
E.EstablishmentName,DATEADD(MINUTE,AM.TimeOffSet,AM.CreatedOn) AS CapturedDate,AM.id AS ReferenceNo,
A.Detail AS Answer,AM.Isresolved AS Status

,Q.QuestionTitle AS Question , u.name AS UserName,u.UserName AS [User]

FROM dbo.[Group] G
INNER JOIN EstablishmentGroup EG ON G.id=EG.groupid AND G.Id=494 AND EG.Id =5129
INNER JOIN Establishment E ON  E.EstablishmentGroupId=EG.Id --and E.id in (27195,27196,27200,27199)
INNER JOIN SeenClientAnswerMaster AM ON AM.EstablishmentId=E.id AND (AM.IsDeleted=0 OR AM.IsDeleted=NULL)
INNER JOIN [SeenClientAnswers] A ON A.SeenclientAnswerMasterId=AM.id
INNER JOIN SeenClientQuestions Q ON Q.id=A.QuestionId AND  Q.id IN (40465,40466,40462,40467,44235,44236,40470,40471,46640,46641,40472,54125,54019,54126)
LEFT OUTER JOIN dbo.[Appuser] u ON u.id=AM.CreatedBy
)S
PIVOT(
MAX(Answer)
FOR  Question IN (
[Is this a new or existing client?],
[Did this come of a prospect engagement, courtesy call or cold call?],
[Industry],
[Company Name],
[Company Size],
[Company registration number from quote],
[Contract Type],
[If Bargaining Council, Please select below],
[Expected Monthly Revenue],
[Expected GP (%)],
[Order or Project Duration (Months)],
[Total Sale Value],
[Are we facing competition?]
))P


