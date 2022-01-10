
CREATE Procedure [dbo].[PB_Proc_DFC_DimTemplate]
As
BEGIN
	set NoCount On;

	Declare @Desc Varchar(200)
	Exec dbo.PB_Log_Insert 'DFC_DimTemplate','DFC_DimTemplate Start','DFC'

	Truncate table dbo.DFC_DimTemplate

	Insert Into dbo.DFC_DimTemplate(SeenClientAnswerMasterId ,Template ,Date,Name) 
	Select SeenClientAnswerMasterId ,Template ,Date,Name From dbo.VW_PB_DFC_DimTemplate


	Select @Desc = 'DFC_DimTemplate Completed.( '+  Convert(Varchar,Count(1)) + ' ) Records Inserted'  From dbo.DFC_DimTemplate(NoLock) 
	Exec dbo.PB_Log_Insert 'DFC_DimTemplate',@Desc,'DFC'

	Set NoCount OFF;
END
