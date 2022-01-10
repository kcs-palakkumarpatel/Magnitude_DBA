-- =============================================  
-- Author:   Sunil Vaghasiya  
-- Create date: 17-Apr-2017  
-- Description: <Description,,GetQuestionsById>  
-- Call SP    :  dbo.GetQuestionConditionsByQuestionnaireId 12891  
-- =============================================  
CREATE PROCEDURE [dbo].[GetQuestionConditionsByQuestionnaireId] @QuestionnaireId BIGINT
AS
BEGIN
    SELECT CL.QuestionId,
           CL.ConditionQuestionId,
           QQ.QuestionTitle AS [ConditionQuestionTitle],
           CL.OperationId,
           O.Symbol,
           Q.QuestionTypeId,
           ISNULL(CL.AnswerId, '') AS AnswerId,
           ISNULL(OPT.[Name], '') AS [AnswerOptionText],
           ISNULL(CL.AnswerText,'') as [AnswerText],
		   Cl.IsDeleted,
		   Cl.UpdatedBy,
		   Cl.CreatedBy,
		   Cl.IsAnd
    FROM ConditionLogic CL
        INNER JOIN Questions Q
            ON CL.QuestionId = Q.Id
               AND Q.IsDeleted = 0
        INNER JOIN Questions QQ
            ON CL.ConditionQuestionId = QQ.Id
               AND QQ.IsDeleted = 0
        INNER JOIN Operation O
            ON CL.OperationId = O.Id
               AND O.IsDeleted = 0
        LEFT JOIN Options OPT
            ON CL.AnswerId = OPT.Id
               AND OPT.IsDeleted = 0
    WHERE Q.QuestionnaireId = @QuestionnaireId
          AND CL.IsDeleted = 0;

END;
