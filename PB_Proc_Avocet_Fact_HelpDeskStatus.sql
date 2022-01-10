CREATE Procedure [dbo].[PB_Proc_Avocet_Fact_HelpDeskStatus]
As
BEGIN
	set NoCount On;

	Declare @Desc Varchar(200)
	Exec dbo.PB_Log_Insert 'Avocet_Fact_HelpDeskStatus','Avocet_Fact_HelpDeskStatus Start','Avocet'

	Truncate table dbo.Avocet_Fact_HelpDeskStatus

	
	Insert into Avocet_Fact_HelpDeskStatus(Activity,ReferenceNo, AppUserId,UserName,StatusName,Statustime,StatusSort,
EndTime,TotalTime,Latitude,Longitude )
	select Activity,ReferenceNo, AppUserId,UserName,StatusName,Statustime,StatusSort,
EndTime,TotalTime,Latitude,Longitude 
	 from [PB_VW_Avocet_Fact_HelpDeskStatus]

	Select @Desc = 'Avocet_Fact_HelpDeskStatus Completed.( '+  Convert(Varchar,Count(1)) + ' ) Records Inserted'  From dbo.Avocet_Fact_HelpDeskStatus(NoLock) 
	Exec dbo.PB_Log_Insert 'Avocet_Fact_HelpDeskStatus',@Desc,'Avocet'

	Set NoCount OFF;
END
