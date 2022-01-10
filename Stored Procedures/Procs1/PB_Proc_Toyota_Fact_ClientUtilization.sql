

Create Procedure [dbo].[PB_Proc_Toyota_Fact_ClientUtilization]
As
BEGIN
	set NoCount On;

	Declare @Desc Varchar(200)
	Exec dbo.PB_Log_Insert 'Toyota_Fact_ClientUtilization','Toyota_Fact_ClientUtilization Start','Toyota'

	Truncate table dbo.Toyota_Fact_ClientUtilization

	
	Insert into Toyota_Fact_ClientUtilization(GroupName,EstablishmentGroupName,EstablishmentName,ReferenceNo,
    Username,CreatedOn,Formtype,ChatId,ChatDate,Conversation,chattype)
	select GroupName,EstablishmentGroupName,EstablishmentName,ReferenceNo,
    Username,CreatedOn,Formtype,ChatId,ChatDate,Conversation,chattype
	 from [PB_VW_Toyota_Fact_ClientUtilization]

	Select @Desc = 'Toyota_Fact_ClientUtilization Completed.( '+  Convert(Varchar,Count(1)) + ' ) Records Inserted'  From dbo.Toyota_Fact_ClientUtilization(NoLock) 
	Exec dbo.PB_Log_Insert 'Toyota_Fact_ClientUtilization',@Desc,'Toyota'

	Set NoCount OFF;
END
