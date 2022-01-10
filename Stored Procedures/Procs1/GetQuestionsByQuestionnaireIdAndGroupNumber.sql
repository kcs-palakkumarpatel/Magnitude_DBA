-- =============================================
-- Author:			MIttal Patel
-- Create date:	27-Feb-2020
-- Description:	<Description,,GetQuestionsByQuestionnaireIdAndGroupNumber>
-- Call SP    :		dbo.GetQuestionsByQuestionnaireIdAndGroupNumber 2241,1
-- =============================================
CREATE PROCEDURE [dbo].[GetQuestionsByQuestionnaireIdAndGroupNumber]
    @QuestionnaireId BIGINT,
    @GroupId BIGINT
AS
BEGIN
    DECLARE @Url NVARCHAR(150);
    SELECT @Url = KeyValue + 'Questions/'
    FROM dbo.AAAAConfigSettings
    WHERE KeyName = 'DocViewerRootFolderPathCMS';

    DECLARE @Position INT = 0;
    SELECT @Position = Position
    FROM dbo.Questions
    WHERE QuestionnaireId = @QuestionnaireId
          AND QuestionsGroupNo = @GroupId
		  AND IsDeleted = 0;

    SELECT Questions.Id AS Id,
           QuestionnaireId AS QuestionnaireId,
           Questions.Position AS Position,
           ISNULL(Questions.ChildPosition, 0) AS ChildPosition,
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
                         WHEN QuestionTypeId IN ( 5, 6, 18, 21 ) THEN
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
           SummaryOption AS SummaryOption,
           ISNULL(IsDefaultDisplay, 0) AS IsDefaultDisplay,
           ISNULL(IsRoutingOnGroup, 0) AS IsRoutingOnGroup
    FROM dbo.Questions
        INNER JOIN dbo.QuestionType AS Qt
            ON Qt.Id = QuestionTypeId
    WHERE Questions.IsDeleted = 0
          AND [QuestionnaireId] = @QuestionnaireId
          AND Questions.Position < @Position
          AND IsRepetitive = 0
    ORDER BY Questions.Position,
             ChildPosition;
END;
