

CREATE Procedure [dbo].[PB_Proc_JDF_Sales_Person]
As
BEGIN
	set NoCount On;

	Declare @Desc Varchar(200)
	Exec dbo.PB_Log_Insert 'JDF_Sales_Person','JDF_Sales_Person Start','JDF'

	Truncate table dbo.JDF_Sales_Person

	Insert Into dbo.JDF_Sales_Person([Sales Person Id],[Sales Person]) 
	Select [Sales Person Id],[Sales Person] From dbo.JDF_BI_Vw_Sales_Person


	Select @Desc = 'JDF_Sales_Person Completed.( '+  Convert(Varchar,Count(1)) + ' ) Records Inserted'  From dbo.JDF_Sales_Person(NoLock) 
	Exec dbo.PB_Log_Insert 'JDF_Sales_Person',@Desc,'JDF'

	Set NoCount OFF;
END

