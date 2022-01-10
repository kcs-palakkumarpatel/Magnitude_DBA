
CREATE Procedure [dbo].[PB_Proc_UM_DimEstablishment]
As
BEGIN
	set NoCount On;

	Declare @Desc Varchar(200)
	Exec dbo.PB_Log_Insert 'UM_DimEstablishment','UM_DimEstablishment Start','User Management'

	Truncate table dbo.UM_DimEstablishment

	
	Insert into UM_DimEstablishment(Id,EstablishmentName)
	select Id,EstablishmentName
	 from PB_VW_UM_DimEstablishment

	Select @Desc = 'UM_DimEstablishment Completed.( '+  Convert(Varchar,Count(1)) + ' ) Records Inserted'  From dbo.UM_DimEstablishment(NoLock) 
	Exec dbo.PB_Log_Insert 'UM_DimEstablishment',@Desc,'User Management'

	Set NoCount OFF;
END

