CREATE PROC [dbo].[PB_Proc_UpdateDimensionsMasslift]
AS
BEGIN
	EXECUTE sp_executesql [PB_Proc_Masslift_Fact_DailyPlanFeedback]
	EXECUTE sp_executesql [PB_Proc_Masslift_Fact_TaskCaptured]
	EXECUTE sp_executesql [PB_Proc_Masslift_Fact_TaskFeedback]
	EXECUTE sp_executesql [PB_Proc_Masslift_Fact_OpportunitySummary]
	EXECUTE sp_executesql [PB_Proc_Masslift_Dim_EngagementChats]
	EXECUTE sp_executesql [PB_Proc_Masslift_Dim_Company]
	EXECUTE sp_executesql [PB_Proc_Masslift_Fact_KnowYourArea]
	EXECUTE sp_executesql [PB_Proc_Masslift_Fact_CourtseyCall]
	EXECUTE sp_executesql [PB_Proc_Masslift_Fact_Leads]
	EXECUTE sp_executesql [PB_Proc_Masslift_Fact_ColdCallPush]
	EXECUTE sp_executesql [PB_Proc_Masslift_Fact_Engagements]
	EXECUTE sp_executesql [PB_Proc_Masslift_Fact_Pipeline]
	EXECUTE sp_executesql [PB_Proc_Masslift_Fact_Discussions]
	EXECUTE sp_executesql [PB_Proc_Masslift_Fact_ContractExpiry]
	EXECUTE sp_executesql [PB_Proc_Masslift_Fact_FMD]
	EXECUTE sp_executesql [PB_Proc_Masslift_Fact_SiteAssessment]
	EXECUTE sp_executesql [PB_Proc_Masslift_Fact_SalesStack]
	EXECUTE sp_executesql [PB_Proc_Masslift_Fact_Area]
	EXECUTE sp_executesql [PB_Proc_Masslift_Fact_Salesmen]
	EXECUTE sp_executesql [PB_Proc_Masslift_Fact_ClientUtilization]
	EXECUTE sp_executesql [PB_Proc_MassLift_Fact_SalesStack_Order_Dealer]
	EXECUTE sp_executesql [PB_Proc_Masslift_Fact_DailyPlanCaptured]


END
