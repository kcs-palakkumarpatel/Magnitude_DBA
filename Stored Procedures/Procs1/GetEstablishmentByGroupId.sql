-- =============================================
-- Author:		GetEstablishmentByActivityId
-- Create date: 
-- Description:	
-- Call: GetEstablishmentByGroupId
-- =============================================
CREATE PROCEDURE dbo.GetEstablishmentByGroupId
    -- Add the parameters for the stored procedure here
    @GroupId BIGINT
AS
BEGIN
    SET NOCOUNT ON;
    SELECT Id,
           EstablishmentName
    FROM dbo.Establishment WITH (NOLOCK)
    WHERE GroupId = @GroupId;
    SET NOCOUNT OFF;
END;
