-- =============================================
-- Author:			Sunil Vaghasiya
-- Create date:	10-May-2017
-- Description:	<Description,,GetSeenClientQuestionsById>
-- Call SP    :		GetSeenClientQuestionsBySeenClientId 609
-- =============================================
CREATE PROCEDURE dbo.GetSeenClientQuestionsBySeenClientId @SeenClientId BIGINT
AS
BEGIN
    DECLARE @Url NVARCHAR(150);

    SELECT @Url = KeyValue + N'SeenClientQuestions/'
    FROM dbo.AAAAConfigSettings
    WHERE KeyName = 'DocViewerRootFolderPathCMS';

    DECLARE @DefaultOptions TABLE
    (
        Id INT,
        QuestionTypeId INT
    );

    SELECT dbo.[SeenClientQuestions].[Id] AS Id,
           dbo.[SeenClientQuestions].[SeenClientId] AS SeenClientId,
           dbo.[SeenClientQuestions].[Position] AS Position,
           ISNULL(dbo.SeenClientQuestions.ChildPosition, 0) AS ChildPosition,
           dbo.[SeenClientQuestions].[QuestionTypeId] AS QuestionTypeId,
           dbo.[SeenClientQuestions].[QuestionTitle] AS QuestionTitle,
           dbo.[SeenClientQuestions].[ShortName] AS ShortName,
           dbo.[SeenClientQuestions].[Required] AS Required,
           dbo.[SeenClientQuestions].[IsDisplayInSummary] AS IsDisplayInSummary,
           dbo.[SeenClientQuestions].[IsRepetitive] AS IsRepetitive,
           dbo.[SeenClientQuestions].QuestionsGroupNo AS RepetitiveQuestionsGroupNo,
           dbo.[SeenClientQuestions].QuestionsGroupName AS RepetitiveQuestionsGroupName,
           dbo.[SeenClientQuestions].[IsDisplayInDetail] AS IsDisplayInDetail,
           dbo.[SeenClientQuestions].[MaxLength] AS MaxLength,
           dbo.[SeenClientQuestions].[Hint] AS Hint,
           dbo.[SeenClientQuestions].[EscalationRegex] AS EscalationRegex,
           dbo.[SeenClientQuestions].[KeyName] AS KeyName,
           dbo.[SeenClientQuestions].[GroupId] AS GroupId,
           dbo.[SeenClientQuestions].[OptionsDisplayType] AS OptionsDisplayType,
           dbo.[SeenClientQuestions].IsTitleBold,
           dbo.[SeenClientQuestions].IsTitleItalic,
           dbo.[SeenClientQuestions].IsTitleUnderline,
           dbo.[SeenClientQuestions].TitleTextColor,
           dbo.[SeenClientQuestions].ContactQuestionId,
           dbo.[SeenClientQuestions].TableGroupName,
           dbo.[SeenClientQuestions].[EscalationValue] AS EscalationValue,
           dbo.[SeenClientQuestions].[DisplayInGraphs] AS DisplayInGraphs,
           dbo.[SeenClientQuestions].[DisplayInTableView] AS DisplayInTableView,
           ISNULL(   CASE
                         WHEN QuestionTypeId IN ( 5, 6, 18, 21 ) THEN
                         (
                             SELECT SUM([Weight])
                             FROM dbo.SeenClientOptions
                             WHERE QuestionId = dbo.[SeenClientQuestions].Id
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
           dbo.[SeenClientQuestions].Margin,
           dbo.[SeenClientQuestions].FontSize,
           ISNULL(
           (
               SELECT COUNT(1)
               FROM Questions
               WHERE SeenClientQuestionIdRef = SeenClientQuestions.Id
                     AND IsDeleted = 0
           ),
           0
                 ) AS ReferenceId,
           ISNULL(ImagePath, '') AS ImagePath,
           IsActive,
           IsCommentCompulsory AS IsCommentCompulsory,
           IsDecimal AS AllowDecimal,
           IsSignature AS IsSignature,
           dbo.[SeenClientQuestions].ImageHeight AS ImageHeight,
           dbo.[SeenClientQuestions].ImageWidth AS ImageWidth,
           dbo.[SeenClientQuestions].ImageAlign AS ImageAlign,
           dbo.[SeenClientQuestions].CalculationOptions AS CalculationOptions,
           dbo.[SeenClientQuestions].SummaryOption AS SummaryOption,
           ISNULL(dbo.[SeenClientQuestions].IsValidateUsingQR, 0) AS IsValidateUsingQR,
           ISNULL(TenderQuestionType, 0) AS TenderQuestionType,
           ISNULL(AllowArithmeticOperation, 0) AS AllowArithmeticOperation,
           ISNULL(qc.Formula, '') AS Formula,
           ISNULL(IsSection, 0) AS IsSection,
           ISNULL(SectionNo, 0) AS SectionNo,
           ISNULL(SectionName, '') AS SectionName
    FROM dbo.[SeenClientQuestions]
        INNER JOIN dbo.[SeenClient]
            ON dbo.[SeenClient].Id = dbo.[SeenClientQuestions].SeenClientId
        INNER JOIN dbo.QuestionType AS Qt
            ON Qt.Id = QuestionTypeId
        LEFT JOIN dbo.QuestionCalculationItem qc
            ON qc.QuestionId = dbo.SeenClientQuestions.Id
               AND qc.IsCapture = 1
               AND qc.IsDeleted = 0
    WHERE dbo.[SeenClientQuestions].IsDeleted = 0
          AND [SeenClientId] = @SeenClientId
    ORDER BY SeenClientQuestions.Position,
             ChildPosition;
END;
