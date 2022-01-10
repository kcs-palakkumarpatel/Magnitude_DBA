

CREATE Procedure [dbo].[PB_Proc_UM_FactUserEstablishment]
As
BEGIN
	set NoCount On;

	Declare @Desc Varchar(200)
	Exec dbo.PB_Log_Insert 'UM_FactUserEstablishment','UM_FactUserEstablishment Start','User Management'

	Truncate table dbo.UM_FactUserEstablishment

	
	Insert into UM_FactUserEstablishment(GroupId,GroupName,EstablishmentGroupId,EstablishmentGroupName,AppUserId,EstablishmentName,Id,EstablishmentType)
	Select GroupId,GroupName,EstablishmentGroupId,EstablishmentGroupName,AppUserId,EstablishmentName,Id,EstablishmentType
	 from PB_VW_UM_FactUserEstablishment

	Select @Desc = 'UM_FactUserEstablishment Completed.( '+  Convert(Varchar,Count(1)) + ' ) Records Inserted'  From dbo.UM_FactUserEstablishment(NoLock) 
	Exec dbo.PB_Log_Insert 'UM_FactUserEstablishment',@Desc,'User Management'

	Set NoCount OFF;
END
