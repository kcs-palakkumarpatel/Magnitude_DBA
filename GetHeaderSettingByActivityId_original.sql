-- GetHeaderSettingByActivityId 4633
create PROCEDURE dbo.GetHeaderSettingByActivityId_original @ActivityId BIGINT
AS
    BEGIN        SELECT  [HeaderId] AS HeaderId ,
                CAST(GroupId AS BIGINT) AS GroupId ,
                [EstablishmentGroupId] AS ActivityId ,
                ISNULL([HeaderName], '') AS HeaderName ,
                ISNULL([HeaderValue], '') AS HeaderValue
        FROM    dbo.[HeaderSetting]
        WHERE   EstablishmentGroupId = @ActivityId AND IsDeleted = 0
		GROUP BY ISNULL([HeaderName], '') ,
                 ISNULL([HeaderValue], '') ,
                 HeaderId ,
                 EstablishmentGroupId,
				  GroupId
            END;
