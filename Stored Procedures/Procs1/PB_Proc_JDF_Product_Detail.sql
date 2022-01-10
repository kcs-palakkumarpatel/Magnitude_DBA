CREATE Procedure [dbo].[PB_Proc_JDF_Product_Detail]
As
BEGIN
	set NoCount On;

	Declare @Desc Varchar(200)
	Exec dbo.PB_Log_Insert 'JDF_Product_Detail','JDF_Product_Detail Start','JDF'

	Truncate table dbo.JDF_Product_Detail

	Insert Into dbo.JDF_Product_Detail(SeenClientAnswerMasterId,Product) 
	Select SeenClientAnswerMasterId,Product From dbo.JDF_BI_Vw_Product_Detail


	Select @Desc = 'JDF_Product_Detail Completed.( '+  Convert(Varchar,Count(1)) + ' ) Records Inserted'  From dbo.JDF_Product_Detail(NoLock) 
	Exec dbo.PB_Log_Insert 'JDF_Product_Detail',@Desc,'JDF'

	Set NoCount OFF;
END

