
CREATE Procedure [dbo].[PB_Proc_Fact_Beekman_OnlineGuestReviews]
As
BEGIN
	set NoCount On;

	Declare @Desc Varchar(200)
	Exec dbo.PB_Log_Insert 'Fact_Beekman_OnlineGuestReviews','Fact_Beekman_OnlineGuestReviews Start','Beekman New'

	Truncate table dbo.Fact_Beekman_OnlineGuestReviews

	
	Insert into Fact_Beekman_OnlineGuestReviews(EstablishmentName,CapturedDate,ReferenceNo,IsPositive,Status,PI,UserId,UserName,FirstActionDate,FirstResponseDate,ResolvedDate,CustomerName,
	Longitude,Latitude,AutoResolved,[Reviewer],[Source],[Good_Comments],[Bad_Comments],[General_Comments],[Manager_Comments],[Overall_Rating],[Room_Rating],[Cleanliness_Rating],
	[Facilities_Rating],[Service_Rating],ResponseReference,[Was this an Issue],[Type of Issue],[Action Taken],[Issue Fixed],[Confidence in Fix],[Deadline of fix],[Comments])
	select EstablishmentName,CapturedDate,ReferenceNo,IsPositive,Status,PI,UserId,UserName,FirstActionDate,FirstResponseDate,ResolvedDate,CustomerName,
	Longitude,Latitude,AutoResolved,[Reviewer],[Source],[Good_Comments],[Bad_Comments],[General_Comments],[Manager_Comments],[Overall_Rating],[Room_Rating],[Cleanliness_Rating],
	[Facilities_Rating],[Service_Rating],ResponseReference,[Was this an Issue],[Type of Issue],[Action Taken],[Issue Fixed],[Confidence in Fix],[Deadline of fix],[Comments]
	 from [PB_VW_Fact_Beekman_OnlineGuestReviews]

	Select @Desc = 'Fact_Beekman_OnlineGuestReviews Completed.( '+  Convert(Varchar,Count(1)) + ' ) Records Inserted'  From dbo.Fact_Beekman_OnlineGuestReviews(NoLock) 
	Exec dbo.PB_Log_Insert 'Fact_Beekman_OnlineGuestReviews',@Desc,'Beekman New'

	Set NoCount OFF;
END
