-- =============================================
-- Author:			Developer D3
-- Create date:	10-11-2016
-- Description:	Get Feedback Answers Data from for Web API Using MerchantKey(GroupId)
-- Call:					dbo.APIGetFeedbackAnswersDataByAnswerMasterId 170
-- =============================================
CREATE PROCEDURE [dbo].[APIGetFeedbackAnswersDataByAnswerMasterId]
    (
      @AnswerMasterId NVARCHAR(2000) = NULL
	)
AS
    BEGIN
        SET NOCOUNT OFF;

        SELECT  ISNULL(SCA.AnswerMasterId, 0) AS ReportId ,
                ISNULL(SCA.Id, 0) AS AnswerId ,
                ISNULL(SCA.QuestionId, 0) AS QuestionId ,
                ISNULL(QT.QuestionTypeName, '') AS QuestionType ,
                ISNULL(SCQ.QuestionTitle, '') AS Question ,
                ISNULL(SCA.Detail, '') AS Answer ,
                ISNULL(SCA.[Weight], 0) AS [Weight] ,
                ISNULL(SCA.QPI, 0) AS QPI
        FROM    dbo.Answers AS SCA
                LEFT JOIN dbo.Questions AS SCQ ON SCQ.Id = SCA.QuestionId
                LEFT JOIN dbo.QuestionType AS QT ON QT.Id = SCA.QuestionTypeId
        WHERE   SCA.AnswerMasterId IN ( SELECT Data FROM dbo.Split(@AnswerMasterId, ','))

    END;
