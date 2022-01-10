-- =============================================  
-- Author:   Sunil Vaghasiya  
-- Create date: 17-Apr-2017  
-- Description: <Description,,GetQuestionsById>  
-- Call SP    :  dbo.GetGroupQuestionConditionsByQuestionnaireId 2241  
-- =============================================  
CREATE PROCEDURE [dbo].[GetGroupQuestionConditionsByQuestionnaireId]
    @QuestionnaireId BIGINT,
    @GroupId BIGINT
AS
BEGIN
    SELECT CL.QuestionId,
           CL.ConditionQuestionId,
           QQ.QuestionTitle AS [ConditionQuestionTitle],
           CL.OperationId,
           O.Symbol,
           QQ.QuestionTypeId,
           ISNULL(CL.AnswerId, '') AS AnswerId,
           ISNULL(OPT.[Name], '') AS [AnswerOptionText],
           ISNULL(CL.AnswerText, '') AS [AnswerText],
           CL.IsDeleted,
           CL.UpdatedBy,
           CL.CreatedBy,
           CL.IsAnd,
           CL.IsRoutingonGroup,
           CL.ConditionRepetitiveGroupId
    FROM ConditionLogic CL
        INNER JOIN Questions QQ
            ON CL.ConditionQuestionId = QQ.Id
               AND QQ.IsDeleted = 0
        INNER JOIN Operation O
            ON CL.OperationId = O.Id
               AND O.IsDeleted = 0
        LEFT JOIN Options OPT
            ON CL.AnswerId = OPT.Id
               AND OPT.IsDeleted = 0
    WHERE QQ.QuestionnaireId = @QuestionnaireId
	AND CL.ConditionRepetitiveGroupId = @GroupId
          AND CL.IsDeleted = 0;

END;
