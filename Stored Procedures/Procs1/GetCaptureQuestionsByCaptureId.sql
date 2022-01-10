-- =============================================
-- Author:			Sunil Vaghasiya
-- Create date:	20-Mar-2017
-- Description:	<Description,,>
-- Call:					dbo.GetCaptureQuestionsByCaptureId 334
-- =============================================
CREATE PROCEDURE [dbo].[GetCaptureQuestionsByCaptureId] @SeenClientId BIGINT
AS
    BEGIN
        DECLARE @Url NVARCHAR(150);
        SELECT  @Url = KeyValue + 'SeenClientQuestions/'
        FROM    dbo.AAAAConfigSettings
        WHERE   KeyName = 'DocViewerRootFolderPathCMS';

        SELECT  Q.Id AS QuestionId ,
                Q.QuestionTypeId ,
                Q.QuestionTitle ,
                Q.ShortName ,
                Q.[Required] ,
                Q.[MaxLength] ,
                ISNULL(Hint, '') AS Hint ,
                ISNULL(OptionsDisplayType, '') AS OptionsDisplayType ,
                Q.IsTitleBold ,
                Q.IsTitleItalic ,
                Q.IsTitleUnderline ,
                TitleTextColor ,
                Q.Position ,
                Q.EscalationRegex ,
                ISNULL(Q.ContactQuestionId, 0) AS ContactQuestionId ,
                Margin ,
                FontSize ,
                ISNULL(@Url + ImagePath, '') AS ImagePath ,
                Q.IsDisplayInDetail AS DisplayInDetail ,
                Q.IsRepetitive AS IsRepetitive ,
                Q.IsDisplayInSummary AS DisplayInList ,
                Q.IsCommentCompulsory AS IsCommentCompulsory ,
                Q.IsDecimal AS IsDecimal
        FROM    dbo.SeenClientQuestions AS Q
        WHERE   Q.IsDeleted = 0
                AND SeenClientId = @SeenClientId
                AND Q.IsActive = 1
				AND Q.ContactQuestionId IS NULL
        ORDER BY Q.Position ASC;
    END;
