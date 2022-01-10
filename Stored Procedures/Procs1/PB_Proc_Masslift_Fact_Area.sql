CREATE Procedure [dbo].[PB_Proc_Masslift_Fact_Area]
As
BEGIN
	set NoCount On;

	Declare @Desc Varchar(200)
	Exec dbo.PB_Log_Insert 'Masslift_Fact_Area','Masslift_Fact_Area Start','Masslift'

	Truncate table dbo.Masslift_Fact_Area

	
	Insert into Masslift_Fact_Area(ReferenceNo,RepeatCount,[Area],[Target annual],[Used sales YTD],[Proposals],[Lost sales shelved],[Lost sales actual],[Orders for the month],
[Enquires],[Trucks/Area],[% of the Market],[Year],[Month])
	select ReferenceNo,RepeatCount,[Area],[Target annual],[Used sales YTD],[Proposals],[Lost sales shelved],[Lost sales actual],[Orders for the month],
[Enquires],[Trucks/Area],[% of the Market],[Year],[Month]
	 from [PB_VW_Masslift_Fact_Area]

	Select @Desc = 'Masslift_Fact_Area Completed.( '+  Convert(Varchar,Count(1)) + ' ) Records Inserted'  From dbo.Masslift_Fact_Area(NoLock) 
	Exec dbo.PB_Log_Insert 'Masslift_Fact_Area',@Desc,'Masslift'
	-------------------------------------------------------------------------------------------------------------------
	Exec dbo.PB_Log_Insert 'Masslift_Fact_MRValidations','Masslift_Fact_MRValidations Start','Masslift'

	Truncate table dbo.Masslift_Fact_MRValidations

	
	Insert into Masslift_Fact_MRValidations(Year,Month,[MR value])
	select Year,Month,[MR value]
	 from [PB_VW_Masslift_Fact_MRValidations]

	Select @Desc = 'Masslift_Fact_MRValidations Completed.( '+  Convert(Varchar,Count(1)) + ' ) Records Inserted'  From dbo.Masslift_Fact_MRValidations(NoLock) 
	Exec dbo.PB_Log_Insert 'Masslift_Fact_MRValidations',@Desc,'Masslift'
	Set NoCount OFF;
END
