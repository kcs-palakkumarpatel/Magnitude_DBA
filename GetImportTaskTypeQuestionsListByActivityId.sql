-- =============================================  
-- Author:			Sunil Vaghasiya
-- Create date:	22-Sep-2017
-- Description:	Get Contacts Questions Details For Mass Upload.
-- Call SP:			dbo.GetImportTaskTypeQuestionsListByActivityId 7345
-- =============================================
CREATE PROCEDURE dbo.GetImportTaskTypeQuestionsListByActivityId @ActivityId INT
AS
BEGIN
    SELECT SCQ.Id AS QuestionId,
          SCQ.QuestionTypeId,
          SCQ.QuestionTitle,
          SCQ.ShortName,
          SCQ.[Required],
          SCQ.IsDisplayInSummary,
          SCQ.IsDisplayInDetail,
          SCQ.[MaxLength],
          SCQ.IsDecimal,
          SCQ.IsCommentCompulsory,
          SCQ.Position,
		  SCQ.SeenClientId,
		  SCQ.IsRepetitive
    FROM dbo.SeenClientQuestions SCQ
        INNER JOIN dbo.EstablishmentGroup EG
            ON EG.SeenClientId = SCQ.SeenClientId
    WHERE EG.Id = @ActivityId
          AND ISNULL(SCQ.IsDeleted, 0) = 0
		  AND SCQ.IsActive = 1
          AND SCQ.QuestionTypeId NOT IN ( 16, 17, 23, 25 )
    ORDER BY Position ASC;

END;
