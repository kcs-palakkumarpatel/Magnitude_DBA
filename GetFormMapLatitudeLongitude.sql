-- =============================================
-- Author:			D#3
-- Create date:	08-Dec-2017
-- Description:	Get Latitude Longitude Data For Forms.
-- Call SP:			dbo.GetFormMapLatitudeLongitude
-- =============================================
CREATE PROCEDURE [dbo].[GetFormMapLatitudeLongitude]
    @ReportIds NVARCHAR(MAX)
AS
    BEGIN
       
        SELECT  ReportId ,
                EstablishmentName ,
                UserName ,
                IsOut ,
                ISNULL(CAST(ISNULL(Latitude, 0) AS DECIMAL(18, 2)), 0) AS Latitude,
                ISNULL(CAST(ISNULL(Longitude, 0) AS DECIMAL(18, 2)), 0) AS Longitude
        FROM    dbo.View_AllAnswerMaster AS A
                INNER JOIN ( SELECT * FROM   dbo.Split(@ReportIds, ',') ) AS RP ON A.ReportId = RP.Data
				WHERE A.Latitude IS NOT NULL AND A.Longitude IS NOT NULL
				AND A.Latitude <> '0.00' AND A.Longitude <> '0.00'
   
    END;
