
CREATE PROC [dbo].[PB_Proc_UpdateDimensionsInfraset]
AS
BEGIN

	
	execute sp_executesql [PB_Proc_Fact_Infraset_ProductSales]
	execute sp_executesql [PB_Proc_Fact_Infraset_ReportIssues]
	execute sp_executesql [PB_Proc_Fact_Infraset_Specification]
	execute sp_executesql [PB_Proc_Fact_Infraset_DigitalDiary]
END
