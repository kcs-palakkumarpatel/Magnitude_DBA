


Create Procedure [dbo].[PB_Proc_Masslift_Fact_DailyPlanCaptured]
As
BEGIN
	set NoCount On;

	Declare @Desc Varchar(200)
	Exec dbo.PB_Log_Insert 'Masslift_Fact_DailyPlanCaptured','Masslift_Fact_DailyPlanCaptured Start','Masslift'

	Truncate table dbo.Masslift_Fact_DailyPlanCaptured

	
	Insert into Masslift_Fact_DailyPlanCaptured(EstablishmentName,CapturedDate,ReferenceNo,IsPositive,Status,PI,
UserId,UserName,[Area:],[Total Clients ],[Client Time],[Non-Client Time],[What is the plan])
	select EstablishmentName,CapturedDate,ReferenceNo,IsPositive,Status,PI,
UserId,UserName,[Area:],[Total Clients ],[Client Time],[Non-Client Time],[What is the plan]
	 from [PB_VW_Masslift_Fact_DailyPlanCaptured]

	Select @Desc = 'Masslift_Fact_DailyPlanCaptured Completed.( '+  Convert(Varchar,Count(1)) + ' ) Records Inserted'  From dbo.Masslift_Fact_DailyPlanCaptured(NoLock) 
	Exec dbo.PB_Log_Insert 'Masslift_Fact_DailyPlanCaptured',@Desc,'Masslift'

	Exec dbo.PB_Log_Insert 'Dim_UpdateDateTime_Masslift','Dim_UpdateDateTime_Masslift Start','Masslift'


	Truncate table dbo.[Dim_UpdateDateTime_Masslift]

	Insert Into dbo.[Dim_UpdateDateTime_Masslift]
	Select * From [dbo].[Vw_Dim_UpdateDateTime]

	Select @Desc = 'Dim_UpdateDateTime_Masslift Completed.( 1 ) Records Inserted' 
	Exec dbo.PB_Log_Insert 'Dim_UpdateDateTime_Masslift',@Desc,'Masslift'
	Set NoCount OFF;
END
