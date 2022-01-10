CREATE Procedure [dbo].[PB_Proc_MassLift_Fact_SalesStack_Order_Dealer]
As
BEGIN
	set NoCount On;

	Declare @Desc Varchar(200)
	Exec dbo.PB_Log_Insert 'Masslift_Fact_Salestack_Order','Masslift_Fact_Salestack_Order Start','Mass Lift'

	Truncate table dbo.Masslift_Fact_Salestack_Order

	
	Insert into Masslift_Fact_Salestack_Order(Year,Month,[Order Intake by Truck Type],[Target],Count)
	 
	 select Year,Month,[Order Intake by Truck Type],[Target],Count
	 from [PB_VW_Masslift_Fact_Salestack_Order]

	Select @Desc = 'Masslift_Fact_Salestack_Order Completed.( '+  Convert(Varchar,Count(1)) + ' ) Records Inserted'  From dbo.Masslift_Fact_Salestack_Order(NoLock) 
	Exec dbo.PB_Log_Insert 'Masslift_Fact_Salestack_Order',@Desc,'Mass Lift'

	-------------------------------------------------------------------------------------------------------------------
	Exec dbo.PB_Log_Insert 'Masslift_Fact_Salestack_Dealer','Masslift_Fact_Salestack_Dealer Start','MassLift'

	Truncate table dbo.Masslift_Fact_Salestack_Dealer

	
	Insert into Masslift_Fact_Salestack_Dealer([Year],Month,New,Used,Dealer,DealerCount)
	 
	 select [Year],Month,New,Used,Dealer,DealerCount
	 from PB_VW_Masslift_Fact_Salestack_Dealer

	Select @Desc = 'Masslift_Fact_Salestack_Dealer Completed.( '+  Convert(Varchar,Count(1)) + ' ) Records Inserted'  From dbo.Masslift_Fact_Salestack_Dealer(NoLock) 
	Exec dbo.PB_Log_Insert 'Masslift_Fact_Salestack_Dealer',@Desc,'MassLift'

	Set NoCount OFF;
END
