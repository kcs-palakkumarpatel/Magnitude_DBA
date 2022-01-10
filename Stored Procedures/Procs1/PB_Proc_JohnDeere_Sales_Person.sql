

CREATE Procedure [dbo].[PB_Proc_JohnDeere_Sales_Person]
As
BEGIN
	set NoCount On;

	Declare @Desc Varchar(200)
	Exec dbo.PB_Log_Insert 'JohnDeere_Sales_Person','JohnDeere_Sales_Person Start','JohnDeere'

	Truncate table dbo.JohnDeere_Sales_Person

	Insert Into dbo.JohnDeere_Sales_Person([Sales Person Id],[Sales Person],Email,Mobile,[Join Date],[Area Manager]) 
	Select [Sales Person Id],[Sales Person],Email,Mobile,[Join Date],[Area Manager] From dbo.JD_BI_Vw_Sales_Person


	Select @Desc = 'JohnDeere_Sales_Person Completed.( '+  Convert(Varchar,Count(1)) + ' ) Records Inserted'  From dbo.JohnDeere_Sales_Person(NoLock) 
	Exec dbo.PB_Log_Insert 'JohnDeere_Sales_Person',@Desc,'JohnDeere'

	Set NoCount OFF;
END

