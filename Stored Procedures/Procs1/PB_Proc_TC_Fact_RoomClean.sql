Create Procedure [dbo].[PB_Proc_TC_Fact_RoomClean]
As
BEGIN
	set NoCount On;

	Declare @Desc Varchar(200)
	Exec dbo.PB_Log_Insert 'TC_Dim_Rooms','TC_Dim_Rooms Start','Tsebo Cleaning'

	Truncate table dbo.TC_Dim_Rooms

	
	Insert into TC_Dim_Rooms(Id, EstablishmentName)
	select Id, EstablishmentName	 from [PB_VW_TC_Dim_Rooms]

	Select @Desc = 'TC_Dim_Rooms Completed.( '+  Convert(Varchar,Count(1)) + ' ) Records Inserted'  From dbo.TC_Dim_Rooms(NoLock) 
	Exec dbo.PB_Log_Insert 'TC_Dim_Rooms',@Desc,'Tsebo Cleaning'

	Exec dbo.PB_Log_Insert 'TC_Fact_RoomClean','TC_Fact_RoomClean Start','Tsebo Cleaning'

	Truncate table dbo.TC_Fact_RoomClean

	
	Insert into TC_Fact_RoomClean(EstablishmentId,EstablishmentName,CapturedDate,ReferenceNo,Status,UserName,
	[Cleaner Name],[Type of Clean],[Planned Beds],StatusTime,StatusName,[Total Beds in Room])
	select EstablishmentId,EstablishmentName,CapturedDate,ReferenceNo,Status,UserName,
	[Cleaner Name],[Type of Clean],[Planned Beds],StatusTime,StatusName,[Total Beds in Room]
	 from [PB_VW_TC_Fact_RoomClean]

	Select @Desc = 'TC_Fact_RoomClean Completed.( '+  Convert(Varchar,Count(1)) + ' ) Records Inserted'  From dbo.TC_Fact_RoomClean(NoLock) 
	Exec dbo.PB_Log_Insert 'TC_Fact_RoomClean',@Desc,'Tsebo Cleaning'

	Set NoCount OFF;
END
