CREATE Procedure [dbo].[PB_Proc_Fact_Covid]
As
BEGIN
	set NoCount On;

	Declare @Desc Varchar(200)
	Exec dbo.PB_Log_Insert 'Fact_Covid','Fact_Covid Start','Covid-19'

	Truncate table dbo.Fact_Covid

	
	Insert into Fact_Covid(ReferenceNo,ResponsibleUser,ResponseDate,ResponseReferenceNo,[Location],[Fever],[Cough],
	[Sore Throat],[Headache],[Household Members],[Comments])
	select ReferenceNo,ResponsibleUser,ResponseDate,ResponseReferenceNo,[Location],[Fever],[Cough],
	[Sore Throat],[Headache],[Household Members],[Comments]
	 from [PB_VW_Fact_Covid]

	Select @Desc = 'Fact_Covid Completed.( '+  Convert(Varchar,Count(1)) + ' ) Records Inserted'  From dbo.Fact_Covid(NoLock) 
	Exec dbo.PB_Log_Insert 'Fact_Covid',@Desc,'Covid-19'

	Set NoCount OFF;
END
