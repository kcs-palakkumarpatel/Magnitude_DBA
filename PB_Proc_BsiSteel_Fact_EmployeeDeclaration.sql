CREATE Procedure [dbo].[PB_Proc_BsiSteel_Fact_EmployeeDeclaration]
As
BEGIN
	set NoCount On;

	Declare @Desc Varchar(200)
	Exec dbo.PB_Log_Insert 'BsiSteel_Fact_EmployeeDeclaration','BsiSteel_Fact_EmployeeDeclaration Start','Bsi Steel'

	Truncate table dbo.BsiSteel_Fact_EmployeeDeclaration

	
	Insert into BsiSteel_Fact_EmployeeDeclaration(EstablishmentName,[ReferenceNo],Latitude,Longitude,[Form Status],[Captured Date],
ResponsibleUser,[UserName],[Name],[Surname],[Cell],[Email],Activity,[Mobile],
[ResponseReferenceNo],IsPositive,PI,[ResponseDate],[Response Lat],[ Response Long],
[ SeenClientMasterId],ResponseResponsibleUser,[Location],[If other],[Fever],
[Dry Cough],[Sore Throat],[Headache],[Extreme Tiredness],[Breath Shortness],
[Aches and Pains],[Diarrhoea],[Nausea],[Runny Nose],[Repeated Shaking],
[Chills],[Muscle Pain],[Lost taste/smell],[Household members])
	select EstablishmentName,[ReferenceNo],Latitude,Longitude,[Form Status],[Captured Date],
ResponsibleUser,[UserName],[Name],[Surname],[Cell],[Email],Activity,[Mobile],
[ResponseReferenceNo],IsPositive,PI,[ResponseDate],[Response Lat],[ Response Long],
[ SeenClientMasterId],ResponseResponsibleUser,[Location],[If other],[Fever],
[Dry Cough],[Sore Throat],[Headache],[Extreme Tiredness],[Breath Shortness],
[Aches and Pains],[Diarrhoea],[Nausea],[Runny Nose],[Repeated Shaking],
[Chills],[Muscle Pain],[Lost taste/smell],[Household members]
	 from [PB_VW_BsiSteel_Fact_EmployeeDeclaration]

	Select @Desc = 'BsiSteel_Fact_EmployeeDeclaration Completed.( '+  Convert(Varchar,Count(1)) + ' ) Records Inserted'  From dbo.BsiSteel_Fact_EmployeeDeclaration(NoLock) 
	Exec dbo.PB_Log_Insert 'BsiSteel_Fact_EmployeeDeclaration',@Desc,'Bsi Steel'

	Set NoCount OFF;
END
