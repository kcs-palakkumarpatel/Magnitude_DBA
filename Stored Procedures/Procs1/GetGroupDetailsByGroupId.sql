-- =============================================
-- Author:			Developer D3
-- Create date:	01-18-2017
-- Description:	Get Group For Generate MerchantKey For API
-- Call:					dbo.GetGroupDetailsByGroupId 27
-- =============================================
CREATE PROCEDURE dbo.GetGroupDetailsByGroupId ( @GroupId BIGINT = 0 )
AS
    BEGIN
        SET NOCOUNT OFF;

        SELECT  CAST(Id AS NVARCHAR(20)) + '_' + ISNULL(GroupName, '') + '_'
                + dbo.ChangeDateFormat(CreatedOn, 'MM-dd-yyyy') AS SecurityKey
        FROM    dbo.[Group]
        WHERE   Id = @GroupId
                AND IsDeleted = 0;
    END;
