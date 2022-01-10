CREATE PROCEDURE [dbo].[PB_Proc_WorkForceStaffing_Fact_MonthlyPlan]
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @Desc VARCHAR(200)
	EXEC dbo.PB_Log_Insert 'WorkForceStaffing_Fact_MonthlyPlan','WorkForceStaffing_Fact_MonthlyPlan Start','WorkForce Staffing'

	TRUNCATE TABLE dbo.WorkForceStaffing_Fact_MonthlyPlan

	
	INSERT INTO WorkForceStaffing_Fact_MonthlyPlan(EstablishmentName,CapturedDate,ReferenceNo,Status,RepeatCount,UserName,[Month],[Cold Calling],[Getting Referrals],
[Getting leads from the company],[Setting up appointments],[Understanding client needs],[Explaining the value proposition],
[Handling objections],[Knowledge of group service offering],[Passing Leads],[Knowledge of T&Ci (Credit App)],[Knowledge of T&Ci (Vetting Process)],
[Knowledge of bargaining councils/industry],[Completing a costing template],[Onboarding Efficiency],[You vs Competition],
[How do you feel in general about deals lost?],[Your issues addressed?],[Getting on top of adhoc tasks],[Planned Appointments],
[Quotes to be Submitted],[Close Deals],[Revenue],[Product Knowledge],[Confidence],[Planning],[Presentation Material],[Training],
[Category],[Planned Deadline],[Task],[Meeting budget commitments],ResponseDate,ResposneMonth,[Getting Business],[Client Engagement],
[Leads],[Appointments],[Quotes Submitted],[Closed Deals],ResponseRevenue,[Achieve Targets ],[Please explain],[User])
	SELECT EstablishmentName,CapturedDate,ReferenceNo,Status,RepeatCount,UserName,[Month],[Cold Calling],[Getting Referrals],
[Getting leads from the company],[Setting up appointments],[Understanding client needs],[Explaining the value proposition],
[Handling objections],[Knowledge of group service offering],[Passing Leads],[Knowledge of T&Ci (Credit App)],[Knowledge of T&Ci (Vetting Process)],
[Knowledge of bargaining councils/industry],[Completing a costing template],[Onboarding Efficiency],[You vs Competition],
[How do you feel in general about deals lost?],[Your issues addressed?],[Getting on top of adhoc tasks],[Planned Appointments],
[Quotes to be Submitted],[Close Deals],[Revenue],[Product Knowledge],[Confidence],[Planning],[Presentation Material],[Training],
[Category],[Planned Deadline],[Task],[Meeting budget commitments],ResponseDate,ResposneMonth,[Getting Business],[Client Engagement],
[Leads],[Appointments],[Quotes Submitted],[Closed Deals],ResponseRevenue,[Achieve Targets ],[Please explain],[User]
	 FROM [PB_VW_WorkForceStaffing_Fact_MonthlyPlan]

	SELECT @Desc = 'WorkForceStaffing_Fact_MonthlyPlan Completed.( '+  CONVERT(VARCHAR,COUNT(1)) + ' ) Records Inserted'  FROM dbo.WorkForceStaffing_Fact_MonthlyPlan(NOLOCK) 
	EXEC dbo.PB_Log_Insert 'WorkForceStaffing_Fact_MonthlyPlan',@Desc,'WorkForce Staffing'

	SET NOCOUNT OFF;
END
