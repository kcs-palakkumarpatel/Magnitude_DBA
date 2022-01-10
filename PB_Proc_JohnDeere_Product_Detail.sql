

CREATE Procedure [dbo].[PB_Proc_JohnDeere_Product_Detail]
As
BEGIN
	set NoCount On;

	Declare @Desc Varchar(200)
	Exec dbo.PB_Log_Insert 'JohnDeere_Product_Detail','JohnDeere_Product_Detail Start','JohnDeere'

	Truncate table dbo.JohnDeere_Product_Detail

	Insert Into dbo.JohnDeere_Product_Detail(SeenClientAnswerMasterId,EstablishmentGroupId,Product) 
	Select SeenClientAnswerMasterId,EstablishmentGroupId,Product From dbo.JD_BI_Vw_Product_Detail


	Select @Desc = 'JohnDeere_Product_Detail Completed.( '+  Convert(Varchar,Count(1)) + ' ) Records Inserted'  From dbo.JohnDeere_Product_Detail(NoLock) 
	Exec dbo.PB_Log_Insert 'JohnDeere_Product_Detail',@Desc,'JohnDeere'

	Set NoCount OFF;
END

