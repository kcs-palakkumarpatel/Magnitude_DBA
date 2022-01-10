Create Procedure [dbo].[PB_Proc_Stef_Fact_Covid]
As
BEGIN
	set NoCount On;

	Declare @Desc Varchar(200)
	Exec dbo.PB_Log_Insert 'Stef_Fact_Covid','Stef_Fact_Covid Start','Stef Stocks'

	Truncate table dbo.Stef_Fact_Covid

	
	Insert into Stef_Fact_Covid(EstablishmentName,ReferenceNo,ResponsibleUser,StatusDateTime,StatusName,ResponseDate,ResponseReferenceNo,[Location],[Fever],[Cough],
	[Sore Throat],[Headache],[Household Members],[Tiredness],[Shortness of Breat],[Aches and pains],
[Diarrhoea],[Nausea],[Runny Nose],[Comments],Longitude,Latitude)
	select EstablishmentName,ReferenceNo,ResponsibleUser,StatusDateTime,StatusName,ResponseDate,ResponseReferenceNo,[Location],[Fever],[Cough],
	[Sore Throat],[Headache],[Household Members],[Tiredness],[Shortness of Breat],[Aches and pains],
[Diarrhoea],[Nausea],[Runny Nose],[Comments],Longitude,Latitude
	 from [PB_VW_Stef_Fact_Covid]

	Select @Desc = 'Stef_Fact_Covid Completed.( '+  Convert(Varchar,Count(1)) + ' ) Records Inserted'  From dbo.Stef_Fact_Covid(NoLock) 
	Exec dbo.PB_Log_Insert 'Stef_Fact_Covid',@Desc,'Stef Stocks'

	Set NoCount OFF;
END
