
-- =============================================
-- Author:			Sunil Vaghasiya
-- Create date:	26-Apr-2017
-- Description:	<Description,,>
-- Call SP:	dbo.WsGetSeenClientOutDataForMobiForm 1580422,0
-- =============================================
/*
Drop procedure WsGetSeenClientOutDataForMobiForm_101120

Exec WsGetSeenClientOutDataForMobiForm_101120
*/
CREATE PROCEDURE [dbo].[WsGetSeenClientOutDataForMobiForm]
    @AnswerMasterId BIGINT,
    @AppUserId BIGINT
AS
BEGIN
    SET NOCOUNT ON;
	SET DEADLOCK_PRIORITY NORMAL;
	
	BEGIN TRY
    DECLARE @Id BIGINT,
            @IsGroup BIT,
            @ActivityId BIGINT;
    DECLARE @ImageQuestionId NVARCHAR(MAX);
    SELECT @Id = CASE IsSubmittedForGroup
                     WHEN 1 THEN
                         ContactGroupId
                     ELSE
                         ContactMasterId
                 END,
           @IsGroup = IsSubmittedForGroup,
           @ActivityId =
    (
        SELECT EstablishmentGroupId
        FROM dbo.Establishment WITH (NOLOCK)
        WHERE Id = SAM.EstablishmentId
    )
    FROM dbo.SeenClientAnswerMaster AS SAM WITH (NOLOCK)
    WHERE Id = @AnswerMasterId;

    DECLARE @Url NVARCHAR(100),
            @GraphicImagePath NVARCHAR(100),
            @ThumbnilUrl NVARCHAR(100);

    SELECT @Url = KeyValue + 'SeenClient/'
    FROM dbo.AAAAConfigSettings WITH (NOLOCK)
    WHERE KeyName = 'DocViewerRootFolderPathWebApp';

    SELECT @ThumbnilUrl = KeyValue + 'Thumbnail/'
    FROM dbo.AAAAConfigSettings WITH (NOLOCK)
    WHERE KeyName = 'DocViewerRootFolderPathWebApp';

    SELECT @GraphicImagePath = KeyValue + 'SeenClientQuestions/'
    FROM dbo.AAAAConfigSettings WITH (NOLOCK)
    WHERE KeyName = 'DocViewerRootFolderPathCMS';

    DECLARE @PIDispaly VARCHAR(5) = '0';

    IF (
       (
           SELECT COUNT(1)
           FROM dbo.SeenClientQuestions WITH (NOLOCK)
           WHERE QuestionTypeId IN ( 1, 5, 6, 7, 18, 21 )
                 AND SeenClientId =
                 (
                     SELECT SeenClientId
                     FROM dbo.EstablishmentGroup WITH (NOLOCK)
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
           IsSignature,
           IsTitleBold,
           IsTitleItalic,
           IsTitleUnderline,
           TitleTextColor,
           FontSize,
           Margin,
           ImageHeight,
           ImageWidth,
           ImageAlign
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
                WHEN 17 THEN
                    dbo.GetMappingImageQuestionPath(SQ.Id)
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
            SQ.IsSignature,
            SQ.IsTitleBold,
            SQ.IsTitleItalic,
            SQ.IsTitleUnderline,
            SQ.TitleTextColor,
            SQ.FontSize,
            SQ.Margin,
            SQ.ImageHeight,
            SQ.ImageWidth,
            SQ.ImageAlign
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
                Am.IsDisabled AS IsDisabled
            FROM dbo.SeenClientAnswerMaster AS Am WITH (NOLOCK)
                INNER JOIN dbo.Establishment AS E WITH (NOLOCK)
                    ON Am.EstablishmentId = E.Id
                INNER JOIN dbo.EstablishmentGroup AS Eg WITH (NOLOCK)
                    ON E.EstablishmentGroupId = Eg.Id
                INNER JOIN dbo.AppUser AS U WITH (NOLOCK)
                    ON Am.AppUserId = U.Id
            WHERE Am.IsDeleted = 0
                  AND (
                          (
                              ContactMasterId = @Id
                              AND @IsGroup = 0
                          )
                          OR (
                                 ContactGroupId = @Id
                                 AND @IsGroup = 1
                             )
                      )
                  AND Am.EstablishmentId IN (
                                                SELECT EST.Id
                                                FROM dbo.Establishment AS EST WITH (NOLOCK)
                                                WHERE EST.EstablishmentGroupId = @ActivityId
                                            )
                  AND Am.Id = @AnswerMasterId
            ORDER BY Am.CreatedOn DESC
        ) AS R
            INNER JOIN dbo.SeenClientAnswers AS A WITH (NOLOCK)
                ON A.SeenClientAnswerMasterId = R.ReportId
            INNER JOIN dbo.SeenClientQuestions AS SQ WITH (NOLOCK)
                ON A.QuestionId = SQ.Id
                   AND R.SeenClientId = SQ.SeenClientId
        WHERE A.IsDeleted = 0
              AND SQ.IsDeleted = 0
              AND IsDisplayInDetail = 1
              AND SQ.ContactQuestionId IS NULL
    ) i
    ORDER BY i.Position;
	END TRY

BEGIN CATCH
	INSERT INTO dbo.ErrorLog
        (
            PageId,
            MethodName,
            ErrorType,
            ErrorMessage,
            ErrorDetails,
            ErrorDate,
            UserId,
            Solution,
            CreatedOn,
            CreatedBy
        )
        VALUES
        (ERROR_LINE(),
         'dbo.WsGetSeenClientOutDataForMobiForm',
         N'DATABASE',
         ERROR_MESSAGE(),
         ('ERROR_NUMBER=' + CONVERT(VARCHAR(100), ERROR_NUMBER()) + ',ERROR_STATE='
          + CONVERT(VARCHAR(20), ERROR_STATE()) + ',ERROR_SEVERITY=' + CONVERT(VARCHAR(20), ERROR_SEVERITY())
         )  ,
         GETUTCDATE(),
         ISNULL(@AppUserId,0),
         @AnswerMasterId+','+@AppUserId,
         GETUTCDATE(),
         ISNULL(@AppUserId,0)
        );
END CATCH
    SET NOCOUNT OFF;
END;
