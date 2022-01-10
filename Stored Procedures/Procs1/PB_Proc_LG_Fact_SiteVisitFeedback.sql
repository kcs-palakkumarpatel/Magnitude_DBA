CREATE Procedure [dbo].[PB_Proc_LG_Fact_SiteVisitFeedback]
As
BEGIN
	set NoCount On;

	Declare @Desc Varchar(200)
	Exec dbo.PB_Log_Insert 'LG_Fact_SiteVisitFeedback','LG_Fact_SiteVisitFeedback Start','Life Green'

	Truncate table dbo.LG_Fact_SiteVisitFeedback

	
	Insert into LG_Fact_SiteVisitFeedback(EstablishmentName,ResponseDate,ReferenceNo,SeenClientAnswerMasterId,
	UserName,Longitude,Latitude,[Proceed with],[Select day],DaySort,[Week],[Plant replacement],[Replacement type],
	[Type of plant],[Quantity],[Size],[Replacement area],[Replacement reason],[What to replace],
	[Material Replacement area],[Material Replacement reason],[Client name],[Picture of plant],[Client Signature],[Any plant diseases to report?],
[Picture of the plant],
[Please describe what the disease looks like],
[Are you Replacing a plant today?],
[Plant Description],
[Location],
[Image of New plant],
	CompleteSiteVisit,TotalTime)
	select EstablishmentName,ResponseDate,ReferenceNo,SeenClientAnswerMasterId,
	UserName,Longitude,Latitude,[Proceed with],[Select day],DaySort,[Week],[Plant replacement],[Replacement type],
	[Type of plant],[Quantity],[Size],[Replacement area],[Replacement reason],[What to replace],
	[Material Replacement area],[Material Replacement reason],[Client name],[Picture of plant],[Client Signature],
	[Any plant diseases to report?],
[Picture of the plant],
[Please describe what the disease looks like],
[Are you Replacing a plant today?],
[Plant Description],
[Location],
[Image of New plant],
	CompleteSiteVisit,TotalTime
	 from [PB_VW_LG_Fact_SiteVisitFeedback]

	Select @Desc = 'LG_Fact_SiteVisitFeedback Completed.( '+  Convert(Varchar,Count(1)) + ' ) Records Inserted'  From dbo.LG_Fact_SiteVisitFeedback(NoLock) 
	Exec dbo.PB_Log_Insert 'LG_Fact_SiteVisitFeedback',@Desc,'Life Green'

	Set NoCount OFF;
END
