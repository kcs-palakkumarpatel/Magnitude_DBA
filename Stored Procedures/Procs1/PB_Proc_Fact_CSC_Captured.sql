CREATE Procedure [dbo].[PB_Proc_Fact_CSC_Captured]
As
BEGIN
	set NoCount On;

	Declare @Desc Varchar(200)
	Exec dbo.PB_Log_Insert 'Fact_CSC_Captured','Fact_CSC_Captured Start','Car Service City'

	Truncate table dbo.Fact_CSC_Captured
	
	Insert into Fact_CSC_Captured(EstablishmentName,CapturedDate,ReferenceNo,[Name],[Surname],[Cell],[Email],[Gender],
[Ethnic Group],[Alternate Number],[Vehicle Registration])
select 
	EstablishmentName,CapturedDate,ReferenceNo,[Name],[Surname],[Cell],[Email],[Gender],
[Ethnic Group],[Alternate Number],[Vehicle Registration]
  from PB_VW_Fact_CSC_Captured

	Select @Desc = 'Fact_CSC_Captured Completed.( '+  Convert(Varchar,Count(1)) + ' ) Records Inserted'  From dbo.Fact_CSC_Captured(NoLock) 
	Exec dbo.PB_Log_Insert 'Fact_CSC_Captured',@Desc,'Car Service City'

	Truncate table dbo.Dim_UpdateDateTimeCSC

	Insert Into dbo.Dim_UpdateDateTimeCSC
	Select * From [dbo].[Vw_Dim_UpdateDateTime]

	Select @Desc = 'Dim_UpdateDateTimeCSC Completed.( 1 ) Records Inserted' 
	Exec dbo.PB_Log_Insert 'Dim_UpdateDateTimeCSC',@Desc,'Reef Catering'


	Set NoCount OFF;
END
