
CREATE Procedure [dbo].[PB_Proc_UM_DimGroup]
As
BEGIN
	set NoCount On;

	Declare @Desc Varchar(200)
	Exec dbo.PB_Log_Insert 'UM_DimGroup','UM_DimGroup Start','User Management'

	Truncate table dbo.UM_DimGroup

	
	Insert into UM_DimGroup(Id,GroupName)
	select Id,GroupName
	 from PB_VW_UM_DimGroup

	Select @Desc = 'UM_DimGroup Completed.( '+  Convert(Varchar,Count(1)) + ' ) Records Inserted'  From dbo.UM_DimGroup(NoLock) 
	Exec dbo.PB_Log_Insert 'UM_DimGroup',@Desc,'User Management'


	Exec dbo.PB_Log_Insert 'Dim_UpdateDateTime','Dim_UpdateDateTime Start','UserManagement'


	Truncate table dbo.Dim_UpdateDateTime_UserManagement

	Insert Into dbo.Dim_UpdateDateTime_UserManagement
	Select * From [dbo].[VW_Dim_UpdateDateTime]

	Select @Desc = 'Dim_UpdateDateTime Completed.( 1 ) Records Inserted' 
	Exec dbo.PB_Log_Insert 'Dim_UpdateDateTime',@Desc,'User Management'

	Set NoCount OFF;
END

