CREATE Procedure [dbo].[PB_Proc_TSG_Fact_Covid]
As
BEGIN
	set NoCount On;

	Declare @Desc Varchar(200)
	Exec dbo.PB_Log_Insert 'TSG_Fact_Covid','TSG_Fact_Covid Start','Tsebo Group'

	Truncate table dbo.TSG_Fact_Covid

	
	Insert into TSG_Fact_Covid(EstablishmentName,ReferenceNo,ResponsibleUser,StatusDateTime,StatusName,ResponseDate,ResponseReferenceNo,[Location],[Fever],[Cough],
	[Sore Throat],[Headache],[Household Members],[Comments],Longitude,Latitude)
	select EstablishmentName,ReferenceNo,ResponsibleUser,StatusDateTime,StatusName,ResponseDate,ResponseReferenceNo,[Location],[Fever],[Cough],
	[Sore Throat],[Headache],[Household Members],[Comments],Longitude,Latitude
	 from [PB_VW_TSG_Fact_Covid]

	Select @Desc = 'TSG_Fact_Covid Completed.( '+  Convert(Varchar,Count(1)) + ' ) Records Inserted'  From dbo.TSG_Fact_Covid(NoLock) 
	Exec dbo.PB_Log_Insert 'TSG_Fact_Covid',@Desc,'Tsebo Group'

	Set NoCount OFF;
END
