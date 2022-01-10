
-- =============================================
-- Author:		<Author,,GD>
-- Create date: <Create Date,,20 Jun 2015>
-- Description:	<Description,,>
-- Call SP:		WSGetSeenClientOptionsBySeenClientId 609
-- =============================================
CREATE PROCEDURE [dbo].[WSGetSeenClientOptionsBySeenClientId_111921] @SeenClientId BIGINT
AS
    BEGIN
        SELECT  O.Id AS OptionId ,
                RTRIM(LTRIM(O.Name)) AS OptionName ,
                O.DefaultValue AS IsDefaultValue,
                Q.Id AS QuestionId,
                RTRIM(LTRIM(O.Value)) AS OptionValue,
				ISNULL(O.IsHTTPHeader,0) AS IsHTTPHeader,
		        ISNULL(O.ReferenceQuestionId,0) AS ReferenceQuestionId,
		        ISNULL(O.FromRef,0) AS FromRef
        FROM    dbo.SeenClientOptions AS O
                INNER JOIN dbo.SeenClientQuestions AS Q ON O.QuestionId = Q.Id
        WHERE   Q.SeenClientId = @SeenClientId
                AND O.IsDeleted = 0
                AND Q.IsDeleted = 0
				AND Q.QuestionTypeId !=26
        ORDER BY Q.Id ,
                O.Position;      
    END;
