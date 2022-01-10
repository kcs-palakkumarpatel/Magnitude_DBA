-- =============================================
-- Author:		<Author,,GD>
-- Create date: <Create Date,,29 May 2015>
-- Description:	<Description,,>
-- Call SP:		GetSeenClientOptionBySeenClientId 609
-- =============================================
CREATE PROCEDURE [dbo].[GetSeenClientOptionBySeenClientId]
 @SeenClientId BIGINT
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
				ORDER BY QuestionId, dbo.SeenClientOptions.Position
    END
