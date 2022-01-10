

CREATE Procedure [dbo].[PB_Proc_UM_FactResolved]
As
BEGIN
	set NoCount On;

	Declare @Desc Varchar(200)
	Exec dbo.PB_Log_Insert 'UM_FactResolved','UM_FactResolved Start','User Management'

	Truncate table dbo.UM_FactResolved

	
	Insert into UM_FactResolved(UserId,Username,Id,GroupId,GroupName,EstablishmentId,EstablishmentName,ActivityId,Activity ,ResolvedDate)
	select UserId,Username,Id,GroupId,GroupName,EstablishmentId,EstablishmentName,ActivityId,Activity ,ResolvedDate
	 from PB_VW_UM_FactResolved

	Select @Desc = 'UM_FactResolved Completed.( '+  Convert(Varchar,Count(1)) + ' ) Records Inserted'  From dbo.UM_FactResolved(NoLock) 
	Exec dbo.PB_Log_Insert 'UM_FactResolved',@Desc,'User Management'

	Set NoCount OFF;
END
