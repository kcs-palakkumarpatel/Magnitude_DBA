
CREATE Procedure [dbo].[PB_Proc_Fact_AustroEquipmentTelesalesFeedback]
As
BEGIN
	set NoCount On;

	Declare @Desc Varchar(200)
	Exec dbo.PB_Log_Insert 'Fact_AustroEquipmentTelesalesFeedback','Fact_AustroEquipmentTelesalesFeedback Start','Austro'

	--Truncate table dbo.Fact_AustroEquipmentTelesalesFeedback

	delete From Fact_AustroEquipmentTelesalesFeedback where Flag=0
	
	Insert into Fact_AustroEquipmentTelesalesFeedback(EstablishmentName,CapturedDate,ReferenceNo,SeenClientAnswerMasterId,Status,CustomerCompany,CustomerEmail,CustomerMobile,UserName,
[Is the above information correct?],[What was incorrect?],[Would you like to be contacted?],[General comments:],Flag)
	select EstablishmentName,CapturedDate,ReferenceNo,SeenClientAnswerMasterId,Status,CustomerCompany,CustomerEmail,CustomerMobile,UserName,
[Is the above information correct?],[What was incorrect?],[Would you like to be contacted?],[General comments:],0 as Flag
	 from [PB_VW_Fact_AustroEquipmentTelesalesFeedback]

	Select @Desc = 'Fact_AustroEquipmentTelesalesFeedback Completed.( '+  Convert(Varchar,Count(1)) + ' ) Records Inserted'  From dbo.Fact_AustroEquipmentTelesalesFeedback(NoLock) 
	Exec dbo.PB_Log_Insert 'Fact_AustroEquipmentTelesalesFeedback',@Desc,'Austro'

	
	Set NoCount OFF;
END
