
-- =============================================
-- Author:			Sunil Vaghasiya
-- Create date:	26-Apr-2017
-- Description:	<Description,,>
-- Call SP:	dbo.WsGetSeenClientOutData 84383,2277,0,2803
-- 
-- =============================================
CREATE PROCEDURE [dbo].[WsGetSeenClientOutData_111921]
    @Id BIGINT,
    @AppUserId BIGINT,
    @IsGroup BIT,
    @ActivityId BIGINT
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @Url NVARCHAR(100),
            @GraphicImagePath NVARCHAR(100),
            @ThumbnilUrl NVARCHAR(100);

    SELECT @Url = KeyValue + N'SeenClient/'
    FROM dbo.AAAAConfigSettings
    WHERE KeyName = 'DocViewerRootFolderPathWebApp';

    SELECT @ThumbnilUrl = KeyValue + N'Thumbnail/'
    FROM dbo.AAAAConfigSettings
    WHERE KeyName = 'DocViewerRootFolderPathWebApp';

    SELECT @GraphicImagePath = KeyValue + N'SeenClientQuestions/'
    FROM dbo.AAAAConfigSettings
    WHERE KeyName = 'DocViewerRootFolderPathCMS';

    --SELECT  @Url = KeyValue + 'UploadFiles/SeenClient/'
    --      FROM    dbo.AAAAConfigSettings
    --      WHERE   KeyName = 'WebAppUrl';

    --SELECT  @ThumbnilUrl = KeyValue + 'UploadFiles/Thumbnail/'
    --      FROM    dbo.AAAAConfigSettings
    --      WHERE   KeyName = 'WebAppUrl';

    --      SELECT  @GraphicImagePath = KeyValue
    --              + 'UploadFiles/SeenClientQuestions/'
    --      FROM    dbo.AAAAConfigSettings
    --      WHERE   KeyName = 'DocViewerRootFolderPath';

    DECLARE @PIDispaly VARCHAR(5) = '0';
    IF (
       (
           SELECT COUNT(1)
           FROM dbo.SeenClientQuestions WITH
               (NOLOCK)
           WHERE QuestionTypeId IN ( 1, 5, 6, 7, 18, 21 )
                 AND SeenClientId =
                 (
                     SELECT SeenClientId
                     FROM dbo.EstablishmentGroup WITH
                         (NOLOCK)
                     WHERE Id = @ActivityId
                 )
                 AND [Required] = 1
                 AND IsDeleted = 0
       ) > 0
       )
    BEGIN
        SET @PIDispaly = '1';
    END;

    SELECT ReportId,
           EstablishmentId,
           SeenClientId,
           AppUserId,
           Latitude,
           Longitude,
           EI,
           IsPositive,
           CaptureDate,
           EstablishmentGroupName,
           CapturedBy,
           Client,
           QuestionId,
           QuestionTitle,
           IsDisplayInDetail,
           QuestionTypeId,
           Detail,
           Url,
           ThumbnilUrl,
           IsTransferred,
           AnswerStatus,
           IsActioned,
           RepetitiveGroupCount,
           RepetitiveGroupNo,
           RepetitiveGroupName,
           IsDisabled,
           ISNULL(ImageHeight, '0') AS ImageHeight,
           ISNULL(ImageWidth, '0') AS ImageWidth,
           ISNULL(ImageAlign, '0') AS ImageAlign,
           IsSignature,
           StatusId,
           StatusName,
           StatusImage,
           StatusCounter,
           StatusIconEstablishment
    FROM
    (
        SELECT DISTINCT
               R.ReportId,
               R.EstablishmentId,
               R.SeenClientId,
               R.AppUserId,
               R.Latitude,
               R.Longitude,
               R.EI,
               R.IsPositive,
               R.CaptureDate,
               R.EstablishmentGroupName,
               R.CapturedBy,
               R.Client,
               A.QuestionId,
               SQ.QuestionTitle AS QuestionTitle,
               IsDisplayInDetail,
               A.QuestionTypeId,
               CASE SQ.QuestionTypeId
                   WHEN 8 THEN
                       dbo.ChangeDateFormat(Detail, 'dd/MMM/yyyy')
                   WHEN 9 THEN
                       dbo.ChangeDateFormat(Detail, 'hh:mm AM/PM')
                   WHEN 22 THEN
                       dbo.ChangeDateFormat(Detail, 'dd/MMM/yyyy hh:mm AM/PM')
                   WHEN 1 THEN
                       dbo.GetOptionNameByQuestionId(A.QuestionId, A.Detail, 1)
                   WHEN 23 THEN
                       SQ.ImagePath
                   ELSE
                       ISNULL(A.Detail, '')
               END AS Detail,
               CASE SQ.QuestionTypeId
                   WHEN 23 THEN
                       @GraphicImagePath
                   ELSE
                       @Url
               END AS Url,
               CASE SQ.QuestionTypeId
                   WHEN 23 THEN
                       @GraphicImagePath
                   ELSE
                       @ThumbnilUrl
               END AS ThumbnilUrl,
               R.IsTransferred,
               R.AnswerStatus,
               R.IsActioned,
               SQ.Position,
               ISNULL(A.RepeatCount, 0) AS RepetitiveGroupCount,
               ISNULL(A.RepetitiveGroupId, 0) AS RepetitiveGroupNo,
               ISNULL(A.RepetitiveGroupName, '') AS RepetitiveGroupName,
               R.IsDisabled,
               SQ.ImageHeight,
               SQ.ImageWidth,
               SQ.ImageAlign,
               ISNULL(SQ.IsSignature, 0) AS IsSignature,
               R.StatusId,
               R.StatusName,
               R.StatusImage,
               R.StatusCounter,
               R.StatusIconEstablishment
        FROM
        (
            SELECT TOP 1
                   Am.Id AS ReportId,
                   Am.EstablishmentId,
                   Am.SeenClientId,
                   Am.AppUserId,
                   Am.Latitude,
                   Am.Longitude,
                   IIF(@PIDispaly = 1, Am.[PI], IIF(Am.[PI] > 0.00, Am.[PI], -1)) AS EI,
                   Am.IsPositive,
                   dbo.ChangeDateFormat(DATEADD(MINUTE, Am.TimeOffSet, Am.CreatedOn), 'dd/MMM/yyyy hh:mm AM/PM') AS CaptureDate,
                   DATEADD(MINUTE, Am.TimeOffSet, Am.CreatedOn) AS CreatedOn,
                   Eg.EstablishmentGroupName,
                   U.Name AS CapturedBy,
                   dbo.ConcateString(N'ContactSummary', Am.ContactMasterId) AS Client,
                   ISNULL(CAST(0 AS BIT), 0) AS IsTransferred,
                   Am.IsResolved AS AnswerStatus,
                   IsActioned,
                   Am.IsDisabled AS IsDisabled,
                   ES.Id AS StatusId,
                   ES.StatusName,
                   SII.IconPath AS StatusImage,
                   (
                       SELECT FORMAT(CAST(SH.StatusDateTime AS DATETIME), 'dd/MMM/yy HH:mm', 'en-us')
                   ) AS StatusTime,
                   (
                       SELECT dbo.DifferenceDatefun(
                                                       ISNULL(SH.StatusDateTime, GETUTCDATE()),
                                                       DATEADD(MINUTE, Am.TimeOffSet, GETUTCDATE())
                                                   )
                   ) AS StatusCounter,
                   E.StatusIconEstablishment AS StatusIconEstablishment
            FROM dbo.SeenClientAnswerMaster AS Am WITH
                (NOLOCK)
                INNER JOIN dbo.Establishment AS E WITH
                (NOLOCK)
                    ON Am.EstablishmentId = E.Id
                INNER JOIN dbo.EstablishmentGroup AS Eg WITH
                (NOLOCK)
                    ON E.EstablishmentGroupId = Eg.Id
                INNER JOIN dbo.AppUser AS U WITH
                (NOLOCK)
                    ON Am.AppUserId = U.Id
                LEFT OUTER JOIN dbo.StatusHistory AS SH WITH
                (NOLOCK)
                    ON Am.StatusHistoryId = SH.Id
                LEFT OUTER JOIN dbo.EstablishmentStatus AS ES WITH
                (NOLOCK)
                    ON SH.EstablishmentStatusId = ES.Id
                LEFT OUTER JOIN dbo.StatusIconImage SII WITH
                (NOLOCK)
                    ON ES.StatusIconImageId = SII.Id
            WHERE Am.IsDeleted = 0
                  AND
                  (
                      (
                          ContactMasterId = @Id
                          AND @IsGroup = 0
                      )
                      OR
                      (
                          ContactGroupId = @Id
                          AND @IsGroup = 1
                      )
                  )
                  AND Am.EstablishmentId IN
                      (
                          SELECT EST.Id
                          FROM dbo.Establishment AS EST
                          WHERE EST.EstablishmentGroupId = @ActivityId
                      )
                  AND Am.CreatedBy = @AppUserId
            ORDER BY Am.CreatedOn DESC
        ) AS R
            INNER JOIN dbo.SeenClientAnswers AS A WITH
            (NOLOCK)
                ON A.SeenClientAnswerMasterId = R.ReportId
            INNER JOIN dbo.SeenClientQuestions AS SQ WITH
            (NOLOCK)
                ON A.QuestionId = SQ.Id
                   AND R.SeenClientId = SQ.SeenClientId
        WHERE A.IsDeleted = 0
              AND SQ.IsDeleted = 0
              AND SQ.IsDisplayInDetail = 1
              AND SQ.ContactQuestionId IS NULL
    ) i
    ORDER BY i.Position;
END;
