
CREATE Procedure [dbo].[PB_Proc_Fact_AustroEquipmentOpportunity]
As
BEGIN
	set NoCount On;

	Declare @Desc Varchar(200)
	Exec dbo.PB_Log_Insert 'Fact_AustroEquipmentOpportunity','Fact_AustroEquipmentOpportunity Start','Austro'

	--Truncate table dbo.Fact_AustroEquipmentOpportunity

	delete From Fact_AustroEquipmentOpportunity where Flag=0
	
	Insert into Fact_AustroEquipmentOpportunity(EstablishmentName,CapturedDate,ReferenceNo,IsPositive,Status,PI,UserId,UserName,Longitude,Latitude,
CustomerEmail,CustomerCompany,CustomerMobile,CustomerName,[Are you logging an opportunity:],[Company name:],[What is the opportunity spotted?],
[What is the customer interested in?],[Price of total opportunity (ZAR):],[Expected date of delivery:],[Name:],[Surname:],[Mobile:],
[Is this a Biesse opportunity?],[Company Tier],[Confidence],[Brands Presented],[Short Feedback],
[Long Feedback],ResponseDate,ResponseReferenceNo,ResponsePI,[Reason for lost sale:],[Status:],[What can you do better?],
[Who did we loose the deal to?],DummyRow,Sort,Flag)
	select EstablishmentName,CapturedDate,ReferenceNo,IsPositive,Status,PI,UserId,UserName,Longitude,Latitude,
CustomerEmail,CustomerCompany,CustomerMobile,CustomerName,[Are you logging an opportunity:],[Company name:],[What is the opportunity spotted?],
[What is the customer interested in?],[Price of total opportunity (ZAR):],[Expected date of delivery:],[Name:],[Surname:],[Mobile:],
[Is this a Biesse opportunity?],[Company Tier],[Confidence],[Brands Presented],[Short Feedback],
[Long Feedback],ResponseDate,ResponseReferenceNo,ResponsePI,[Reason for lost sale:],[Status:],[What can you do better?],
[Who did we loose the deal to?],DummyRow,Sort,0 as Flag
	 from [PB_VW_Fact_AustroEquipmentOpportunity]

	Select @Desc = 'Fact_AustroEquipmentOpportunity Completed.( '+  Convert(Varchar,Count(1)) + ' ) Records Inserted'  From dbo.Fact_AustroEquipmentOpportunity(NoLock) 
	Exec dbo.PB_Log_Insert 'Fact_AustroEquipmentOpportunity',@Desc,'Austro'

	
	Set NoCount OFF;
END
