
CREATE Procedure [dbo].[PB_Proc_Fact_LBH_OnlineReviews]
As
BEGIN
	set NoCount On;

	Declare @Desc Varchar(200)
	Exec dbo.PB_Log_Insert 'Fact_LBH_OnlineReviews','Fact_LBH_OnlineReviews Start','LBH Reputation Management'

	Truncate table dbo.Fact_LBH_OnlineReviews

	
	Insert into Fact_LBH_OnlineReviews([EstablishmentName],[CapturedDate],[ReferenceNo],[Status],[UserName],[ResolvedDate],FirstResponseDate,
AutoResolved,[Reviewer] ,[Source],[Good_Comments],[Bad_Comments],[General_Comments],[Manager_Comments],
[Overall_Rating],[Room_Rating],[Cleanliness_Rating],[Facilities_Rating],[Service_Rating],IsOutStanding ,
ResponseDate ,SeenClientAnswerMasterId ,[Was this an issue?],[Type of Issue],[Action taken],[Is the issue fixed],
[Confidence],[Deadline of fix],[Comments])
	select [EstablishmentName],[CapturedDate],[ReferenceNo],[Status],[UserName],[ResolvedDate],FirstResponseDate,
AutoResolved,[Reviewer] ,[Source],[Good_Comments],[Bad_Comments],[General_Comments],[Manager_Comments],
[Overall_Rating],[Room_Rating],[Cleanliness_Rating],[Facilities_Rating],[Service_Rating],IsOutStanding ,
ResponseDate ,SeenClientAnswerMasterId ,[Was this an issue?],[Type of Issue],[Action taken],[Is the issue fixed],
[Confidence],[Deadline of fix],[Comments]
	from PB_VW_Fact_LBH_OnlineReviews

	Select @Desc = 'Fact_LBH_OnlineReviews Completed.( '+  Convert(Varchar,Count(1)) + ' ) Records Inserted'  From dbo.Fact_LBH_OnlineReviews(NoLock) 
	Exec dbo.PB_Log_Insert 'Fact_LBH_OnlineReviews',@Desc,'LBH Reputation Management'

	Set NoCount OFF;
END
