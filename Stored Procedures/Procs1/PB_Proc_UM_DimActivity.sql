

CREATE Procedure [dbo].[PB_Proc_UM_DimActivity]
As
BEGIN
	set NoCount On;

	Declare @Desc Varchar(200)
	Exec dbo.PB_Log_Insert 'UM_DimActivity','UM_DimActivity Start','User Management'

	Truncate table dbo.UM_DimActivity

	
	Insert into UM_DimActivity(Id,ActivityName)
	select Id,ActivityName
	 from PB_VW_UM_DimActivity

	Select @Desc = 'UM_DimActivity Completed.( '+  Convert(Varchar,Count(1)) + ' ) Records Inserted'  From dbo.UM_DimActivity(NoLock) 
	Exec dbo.PB_Log_Insert 'UM_DimActivity',@Desc,'User Management'

	Set NoCount OFF;
END

