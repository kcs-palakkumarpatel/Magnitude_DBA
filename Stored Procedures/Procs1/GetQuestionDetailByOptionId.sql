-- =============================================
-- Author:		<Ankit,,GD>
-- Create date: <Create Date,,20 May 2019>
-- Description:	<Description,,>
-- Call SP:		GetQuestionDetailByOptionId 14320
-- =============================================
CREATE PROCEDURE dbo.GetQuestionDetailByOptionId @OptionId BIGINT
AS
BEGIN
    SET NOCOUNT ON;
    SELECT O.Id AS [OptionId],
           Q.Id AS [QuestionId],
           Q.QuestionTypeId,
           O.[Name] [Name],
           O.[Value] [Value]
    FROM dbo.Options O WITH (NOLOCK)
        INNER JOIN dbo.Questions Q WITH (NOLOCK)
            ON O.QuestionId = Q.Id
               AND Q.IsDeleted = 0
    WHERE O.Id = @OptionId
          AND O.IsDeleted = 0;
    SET NOCOUNT OFF;
END;
