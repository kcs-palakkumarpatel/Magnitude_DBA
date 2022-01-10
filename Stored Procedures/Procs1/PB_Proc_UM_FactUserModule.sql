


CREATE Procedure [dbo].[PB_Proc_UM_FactUserModule]
As
BEGIN
	set NoCount On;

	Declare @Desc Varchar(200)
	Exec dbo.PB_Log_Insert 'UM_FactUserModule','UM_FactUserModule Start','User Management'

	Truncate table dbo.UM_FactUserModule

	
	Insert into UM_FactUserModule(AppUserID,AppmoduleId,AliasName,IsSelected,EstablishmentGroupId,EstablishmentGroupName)
	Select AppUserID,AppmoduleId,AliasName,IsSelected,EstablishmentGroupId,EstablishmentGroupName
	 from PB_VW_UM_FactUserModule

	Select @Desc = 'UM_FactUserModule Completed.( '+  Convert(Varchar,Count(1)) + ' ) Records Inserted'  From dbo.UM_FactUserModule(NoLock) 
	Exec dbo.PB_Log_Insert 'UM_FactUserModule',@Desc,'User Management'

	Set NoCount OFF;
END
