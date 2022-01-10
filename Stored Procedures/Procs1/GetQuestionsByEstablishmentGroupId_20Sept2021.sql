-- =============================================
-- Author:			Sunil Vaghasiya
-- Create date:	17-Apr-2017
-- Description:	<Description,,GetQuestionsById>
-- Call SP    :		dbo.GetQuestionsByEstablishmentGroupId 7
-- =============================================
CREATE PROCEDURE [dbo].[GetQuestionsByEstablishmentGroupId_20Sept2021] @EstablishmentGroupId BIGINT
AS
BEGIN
    DECLARE @Url NVARCHAR(150);
    SELECT @Url = KeyValue + 'Questions/'
    FROM dbo.AAAAConfigSettings
    WHERE KeyName = 'DocViewerRootFolderPathCMS';

    SELECT Questions.Id AS Id,
           Questions.QuestionnaireId AS QuestionnaireId,
           Questions.Position AS Position,
           QuestionTypeId AS QuestionTypeId,
           QuestionTitle AS QuestionTitle,
           ShortName AS ShortName,
           IsActive AS IsActive,
           Required AS Required,
           IsDisplayInSummary AS IsDisplayInSummary,
           IsDisplayInDetail AS IsDisplayInDetail,
           MaxLength AS MaxLength,
           Hint AS Hint,
           EscalationRegex AS EscalationRegex,
           OptionsDisplayType AS OptionsDisplayType,
           SeenClientQuestionIdRef AS SeenClientQuestionIdRef,
           EscalationValue AS EscalationValue,
           DisplayInGraphs AS DisplayInGraphs,
           DisplayInTableView AS DisplayInTableView,
           MultipleRoutingValue AS MultipleRoutingValue,
           IsTitleBold,
           IsTitleItalic,
           IsTitleUnderline,
           TitleTextColor,
           TableGroupName,
           ISNULL(   CASE
                         WHEN EXISTS (SELECT QuestionTypeId from dbo.Questions where  QuestionTypeId = 5 OR QuestionTypeId = 6 OR QuestionTypeId = 18 OR QuestionTypeId = 21 ) THEN
                         (
                             SELECT SUM([Weight])
                             FROM dbo.Options
                             WHERE QuestionId = dbo.[Questions].Id
                                   AND IsDeleted = 0
                         )
                         ELSE
                             [Weight]
                     END,
                     0
                 ) [Weight],
           WeightForYes,
           WeightForNo,
           Qt.QuestionTypeName,
           Margin,
           FontSize,
           ISNULL(ImagePath, '') AS ImagePath,
           IsCommentCompulsory AS IsCommentCompulsory,
           IsAnonymous AS IsAnonymous,
           ContactQuestionIdRef,
           IsDecimal AS AllowDecimal,
           IsRepetitive AS IsRepetitive,
           QuestionsGroupNo AS RepetitiveQuestionsGroupNo,
           QuestionsGroupName AS RepetitiveQuestionsGroupName,
           IsSignature AS IsSignature,
           ImageHeight AS ImageHeight,
           ImageWidth AS ImageWidth,
           ImageAlign AS ImageAlign,
           CalculationOptions AS CalculationOptions,
           SummaryOption AS SummaryOption
    FROM dbo.Questions
        INNER JOIN dbo.QuestionType AS Qt
            ON Qt.Id = QuestionTypeId
        INNER JOIN dbo.EstablishmentGroup EG
            ON EG.QuestionnaireId = dbo.Questions.QuestionnaireId
    WHERE Questions.IsDeleted = 0
          AND EG.Id = @EstablishmentGroupId;
END;
