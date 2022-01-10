
CREATE Procedure [dbo].[PB_Proc_JohnDeere_Establishment]
As
BEGIN
	set NoCount On;

	Declare @Desc Varchar(200)
	Exec dbo.PB_Log_Insert 'JohnDeere_Establishment','JohnDeere_Establishment Start','JohnDeere'

	Truncate table dbo.JohnDeere_Establishment

	Insert Into dbo.JohnDeere_Establishment([Establishment Id] , [Establishment Name]) 
	Select [Establishment Id] , [Establishment Name] From dbo.JD_BI_Vw_Establishment


	Select @Desc = 'JohnDeere_Establishment Completed.( '+  Convert(Varchar,Count(1)) + ' ) Records Inserted'  From dbo.JohnDeere_Establishment(NoLock) 
	Exec dbo.PB_Log_Insert 'JohnDeere_Establishment',@Desc,'JohnDeere'

	Set NoCount OFF;
END

