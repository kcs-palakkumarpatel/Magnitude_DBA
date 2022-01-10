-- =============================================
-- Author:			Developer D3
-- Create date:	10-10-2017
-- Description:	
-- Call:					
-- =============================================
CREATE PROCEDURE [dbo].[GetActivityTypeByActivityId]
    @ActivityId BIGINT
AS
    BEGIN
       SELECT ISNULL(EstablishmentGroupType, '') AS ActivityType FROM dbo.EstablishmentGroup WHERE Id = @ActivityId AND IsDeleted = 0;
    END;
