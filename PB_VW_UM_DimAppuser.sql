
Create view PB_VW_UM_DimAppuser
as
Select Id, Name, Email,Mobile,case when IsAreaManager=1 then 'Yes' else 'No' end ISAreaManager,UserName,GroupId,
case when AccessBulkSMS=1 then 'Yes' else 'No' end AccessBulkSMS,
case when AccessRemoveFromStatistics=1 then 'Yes' else 'No' end AccessRemoveFromStatistics,
case when IsActive=1 then 'Yes' else 'No' end IsActive,
case when AllowDeleteFeedback=1 then 'Yes' else 'No' end AllowDeleteFeedback,
case when IsDefaultContact=1 then 'Yes' else 'No' end IsDefaultContact,
case when ResolveAllRights=1 then 'Yes' else 'No' end ResolveAllRights,
case when DatabaseReferenceOption=1 then 'Yes' else 'No' end DatabaseReferenceOption,
case when AllowImportContacts=1 then 'Yes' else 'No' end AllowImportContacts,
case when AutoSave=1 then 'Yes' else 'No' end AutoSave,
case when AllowChangeContact=1 then 'Yes' else 'No' end AllowChangeContact,
case when IsUserActive=1 then 'Yes' else 'No' end IsUserActive
 from Appuser where isactive=1 and IsDeleted=0 or IsDeleted is null
