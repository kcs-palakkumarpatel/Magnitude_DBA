

CREATE Procedure [dbo].[PB_Proc_Afgri_Sales_Person]
As
BEGIN
	set NoCount On;

	Declare @Desc Varchar(200)
	Exec dbo.PB_Log_Insert 'Afgri_Sales_Person','Afgri_Sales_Person Start','Afgri'

	Truncate table dbo.Afgri_Sales_Person

	Insert Into dbo.Afgri_Sales_Person([Sales Person Id],[Sales Person],Email,Mobile,[Join Date],[Area Manager]) 
	Select [Sales Person Id],[Sales Person],Email,Mobile,[Join Date],[Area Manager] From dbo.BI_Vw_Sales_Person


	Select @Desc = 'Afgri_Sales_Person Completed.( '+  Convert(Varchar,Count(1)) + ' ) Records Inserted'  From dbo.Afgri_Sales_Person(NoLock) 
	Exec dbo.PB_Log_Insert 'Afgri_Sales_Person',@Desc,'Afgri'

	Set NoCount OFF;
END

