CREATE PROC [dbo].[PB_Proc_UpdateDimensionsAfgri]
AS
BEGIN

	execute sp_executesql [dbo.PB_Proc_Afgri_DimCompany]
	execute sp_executesql [dbo.PB_Proc_Afgri_DetailInformation]
	execute sp_executesql [dbo.PB_Proc_Afgri_Establishment]
	execute sp_executesql [dbo.PB_Proc_Afgri_Establishment_Group]
	execute sp_executesql [dbo.PB_Proc_Afgri_FinancedBy]
	execute sp_executesql [dbo.PB_Proc_Afgri_Product_Detail]
	execute sp_executesql [dbo.PB_Proc_Afgri_Sales_Person]
	execute sp_executesql [dbo.PB_Proc_Afgri_Fact_Magnitude]
END
