

CREATE Procedure [dbo].[PB_Proc_LG_Fact_ClientScheduled1]
As
BEGIN
	set NoCount On;

	Declare @Desc Varchar(200)
	Exec dbo.PB_Log_Insert 'LG_Fact_ClientScheduled1','LG_Fact_ClientScheduled1 Start','Life Green'

	Truncate table dbo.LG_Fact_ClientScheduled1

	
	Insert into LG_Fact_ClientScheduled1(EstablishmentName,CapturedDate,ReferenceNo,Status,UserName,[Company Name],
[Site Address],[Contact Person],[Contact Person mob], [Scheduled Week],
[Scheduled Day],[Lead Technician])
	 
	 select EstablishmentName,CapturedDate,ReferenceNo,Status,UserName,[Company Name],
[Site Address],[Contact Person],[Contact Person mob], [Scheduled Week],
[Scheduled Day],[Lead Technician]
	 from [PB_VW_LG_Fact_ClientScheduled1]

	Select @Desc = 'LG_Fact_ClientScheduled1 Completed.( '+  Convert(Varchar,Count(1)) + ' ) Records Inserted'  From dbo.LG_Fact_ClientScheduled1(NoLock) 
	Exec dbo.PB_Log_Insert 'LG_Fact_ClientScheduled1',@Desc,'Life Green'

	Set NoCount OFF;
END
