
CREATE Procedure [dbo].[PB_Proc_Dim_Beekman_BodyBlissChats]
As
BEGIN
	set NoCount On;

	Declare @Desc Varchar(200)
	Exec dbo.PB_Log_Insert 'Dim_Beekman_BodyBlissChats','Dim_Beekman_BodyBlissChats Start','Beekman New'

	Truncate table dbo.Dim_Beekman_BodyBlissChats

	
	Insert into Dim_Beekman_BodyBlissChats(ReferenceNo, Conversation,name,Date)
	select ReferenceNo, Conversation,name,Date
	 from [PB_VW_Dim_Beekman_BodyBlissChats]

	Select @Desc = 'Dim_Beekman_BodyBlissChats Completed.( '+  Convert(Varchar,Count(1)) + ' ) Records Inserted'  From dbo.Dim_Beekman_BodyBlissChats(NoLock) 
	Exec dbo.PB_Log_Insert 'Dim_Beekman_BodyBlissChats',@Desc,'Beekman New'

	Set NoCount OFF;
END
