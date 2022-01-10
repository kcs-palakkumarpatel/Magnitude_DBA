

CREATE view [dbo].[PB_VW_Fact_DFC_SM_Captured] as


with cte as(
select EstablishmentName,CapturedDate,ReferenceNo,IsPositive,Status,UserId, UserName, Longitude,Latitude, RepeatCount,
CustomerCompany,
CustomerEmail,CustomerMobile,CustomerName,

[Customer Name],
[How did the meeting come about?],
[Meeting Type],
[Who did you meet with?],
[Purpose of the Meeting],
[If this Meeting is with Channel Partner and End Customer, who is the End Customer],
[If Objective was to resolve technical issues, please provide feedback on the issue and how this was resolved],
[If Any, What issues were raised in the meeting by the Customer?],
[If Issues Raised, what was discussed to resolve or mitigate against risk of losing business],
[If Product Quality, please provide a full description of the issue],
[Do you require Management Involvement?],
[If YES selected, tell us what assistance you anticipate from management?],
[Who are the key competitors (please list in order of priority) or if NONE, then N/A],
[Product Qualified (Use the ADD Tab to qualify multiple products)],
[Quantity],
[If Qualified please select which Sector this opportunity is for],
[What is your commitment to this qualifier?],
[Will you be placing this in Forecast or Pipeline],
[If Qualified what month do you expect to convert this deal to closed],
[If CLOSED can we meet the Delivery Date Requested (If NO do you require assistance with this?)],
[Is this Opportunity a Section 72, If YES please select what the Requirements are],
[Any other Comments Relevant to this Opportunity],
[Are you assessing Target Tracking in this Meeting?],
[Value of Deals Lost],
[If LOST DEAL reported, provide reason why the opportunity was lost],
[Will this Distributor Achieve their Quarterly Target as per the Agreement?],
[If there is a Target Achievement Risk - Rate it!],
[Atval Inventory Count],
[Automatic Control Valve Inventory Count],
[Insamcor Inventory Control Count],
[Saunders Inventory Control Count],
[SKG Inventory Control Count],
[Vent-O-Mat Inventory Control Count],
[Inventory Replenishment Required],
[Estimate Value of Inventory Replenishment],
[When will you receive the order for Inventory],
[Have you advised your customer to place an order and have they agreed to this]
From(
select

E.EstablishmentName,dateadd(MINUTE,AM.TimeOffSet,AM.CreatedOn) as CapturedDate,AM.id as ReferenceNo,
AM.IsPositive,AM.IsResolved as Status,
A.Detail as Answer

,Q.Questiontitle as Question ,U.id as UserId, u.name as UserName, 
AM.Longitude ,AM.Latitude ,A.RepeatCount,
(SELECT TOP 1 cd.Detail FROM ContactDetails CD WHERE   CD.ContactMasterId=(case when AM.IsSubmittedForGroup=1 then SAC.ContactMasterId  else AM.ContactMasterId end) and CD.IsDeleted = 0 and CD.Detail<>'' 
and CD.contactQuestionId=2283
) as CustomerCompany,
(SELECT TOP 1 cd.Detail FROM ContactDetails CD WHERE   CD.ContactMasterId=(case when AM.IsSubmittedForGroup=1 then SAC.ContactMasterId  else AM.ContactMasterId end) and CD.IsDeleted = 0 and CD.Detail<>'' 
and CD.contactQuestionId=2287
) as CustomerEmail,
(SELECT TOP 1 cd.Detail FROM ContactDetails CD WHERE   CD.ContactMasterId=(case when AM.IsSubmittedForGroup=1 then SAC.ContactMasterId  else AM.ContactMasterId end) and CD.IsDeleted = 0 and CD.Detail<>'' 
and CD.contactQuestionId=2286
) as CustomerMobile,
(SELECT TOP 1 cd.Detail FROM ContactDetails CD WHERE   CD.ContactMasterId=(case when AM.IsSubmittedForGroup=1 then SAC.ContactMasterId  else AM.ContactMasterId end) and CD.IsDeleted = 0 and CD.Detail<>'' 
and CD.contactQuestionId=2284
) +' ' +
(SELECT TOP 1 cd.Detail FROM ContactDetails CD WHERE   CD.ContactMasterId=(case when AM.IsSubmittedForGroup=1 then SAC.ContactMasterId  else AM.ContactMasterId end) and CD.IsDeleted = 0 and CD.Detail<>'' 
and CD.contactQuestionId=2285
) as CustomerName


from dbo.[Group] G
inner join EstablishmentGroup EG on G.id=EG.groupid
inner join Establishment E on  E.EstablishmentGroupId=EG.Id
inner join SeenClientAnswerMaster AM on AM.EstablishmentId=E.id
inner join [SeenClientAnswers] A on A.SeenclientAnswerMasterId=AM.id
inner join SeenClientQuestions Q on Q.id=A.QuestionId
left outer join dbo.[Appuser] u on u.id=AM.CreatedBy
left outer join SeenClientAnswerChild SAC on AM.id=SAC.SeenClientAnswerMasterId 

Where (G.Id=366 and EG.Id =3547
ANd (AM.IsDeleted=0 or AM.IsDeleted=null)) 
and Q.IsRequiredInBI=1
/*Q.id in(35566,26795,35527,35528,35526,35530,26797,26799,26801,26803,26804,26805,26806,26808,26810,28378,26825,35531,35532,
26827,26829,26831,35522,35524,35542,26938,30762,26940,26941,26944,26945,26946,26947,35529,35535,35536,35537)*/

)S
pivot(
Max(Answer)
For  Question In (

[Customer Name],
[How did the meeting come about?],
[Meeting Type],
[Who did you meet with?],
[Purpose of the Meeting],
[If this Meeting is with Channel Partner and End Customer, who is the End Customer],
[If Objective was to resolve technical issues, please provide feedback on the issue and how this was resolved],
[If Any, What issues were raised in the meeting by the Customer?],
[If Issues Raised, what was discussed to resolve or mitigate against risk of losing business],
[If Product Quality, please provide a full description of the issue],
[Do you require Management Involvement?],
[If YES selected, tell us what assistance you anticipate from management?],
[Who are the key competitors (please list in order of priority) or if NONE, then N/A],
[Product Qualified (Use the ADD Tab to qualify multiple products)],
[Quantity],
[If Qualified please select which Sector this opportunity is for],
[What is your commitment to this qualifier?],
[Will you be placing this in Forecast or Pipeline],
[If Qualified what month do you expect to convert this deal to closed],
[If CLOSED can we meet the Delivery Date Requested (If NO do you require assistance with this?)],
[Is this Opportunity a Section 72, If YES please select what the Requirements are],
[Any other Comments Relevant to this Opportunity],
[Are you assessing Target Tracking in this Meeting?],
[Value of Deals Lost],
[If LOST DEAL reported, provide reason why the opportunity was lost],
[Will this Distributor Achieve their Quarterly Target as per the Agreement?],
[If there is a Target Achievement Risk - Rate it!],
[Atval Inventory Count],
[Automatic Control Valve Inventory Count],
[Insamcor Inventory Control Count],
[Saunders Inventory Control Count],
[SKG Inventory Control Count],
[Vent-O-Mat Inventory Control Count],
[Inventory Replenishment Required],
[Estimate Value of Inventory Replenishment],
[When will you receive the order for Inventory],
[Have you advised your customer to place an order and have they agreed to this]
))P
)




Select 
B.EstablishmentName,B.CapturedDate,B.ReferenceNo,B.IsPositive,B.Status,B.UserId, B.UserName, B.Longitude,B.Latitude, A.RepeatCount,
B.CustomerCompany,
B.CustomerEmail,B.CustomerMobile,B.CustomerName,

B.[Customer Name],
B.[How did the meeting come about?],
B.[Meeting Type],
B.[Who did you meet with?],
B.[Purpose of the Meeting],
B.[If this Meeting is with Channel Partner and End Customer, who is the End Customer],
B.[If Objective was to resolve technical issues, please provide feedback on the issue and how this was resolved],
B.[If Any, What issues were raised in the meeting by the Customer?],
B.[If Issues Raised, what was discussed to resolve or mitigate against risk of losing business],
B.[If Product Quality, please provide a full description of the issue],
B.[Do you require Management Involvement?],
B.[If YES selected, tell us what assistance you anticipate from management?],
B.[Who are the key competitors (please list in order of priority) or if NONE, then N/A],
A.[Product Qualified (Use the ADD Tab to qualify multiple products)],
A.[Quantity],
A.[If Qualified please select which Sector this opportunity is for],
A.[What is your commitment to this qualifier?],
A.[Will you be placing this in Forecast or Pipeline],
A.[If Qualified what month do you expect to convert this deal to closed],
A.[If CLOSED can we meet the Delivery Date Requested (If NO do you require assistance with this?)],
A.[Is this Opportunity a Section 72, If YES please select what the Requirements are],
A.[Any other Comments Relevant to this Opportunity],
A.[Are you assessing Target Tracking in this Meeting?],
A.[Value of Deals Lost],
A.[If LOST DEAL reported, provide reason why the opportunity was lost],
A.[Will this Distributor Achieve their Quarterly Target as per the Agreement?],
A.[If there is a Target Achievement Risk - Rate it!],
A.[Atval Inventory Count],
A.[Automatic Control Valve Inventory Count],
A.[Insamcor Inventory Control Count],
A.[Saunders Inventory Control Count],
A.[SKG Inventory Control Count],
A.[Vent-O-Mat Inventory Control Count],
A.[Inventory Replenishment Required],
A.[Estimate Value of Inventory Replenishment],
A.[When will you receive the order for Inventory],
A.[Have you advised your customer to place an order and have they agreed to this]
From (
	Select * 
	from cte
	where repeatcount <> 0
) A
inner Join (
	Select * 
	from cte
	where repeatcount = 0
) B On A.referenceno=B.referenceno


