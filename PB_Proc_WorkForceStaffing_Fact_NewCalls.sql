CREATE PROCEDURE [dbo].[PB_Proc_WorkForceStaffing_Fact_NewCalls]
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @Desc VARCHAR(200)
	EXEC dbo.PB_Log_Insert 'WorkForceStaffing_Fact_NewCalls','WorkForceStaffing_Fact_NewCalls Start','WorkForce Staffing'

	TRUNCATE TABLE dbo.WorkForceStaffing_Fact_NewCalls

	
	INSERT INTO WorkForceStaffing_Fact_NewCalls(EstablishmentName,CapturedDate,ReferenceNo,Status,UserName,
[Call Type],[Who have you spoken with?],[Do they need staff],[If yes, what staff do they need?],[Do they belong to a council?],
[Which council do they belong to?],[Estimate Monthly Revenue],[Did you secure an appointment],
[Company],[Industry],ResponseDate,ResponseRef,[Understand Value],[Value Not Clear],
[Met Requirements],[Why not],[User]
 )
	SELECT EstablishmentName,CapturedDate,ReferenceNo,Status,UserName,
[Call Type],[Who have you spoken with?],[Do they need staff],[If yes, what staff do they need?],[Do they belong to a council?],
[Which council do they belong to?],[Estimate Monthly Revenue],[Did you secure an appointment],
[Company],[Industry],ResponseDate,ResponseRef,[Understand Value],[Value Not Clear],
[Met Requirements],[Why not],[User]
	 FROM [PB_VW_WorkForceStaffing_Fact_NewCalls]

	SELECT @Desc = 'WorkForceStaffing_Fact_NewCalls Completed.( '+  CONVERT(VARCHAR,COUNT(1)) + ' ) Records Inserted'  FROM dbo.WorkForceStaffing_Fact_NewCalls(NOLOCK) 
	EXEC dbo.PB_Log_Insert 'WorkForceStaffing_Fact_NewCalls',@Desc,'WorkForce Staffing'

	SET NOCOUNT OFF;
END
