Create Procedure [dbo].[PB_Proc_DFC_Fact_Covid]
As
BEGIN
	set NoCount On;

	Declare @Desc Varchar(200)
	Exec dbo.PB_Log_Insert 'DFC_Fact_Covid','DFC_Fact_Covid Start','DFC'

	Truncate table dbo.DFC_Fact_Covid

	
	Insert into DFC_Fact_Covid(EstablishmentName,ReferenceNo,ResponsibleUser,StatusDateTime,StatusName,ResponseDate,ResponseReferenceNo,[Location],[Fever],[Cough],
	[Sore Throat],[Headache],[Household Members],[Comments],Longitude,Latitude)
	select EstablishmentName,ReferenceNo,ResponsibleUser,StatusDateTime,StatusName,ResponseDate,ResponseReferenceNo,[Location],[Fever],[Cough],
	[Sore Throat],[Headache],[Household Members],[Comments],Longitude,Latitude
	 from [PB_VW_DFC_Fact_Covid]

	Select @Desc = 'DFC_Fact_Covid Completed.( '+  Convert(Varchar,Count(1)) + ' ) Records Inserted'  From dbo.DFC_Fact_Covid(NoLock) 
	Exec dbo.PB_Log_Insert 'DFC_Fact_Covid',@Desc,'DFC'

	Set NoCount OFF;
END
