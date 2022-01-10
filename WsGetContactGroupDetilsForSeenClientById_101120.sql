/*
EXEC dbo.WsGetContactGroupDetilsForSeenClientById_101120 8243,1827,1

Drop procedure WsGetContactGroupDetilsForSeenClientById_101120
*/

CREATE PROCEDURE [dbo].[WsGetContactGroupDetilsForSeenClientById_101120]
	@EstablishmentGroupId BIGINT,
    @ContactGroupId BIGINT,
    @IsFromWeb BIT
AS
BEGIN
	SELECT  -1 AS QuestionId ,
		-1 AS QuestionTypeId ,
        'Group Name' AS QuestionTitle ,
        ContactGropName AS Detail,
		LastUsedOn
	FROM dbo.ContactGroup
	WHERE Id = @ContactGroupId
	UNION
    SELECT  Cq.Id AS QuestionId ,
		Cq.QuestionTypeId ,
        QuestionTitle ,
        CASE WHEN @IsFromWeb = 1 THEN dbo.GetContactDetailsForGroupWeb(@ContactGroupId, Cq.Id)
			ELSE dbo.GetContactDetailsForGroup(@ContactGroupId, Cq.Id)
        END AS Detail,
		NULL as LastUsedOn
	FROM  dbo.ContactGroupRelation AS CGR
    INNER JOIN dbo.ContactMaster AS Cm ON CGR.ContactMasterId = Cm.Id
    INNER JOIN dbo.ContactDetails AS Cd ON Cm.Id = Cd.ContactMasterId AND (@EstablishmentGroupId = 0 OR Cd.ContactQuestionId IN (SELECT ColumnValue AS ContactMasterId FROM dbo.ConvertStringToTable(
		(SELECT ContactQuestion FROM dbo.EstablishmentGroup WHERE Id=@EstablishmentGroupId),',')))
    INNER JOIN dbo.ContactQuestions AS Cq ON Cd.ContactQuestionId = Cq.Id
    WHERE Cd.IsDeleted = 0
	AND CGR.IsDeleted = 0
    AND Cm.IsDeleted = 0
    AND Cq.IsDeleted = 0
    AND IsDisplayInSummary = 1
    AND ContactGroupId = @ContactGroupId
    GROUP BY Cq.Id ,Cq.QuestionTypeId ,QuestionTitle
END