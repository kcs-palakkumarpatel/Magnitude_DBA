-- =============================================
-- Author:		<Ankit,,GD>
-- Create date: <Create Date,, 17 Mar 2015>
-- Description:	<Description,,InsertOrUpdateSeenClient>
-- Call SP    :	InsertOrUpdateSeenClient
-- =============================================
CREATE PROCEDURE dbo.InsertOrUpdateConditionLogic @ConditionLogicTableType ConditionLogicTableType READONLY
AS
BEGIN
    INSERT INTO dbo.ConditionLogic
    (
        QuestionId,
        ConditionQuestionId,
        OperationId,
        AnswerId,
        AnswerText,
        IsAnd,
        CreatedOn,
        CreatedBy
    )
    SELECT CLT.QuestionId,
           CLT.ConditionQuestionId,
           CLT.OperationId,
           CASE CLT.AnswerId
               WHEN 0 THEN
                   NULL
               ELSE
                   CLT.AnswerId
           END AS [AnswerId],
           CLT.AnswerText,
           CLT.IsAnd,
           GETUTCDATE(),
           CLT.CreatedBy
    FROM @ConditionLogicTableType CLT
        LEFT JOIN dbo.ConditionLogic CL
            ON CLT.QuestionId = CL.QuestionId
               AND CL.ConditionQuestionId = CLT.ConditionQuestionId
               AND CLT.AnswerText = CL.AnswerText
               AND CL.IsDeleted = 0
			   AND CLT.OperationId = CL.OperationId
    WHERE CLT.IsDeleted = 0
          AND CL.Id IS NULL;


    ;
    WITH CLT
    AS (SELECT ConditionQuestionId,
               DeletedBy,
               IsDeleted,
               QuestionId,
               AnswerText,
               OperationId
        FROM @ConditionLogicTableType
        WHERE IsDeleted = 1
       )
    UPDATE ConditionLogic
    SET DeletedOn = GETUTCDATE(),
        DeletedBy = CLT.DeletedBy,
        IsDeleted = CLT.IsDeleted
    FROM ConditionLogic AS CL
        INNER JOIN CLT
            ON CL.ConditionQuestionId = CLT.ConditionQuestionId
               AND CLT.AnswerText = CL.AnswerText
               AND CL.OperationId = CLT.OperationId
			   AND CL.QuestionId = CLT.QuestionId;

END;
