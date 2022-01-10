
CREATE Procedure [dbo].[PB_Proc_Avocet_Fact_HelpDeskCaptured]
As
BEGIN
	set NoCount On;

	Declare @Desc Varchar(200)
	Exec dbo.PB_Log_Insert 'Avocet_Fact_HelpDeskCaptured','Avocet_Fact_HelpDeskCaptured Start','Avocet'

	Truncate table dbo.Avocet_Fact_HelpDeskCaptured

	
	Insert into Avocet_Fact_HelpDeskCaptured(EstablishmentName,CapturedDate,ReferenceNo,IsPositive,FormStatus,ResolvedDate,UserName,
[Customer/Store],[Store number],[Incident Number],[Contact Person],[Contact Number],
CapturedServiceType,[Category],[Type],[Priority],[Summary - Informat],[Status],
[Received/Closed by],Latitude,Longitude,ResponseDate,ResponseReferenceNo, RepeatCount,
[Response User],[4hrs SLA],[Issues],[What Were The Issu],[Service Complete],
[What is Outstandin],[Charges to],[Onsite Service Type],[Verification Type],
[Ref Number],[Job Complete],[Description],[How Many Pages],[Login Option],[Problem],
[Resolution],[Installation Check],[Product],[Loan Serial Number],[Comments],[Attachments - Imag],
[Service Type],[Machine],[Certificate Number],[Stock Code],[Job | Work Done],[Serial Number],
[Quantity],[Unit Price],[Total Price R],[In case of Repair],[Acknowledge that a],[TECHNICIAN SIGNATU],
[Please confirm tha],[Customer Name],[CUSTOMER SIGNATURE] ,ResponseLatitude,ResponseLongitude,Technician )
	select EstablishmentName,CapturedDate,ReferenceNo,IsPositive,FormStatus,ResolvedDate,UserName,
[Customer/Store],[Store number],[Incident Number],[Contact Person],[Contact Number],
CapturedServiceType,[Category],[Type],[Priority],[Summary - Informat],[Status],
[Received/Closed by],Latitude,Longitude,ResponseDate,ResponseReferenceNo, RepeatCount,
[Response User],[4hrs SLA],[Issues],[What Were The Issu],[Service Complete],
[What is Outstandin],[Charges to],[Onsite Service Type],[Verification Type],
[Ref Number],[Job Complete],[Description],[How Many Pages],[Login Option],[Problem],
[Resolution],[Installation Check],[Product],[Loan Serial Number],[Comments],[Attachments - Imag],
[Service Type],[Machine],[Certificate Number],[Stock Code],[Job | Work Done],[Serial Number],
[Quantity],[Unit Price],[Total Price R],[In case of Repair],[Acknowledge that a],[TECHNICIAN SIGNATU],
[Please confirm tha],[Customer Name],[CUSTOMER SIGNATURE] ,ResponseLatitude,ResponseLongitude ,Technician
	 from [PB_VW_Avocet_Fact_HelpDeskCaptured]

	Select @Desc = 'Avocet_Fact_HelpDeskCaptured Completed.( '+  Convert(Varchar,Count(1)) + ' ) Records Inserted'  From dbo.Avocet_Fact_HelpDeskCaptured(NoLock) 
	Exec dbo.PB_Log_Insert 'Avocet_Fact_HelpDeskCaptured',@Desc,'Avocet'

	Set NoCount OFF;
END
