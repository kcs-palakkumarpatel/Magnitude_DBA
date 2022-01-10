

CREATE Procedure [dbo].[PB_Proc_Dim_Beekman_OnlineChats]
As
BEGIN
	set NoCount On;

	Declare @Desc Varchar(200)
	Exec dbo.PB_Log_Insert 'Dim_Beekman_OnlineChats','Dim_Beekman_OnlineChats Start','Beekman New'

	Truncate table dbo.Dim_Beekman_OnlineChats

	
	Insert into Dim_Beekman_OnlineChats(ReferenceNo, Conversation,name,Date)
	select ReferenceNo, Conversation,name,Date
	 from [PB_VW_Dim_Beekman_OnlineChats]

	Select @Desc = 'Dim_Beekman_OnlineChats Completed.( '+  Convert(Varchar,Count(1)) + ' ) Records Inserted'  From dbo.Dim_Beekman_OnlineChats(NoLock) 
	Exec dbo.PB_Log_Insert 'Dim_Beekman_OnlineChats',@Desc,'Beekman New'

	Set NoCount OFF;
END
