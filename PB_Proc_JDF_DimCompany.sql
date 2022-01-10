
CREATE Procedure [dbo].[PB_Proc_JDF_DimCompany]
As
BEGIN
	set NoCount On;

	Declare @Desc Varchar(200)
	Exec dbo.PB_Log_Insert 'JDF_DimCompany','JDF_DimCompany Start','JDF'

	Truncate table dbo.JDF_DimCompany

	Insert Into dbo.JDF_DimCompany(CompanyId,Company) 
	Select CompanyId,Company From dbo.JDF_BI_Vw_DimCompany


	Select @Desc = 'JDF_DimCompany Completed.( '+  Convert(Varchar,Count(1)) + ' ) Records Inserted'  From dbo.JDF_DimCompany(NoLock) 
	Exec dbo.PB_Log_Insert 'JDF_DimCompany',@Desc,'JDF'

	Set NoCount OFF;
END

