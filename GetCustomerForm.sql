-- =============================================
-- Author:			Sunil Vaghasiya
-- Create date:	24-Apr-2017
-- Description:	Get all active questions by questionnaire id for mobi form
-- Call SP    :		dbo.GetMobiForm 0,87034,0
-- =============================================
CREATE PROCEDURE [dbo].[GetCustomerForm]
    @QuestionnaireId BIGINT ,
    @SeenClientAnswerMasterId BIGINT ,
    @SeenClientAnswerChildId BIGINT
AS
    BEGIN
	DECLARE @blIsIntroductoryMessage BIT
            IF @QuestionnaireId = 0
            AND @SeenClientAnswerMasterId > 0
            BEGIN
                SELECT  @QuestionnaireId = QuestionnaireId,@blIsIntroductoryMessage = e.ShowIntroductoryOnMobi
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
        --FROM    dbo.AAAAConfigSettings
        --WHERE   KeyName = 'DocViewerRootFolderPath';

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
                ISNULL(Q.Hint,'') AS Hint ,
                Q.EscalationRegex AS EscalationRegex ,
                ISNULL(Q.OptionsDisplayType,'') AS OptionsDisplayType ,
                Q.SeenClientQuestionIdRef AS SeenClientQuestionIdRef ,
                Q.IsTitleBold ,
                Q.IsTitleItalic ,
                Q.IsTitleUnderline ,
                Q.TitleTextColor ,
                Q.FontSize ,
                Q.Margin ,
                ISNULL(SQ.QuestionTitle, '') AS SeenClientQuestionTitle ,
                ISNULL(SA.Detail, '') AS Detail ,
                ISNULL(SQ.Id, 0) AS SeenClientQuestionId ,
                ISNULL(@Url + Q.ImagePath, '') AS ImagePath ,
                Q.IsCommentCompulsory AS IsCommentCompulsory ,
                Q.IsAnonymous AS IsAnonymous ,
                ISNULL(Q.IsDecimal, 0) AS IsDecimal ,
				ISNULL(Q.IsSignature, 0) AS IsSignature,
                ISNULL(Q.IsRepetitive, 0) AS IsRepetitive ,
                ISNULL(Q.QuestionsGroupNo, 0) AS RepetitiveGroupNo ,
                ISNULL(Q.QuestionsGroupName, '') AS RepetitiveGroupName,
				Q.ImageHeight AS ImageHeight,
				Q.ImageWidth AS ImageWidth,
				Q.ImageAlign AS ImageAlign,
				Q.CalculationOptions AS CalculationOptions,
				Q.SummaryOption AS SummaryOption

        FROM    dbo.[Questions] AS Q
                LEFT OUTER JOIN dbo.SeenClientQuestions AS SQ ON Q.SeenClientQuestionIdRef = SQ.Id
                LEFT OUTER JOIN dbo.SeenClientAnswers AS SA ON SQ.Id = SA.QuestionId
                                                              AND SA.SeenClientAnswerMasterId = @SeenClientAnswerMasterId
                                                              AND ( @SeenClientAnswerChildId = 0
                                                              OR SA.SeenClientAnswerChildId = @SeenClientAnswerChildId
                                                              )
        WHERE   Q.IsActive = 1
                AND Q.IsDeleted = 0
                AND Q.QuestionnaireId = @QuestionnaireId
        ORDER BY Q.Position;
    END;