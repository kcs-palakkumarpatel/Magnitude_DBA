


CREATE Procedure [dbo].[PB_Proc_UM_DimAppuser]
As
BEGIN
	set NoCount On;

	Declare @Desc Varchar(200)
	Exec dbo.PB_Log_Insert 'UM_DimAppuser','UM_DimAppuser Start','User Management'

	Truncate table dbo.UM_DimAppuser

	
	Insert into UM_DimAppuser(Id, Name, Email,Mobile,ISAreaManager,UserName,GroupId,AccessBulkSMS,AccessRemoveFromStatistics,IsActive,
	AllowDeleteFeedback,IsDefaultContact,ResolveAllRights,DatabaseReferenceOption,AllowImportContacts,AutoSave,AllowChangeContact,IsUserActive)
	Select Id, Name, Email,Mobile,ISAreaManager,UserName,GroupId,AccessBulkSMS,AccessRemoveFromStatistics,IsActive,
	AllowDeleteFeedback,IsDefaultContact,ResolveAllRights,DatabaseReferenceOption,AllowImportContacts,AutoSave,AllowChangeContact,IsUserActive
 
	 from PB_VW_UM_DimAppuser

	Select @Desc = 'UM_DimAppuser Completed.( '+  Convert(Varchar,Count(1)) + ' ) Records Inserted'  From dbo.UM_DimAppuser(NoLock) 
	Exec dbo.PB_Log_Insert 'UM_DimAppuser',@Desc,'User Management'

	Set NoCount OFF;
END
