Create Procedure [dbo].[PB_Proc_Fact_DFC_SM_Captured]
As
BEGIN
	set NoCount On;

	Declare @Desc Varchar(200)
	Exec dbo.PB_Log_Insert 'Fact_DFC_SM_Captured','Fact_DFC_SM_Captured Start','DFC'

	Truncate table dbo.Fact_DFC_SM_Captured

	Insert Into dbo.Fact_DFC_SM_Captured(
EstablishmentName,CapturedDate,ReferenceNo,IsPositive,Status,UserId, UserName, Longitude,Latitude, RepeatCount,
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
[Have you advised your customer to place an order and have they agreed to this]) 
	Select EstablishmentName,CapturedDate,ReferenceNo,IsPositive,Status,UserId, UserName, Longitude,Latitude, RepeatCount,
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
[Have you advised your customer to place an order and have they agreed to this]From dbo.PB_VW_Fact_DFC_SM_Captured


	Select @Desc = 'Fact_DFC_SM_Captured Completed.( '+  Convert(Varchar,Count(1)) + ' ) Records Inserted'  From dbo.Fact_DFC_SM_Captured(NoLock) 
	Exec dbo.PB_Log_Insert 'Fact_DFC_SM_Captured',@Desc,'DFC'

	Set NoCount OFF;
END
