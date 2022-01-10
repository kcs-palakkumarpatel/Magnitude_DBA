--EXEC dbo.WsGetContactGroupDetilsForSeenClientByIdOnChnageContact 8243,1827,1
CREATE PROCEDURE [dbo].[WsGetContactGroupDetilsForSeenClientByIdOnChnageContact]
    @EstablishmentGroupId BIGINT,
    @ContactGroupId BIGINT,
    @IsFromWeb BIT
AS
BEGIN
    SET NOCOUNT ON;
    SELECT -1 AS QuestionId,
           -1 AS QuestionTypeId,
           'Group Name' AS QuestionTitle,
           ContactGropName AS Detail,
           LastUsedOn,
           0 AS IsDisplayInList
    FROM dbo.ContactGroup WITH (NOLOCK)
    WHERE Id = @ContactGroupId
    UNION
    SELECT Cq.Id AS QuestionId,
           Cq.QuestionTypeId,
           QuestionTitle,
           CASE
               WHEN @IsFromWeb = 1 THEN
                   dbo.GetContactDetailsForGroupWeb(@ContactGroupId, Cq.Id)
               ELSE
                   dbo.GetContactDetailsForGroup(@ContactGroupId, Cq.Id)
           END AS Detail,
           NULL AS LastUsedOn,
           Cq.IsDisplayInSummary AS IsDisplayInList
    FROM dbo.ContactGroupRelation AS CGR WITH (NOLOCK)
        INNER JOIN dbo.ContactMaster AS Cm WITH (NOLOCK)
            ON CGR.ContactMasterId = Cm.Id
        INNER JOIN dbo.ContactDetails AS Cd WITH (NOLOCK)
            ON Cm.Id = Cd.ContactMasterId
               AND (
                       @EstablishmentGroupId = 0
                       OR Cd.ContactQuestionId IN (
                                                      SELECT ColumnValue AS ContactMasterId
                                                      FROM dbo.ConvertStringToTable(
                                                           (
                                                               SELECT ContactQuestion
                                                               FROM dbo.EstablishmentGroup WITH (NOLOCK)
                                                               WHERE Id = @EstablishmentGroupId
                                                           ),
                                                           ','
                                                                                   )
                                                  )
                   )
        INNER JOIN dbo.ContactQuestions AS Cq WITH (NOLOCK)
            ON Cd.ContactQuestionId = Cq.Id
    WHERE Cd.IsDeleted = 0
          AND CGR.IsDeleted = 0
          AND Cm.IsDeleted = 0
          AND Cq.IsDeleted = 0
		  AND IsDisplayInSummary = 1
    --AND ContactGroupId = @ContactGroupId
    GROUP BY Cq.Id,
             Cq.QuestionTypeId,
             QuestionTitle,
             Cq.IsDisplayInSummary;
    SET NOCOUNT OFF;
END;
