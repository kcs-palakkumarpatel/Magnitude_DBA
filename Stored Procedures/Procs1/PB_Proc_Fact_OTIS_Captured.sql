
CREATE Procedure [dbo].[PB_Proc_Fact_OTIS_Captured]
As
BEGIN
	set NoCount On;

	Declare @Desc Varchar(200)
	Exec dbo.PB_Log_Insert 'Fact_OTIS_Captured','Fact_OTIS_Captured Start','OTIS'

	Truncate table dbo.Fact_OTIS_Captured
	
	Insert into Fact_OTIS_Captured([EstablishmentName] ,[CapturedDate] ,[ReferenceNo] ,[IsPositive] ,[Status],[UserId] ,[UserName] ,[Building],	[Unit Number] ,	
	[Visit Type] ,	[Unit in good working order] ,	[Any other notes or comments about this visit],	[A possible T-Lead opportunity?] ,
	[If YES, give the brief and key details])
select 
	[EstablishmentName] ,[CapturedDate] ,[ReferenceNo] ,[IsPositive] ,[Status],[UserId] ,[UserName] ,[Building],	[Unit Number] ,	
	[Visit Type] ,	[Unit in good working order] ,	[Any other notes or comments about this visit],	[A possible T-Lead opportunity?] ,
	[If YES, give the brief and key details]
  from PB_VW_Fact_OTISCaptured

	Select @Desc = 'Fact_OTIS_Captured Completed.( '+  Convert(Varchar,Count(1)) + ' ) Records Inserted'  From dbo.Fact_OTIS_Captured(NoLock) 
	Exec dbo.PB_Log_Insert 'Fact_OTIS_Captured',@Desc,'OTIS'

	Truncate table dbo.Dim_OTIS_Unit
	
	Insert into Dim_OTIS_Unit([UnitNumber])
	select [Name] as UnitNumber from seenclientoptions where questionid=36373 and id<>289686

	Select @Desc = 'Dim_OTIS_Unit Completed.( '+  Convert(Varchar,Count(1)) + ' ) Records Inserted'  From dbo.Dim_OTIS_Unit(NoLock) 
	Exec dbo.PB_Log_Insert 'Dim_OTIS_Unit',@Desc,'OTIS'

	Truncate table dbo.Dim_UpdateDateTimeOTIS

	Insert Into dbo.Dim_UpdateDateTimeOTIS
	Select * From [dbo].[Vw_Dim_UpdateDateTime]

	Select @Desc = 'Dim_UpdateDateTimeOTIS Completed.( 1 ) Records Inserted' 
	Exec dbo.PB_Log_Insert 'Dim_UpdateDateTimeOTIS',@Desc,'OTIS'


	Set NoCount OFF;
END
