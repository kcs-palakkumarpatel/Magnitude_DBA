CREATE Procedure [dbo].[PB_Proc_Clifton_Fact_SelfAssessment]
As
BEGIN
	set NoCount On;

	Declare @Desc Varchar(200)
	Exec dbo.PB_Log_Insert 'Clifton_Fact_SelftAssessment','Clifton_Fact_SelftAssessment Start','Clifton'

	Truncate table dbo.Clifton_Fact_SelftAssessment

	
	Insert into Clifton_Fact_SelftAssessment(EstablishmentName,ReferenceNo,StatusDateTime , CapturedBy ,
StatusName ,ResponsibleUser,ResponseDate,ResponseReferenceNo,[Student Name],[Location],[If other, Let us k],
[Fever],[Dry Cough],[Sore Throat],[Headache],[Extreme Tiredness],[Shortness of Breat],[Aches and Pains],[Diarrhoea],
[Runny Nose],[Repeated Shaking],[Chills],[Muscle Pain],[Loss of taste or s],[Household Members],[Anything to tell u],
[Anything to Attach],[Nausea],[Temperature (],Longitude,Latitude,Status,IsPositive)
	select EstablishmentName,ReferenceNo,StatusDateTime , CapturedBy ,
StatusName ,ResponsibleUser,ResponseDate,ResponseReferenceNo,[Student Name],[Location],[If other, Let us k],
[Fever],[Dry Cough],[Sore Throat],[Headache],[Extreme Tiredness],[Shortness of Breat],[Aches and Pains],[Diarrhoea],
[Runny Nose],[Repeated Shaking],[Chills],[Muscle Pain],[Loss of taste or s],[Household Members],[Anything to tell u],
[Anything to Attach],[Nausea],[Temperature (],Longitude,Latitude,Status,IsPositive
	 from [PB_VW_Clifton_Fact_SelftAssessment]

	Select @Desc = 'Clifton_Fact_SelftAssessment Completed.( '+  Convert(Varchar,Count(1)) + ' ) Records Inserted'  From dbo.Clifton_Fact_SelftAssessment(NoLock) 
	Exec dbo.PB_Log_Insert 'Clifton_Fact_SelftAssessment',@Desc,'Clifton'

--------------------------------------------------------------------------------------------------------------
	Exec dbo.PB_Log_Insert 'Clifton_Fact_SelfReportQR','Clifton_Fact_SelfReportQR Start','Clifton'

	Truncate table dbo.Clifton_Fact_SelfReportQR

	
	Insert into Clifton_Fact_SelfReportQR(EstablishmentName,	ResponseDate,		ResponseReferenceNo,
			SeenClientAnswerMasterId,				Status	,UserName	,Longitude,Latitude,[First Name],
[Last Name],[Location],[Fever],[Dry Cough],[Sore Throat],[Headache],[Extreme Tiredness],[Shortness of Breat],
[Aches and Pains],[Diarrhoea],[[Runny Nose],[Repeated Shaking],[Chills],[Nausea],[Muscle Pain],[Loss of Taste],
[Household Sick],[Comments])
	select EstablishmentName,	ResponseDate,		ResponseReferenceNo,
			SeenClientAnswerMasterId,				Status	,UserName	,Longitude,Latitude,[First Name],
[Last Name],[Location],[Fever],[Dry Cough],[Sore Throat],[Headache],[Extreme Tiredness],[Shortness of Breat],
[Aches and Pains],[Diarrhoea],[[Runny Nose],[Repeated Shaking],[Chills],[Nausea],[Muscle Pain],[Loss of Taste],
[Household Sick],[Comments]
	 from [PB_VW_Clifton_Fact_SelfReportQR]

	Select @Desc = 'Clifton_Fact_SelfReportQR Completed.( '+  Convert(Varchar,Count(1)) + ' ) Records Inserted'  From dbo.Clifton_Fact_SelfReportQR(NoLock) 
	Exec dbo.PB_Log_Insert 'Clifton_Fact_SelfReportQR',@Desc,'Clifton'



	Set NoCount OFF;
END
