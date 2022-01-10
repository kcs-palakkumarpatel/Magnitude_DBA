

CREATE Procedure [dbo].[PB_Proc_JohnDeere_FinancedBy]
As
BEGIN
	set NoCount On;

	Declare @Desc Varchar(200)
	Exec dbo.PB_Log_Insert 'JohnDeere_FinancedBy','JohnDeere_FinancedBy Start','JohnDeere'

	Truncate table dbo.JohnDeere_FinancedBy

	Insert Into dbo.JohnDeere_FinancedBy(SeenClientAnswerMasterId ,EstablishmentGroupId ,[Financed By]) 
	Select SeenClientAnswerMasterId ,EstablishmentGroupId ,[Financed By] From dbo.JD_BI_Vw_FinancedBy


	Select @Desc = 'JohnDeere_FinancedBy Completed.( '+  Convert(Varchar,Count(1)) + ' ) Records Inserted'  From dbo.JohnDeere_FinancedBy(NoLock) 
	Exec dbo.PB_Log_Insert 'JohnDeere_FinancedBy',@Desc,'JohnDeere'

	Set NoCount OFF;
END

