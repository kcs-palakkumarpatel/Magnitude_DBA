
CREATE Procedure [dbo].[PB_Proc_UM_FactChats]
As
BEGIN
	set NoCount On;

	Declare @Desc Varchar(200)
	Exec dbo.PB_Log_Insert 'UM_FactChats','UM_FactChats Start','User Management'

	Truncate table dbo.UM_FactChats

	
	Insert into UM_FactChats(UserId,Username,Id,GroupId,GroupName,EstablishmentId,EstablishmentName,ActivityId,Activity, ChatDate)
	select UserId,Username,Id,GroupId,GroupName,EstablishmentId,EstablishmentName,ActivityId,Activity, ChatDate
	 from PB_VW_UM_FactChats

	Select @Desc = 'UM_FactChats Completed.( '+  Convert(Varchar,Count(1)) + ' ) Records Inserted'  From dbo.UM_FactChats(NoLock) 
	Exec dbo.PB_Log_Insert 'UM_FactChats',@Desc,'User Management'

	Set NoCount OFF;
END
