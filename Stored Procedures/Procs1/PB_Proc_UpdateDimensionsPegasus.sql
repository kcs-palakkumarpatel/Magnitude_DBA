

CREATE PROC [dbo].[PB_Proc_UpdateDimensionsPegasus]
AS
BEGIN

	execute sp_executesql [PB_Proc_Fact_Pegasus_CourtseyCall]
	execute sp_executesql [PB_Proc_Fact_Pegasus_SalesCall]
	execute sp_executesql [PB_Proc_Fact_Pegasus_Pipeline]
	execute sp_executesql [PB_Proc_Fact_Pegasus_DailyPlan]
END
