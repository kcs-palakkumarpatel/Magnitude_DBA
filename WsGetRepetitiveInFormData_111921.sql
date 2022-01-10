
-- =============================================
-- Author:			Sunil Vaghasiya
-- Create date:	28-Apr-2017
-- Description:	<Get Repetitive Form Data>
-- Call:					dbo.WsGetRepetitiveInFormData 33700
-- =============================================
CREATE PROCEDURE [dbo].[WsGetRepetitiveInFormData_111921] @ReportId BIGINT
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @Url NVARCHAR(100),
            @GraphicImagePath NVARCHAR(100);

    SELECT @Url = KeyValue + N'Feedback/'
    FROM dbo.AAAAConfigSettings WITH
        (NOLOCK)
    WHERE KeyName = 'DocViewerRootFolderPathWebApp';

    SELECT @GraphicImagePath = KeyValue + N'SeenClientQuestions/'
    FROM dbo.AAAAConfigSettings WITH
        (NOLOCK)
    WHERE KeyName = 'DocViewerRootFolderPathCMS';

    --SELECT  @Url = KeyValue + 'UploadFiles/Feedback/'
    --     FROM    dbo.AAAAConfigSettings
    --     WHERE   KeyName = 'WebAppUrl';

    --     SELECT  @GraphicImagePath = KeyValue
    --             + 'UploadFiles/SeenClientQuestions/'
    --     FROM    dbo.AAAAConfigSettings
    --     WHERE   KeyName = 'DocViewerRootFolderPath';

    SELECT DISTINCT
           SCA.QuestionId,
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
               ELSE
                   @Url
           END AS Url,
           ISNULL(SCA.RepeatCount, 0) AS RepetitiveGroupCount,
           ISNULL(SCA.RepetitiveGroupId, 0) AS GroupId,
           ISNULL(SCA.RepetitiveGroupName, '') AS GroupName,
           SCA.QuestionTypeId,
           SCQ.QuestionTitle,
           SCQ.ShortName,
           SCQ.IsDisplayInDetail,
           SCQ.IsDisplayInSummary,
           SCQ.Position,
           ISNULL(SCQ.IsSignature, 0) AS IsSignature
    FROM dbo.Answers SCA WITH
        (NOLOCK)
        INNER JOIN dbo.Questions SCQ WITH
        (NOLOCK)
            ON SCA.QuestionId = SCQ.Id
    WHERE SCA.AnswerMasterId = @ReportId
          AND ISNULL(SCA.RepetitiveGroupId, 0) > 0
    ORDER BY SCQ.Position;
END;
