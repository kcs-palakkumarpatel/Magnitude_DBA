

CREATE Procedure [dbo].[PB_Proc_Afgri_FinancedBy]
As
BEGIN
	set NoCount On;

	Declare @Desc Varchar(200)
	Exec dbo.PB_Log_Insert 'Afgri_FinancedBy','Afgri_FinancedBy Start','Afgri'

	Truncate table dbo.Afgri_FinancedBy

	Insert Into dbo.Afgri_FinancedBy(SeenClientAnswerMasterId ,EstablishmentGroupId ,[Financed By]) 
	Select SeenClientAnswerMasterId ,EstablishmentGroupId ,[Financed By] From dbo.BI_Vw_FinancedBy


	Select @Desc = 'Afgri_FinancedBy Completed.( '+  Convert(Varchar,Count(1)) + ' ) Records Inserted'  From dbo.Afgri_FinancedBy(NoLock) 
	Exec dbo.PB_Log_Insert 'Afgri_FinancedBy',@Desc,'Afgri'

	Set NoCount OFF;
END

