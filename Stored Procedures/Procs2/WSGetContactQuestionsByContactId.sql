-- =============================================
-- Author:		<Author,,GD>
-- Create date: <Create Date,,19 Jun 2015>
-- Description:	<Description,,>
-- Call SP:		WSGetContactQuestionsByContactId 3,0
-- =============================================
CREATE PROCEDURE [dbo].[WSGetContactQuestionsByContactId]
    @ContactId BIGINT ,
    @ContactMasterId BIGINT
AS
    BEGIN
        DECLARE @Url NVARCHAR(150);

        SELECT  @Url = KeyValue + 'ContactQuestions/'
        FROM    dbo.AAAAConfigSettings
        WHERE   KeyName = 'DocViewerRootFolderPathCMS';

		--SELECT  @Url = KeyValue + 'UploadFiles/ContactQuestions/'
  --      FROM    dbo.AAAAConfigSettings
  --      WHERE   KeyName = 'DocViewerRootFolderPath';

        SELECT  Q.Id AS QuestionId ,
                Q.QuestionTypeId ,
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
                IsGroupField ,
                ISNULL(D.ContactOptionId, '') AS ContactOptionId ,
                ISNULL(D.Detail, '') AS Detail ,
                Margin ,
                FontSize ,
                ISNULL(@Url + ImagePath, '') AS ImagePath,
				Q.IsCommentCompulsory AS IsCommentCompulsory
        FROM    dbo.ContactQuestions AS Q
                LEFT OUTER JOIN dbo.ContactDetails D ON D.ContactQuestionId = Q.Id
                                                        AND ContactMasterId = @ContactMasterId
                                                        AND D.IsDeleted = 0
        WHERE   Q.IsDeleted = 0
                AND ContactId = @ContactId
        ORDER BY Q.Position;

    END;
