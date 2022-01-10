
CREATE Procedure [dbo].[PB_Proc_Austro_Fact_Captured]
As
BEGIN
	set NoCount On;

	Declare @Desc Varchar(200)
	Exec dbo.PB_Log_Insert 'Austro_Fact_Captured','Austro_Fact_Captured Start','Austro'

	--Truncate table dbo.Austro_Fact_Captured
	delete From dbo.Austro_Fact_Captured where flag=0
	
	Insert into Austro_Fact_Captured(Activity,CapturedDate,ReferenceNo,SalesPerson,Longitude,Latitude,[Company Name],
	[Company tier],[Brands Presented],[Short Feedback],[Long Feedback],[Was Trevor with you during the meeting?],flag)
	select Activity, CapturedDate,ReferenceNo,SalesPerson,Longitude,Latitude,[Company Name],
	[Company tier],[Brands Presented],[Short Feedback],[Long Feedback],[Was Trevor with you during the meeting?],0 as Flag
	 from [PB_VW_Austro_Fact_Captured]

	Select @Desc = 'Austro_Fact_Captured Completed.( '+  Convert(Varchar,Count(1)) + ' ) Records Inserted'  From dbo.Austro_Fact_Captured(NoLock) 
	Exec dbo.PB_Log_Insert 'Austro_Fact_Captured',@Desc,'Austro'

	Exec dbo.PB_Log_Insert 'Dim_UpdateDateTime_Austro','Dim_UpdateDateTime_Austro Start','Austro'


	Truncate table dbo.[Dim_UpdateDateTime_Austro]

	Insert Into dbo.[Dim_UpdateDateTime_Austro]
	Select * From [dbo].[Vw_Dim_UpdateDateTime]

	Select @Desc = 'Dim_UpdateDateTime_Austro Completed.( 1 ) Records Inserted' 
	Exec dbo.PB_Log_Insert 'Dim_UpdateDateTime_Austro',@Desc,'Austro'
	Set NoCount OFF;
END
