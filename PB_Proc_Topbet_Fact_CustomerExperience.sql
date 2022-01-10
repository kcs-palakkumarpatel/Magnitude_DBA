
Create Procedure [dbo].[PB_Proc_Topbet_Fact_CustomerExperience]
As
	set NoCount On;

	Declare @Desc Varchar(200)
	Exec dbo.PB_Log_Insert 'Topbet_Fact_CustomerExperience','Topbet_Fact_CustomerExperience Start','Topbet'

	Truncate table dbo.Topbet_Fact_CustomerExperience

	
	Insert into Topbet_Fact_CustomerExperience(EstablishmentName,CapturedDate,ReferenceNo,IsPositive,Status,PI,
[Friendliness],[Helpfulness],[Cleanliness],[Betting Stations],[Sports fixtures],[Betting Products],[Placing Your Bet],
[Time Taken],[Comfort],[Anything to Add],[Respond to you])
	select EstablishmentName,CapturedDate,ReferenceNo,IsPositive,Status,PI,
[Friendliness],[Helpfulness],[Cleanliness],[Betting Stations],[Sports fixtures],[Betting Products],[Placing Your Bet],
[Time Taken],[Comfort],[Anything to Add],[Respond to you]
	 from [PB_VW_Topbet_Fact_CustomerExperience]

	Select @Desc = 'Topbet_Fact_CustomerExperience Completed.( '+  Convert(Varchar,Count(1)) + ' ) Records Inserted'  From dbo.Topbet_Fact_CustomerExperience(NoLock) 
	Exec dbo.PB_Log_Insert 'Topbet_Fact_CustomerExperience',@Desc,'Topbet'
	Set NoCount OFF;
