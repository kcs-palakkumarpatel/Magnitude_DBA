
CREATE Procedure [dbo].[PB_Proc_Afgri_DimCompany]
As
BEGIN
	set NoCount On;

	Declare @Desc Varchar(200)
	Exec dbo.PB_Log_Insert 'Afgri_DimCompany','Afgri_DimCompany Start','Afgri'

	Truncate table dbo.Afgri_DimCompany

	Insert Into dbo.Afgri_DimCompany(CompanyId,Company) 
	Select CompanyId,Company From dbo.BI_Vw_DimCompany


	Select @Desc = 'Afgri_DimCompany Completed.( '+  Convert(Varchar,Count(1)) + ' ) Records Inserted'  From dbo.Afgri_DimCompany(NoLock) 
	Exec dbo.PB_Log_Insert 'Afgri_DimCompany',@Desc,'Afgri'

	Set NoCount OFF;
END

