
CREATE Procedure [dbo].[PB_Proc_JDF_Establishment_Group]
As
BEGIN
	set NoCount On;

	Declare @Desc Varchar(200)
	Exec dbo.PB_Log_Insert 'JDF_Establishment_Group','JDF_Establishment_Group Start','JDF'

	Truncate table dbo.JDF_Establishment_Group

	Insert Into dbo.JDF_Establishment_Group([Establishment Group Id],  [Establishment Group Name],[Establishment Group Type] ,[Group Name],[Sort Id]) 
	Select [Establishment Group Id],  [Establishment Group Name],[Establishment Group Type] ,[Group Name],[Sort Id] From dbo.JDF_BI_Vw_Establishment_Group


	Select @Desc = 'JDF_Establishment_Group Completed.( '+  Convert(Varchar,Count(1)) + ' ) Records Inserted'  From dbo.JDF_Establishment_Group(NoLock) 
	Exec dbo.PB_Log_Insert 'JDF_Establishment_Group',@Desc,'JDF'

	Set NoCount OFF;
END

