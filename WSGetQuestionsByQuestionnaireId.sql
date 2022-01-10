-- =============================================
-- Author:		<Author,,GD>
-- Create date: <Create Date,,12 Jun 2015>
-- Description:	<Description,,>
-- Call SP:		WSGetQuestionsByQuestionnaireId 23
-- =============================================
CREATE PROCEDURE [dbo].[WSGetQuestionsByQuestionnaireId]
    @QuestionnaireId BIGINT
AS
    BEGIN
        DECLARE @Url NVARCHAR(150);
        SELECT  @Url = KeyValue + 'Questions/'
        FROM    dbo.AAAAConfigSettings
        WHERE   KeyName = 'DocViewerRootFolderPathCMS';

        SELECT  Q.Id AS QuestionId ,
                QuestionTypeId ,
                QuestionTitle ,
                ShortName ,
                [Required] ,
                [MaxLength] ,
                ISNULL(Hint, '') AS Hint ,
                ISNULL(OptionsDisplayType, '') AS OptionsDisplayType ,
                IsTitleBold ,
                IsTitleItalic ,
                IsTitleUnderline ,
                TitleTextColor ,
                Position ,
                EscalationRegex ,
                Margin ,
                FontSize ,
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
				Q.SummaryOption AS SummaryOption
        FROM    dbo.Questions AS Q
        WHERE   Q.IsActive = 1
                AND Q.IsDeleted = 0
                AND QuestionnaireId = @QuestionnaireId
        ORDER BY Q.Position;
    END;
