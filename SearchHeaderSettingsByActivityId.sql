-- =============================================
-- Author:		<Author,,ADMIN>
-- Create date: <Create Date,, 16 Dec 2016>
-- Description:	<Description,,GetHeaderSettingAll>
-- Call SP    :	dbo.SearchHeaderSettingsByActivityId		70
-- =============================================
CREATE PROCEDURE [dbo].[SearchHeaderSettingsByActivityId]
   	@ActivityId BIGINT 
AS
    BEGIN       SELECT 	   HS.HeaderName AS [HeaderName],       HS.HeaderValue AS [HeaderValue],	   ISNULL(HS.LabelColor,'') AS LabelColor,	   ISNULL(HS.IsLabel,0) AS IsLabel	    FROM dbo.HeaderSetting AS HS WHERE HS.EstablishmentGroupId= @ActivityId           END;
