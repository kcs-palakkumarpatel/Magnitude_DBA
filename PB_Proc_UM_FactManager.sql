
CREATE Procedure [dbo].[PB_Proc_UM_FactManager]
As
BEGIN
	set NoCount On;

	Declare @Desc Varchar(200)
	Exec dbo.PB_Log_Insert 'UM_FactUserManager','UM_FactUserManager Start','User Management'

	Truncate table dbo.UM_FactUserManager

	
	Insert into UM_FactUserManager(UserId, Name,UserName,EstablishmentId,ManagerUserId,ManagerName)
	Select UserId, Name,UserName,EstablishmentId,ManagerUserId,ManagerName
	 from PB_VW_UM_FactManager

	Select @Desc = 'UM_FactUserManager Completed.( '+  Convert(Varchar,Count(1)) + ' ) Records Inserted'  From dbo.UM_FactUserManager(NoLock) 
	Exec dbo.PB_Log_Insert 'UM_FactUserManager',@Desc,'User Management'

	Set NoCount OFF;
END