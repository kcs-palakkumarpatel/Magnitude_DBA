CREATE Procedure [dbo].[PB_Proc_Avocet_Fact_OnSiteJobStatus]
As
BEGIN
	set NoCount On;

	Declare @Desc Varchar(200)
	Exec dbo.PB_Log_Insert 'Avocet_Fact_OnSiteJobStatus','Avocet_Fact_OnSiteJobStatus Start','Avocet'

	Truncate table dbo.Avocet_Fact_OnSiteJobStatus

	
	Insert into Avocet_Fact_OnSiteJobStatus(Activity,ReferenceNo, AppUserId,UserName,StatusName,Statustime,StatusSort,
EndTime,TotalTime,Latitude,Longitude )
	select Activity,ReferenceNo, AppUserId,UserName,StatusName,Statustime,StatusSort,
EndTime,TotalTime,Latitude,Longitude 
	 from [PB_VW_Avocet_Fact_OnSiteJobStatus]

	Select @Desc = 'Avocet_Fact_OnSiteJobStatus Completed.( '+  Convert(Varchar,Count(1)) + ' ) Records Inserted'  From dbo.Avocet_Fact_OnSiteJobStatus(NoLock) 
	Exec dbo.PB_Log_Insert 'Avocet_Fact_OnSiteJobStatus',@Desc,'Avocet'

	Set NoCount OFF;
END
