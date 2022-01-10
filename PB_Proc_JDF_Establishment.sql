
CREATE Procedure [dbo].[PB_Proc_JDF_Establishment]
As
BEGIN
	set NoCount On;

	Declare @Desc Varchar(200)
	Exec dbo.PB_Log_Insert 'JDF_Establishment','JDF_Establishment Start','JDF'

	Truncate table dbo.JDF_Establishment

	Insert Into dbo.JDF_Establishment([Establishment Id] , [Establishment Name]) 
	Select [Establishment Id] , [Establishment Name] From dbo.JDF_BI_Vw_Establishment


	Select @Desc = 'JDF_Establishment Completed.( '+  Convert(Varchar,Count(1)) + ' ) Records Inserted'  From dbo.JDF_Establishment(NoLock) 
	Exec dbo.PB_Log_Insert 'JDF_Establishment',@Desc,'JDF'

	Set NoCount OFF;
END

