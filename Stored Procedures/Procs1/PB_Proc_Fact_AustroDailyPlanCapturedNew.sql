
CREATE Procedure [dbo].[PB_Proc_Fact_AustroDailyPlanCapturedNew]
As
BEGIN
	set NoCount On;

	Declare @Desc Varchar(200)
	Exec dbo.PB_Log_Insert 'Fact_AustroDailyPlanCapturedNew','Fact_AustroDailyPlanCapturedNew Start','Austro'

	--Truncate table dbo.Fact_AustroDailyPlanCapturedNew

	delete From Fact_AustroDailyPlanCapturedNew where Flag=0
	
	Insert into Fact_AustroDailyPlanCapturedNew(EstablishmentName,CapturedDate,ReferenceNo,IsPositive,Status,PI,UserId,UserName,ResolvedDate,
Longitude,Latitude,[Clients Today],[Client Time Today],[Non-Client Time],[Whats the plan for],Flag)
	select EstablishmentName,CapturedDate,ReferenceNo,IsPositive,Status,PI,UserId,UserName,ResolvedDate,
Longitude,Latitude,[Clients Today],[Client Time Today],[Non-Client Time],[Whats the plan for], 0 as Flag
	 from [PB_VW_Fact_AustroDailyPlanCapturedNew]

	Select @Desc = 'Fact_AustroDailyPlanCapturedNew Completed.( '+  Convert(Varchar,Count(1)) + ' ) Records Inserted'  From dbo.Fact_AustroDailyPlanCapturedNew(NoLock) 
	Exec dbo.PB_Log_Insert 'Fact_AustroDailyPlanCapturedNew',@Desc,'Austro'

	
	Set NoCount OFF;
END
