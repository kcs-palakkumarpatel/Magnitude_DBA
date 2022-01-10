

CREATE Procedure [dbo].[PB_Proc_Fact_AustroDailyPlanFeedback]
As
BEGIN
	set NoCount On;

	Declare @Desc Varchar(200)
	Exec dbo.PB_Log_Insert 'Fact_AustroDailyPlanFeedback','Fact_AustroDailyPlanFeedback Start','Austro'

	Truncate table dbo.Fact_AustroDailyPlanFeedback

	
	Insert into Fact_AustroDailyPlanFeedback(EstablishmentName ,CapturedDate,ReferenceNo ,IsPositive ,Status ,PI,UserId ,UserName,SeenClientAnswerMasterId ,Longitude,Latitude,
RepeatCount,[Achieve Plan],[Comment:],[Issues Today],[If yes what were t],[Company Name:],[Time taken],[Description of wor],
[Task Type Plan ],[Task Kind],[Actual Clients ],[Actual non-client],[Time Travelled ],[If applicable, ple] ,Activity ,
Customer ,TimeTakenForEngagement ,TypeOftaskForEngagement, EngagementDescription)
	select EstablishmentName ,CapturedDate,ReferenceNo ,IsPositive ,Status ,PI,UserId ,UserName,SeenClientAnswerMasterId ,Longitude,Latitude,
RepeatCount,[Achieve Plan],[Comment:],[Issues Today],[If yes what were t],[Company Name:],[Time taken],[Description of wor],
[Task Type Plan ],[Task Kind],[Actual Clients ],[Actual non-client],[Time Travelled ],[If applicable, ple] ,Activity ,
Customer ,TimeTakenForEngagement ,TypeOftaskForEngagement, EngagementDescription
	 from [PB_VW_Fact_AustroDailyPlanFeedback]

	Select @Desc = 'Fact_AustroDailyPlanFeedback Completed.( '+  Convert(Varchar,Count(1)) + ' ) Records Inserted'  From dbo.Fact_AustroDailyPlanFeedback(NoLock) 
	Exec dbo.PB_Log_Insert 'Fact_AustroDailyPlanFeedback',@Desc,'Austro'

	
	Set NoCount OFF;
END
