CREATE Procedure [dbo].[PB_Proc_Nosa_Fact_Covid_28Sept21]
As
BEGIN
	set NoCount On;

	Declare @Desc Varchar(200)
	Exec dbo.PB_Log_Insert 'Nosa_Fact_Covid','Nosa_Fact_Covid Start','Nosa Logistics'

	Truncate table dbo.Nosa_Fact_Covid_Test

	
	/*Insert into Nosa_Fact_Covid(EstablishmentName,ReferenceNo,ResponsibleUser,StatusDateTime,StatusName,ResponseDate,ResponseReferenceNo,[Location],[Fever],[Cough],
	[Sore Throat],[Headache],[Household Members],[Comments],Longitude,Latitude,CapturedDate,[Your temperature],EmployeeId,[Tiredness],
[Breathe Shortness],[Aches and Pains],[Diarrhoea],[Nausea],[Runny Nose],[Repeated Shaking],[Chills ],[Muscle Pain ],
[Loss Taste/Smell],[underlying medical],[What is condition])
	select EstablishmentName,ReferenceNo,ResponsibleUser,StatusDateTime,StatusName,ResponseDate,ResponseReferenceNo,[Location],[Fever],[Cough],
	[Sore Throat],[Headache],[Household Members],[Comments],Longitude,Latitude,CapturedDate,[Your temperature],EmployeeId,[Tiredness],
[Breathe Shortness],[Aches and Pains],[Diarrhoea],[Nausea],[Runny Nose],[Repeated Shaking],[Chills ],[Muscle Pain ],
[Loss Taste/Smell],[underlying medical],[What is condition]
	 from [PB_VW_Nosa_Fact_Covid]*/
	 select EstablishmentName,ReferenceNo,ResponsibleUser,StatusDateTime,StatusName,ResponseDate,ResponseReferenceNo,[Location],[Fever],[Cough],
	[Sore Throat],[Headache],[Household Members],[Comments],Longitude,Latitude,CapturedDate,[Your temperature],EmployeeId,[Tiredness],
[Breathe Shortness],[Aches and Pains],[Diarrhoea],[Nausea],[Runny Nose],[Repeated Shaking],[Chills ],[Muscle Pain ],
[Loss Taste/Smell],[underlying medical],[What is condition] into Nosa_Fact_Covid_Test from  [PB_VW_Nosa_Fact_Covid]

	Select @Desc = 'Nosa_Fact_Covid Completed.( '+  Convert(Varchar,Count(1)) + ' ) Records Inserted'  From dbo.Nosa_Fact_Covid_Test(NoLock) 
	Exec dbo.PB_Log_Insert 'DFC_Fact_Covid',@Desc,'Nosa Logistics'

	Set NoCount OFF;
END
