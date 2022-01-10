CREATE Procedure [dbo].[PB_Proc_WorkForceStaffing_Fact_AppUser]
As
BEGIN
	set NoCount On;

	Declare @Desc Varchar(200)
	Exec dbo.PB_Log_Insert 'WorkForceStaffing_Fact_AppUser','WorkForceStaffing_Fact_AppUser Start','WorkForce Staffing'

	Truncate table dbo.WorkForceStaffing_Fact_AppUser

	
	Insert into WorkForceStaffing_Fact_AppUser([Region],[EstablishmentName],[Name],[UserName] )
	select [Region],[EstablishmentName],[Name],[UserName]
	 from [PB_VW_WorkForceStaffing_Fact_AppUser]

	Select @Desc = 'WorkForceStaffing_Fact_AppUser Completed.( '+  Convert(Varchar,Count(1)) + ' ) Records Inserted'  From dbo.WorkForceStaffing_Fact_AppUser(NoLock) 
	Exec dbo.PB_Log_Insert 'WorkForceStaffing_Fact_AppUser',@Desc,'WorkForce Staffing'

	Set NoCount OFF;
END
