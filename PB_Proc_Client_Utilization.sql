Create Procedure [dbo].[PB_Proc_Client_Utilization]
As
BEGIN
	set NoCount On;

	Declare @Desc Varchar(200)
	Exec dbo.PB_Log_Insert 'Client_Utilization','Client_Utilization Start','Client_Utilization'

	Truncate table dbo.Client_Utilization

	
	Insert into Client_Utilization(Id,GroupName,EstablishmentGroupName,EstablishmentName,Username,CreatedOn,Formtype,chatid,chatdate,Conversation,chattype)
	select Id,GroupName,EstablishmentGroupName,EstablishmentName,Username,CreatedOn,Formtype,chatid,chatdate,Conversation,chattype
	 from [PB_VW_Client_Utilization]

	Select @Desc = 'Client_Utilization Completed.( '+  Convert(Varchar,Count(1)) + ' ) Records Inserted'  From dbo.Client_Utilization(NoLock) 
	Exec dbo.PB_Log_Insert 'Client_Utilization',@Desc,'Client_Utilization'

	Set NoCount OFF;
END
