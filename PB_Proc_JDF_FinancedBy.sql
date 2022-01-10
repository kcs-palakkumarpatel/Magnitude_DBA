

CREATE Procedure [dbo].[PB_Proc_JDF_FinancedBy]
As
BEGIN
	set NoCount On;

	Declare @Desc Varchar(200)
	Exec dbo.PB_Log_Insert 'JDF_FinancedBy','JDF_FinancedBy Start','JDF'

	Truncate table dbo.JDF_FinancedBy

	Insert Into dbo.JDF_FinancedBy(SeenClientAnswerMasterId ,EstablishmentGroupId ,[Financed By]) 
	Select SeenClientAnswerMasterId ,EstablishmentGroupId ,[Financed By] From dbo.JDF_BI_Vw_FinancedBy


	Select @Desc = 'JDF_FinancedBy Completed.( '+  Convert(Varchar,Count(1)) + ' ) Records Inserted'  From dbo.JDF_FinancedBy(NoLock) 
	Exec dbo.PB_Log_Insert 'JDF_FinancedBy',@Desc,'JDF'

	Set NoCount OFF;
END

