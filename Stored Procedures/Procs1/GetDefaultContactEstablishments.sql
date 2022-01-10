-- =============================================
-- Author:			D3
-- Create date:	13 Dec 2017
-- Description:	
--  Exec:				dbo.GetDefaultContactEstablishments  651,7157,18484
-- =============================================
CREATE PROCEDURE dbo.GetDefaultContactEstablishments
    @GroupId BIGINT,
    @ActivityId BIGINT,
    @AppUserId BIGINT
AS
BEGIN
    IF OBJECT_ID('dbo.TEST_ESTABLISHMENT', 'U') IS NOT NULL
        DROP TABLE dbo.TEST_ESTABLISHMENT;

    CREATE TABLE dbo.TEST_ESTABLISHMENT
    (
        DefaultContactId BIGINT,
        ContactMasterId BIGINT,
        ActivityId BIGINT,
        ActivityName NVARCHAR(100),
        EstablishmentId BIGINT,
        EstablishmentName NVARCHAR(100),
        ContactName NVARCHAR(255),
        CreatedOn DATETIME
    );
    IF (@ActivityId > 0)
    BEGIN
        INSERT INTO TEST_ESTABLISHMENT
        SELECT ISNULL(DC.Id, 0) AS DefaultContactId,
               ISNULL(DC.ContactId, 0) AS ContactMasterId,
               ISNULL(EG.Id, 0) AS ActivityId,
               ISNULL(EG.EstablishmentGroupName, '') AS ActivityName,
               ISNULL(E.Id, 0) AS EstablishmentId,
               ISNULL(E.EstablishmentName, '') AS EstablishmentName,
               CASE
                   WHEN DC.IsGroup = 1 THEN
                   (
                       SELECT ContactGropName FROM dbo.ContactGroup WHERE Id = DC.ContactId
                   )
                   ELSE
                       ISNULL((STUFF(
                               (
                                   SELECT ',' + CD.Detail
                                   FROM dbo.ContactDetails AS CD
                                       INNER JOIN dbo.ContactQuestions AS CQ
                                           ON CQ.Id = CD.ContactQuestionId
                                   WHERE CD.ContactMasterId = DC.ContactId
                                         AND CQ.ContactId = GP.ContactId
                                         AND CQ.IsDeleted = 0
                                         AND CQ.IsDisplayInSummary = 1
                                   ORDER BY CQ.Position ASC
                                   FOR XML PATH('')
                               ),
                               1,
                               1,
                               ''
                                    )
                              ),
                              ''
                             )
               END AS ContactName,
               DC.CreatedOn
        FROM dbo.Establishment AS E
            INNER JOIN dbo.EstablishmentGroup AS EG
                ON EG.Id = E.EstablishmentGroupId
            INNER JOIN dbo.[Group] AS GP
                ON GP.Id = E.GroupId
                   AND GP.Id = EG.GroupId
            LEFT JOIN dbo.DefaultContact AS DC
                ON E.Id = DC.EstablishmentId
                   AND DC.AppUserId = @AppUserId
                   AND DC.IsDeleted = 0
            INNER JOIN dbo.AppUserEstablishment AS UE
                ON UE.EstablishmentId = E.Id
                   AND UE.IsDeleted = 0
                   AND UE.AppUserId = @AppUserId
        WHERE GP.Id = @GroupId
              AND EG.GroupId = @GroupId
              AND EG.Id = @ActivityId
              AND EG.EstablishmentGroupType = 'Sales'
              AND EG.IsDeleted = 0
        ORDER BY E.EstablishmentName;

        SELECT *
        FROM dbo.VW_TEST_ESTABLISHMENT;
    END;
    ELSE
    BEGIN
        SELECT ISNULL(DC.Id, 0) AS DefaultContactId,
               ISNULL(DC.ContactId, 0) AS ContactMasterId,
               ISNULL(EG.Id, 0) AS ActivityId,
               ISNULL(EG.EstablishmentGroupName, '') AS ActivityName,
               ISNULL(E.Id, 0) AS EstablishmentId,
               ISNULL(E.EstablishmentName, '') AS EstablishmentName,
               CASE
                   WHEN DC.IsGroup = 1 THEN
                   (
                       SELECT ContactGropName FROM dbo.ContactGroup WHERE Id = DC.ContactId
                   )
                   ELSE
                       ISNULL((STUFF(
                               (
                                   SELECT ',' + CD.Detail
                                   FROM dbo.ContactDetails AS CD
                                       INNER JOIN dbo.ContactQuestions AS CQ
                                           ON CQ.Id = CD.ContactQuestionId
                                   WHERE CD.ContactMasterId = DC.ContactId
                                         AND CQ.ContactId = GP.ContactId
                                         AND CQ.IsDeleted = 0
                                         AND CQ.IsDisplayInSummary = 1
                                   ORDER BY CQ.Position ASC
                                   FOR XML PATH('')
                               ),
                               1,
                               1,
                               ''
                                    )
                              ),
                              ''
                             )
               END AS ContactName
        FROM dbo.Establishment AS E
            INNER JOIN dbo.EstablishmentGroup AS EG
                ON EG.Id = E.EstablishmentGroupId
            INNER JOIN dbo.[Group] AS GP
                ON GP.Id = E.GroupId
                   AND GP.Id = EG.GroupId
            LEFT JOIN dbo.DefaultContact AS DC
                ON E.Id = DC.EstablishmentId
                   AND DC.AppUserId = @AppUserId
                   AND DC.IsDeleted = 0
            INNER JOIN dbo.AppUserEstablishment AS UE
                ON UE.EstablishmentId = E.Id
                   AND UE.IsDeleted = 0
                   AND UE.AppUserId = @AppUserId
        WHERE GP.Id = @GroupId
              AND EG.GroupId = @GroupId
              AND EG.EstablishmentGroupType = 'Sales'
              AND EG.IsDeleted = 0
        ORDER BY E.EstablishmentName;
    END;
END;
