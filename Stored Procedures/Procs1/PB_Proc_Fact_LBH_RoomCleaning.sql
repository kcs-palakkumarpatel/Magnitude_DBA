

CREATE Procedure [dbo].[PB_Proc_Fact_LBH_RoomCleaning]
As
BEGIN
	set NoCount On;

	Declare @Desc Varchar(200)
	Exec dbo.PB_Log_Insert 'Fact_LBH_RoomCleaning','Fact_LBH_RoomCleaning Start','LBH Room Cleaning'

	Truncate table dbo.Fact_LBH_RoomCleaning

	
	Insert into Fact_LBH_RoomCleaning(EstablishmentName,CapturedDate,ReferenceNo,Status,UserName,ResolvedDate,
	FirstResponseDate,CleanStartDate,CleanEndDate,FailedDate,InspectionDate,[Room Number],[Guest Name],[Room Status],
[Check-in date],[Check-out date],[Bed],[Duties (Traces)],[Task of the Day],IsOutStanding,ResolvedBy)
	select EstablishmentName,CapturedDate,ReferenceNo,Status,UserName,ResolvedDate,
	FirstResponseDate,CleanStartDate,CleanEndDate,FailedDate,InspectionDate,[Room Number],[Guest Name],[Room Status],
[Check-in date],[Check-out date],[Bed],[Duties (Traces)],[Task of the Day],IsOutStanding,ResolvedBy
	from PB_VW_Fact_LBH_RoomCleaning

	Select @Desc = 'Fact_LBH_RoomCleaning Completed.( '+  Convert(Varchar,Count(1)) + ' ) Records Inserted'  From dbo.Fact_LBH_RoomCleaning(NoLock) 
	Exec dbo.PB_Log_Insert 'Fact_LBH_RoomCleaning',@Desc,'LBH Room Cleaning'

	Set NoCount OFF;
END
