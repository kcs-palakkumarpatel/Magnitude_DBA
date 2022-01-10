


CREATE Procedure [dbo].[PB_Proc_Fact_AustroEquipmentTelesalesCaptured]
As
BEGIN
	set NoCount On;

	Declare @Desc Varchar(200)
	Exec dbo.PB_Log_Insert 'Fact_AustroEquipmentTelesalesCaptured','Fact_AustroEquipmentTelesalesCaptured Start','Austro'

	--Truncate table dbo.Fact_AustroEquipmentTelesalesCaptured

	delete from Fact_AustroEquipmentTelesalesCaptured where Flag=0
	
	Insert into Fact_AustroEquipmentTelesalesCaptured(EstablishmentName,CapturedDate,ReferenceNo,IsPositive,Status,UserId, UserName, Longitude,Latitude,CustomerCompany,CustomerEmail,CustomerMobile,
	CustomerName,[Have you spoken with:],[Was there interest?],[In your opinion, was the cold call successful?],[What was the client interested in?],[Is this a Biesse callout?],
[Company name:],[Company tier:],[Brands presented:],[Short feedback:],[Long feedback:],[What transpired during the call?],Flag)
	select EstablishmentName,CapturedDate,ReferenceNo,IsPositive,Status,UserId, UserName, Longitude,Latitude,CustomerCompany,CustomerEmail,CustomerMobile,
	CustomerName,[Have you spoken with:],[Was there interest?],[In your opinion, was the cold call successful?],[What was the client interested in?],[Is this a Biesse callout?],
[Company name:],[Company tier:],[Brands presented:],[Short feedback:],[Long feedback:],[What transpired during the call?],0 as Flag
	 from [PB_VW_Fact_AustroEquipmentTelesalesCaptured]

	Select @Desc = 'Fact_AustroEquipmentTelesalesCaptured Completed.( '+  Convert(Varchar,Count(1)) + ' ) Records Inserted'  From dbo.Fact_AustroEquipmentTelesalesCaptured(NoLock) 
	Exec dbo.PB_Log_Insert 'Fact_AustroEquipmentTelesalesCaptured',@Desc,'Austro'

	
	Set NoCount OFF;
END
