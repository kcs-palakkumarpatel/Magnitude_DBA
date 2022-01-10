CREATE PROCEDURE [dbo].[PB_Proc_WorkForceStaffing_Fact_FollowUp]
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @Desc VARCHAR(200)
	EXEC dbo.PB_Log_Insert 'WorkForceStaffing_Fact_FollowUp','WorkForceStaffing_Fact_FollowUp Start','WorkForce Staffing'

	TRUNCATE TABLE dbo.WorkForceStaffing_Fact_FollowUp

	
	INSERT INTO WorkForceStaffing_Fact_FollowUp(EstablishmentName,CapturedDate,ReferenceNo,Status,UserName,
[Type of Follow Up],[Time taken],[Type of account],[Today you met with the],[How is your relationship with the client?],[Reason for the meeting?],
[Have you quoted the client?],[If Yes, What amount was quoted per month],[Company],[Industry],ResponseDate,ResponseRef,[Happy With Service],[Why are you unhapp],
[Requirements Met],[Not Met],[User])
	SELECT EstablishmentName,CapturedDate,ReferenceNo,Status,UserName,
[Type of Follow Up],[Time taken],[Type of account],[Today you met with the],[How is your relationship with the client?],[Reason for the meeting?],
[Have you quoted the client?],[If Yes, What amount was quoted per month],[Company],[Industry],ResponseDate,ResponseRef,[Happy With Service],[Why are you unhapp],
[Requirements Met],[Not Met],[User]
	 FROM [PB_VW_WorkForceStaffing_Fact_FollowUp]

	SELECT @Desc = 'WorkForceStaffing_Fact_FollowUp Completed.( '+  CONVERT(VARCHAR,COUNT(1)) + ' ) Records Inserted'  FROM dbo.WorkForceStaffing_Fact_FollowUp(NOLOCK) 
	EXEC dbo.PB_Log_Insert 'WorkForceStaffing_Fact_FollowUp',@Desc,'WorkForce Staffing'

	SET NOCOUNT OFF;
END
