

Create Procedure [dbo].[PB_Proc_Topbet_Fact_MaintenancePlanning]
As
	set NoCount On;

	Declare @Desc Varchar(200)
	Exec dbo.PB_Log_Insert 'Topbet_Fact_MaintenancePlanning','Topbet_Fact_MaintenancePlanning Start','Topbet'

	Truncate table dbo.Topbet_Fact_MaintenancePlanning

	
	Insert into Topbet_Fact_MaintenancePlanning(EstablishmentName,	CapturedDate,	ReferenceNo,	IsPositive,
	Status,UserId,UserName,Longitude,Latitude,RepeatCount,[Planned tasks],[Surprise tasks],[Made easier],[Notes for the day],
[Locations visited],[Type of task],[Job overview],[From request],[Time Spent on task],[Comments])
	select EstablishmentName,	CapturedDate,	ReferenceNo,	IsPositive,
	Status,UserId,UserName,Longitude,Latitude,RepeatCount,[Planned tasks],[Surprise tasks],[Made easier],[Notes for the day],
[Locations visited],[Type of task],[Job overview],[From request],[Time Spent on task],[Comments]
	 from [PB_VW_Topbet_Fact_MaintenancePlanning]

	Select @Desc = 'Topbet_Fact_MaintenancePlanning Completed.( '+  Convert(Varchar,Count(1)) + ' ) Records Inserted'  From dbo.Topbet_Fact_MaintenancePlanning(NoLock) 
	Exec dbo.PB_Log_Insert 'Topbet_Fact_MaintenancePlanning',@Desc,'Topbet'
	Set NoCount OFF;
