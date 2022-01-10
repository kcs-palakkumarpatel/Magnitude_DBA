

Create Procedure [dbo].[PB_Proc_Topbet_Fact_MaintenanceRequest]
As
	set NoCount On;

	Declare @Desc Varchar(200)
	Exec dbo.PB_Log_Insert 'Topbet_Fact_MaintenanceRequest','Topbet_Fact_MaintenanceRequest Start','Topbet'

	Truncate table dbo.Topbet_Fact_MaintenanceRequest

	
	Insert into Topbet_Fact_MaintenanceRequest(EstablishmentName,CapturedDate,ReferenceNo,IsPositive,Status,
UserId,UserName,Longitude,Latitude,[Name],[Maintenance Type],[IT Category],[Security Cat.],[Equipment Cat.],
[Property Cat.],[Description],[Issue Impact],[Is this a maintena],ResponseDate,SeenClientAnswerMasterId,CustomerName,
[Issue Cause],[Rectify Problem])
	select EstablishmentName,CapturedDate,ReferenceNo,IsPositive,Status,
UserId,UserName,Longitude,Latitude,[Name],[Maintenance Type],[IT Category],[Security Cat.],[Equipment Cat.],
[Property Cat.],[Description],[Issue Impact],[Is this a maintena],ResponseDate,SeenClientAnswerMasterId,CustomerName,
[Issue Cause],[Rectify Problem]
	 from [PB_VW_Topbet_Fact_MaintenanceRequest]

	Select @Desc = 'Topbet_Fact_MaintenanceRequest Completed.( '+  Convert(Varchar,Count(1)) + ' ) Records Inserted'  From dbo.Topbet_Fact_MaintenanceRequest(NoLock) 
	Exec dbo.PB_Log_Insert 'Topbet_Fact_MaintenanceRequest',@Desc,'Masslift'
	Set NoCount OFF;
