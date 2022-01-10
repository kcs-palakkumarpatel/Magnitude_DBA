
CREATE Procedure [dbo].[PB_Proc_JohnDeere_DimCompany]
As
BEGIN
	set NoCount On;

	Declare @Desc Varchar(200)
	Exec dbo.PB_Log_Insert 'JohnDeere_DimCompany','JohnDeere_DimCompany Start','JohnDeere'

	Truncate table dbo.JohnDeere_DimCompany

	Insert Into dbo.JohnDeere_DimCompany(CompanyId,Company) 
	Select CompanyId,Company From dbo.JD_BI_Vw_DimCompany


	Select @Desc = 'JohnDeere_DimCompany Completed.( '+  Convert(Varchar,Count(1)) + ' ) Records Inserted'  From dbo.JohnDeere_DimCompany(NoLock) 
	Exec dbo.PB_Log_Insert 'JohnDeere_DimCompany',@Desc,'JohnDeere'

	Set NoCount OFF;
END

