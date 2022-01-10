
CREATE Procedure [dbo].[PB_Proc_JohnDeere_Fact_Magnitude]
As
BEGIN
	set NoCount On;

	Declare @Desc Varchar(200)
	Exec dbo.PB_Log_Insert 'JohnDeere_Fact_Magnitude','JohnDeere_Fact_Magnitude Start','JohnDeere'

	Truncate table dbo.JohnDeere_Fact_Magnitude

	Insert Into dbo.JohnDeere_Fact_Magnitude(Id,[Company Id],EstablishmentId ,EstablishmentGroupId ,[Sales Person Id],TownId,Result,
Status,[Sender MobileNo],Date,Latitude, Longitude,Likelihood,ClientName,SPName,TName,IsLikelihood) 
	Select Id,[Company Id],EstablishmentId ,EstablishmentGroupId ,[Sales Person Id],TownId,Result,
Status,[Sender MobileNo],Date,Latitude, Longitude,Likelihood,ClientName,SPName,TName,IsLikelihood From dbo.JD_BI_Vw_FACT_Magnitude


	Select @Desc = 'JohnDeere_Fact_Magnitude Completed.( '+  Convert(Varchar,Count(1)) + ' ) Records Inserted'  From dbo.JohnDeere_Fact_Magnitude(NoLock) 
	Exec dbo.PB_Log_Insert 'JohnDeere_Fact_Magnitude',@Desc,'JohnDeere'


	Exec dbo.PB_Log_Insert 'Dim_UpdateDateTimeJohnDeere','Dim_UpdateDateTimeJohnDeere Start','JohnDeere'


	Truncate table dbo.Dim_UpdateDateTimeJohnDeere

	Insert Into dbo.Dim_UpdateDateTimeJohnDeere
	Select * From [dbo].[Vw_Dim_UpdateDateTime]

	Select @Desc = 'Dim_UpdateDateTimeJohnDeere Completed.( 1 ) Records Inserted' 
	Exec dbo.PB_Log_Insert 'Dim_UpdateDateTimeJohnDeere',@Desc,'JohnDeere'

	Set NoCount OFF;
END

