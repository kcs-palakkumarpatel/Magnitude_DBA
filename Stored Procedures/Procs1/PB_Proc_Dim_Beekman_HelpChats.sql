

CREATE Procedure [dbo].[PB_Proc_Dim_Beekman_HelpChats]
As
BEGIN
	set NoCount On;

	Declare @Desc Varchar(200)
	Exec dbo.PB_Log_Insert 'Dim_Beekman_HelpChats','Dim_Beekman_HelpChats Start','Beekman New'

	Truncate table dbo.Dim_Beekman_HelpChats

	
	Insert into Dim_Beekman_HelpChats(ReferenceNo, Conversation,name,Date)
	select ReferenceNo, Conversation,name,Date
	 from [PB_VW_Dim_Beekman_HelpChats]

	Select @Desc = 'Dim_Beekman_HelpChats Completed.( '+  Convert(Varchar,Count(1)) + ' ) Records Inserted'  From dbo.Dim_Beekman_HelpChats(NoLock) 
	Exec dbo.PB_Log_Insert 'Dim_Beekman_HelpChats',@Desc,'Beekman New'

	Set NoCount OFF;
END
