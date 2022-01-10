
-- =============================================
-- Author:			Sunil Vaghasiya
-- Create date:	28-Apr-2017
-- Description:	<Get Repetitive Form Data>
-- Call:WsGetRepetitiveFormData 1894983
-- =============================================
CREATE PROCEDURE [dbo].[WsGetRepetitiveFormData_111921] @ReportId BIGINT
AS
BEGIN

    DECLARE @ImageQuestionId NVARCHAR(MAX);
    DECLARE @Url NVARCHAR(100),
            @GraphicImagePath NVARCHAR(100),
            @ThumbnilUrl NVARCHAR(100);

    SELECT @Url = KeyValue + 'SeenClient/'
    FROM dbo.AAAAConfigSettings
    WHERE KeyName = 'DocViewerRootFolderPathWebApp';

    SELECT @ThumbnilUrl = KeyValue + 'Thumbnail/'
    FROM dbo.AAAAConfigSettings
    WHERE KeyName = 'DocViewerRootFolderPathWebApp';

    SELECT @GraphicImagePath = KeyValue + 'SeenClientQuestions/'
    FROM dbo.AAAAConfigSettings
    WHERE KeyName = 'DocViewerRootFolderPathCMS';

    SELECT QuestionId,
           Detail,
           Url,
           OUTDATA.ThumbnilUrl,
           RepetitiveGroupCount,
           GroupId,
           GroupName,
           QuestionTypeId,
           QuestionTitle,
           ShortName,
           IsDisplayInDetail,
           IsDisplayInSummary,
           ISNULL(ImageHeight, '0') AS ImageHeight,
           ISNULL(ImageWidth, '0') AS ImageWidth,
           ISNULL(ImageAlign, '0') AS ImageAlign,
           ISNULL(IsSignature, '0') AS IsSignature,
           IsTitleBold,
           IsTitleItalic,
           IsTitleUnderline,
           TitleTextColor,
           FontSize,
           Margin,
		   OUTDATA.ChildPosition
    FROM
    (
        SELECT QuestionId,
               CASE SCQ.QuestionTypeId
                   WHEN 8 THEN
                       dbo.ChangeDateFormat(Detail, 'dd/MMM/yyyy')
                   WHEN 9 THEN
                       dbo.ChangeDateFormat(Detail, 'hh:mm AM/PM')
                   WHEN 22 THEN
                       dbo.ChangeDateFormat(Detail, 'dd/MMM/yyyy hh:mm AM/PM')
                   WHEN 1 THEN
                       dbo.GetOptionNameByQuestionId(QuestionId, Detail, 1)
                   WHEN 23 THEN
                       SCQ.ImagePath
                   ELSE
                       ISNULL(Detail, '')
               END AS Detail,
               CASE SCQ.QuestionTypeId
                   WHEN 23 THEN
                       @GraphicImagePath
                   WHEN 17 THEN
                    dbo.GetMappingImageQuestionPath(SCQ.Id)
                ELSE
                    @Url
               END AS Url,
               CASE SCQ.QuestionTypeId
                   WHEN 23 THEN
                       @GraphicImagePath
                   ELSE
                       @ThumbnilUrl
               END AS ThumbnilUrl,
               ISNULL(SCA.RepeatCount, 0) AS RepetitiveGroupCount,
               ISNULL(SCA.RepetitiveGroupId, 0) AS GroupId,
               ISNULL(SCA.RepetitiveGroupName, '') AS GroupName,
               SCA.QuestionTypeId,
               SCQ.QuestionTitle,
               SCQ.ShortName,
               SCQ.IsDisplayInDetail,
               SCQ.IsDisplayInSummary,
               SCQ.Position,
               SCQ.ImageHeight,
               SCQ.ImageWidth,
               SCQ.ImageAlign,
               SCQ.IsSignature,
               SCQ.IsTitleBold,
               SCQ.IsTitleItalic,
               SCQ.IsTitleUnderline,
               SCQ.TitleTextColor,
               SCQ.FontSize,
               SCQ.Margin,
               ISNULL(SCQ.IsRoutingOnGroup, 0) AS isRoutingOnGroup,
               ISNULL(SCQ.ChildPosition, 0) AS ChildPosition
        FROM dbo.SeenClientAnswers SCA
            INNER JOIN dbo.SeenClientQuestions SCQ
                ON SCA.QuestionId = SCQ.Id
                   AND ISNULL(SCQ.QuestionsGroupNo, 0) = ISNULL(SCA.RepetitiveGroupId, 0)
        WHERE SeenClientAnswerMasterId = @ReportId
              AND ISNULL(SCA.RepetitiveGroupId, 0) > 0
    ) AS OUTDATA
    GROUP BY OUTDATA.QuestionId,
             OUTDATA.Detail,
             OUTDATA.Url,
             OUTDATA.ThumbnilUrl,
             OUTDATA.RepetitiveGroupCount,
             OUTDATA.GroupId,
             OUTDATA.GroupName,
             OUTDATA.QuestionTypeId,
             OUTDATA.QuestionTitle,
             OUTDATA.ShortName,
             OUTDATA.IsDisplayInDetail,
             OUTDATA.IsDisplayInSummary,
             OUTDATA.Position,
             OUTDATA.ImageHeight,
             OUTDATA.ImageWidth,
             OUTDATA.ImageAlign,
             OUTDATA.IsSignature,
             OUTDATA.IsTitleBold,
             OUTDATA.IsTitleItalic,
             OUTDATA.IsTitleUnderline,
             OUTDATA.TitleTextColor,
             OUTDATA.FontSize,
             OUTDATA.Margin,
             OUTDATA.isRoutingOnGroup,
             OUTDATA.ChildPosition
    ORDER BY OUTDATA.RepetitiveGroupCount,
             OUTDATA.Position,
             OUTDATA.ChildPosition;

END;

