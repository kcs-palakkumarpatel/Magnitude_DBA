CREATE Procedure [dbo].[PB_Proc_TseboCleaning_Fact_CovidIsolationTracker]
As
BEGIN
	set NoCount On;

	Declare @Desc Varchar(200)
	Exec dbo.PB_Log_Insert 'TseboCleaning_Fact_CovidIsolationTracker','TseboCleaning_Fact_CovidIsolationTracker','Tsebo Cleaning'

	Truncate table dbo.TseboCleaning_Fact_CovidIsolationTracker

	
	Insert into TseboCleaning_Fact_CovidIsolationTracker(EstablishmentName ,CapturedDate,Status,ReferenceNo ,UserName,
StatusDateTime , StatusName,HR ,ResolvedDate ,[Employee Name],
[Employee ID],[Employee Mobile] ,[Employee address] ,
[Next of Kin NAME] ,[Next of Kin Mobile] ,[Alternative Mobile] ,[Relationship],ResponseDate, ResponseRef,SeenClientAnswerMasterId )
	select EstablishmentName ,CapturedDate,Status,ReferenceNo ,UserName,
StatusDateTime , StatusName,HR ,ResolvedDate ,[Employee Name],
[Employee ID],[Employee Mobile] ,[Employee address] ,
[Next of Kin NAME] ,[Next of Kin Mobile] ,[Alternative Mobile] ,[Relationship] ,ResponseDate, ResponseRef,SeenClientAnswerMasterId
	 from [PB_VW_TseboCleaning_Fact_CovidIsolationTracker]

	Select @Desc = 'TseboCleaning_Fact_CovidIsolationTracker Completed.( '+  Convert(Varchar,Count(1)) + ' ) Records Inserted'  From dbo.TseboCleaning_Fact_CovidIsolationTracker(NoLock) 
	Exec dbo.PB_Log_Insert 'TseboCleaning_Fact_CovidIsolationTracker',@Desc,'Tsebo Cleaning'

	Set NoCount OFF;
END
