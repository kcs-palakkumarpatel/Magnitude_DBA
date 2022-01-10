

CREATE Procedure [dbo].[PB_Proc_Fact_AustroConsumableFeedback]
As
BEGIN
	set NoCount On;

	Declare @Desc Varchar(200)
	Exec dbo.PB_Log_Insert 'Fact_AustroConsumableFeedback','Fact_AustroConsumableFeedback Start','Austro'

	--Truncate table dbo.Fact_AustroConsumableFeedback

	delete From Fact_AustroConsumableFeedback where Flag=0

	Insert into Fact_AustroConsumableFeedback(EstablishmentName ,ResponseDate ,ReferenceNo ,SeenClientAnswerMasterId,IsPositive,Status ,UserName,Customer,Email ,Mobile ,
	[Service Good],[Correct Info] ,[Make Contact],Flag)
	select EstablishmentName ,ResponseDate ,ReferenceNo ,SeenClientAnswerMasterId,IsPositive,Status ,UserName,Customer,Email ,Mobile ,[Service Good],[Correct Info] ,[Make Contact] ,0 as Flag
	 from [PB_VW_Fact_AustroConsumableFeedback]

	Select @Desc = 'Fact_AustroConsumableFeedback Completed.( '+  Convert(Varchar,Count(1)) + ' ) Records Inserted'  From dbo.Fact_AustroConsumableFeedback(NoLock) 
	Exec dbo.PB_Log_Insert 'Fact_AustroConsumableFeedback',@Desc,'Austro'

	
	Set NoCount OFF;
END
