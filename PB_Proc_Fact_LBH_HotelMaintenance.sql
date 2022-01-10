

CREATE Procedure [dbo].[PB_Proc_Fact_LBH_HotelMaintenance]
As
BEGIN
	set NoCount On;

	Declare @Desc Varchar(200)
	Exec dbo.PB_Log_Insert 'Fact_LBH_HotelMaintenance','Fact_LBH_HotelMaintenance Start','LBH Hotel Maintenance'

	Truncate table dbo.Fact_LBH_HotelMaintenance

	
	Insert into Fact_LBH_HotelMaintenance(EstablishmentName,CapturedDate,ReferenceNo,Status,UserName,
ResolvedDate,FirstResponseDate,FirstActionDate,ProgressDate,JobDoneDate,[What is broken],[Room Number],
[Cause],[Urgency],[Category],[Comments],IsOutStanding,ResponseDate,SeenClientAnswerMasterId,[Time Acceptable],[Good Quality])
	select EstablishmentName,CapturedDate,ReferenceNo,Status,UserName,
ResolvedDate,FirstResponseDate,FirstActionDate,ProgressDate,JobDoneDate,[What is broken],[Room Number],
[Cause],[Urgency],[Category],[Comments],IsOutStanding,ResponseDate,SeenClientAnswerMasterId,[Time Acceptable],[Good Quality]
	 from PB_VW_Fact_LBH_HotelMaintenance

	Select @Desc = 'Fact_LBH_HotelMaintenance Completed.( '+  Convert(Varchar,Count(1)) + ' ) Records Inserted'  From dbo.Fact_LBH_HotelMaintenance(NoLock) 
	Exec dbo.PB_Log_Insert 'Fact_LBH_HotelMaintenance',@Desc,'LBH Hotel Maintenance'

		Exec dbo.PB_Log_Insert 'Dim_UpdateDateTime_LBH','Dim_UpdateDateTime_LBH Start','LBH Hotel Maintenance'


	Truncate table dbo.[Dim_UpdateDateTime_LBH]

	Insert Into dbo.[Dim_UpdateDateTime_LBH]
	Select * From [dbo].[Vw_Dim_UpdateDateTime]

	Select @Desc = 'Dim_UpdateDateTime_LBH Completed.( 1 ) Records Inserted' 
	Exec dbo.PB_Log_Insert 'Dim_UpdateDateTime_LBH',@Desc,'LBH Hotel Maintenance'
	Set NoCount OFF;
END
