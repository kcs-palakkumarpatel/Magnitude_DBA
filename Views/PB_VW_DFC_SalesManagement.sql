CREATE VIEW PB_VW_DFC_SalesManagement AS

WITH cte as
(SELECT CapturedDate,CAST(CapturedDate AS DATE) AS [Capture Date],ReferenceNo,IsResolved,UserName,p.RepeatCount,p.CustomerName,p.[Job Title],p.CompanyName,p.Email,p.Mobile,
[Customer Name],[How did the meeting come about?],[Meeting Type],[Who did you meet with?],[Purpose of the Meeting],[If this Meeting is with Channel Partner and End Customer, who is the End Customer],[If Objective was to resolve technical issues, please provide feedback on the issue and how this was resolved],[If Any, What issues were raised in the meeting by the Customer?],[If Issues Raised, what was discussed to resolve or mitigate against risk of losing business],[If Quality, and product is available, please take a photo of the quality issue],[If Product Quality, please provide a full description of the issue],[Do you require Management Involvement?],[If YES selected, tell us what assistance you anticipate from management?],[Who are the key competitors (please list in order of priority) or if NONE, then N/A],[Product Qualified (Use the ADD Tab to qualify multiple products)],[Quantity],[If Qualified please select which Sector this opportunity is for],[What is your commitment to this qualifier?],[Will you be placing this in Forecast or Pipeline],[If Qualified what month do you expect to convert this deal to closed],[If CLOSED can we meet the Delivery Date Requested (If NO do you require assistance with this?)],[If CLOSED, please upload Purchase Order (Can attach Mobile Photo)],[Is this Opportunity a form 72/74, If YES please select what the Requirements are],[Any other Comments Relevant to this Opportunity],[Are you assessing Target Tracking in this Meeting?],[Value of Deals Lost],[If LOST DEAL reported, provide reason why the opportunity was lost],[Will this Distributor Achieve their Quarterly Target as per the Agreement?],[If there is a Target Achievement Risk - Rate it!],[Atval Inventory Count],[Automatic Control Valve Inventory Count],[Insamcor Inventory Control Count],[Saunders Inventory Control Count],[SKG Inventory Control Count],[Vent-O-Mat Inventory Control Count],[Inventory Replenishment Required],[Estimate Value of Inventory Replenishment],[When will you receive the order for Inventory],[Have you advised your customer to place an order and have they agreed to this],[Is this forecasted or Pipeline]
from (
SELECT
cast(dateadd(MINUTE,AM.TimeOffSet,AM.CreatedOn) as DATETIME) as CapturedDate,AM.id as ReferenceNo,
AM.IsResolved,A.Detail as Answer,u.name as UserName,a.RepeatCount,
CASE WHEN q.id=26798 THEN 'Meeting Type' 
	 WHEN q.id=30763 THEN 'Meeting Type' 
	 WHEN q.id=26792 THEN 'Purpose of the Meeting' 
	 WHEN q.id=26939 THEN 'If there is a Target Achievement Risk - Rate it!' 
	 WHEN q.id=26821 THEN 'Is this forecasted or Pipeline' 
	 WHEN q.id=27435 THEN 'Is this forecasted or Pipeline' 
	 WHEN q.id=35534 THEN 'If LOST DEAL reported, provide reason why the opportunity was lost' ELSE Q.QuestionTitle END AS Question,
(SELECT TOP 1 cd.Detail FROM ContactDetails CD WHERE   CD.ContactMasterId=(case when AM.IsSubmittedForGroup=1 then SAC.ContactMasterId  else AM.ContactMasterId end) and CD.IsDeleted = 0 and CD.Detail<>'' 
and CD.contactQuestionId=2283
) as CompanyName,
(SELECT TOP 1 cd.Detail FROM ContactDetails CD WHERE   CD.ContactMasterId=(case when AM.IsSubmittedForGroup=1 then SAC.ContactMasterId  else AM.ContactMasterId end) and CD.IsDeleted = 0 and CD.Detail<>'' 
and CD.contactQuestionId=2291
) as [Job Title],
(SELECT TOP 1 cd.Detail FROM ContactDetails CD WHERE   CD.ContactMasterId=(case when AM.IsSubmittedForGroup=1 then SAC.ContactMasterId  else AM.ContactMasterId end) and CD.IsDeleted = 0 and CD.Detail<>'' 
and CD.contactQuestionId=2287
) as [Email],
(SELECT TOP 1 cd.Detail FROM ContactDetails CD WHERE   CD.ContactMasterId=(case when AM.IsSubmittedForGroup=1 then SAC.ContactMasterId  else AM.ContactMasterId end) and CD.IsDeleted = 0 and CD.Detail<>'' 
and CD.contactQuestionId=2286
) as [Mobile],
(SELECT TOP 1 cd.Detail FROM ContactDetails CD WHERE   CD.ContactMasterId=(case when AM.IsSubmittedForGroup=1 then SAC.ContactMasterId  else AM.ContactMasterId end) and CD.IsDeleted = 0 and CD.Detail<>'' 
and CD.contactQuestionId=2284
)+' '+
(SELECT TOP 1 cd.Detail FROM ContactDetails CD WHERE   CD.ContactMasterId=(case when AM.IsSubmittedForGroup=1 then SAC.ContactMasterId  else AM.ContactMasterId end) and CD.IsDeleted = 0 and CD.Detail<>'' 
and CD.contactQuestionId=2285
) as CustomerName
from dbo.[Group] G
inner join EstablishmentGroup EG on G.id=EG.groupid and g.id = 366 and eg.id=3547 
inner join Establishment E on  E.EstablishmentGroupId=EG.Id 
inner join SeenClientAnswerMaster AM on AM.EstablishmentId=E.id ANd (AM.IsDeleted=0 or AM.IsDeleted=null)
inner join [SeenClientAnswers] A on A.SeenclientAnswerMasterId=AM.id 
inner join SeenClientQuestions Q on Q.id=A.QuestionId and Q.Id IN (35566,26795,35527,35528,35526,35530,26797,26799,26801,26802,26803,26804,26805,26806,35531,35532,28378,26808,26810,26825,26827,26828,26829,26831,30762,35522,35524,26938,35542,35529,35535,35536,35537,70623,26940,26941,26944,26945,26946,26947,26793,26798,30763,26792,26939,26821,27435,35534)
left outer join dbo.[Appuser] u on u.id=AM.CreatedBy
left outer join SeenClientAnswerChild SAC on AM.id=SAC.SeenClientAnswerMasterId
)s
pivot(
Max(Answer)
For  Question In (
[Customer Name],[How did the meeting come about?],[Meeting Type],[Who did you meet with?],[Purpose of the Meeting],[If this Meeting is with Channel Partner and End Customer, who is the End Customer],[If Objective was to resolve technical issues, please provide feedback on the issue and how this was resolved],[If Any, What issues were raised in the meeting by the Customer?],[If Issues Raised, what was discussed to resolve or mitigate against risk of losing business],[If Quality, and product is available, please take a photo of the quality issue],[If Product Quality, please provide a full description of the issue],[Do you require Management Involvement?],[If YES selected, tell us what assistance you anticipate from management?],[Who are the key competitors (please list in order of priority) or if NONE, then N/A],[Will you be placing this in Forecast or Pipeline],[If Qualified what month do you expect to convert this deal to closed],[If Qualified please select which Sector this opportunity is for],[Product Qualified (Use the ADD Tab to qualify multiple products)],[Quantity],[What is your commitment to this qualifier?],[If CLOSED can we meet the Delivery Date Requested (If NO do you require assistance with this?)],[If CLOSED, please upload Purchase Order (Can attach Mobile Photo)],[Is this Opportunity a form 72/74, If YES please select what the Requirements are],[Any other Comments Relevant to this Opportunity],[If there is a Target Achievement Risk - Rate it!],[Are you assessing Target Tracking in this Meeting?],[Value of Deals Lost],[Will this Distributor Achieve their Quarterly Target as per the Agreement?],[If LOST DEAL reported, provide reason why the opportunity was lost],[Inventory Replenishment Required],[Estimate Value of Inventory Replenishment],[When will you receive the order for Inventory],[Have you advised your customer to place an order and have they agreed to this],[Is this forecasted or Pipeline],[Atval Inventory Count],[Automatic Control Valve Inventory Count],[Insamcor Inventory Control Count],[Saunders Inventory Control Count],[SKG Inventory Control Count],[Vent-O-Mat Inventory Control Count]
))p
)
SELECT B.CapturedDate,
       B.[Capture Date],
       B.ReferenceNo,
       B.IsResolved,
       B.UserName,
       A.RepeatCount,
       B.CustomerName,
       B.[Job Title],
       B.CompanyName,
       B.Email,
       B.Mobile,
       B.[Customer Name],
       B.[How did the meeting come about?],
       B.[Meeting Type],
       B.[Who did you meet with?],
       B.[Purpose of the Meeting],
       B.[If this Meeting is with Channel Partner and End Customer, who is the End Customer],
       B.[If Objective was to resolve technical issues, please provide feedback on the issue and how this was resolved],
       B.[If Any, What issues were raised in the meeting by the Customer?],
       B.[If Issues Raised, what was discussed to resolve or mitigate against risk of losing business],
       B.[If Quality, and product is available, please take a photo of the quality issue],
       B.[If Product Quality, please provide a full description of the issue],
       B.[Do you require Management Involvement?],
       B.[If YES selected, tell us what assistance you anticipate from management?],
       B.[Who are the key competitors (please list in order of priority) or if NONE, then N/A],
       A.[Product Qualified (Use the ADD Tab to qualify multiple products)],
       A.Quantity,
       A.[If Qualified please select which Sector this opportunity is for],
       A.[What is your commitment to this qualifier?],
       IIF(A.[Will you be placing this in Forecast or Pipeline] LIKE '%,%',SUBSTRING(A.[Will you be placing this in Forecast or Pipeline],1,CHARINDEX(',',A.[Will you be placing this in Forecast or Pipeline])-1),A.[Will you be placing this in Forecast or Pipeline]) AS [Will you be placing this in Forecast or Pipeline],
	   IIF(A.[Will you be placing this in Forecast or Pipeline] LIKE '%,%',SUBSTRING(A.[Will you be placing this in Forecast or Pipeline],CHARINDEX(',',A.[Will you be placing this in Forecast or Pipeline])+1,LEN(A.[Will you be placing this in Forecast or Pipeline])),'') AS Comment,
       A.[If Qualified what month do you expect to convert this deal to closed],
       IIF(A.[If CLOSED can we meet the Delivery Date Requested (If NO do you require assistance with this?)] LIKE '%,%',SUBSTRING(A.[If CLOSED can we meet the Delivery Date Requested (If NO do you require assistance with this?)],1,CHARINDEX(',',A.[If CLOSED can we meet the Delivery Date Requested (If NO do you require assistance with this?)])-1),A.[If CLOSED can we meet the Delivery Date Requested (If NO do you require assistance with this?)]) AS [If CLOSED can we meet the Delivery Date Requested (If NO do you require assistance with this?)],
	   IIF(A.[If CLOSED can we meet the Delivery Date Requested (If NO do you require assistance with this?)] LIKE '%,%',SUBSTRING(A.[If CLOSED can we meet the Delivery Date Requested (If NO do you require assistance with this?)],CHARINDEX(',',A.[If CLOSED can we meet the Delivery Date Requested (If NO do you require assistance with this?)])+1,LEN(A.[If CLOSED can we meet the Delivery Date Requested (If NO do you require assistance with this?)])),'') AS Comment1,
       A.[If CLOSED, please upload Purchase Order (Can attach Mobile Photo)],
       A.[Is this Opportunity a form 72/74, If YES please select what the Requirements are],
       A.[Any other Comments Relevant to this Opportunity],
       A.[Are you assessing Target Tracking in this Meeting?],
       A.[Value of Deals Lost],
       A.[If LOST DEAL reported, provide reason why the opportunity was lost],
       IIF(A.[Will this Distributor Achieve their Quarterly Target as per the Agreement?] LIKE '%,%',SUBSTRING(A.[Will this Distributor Achieve their Quarterly Target as per the Agreement?],1,CHARINDEX(',',A.[Will this Distributor Achieve their Quarterly Target as per the Agreement?])-1),A.[Will this Distributor Achieve their Quarterly Target as per the Agreement?]) AS [Will this Distributor Achieve their Quarterly Target as per the Agreement?],
	   IIF(A.[Will this Distributor Achieve their Quarterly Target as per the Agreement?] LIKE '%,%',SUBSTRING(A.[Will this Distributor Achieve their Quarterly Target as per the Agreement?],CHARINDEX(',',A.[Will this Distributor Achieve their Quarterly Target as per the Agreement?])+1,LEN(A.[Will this Distributor Achieve their Quarterly Target as per the Agreement?])),'') AS Comment2,
       A.[If there is a Target Achievement Risk - Rate it!],
       A.[Atval Inventory Count],
       A.[Automatic Control Valve Inventory Count],
       A.[Insamcor Inventory Control Count],
       A.[Saunders Inventory Control Count],
       A.[SKG Inventory Control Count],
       A.[Vent-O-Mat Inventory Control Count],
       IIF(A.[Inventory Replenishment Required] LIKE '%,%',SUBSTRING(A.[Inventory Replenishment Required],1,CHARINDEX(',',A.[Inventory Replenishment Required])-1),A.[Inventory Replenishment Required]) AS [Inventory Replenishment Required],
	   IIF(A.[Inventory Replenishment Required] LIKE '%,%',SUBSTRING(A.[Inventory Replenishment Required],CHARINDEX(',',A.[Inventory Replenishment Required])+1,LEN(A.[Inventory Replenishment Required])),'') AS Comment3,
       A.[Estimate Value of Inventory Replenishment],
       A.[When will you receive the order for Inventory],
       IIF(A.[Have you advised your customer to place an order and have they agreed to this] LIKE '%,%',SUBSTRING(A.[Have you advised your customer to place an order and have they agreed to this],1,CHARINDEX(',',A.[Have you advised your customer to place an order and have they agreed to this])-1),A.[Have you advised your customer to place an order and have they agreed to this]) AS [Have you advised your customer to place an order and have they agreed to this],
	   IIF(A.[Have you advised your customer to place an order and have they agreed to this] LIKE '%,%',SUBSTRING(A.[Have you advised your customer to place an order and have they agreed to this],CHARINDEX(',',A.[Have you advised your customer to place an order and have they agreed to this])+1,LEN(A.[Have you advised your customer to place an order and have they agreed to this])),'') AS Comment4,
       A.[Is this forecasted or Pipeline] 
FROM (SELECT * FROM cte WHERE RepeatCount <> 0)A RIGHT OUTER JOIN (SELECT * FROM cte WHERE RepeatCount = 0)B ON A.ReferenceNo = B.ReferenceNo

