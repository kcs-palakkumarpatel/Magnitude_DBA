


Create Procedure [dbo].[PB_Proc_Masslift_Fact_DailyPlanFeedback]
As
BEGIN
	set NoCount On;

	Declare @Desc Varchar(200)
	Exec dbo.PB_Log_Insert 'Masslift_Fact_DailyPlanFeedback','Masslift_Fact_DailyPlanFeedback Start','Masslift'

	Truncate table dbo.Masslift_Fact_DailyPlanFeedback

	
	Insert into Masslift_Fact_DailyPlanFeedback(EstablishmentName,CapturedDate,ReferenceNo,IsPositive,Status,PI,UserId,UserName,
[Have you achieved your goals for today?],[If no, please explain what you didnt achieve and how you plan to rectify it:],
[Non-client facing tasks:],[Who did you cold call?],[If other, please state],[Time taken:],[Description of work:],
[Time travelled:],[KM travelled:],[How many cold calls did you make?],PlanCapturedDate,SeenClientAnswerMasterId,
EngagementRef, Activity,Customer,TimeTakenForEngagement,TypeOftaskForEngagement,WhatTranspiredInEngagement)
	select EstablishmentName,CapturedDate,ReferenceNo,IsPositive,Status,PI,UserId,UserName,
[Have you achieved your goals for today?],[If no, please explain what you didnt achieve and how you plan to rectify it:],
[Non-client facing tasks:],[Who did you cold call?],[If other, please state],[Time taken:],[Description of work:],
[Time travelled:],[KM travelled:],[How many cold calls did you make?],PlanCapturedDate,SeenClientAnswerMasterId,
EngagementRef, Activity,Customer,TimeTakenForEngagement,TypeOftaskForEngagement,WhatTranspiredInEngagement
	 from [PB_VW_Masslift_Fact_DailyPlanFeedback]

	Select @Desc = 'Masslift_Fact_DailyPlanFeedback Completed.( '+  Convert(Varchar,Count(1)) + ' ) Records Inserted'  From dbo.Masslift_Fact_DailyPlanCaptured(NoLock) 
	Exec dbo.PB_Log_Insert 'Masslift_Fact_DailyPlanFeedback',@Desc,'Masslift'

	Set NoCount OFF;
END
