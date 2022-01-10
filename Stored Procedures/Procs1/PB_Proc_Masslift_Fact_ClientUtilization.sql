



Create Procedure [dbo].[PB_Proc_Masslift_Fact_ClientUtilization]
As
BEGIN
	set NoCount On;

	Declare @Desc Varchar(200)
	Exec dbo.PB_Log_Insert 'Masslift_Fact_ClientUtilization','Masslift_Fact_ClientUtilization Start','Masslift'

	Truncate table dbo.Masslift_Fact_ClientUtilization

	
	Insert into Masslift_Fact_ClientUtilization(GroupName,EstablishmentGroupName,EstablishmentName,ReferenceNo,
    Username,CreatedOn,Formtype,ChatId,ChatDate,Conversation,chattype)
	select GroupName,EstablishmentGroupName,EstablishmentName,ReferenceNo,
    Username,CreatedOn,Formtype,ChatId,ChatDate,Conversation,chattype
	 from [PB_VW_Masslift_Fact_ClientUtilization]

	Select @Desc = 'Masslift_Fact_ClientUtilization Completed.( '+  Convert(Varchar,Count(1)) + ' ) Records Inserted'  From dbo.Masslift_Fact_ClientUtilization(NoLock) 
	Exec dbo.PB_Log_Insert 'Masslift_Fact_ClientUtilization',@Desc,'Masslift'

	Set NoCount OFF;
END
