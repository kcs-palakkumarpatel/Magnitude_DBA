

CREATE Procedure [dbo].[PB_Proc_Afgri_Product_Detail]
As
BEGIN
	set NoCount On;

	Declare @Desc Varchar(200)
	Exec dbo.PB_Log_Insert 'Afgri_Product_Detail','Afgri_Product_Detail Start','Afgri'

	Truncate table dbo.Afgri_Product_Detail

	Insert Into dbo.Afgri_Product_Detail(SeenClientAnswerMasterId,EstablishmentGroupId,Product) 
	Select SeenClientAnswerMasterId,EstablishmentGroupId,Product From dbo.BI_Vw_Product_Detail


	Select @Desc = 'Afgri_Product_Detail Completed.( '+  Convert(Varchar,Count(1)) + ' ) Records Inserted'  From dbo.Afgri_Product_Detail(NoLock) 
	Exec dbo.PB_Log_Insert 'Afgri_Product_Detail',@Desc,'Afgri'

	Set NoCount OFF;
END

