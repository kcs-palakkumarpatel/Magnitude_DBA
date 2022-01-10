CREATE PROCEDURE dbo.PB_Proc_NW_Sales
As
BEGIN
	set NoCount On;

	Declare @Desc Varchar(200)
	Exec dbo.PB_Log_Insert 'NW_Quoting','NW_Quoting Start','NW_Quoting'

	Truncate table dbo.NW_Quoting
	
	
	Insert into NW_Quoting(EstablishmentName,CapturedDate,ReferenceNo,IsPositive,IsResolved,UserId,UserName,Longitude,Latitude,CustomerName,CustomerMobile,CustomerEmail,RepeatCount,Area,[O2 Province],[Contact person],[Contact number],[Email address],[Are you logging an opportunity?],[Is this a hot prospect?],[What is the opportunity spotted?],[Are you speaking to ..],[Company name],[Is this a Quote or Tender],[What is the customer interested in?],[Price value of opportunity (ZAR)],[Accessories],[If other, what?],[kVA/Equipement],[Quantity],[Full price value of opportunity (ZAR) Amount Excl. VAT],[Is this long term or short term?],[ResponseDate],[Refno],[%PI],[Status],[Comments],[Brand chosen],[Full Value of quote (ZAR)],[Reason for lost deal],[Follow up],[Who did we loose the deal to?],[Who was the competitor?],[Reason for cancellation],[Price (ZAR)],[Deviation in original price (ZAR)],[Reason for deviation],[Has this become a hot quote?],[General comments],[sortorder])
	select EstablishmentName,CapturedDate,ReferenceNo,IsPositive,IsResolved,UserId,UserName,Longitude,Latitude,CustomerName,CustomerMobile,CustomerEmail,RepeatCount,Area,[O2 Province],[Contact person],[Contact number],[Email address],[Are you logging an opportunity?],[Is this a hot prospect?],[What is the opportunity spotted?],[Are you speaking to ..],[Company name],[Is this a Quote or Tender],[What is the customer interested in?],[Price value of opportunity (ZAR)],[Accessories],[If other, what?],[kVA/Equipement],[Quantity],[Full price value of opportunity (ZAR) Amount Excl. VAT],[Is this long term or short term?],[ResponseDate],[Refno],[%PI],[Status],[Comments],[Brand chosen],[Full Value of quote (ZAR)],[Reason for lost deal],[Follow up],[Who did we loose the deal to?],[Who was the competitor?],[Reason for cancellation],[Price (ZAR)],[Deviation in original price (ZAR)],[Reason for deviation],[Has this become a hot quote?],[General comments],[sortorder]
	 from [dbo].[PB_VW_NW_Quoting]

	Select @Desc = 'NW_Quoting Completed.( '+  Convert(Varchar,Count(1)) + ' ) Records Inserted'  From dbo.NW_Quoting(NoLock) 
	Exec dbo.PB_Log_Insert 'NW_Quoting',@Desc,'NW_Quoting'

	DECLARE @Desc1 Varchar(200)
	Exec dbo.PB_Log_Insert 'NW_SalesOrder','NW_SalesOrder Start','NW_SalesOrder'

	Truncate table dbo.NW_SalesOrder

	
	Insert into NW_SalesOrder([EstablishmentName],[CapturedDate],[ReferenceNo],[IsPositive],[Status],[UserId],[UserName],[Longitude],[Latitude],[CustomerName],[CustomerMobile],[CustomerEmail],[RepeatCount],[Area],[O2 Province],[Sales representative on job],[Date],[Type],[Price of job (Excluding VAT) (ZAR)],[Company name],[Customer order number],[Contact person],[Contact number],[Email address],[Industry serve],[Required delivery date],[Delivery address],[Accessories],[If other, what?],[Full price value of opportunity (ZAR) Amount Excl. VAT],[kVA rating],[If other, please state],[Engine make],[Engine Model],[Quantity],[Quote / tender ref number],[Customer job number])
	select [EstablishmentName],[CapturedDate],[ReferenceNo],[IsPositive],[Status],[UserId],[UserName],[Longitude],[Latitude],[CustomerName],[CustomerMobile],[CustomerEmail],[RepeatCount],[Area],[O2 Province],[Sales representative on job],[Date],[Type],[Price of job (Excluding VAT) (ZAR)],[Company name],[Customer order number],[Contact person],[Contact number],[Email address],[Industry serve],[Required delivery date],[Delivery address],[Accessories],[If other, what?],[Full price value of opportunity (ZAR) Amount Excl. VAT],[kVA rating],[If other, please state],[Engine make],[Engine Model],[Quantity],[Quote / tender ref number],[Customer job number]
	 from [dbo].[PB_VW_NW_SalesOrder]

	Select @Desc1 = 'NW_SalesOrder Completed.( '+  Convert(Varchar,Count(1)) + ' ) Records Inserted'  From dbo.NW_SalesOrder(NoLock) 
	Exec dbo.PB_Log_Insert 'NW_SalesOrder',@Desc1,'NW_SalesOrder'

	DECLARE @Desc2 Varchar(200)
	Exec dbo.PB_Log_Insert 'NW_LeadDelegation','NW_LeadDelegation Start','NW_LeadDelegation'

	Truncate table dbo.NW_LeadDelegation

	
	Insert into NW_LeadDelegation([EstablishmentName] ,[CapturedDate] ,[ReferenceNo] ,[IsResolved],[UserId] ,[UserName] ,[Longitude] ,[Latitude] ,[CustomerName] ,[CustomerMobile] ,[CustomerEmail] ,[Company name] ,[Contact person] ,[Contact number],[Source of lead],[If other, please state],[Type of lead],[Potential price value of lead (ZAR)],[About the lead],[Brand],[kVA],[If other, please specify],[Email address],[Type of Product],[Lead specific too] ,[ResponseDate],[Refno],[Have you contacted the lead?],[Why haven't you contacted the lead?],[How did you contact the lead?],[Have you set up the meeting?],[When is the meeting?],[Who did you speak to?],[Outcome of contact],[Outcome of contact.],[What was the prospect interested in?],[Value of lead (ZAR)])
	select [EstablishmentName] ,[CapturedDate] ,[ReferenceNo] ,[IsResolved],[UserId] ,[UserName] ,[Longitude] ,[Latitude] ,[CustomerName] ,[CustomerMobile] ,[CustomerEmail] ,[Company name] ,[Contact person] ,[Contact number],[Source of lead],[If other, please state],[Type of lead],[Potential price value of lead (ZAR)],[About the lead],[Brand],[kVA],[If other, please specify],[Email address],[Type of Product],[Lead specific too] ,[ResponseDate],[Refno],[Have you contacted the lead?],[Why haven't you contacted the lead?],[How did you contact the lead?],[Have you set up the meeting?],[When is the meeting?],[Who did you speak to?],[Outcome of contact],[Outcome of contact.],[What was the prospect interested in?],[Value of lead (ZAR)]
	 from [dbo].[PB_VW_NW_LeadDelegation]

	Select @Desc2 = 'NW_LeadDelegation Completed.( '+  Convert(Varchar,Count(1)) + ' ) Records Inserted'  From dbo.NW_LeadDelegation(NoLock) 
	Exec dbo.PB_Log_Insert 'NW_LeadDelegation',@Desc2,'NW_LeadDelegation'

	DECLARE @Desc3 Varchar(200)
	Exec dbo.PB_Log_Insert 'NW_CustFeedback','NW_CustFeedback Start','NW_CustFeedback'

	Truncate table dbo.NW_CustFeedback

	
	Insert into NW_CustFeedback([EstablishmentName],[CapturedDate],[ReferenceNo],[Status],[UserId],[UserName],[Company],[Company name:],[Sales representative on job],[PI],[Staff satisfaction],[Overall service],[Response times],[Pricing],[General Comments],[ResponseDate],[Refno],[What did the problem pertain to?],[What was wrong with staff interaction?],[What was wrong with the service?],[What was wrong with the response times?],[What was wrong with our pricing?],[Did we face competition?],[Which competitors?],[Did you know their price?],[What was their price (ZAR)],[Was the person contacted?],[What happened during this point of contact?],[Why haven't you contacted the person?],[What corrective measures will be implemented to ensure this does not happen again?],[Your confidence in the solution?])
	select [EstablishmentName],[CapturedDate],[ReferenceNo],[Status],[UserId],[UserName],[Company],[Company name:],[Sales representative on job],[PI],[Staff satisfaction],[Overall service],[Response times],[Pricing],[General Comments],[ResponseDate],[Refno],[What did the problem pertain to?],[What was wrong with staff interaction?],[What was wrong with the service?],[What was wrong with the response times?],[What was wrong with our pricing?],[Did we face competition?],[Which competitors?],[Did you know their price?],[What was their price (ZAR)],[Was the person contacted?],[What happened during this point of contact?],[Why haven't you contacted the person?],[What corrective measures will be implemented to ensure this does not happen again?],[Your confidence in the solution?]
	 from [dbo].[PB_VW_NW_CustFeedback]

	Select @Desc3 = 'NW_CustFeedback Completed.( '+  Convert(Varchar,Count(1)) + ' ) Records Inserted'  From dbo.NW_CustFeedback(NoLock) 
	Exec dbo.PB_Log_Insert 'NW_CustFeedback',@Desc3,'NW_CustFeedback'

	DECLARE @Desc4 Varchar(200)
	Exec dbo.PB_Log_Insert 'NW_Particulars','NW_Particulars Start','NW_Particulars'

	Truncate table dbo.NW_Particulars

	
	Insert into NW_Particulars([EstablishmentName],[CapturedDate],[ReferenceNo],[Status],[UserId],[UserName],[Longitude],[Latitude],[CustomerName],[CustomerMobile],[CustomerEmail],[Company name],[Product interested in],[ResponseDate],[Refno],[Are you],[Trading name of business],[Registered name of business],[Previous trading/registered names],[Incorporated form of business],[VAT registration number],[Registered name of holding company],[Names of subsidiary and associate companies],[Business activities],[Physical address],[Are deliveries to be made to this address? If not, then where?],[Postal address + code],[Are invoices to be sent to this postal address? If not, then where?],[Registered address],[Telephone number],[Fax area & no],[Premises],[Email],[Name of landlord],[Postal address of landlord],[Details of],[Full name],[ID No.],[Residential address],[% shareholding / interest],[Registration number of incorporation],[Postal address for invoice],[Delivery address if different to physical address],[Accounts contact person],[Accounts department telephone number],[Accounts department fax number],[Orders placed by],[Order numbers used?],[Project / division requesting invoice],[Credit limit request])
	select [EstablishmentName],[CapturedDate],[ReferenceNo],[Status],[UserId],[UserName],[Longitude],[Latitude],[CustomerName],[CustomerMobile],[CustomerEmail],[Company name],[Product interested in],[ResponseDate],[Refno],[Are you],[Trading name of business],[Registered name of business],[Previous trading/registered names],[Incorporated form of business],[VAT registration number],[Registered name of holding company],[Names of subsidiary and associate companies],[Business activities],[Physical address],[Are deliveries to be made to this address? If not, then where?],[Postal address + code],[Are invoices to be sent to this postal address? If not, then where?],[Registered address],[Telephone number],[Fax area & no],[Premises],[Email],[Name of landlord],[Postal address of landlord],[Details of],[Full name],[ID No.],[Residential address],[% shareholding / interest],[Registration number of incorporation],[Postal address for invoice],[Delivery address if different to physical address],[Accounts contact person],[Accounts department telephone number],[Accounts department fax number],[Orders placed by],[Order numbers used?],[Project / division requesting invoice],[Credit limit request]
	 from [dbo].[PB_VW_NW_Particulars]

	Select @Desc4 = 'NW_Particulars Completed.( '+  Convert(Varchar,Count(1)) + ' ) Records Inserted'  From dbo.NW_Particulars(NoLock) 
	Exec dbo.PB_Log_Insert 'NW_Particulars',@Desc4,'NW_Particulars'

	Set NoCount OFF;
END
