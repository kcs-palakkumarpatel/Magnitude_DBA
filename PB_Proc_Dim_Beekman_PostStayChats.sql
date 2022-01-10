


CREATE Procedure [dbo].[PB_Proc_Dim_Beekman_PostStayChats]
As
BEGIN
	set NoCount On;

	Declare @Desc Varchar(200)
	Exec dbo.PB_Log_Insert 'Dim_Beekman_PostStayChats','Dim_Beekman_PostStayChats Start','Beekman New'

	Truncate table dbo.Dim_Beekman_PostStayChats

	
	Insert into Dim_Beekman_PostStayChats(ReferenceNo, Conversation,name,Date)
	select ReferenceNo, Conversation,name,Date
	 from [PB_VW_Dim_Beekman_PostStayChats]

	Select @Desc = 'Dim_Beekman_PostStayChats Completed.( '+  Convert(Varchar,Count(1)) + ' ) Records Inserted'  From dbo.Dim_Beekman_PostStayChats(NoLock) 
	Exec dbo.PB_Log_Insert 'Dim_Beekman_PostStayChats',@Desc,'Beekman New'

	Set NoCount OFF;
END
