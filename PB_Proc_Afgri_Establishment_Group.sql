CREATE Procedure [dbo].[PB_Proc_Afgri_Establishment_Group]
As
BEGIN
	set NoCount On;

	Declare @Desc Varchar(200)
	Exec dbo.PB_Log_Insert 'Afgri_EstablishmentGroup','Afgri_EstablishmentGroup Start','JDF'

	Truncate table dbo.Afgri_EstablishmentGroup

	Insert Into dbo.Afgri_EstablishmentGroup([Establishment Group Id],  [Establishment Group Name],[Establishment Group Type] ,[Group Name]) 
	Select [Establishment Group Id],  [Establishment Group Name],[Establishment Group Type] ,[Group Name] From dbo.BI_Vw_Establishment_Group


	Select @Desc = 'Afgri_EstablishmentGroup Completed.( '+  Convert(Varchar,Count(1)) + ' ) Records Inserted'  From dbo.Afgri_EstablishmentGroup(NoLock) 
	Exec dbo.PB_Log_Insert 'Afgri_EstablishmentGroup',@Desc,'Afgri'

	Set NoCount OFF;
END

