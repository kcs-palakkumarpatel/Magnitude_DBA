CREATE Procedure [dbo].[PB_Proc_Fact_Infraset_DigitalDiary]
As
BEGIN
	set NoCount On;

	Declare @Desc Varchar(200)
	Exec dbo.PB_Log_Insert 'Fact_Infraset_DigitalDiary','Fact_Infraset_DigitalDiary Start','Infraset'

	Truncate table dbo.Fact_Infraset_DigitalDiary
	
	Insert into Fact_Infraset_DigitalDiary(EstablishmentName,CapturedDate,ReferenceNo,IsPositive,Status,PI,UserId,UserName,ResolvedDate,
Longitude,Latitude ,[Name & Surname],[Customer Company Name],[Mobile Number],[Email Address],[Digital Diary],[Date of Meeting],[Time of Meeting],
[Meeting Location],[Meeting With],[Your plan for this],[Meeting Purpose],[Customer Name],[Company Name])
select 
EstablishmentName,CapturedDate,ReferenceNo,IsPositive,Status,PI,UserId,UserName,ResolvedDate,
Longitude,Latitude ,[Name & Surname],[Customer Company Name],[Mobile Number],[Email Address],[Digital Diary],[Date of Meeting],[Time of Meeting],
[Meeting Location],[Meeting With],[Your plan for this],[Meeting Purpose],[Customer Name],[Company Name]
  from PB_VW_Fact_Infraset_DigitalDiary

	Select @Desc = 'Fact_Infraset_DigitalDiary Completed.( '+  Convert(Varchar,Count(1)) + ' ) Records Inserted'  From dbo.Fact_Infraset_DigitalDiary(NoLock) 
	Exec dbo.PB_Log_Insert 'Fact_Infraset_DigitalDiary',@Desc,'Infraset'

	Truncate table dbo.Dim_UpdateDateTimeInfraset

	Insert Into dbo.Dim_UpdateDateTimeInfraset
	Select * From [dbo].[Vw_Dim_UpdateDateTime]

	Select @Desc = 'Dim_UpdateDateTimeInfraset Completed.( 1 ) Records Inserted' 
	Exec dbo.PB_Log_Insert 'Dim_UpdateDateTimeInfraset',@Desc,'infraset'


	Set NoCount OFF;
END
