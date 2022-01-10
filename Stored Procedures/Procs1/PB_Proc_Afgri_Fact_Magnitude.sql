
CREATE Procedure [dbo].[PB_Proc_Afgri_Fact_Magnitude]
As
BEGIN
	set NoCount On;

	Declare @Desc Varchar(200)
	Exec dbo.PB_Log_Insert 'Afgri_Fact_Magnitude','Afgri_Fact_Magnitude Start','JDF'

	Truncate table dbo.Afgri_Fact_Magnitude

	Insert Into dbo.Afgri_Fact_Magnitude(Id,[Company Id],EstablishmentId ,EstablishmentGroupId ,[Sales Person Id],TownId,Result,
Status,[Sender MobileNo],Date,Latitude, Longitude,Likelihood,ClientName,SPName,TName,IsLikelihood) 
	Select Id,[Company Id],EstablishmentId ,EstablishmentGroupId ,[Sales Person Id],TownId,Result,
Status,[Sender MobileNo],Date,Latitude, Longitude,Likelihood,ClientName,SPName,TName,IsLikelihood From dbo.BI_Vw_FACT_Magnitude


	Select @Desc = 'Afgri_Fact_Magnitude Completed.( '+  Convert(Varchar,Count(1)) + ' ) Records Inserted'  From dbo.Afgri_Fact_Magnitude(NoLock) 
	Exec dbo.PB_Log_Insert 'Afgri_Fact_Magnitude',@Desc,'Afgri'


	Exec dbo.PB_Log_Insert 'Dim_UpdateDateTimeJDF','Dim_UpdateDateTimeAfgri Start','Afgri'


	Truncate table dbo.Dim_UpdateDateTimeAfgri

	Insert Into dbo.Dim_UpdateDateTimeAfgri
	Select * From [dbo].[Vw_Dim_UpdateDateTime]

	Select @Desc = 'Dim_UpdateDateTimeAfgri Completed.( 1 ) Records Inserted' 
	Exec dbo.PB_Log_Insert 'Dim_UpdateDateTimeAfgri',@Desc,'Afgri'

	Set NoCount OFF;
END

