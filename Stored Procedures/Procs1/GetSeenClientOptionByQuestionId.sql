-- =============================================
-- Author:		<Author,,BHAVIk PATEL>
-- Create date: <Create Date,,19-01-21>
-- Description:	<Description,,>
-- Call SP:		[GetSeenClientOptionByQuestionId] 609,84692
-- =============================================
CREATE PROCEDURE [dbo].[GetSeenClientOptionByQuestionId]
 @SeenClientId BIGINT,
 @QuestionId BIGINT
AS 
    BEGIN
        SELECT  dbo.[SeenClientOptions].[Id] AS Id ,
                dbo.[SeenClientOptions].[QuestionId] AS QuestionId ,
                dbo.[SeenClientQuestions].QuestionTitle ,
                dbo.[SeenClientOptions].[Position] AS Position ,
                dbo.[SeenClientOptions].[Name] AS Name ,
                dbo.[SeenClientOptions].[Value] AS Value ,
                dbo.[SeenClientOptions].[DefaultValue] AS DefaultValue ,
                dbo.[SeenClientOptions].[QAEnd] AS QAEnd ,
                dbo.SeenClientOptions.[Weight],
				Point
        FROM    dbo.[SeenClientOptions]
                INNER JOIN dbo.[SeenClientQuestions] ON dbo.[SeenClientQuestions].Id = dbo.[SeenClientOptions].QuestionId 
                INNER JOIN dbo.SeenClient AS S ON S.Id = dbo.[SeenClientQuestions].SeenClientId
        WHERE   dbo.[SeenClientOptions].IsDeleted = 0
                AND SeenClientId = @SeenClientId
				AND dbo.SeenClientQuestions.IsDeleted = 0
				AND dbo.[SeenClientQuestions].QuestionTypeId !=26
				AND  dbo.[SeenClientQuestions].Id  = @QuestionId
				ORDER BY QuestionId, dbo.SeenClientOptions.Position
    END
