CREATE VIEW PB_VW_Toyota_FinanceRentalPack AS

SELECT AA.CapturedDate,
       AA.[Capture Date],
       AA.ReferenceNo,
       AA.IsResolved,
       AA.StatusName,
       AA.UserName,
       AA.[Company Name],
       AA.[Indent Number],
       AA.[Model - as per CRM],
	   AA.[Start],
	   AA.[End],
       AA.[Monthly Hours],
       AA.[RV %],
	   AA.[Average GP%],
	   AA.[Sales administrator],
	   AA.[Rental administrator],
       AA.[Sales Representative],
       AA.[Costing Sheet],
       AA.[Site Inspection],
       AA.[Sales Order],
       AA.[Hire Agreement],
       AA.[T&C's],
       AA.POD,
       AA.[VSB (ERP)],
       AA.[LMI (Load Test Certificate)],
	   AA.[9) Other documents],
       AA.Comments,
       BB.ResponseDate,
       BB.ReferenceNo AS Refno,
       BB.UserName AS Respondent,
       BB.[Is the documentation attached up to standard?],
       BB.[What is not up to standard?],
       BB.[Finance checklist],
       BB.[GP Amount],
       BB.[CF Sheet],
       BB.Quote,
	   BB.[Other Documents],
       BB.[Hire Agreement Completed & Signed],
       BB.[Amortisation - GP approved by relevant authority],
       BB.[S-order signed by Rental, Sales, Maintenance & General Manager],
       BB.[VSB Profit & Loss - Zero VAT On Invoice],
       BB.[Terms & Conditions],
       BB.[Res POD],
       BB.[Costing Sheet Signed & Approved By Relevant Authority],
       BB.[Res Site Inspection],
       BB.[Valid load test certificate],
       BB.[Correct fiance parameters],
       BB.[Correct branch location],
       BB.[Correct contract type],
       BB.[Escalations if applicable],
       BB.[Check customer account number],
       BB.[Correct Delivery & Start Dates],
       BB.[Have you checked all?],
       BB.Comments AS response_comm, 
	   CASE WHEN AA.StatusName='Sales Documents Reviewed' THEN 1
	        WHEN AA.StatusName='Reviewing waiting approval' THEN 2
	        WHEN AA.StatusName='Awaiting signature' THEN 3
	        WHEN AA.StatusName='Awaiting legal' THEN 4
	        WHEN AA.StatusName='Awaiting GP approval' THEN 5
	        WHEN AA.StatusName='Awaiting customer' THEN 6
	        WHEN AA.StatusName='Phase 1 completed' THEN 7
	        ELSE 8
			END AS sortorder
	   FROM 
(SELECT EstablishmentName,CapturedDate,CAST(CapturedDate AS DATE) AS [Capture Date],ReferenceNo,IsResolved,StatusName,UserName,
[Customer Name (Please note when typing in this field, press enter to lock in your option)] AS [Company Name],[Indent Number],[Model - as per CRM],[Start],[End],[Monthly Hours],[RV %],[Average GP%],[Sales administrator],[Rental administrator],[Sales Representative],
IIF(p.[1) Costing Sheet] IS NULL,'N/A',CONCAT('https://webapi.magnitudefb.com/MGUploadData/SeenClient/',[1) Costing Sheet])) AS [Costing Sheet],
IIF(p.[2) Site Inspection] IS NULL,'N/A',CONCAT('https://webapi.magnitudefb.com/MGUploadData/SeenClient/',[2) Site Inspection])) AS [Site Inspection],
IIF(p.[3) Sales Order] IS NULL,'N/A',CONCAT('https://webapi.magnitudefb.com/MGUploadData/SeenClient/',[3) Sales Order])) AS [Sales Order],
IIF(p.[4) Hire Agreement] IS NULL,'N/A',CONCAT('https://webapi.magnitudefb.com/MGUploadData/SeenClient/',[4) Hire Agreement])) AS [Hire Agreement],
IIF(p.[5) Terms & Conditions] IS NULL,'N/A',CONCAT('https://webapi.magnitudefb.com/MGUploadData/SeenClient/',[5) Terms & Conditions])) AS [T&C's],
IIF(p.[6) POD] IS NULL,'N/A',CONCAT('https://webapi.magnitudefb.com/MGUploadData/SeenClient/',[6) POD])) AS [POD],
IIF(p.[7) VSB] IS NULL,'N/A',CONCAT('https://webapi.magnitudefb.com/MGUploadData/SeenClient/',[7) VSB])) AS [VSB (ERP)],
IIF(p.[8) LMI (Load Test Certificate)] IS NULL,'N/A',CONCAT('https://webapi.magnitudefb.com/MGUploadData/SeenClient/',[8) LMI (Load Test Certificate)])) AS [LMI (Load Test Certificate)],
IIF(p.[9) Other documents] IS NULL OR p.[9) Other documents]='','N/A',CONCAT('https://webapi.magnitudefb.com/MGUploadData/SeenClient/',[9) Other documents])) AS [9) Other documents],
[Comments]
from (
select
E.EstablishmentName,cast(dateadd(MINUTE,AM.TimeOffSet,AM.CreatedOn) as DATETIME) as CapturedDate,AM.id as ReferenceNo,
AM.IsResolved ,es.StatusName,A.Detail as Answer,u.name as UserName,
CASE WHEN Q.Id=72964 THEN 'Model - as per CRM' ELSE Q.QuestionTitle END AS Question
from dbo.[Group] G
inner join EstablishmentGroup EG on G.id=EG.groupid and g.id = 509 and eg.id=5439 
inner join Establishment E on  E.EstablishmentGroupId=EG.Id 
inner join SeenClientAnswerMaster AM on AM.EstablishmentId=E.id ANd (AM.IsDeleted=0 or AM.IsDeleted=null)
LEFT JOIN dbo.StatusHistory sh ON sh.Id=AM.StatusHistoryId
LEFT JOIN dbo.EstablishmentStatus es ON es.Id=sh.EstablishmentStatusId
inner join [SeenClientAnswers] A on A.SeenclientAnswerMasterId=AM.id 
inner join SeenClientQuestions Q on Q.id=A.QuestionId and Q.Id IN (44160,44161,44162,44163,44801,44165,44168,44169,44170,44171,44172,44173,44174,44175,44176,72964,69538,69539,69540,69541,69542,78575)
left outer join dbo.[Appuser] u on u.id=AM.CreatedBy
left outer join SeenClientAnswerChild SAC on AM.id=SAC.SeenClientAnswerMasterId 
)s
pivot(
Max(Answer)
For  Question In (
[Customer Name (Please note when typing in this field, press enter to lock in your option)],[Indent Number],[Model - as per CRM],[Start],[End],[Monthly Hours],[RV %],[Average GP%],[Sales administrator],[Rental administrator],[Sales Representative],[1) Costing Sheet],[2) Site Inspection],[3) Sales Order],[4) Hire Agreement],[5) Terms & Conditions],[6) POD],[7) VSB],[8) LMI (Load Test Certificate)],[9) Other documents],[Comments]
))p
)AA

LEFT JOIN

(select EstablishmentName,CapturedDate,ResponseDate,SeenClientAnswerMasterId,ReferenceNo,UserName,
[Is the documentation attached up to standard?],[What is not up to standard?],
IIF([1) Finance checklist] IS NULL,'N/A',CONCAT('https://webapi.magnitudefb.com/MGUploadData/Feedback/',[1) Finance checklist])) AS [Finance checklist],
IIF([2) GP Amort] IS NULL,'N/A',CONCAT('https://webapi.magnitudefb.com/MGUploadData/Feedback/',[2) GP Amort])) AS [GP Amount],
IIF([3) CF sheet] IS NULL,'N/A',CONCAT('https://webapi.magnitudefb.com/MGUploadData/Feedback/',[3) CF sheet])) AS [CF Sheet],
IIF([4) Quote] IS NULL,'N/A',CONCAT('https://webapi.magnitudefb.com/MGUploadData/Feedback/',[4) Quote])) AS [Quote],
IIF([5) Other Documents] IS NULL,'N/A',CONCAT('https://webapi.magnitudefb.com/MGUploadData/Feedback/',[5) Other Documents])) AS [Other Documents],
[Hire Agreement Completed & Signed],[Amortisation - GP approved by relevant authority],[S-order signed by Rental, Sales, Maintenance & General Manager],[VSB Profit & Loss - Zero VAT On Invoice],[Terms & Conditions],[POD] AS [Res POD],[Costing Sheet Signed & Approved By Relevant Authority],[Site Inspection] AS [Res Site Inspection],[Valid load test certificate],[Correct fiance parameters],[Correct branch location],[Correct contract type],[Escalations if applicable],[Check customer account number],[Correct Delivery & Start Dates],[Have you checked all?],[Comments]
from (
select
E.EstablishmentName,cast(dateadd(MINUTE,cam.TimeOffSet,cam.CreatedOn) as date) as CapturedDate,dateadd(MINUTE,am.TimeOffSet,am.CreatedOn) as ResponseDate,am.id as ReferenceNo,cam.Id as SeenClientAnswerMasterId,
a.Detail as Answer,q.QuestionTitle as Question,u.name as UserName 
from dbo.[Group] g
inner join EstablishmentGroup eg on g.id=eg.groupid and g.id = 509 and eg.id=5439 
inner join Establishment e on  e.EstablishmentGroupId=eg.Id 
inner join answermaster am on am.EstablishmentId=e.id and (am.IsDeleted=0 or am.IsDeleted=null)
inner join Answers a on a.AnswerMasterId=am.id 
inner join Questions q on q.id=a.QuestionId and q.Id IN(29255,29256,29258,29259,29260,29261,29263,29712,29265,29266,29267,29268,29269,29270,29271,29272,29273,29274,29275,29276,29277,29279,29278,62459)
left outer join dbo.[Appuser] u on u.id=am.CreatedBy
left join SeenClientAnswerMaster cam on cam.Id=am.SeenClientAnswerMasterId and (cam.IsDeleted=0 or cam.IsDeleted=null)
left outer join SeenClientAnswerChild SAC on cam.id=SAC.SeenClientAnswerMasterId
) s
pivot(
Max(Answer)
For  Question In (
[Is the documentation attached up to standard?],[What is not up to standard?],[1) Finance checklist],[2) GP Amort],[3) CF sheet],[4) Quote],[5) Other Documents],[Hire Agreement Completed & Signed],[Amortisation - GP approved by relevant authority],[S-order signed by Rental, Sales, Maintenance & General Manager],[VSB Profit & Loss - Zero VAT On Invoice],[Terms & Conditions],[POD],[Costing Sheet Signed & Approved By Relevant Authority],[Site Inspection],[Valid load test certificate],[Correct fiance parameters],[Correct branch location],[Correct contract type],[Escalations if applicable],[Check customer account number],[Correct Delivery & Start Dates],[Have you checked all?],[Comments]
))P
)BB ON AA.ReferenceNo=BB.SeenClientAnswerMasterId WHERE AA.UserName NOT LIKE '%admin%'

