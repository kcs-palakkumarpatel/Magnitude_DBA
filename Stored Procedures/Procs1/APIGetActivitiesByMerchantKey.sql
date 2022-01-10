
-- =============================================
-- Author:		Matthew Grinaker
-- Udated Date:	2020-04-09
-- Create date:	30-09-2016
-- Description:	Get Get Activity List for Web API Using MerchantKey
-- Call:        dbo.APIGetActivitiesByMerchantKey 413, 3297
-- =============================================
CREATE PROCEDURE [dbo].[APIGetActivitiesByMerchantKey]
    (
      @MerchantKey BIGINT = 0,
	  @ActivityID NVARCHAR(MAX) = '0'
	)
AS
    BEGIN
        SET NOCOUNT OFF;
		IF (@ActivityID != '0')
		BEGIN
        SELECT  Id AS ActivityId ,
                ISNULL(EstablishmentGroupName, '') AS ActivityName ,
                ISNULL(EstablishmentGroupType, '') AS ActivityType ,
                ISNULL(AboutEstablishmentGroup, '') AS ActivityGroup
        FROM    dbo.EstablishmentGroup
        WHERE   GroupId = @MerchantKey
				AND Id IN ( SELECT Data FROM dbo.Split(@ActivityID, ','))
                AND IsDeleted = 0
		END
		ELSE
		BEGIN
		 SELECT  Id AS ActivityId ,
                ISNULL(EstablishmentGroupName, '') AS ActivityName ,
                ISNULL(EstablishmentGroupType, '') AS ActivityType ,
                ISNULL(AboutEstablishmentGroup, '') AS ActivityGroup
        FROM    dbo.EstablishmentGroup
        WHERE   GroupId = @MerchantKey
                AND IsDeleted = 0
		END

    END;