-- =============================================
-- Author:		<Author,,GD>
-- Create date: <Create Date,, 30 May 2015>
-- Description:	<Description,,GetOptionsById>
-- Call SP    :	GetOptionsByQuestionsIdForAutocomplate 19136
-- =============================================
CREATE PROCEDURE  [dbo].[GetOptionsByQuestionsIdForAutocomplate]
    @QuestionsId BIGINT ,
    @Type NVARCHAR(10)
AS
    BEGIN
        IF ( @Type = 'Feedback' )
            BEGIN
                SELECT  CONVERT(VARCHAR(25), dbo.[Options].[QuestionId]) AS QuestionId ,
                        dbo.[Options].[Value] AS Value
                FROM    dbo.[Options]
                        INNER JOIN dbo.[Questions] ON dbo.[Questions].Id = dbo.[Options].QuestionId
                WHERE   dbo.[Options].IsDeleted = 0
                        AND [QuestionId] = @QuestionsId
                UNION ALL
                SELECT TOP 100
                        @QuestionsId AS QuestionId ,
                        '' AS Value
                FROM    dbo.Questions;
            END;
        ELSE
            BEGIN
                SELECT  CONVERT(VARCHAR(25), dbo.[SeenClientOptions].[QuestionId]) AS QuestionId ,
                        dbo.[SeenClientOptions].[Value] AS Value 
                FROM    dbo.[SeenClientOptions]
                        INNER JOIN dbo.[SeenClientQuestions] ON dbo.[SeenClientQuestions].Id = dbo.[SeenClientOptions].QuestionId
                WHERE   dbo.[SeenClientOptions].IsDeleted = 0
                        AND [QuestionId] = @QuestionsId
                UNION ALL
                SELECT TOP 100
                        @QuestionsId AS QuestionId ,
                        '' AS Value 
                FROM    dbo.[SeenClientQuestions];
            END;
    END;
