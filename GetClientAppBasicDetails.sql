-- =============================================
-- Author:		<Author,,Anant Bhatt>
-- Create date: <Create Date,, 25 May 2015>
-- Description:	<Description,,GetUserById>
-- Call SP    :	GetClientAppBasicDetails
-- =============================================
CREATE PROCEDURE [dbo].[GetClientAppBasicDetails]
AS
    BEGIN
        SELECT  Id AS Id ,
                ClientName AS ClientName ,
                AppName AS AppName,
                AppLogo AS AppLogo ,
                AppBackgroundImage AS BackgroundImage ,
                AppDashboardImage AS DashboardImage ,
                AppHeaderLogo AS HeaderLogo,
				AppDashboardBackgroundImage AS AppDashboardBackgroundImage,
				WebAppurl AS WebAppurl,
				LoginFlag AS LoginFlag,
				WebVersion AS WebVersion,
				LANGUAGE AS language
        FROM    dbo.clientInfo
			OPTION (RECOMPILE);
    END;
