CREATE PROCEDURE [dbo].[PB_Proc_WorkForceStaffing_Fact_LeadAllocation]
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @Desc VARCHAR(200)
	EXEC dbo.PB_Log_Insert 'WorkForceStaffing_Fact_LeadAllocation','WorkForceStaffing_Fact_LeadAllocation Start','WorkForce Staffing'

	TRUNCATE TABLE dbo.WorkForceStaffing_Fact_LeadAllocation

	
	INSERT INTO WorkForceStaffing_Fact_LeadAllocation(EstablishmentName,CapturedDate ,ReferenceNo ,Status ,UserName ,LeadRecievedByUser,[Company Name] ,
[Contact details] ,[Designation],[Contact Person Full Name] ,[E-Mail] ,[Mobile] ,
[Landline] ,[Preferred Communication] ,[Staffing Requirement],
[Attach the Spec or PDF Export of the lead logged],[Date Required (Start)], 
[Date Required To (End)],ResponseDate ,ResponseRef ,[Lead Status] ,[Unqualified Reason] ,
[Meeting Date] ,[Next Steps],[Comments],[Attachments],[User] )
	SELECT EstablishmentName,CapturedDate ,ReferenceNo ,Status ,UserName ,LeadRecievedByUser,[Company Name] ,
[Contact details] ,[Designation],[Contact Person Full Name] ,[E-Mail] ,[Mobile] ,
[Landline] ,[Preferred Communication] ,[Staffing Requirement],
[Attach the Spec or PDF Export of the lead logged],[Date Required (Start)], 
[Date Required To (End)],ResponseDate ,ResponseRef ,[Lead Status] ,[Unqualified Reason] ,
[Meeting Date] ,[Next Steps],[Comments],[Attachments],[User] 
	 FROM [PB_VW_WorkForceStaffing_Fact_LeadAllocation]

	SELECT @Desc = 'WorkForceStaffing_Fact_LeadAllocation Completed.( '+  CONVERT(VARCHAR,COUNT(1)) + ' ) Records Inserted'  FROM dbo.WorkForceStaffing_Fact_LeadAllocation(NOLOCK) 
	EXEC dbo.PB_Log_Insert 'WorkForceStaffing_Fact_LeadAllocation',@Desc,'WorkForce Staffing'

	SET NOCOUNT OFF;
END
