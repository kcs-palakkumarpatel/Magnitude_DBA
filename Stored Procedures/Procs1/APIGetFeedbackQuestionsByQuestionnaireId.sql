-- =============================================
-- Author:			Developer D3
-- Create date:	05-June-2017
-- Description:	Get Feedback Questions List for Web API Using QuestionnaireId
-- Call:					dbo.APIGetFeedbackQuestionsByQuestionnaireId 759
-- =============================================
CREATE PROCEDURE [dbo].[APIGetFeedbackQuestionsByQuestionnaireId]
    (
      @QuestionnaireId VARCHAR(MAX) = ''
	)
AS
    BEGIN
        SET NOCOUNT OFF;

        SELECT  
		QuestionnaireId AS FeedbackId,
		Q.Id AS QuestionId ,
                QuestionTypeId ,
                ISNULL(QuestionTitle, '') AS QuestionTitle ,
                ISNULL([Required], 0) AS QuestionRequired ,
                '' AS Answer
        FROM    dbo.Questions AS Q
        WHERE   Q.IsActive = 1
                AND Q.IsDeleted = 0
				AND Q.QuestionTypeId NOT IN (16, 23)
                AND QuestionnaireId IN ( SELECT Data FROM dbo.Split(@QuestionnaireId, ','))
        ORDER BY Q.Position;

    END;
