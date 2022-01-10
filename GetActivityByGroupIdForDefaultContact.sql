-- =============================================
-- Author:		Vasudev Patel
-- Create date: 13 Dec 2016
-- Description:	
--  Exec: GetActivityByGroupIdForDefaultContact 170,314
-- =============================================
CREATE PROCEDURE [dbo].[GetActivityByGroupIdForDefaultContact]
    @GroupId BIGINT ,
    @AppUserId BIGINT
AS
    BEGIN
        SELECT  
	DISTINCT    ISNULL(DC.Id, 0) AS Id ,
                EG.Id AS ActivityId ,
                EG.EstablishmentGroupName ,
                CONVERT(VARCHAR(10), ISNULL(DC.ContactId, 0)) + '_'
                + ( CASE DC.IsGroup
                      WHEN 1 THEN 'True'
                      ELSE 'False'
                    END ) AS ContactId
        FROM    dbo.AppUserEstablishment AS UE
                INNER JOIN dbo.Establishment AS E ON UE.EstablishmentId = E.Id
                INNER JOIN dbo.EstablishmentGroup AS EG ON E.EstablishmentGroupId = EG.Id
                LEFT JOIN dbo.DefaultContact AS DC ON EG.Id = DC.ActivityId
                                                      AND DC.AppUserId = @AppUserId AND DC.IsDeleted = 0
        WHERE   EG.GroupId = @GroupId
                AND EG.EstablishmentGroupType = 'Sales'
                AND EG.IsDeleted = 0
                AND UE.AppUserId = @AppUserId
                AND UE.IsDeleted = 0;
	
    END;