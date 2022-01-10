-- =============================================
-- Author:			D2
-- Create date:	22-Nov-2017
-- Description:	
-- Call SP:			GetCaptureFormReferenceContactQuestionsDetail
-- =============================================
CREATE PROCEDURE [dbo].[GetCaptureFormReferenceContactQuestionsDetail]
    (
	@ActivityId BIGINT,
	@ContactGroupId BIGINT
	)
AS 
    BEGIN
        SELECT  Cm.Id AS ContactMasterId ,
                Cq.Id AS QuestionId ,
                Cq.QuestionTypeId ,
                QuestionTitle ,
                ISNULL(Cd.Detail, '') AS Detail,
				IsDisplayInDetail,
				IsDisplayInSummary AS DisplayInList
        FROM    dbo.ContactGroupRelation AS CGR
                INNER JOIN dbo.ContactMaster AS Cm ON CGR.ContactMasterId = Cm.Id
                LEFT JOIN dbo.ContactDetails AS Cd ON Cm.Id = Cd.ContactMasterId
                INNER JOIN dbo.ContactQuestions AS Cq ON Cd.ContactQuestionId = Cq.Id
        WHERE  CGR.IsDeleted = 0
                AND Cm.IsDeleted = 0
                AND Cq.IsDeleted = 0
				AND Cq.Id IN ( SELECT Data FROM dbo.Split((SELECT TOP 1 ContactQuestion FROM dbo.EstablishmentGroup WHERE Id=@ActivityId AND IsDeleted=0), ',' ))
                AND ContactGroupId = @ContactGroupId
        ORDER BY Cm.Id, Cq.Position
    END
