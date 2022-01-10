
Create Procedure [dbo].[PB_Proc_Dim_DFC_SM_Template]
As
BEGIN
	set NoCount On;

	Declare @Desc Varchar(200)
	Exec dbo.PB_Log_Insert 'Dim_DFC_SM_Template','Dim_DFC_SM_Template Start','DFC'

	Truncate table dbo.Dim_DFC_SM_Template

	Insert Into dbo.Dim_DFC_SM_Template(SeenClientAnswerMasterId ,Template ,Date,Name) 
	Select SeenClientAnswerMasterId ,Template ,Date,Name From dbo.PB_VW_Dim_DFC_SM_Template


	Select @Desc = 'Dim_DFC_SM_Template Completed.( '+  Convert(Varchar,Count(1)) + ' ) Records Inserted'  From dbo.Dim_DFC_SM_Template(NoLock) 
	Exec dbo.PB_Log_Insert 'Dim_DFC_SM_Template',@Desc,'DFC'

	Set NoCount OFF;
END

