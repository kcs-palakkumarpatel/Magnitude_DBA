CREATE PROC [dbo].[PB_Proc_UpdateDimensionsDFC]
AS
BEGIN
	execute sp_executesql [PB_Proc_Fact_DFC_SM_Captured]
	execute sp_executesql [PB_Proc_Fact_DFC_SM_Feedback]
	execute sp_executesql [PB_Proc_Dim_DFC_SM_Template]
	execute sp_executesql [PB_Proc_DFC_DimTemplate]
	execute sp_executesql [PB_Proc_DFC_FactCaptured]
	
	END
