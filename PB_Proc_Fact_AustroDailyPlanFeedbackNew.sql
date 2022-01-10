
CREATE Procedure [dbo].[PB_Proc_Fact_AustroDailyPlanFeedbackNew]
As
BEGIN
	set NoCount On;

	Declare @Desc Varchar(200)
	Exec dbo.PB_Log_Insert 'Fact_AustroDailyPlanFeedbackNew','Fact_AustroDailyPlanFeedbackNew Start','Austro'

	--Truncate table dbo.Fact_AustroDailyPlanFeedbackNew

	delete From Fact_AustroDailyPlanFeedbackNew where Flag=0
	
	Insert into Fact_AustroDailyPlanFeedbackNew(EstablishmentName ,CapturedDate ,ReferenceNo ,IsPositive ,Status ,PI,UserId,UserName ,SeenClientAnswerMasterId ,Longitude ,Latitude,
	[Achieve Plan] ,[Comment:] ,[Non-Client Time] ,[If other, please s] ,[Time taken:] ,[Description fo wor] ,[Time travelled: ] ,Activity ,Customer ,TimeTakenForEngagement ,
	TypeOftaskForEngagement , EngagementDescription,EngagementRef,Flag)
	select EstablishmentName ,CapturedDate ,ReferenceNo ,IsPositive ,Status ,PI,UserId,UserName ,SeenClientAnswerMasterId ,Longitude ,Latitude,
	[Achieve Plan] ,[Comment:] ,[Non-Client Time] ,[If other, please s] ,[Time taken:] ,[Description fo wor] ,[Time travelled: ] ,Activity ,Customer ,TimeTakenForEngagement ,
	TypeOftaskForEngagement , EngagementDescription,EngagementRef, 0 as Flag
	 from [PB_VW_Fact_AustroDailyPlanFeedbackNew]

	Select @Desc = 'Fact_AustroDailyPlanFeedbackNew Completed.( '+  Convert(Varchar,Count(1)) + ' ) Records Inserted'  From dbo.Fact_AustroDailyPlanFeedbackNew(NoLock) 
	Exec dbo.PB_Log_Insert 'Fact_AustroDailyPlanFeedbackNew',@Desc,'Austro'

	
	Set NoCount OFF;
END
