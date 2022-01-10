
CREATE Procedure [dbo].[PB_Proc_Afgri_Establishment]
As
BEGIN
	set NoCount On;

	Declare @Desc Varchar(200)
	Exec dbo.PB_Log_Insert 'Afgri_Establishment','Afgri_Establishment Start','Afgri'

	Truncate table dbo.Afgri_Establishment

	Insert Into dbo.Afgri_Establishment([Establishment Id] , [Establishment Name]) 
	Select [Establishment Id] , [Establishment Name] From dbo.BI_Vw_Establishment


	Select @Desc = 'Afgri_Establishment Completed.( '+  Convert(Varchar,Count(1)) + ' ) Records Inserted'  From dbo.Afgri_Establishment(NoLock) 
	Exec dbo.PB_Log_Insert 'Afgri_Establishment',@Desc,'Afgri'

	Set NoCount OFF;
END

