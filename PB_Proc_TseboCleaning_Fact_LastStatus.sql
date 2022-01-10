CREATE Procedure [dbo].[PB_Proc_TseboCleaning_Fact_LastStatus]
As
BEGIN
	set NoCount On;

	Declare @Desc Varchar(200)
	Exec dbo.PB_Log_Insert 'TseboCleaning_Fact_LastStatus','TseboCleaning_Fact_LastStatus','Tsebo Cleaning'

	Truncate table dbo.TseboCleaning_Fact_LastStatus

	
	Insert into TseboCleaning_Fact_LastStatus(ReferenceNo,StatusName,Statustime,UserName,LastStatus)
	select ReferenceNo,StatusName,Statustime,UserName,LastStatus
	 from [PB_VW_TseboCleaning_Fact_LastStatus]

	Select @Desc = 'TseboCleaning_Fact_LastStatus Completed.( '+  Convert(Varchar,Count(1)) + ' ) Records Inserted'  From dbo.TseboCleaning_Fact_LastStatus(NoLock) 
	Exec dbo.PB_Log_Insert 'TseboCleaning_Fact_LastStatus',@Desc,'Tsebo Cleaning'

	Set NoCount OFF;
END
