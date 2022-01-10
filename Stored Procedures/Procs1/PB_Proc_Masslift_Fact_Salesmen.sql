CREATE Procedure [dbo].[PB_Proc_Masslift_Fact_Salesmen]
As
BEGIN
	set NoCount On;

	Declare @Desc Varchar(200)
	Exec dbo.PB_Log_Insert 'Masslift_Fact_Salesmen','Masslift_Fact_Salesmen Start','Masslift'

	Truncate table dbo.Masslift_Fact_Salesmen

	
	Insert into Masslift_Fact_Salesmen(ReferenceNo,RepeatCount,[Sale reps],[New sales target],[New sales YTD],[Used sales target],[Used sales YTD],[Month],[Year] )
	select ReferenceNo,RepeatCount,[Sale reps],[New sales target ],[New sales YTD],[Used sales target],[Used sales YTD],[Month ],[Year ] 
	 from [PB_VW_Masslift_Fact_Salesmen]

	Select @Desc = 'Masslift_Fact_Salesmen Completed.( '+  Convert(Varchar,Count(1)) + ' ) Records Inserted'  From dbo.Masslift_Fact_Salesmen(NoLock) 
	Exec dbo.PB_Log_Insert 'Masslift_Fact_Salesmen',@Desc,'Masslift'

	Set NoCount OFF;
END
