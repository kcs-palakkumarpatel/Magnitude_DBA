-- =============================================
-- Author:			Developer D3
-- Create date:	10-11-2016
-- Description:	Get Contact Answers Data from for Web API Using MerchantKey(GroupId)
-- Call:					dbo.APIGetCaptureAnswersDataByAnswerMasterId '170,180'
-- =============================================
CREATE PROCEDURE dbo.APIGetCaptureAnswersDataByAnswerMasterId
    (
      @AnswerMasterId NVARCHAR(2000) = NULL
	)
AS
    BEGIN
        SET NOCOUNT OFF;

    SELECT ISNULL( SCA.SeenClientAnswerMasterId , 0)AS AnswerMasterId,
ISNULL(SCA.Id , 0) AS AnswerId,
ISNULL(SCA.QuestionId , 0) AS QuestionId,
ISNULL(QT.QuestionTypeName, '') AS QuestionType,
ISNULL(SCQ.QuestionTitle, '') AS Question,
ISNULL(SCA.Detail, '') AS Answer,
ISNULL(SCA.[Weight], 0) AS [Weight],
ISNULL(SCA.QPI, 0) AS QPI
 FROM dbo.SeenClientAnswers AS SCA
LEFT JOIN dbo.SeenClientQuestions AS SCQ ON SCQ.Id = SCA.QuestionId
LEFT JOIN dbo.QuestionType AS QT ON QT.Id = SCA.QuestionTypeId
WHERE SCA.SeenClientAnswerMasterId IN ( SELECT Data FROM dbo.Split(@AnswerMasterId, ','))

    END;