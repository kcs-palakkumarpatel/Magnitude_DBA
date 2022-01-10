CREATE Procedure [dbo].[PB_Proc_TC_Fact_Covid]
As
BEGIN
	set NoCount On;

	Declare @Desc Varchar(200)
	Exec dbo.PB_Log_Insert 'TC_Fact_Covid','TC_Fact_Covid Start','Tsebo Cleaning'

	Truncate table dbo.TC_Fact_Covid

	
	Insert into TC_Fact_Covid(EstablishmentName,ReferenceNo,ResponsibleUser,StatusDateTime,StatusName,ResponseDate,ResponseReferenceNo,[Location],[Fever],[Cough],
	[Sore Throat],[Headache],[Household Members],[Comments],Longitude,Latitude)
	select EstablishmentName,ReferenceNo,ResponsibleUser,StatusDateTime,StatusName,ResponseDate,ResponseReferenceNo,[Location],[Fever],[Cough],
	[Sore Throat],[Headache],[Household Members],[Comments],Longitude,Latitude
	 from [PB_VW_TC_Fact_Covid]

	Select @Desc = 'TC_Fact_Covid Completed.( '+  Convert(Varchar,Count(1)) + ' ) Records Inserted'  From dbo.TC_Fact_Covid(NoLock) 
	Exec dbo.PB_Log_Insert 'TC_Fact_Covid',@Desc,'Tsebo Cleaning'

	Set NoCount OFF;
END
