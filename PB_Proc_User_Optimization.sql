CREATE PROCEDURE dbo.PB_Proc_User_Optimization
As
BEGIN
	set NoCount On;

	Declare @Desc Varchar(200)
	Exec dbo.PB_Log_Insert 'User_Optimization','User_Optimization Start','User_Optimization'

	Truncate table dbo.User_Optimization

	
	Insert into User_Optimization(Id,GroupName,EstablishmentGroupName,EstablishmentName,Username,Respondent,CreatedOn,Formtype,chatid,chatdate,Conversation,chattype)
	select Id,GroupName,EstablishmentGroupName,EstablishmentName,Username,Respondent,CreatedOn,Formtype,chatid,chatdate,Conversation,chattype
	 from [PB_VW_User_Optimization]

	Select @Desc = 'User_Optimization Completed.( '+  Convert(Varchar,Count(1)) + ' ) Records Inserted'  From dbo.User_Optimization(NoLock) 
	Exec dbo.PB_Log_Insert 'User_Optimization',@Desc,'User_Optimization'

	Set NoCount OFF;
END
