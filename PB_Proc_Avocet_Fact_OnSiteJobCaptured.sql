
CREATE Procedure [dbo].[PB_Proc_Avocet_Fact_OnSiteJobCaptured]
As
BEGIN
	set NoCount On;

	Declare @Desc Varchar(200)
	Exec dbo.PB_Log_Insert 'Avocet_Fact_OnSiteJobCaptured','Avocet_Fact_OnSiteJobCaptured Start','Avocet'

	Truncate table dbo.Avocet_Fact_OnSiteJobCaptured

	
	Insert into Avocet_Fact_OnSiteJobCaptured(EstablishmentName,CapturedDate,ReferenceNo,IsPositive,Status,UserName,[Name and Surname],
[Contact Number],[Contact Email],CapturedServiceType,[Incident Reference],[Comments | Faults ],
[Company Name],[Store Name],[INV No.],Latitude,Longitude,ResolvedDate,ResponseDate, ResponseReferenceNo,
[Response User],RepeatCount,[Experience Issues],[Issues],[Service Complete],[Still to do],[Charges to],
[Onsite Service],[Verification Type],[Ref Number],[Job Complete],[Description],[How Many Pages],
[Login Option],[Problem],[Resolution],[Installation Check],[Product],[Loan Service Number],
[Comments],[Service Attachment],[In case of Repair ],[Certificate Number],[Service Type],
[Job / Work Done],[Serial Number ],[Quantity],[Unit Price],[Total Price],[Machine],[Stock Code],
[Attachments - Imag],[Acknowledge ],[TECHNICIAN Sign],[Confirmation],[CUSTOMER Signature],[CUSTOMER NAME],
ResponseLatitude,ResponseLongitude,SeenClientAnswerMasterId,Technician)
	select EstablishmentName,CapturedDate,ReferenceNo,IsPositive,Status,UserName,[Name and Surname],
[Contact Number],[Contact Email],CapturedServiceType,[Incident Reference],[Comments | Faults ],
[Company Name],[Store Name],[INV No.],Latitude,Longitude,ResolvedDate,ResponseDate, ResponseReferenceNo,
[Response User],RepeatCount,[Experience Issues],[Issues],[Service Complete],[Still to do],[Charges to],
[Onsite Service],[Verification Type],[Ref Number],[Job Complete],[Description],[How Many Pages],
[Login Option],[Problem],[Resolution],[Installation Check],[Product],[Loan Service Number],
[Comments],[Service Attachment],[In case of Repair ],[Certificate Number],[Service Type],
[Job / Work Done],[Serial Number ],[Quantity],[Unit Price],[Total Price],[Machine],[Stock Code],
[Attachments - Imag],[Acknowledge ],[TECHNICIAN Sign],[Confirmation],[CUSTOMER Signature],[CUSTOMER NAME],
ResponseLatitude,ResponseLongitude,SeenClientAnswerMasterId,Technician
	 from [PB_VW_Avocet_Fact_OnSiteJobCaptured]

	Select @Desc = 'Avocet_Fact_OnSiteJobCaptured Completed.( '+  Convert(Varchar,Count(1)) + ' ) Records Inserted'  From dbo.Avocet_Fact_OnSiteJobCaptured(NoLock) 
	Exec dbo.PB_Log_Insert 'Avocet_Fact_OnSiteJobCaptured',@Desc,'Avocet'

	Set NoCount OFF;
END
