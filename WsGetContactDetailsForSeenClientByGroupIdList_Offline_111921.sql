
-- =============================================
-- Author:		<Abhishek Vyas>
-- Create date: <Create Date,12 OCT 2021>
-- Call SP:		WsGetContactDetailsForSeenClientByGroupIdList_Offline '1724, 1702'
-- =============================================
CREATE PROCEDURE [dbo].[WsGetContactDetailsForSeenClientByGroupIdList_Offline_111921] @ContactGroupId VARCHAR(MAX)
AS
BEGIN
    SET NOCOUNT ON;
    SELECT Cm.Id AS ContactMasterId,
           Cq.Id AS QuestionId,
           Cq.QuestionTypeId,
           Cq.QuestionTitle,
           CONVERT(NVARCHAR(500), ISNULL(Detail, '')) AS Detail,
           Cq.IsDisplayInDetail,
           Cq.IsDisplayInSummary AS DisplayInList,
		   CGR.ContactGroupId
    FROM dbo.ContactGroupRelation AS CGR WITH
        (NOLOCK)
        INNER JOIN dbo.ContactMaster AS Cm WITH
        (NOLOCK)
            ON CGR.ContactMasterId = Cm.Id
        INNER JOIN dbo.ContactDetails AS Cd WITH
        (NOLOCK)
            ON Cm.Id = Cd.ContactMasterId
        INNER JOIN dbo.ContactQuestions AS Cq WITH
        (NOLOCK)
            ON Cd.ContactQuestionId = Cq.Id
    WHERE Cd.IsDeleted = 0
          AND CGR.IsDeleted = 0
          AND Cm.IsDeleted = 0
          AND Cq.IsDeleted = 0
          AND CGR.ContactGroupId IN ((SELECT Data FROM Dbo.Split(@ContactGroupId,',')))
    ORDER BY Cm.Id;
END;
