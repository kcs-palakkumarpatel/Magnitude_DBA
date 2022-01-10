
-- =============================================
-- Author:			Sunil Vaghasiya
-- Create date:	17-Apr-2017
-- Description:	<Description,,GetQuestionsById>
-- Call SP    :		dbo.GetQuestionsByQuestionnaireId 4846
-- =============================================
CREATE PROCEDURE [dbo].[GetQuestionsByQuestionnaireId] @QuestionnaireId BIGINT
AS
BEGIN
	SET DEADLOCK_PRIORITY NORMAL;
	
	BEGIN TRY
    DECLARE @Url NVARCHAR(150);
    SELECT @Url = KeyValue + 'Questions/'
    FROM dbo.AAAAConfigSettings
    WHERE KeyName = 'DocViewerRootFolderPathCMS';

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
           ISNULL(IsRoutingOnGroup, 0) AS IsRoutingOnGroup,
           ISNULL(IsValidateUsingQR, 0) AS IsValidateUsingQR,
           ISNULL(IsForReminder, 0) AS IsForReminder,
           ISNULL(IsSingleSelect, 0) AS IsSingleSelect,
           ISNULL(AllowArithmeticOperation, 0) AS AllowArithmeticOperation,
           ISNULL(qc.Formula, '') AS Formula
         
    FROM dbo.Questions
        INNER JOIN dbo.QuestionType AS Qt
            ON Qt.Id = QuestionTypeId
        LEFT JOIN dbo.QuestionCalculationItem qc
            ON qc.QuestionId = dbo.Questions.Id
               AND qc.IsCapture = 0
               AND qc.IsDeleted = 0
    WHERE Questions.IsDeleted = 0
          AND [QuestionnaireId] = @QuestionnaireId
    ORDER BY Questions.Position,
             ChildPosition;
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
         'dbo.GetQuestionsByQuestionnaireId',
         N'DATABASE',
         ERROR_MESSAGE(),
         ('ERROR_NUMBER=' + CONVERT(VARCHAR(100), ERROR_NUMBER()) + ',ERROR_STATE='
          + CONVERT(VARCHAR(20), ERROR_STATE()) + ',ERROR_SEVERITY=' + CONVERT(VARCHAR(20), ERROR_SEVERITY())
         )  ,
         GETUTCDATE(),
         N'',
         @QuestionnaireId,
         GETUTCDATE(),
         N''
        );
END CATCH
END;
