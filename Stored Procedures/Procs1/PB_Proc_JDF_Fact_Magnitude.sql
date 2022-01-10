
CREATE Procedure [dbo].[PB_Proc_JDF_Fact_Magnitude]
As
BEGIN
	set NoCount On;

	Declare @Desc Varchar(200)
	Exec dbo.PB_Log_Insert 'JDF_Fact_Magnitude','JDF_Fact_Magnitude Start','JDF'

	Truncate table dbo.JDF_Fact_Magnitude

	Insert Into dbo.JDF_Fact_Magnitude(Id,SCAM_ID ,[Company Id],EstablishmentId ,EstablishmentGroupId ,[Sales Person Id],TownId,
Status,Date,Latitude, Longitude,SPName,TName,BranchName) 
	Select Id,SCAM_ID ,[Company Id],EstablishmentId ,EstablishmentGroupId ,[Sales Person Id],TownId,
Status,Date,Latitude, Longitude,SPName,TName,BranchName From dbo.JDF_BI_Vw_FACT_Magnitude


	Select @Desc = 'JDF_Fact_Magnitude Completed.( '+  Convert(Varchar,Count(1)) + ' ) Records Inserted'  From dbo.JDF_Fact_Magnitude(NoLock) 
	Exec dbo.PB_Log_Insert 'JDF_Fact_Magnitude',@Desc,'JDF'


	Exec dbo.PB_Log_Insert 'Dim_UpdateDateTimeJDF','Dim_UpdateDateTimeJDF Start','JDF'


	Truncate table dbo.Dim_UpdateDateTimeJDF

	Insert Into dbo.Dim_UpdateDateTimeJDF
	Select * From [dbo].[Vw_Dim_UpdateDateTime]

	Select @Desc = 'Dim_UpdateDateTimeJDF Completed.( 1 ) Records Inserted' 
	Exec dbo.PB_Log_Insert 'Dim_UpdateDateTimeJDF',@Desc,'JDF'

	Set NoCount OFF;
END

