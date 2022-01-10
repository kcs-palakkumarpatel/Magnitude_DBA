

CREATE PROCEDURE [dbo].[PB_Proc_WorkForce_Fact_ServiceZoneCaptured]
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @Desc VARCHAR(200)
	EXEC dbo.PB_Log_Insert 'WorkForce_Fact_ServiceZoneCaptured','WorkForce_Fact_ServiceZoneCaptured Start','WorkForce Staffing'

	TRUNCATE TABLE dbo.WorkForce_Fact_ServiceZoneCaptured

	
	INSERT INTO WorkForce_Fact_ServiceZoneCaptured(Establishment,CapturedDate,ReferenceNo,IsPositive,FormStatus,UserName,[User],Longitude,
Latitude,RepeatCount,[Name],[Surname],[Mobile],[Email],[Company],[Industry],[Designation],
[Date],[Time],[Name of Client],[Name of Site],[Current Head count],[Contact Person],
[Attendees],[Apologies],[Reason for meeting],[Minutes],[Action Point],[Responsible Person],
[Deadline],[Compliments],[Pain Points],[Other Opportunity],[Rate Meeting])
	SELECT Establishment,CapturedDate,ReferenceNo,IsPositive,FormStatus,UserName,[User],Longitude,
Latitude,RepeatCount,[Name],[Surname],[Mobile],[Email],[Company],[Industry],[Designation],
[Date],[Time],[Name of Client],[Name of Site],[Current Head count],[Contact Person],
[Attendees],[Apologies],[Reason for meeting],[Minutes],[Action Point],[Responsible Person],
[Deadline],[Compliments],[Pain Points],[Other Opportunity],[Rate Meeting]
	 FROM [PB_VW_WorkForce_Fact_ServiceZoneCaptured]

	SELECT @Desc = 'WorkForce_Fact_ServiceZoneCaptured Completed.( '+  CONVERT(VARCHAR,COUNT(1)) + ' ) Records Inserted'  FROM dbo.WorkForce_Fact_ServiceZoneCaptured(NOLOCK) 
	EXEC dbo.PB_Log_Insert 'WorkForce_Fact_ServiceZoneCaptured',@Desc,'WorkForce Staffing'

	SET NOCOUNT OFF;
END
