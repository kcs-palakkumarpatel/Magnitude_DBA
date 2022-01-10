

CREATE Procedure [dbo].[PB_Proc_Fact_AustroMachineFeedback]
As
BEGIN
	set NoCount On;

	Declare @Desc Varchar(200)
	Exec dbo.PB_Log_Insert 'Fact_AustroMachineFeedback','Fact_AustroMachineFeedback Start','Austro'

	--Truncate table dbo.Fact_AustroMachineFeedback

	delete From Fact_AustroMachineFeedback where Flag=0
	
	Insert into Fact_AustroMachineFeedback([EstablishmentName] ,	[ResponseDate] ,	[ReferenceNo] ,	[SeenClientAnswerMasterId] ,	[IsPositive] ,	[Status] ,	[PI] ,
	[UserName] ,	[Customer],	[Email] ,	[Mobile] ,	[Do you see value?],[Are we on the same page?],[General Comments],[Were you happy with the service of the salesman?],Flag)
	select [EstablishmentName] ,	[ResponseDate] ,	[ReferenceNo] ,	[SeenClientAnswerMasterId] ,	[IsPositive] ,	[Status] ,	[PI] ,
	[UserName] ,	[Customer],	[Email] ,	[Mobile] ,	[Do you see value?],[Are we on the same page?],[General Comments],[Were you happy with the service of the salesman?], 0 as Flag
	 from [PB_VW_Fact_AustroMachineFeedback]

	Select @Desc = 'Fact_AustroMachineFeedback Completed.( '+  Convert(Varchar,Count(1)) + ' ) Records Inserted'  From dbo.Fact_AustroMachineFeedback(NoLock) 
	Exec dbo.PB_Log_Insert 'Fact_AustroMachineFeedback',@Desc,'Austro'

	
	Set NoCount OFF;
END
