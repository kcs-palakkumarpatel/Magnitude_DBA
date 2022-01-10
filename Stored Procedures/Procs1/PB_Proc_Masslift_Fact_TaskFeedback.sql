
Create Procedure [dbo].[PB_Proc_Masslift_Fact_TaskFeedback]
As
BEGIN
	set NoCount On;

	Declare @Desc Varchar(200)
	Exec dbo.PB_Log_Insert 'Masslift_Fact_TaskFeedback','Masslift_Fact_TaskFeedback Start','Masslift'

	Truncate table dbo.Masslift_Fact_TaskFeedback

	
	Insert into Masslift_Fact_TaskFeedback(EstablishmentName,CapturedDate,ReferenceNo,IsPositive,Status,PI,
Company,Email,Mobile,[Met Deadline],[If no, why?],[Completion Time],[Issues ],[If YES, please out],
[General Comments ],SeenclientAnswerMasterId)
	select EstablishmentName,CapturedDate,ReferenceNo,IsPositive,Status,PI,
Company,Email,Mobile,[Met Deadline],[If no, why?],[Completion Time],[Issues ],[If YES, please out],
[General Comments ],SeenclientAnswerMasterId
	 from [PB_VW_Masslift_Fact_TaskFeedback]

	Select @Desc = 'Masslift_Fact_TaskFeedback Completed.( '+  Convert(Varchar,Count(1)) + ' ) Records Inserted'  From dbo.Masslift_Fact_TaskFeedback(NoLock) 
	Exec dbo.PB_Log_Insert 'Masslift_Fact_TaskFeedback',@Desc,'Masslift'

	Set NoCount OFF;
END
