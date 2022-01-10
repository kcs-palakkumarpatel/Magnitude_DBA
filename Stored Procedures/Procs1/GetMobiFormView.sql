-- =============================================
-- Author:			Sunil Vaghasiya
-- Create date:	16-Mar-2017
-- Description:	Get all active questions by questionnaire id for mobi form
-- Call SP    :	GetMobiFormView 507, 42513,0,14462
-- =============================================
CREATE PROCEDURE [dbo].[GetMobiFormView]
    @QuestionnaireId BIGINT ,
    @SeenClientAnswerMasterId BIGINT ,
    @SeenClientAnswerChildId BIGINT ,
    @AnswerMasterId BIGINT
AS
    BEGIN
        IF @QuestionnaireId = 0
            AND @SeenClientAnswerMasterId > 0
            BEGIN
                SELECT  @QuestionnaireId = QuestionnaireId
                FROM    dbo.SeenClientAnswerMaster AS SAM
                        INNER JOIN dbo.Establishment AS E ON SAM.EstablishmentId = E.Id
                        INNER JOIN dbo.EstablishmentGroup AS Eg ON E.EstablishmentGroupId = Eg.Id
                WHERE   SAM.Id = @SeenClientAnswerMasterId;
            END;

        DECLARE @Url NVARCHAR(150);
        SELECT  @Url = KeyValue + 'Questions/'
        FROM    dbo.AAAAConfigSettings
        WHERE   KeyName = 'DocViewerRootFolderPathCMS';


		--SELECT  @Url = KeyValue + 'UploadFiles/Questions/'
  --      FROM    dbo.AAAAConfigSettings
  --      WHERE   KeyName = 'DocViewerRootFolderPath';

        SELECT  Q.Id AS Id ,
                Q.QuestionnaireId AS QuestionnaireId ,
                Q.Position AS Position ,
                Q.QuestionTypeId AS QuestionTypeId ,
                Q.QuestionTitle AS QuestionTitle ,
                Q.ShortName AS ShortName ,
                Q.IsActive AS IsActive ,
                Q.[Required] AS Required ,
                Q.IsDisplayInSummary AS IsDisplayInSummary ,
                Q.IsDisplayInDetail AS IsDisplayInDetail ,
                Q.[MaxLength] AS MaxLength ,
                Q.Hint AS Hint ,
                Q.EscalationRegex AS EscalationRegex ,
                Q.OptionsDisplayType AS OptionsDisplayType ,
                Q.SeenClientQuestionIdRef AS SeenClientQuestionIdRef ,
                Q.IsTitleBold ,
                Q.IsTitleItalic ,
                Q.IsTitleUnderline ,
                Q.TitleTextColor ,
                Q.FontSize ,
                Q.Margin ,
                ISNULL(SQ.QuestionTitle, '') AS SeenClientQuestionTitle ,
                ISNULL(SA.Detail, ISNULL(A.Detail, '')) AS Detail ,
                ISNULL(SQ.Id, 0) AS SeenClientQuestionId ,
                ISNULL(@Url + Q.ImagePath, '') AS ImagePath ,
                Q.IsCommentCompulsory AS IsCommentCompulsory ,
                Q.IsAnonymous AS IsAnonymous,
				ISNULL(Q.IsDecimal, 0) AS IsDecimal,
				ISNULL(Q.IsRepetitive, 0) AS IsRepetitive,
				Q.ImageHeight AS ImageHeight,
				Q.ImageWidth AS ImageWidth,
				Q.ImageAlign AS ImageAlign,
				Q.IsSignature AS IsSignature
        FROM    dbo.[Questions] AS Q
                LEFT OUTER JOIN dbo.SeenClientQuestions AS SQ ON Q.SeenClientQuestionIdRef = SQ.Id
                LEFT OUTER JOIN dbo.SeenClientAnswers AS SA ON SQ.Id = SA.QuestionId
                                                              AND SA.SeenClientAnswerMasterId = @SeenClientAnswerMasterId
                                                              AND ( @SeenClientAnswerChildId = 0
                                                              OR SA.SeenClientAnswerChildId = @SeenClientAnswerChildId
                                                              )
                LEFT OUTER JOIN dbo.Answers AS A ON A.QuestionId = Q.Id
                                                    AND A.AnswerMasterId = @AnswerMasterId
        WHERE   Q.IsActive = 1
                AND Q.IsDeleted = 0
                AND Q.QuestionnaireId = @QuestionnaireId
        ORDER BY Q.Position;
    END;
