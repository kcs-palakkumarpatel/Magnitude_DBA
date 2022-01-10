




CREATE Procedure [dbo].[PB_Proc_Fact_AustroConsumableTelesalesFeedback]
As
BEGIN
	set NoCount On;

	Declare @Desc Varchar(200)
	Exec dbo.PB_Log_Insert 'Fact_AustroConsumableTelesalesFeedback','Fact_AustroConsumableTelesalesFeedback Start','Austro'

	--Truncate table dbo.Fact_AustroConsumableTelesalesFeedback

	delete From Fact_AustroConsumableTelesalesFeedback where Flag=0
	
	Insert into Fact_AustroConsumableTelesalesFeedback(EstablishmentName,ResponseDate,ReferenceNo,SeenClientAnswerMasterId,IsPositive,
Status,CustomerCompany,CustomerEmail,CustomerMobile,UserName,[Info Correct ],[Make Contact],[General Comments ],Flag)
	select EstablishmentName,ResponseDate,ReferenceNo,SeenClientAnswerMasterId,IsPositive,
Status,CustomerCompany,CustomerEmail,CustomerMobile,UserName,[Info Correct ],[Make Contact],[General Comments ],0 as Flag
	 from [PB_VW_Fact_AustroConsumableTelesalesFeedback]

	Select @Desc = 'Fact_AustroConsumableTelesalesFeedback Completed.( '+  Convert(Varchar,Count(1)) + ' ) Records Inserted'  From dbo.Fact_AustroConsumableTelesalesFeedback(NoLock) 
	Exec dbo.PB_Log_Insert 'Fact_AustroConsumableTelesalesFeedback',@Desc,'Austro'

	
	Set NoCount OFF;
END
