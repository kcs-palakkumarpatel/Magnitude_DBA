

CREATE Procedure [dbo].[PB_Proc_JDF_Stage]
As
BEGIN
	set NoCount On;

	Declare @Desc Varchar(200)
	Exec dbo.PB_Log_Insert 'JDF_Stage','JDF_Stage Start','JDF'

	Truncate table dbo.JDF_Stage

	Insert Into dbo.JDF_Stage(SeenClientAnswerMasterId,StageName,Stage_Level,CreatedOn) 
	Select SeenClientAnswerMasterId,StageName,Stage_Level,CreatedOn From dbo.NEW_JDF_BI_Vw_Stage


	Select @Desc = 'JDF_Stage Completed.( '+  Convert(Varchar,Count(1)) + ' ) Records Inserted'  From dbo.JDF_Stage(NoLock) 
	Exec dbo.PB_Log_Insert 'JDF_Stage',@Desc,'JDF'

	Set NoCount OFF;
END

