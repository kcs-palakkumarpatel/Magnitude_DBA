

Create Procedure [dbo].[PB_Proc_Masslift_Dim_EngagementChats]
As
BEGIN
	set NoCount On;

	Declare @Desc Varchar(200)
	Exec dbo.PB_Log_Insert 'Masslift_Dim_EngagementChats','Masslift_Dim_EngagementChats Start','Masslift'

	Truncate table dbo.Masslift_Dim_EngagementChats

	
	Insert into Masslift_Dim_EngagementChats(SeenClientAnswerMasterId ,		 Conversation ,		 Name ,		 Date)
	select SeenClientAnswerMasterId ,		 Conversation ,		 Name ,		 Date
	 from [PB_VW_Masslift_Dim_EngagementChats]

	Select @Desc = 'Masslift_Dim_EngagementChats Completed.( '+  Convert(Varchar,Count(1)) + ' ) Records Inserted'  From dbo.Masslift_Dim_EngagementChats(NoLock) 
	Exec dbo.PB_Log_Insert 'Masslift_Dim_EngagementChats',@Desc,'Masslift'

	Set NoCount OFF;
END
