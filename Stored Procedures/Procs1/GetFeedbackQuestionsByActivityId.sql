-- =============================================
-- Author:			Sunil Vaghasiya
-- Create date:	20-Mar-2017
-- Description:	<Description,,GetQuestionsById>
-- Call SP    :		dbo.GetFeedbackQuestionsByActivityId 9565
-- =============================================
CREATE PROCEDURE [dbo].[GetFeedbackQuestionsByActivityId] @ActivityId BIGINT
AS
    BEGIN
        DECLARE @Url NVARCHAR(150) ,
            @QuestionnaireId BIGINT;
        SELECT  @Url = KeyValue + 'Questions/'
        FROM    dbo.AAAAConfigSettings
        WHERE   KeyName = 'DocViewerRootFolderPathCMS';

        SELECT  @QuestionnaireId = QuestionnaireId
        FROM    dbo.EstablishmentGroup
        WHERE   Id = @ActivityId;

        SELECT  dbo.[Questions].[Id] AS Id ,
                dbo.[Questions].[QuestionnaireId] AS QuestionnaireId ,
                dbo.[Questions].[Position] AS Position ,
                dbo.[Questions].[QuestionTypeId] AS QuestionTypeId ,
                dbo.[Questions].[QuestionTitle] AS QuestionTitle ,
                dbo.[Questions].[ShortName] AS ShortName ,
                dbo.[Questions].[IsActive] AS IsActive ,
                dbo.[Questions].[Required] AS Required ,
                dbo.[Questions].[IsDisplayInSummary] AS IsDisplayInSummary ,
                dbo.[Questions].[IsDisplayInDetail] AS IsDisplayInDetail ,
                dbo.[Questions].[MaxLength] AS MaxLength ,
                dbo.[Questions].[Hint] AS Hint ,
                dbo.[Questions].[EscalationRegex] AS EscalationRegex ,
                dbo.[Questions].[OptionsDisplayType] AS OptionsDisplayType ,
                dbo.[Questions].[SeenClientQuestionIdRef] AS SeenClientQuestionIdRef ,
                dbo.[Questions].[EscalationValue] AS EscalationValue ,
                dbo.[Questions].[DisplayInGraphs] AS DisplayInGraphs ,
                dbo.[Questions].[DisplayInTableView] AS DisplayInTableView ,
                dbo.[Questions].[MultipleRoutingValue] AS MultipleRoutingValue ,
                IsTitleBold ,
                IsTitleItalic ,
                IsTitleUnderline ,
                TitleTextColor ,
                TableGroupName ,
                ISNULL(CASE WHEN QuestionTypeId IN ( 5, 6, 18, 21 )
                            THEN ( SELECT   SUM([Weight])
                                   FROM     dbo.Options
                                   WHERE    QuestionId = dbo.[Questions].Id
                                            AND IsDeleted = 0
                                 )
                            ELSE [Weight]
                       END, 0) [Weight] ,
                WeightForYes ,
                WeightForNo ,
                Qt.QuestionTypeName ,
                Margin ,
                FontSize ,
                ISNULL(ImagePath, '') AS ImagePath ,
                IsCommentCompulsory AS IsCommentCompulsory ,
                IsAnonymous AS IsAnonymous ,
                dbo.[Questions].ContactQuestionIdRef ,
                dbo.[Questions].[IsDecimal] AS AllowDecimal ,
                ISNULL(dbo.[Questions].[IsRepetitive], 0) AS IsRepetitive
        FROM    dbo.[Questions]
                INNER JOIN dbo.QuestionType AS Qt ON Qt.Id = QuestionTypeId
        WHERE   dbo.[Questions].IsDeleted = 0
                AND [QuestionnaireId] = @QuestionnaireId 
				ORDER BY Position
    END;
