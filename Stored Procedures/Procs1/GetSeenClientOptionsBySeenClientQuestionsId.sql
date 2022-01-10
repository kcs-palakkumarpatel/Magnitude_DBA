-- =============================================
-- Author:		<Author,,GD>
-- Create date: <Create Date,, 28 May 2015>
-- Description:	<Description,,GetSeenClientOptionsById>
-- Call SP    :	GetSeenClientOptionsBySeenClientQuestionsId
-- =============================================
CREATE PROCEDURE dbo.GetSeenClientOptionsBySeenClientQuestionsId
    @SeenClientQuestionsId BIGINT
AS 
    BEGIN
        SELECT  dbo.[SeenClientOptions].[Id] AS Id ,
                dbo.[SeenClientOptions].[QuestionId] AS QuestionId ,
                dbo.[SeenClientQuestions].QuestionTitle ,
                dbo.[SeenClientOptions].[Position] AS Position ,
                dbo.[SeenClientOptions].[Name] AS Name ,
                dbo.[SeenClientOptions].[Value] AS Value ,
                dbo.[SeenClientOptions].[DefaultValue] AS DefaultValue ,
                dbo.[SeenClientOptions].[Weight],
				dbo.[SeenClientOptions].[Point] ,
                dbo.[SeenClientOptions].[QAEnd] AS QAEnd
        FROM    dbo.[SeenClientOptions]
                INNER JOIN dbo.[SeenClientQuestions] ON dbo.[SeenClientQuestions].Id = dbo.[SeenClientOptions].QuestionId
        WHERE   dbo.[SeenClientOptions].IsDeleted = 0
                AND [QuestionId] = @SeenClientQuestionsId
		ORDER BY Position
    END
