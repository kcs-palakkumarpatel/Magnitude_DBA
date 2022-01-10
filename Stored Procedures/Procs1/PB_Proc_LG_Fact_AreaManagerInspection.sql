CREATE PROCEDURE [dbo].[PB_Proc_LG_Fact_AreaManagerInspection]
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @Desc VARCHAR(200)
	EXEC dbo.PB_Log_Insert 'LG_Fact_AreaManagerInspection','LG_Fact_AreaManagerInspection Start','Life Green'

	TRUNCATE TABLE dbo.LG_Fact_AreaManagerInspection

	
	INSERT INTO LG_Fact_AreaManagerInspection(EstablishmentName,CapturedDate,ReferenceNo,Status,UserName,RepeatCount,
	[Client Name],[Site Address],[Select Month],MonthSort,[Week],[Watering],[Pruning],[Fertilizing],
	[Cleaning of Plants],[Rotating of Plants],[Caps],[Bark Dressing],[Pest Control],[Disease Control],
	[Overall impression],[Clients perception],[Client Full Name],[Date and Time IN],[Plant/Pot Replaced],
	[Plant Replacement],[Plant Description],[Quantity],[Location],[Reason],[Issue Description],[Watering Comments],
	[Pruning Comments],[Fertilizing Comments],[Cleaning of Plants Comments],[Rotating of Plants Comments],
	[Caps Comments],[Bark Dressing Comments],[Pest Control Comments],[Diesel Control Comments],[Watering Image],
[Pruning Image],
[Fertilizing Image],
[Cleaning Image],
[Rotating Image],
[Bark Image],
[Pest Control Image],
[Desease Ctrl Image],
[Caps Image],
[Picture of plant],
	ResponseDate,[Condition Site, Happy?],[Please explain],[Improvement Notes],[Attach Image],PI,[Managers comments])
	SELECT EstablishmentName,CapturedDate,ReferenceNo,Status,UserName,RepeatCount,
	[Client Name],[Site Address],[Select Month],MonthSort,[Week],[Watering],[Pruning],[Fertilizing],
	[Cleaning of Plants],[Rotating of Plants],[Caps],[Bark Dressing],[Pest Control],[Disease Control],
	[Overall impression],[Clients perception],[Client Full Name],[Date and Time IN],[Plant/Pot Replaced],
	[Plant Replacement],[Plant Description],[Quantity],[Location],[Reason],[Issue Description],[Watering Comments],
	[Pruning Comments],[Fertilizing Comments],[Cleaning of Plants Comments],[Rotating of Plants Comments],
	[Caps Comments],[Bark Dressing Comments],[Pest Control Comments],[Diesel Control Comments],[Watering Image],
[Pruning Image],
[Fertilizing Image],
[Cleaning Image],
[Rotating Image],
[Bark Image],
[Pest Control Image],
[Desease Ctrl Image],
[Caps Image],
[Picture of plant],
	ResponseDate,[Condition Site, Happy?],[Please explain],[Improvement Notes],[Attach Image],PI,[Managers comments]
	 FROM [PB_VW_LG_Fact_AreaManagerInspection]

	SELECT @Desc = 'LG_Fact_AreaManagerInspection Completed.( '+  CONVERT(VARCHAR,COUNT(1)) + ' ) Records Inserted'  FROM dbo.LG_Fact_AreaManagerInspection(NOLOCK) 
	EXEC dbo.PB_Log_Insert 'LG_Fact_AreaManagerInspection',@Desc,'Life Green'

	SET NOCOUNT OFF;
END
