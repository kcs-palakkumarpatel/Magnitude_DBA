CREATE PROC [dbo].[PB_Proc_UpdateDimensionsCSC]
AS
BEGIN
	EXECUTE sp_executesql [PB_Proc_LG_Fact_SiteVisitCaptured]
	EXECUTE sp_executesql [PB_Proc_LG_Fact_ClientScheduled1]
	EXECUTE sp_executesql [PB_Proc_LG_Fact_SiteVisit1]
	EXECUTE sp_executesql [PB_Proc_LG_Fact_SiteVisitFeedback]
	EXECUTE sp_executesql [PB_Proc_LG_Fact_AreaManagerInspection]
	EXECUTE sp_executesql [PB_Proc_LG_Fact_GreenHouseRequest]
EXECUTE sp_executesql [PB_Proc_Fact_Covid]
EXECUTE sp_executesql [PB_Proc_TC_Fact_Covid]
EXECUTE sp_executesql [PB_Proc_TSG_Fact_Covid]
EXECUTE sp_executesql [PB_Proc_DFC_Fact_Covid]
EXECUTE sp_executesql [PB_Proc_Nosa_Fact_Covid]
EXECUTE sp_executesql [PB_Proc_Stef_Fact_Covid]
EXECUTE sp_executesql [PB_Proc_RB_Fact_Covid]
	--EXECUTE sp_executesql [PB_Proc_User_Optimization]
	EXECUTE sp_executesql [PB_Proc_NW_Sales]
	EXECUTE sp_executesql [PB_Proc_Toyota_CSI]
	EXECUTE sp_executesql [PB_Proc_Fact_EAS_MaseveTally]
	EXECUTE sp_executesql [PB_Proc_Macsteel_Fact_ClientUtilization]
	EXECUTE sp_executesql [PB_Proc_Toyota_Fact_ClientUtilization]
EXECUTE sp_executesql [PB_Proc_Topbet_Fact_MaintenanceRequest]
EXECUTE sp_executesql [PB_Proc_Topbet_Fact_OvertimeRequest]
EXECUTE sp_executesql [PB_Proc_Topbet_Fact_TrainingRequest]
EXECUTE sp_executesql [PB_Proc_Topbet_Fact_CustomerExperience]
EXECUTE sp_executesql [PB_Proc_Topbet_Fact_MaintenancePlanning]
	EXECUTE sp_executesql [PB_Proc_Topbet_Fact_StoreOpenClose]
	EXECUTE sp_executesql [PB_Proc_SOG_Fact]
EXECUTE sp_executesql [PB_Proc_TC_Fact_RoomClean]
	EXECUTE sp_executesql [PB_Proc_Fact_CSC_Captured]
	EXECUTE sp_executesql [PB_Proc_Fact_CSC_Feedback]
	EXECUTE sp_executesql [PB_Proc_Fact_CSC_Complaint_Captured]
	EXECUTE sp_executesql [PB_Proc_Kamojou_Fact_EmployeeDeclaration]
	EXECUTE sp_executesql [PB_Proc_MediPost_Fact_CovidAccessControl]
	--EXECUTE sp_executesql [PB_Proc_BsiSteel_Fact_EmployeeDeclaration]
	--EXECUTE sp_executesql [PB_Proc_BsiSteel_Fact_StaffTemperature]
	EXECUTE sp_executesql [PB_Proc_Avocet_Fact_DeliveryCaptured]
	EXECUTE sp_executesql [PB_Proc_Avocet_Fact_HelpDeskCaptured]
	EXECUTE sp_executesql [PB_Proc_Avocet_Fact_OnSiteJobCaptured]
	EXECUTE sp_executesql [PB_Proc_Avocet_Fact_OverallStatus]
	EXECUTE sp_executesql [PB_Proc_Avocet_Fact_HelpDeskStatus]
	EXECUTE sp_executesql [PB_Proc_Avocet_Fact_OnSiteJobStatus]
	EXECUTE sp_executesql [PB_Proc_Avocet_Fact_OnLineSupportCaptured]
	--EXECUTE sp_executesql [PB_Proc_Fact_SMS_Usage]
	EXECUTE sp_executesql [PB_Proc_WorkForceStaffing_Fact_AppUser]
	EXECUTE sp_executesql [PB_Proc_WorkForceStaffing_Fact_ClientTrack]
	EXECUTE sp_executesql [PB_Proc_WorkForceStaffing_Fact_FollowUp]
	EXECUTE sp_executesql [PB_Proc_WorkForceStaffing_Fact_LeadAllocation]
	EXECUTE sp_executesql [PB_Proc_WorkForceStaffing_Fact_Leads]
	EXECUTE sp_executesql [PB_Proc_WorkForceStaffing_Fact_MonthlyPlan]
	EXECUTE sp_executesql [PB_Proc_WorkForceStaffing_Fact_NewCalls]
	EXECUTE sp_executesql [PB_Proc_WorkForceStaffing_Fact_ProspectEngagement]
	EXECUTE sp_executesql [PB_Proc_WorkForceStaffing_Fact_Quotes]
	EXECUTE sp_executesql [PB_Proc_WorkForce_Fact_ServiceZoneCaptured]
	EXECUTE sp_executesql [PB_Proc_RB_Fact_EmployeeScreening]


END
