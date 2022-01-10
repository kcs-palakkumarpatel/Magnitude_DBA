
Create Procedure [dbo].[PB_Proc_Topbet_Fact_OvertimeRequest]
As
	set NoCount On;

	Declare @Desc Varchar(200)
	Exec dbo.PB_Log_Insert 'Topbet_Fact_OvertimeRequest','Topbet_Fact_OvertimeRequest Start','Topbet'

	Truncate table dbo.Topbet_Fact_OvertimeRequest

	
	Insert into Topbet_Fact_OvertimeRequest(EstablishmentName,CapturedDate,ReferenceNo,IsPositive,Status,
UserId,UserName,Longitude,Latitude,[Branch manager],[Full Name Employee],[Employee Number],[Overtime Date],
[How many overtime],[Overtime Reason],[Motivation],ResponseDate,SeenClientAnswerMasterId,CustomerName,
[Approval],[Comments])
	select EstablishmentName,CapturedDate,ReferenceNo,IsPositive,Status,
UserId,UserName,Longitude,Latitude,[Branch manager],[Full Name Employee],[Employee Number],[Overtime Date],
[How many overtime],[Overtime Reason],[Motivation],ResponseDate,SeenClientAnswerMasterId,CustomerName,
[Approval],[Comments]
	 from [PB_VW_Topbet_Fact_OvertimeRequest]

	Select @Desc = 'Topbet_Fact_OvertimeRequest Completed.( '+  Convert(Varchar,Count(1)) + ' ) Records Inserted'  From dbo.Topbet_Fact_OvertimeRequest(NoLock) 
	Exec dbo.PB_Log_Insert 'Topbet_Fact_OvertimeRequest',@Desc,'Topbet'
	Set NoCount OFF;
