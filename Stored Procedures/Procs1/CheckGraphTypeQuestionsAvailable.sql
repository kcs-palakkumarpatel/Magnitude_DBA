-- =============================================
-- Author:			D#3
-- Create date:	15-Dec-2017
-- Description:	
-- Call SP:			dbo.CheckGraphTypeQuestionsAvailable
-- =============================================
CREATE PROCEDURE [dbo].[CheckGraphTypeQuestionsAvailable]
    (
      @AppUserId BIGINT ,
      @ActivityId BIGINT ,
      @IsOut BIT       
    )
AS
    BEGIN
        DECLARE @QuestionnaireId BIGINT = 0 ,
            @SeenClientId BIGINT = 0;

        SELECT TOP 1
                @QuestionnaireId = QuestionnaireId ,
                @SeenClientId = SeenClientId
        FROM    dbo.EstablishmentGroup AS Eg
                LEFT OUTER JOIN dbo.Establishment AS E ON Eg.Id = E.EstablishmentGroupId AND ISNULL(E.IsDeleted, 0) = 0 
                INNER JOIN dbo.Questionnaire AS Q ON Eg.QuestionnaireId = Q.Id
                LEFT OUTER JOIN dbo.SeenClient AS S ON Eg.SeenClientId = S.Id
        WHERE   Eg.Id = @ActivityId;

		IF @IsOut = 1
		BEGIN
			SELECT  ISNULL(Id, 0) AS QuestionId, QuestionTypeId, QuestionTitle ,DisplayInGraphs FROM dbo.SeenClientQuestions WHERE SeenClientId = @SeenClientId AND IsDeleted = 0 AND DisplayInGraphs = 1;
		END
		ELSE
		BEGIN
		    SELECT  ISNULL(Id, 0) AS QuestionId, QuestionTypeId, QuestionTitle ,DisplayInGraphs FROM dbo.Questions WHERE QuestionnaireId = @QuestionnaireId AND IsDeleted = 0 AND DisplayInGraphs = 1;
		END

    END;
