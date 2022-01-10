-- =============================================
-- Author:		<Vasu Patel>
-- Create date: <30 May 2016>
-- Description:	<Best Weight by QuestionId>
-- Call: CalculateBestWeightForQuestionnaireByQuestionId
-- =============================================
CREATE PROC [dbo].[CalculateBestWeightForQuestionnaireByQuestionId]
    @QuestionId BIGINT ,
    @QuestionnaireType NVARCHAR(50)
AS
    BEGIN
        DECLARE @QuestionnaireId BIGINT ,
            @QuestionTypeId BIGINT;
        IF ( @QuestionnaireType = 'Questions' )
            BEGIN
                SELECT  @QuestionnaireId = QuestionnaireId ,
                        @QuestionTypeId = QuestionTypeId
                FROM    dbo.Questions
                WHERE   Id = @QuestionId;

                IF @QuestionTypeId IN ( 1, 2, 5, 6, 7, 14, 15, 18, 21 )
                    BEGIN
                        EXEC dbo.CalculateBestWeightForQuestionnaire @QuestionnaireId; -- bigint
                    END;
            END;
        ELSE
            BEGIN

                SELECT  @QuestionnaireId = SeenClientId ,
                        @QuestionTypeId = QuestionTypeId
                FROM    dbo.SeenClientQuestions
                WHERE   Id = @QuestionId;

                IF @QuestionTypeId IN ( 1, 2, 5, 6, 7, 14, 15, 18, 21 )
                    BEGIN
                        EXEC dbo.CalculateBestWeightForSeenClient @QuestionnaireId; -- bigint
                    END;
            END;
    END;