-- =============================================
-- Author:      Vasudev
-- Create Date: 15-Oct-2019
-- Description: Get Status icon image for dropdonw in establishment
-- Call: dbo.GetStatusIconImage
-- =============================================
CREATE PROCEDURE dbo.GetStatusIconImage
AS
BEGIN
    SELECT Id,
           IconName,
		   IconPath,
		   Descriptions
    FROM dbo.StatusIconImage;
END;
