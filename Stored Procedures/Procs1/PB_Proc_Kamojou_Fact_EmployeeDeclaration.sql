CREATE Procedure [dbo].[PB_Proc_Kamojou_Fact_EmployeeDeclaration]
As
BEGIN
	set NoCount On;

	Declare @Desc Varchar(200)
	Exec dbo.PB_Log_Insert 'Kamojou_Fact_EmployeeDeclaration','Kamojou_Fact_EmployeeDeclaration Start','Kamojou Trading & Projects'

	Truncate table dbo.Kamojou_Fact_EmployeeDeclaration

	
	Insert into Kamojou_Fact_EmployeeDeclaration(EstablishmentName ,[ReferenceNo] ,Latitude ,Longitude ,[Form Status] ,[Captured Date] ,
ResponsibleUser,[Name],[Surname],[Cell],[Email],[Title],[Department],[Employee ID],
[Address],Activity,[Mobile],[ResponseReferenceNo],IsPositive,PI,[ResponseDate],[Response Lat],
[ Response Long],[ SeenClientMasterId],ResponseResponsibleUser,[Location],[If other],
[Fever],[Dry Cough],[Sore Throat],[Headache],[Extreme Tiredness],[Breath Shortness],[Aches and Pains],
[Diarrhoea],[Nausea],[Runny Nose],[Repeated Shaking],[Chills],[Muscle Pain],[Lost taste/smell],
[Household members],[Temperature],[Anything to tell])
	select EstablishmentName ,[ReferenceNo] ,Latitude ,Longitude ,[Form Status] ,[Captured Date] ,
ResponsibleUser,[Name],[Surname],[Cell],[Email],[Title],[Department],[Employee ID],
[Address],Activity,[Mobile],[ResponseReferenceNo],IsPositive,PI,[ResponseDate],[Response Lat],
[ Response Long],[ SeenClientMasterId],ResponseResponsibleUser,[Location],[If other],
[Fever],[Dry Cough],[Sore Throat],[Headache],[Extreme Tiredness],[Breath Shortness],[Aches and Pains],
[Diarrhoea],[Nausea],[Runny Nose],[Repeated Shaking],[Chills],[Muscle Pain],[Lost taste/smell],
[Household members],[Temperature],[Anything to tell]
	 from [PB_VW_Kamojou_Fact_EmployeeDeclaration]

	Select @Desc = 'Kamojou_Fact_EmployeeDeclaration Completed.( '+  Convert(Varchar,Count(1)) + ' ) Records Inserted'  From dbo.Kamojou_Fact_EmployeeDeclaration(NoLock) 
	Exec dbo.PB_Log_Insert 'Kamojou_Fact_EmployeeDeclaration',@Desc,'Kamojou Trading & Projects'

	Set NoCount OFF;
END
