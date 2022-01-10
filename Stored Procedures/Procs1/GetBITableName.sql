
-- =============================================
-- Author:      Vasudev
-- Create Date: 15-Oct-2019
-- Description: Get Status icon image for dropdonw in establishment
-- Call: dbo.GetStatusIconImage
-- =============================================
CREATE PROCEDURE [dbo].[GetBITableName]
(
@ActivityID BIGINT,
@isOUt BIT
)
AS
BEGIN
    SELECT "Table Name"     
    FROM dbo.BITableNames
	WHERE isDeleted = 0
	AND isOut = @isOUt
	AND ACtivityId = @ActivityID
END;
