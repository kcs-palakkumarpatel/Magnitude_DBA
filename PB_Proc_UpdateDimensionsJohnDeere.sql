


Create PROC [dbo].[PB_Proc_UpdateDimensionsJohnDeere]
AS
BEGIN

	execute sp_executesql [dbo.PB_Proc_JohnDeere_DimCompany]
	execute sp_executesql [dbo.PB_Proc_JohnDeere_DetailInformation]
	execute sp_executesql [dbo.PB_Proc_JohnDeere_Establishment]
	execute sp_executesql [dbo.PB_Proc_JohnDeere_Establishment_Group]
	execute sp_executesql [dbo.PB_Proc_JohnDeere_FinancedBy]
	execute sp_executesql [dbo.PB_Proc_JohnDeere_Product_Detail]
	execute sp_executesql [dbo.PB_Proc_JohnDeere_Sales_Person]
	execute sp_executesql [dbo.PB_Proc_JohnDeere_Fact_Magnitude]
END
