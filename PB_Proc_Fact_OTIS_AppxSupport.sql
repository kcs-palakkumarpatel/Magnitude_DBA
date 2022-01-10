
CREATE Procedure [dbo].[PB_Proc_Fact_OTIS_AppxSupport]
As
BEGIN
	set NoCount On;

	Declare @Desc Varchar(200)
	Exec dbo.PB_Log_Insert 'Fact_OTIS_AppxSupport','Fact_OTIS_AppxSupport Start','OTIS'

	Truncate table dbo.Fact_OTIS_AppxSupport
	
	Insert into Fact_OTIS_AppxSupport(EstablishmentName,CapturedDate,ReferenceNo,IsPositive,Status,UserId,UserName,
ResolvedDate,[Submitting for],[Colleagues],[Details],[Title],[Category],[Recurring],[Severity Assess],ResponseDate,
ResponseUser,[Root cause],[Root Cause Type],[Type of Fix],[Time Taken])
select 
	EstablishmentName,CapturedDate,ReferenceNo,IsPositive,Status,UserId,UserName,
ResolvedDate,[Submitting for],[Colleagues],[Details],[Title],[Category],[Recurring],[Severity Assess],ResponseDate,
ResponseUser,[Root cause],[Root Cause Type],[Type of Fix],[Time Taken]
  from PB_VW_Fact_OTIS_AppxSupport

	Select @Desc = 'Fact_OTIS_AppxSupport Completed.( '+  Convert(Varchar,Count(1)) + ' ) Records Inserted'  From dbo.Fact_OTIS_AppxSupport(NoLock) 
	Exec dbo.PB_Log_Insert 'Fact_OTIS_AppxSupport',@Desc,'OTIS'

	Set NoCount OFF;
END
