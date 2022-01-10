



CREATE PROC [dbo].[PB_Proc_UpdateDimensionsJDF]
AS
BEGIN

	execute sp_executesql [dbo.PB_Proc_JDF_DimCompany]
	execute sp_executesql [dbo.PB_Proc_JDF_DetailInformation]
	execute sp_executesql [dbo.PB_Proc_JDF_Establishment]
	execute sp_executesql [dbo.PB_Proc_JDF_Establishment_Group]
	execute sp_executesql [dbo.PB_Proc_JDF_FinancedBy]
	execute sp_executesql [dbo.PB_Proc_JDf_Product_Detail]
	execute sp_executesql [dbo.PB_Proc_JDF_Sales_Person]
	execute sp_executesql [dbo.PB_Proc_JDF_Stage]
	execute sp_executesql [dbo.PB_Proc_JDF_Fact_Magnitude]
	execute sp_executesql [dbo.PB_Proc_JDF_Chats]
END
