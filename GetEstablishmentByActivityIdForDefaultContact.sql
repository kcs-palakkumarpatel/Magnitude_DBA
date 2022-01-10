-- =============================================
-- Author:		Vasudev Patel
-- Create date: 13 Dec 2016
-- Description:	
--  Exec: GetEstablishmentByActivityIdForDefaultContact  170,0,314
-- =============================================

CREATE PROCEDURE [dbo].[GetEstablishmentByActivityIdForDefaultContact]
    @GroupId BIGINT ,
    @ActivityId BIGINT ,
    @AppUserId BIGINT
AS
    BEGIN
        IF ( @ActivityId > 0 )
            BEGIN
                SELECT  ISNULL(DC.Id, 0) AS Id ,
                        EG.EstablishmentGroupName ,
                        E.Id AS EstablishmentId ,
                        E.EstablishmentName ,
                        CONVERT(VARCHAR(10), ISNULL(DC.ContactId, 0)) + '_'
                        + ( CASE DC.IsGroup
                              WHEN 1 THEN 'True'
                              ELSE 'False'
                            END ) AS ContactId
                FROM    dbo.Establishment AS E
                        INNER JOIN dbo.EstablishmentGroup AS EG ON EG.Id = E.EstablishmentGroupId
                        LEFT JOIN dbo.DefaultContact AS DC ON E.Id = DC.EstablishmentId AND DC.AppUserId = @AppUserId AND DC.IsDeleted = 0
						INNER JOIN dbo.AppUserEstablishment AS UE ON UE.EstablishmentId = E.Id AND UE.IsDeleted = 0 AND UE.AppUserId = @AppUserId
                WHERE   EG.GroupId = @GroupId
                        AND EG.Id = @ActivityId
                        AND EG.EstablishmentGroupType = 'Sales'
                        AND EG.IsDeleted = 0
						ORDER BY E.EstablishmentName;
            END;
        ELSE
          BEGIN
                SELECT  ISNULL(DC.Id, 0) AS Id ,
                        EG.EstablishmentGroupName ,
                        E.Id AS EstablishmentId ,
                        E.EstablishmentName ,
                        CONVERT(VARCHAR(10), ISNULL(DC.ContactId, 0)) + '_'
                        + ( CASE DC.IsGroup
                              WHEN 1 THEN 'True'
                              ELSE 'False'
                            END ) AS ContactId
                FROM    dbo.Establishment AS E
                        INNER JOIN dbo.EstablishmentGroup AS EG ON EG.Id = E.EstablishmentGroupId
                                                              AND E.IsDeleted = 0
                        LEFT JOIN dbo.DefaultContact AS DC ON E.Id = DC.EstablishmentId
                                                              AND DC.AppUserId = @AppUserId AND DC.IsDeleted = 0
						INNER JOIN dbo.AppUserEstablishment AS UE ON UE.EstablishmentId = E.Id AND UE.IsDeleted = 0 AND UE.AppUserId = @AppUserId
                WHERE   EG.GroupId = @GroupId
                        AND EG.EstablishmentGroupType = 'Sales'
                        AND EG.IsDeleted = 0
						ORDER by e.EstablishmentName;
            END;
        
    END;