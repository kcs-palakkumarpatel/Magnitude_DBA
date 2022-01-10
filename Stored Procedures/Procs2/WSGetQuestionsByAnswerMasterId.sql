-- =============================================
-- Author:		<Author,,GD>
-- Create date: <Create Date,,12 Jun 2015>
-- Description:	<Description,,>
-- Call SP:		WSGetQuestionsByQuestionnaireId 23
-- =============================================
CREATE PROCEDURE [dbo].[WSGetQuestionsByAnswerMasterId]
    @AnswerMasterId BIGINT
AS
    BEGIN
	DECLARE @QuestionnaireId BIGINT
		SELECT @QuestionnaireId = EG.QuestionnaireId FROM dbo.SeenClientAnswerMaster AS SAM INNER JOIN dbo.Establishment E ON E.Id = SAM.EstablishmentId INNER JOIN dbo.EstablishmentGroup AS EG ON EG.Id = E.EstablishmentGroupId
		WHERE SAM.id = @AnswerMasterId

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
				Q.QuestionnaireId AS QuestionnaireId
        FROM    dbo.Questions AS Q
        WHERE   Q.IsActive = 1
                AND Q.IsDeleted = 0
                AND QuestionnaireId = @QuestionnaireId
        ORDER BY Q.Position;
    END;
