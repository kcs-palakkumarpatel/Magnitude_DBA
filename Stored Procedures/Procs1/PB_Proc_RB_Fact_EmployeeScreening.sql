
CREATE PROCEDURE [dbo].[PB_Proc_RB_Fact_EmployeeScreening]
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @Desc VARCHAR(200)
	EXEC dbo.PB_Log_Insert 'RB_Fact_EmployeeScreening','RB_Fact_EmployeeScreening Start','Royal Bafokeng'

	TRUNCATE TABLE dbo.RB_Fact_EmployeeScreening

	
	INSERT INTO RB_Fact_EmployeeScreening(EstablishmentName,CapturedDate,ReferenceNo,IsPositive,[FormStatus],PI,SeenClientAnswerMasterId,
Longitude,Latitude,[Employee Number],[Name],[Surname],[Mobile],[Contact with Covid],
[Travelled],[Where],[Fever],[Dry/Wet Cough],[Sore Throat],[Loss of Smell],
[Body Pain],[Diarrhoea],[Feeling Weak],[Hard to Breathe],[Other Symptoms],
[Please Explain],[New Mask Needed],[Sanitizer Needed],[Left Rustenburg],
[When],[Where travelled leaving rustenburg])
	SELECT EstablishmentName,CapturedDate,ReferenceNo,IsPositive,[FormStatus],PI,SeenClientAnswerMasterId,
Longitude,Latitude,[Employee Number],[Name],[Surname],[Mobile],[Contact with Covid],
[Travelled],[Where],[Fever],[Dry/Wet Cough],[Sore Throat],[Loss of Smell],
[Body Pain],[Diarrhoea],[Feeling Weak],[Hard to Breathe],[Other Symptoms],
[Please Explain],[New Mask Needed],[Sanitizer Needed],[Left Rustenburg],
[When],[Where travelled leaving rustenburg]
	 FROM [PB_VW_RB_Fact_EmployeeScreening]

	SELECT @Desc = 'RB_Fact_EmployeeScreening Completed.( '+  CONVERT(VARCHAR,COUNT(1)) + ' ) Records Inserted'  FROM dbo.RB_Fact_EmployeeScreening(NOLOCK) 
	EXEC dbo.PB_Log_Insert 'RB_Fact_EmployeeScreening',@Desc,'Royal Bafokeng'

	SET NOCOUNT OFF;
END
