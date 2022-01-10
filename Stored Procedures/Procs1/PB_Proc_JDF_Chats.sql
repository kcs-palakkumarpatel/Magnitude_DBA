CREATE Procedure [dbo].[PB_Proc_JDF_Chats]
As
BEGIN
	set NoCount On;

	Declare @Desc Varchar(200)
	Exec dbo.PB_Log_Insert 'JDF_Chats','JDF_Chats Start','JDF'

	Truncate table dbo.JDF_Chats

	Insert Into dbo.JDF_Chats(SeenClientAnswerMasterId,Conversation,Name,Date) 
	Select SeenClientAnswerMasterId,Conversation,Name,Date From dbo.BI_Vw_DimChats


	Select @Desc = 'JDF_Chats Completed.( '+  Convert(Varchar,Count(1)) + ' ) Records Inserted'  From dbo.JDF_Chats(NoLock) 
	Exec dbo.PB_Log_Insert 'JDF_Chats',@Desc,'JDF'

	Set NoCount OFF;
END

