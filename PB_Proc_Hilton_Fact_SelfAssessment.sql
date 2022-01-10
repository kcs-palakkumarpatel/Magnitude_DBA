

Create Procedure [dbo].[PB_Proc_Hilton_Fact_SelfAssessment]
As
BEGIN
	set NoCount On;

	Declare @Desc Varchar(200)
	Exec dbo.PB_Log_Insert 'Hilton_Fact_SelftAssessment','Hilton_Fact_SelftAssessment Start','Hilton'

	Truncate table dbo.Hilton_Fact_SelftAssessment

	
	Insert into Hilton_Fact_SelftAssessment(EstablishmentName,ReferenceNo,CapturedDate,UserName,PrimaryContactName,StatusDateTime,StatusName,ResponseDate,ResponseReferenceNo,
[Student Name],[Location], [Other Location],[How do you Feel],[Fever],[Cough],
[Sore Throat],[Headache],[Shortness of Breat],[Aches and Pains],[Diarrhoea],[Household Members], [Comments],IsPositive,[Temperature (],[Heart racing])
	select EstablishmentName,ReferenceNo,CapturedDate,UserName,PrimaryContactName,StatusDateTime,StatusName,ResponseDate,ResponseReferenceNo,
[Student Name],[Location], [Other Location],[How do you Feel],[Fever],[Cough],
[Sore Throat],[Headache],[Shortness of Breat],[Aches and Pains],[Diarrhoea],[Household Members], [Comments],IsPositive,[Temperature (],[Heart racing]
	 from [PB_VW_Hilton_Fact_SelftAssessment]

	Select @Desc = 'Hilton_Fact_SelftAssessment Completed.( '+  Convert(Varchar,Count(1)) + ' ) Records Inserted'  From dbo.Hilton_Fact_SelftAssessment(NoLock) 
	Exec dbo.PB_Log_Insert 'Hilton_Fact_SelftAssessment',@Desc,'Hilton'


	Set NoCount OFF;
END
