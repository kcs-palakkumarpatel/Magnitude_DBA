-- =============================================
-- Author:			bhavik patel
-- Create date:	20-Jan-2021
-- Description:	<Description,,[[GetQuestionsDetailsById]]>
-- Call SP    :		[[GetQuestionsDetailsById]] 1898
-- =============================================
CREATE PROCEDURE dbo.GetQuestionsDetailsById @QuestionId BIGINT
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        SELECT SCQ.[Id] AS Id,
               SCQ.[SeenClientId] AS SeenClientId,
               SCQ.[Position] AS Position,
               ISNULL(SCQ.ChildPosition, 0) AS ChildPosition,
               SCQ.[QuestionTypeId] AS QuestionTypeId,
               SCQ.[QuestionTitle] AS QuestionTitle,
               SCQ.[ShortName] AS ShortName,
               SCQ.[Required] AS Required,
               SCQ.[IsDisplayInSummary] AS IsDisplayInSummary,
               SCQ.[IsRepetitive] AS IsRepetitive,
               SCQ.QuestionsGroupNo AS RepetitiveQuestionsGroupNo,
               SCQ.QuestionsGroupName AS RepetitiveQuestionsGroupName,
               SCQ.[IsDisplayInDetail] AS IsDisplayInDetail,
               SCQ.[MaxLength] AS MaxLength,
               SCQ.[Hint] AS Hint,
               SCQ.[EscalationRegex] AS EscalationRegex,
               SCQ.[KeyName] AS KeyName,
               SCQ.[GroupId] AS GroupId,
               SCQ.[OptionsDisplayType] AS OptionsDisplayType,
               SCQ.IsTitleBold,
               SCQ.IsTitleItalic,
               SCQ.IsTitleUnderline,
               SCQ.TitleTextColor,
               SCQ.ContactQuestionId,
               SCQ.TableGroupName,
               SCQ.[EscalationValue] AS EscalationValue,
               SCQ.[DisplayInGraphs] AS DisplayInGraphs,
               SCQ.[DisplayInTableView] AS DisplayInTableView,
               ISNULL(   CASE
                             WHEN QuestionTypeId IN ( 5, 6, 18, 21 ) THEN
                             (
                                 SELECT SUM([Weight])
                                 FROM dbo.SeenClientOptions
                                 WHERE QuestionId = SCQ.Id
                                       AND IsDeleted = 0
                             )
                             ELSE
                                 [Weight]
                         END,
                         0
                     ) [Weight],
               SCQ.WeightForYes,
               SCQ.WeightForNo,
               Qt.QuestionTypeName,
               SCQ.Margin,
               SCQ.FontSize,
               ISNULL(
               (
                   SELECT COUNT(1)
                   FROM Questions
                   WHERE SeenClientQuestionIdRef = SCQ.Id
                         AND IsDeleted = 0
               ),
               0
                     ) AS ReferenceId,
               ISNULL(ImagePath, '') AS ImagePath,
               SCQ.IsActive,
               IsCommentCompulsory AS IsCommentCompulsory,
               SCQ.IsDecimal AS AllowDecimal,
               IsSignature AS IsSignature,
               SCQ.ImageHeight AS ImageHeight,
               SCQ.ImageWidth AS ImageWidth,
               SCQ.ImageAlign AS ImageAlign,
               SCQ.CalculationOptions AS CalculationOptions,
               SCQ.SummaryOption AS SummaryOption,
               ISNULL(SCQ.IsValidateUsingQR, 0) AS IsValidateUsingQR,
               ISNULL(SCQ.TenderQuestionType, 0) AS TenderQuestionType,
               ISNULL(SCQ.IsSingleSelect, 0) AS IsSingleSelect,
               ISNULL(SCQ.AllowArithmeticOperation, 0) AS AllowArithmeticOperation,
               ISNULL(qc.Formula, '') AS Formula,
               ISNULL(SCQ.IsSection, 0) AS IsSection,
               ISNULL(SCQ.SectionNo, 0) AS SectionNo,
               ISNULL(SCQ.SectionName, 0) AS SectionName
        FROM dbo.[SeenClientQuestions] SCQ
            INNER JOIN dbo.[SeenClient] SC
                ON SC.Id = SCQ.SeenClientId
            INNER JOIN dbo.QuestionType AS Qt
                ON Qt.Id = QuestionTypeId
            LEFT JOIN dbo.QuestionCalculationItem qc
                ON qc.QuestionId = SCQ.Id
                   AND qc.IsCapture = 1
                   AND qc.IsDeleted = 0
        WHERE SCQ.IsDeleted = 0
              AND SCQ.Id = @QuestionId;
    END TRY
    BEGIN CATCH
        INSERT INTO dbo.ErrorLog
        (
            PageId,
            MethodName,
            ErrorType,
            ErrorMessage,
            ErrorDetails,
            ErrorDate,
            UserId,
            Solution,
            CreatedOn,
            CreatedBy
        )
        VALUES
        (ERROR_LINE(),
         'dbo.GetQuestionsDetailsById',
         N'Database',
         ERROR_MESSAGE(),
         ('ERROR_NUMBER=' + CONVERT(VARCHAR(100), ERROR_NUMBER()) + ',ERROR_STATE='
          + CONVERT(VARCHAR(20), ERROR_STATE()) + ',ERROR_SEVERITY=' + CONVERT(VARCHAR(20), ERROR_SEVERITY())
         )  ,
         GETUTCDATE(),
         0  ,
         N'',
         GETUTCDATE(),
         0
        );
    END CATCH;
END;
