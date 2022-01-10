CREATE Procedure [dbo].[PB_Proc_Avocet_Fact_OverallStatus]
As
BEGIN
	set NoCount On;

	Declare @Desc Varchar(200)
	Exec dbo.PB_Log_Insert 'Avocet_Fact_OverallStatus','Avocet_Fact_OverallStatus Start','Avocet'

	Truncate table dbo.Avocet_Fact_OverallStatus

	
	Insert into Avocet_Fact_OverallStatus(ReferenceNo, AppUserId,UserName,StatusName,Statustime,StatusSort,
EndTime,TotalTime)
	select ReferenceNo, AppUserId,UserName,StatusName,Statustime,StatusSort,
EndTime,TotalTime
	 from [PB_VW_Avocet_Fact_OverallStatus]

	Select @Desc = 'Avocet_Fact_OverallStatus Completed.( '+  Convert(Varchar,Count(1)) + ' ) Records Inserted'  From dbo.Avocet_Fact_OverallStatus(NoLock) 
	Exec dbo.PB_Log_Insert 'Avocet_Fact_OverallStatus',@Desc,'Avocet'

	Set NoCount OFF;
END
