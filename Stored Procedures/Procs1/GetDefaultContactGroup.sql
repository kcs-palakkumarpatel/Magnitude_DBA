-- =============================================
-- Author:			D3
-- Create date: 13 Dec 2017
-- Description:	
--  Exec:				dbo.GetDefaultContactGroup 201, 449
-- =============================================
CREATE PROCEDURE dbo.GetDefaultContactGroup
    @GroupId BIGINT,
    @AppUserId BIGINT
AS
BEGIN
    DECLARE @ContactGroupId BIGINT = 0;

    SELECT TOP 1
        @ContactGroupId = ContactId
    FROM dbo.DefaultContact
    WHERE GroupId = @GroupId
          AND AppUserId = @AppUserId
          AND IsGroup = 1;

    SELECT ISNULL(DC.Id, 0) AS DefaultContactId,
           ISNULL(G.Id, 0) AS GroupId,
           ISNULL(G.GroupName, '') AS GroupName,
           ISNULL(DC.ContactId, 0) AS ContactMasterId,
           CASE
               WHEN @ContactGroupId > 0 THEN
               (
                   SELECT ContactGropName FROM dbo.ContactGroup WHERE Id = @ContactGroupId
               )
               ELSE
                   ISNULL((STUFF(
                           (
                               SELECT ',' + CD.Detail
                               FROM dbo.ContactDetails AS CD
                                   INNER JOIN dbo.ContactQuestions AS CQ
                                       ON CQ.Id = CD.ContactQuestionId
                               WHERE CD.ContactMasterId = DC.ContactId
                                     AND CQ.ContactId = G.ContactId
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
           ISNULL(
           (
               SELECT ISNULL(IsDefaultContact, 0) FROM dbo.AppUser WHERE Id = @AppUserId
           ),
           0
                 ) AS IsDefaultContact
    FROM dbo.[Group] AS G
        LEFT JOIN dbo.DefaultContact AS DC
            ON G.Id = DC.GroupId
               AND DC.AppUserId = @AppUserId
               AND DC.IsDeleted = 0
               AND DC.CreatedBy = @AppUserId
    WHERE G.Id = @GroupId
          AND G.IsDeleted = 0;
END;
