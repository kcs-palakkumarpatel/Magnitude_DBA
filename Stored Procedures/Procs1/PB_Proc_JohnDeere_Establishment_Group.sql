
Create Procedure [dbo].[PB_Proc_JohnDeere_Establishment_Group]
As
BEGIN
	set NoCount On;

	Declare @Desc Varchar(200)
	Exec dbo.PB_Log_Insert 'JohnDeere_EstablishmentGroup','JohnDeere_EstablishmentGroup Start','JohnDeere'

	Truncate table dbo.JohnDeere_EstablishmentGroup

	Insert Into dbo.JohnDeere_EstablishmentGroup([Establishment Group Id],  [Establishment Group Name],[Establishment Group Type] ,[Group Name]) 
	Select [Establishment Group Id],  [Establishment Group Name],[Establishment Group Type] ,[Group Name] From dbo.JD_BI_Vw_Establishment_Group


	Select @Desc = 'JohnDeere_EstablishmentGroup Completed.( '+  Convert(Varchar,Count(1)) + ' ) Records Inserted'  From dbo.JohnDeere_EstablishmentGroup(NoLock) 
	Exec dbo.PB_Log_Insert 'JohnDeere_EstablishmentGroup',@Desc,'Afgri'

	Set NoCount OFF;
END

