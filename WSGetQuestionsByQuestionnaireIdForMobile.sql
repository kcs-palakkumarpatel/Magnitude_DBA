-- =============================================
-- Author:		Krishna Panchal
-- Create date: 13-11-2020
-- Description:	Get Question by Questionnaire ID For Mobile
-- Call SP:		WSGetQuestionsByQuestionnaireIdForMobile 4329,'2020-11-12 09:55:00.990'
-- =============================================
CREATE PROCEDURE [dbo].[WSGetQuestionsByQuestionnaireIdForMobile]
    @QuestionnaireId BIGINT,
    @LastServerDate DATETIME = '1970-01-01 00:00:00.00'
AS
BEGIN
    DECLARE @Url NVARCHAR(150);
    SELECT @Url = KeyValue + N'Questions/'
    FROM dbo.AAAAConfigSettings
    WHERE KeyName = 'DocViewerRootFolderPathCMS';
    SELECT Q.Id AS QuestionId,
           QuestionTypeId,
           QuestionTitle,
           ShortName,
           [Required],
           [MaxLength],
           ISNULL(Hint, '') AS Hint,
           ISNULL(OptionsDisplayType, '') AS OptionsDisplayType,
           IsTitleBold,
           IsTitleItalic,
           IsTitleUnderline,
           TitleTextColor,
           Position,
           EscalationRegex,
           Margin,
           FontSize,
           ISNULL(@Url + ImagePath, '') AS ImagePath,
           Q.IsCommentCompulsory AS IsCommentCompulsory,
           IsAnonymous AS IsAnonymous,
           Q.IsDisplayInDetail AS DisplayInDetail,
           Q.IsDisplayInSummary AS DisplayInList,
           Q.IsDecimal AS IsDecimal,
           Q.IsSignature AS IsSignature,
           Q.[IsRepetitive] AS IsRepetitive,
           Q.QuestionsGroupNo AS QuestionsGroupNo,
           Q.QuestionsGroupName AS QuestionsGroupName,
           Q.ImageHeight AS ImageHeight,
           Q.ImageWidth AS ImageWidth,
           Q.ImageAlign AS ImageAlign,
           Q.CalculationOptions AS CalculationOptions,
           Q.SummaryOption AS SummaryOption,
           (CASE
                 WHEN ISNULL(Q.DeletedOn, '') <> '' THEN
                    3 -- Deleted
                WHEN ISNULL(Q.UpdatedOn, '') <> '' THEN
                    2 -- Updated
                ELSE
                    1 --Added
            END
           ) AS [Action]
    FROM dbo.Questions AS Q
    WHERE (
              ISNULL(Q.IsDeleted,0) = 0
              OR @LastServerDate <> '1970-01-01 00:00:00.00'
          )
          AND Q.IsActive = 1
          AND QuestionnaireId = @QuestionnaireId
          AND
          (
              ISNULL(Q.UpdatedOn, Q.CreatedOn) >= @LastServerDate
              OR ISNULL(Q.DeletedOn, '') >= @LastServerDate
          )
    ORDER BY Q.Position;
END;
