-- =============================================
-- Author:			Sunil Vaghasiya
-- Create date:	17-Apr-2017
-- Description:	<Description,,GetRepetitiveQuestionGroupListByQuestionnaireId>
-- Call SP    :		GetRepetitiveQuestionGroupListByQuestionnaireId 1037
-- =============================================
CREATE PROCEDURE dbo.GetRepetitiveQuestionGroupListByQuestionnaireId
    @QuestionnaireId BIGINT
AS
    BEGIN
        SELECT  QuestionsGroupNo ,
                QuestionsGroupName,
				ISNULL(IsRoutingOnGroup,0) AS IsRoutingOnGroup
        FROM    dbo.Questions
        WHERE   QuestionnaireId = @QuestionnaireId
                AND ISNULL(IsRepetitive, 0) = 1
				AND IsDeleted= 0
        GROUP BY QuestionsGroupNo ,
                QuestionsGroupName,
				ISNULL(IsRoutingOnGroup,0);
    END;
