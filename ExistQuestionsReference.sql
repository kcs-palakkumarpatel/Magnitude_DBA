-- =============================================
-- Author:		<Author,,ADMIN>
-- Create date: <Create Date,, 26 May 2015>
-- Description:	<Description,,DeleteQuestions>
-- Call SP    :	ExistQuestionsReference 8754
-- =============================================
CREATE PROCEDURE [dbo].[ExistQuestionsReference]
    @QuestionId BIGINT
AS
    BEGIN
      IF EXISTS (SELECT Id FROM  dbo.ConditionLogic WHERE ConditionQuestionId = @QuestionId AND IsDeleted = 0)
	  BEGIN
	     SELECT Id FROM  dbo.ConditionLogic WHERE ConditionQuestionId = @QuestionId AND IsDeleted = 0 
	  END
	  ELSE
	  BEGIN
	      SELECT Id FROM  dbo.RoutingLogic WHERE QueueQuestionId = @QuestionId AND IsDeleted = 0 
	  END
    END;
