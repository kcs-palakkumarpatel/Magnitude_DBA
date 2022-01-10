
-- =============================================
-- Author:			Developer D3
-- Create date:	10-10-2017
-- Description:	
-- Call:					
-- =============================================
CREATE PROCEDURE [dbo].[GetActivityTypeandProductIssueApiStatusByActivityId_111721] @ActivityId BIGINT
AS
BEGIN
    SELECT ISNULL(EstablishmentGroupType, '') AS ActivityType,
           ISNULL(ProductIssueApiStatus, 0) AS ProductIssueApiStatus
    FROM dbo.EstablishmentGroup
    WHERE Id = @ActivityId
          AND IsDeleted = 0;
END;
