
CREATE Procedure [dbo].[PB_Proc_Fact_Pegasus_DailyPlan]
As
BEGIN
	set NoCount On;

	Declare @Desc Varchar(200)
	Exec dbo.PB_Log_Insert 'Fact_Pegasus_DailyPlan','Fact_Pegasus_DailyPlan Start','Pegasus'

	Truncate table dbo.[Fact_Pegasus_Daily Plan]
	
	Insert into [Fact_Pegasus_Daily Plan]([EstablishmentName],[CapturedDate],[ReferenceNo],[IsPositive],[Status],[UserName],[Clients Today],[Client Time] ,
	[Non-Client Time],[What is the plan] ,[Area],ResponseReference,[Time travelled],[KM travelled],[Response Time Taken],[Response Description of Work] ,
	[Achieved Goals],[If no,Explain],[If Other,specify],[Non-client tasks],Activity,Customer,TimeTakenForEngagement,[Meeting Summary])
select 
	[EstablishmentName],[CapturedDate],[ReferenceNo],[IsPositive],[Status],[UserName],[Clients Today],[Client Time] ,
	[Non-Client Time],[What is the plan] ,[Area],ResponseReference,[Time travelled],[KM travelled],[Response Time Taken],[Response Description of Work] ,
	[Achieved Goals],[If no,Explain],[If Other,specify],[Non-client tasks],Activity,Customer,TimeTakenForEngagement,[Meeting Summary]
  from PB_VW_Fact_Pegasus_DailyPlan

	Select @Desc = 'Fact_Pegasus_DailyPlan Completed.( '+  Convert(Varchar,Count(1)) + ' ) Records Inserted'  From dbo.[Fact_Pegasus_Daily Plan](NoLock) 
	Exec dbo.PB_Log_Insert 'Fact_Pegasus_DailyPlan',@Desc,'Pegasus'

	Truncate table dbo.Dim_UpdateDateTimePegasus

	Insert Into dbo.Dim_UpdateDateTimePegasus
	Select * From [dbo].[Vw_Dim_UpdateDateTime]

	Select @Desc = 'Dim_UpdateDateTimePegasus Completed.( 1 ) Records Inserted' 
	Exec dbo.PB_Log_Insert 'Dim_UpdateDateTimePegasus',@Desc,'Pegasus'


	Set NoCount OFF;
END
