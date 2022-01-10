-- =============================================
-- Author:		<Author,,ADMIN>
-- Create date: <Create Date,, 26 May 2015>
-- Description:	<Description,,DeleteQuestions>
-- Call SP    :	ExistQuestionsArithmeticReference 60878

-- =============================================
CREATE PROCEDURE [dbo].[ExistQuestionsArithmeticReference] @QuestionId NVARCHAR(200)
AS
BEGIN
    SELECT Formula AS CalculationFormula
    FROM dbo.QuestionCalculationItem
    WHERE IsCapture = 0
          AND IsDeleted = 0
          AND (
                  Formula LIKE '% ' + @QuestionId + ' %'
                  OR Formula LIKE '% Sum_' + @QuestionId + ' %'
                  OR Formula LIKE '% Sub_' + @QuestionId + ' %'
              );
END;
