



CREATE Procedure [dbo].[PB_Proc_Fact_LBH_GuestFeedback]
As
BEGIN
	set NoCount On;

	Declare @Desc Varchar(200)
	Exec dbo.PB_Log_Insert 'Fact_LBH_GuestFeedback','Fact_LBH_GuestFeedback Start','LBH Reputation Management'

	Truncate table dbo.Fact_LBH_GuestFeedback

	
	Insert into Fact_LBH_GuestFeedback(EstablishmentName,CapturedDate,ReferenceNo,IsPositive,Status,UserId,UserName,
ResolvedDate,AutoResolved,FirstResponseDate,[Guest Name:],[Room Number],[What is the issue?],[Issue Type],[Urgency],
[Comment],IsOutStanding,ResponseDate,SeenClientAnswerMasterId,[Genuine Problem],[What problem],[Permanently fixed],
[Describe])
	select EstablishmentName,CapturedDate,ReferenceNo,IsPositive,Status,UserId,UserName,
ResolvedDate,AutoResolved,FirstResponseDate,[Guest Name:],[Room Number],[What is the issue?],[Issue Type],[Urgency],
[Comment],IsOutStanding,ResponseDate,SeenClientAnswerMasterId,[Genuine Problem],[What problem],[Permanently fixed],
[Describe]
	from PB_VW_Fact_LBH_GuestFeedback

	Select @Desc = 'Fact_LBH_GuestFeedback Completed.( '+  Convert(Varchar,Count(1)) + ' ) Records Inserted'  From dbo.Fact_LBH_GuestFeedback(NoLock) 
	Exec dbo.PB_Log_Insert 'Fact_LBH_GuestFeedback',@Desc,'LBH Reputation Management'

	Set NoCount OFF;
END




