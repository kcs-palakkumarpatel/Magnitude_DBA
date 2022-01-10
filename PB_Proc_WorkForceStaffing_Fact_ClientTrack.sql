CREATE PROCEDURE [dbo].[PB_Proc_WorkForceStaffing_Fact_ClientTrack]
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @Desc VARCHAR(200)
	EXEC dbo.PB_Log_Insert 'WorkForceStaffing_Fact_ClientTrack','WorkForceStaffing_Fact_ClientTrack Start','WorkForce Staffing'

	TRUNCATE TABLE dbo.WorkForceStaffing_Fact_ClientTrack

	
	INSERT INTO WorkForceStaffing_Fact_ClientTrack(EstablishmentName,CapturedDate,ReferenceNo,Status,UserName,
	[Industry Sector],[Company Name],[Contact Person Name],[Contact Number (Mobile)],[Contact Number (Landline)],[Contact E-Mail],
[Client Address],[Date Engaged],[Method of Engagement],[Contractor Zone Category],ResponseDate,
ResponseRef,[What stage are we ],[Comm. Credit App],[Comments (Quote)],[Quote],[Movement Comments],
[Clients Needs],[Needs Still Req.],[Headcount Correct],[Please explain],[Assignee],[Supply not on time],
[Client Credentials],[Group Offerings],[Comments Confirms],[All Confirmed],[Sign Confirmations],[Closing Reason],[User])
	SELECT EstablishmentName,CapturedDate,ReferenceNo,Status,UserName,[Industry Sector],[Company Name],
[Contact Person Name],[Contact Number (Mobile)],[Contact Number (Landline)],[Contact E-Mail],
[Client Address],[Date Engaged],[Method of Engagement],[Contractor Zone Category],ResponseDate,
ResponseRef,[What stage are we ],[Comm. Credit App],[Comments (Quote)],[Quote],[Movement Comments],
[Clients Needs],[Needs Still Req.],[Headcount Correct],[Please explain],[Assignee],[Supply not on time],
[Client Credentials],[Group Offerings],[Comments Confirms],[All Confirmed],[Sign Confirmations],[Closing Reason],[User]
	 FROM [PB_VW_WorkForceStaffing_Fact_ClientTrack]

	SELECT @Desc = 'WorkForceStaffing_Fact_ClientTrack Completed.( '+  CONVERT(VARCHAR,COUNT(1)) + ' ) Records Inserted'  FROM dbo.WorkForceStaffing_Fact_ClientTrack(NOLOCK) 
	EXEC dbo.PB_Log_Insert 'WorkForceStaffing_Fact_ClientTrack',@Desc,'WorkForce Staffing'

	SET NOCOUNT OFF;
END
