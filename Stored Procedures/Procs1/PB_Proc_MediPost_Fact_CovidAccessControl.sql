CREATE Procedure [dbo].[PB_Proc_MediPost_Fact_CovidAccessControl]
As
BEGIN
	set NoCount On;

	Declare @Desc Varchar(200)
	Exec dbo.PB_Log_Insert 'MediPost_Fact_CovidAccessControl','MediPost_Fact_CovidAccessControl Start','MediPost'

	Truncate table dbo.MediPost_Fact_CovidAccessControl

	
	Insert into MediPost_Fact_CovidAccessControl(
EstablishmentName,[Captured Date],[Capture Reference],Latitude,Longitude,
[Form Status],IsPositive,PI,ResponsibleUser,[Name],[Surname],[Mobile],
[Email],[Company Name],[Department],[Employee Number],[ID / Passport Number],
[COVID Manager / Compliance Officer],[Wearing Mask] ,[Washed or Sanitize],
[Fever/Chills],[Temperature],[Cough],[Sore Throat],[Redness of the eye],
[Breath Shortness],[Body aches],[Smell / Taste Lost],[Nausea],[Vomiting],
[Diarrhoea],[Fatigue],[Weakness or tired],[DATE])
	select 
EstablishmentName,[Captured Date],[Capture Reference],Latitude,Longitude,
[Form Status],IsPositive,PI,ResponsibleUser,[Name],[Surname],[Mobile],
[Email],[Company Name],[Department],[Employee Number],[ID / Passport Number],
[COVID Manager / Compliance Officer],[Wearing Mask] ,[Washed or Sanitize],
[Fever/Chills],[Temperature],[Cough],[Sore Throat],[Redness of the eye],
[Breath Shortness],[Body aches],[Smell / Taste Lost],[Nausea],[Vomiting],
[Diarrhoea],[Fatigue],[Weakness or tired],[DATE]
	 from [PB_VW_MediPost_Fact_CovidAccessControl]

	Select @Desc = 'MediPost_Fact_CovidAccessControl Completed.( '+  Convert(Varchar,Count(1)) + ' ) Records Inserted'  From dbo.MediPost_Fact_CovidAccessControl(NoLock) 
	Exec dbo.PB_Log_Insert 'MediPost_Fact_CovidAccessControl',@Desc,'MediPost'

	Set NoCount OFF;
END
