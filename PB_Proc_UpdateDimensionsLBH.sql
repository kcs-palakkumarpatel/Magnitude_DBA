


CREATE PROC [dbo].[PB_Proc_UpdateDimensionsLBH]
AS
BEGIN
	--execute sp_executesql [PB_Proc_Fact_LBH_GuestAlert]
	--execute sp_executesql [PB_Proc_Fact_LBH_GuestFeedback]
	--execute sp_executesql [PB_Proc_Fact_LBH_OnlineReviews]
	execute sp_executesql [PB_Proc_Fact_LBH_RoomCleaning]
	--execute sp_executesql [PB_Proc_Fact_LBH_ToDoList]
	execute sp_executesql [PB_Proc_Fact_LBH_HotelMaintenance]
END
