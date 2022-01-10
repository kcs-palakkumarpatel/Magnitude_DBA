CREATE PROCEDURE [dbo].[PB_Proc_Toyota_CSI]
As
BEGIN
	set NoCount On;

	Declare @Desc Varchar(200)
	Exec dbo.PB_Log_Insert 'Toyota_CSI','Toyota_CSI Start','Toyota_CSI'

	Truncate table dbo.Toyota_CSI

	
	Insert into Toyota_CSI(Branch,Surveytype,EstablishmentName,CapturedDate,ReferenceNo,Refno,IsPositive,Status,UserName,CustomerCompany,CustomerEmail,CustomerMobile,CustomerName,Department,[M-Technician name],[M-WIP number],[M-Quotation],[M-Product Support],[M-Response time],[M-Resolution],[M-Additional Work],[M-Work comments],[M-Service Quality/Referral],[M-Customer comments],[Parts Salesperson],[P-Invoice number],[P-WIP number],[P-Quotation],[P-Availability],[P-Product knowledge],[P-Invoicing & POD],[P-Service Quality/Referral],[P-Customer comments],[Rental Controller],[R-Invoice number],[R-Agreement number],[R-Quotation],[R-Delivery],[R-Customer service],[R-Product experience],[R-Invoicing],[R-Referral],[R-Customer comments],[SL-Type of sales],[Salesperson],[SL-Invoiced number],[SL-Product Knowledge],[SL-Response time],[SL-Proposal],[SL-Deliveries and Hand over],[SL-Customer buying criteria],[SL-What persuaded you],[SL-Customer comment],[SL-Referral],[SL-Customer comments],[Ser-Technician name],[Ser-WIP number],[Ser-Quotation],[Ser-Response time],[Ser-Resolution],[Ser-Additional Work],[Ser-Work comments],[Ser-Product Support],[Ser-Service Quality/Referral],[Ser-Customer comments])
	select Branch,Surveytype,EstablishmentName,CapturedDate,ReferenceNo,Refno,IsPositive,Status,UserName,CustomerCompany,CustomerEmail,CustomerMobile,CustomerName,Department,[M-Technician name],[M-WIP number],[M-Quotation],[M-Product Support],[M-Response time],[M-Resolution],[M-Additional Work],[M-Work comments],[M-Service Quality/Referral],[M-Customer comments],[Parts Salesperson],[P-Invoice number],[P-WIP number],[P-Quotation],[P-Availability],[P-Product knowledge],[P-Invoicing & POD],[P-Service Quality/Referral],[P-Customer comments],[Rental Controller],[R-Invoice number],[R-Agreement number],[R-Quotation],[R-Delivery],[R-Customer service],[R-Product experience],[R-Invoicing],[R-Referral],[R-Customer comments],[SL-Type of sales],[Salesperson],[SL-Invoiced number],[SL-Product Knowledge],[SL-Response time],[SL-Proposal],[SL-Deliveries and Hand over],[SL-Customer buying criteria],[SL-What persuaded you],[SL-Customer comment],[SL-Referral],[SL-Customer comments],[Ser-Technician name],[Ser-WIP number],[Ser-Quotation],[Ser-Response time],[Ser-Resolution],[Ser-Additional Work],[Ser-Work comments],[Ser-Product Support],[Ser-Service Quality/Referral],[Ser-Customer comments]
	 from [PB_VW_TF_CSI]

	Select @Desc = 'Toyota_CSI Completed.( '+  Convert(Varchar,Count(1)) + ' ) Records Inserted'  From dbo.Toyota_CSI 
	Exec dbo.PB_Log_Insert 'Toyota_CSI',@Desc,'Toyota_CSI'

	Set NoCount OFF;
END
