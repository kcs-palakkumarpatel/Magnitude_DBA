
Create Procedure [dbo].[PB_Proc_Masslift_Dim_Company]
As
BEGIN
	set NoCount On;

	Declare @Desc Varchar(200)
	Exec dbo.PB_Log_Insert 'Masslift_Dim_Company','Masslift_Dim_Company Start','Masslift'

	Truncate table dbo.Masslift_Dim_Company

	
	Insert into Masslift_Dim_Company(Company)
	select Company
	 from [PB_VW_Masslift_Dim_Company]

	Select @Desc = 'Masslift_Dim_Company Completed.( '+  Convert(Varchar,Count(1)) + ' ) Records Inserted'  From dbo.Masslift_Dim_Company(NoLock) 
	Exec dbo.PB_Log_Insert 'Masslift_Dim_Company',@Desc,'Masslift'

	Set NoCount OFF;
END
