-- =============================================
-- Author:		<Author,,Mittal Patel>
-- Create date: <Create Date,, 9, jan 2020>
-- Description:	<Description,,GetQuestionnaireById>
-- Call SP    :	GetQuestionnaireByQuestionnaireId 2236
-- =============================================
CREATE PROCEDURE [dbo].[GetQuestionnaireByQuestionnaireId] @Id BIGINT
AS
BEGIN
    --GetQuestionnaireById
    DECLARE @SeenClientId BIGINT,
            @ContactId BIGINT;
    DECLARE @Url NVARCHAR(150);

    SELECT @SeenClientId = SQ.SeenClientId
    FROM dbo.Questions AS Q
        INNER JOIN dbo.SeenClientQuestions AS SQ
            ON Q.SeenClientQuestionIdRef = SQ.Id
    WHERE Q.QuestionnaireId = @Id;

    SELECT @ContactId = CQ.ContactId
    FROM dbo.Questions AS Q
        INNER JOIN dbo.ContactQuestions AS CQ
            ON Q.ContactQuestionIdRef = CQ.Id
    WHERE Q.QuestionnaireId = @Id
          AND Q.IsDeleted = 0;

    SELECT [Id] AS Id,
           [QuestionnaireTitle] AS QuestionnaireTitle,
           [QuestionnaireType] AS QuestionnaireType,
           [Description] AS Description,
           QuestionnaireFormType,
           ISNULL(@SeenClientId, 0) AS SeenClientId,
           ISNULL(CompareType, 0) AS CompareType,
           FixedBenchMark,
           LastTestDate,
           TestTime,
           EscalationValue,
           IsMultipleRouting,
           ISNULL(@ContactId, 0) AS ContactId,
           ISNULL(ControlStyleId, 1) AS ControlStyleId
    FROM dbo.[Questionnaire]
    WHERE [Id] = @Id;

    --GetQuestionsByQuestionnaireId
    SELECT @Url = KeyValue + 'Questions/'
    FROM dbo.AAAAConfigSettings
    WHERE KeyName = 'DocViewerRootFolderPathCMS';

    SELECT Questions.Id AS Id,
           QuestionnaireId AS QuestionnaireId,
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
           IsDefaultDisplay AS IsDefaultDisplay
    FROM dbo.Questions
        INNER JOIN dbo.QuestionType AS Qt
            ON Qt.Id = QuestionTypeId
    WHERE Questions.IsDeleted = 0
          AND [QuestionnaireId] = @Id
    ORDER BY Questions.Position;

    --GetOptionsByQuestionnaireId
    SELECT dbo.[Options].[Id] AS Id,
           dbo.[Options].[QuestionId] AS QuestionId,
           QuestionTitle,
           dbo.[Options].[Position] AS Position,
           dbo.[Options].[Name] AS Name,
           dbo.[Options].[Value] AS Value,
           dbo.[Options].[DefaultValue] AS DefaultValue,
           dbo.Options.[Weight],
           Point,
           dbo.Options.OptionImagePath,
           dbo.Questions.QuestionTypeId
    FROM dbo.[Options]
        INNER JOIN dbo.[Questions]
            ON dbo.[Questions].Id = dbo.[Options].QuestionId
    WHERE dbo.[Options].IsDeleted = 0
          AND QuestionnaireId = @Id
          AND QuestionTypeId != 26;

    --GetRepetitiveQuestionGroupListByQuestionnaireId
    SELECT QuestionsGroupNo,
           QuestionsGroupName
    FROM dbo.Questions
    WHERE QuestionnaireId = @Id
          AND ISNULL(IsRepetitive, 0) = 1
    GROUP BY QuestionsGroupNo,
             QuestionsGroupName;

    --GetAllOperationSymbol
    SELECT Id,
           Symbol
    FROM dbo.Operation
    WHERE IsDeleted = 0;

    --GetQuestionConditionsByQuestionnaireId
    SELECT CL.QuestionId,
           CL.ConditionQuestionId,
           QQ.QuestionTitle AS [ConditionQuestionTitle],
           CL.OperationId,
           O.Symbol,
           Q.QuestionTypeId,
           ISNULL(CL.AnswerId, '') AS AnswerId,
           ISNULL(OPT.[Name], '') AS [AnswerOptionText],
           ISNULL(CL.AnswerText, '') AS [AnswerText],
           CL.IsDeleted,
           CL.UpdatedBy,
           CL.CreatedBy,
           CL.IsAnd
    FROM ConditionLogic CL
        INNER JOIN Questions Q
            ON CL.QuestionId = Q.Id
               AND Q.IsDeleted = 0
        INNER JOIN Questions QQ
            ON CL.ConditionQuestionId = QQ.Id
               AND QQ.IsDeleted = 0
        INNER JOIN Operation O
            ON CL.OperationId = O.Id
               AND O.IsDeleted = 0
        LEFT JOIN Options OPT
            ON CL.AnswerId = OPT.Id
               AND OPT.IsDeleted = 0
    WHERE Q.QuestionnaireId = @Id
          AND CL.IsDeleted = 0;

    --GetRoutingConditionsByQuestionnaireId
    SELECT QI.Id AS [QuestionId],
           RL.OptionId,
           OPT.[Name] AS [OptionName],
           RL.QueueQuestionId,
           Q.QuestionTitle AS [QueueQuestionTitle],
           RL.CreatedBy,
           ISNULL(RL.UpdatedBy, 0) AS UpdatedBy,
           RL.IsDeleted,
           ISNULL(RL.DeletedBy, 0) AS DeletedBy
    FROM RoutingLogic RL
        INNER JOIN Options OPT
            ON RL.OptionId = OPT.Id
               AND OPT.IsDeleted = 0
        INNER JOIN dbo.Questions QI
            ON OPT.QuestionId = QI.Id
               AND QI.IsDeleted = 0
        INNER JOIN Questions Q
            ON RL.QueueQuestionId = Q.Id
               AND Q.IsDeleted = 0
    WHERE Q.QuestionnaireId = @Id;
END;
