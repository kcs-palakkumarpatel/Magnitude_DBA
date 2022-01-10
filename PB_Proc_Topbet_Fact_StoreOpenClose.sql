



Create Procedure [dbo].[PB_Proc_Topbet_Fact_StoreOpenClose]
As
BEGIN
	set NoCount On;

	Declare @Desc Varchar(200)
	Exec dbo.PB_Log_Insert 'Topbet_Fact_StoreOpenClose','Topbet_Fact_StoreOpenClose Start','Topbet'

	Truncate table dbo.Topbet_Fact_StoreOpenClose

	
	Insert into Topbet_Fact_StoreOpenClose(EstablishmentName,	CapturedDate,	ReferenceNo,	IsPositive,
	Status,	PI,UserId,UserName,Longitude,Latitude,[Branch manager],[Turnstile count],[Aircons],[AC Not Working],
[TV],[TV Comment],[Cust. Monitors],[Cust. Monitors Comment],[Staff W/Stations],[W/Stations Broken],[Customer Wifi],
[BetGames Displays],[BetGames Broken],[Branch Clean],[Customer Furniture],[Customer Toilets],[Staff Kitchen Area],
[Snake queues safe?],[Comments],[CCTV System],[Door Security],[G4S Scheduled],[G4S Scheduled Time],[All Staff On Duty],
[Who is not on duty],[A4 Paper Quantity],[Till Roll (Boxes)],[General Comments],ResponseDate,SeenClientAnswerMasterId,
CustomerName,[Maintain request],[Pay & Rec Submit],[Overtime Requested],[General Comments1],[Incidents],[incident detail],
[Adhoc Exp P/Cash],[What did you buy])
	select EstablishmentName,	CapturedDate,	ReferenceNo,	IsPositive,
	Status,	PI,UserId,UserName,Longitude,Latitude,[Branch manager],[Turnstile count],[Aircons],[AC Not Working],
[TV],[TV Comment],[Cust. Monitors],[Cust. Monitors Comment],[Staff W/Stations],[W/Stations Broken],[Customer Wifi],
[BetGames Displays],[BetGames Broken],[Branch Clean],[Customer Furniture],[Customer Toilets],[Staff Kitchen Area],
[Snake queues safe?],[Comments],[CCTV System],[Door Security],[G4S Scheduled],[G4S Scheduled Time],[All Staff On Duty],
[Who is not on duty],[A4 Paper Quantity],[Till Roll (Boxes)],[General Comments],ResponseDate,SeenClientAnswerMasterId,
CustomerName,[Maintain request],[Pay & Rec Submit],[Overtime Requested],[General Comments1],[Incidents],[incident detail],
[Adhoc Exp P/Cash],[What did you buy]
	 from [PB_VW_Topbet_Fact_StoreOpenClose]

	Select @Desc = 'Topbet_Fact_StoreOpenClose Completed.( '+  Convert(Varchar,Count(1)) + ' ) Records Inserted'  From dbo.Topbet_Fact_StoreOpenClose(NoLock) 
	Exec dbo.PB_Log_Insert 'Topbet_Fact_StoreOpenClose',@Desc,'Topbet'

	Exec dbo.PB_Log_Insert 'Dim_UpdateDateTime_Topbet','Dim_UpdateDateTime_Topbet Start','Topbet'


	Truncate table dbo.[Dim_UpdateDateTime_Topbet]

	Insert Into dbo.[Dim_UpdateDateTime_Topbet]
	Select * From [dbo].[Vw_Dim_UpdateDateTime]

	Select @Desc = 'Dim_UpdateDateTime_Topbet Completed.( 1 ) Records Inserted' 
	Exec dbo.PB_Log_Insert 'Dim_UpdateDateTime_Topbet',@Desc,'Topbet'
	Set NoCount OFF;
END
