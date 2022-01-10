


CREATE PROCEDURE [dbo].[PB_Proc_LG_Fact_SiteVisitCaptured]
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @Desc VARCHAR(200)
	EXEC dbo.PB_Log_Insert 'LG_Fact_SiteVisitCaptured','LG_Fact_SiteVisitCaptured Start','Life Green'

	TRUNCATE TABLE dbo.LG_Fact_SiteVisitCaptured

	
	INSERT INTO LG_Fact_SiteVisitCaptured(EstablishmentName,CapturedDate,ReferenceNo,Status,UserName,[Client Name],
	[Site address],[Lead Technician],[Day of week],DaySort,[Which week],Latitude,Longitude)
	SELECT EstablishmentName,CapturedDate,ReferenceNo,Status,UserName,[Client Name],
	[Site address],[Lead Technician],[Day of week],DaySort,[Which week],Latitude,Longitude
	 FROM [PB_VW_LG_Fact_SiteVisitCaptured]

	SELECT @Desc = 'LG_Fact_SiteVisitCaptured Completed.( '+  CONVERT(VARCHAR,COUNT(1)) + ' ) Records Inserted'  FROM dbo.LG_Fact_SiteVisitCaptured(NOLOCK) 
	EXEC dbo.PB_Log_Insert 'LG_Fact_SiteVisitCaptured',@Desc,'Life Green'

	SET NOCOUNT OFF;
END
