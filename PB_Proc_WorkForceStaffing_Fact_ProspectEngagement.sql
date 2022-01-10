CREATE PROCEDURE [dbo].[PB_Proc_WorkForceStaffing_Fact_ProspectEngagement]
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @Desc VARCHAR(200)
	EXEC dbo.PB_Log_Insert 'WorkForceStaffing_Fact_ProspectEngagement','WorkForceStaffing_Fact_ProspectEngagement Start','WorkForce Staffing'

	TRUNCATE TABLE dbo.WorkForceStaffing_Fact_ProspectEngagement

	
	INSERT INTO WorkForceStaffing_Fact_ProspectEngagement(EstablishmentName,CapturedDate,ReferenceNo,Status,UserName,Longitude,Latitude,
[Time taken],[Today you met with the],[Meeting perception],[Have you spotted any additional gaps ?],
[What additional gaps have been spotted?],[Do you believe you have portrayed the value proposition],
[Validate the above answers],[Are you facing any resistance?],[Reasons for resistance],
[Explain the resistance],[Was the price discussed?],[What was discussed],
[What transpired in the meeting and next steps agreed?],[Date for next milestone],
[Company],[Industry],ResponseDate,ResponseRef,[Salesman Rating],[How can we improve],[What impressed you],
[Happy with service],[Why are you unhapp],[Meet Requirements],[What did we not me],[Experience],[Experience Notes],
[All Solutions],[Solutions Needed],[Like Most],[User],[Headcount Estimate] )
	SELECT EstablishmentName,CapturedDate,ReferenceNo,Status,UserName,Longitude,Latitude,
[Time taken],[Today you met with the],[Meeting perception],[Have you spotted any additional gaps ?],
[What additional gaps have been spotted?],[Do you believe you have portrayed the value proposition],
[Validate the above answers],[Are you facing any resistance?],[Reasons for resistance],
[Explain the resistance],[Was the price discussed?],[What was discussed],
[What transpired in the meeting and next steps agreed?],[Date for next milestone],
[Company],[Industry],ResponseDate,ResponseRef,[Salesman Rating],[How can we improve],[What impressed you],
[Happy with service],[Why are you unhapp],[Meet Requirements],[What did we not me],[Experience],[Experience Notes],
[All Solutions],[Solutions Needed],[Like Most],[User],[Headcount Estimate]

	 FROM [PB_VW_WorkForceStaffing_Fact_ProspectEngagement]

	SELECT @Desc = 'WorkForceStaffing_Fact_ProspectEngagement Completed.( '+  CONVERT(VARCHAR,COUNT(1)) + ' ) Records Inserted'  FROM dbo.WorkForceStaffing_Fact_ProspectEngagement(NOLOCK) 
	EXEC dbo.PB_Log_Insert 'WorkForceStaffing_Fact_ProspectEngagement',@Desc,'WorkForce Staffing'

	SET NOCOUNT OFF;
END
