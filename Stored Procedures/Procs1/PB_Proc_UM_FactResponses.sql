CREATE Procedure [dbo].[PB_Proc_UM_FactResponses]
As
BEGIN
	set NoCount On;

	Declare @Desc Varchar(200)
	Exec dbo.PB_Log_Insert 'UM_FactResponses','UM_FactResponses Start','User Management'

	Truncate table dbo.UM_FactResponse

	
	Insert into UM_FactResponse(GroupId,GroupName ,ActivityId,Activity ,EstablishmentId,EstablishmentName,ResponseDate,
	SeenclientAnswermasterid,Id,IsSubmittedforgroup, ContactMasterid,UserEmail,UserId)
	select GroupId,GroupName ,ActivityId,Activity ,EstablishmentId,EstablishmentName,ResponseDate,
	SeenclientAnswermasterid,Id,IsSubmittedforgroup, ContactMasterid,UserEmail,UserId
	
	 from PB_VW_UM_FactResponses

	Select @Desc = 'UM_FactResponses Completed.( '+  Convert(Varchar,Count(1)) + ' ) Records Inserted'  From dbo.UM_FactResponse(NoLock) 
	Exec dbo.PB_Log_Insert 'UM_FactResponses',@Desc,'User Management'

	Set NoCount OFF;
END
