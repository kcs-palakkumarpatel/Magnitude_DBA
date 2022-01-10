-- =============================================
-- Author:			Sunil Vaghasiya
-- Create date:	10-May-2017
-- Description:	<Description,,GetCaptureQuestionList>
-- Call SP    :		GetCaptureQuestionList 3
-- =============================================
CREATE PROCEDURE [dbo].[GetCaptureQuestionList] @SeenClientId BIGINT
AS
    BEGIN
        DECLARE @Url NVARCHAR(150);
        SELECT  @Url = KeyValue + 'SeenClientQuestions/'
        FROM    dbo.AAAAConfigSettings
        WHERE   KeyName = 'DocViewerRootFolderPathCMS';

        SELECT  dbo.[SeenClientQuestions].[Id] AS Id ,
                dbo.[SeenClientQuestions].[SeenClientId] AS SeenClientId ,
                dbo.[SeenClientQuestions].[Position] AS Position ,
                dbo.[SeenClientQuestions].[QuestionTypeId] AS QuestionTypeId ,
                dbo.[SeenClientQuestions].[QuestionTitle] AS QuestionTitle ,
                dbo.[SeenClientQuestions].[ShortName] AS ShortName ,
                dbo.[SeenClientQuestions].[Required] AS Required ,
                dbo.[SeenClientQuestions].[IsDisplayInSummary] AS IsDisplayInSummary ,
				dbo.[SeenClientQuestions].[IsRepetitive] AS IsRepetitive ,
				dbo.[SeenClientQuestions].QuestionsGroupNo AS RepetitiveQuestionsGroupNo,
				dbo.[SeenClientQuestions].QuestionsGroupName AS RepetitiveQuestionsGroupName,
                dbo.[SeenClientQuestions].[IsDisplayInDetail] AS IsDisplayInDetail ,
                dbo.[SeenClientQuestions].[MaxLength] AS MaxLength ,
                dbo.[SeenClientQuestions].[Hint] AS Hint ,
                dbo.[SeenClientQuestions].[EscalationRegex] AS EscalationRegex ,
                dbo.[SeenClientQuestions].[KeyName] AS KeyName ,
                dbo.[SeenClientQuestions].[GroupId] AS GroupId ,
                dbo.[SeenClientQuestions].[OptionsDisplayType] AS OptionsDisplayType ,
                dbo.[SeenClientQuestions].IsTitleBold ,
                dbo.[SeenClientQuestions].IsTitleItalic ,
                dbo.[SeenClientQuestions].IsTitleUnderline ,
                dbo.[SeenClientQuestions].TitleTextColor ,
                dbo.[SeenClientQuestions].ContactQuestionId ,
                dbo.[SeenClientQuestions].TableGroupName ,
                dbo.[SeenClientQuestions].[EscalationValue] AS EscalationValue ,
                dbo.[SeenClientQuestions].[DisplayInGraphs] AS DisplayInGraphs ,
                dbo.[SeenClientQuestions].[DisplayInTableView] AS DisplayInTableView ,
                ISNULL(CASE WHEN QuestionTypeId IN ( 5, 6, 18, 21 )
                            THEN ( SELECT   SUM([Weight])
                                   FROM     dbo.SeenClientOptions
                                   WHERE    QuestionId = dbo.[SeenClientQuestions].Id
                                            AND IsDeleted = 0
                                 )
                            ELSE [Weight]
                       END, 0) [Weight] ,
                WeightForYes ,
                WeightForNo ,
                Qt.QuestionTypeName ,
                dbo.[SeenClientQuestions].Margin ,
                dbo.[SeenClientQuestions].FontSize ,
                ISNULL(( SELECT COUNT(1)
                         FROM   Questions
                         WHERE  SeenClientQuestionIdRef = SeenClientQuestions.Id
                                AND IsDeleted = 0
                       ), 0) AS ReferenceId ,
                ISNULL(ImagePath, '') AS ImagePath ,
                IsActive,
				IsCommentCompulsory AS IsCommentCompulsory,
				IsDecimal AS AllowDecimal
        FROM    dbo.[SeenClientQuestions]
                INNER JOIN dbo.[SeenClient] ON dbo.[SeenClient].Id = dbo.[SeenClientQuestions].SeenClientId
                INNER JOIN dbo.QuestionType AS Qt ON Qt.Id = QuestionTypeId
        WHERE   dbo.[SeenClientQuestions].IsDeleted = 0
                AND [SeenClientId] = @SeenClientId
        ORDER BY Position;
    END;
