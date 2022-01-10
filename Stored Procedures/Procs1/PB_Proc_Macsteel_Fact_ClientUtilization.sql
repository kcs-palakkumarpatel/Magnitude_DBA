




Create Procedure [dbo].[PB_Proc_Macsteel_Fact_ClientUtilization]
As
BEGIN
	set NoCount On;

	Declare @Desc Varchar(200)
	Exec dbo.PB_Log_Insert 'Macsteel_Fact_ClientUtilization','Macsteel_Fact_ClientUtilization Start','Macsteel'

	Truncate table dbo.Macsteel_Fact_ClientUtilization

	
	Insert into Macsteel_Fact_ClientUtilization(GroupName,EstablishmentGroupName,EstablishmentName,ReferenceNo,
    Username,CreatedOn,Formtype,ChatId,ChatDate,Conversation,chattype)
	select GroupName,EstablishmentGroupName,EstablishmentName,ReferenceNo,
    Username,CreatedOn,Formtype,ChatId,ChatDate,Conversation,chattype
	 from [PB_VW_Macsteel_Fact_ClientUtilization]

	Select @Desc = 'Macsteel_Fact_ClientUtilization Completed.( '+  Convert(Varchar,Count(1)) + ' ) Records Inserted'  From dbo.Macsteel_Fact_ClientUtilization(NoLock) 
	Exec dbo.PB_Log_Insert 'Macsteel_Fact_ClientUtilization',@Desc,'Masslift'

	Set NoCount OFF;
END
