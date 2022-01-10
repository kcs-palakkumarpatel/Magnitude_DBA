

CREATE Procedure [dbo].[PB_Proc_UM_FactCaptured]
As
BEGIN
	set NoCount On;

	Declare @Desc Varchar(200)
	Exec dbo.PB_Log_Insert 'UM_FactCaptured','UM_FactCaptured Start','User Management'

	Truncate table dbo.UM_FactCaptured

	
	Insert into UM_FactCaptured(UserId,Username,Id,GroupId,GroupName,EstablishmentId,EstablishmentName,ActivityId,Activity ,CapturedDate)
	select UserId,Username,Id,GroupId,GroupName,EstablishmentId,EstablishmentName,ActivityId,Activity ,CapturedDate
	 from PB_VW_UM_FactCaptured

	Select @Desc = 'UM_FactCaptured Completed.( '+  Convert(Varchar,Count(1)) + ' ) Records Inserted'  From dbo.UM_FactCaptured(NoLock) 
	Exec dbo.PB_Log_Insert 'UM_FactCaptured',@Desc,'User Management'

	Set NoCount OFF;
END
