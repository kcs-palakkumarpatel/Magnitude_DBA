
CREATE PROC [dbo].[PB_Proc_UpdateDimensions]
AS
BEGIN
	execute sp_executesql [dbo.PB_Proc_Dim_Beekman_BodyBlissChats]
	execute sp_executesql [dbo.PB_Proc_Dim_Beekman_FoodBeveragesChats]
	execute sp_executesql [dbo.PB_Proc_Dim_Beekman_HelpChats]
	execute sp_executesql [dbo.PB_Proc_Dim_Beekman_OnlineChats]
	execute sp_executesql [dbo.PB_Proc_Dim_Beekman_PostStayChats]
	execute sp_executesql [dbo.PB_Proc_Fact_Beekman_BodyBliss]
	execute sp_executesql [dbo.PB_Proc_Fact_Beekman_FoodBeverages]
	execute sp_executesql [dbo.PB_Proc_Fact_Beekman_Help]
	execute sp_executesql [dbo.PB_Proc_Fact_Beekman_OnlineGuestReviews]
	execute sp_executesql [dbo.PB_Proc_Fact_Beekman_PostStaySurvey]
	execute sp_executesql [dbo.PB_Proc_Fact_Beekman]
END
