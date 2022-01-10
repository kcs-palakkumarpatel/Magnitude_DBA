
-- =============================================
-- Author:			Sunil Vaghasiya
-- Create date:	26-Apr-2017
-- Description:	<Description,,>
-- Call SP:			dbo.WsGetSeenClientInData 521,313, 1, 919
-- =============================================
CREATE PROCEDURE [dbo].[WsGetSeenClientInData]
    @Id BIGINT,
    @AppUserId BIGINT,
    @IsGroup BIT,
    @ActivityId BIGINT
AS
BEGIN
    SET NOCOUNT ON;
	SET DEADLOCK_PRIORITY NORMAL;
	
	BEGIN TRY
    DECLARE @Url NVARCHAR(100),
            @GraphicImagePath NVARCHAR(100),
            @ThumbnilUrl NVARCHAR(100);

    SELECT @Url = KeyValue + N'Feedback/'
    FROM dbo.AAAAConfigSettings
    WHERE KeyName = 'DocViewerRootFolderPathWebApp';

    SELECT @ThumbnilUrl = KeyValue + N'Thumbnail/'
    FROM dbo.AAAAConfigSettings
    WHERE KeyName = 'DocViewerRootFolderPathWebApp';

    SELECT @GraphicImagePath = KeyValue + N'Questions/'
    FROM dbo.AAAAConfigSettings
    WHERE KeyName = 'DocViewerRootFolderPathCMS';


    --    SELECT  @Url = KeyValue + 'UploadFiles/Feedback/'
    --      FROM    dbo.AAAAConfigSettings
    --      WHERE   KeyName = 'WebAppUrl';

    --SELECT  @ThumbnilUrl = KeyValue + 'UploadFiles/Thumbnail/'
    --      FROM    dbo.AAAAConfigSettings
    --      WHERE   KeyName = 'WebAppUrl';

    --      SELECT  @GraphicImagePath = KeyValue + 'UploadFiles/Questions/'
    --      FROM    dbo.AAAAConfigSettings
    --      WHERE   KeyName = 'DocViewerRootFolderPath';

    DECLARE @PIDispaly VARCHAR(5) = '0';
    IF (
       (
           SELECT COUNT(1)
           FROM dbo.Questions WITH
               (NOLOCK)
           WHERE QuestionTypeId IN ( 1, 5, 6, 7, 18, 21 )
                 AND QuestionnaireId =
                 (
                     SELECT QuestionnaireId
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

    SELECT R.ReportId,
           R.EstablishmentId,
           R.QuestionnaireId,
           R.AppUserId,
           R.Latitude,
           R.Longitude,
           R.EI,
           R.IsPositive,
           R.CaptureDate,
           R.EstablishmentGroupName,
           A.QuestionId,
           Q.ShortName AS QuestionTitle,
           Q.IsDisplayInDetail,
           A.QuestionTypeId,
           CASE Q.QuestionTypeId
               WHEN 8 THEN
                   dbo.ChangeDateFormat(Detail, 'dd/MMM/yyyy')
               WHEN 9 THEN
                   dbo.ChangeDateFormat(Detail, 'hh:mm AM/PM')
               WHEN 22 THEN
                   dbo.ChangeDateFormat(Detail, 'dd/MMM/yyyy hh:mm AM/PM')
               WHEN 1 THEN
                   dbo.GetOptionNameByQuestionId(A.QuestionId, A.Detail, 0)
               WHEN 23 THEN
                   Q.ImagePath
               ELSE
                   ISNULL(A.Detail, '')
           END AS Detail,
           CASE Q.QuestionTypeId
               WHEN 23 THEN
                   @GraphicImagePath
               ELSE
                   @Url
           END AS Url,
           CASE Q.QuestionTypeId
               WHEN 23 THEN
                   @GraphicImagePath
               ELSE
                   @ThumbnilUrl
           END AS ThumbnilUrl,
           R.IsTransferred,
           R.AnswerStatus,
           R.IsActioned,
           R.TransferToUser,
           R.TransferFromUser,
           ISNULL(A.RepeatCount, 0) AS RepetitiveGroupCount,
           ISNULL(A.RepetitiveGroupId, 0) AS RepetitiveGroupNo,
           ISNULL(A.RepetitiveGroupName, '') AS RepetitiveGroupName,
           R.IsDisabled,
           ISNULL(Q.IsSignature, 0) AS IsSignature
    FROM
    (
        SELECT TOP 1
               Am.Id AS ReportId,
               Am.EstablishmentId,
               Am.QuestionnaireId,
               Am.AppUserId,
               Am.Latitude,
               Am.Longitude,
               --Am.PI AS EI,
               IIF(@PIDispaly = 1, Am.[PI], IIF(Am.[PI] > 0.00, Am.[PI], -1)) AS EI,
               Am.IsPositive,
               dbo.ChangeDateFormat(DATEADD(MINUTE, Am.TimeOffSet, Am.CreatedOn), 'dd/MMM/yyyy hh:mm AM/PM') AS CaptureDate,
               DATEADD(MINUTE, Am.TimeOffSet, Am.CreatedOn) AS CreatedOn,
               Eg.EstablishmentGroupName,
               Q.QuestionnaireTitle,
               Am.IsTransferred,
               Am.IsResolved AS AnswerStatus,
               Am.IsActioned,
               ISNULL(U.Name, '') AS TransferToUser,
               ISNULL(TransferFromUser.Name, '') AS TransferFromUser,
               Am.IsDisabled AS IsDisabled
        FROM dbo.AnswerMaster AS Am WITH
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
            INNER JOIN dbo.Questionnaire AS Q WITH
            (NOLOCK)
                ON Am.QuestionnaireId = Q.Id
            INNER JOIN dbo.SeenClientAnswerMaster AS SeenClientAM WITH
            (NOLOCK)
                ON Am.SeenClientAnswerMasterId = SeenClientAM.Id
            LEFT OUTER JOIN dbo.AnswerMaster AS TransferFromAM WITH
            (NOLOCK)
                ON TransferFromAM.Id = Am.AnswerMasterId
            LEFT OUTER JOIN dbo.AppUser AS TransferFromUser WITH
            (NOLOCK)
                ON TransferFromAM.AppUserId = TransferFromUser.Id
        WHERE Am.IsDeleted = 0
              AND
              (
                  (
                      SeenClientAM.ContactMasterId = @Id
                      AND @IsGroup = 0
                  )
                  OR
                  (
                      SeenClientAM.ContactGroupId = @Id
                      AND @IsGroup = 1
                  )
              )
              AND Am.EstablishmentId IN
                  (
                      SELECT EST.Id
                      FROM dbo.Establishment AS EST WITH
                          (NOLOCK)
                      WHERE EST.EstablishmentGroupId = @ActivityId
                  )
              AND Am.CreatedBy = @AppUserId
        ORDER BY Am.CreatedOn DESC
    ) AS R
        INNER JOIN dbo.Answers AS A WITH
        (NOLOCK)
            ON A.AnswerMasterId = R.ReportId
        INNER JOIN dbo.Questions AS Q WITH
        (NOLOCK)
            ON R.QuestionnaireId = Q.QuestionnaireId
               AND A.QuestionId = Q.Id
    WHERE A.IsDeleted = 0
          AND Q.IsDeleted = 0
          AND Q.IsDisplayInDetail = 1
    ORDER BY Q.Position;
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
         'dbo.WsGetSeenClientInData',
         N'DATABASE',
         ERROR_MESSAGE(),
         ('ERROR_NUMBER=' + CONVERT(VARCHAR(100), ERROR_NUMBER()) + ',ERROR_STATE='
          + CONVERT(VARCHAR(20), ERROR_STATE()) + ',ERROR_SEVERITY=' + CONVERT(VARCHAR(20), ERROR_SEVERITY())
         )  ,
         GETUTCDATE(),
         ISNULL(@AppUserId,0),
         @Id+','+@AppUserId+','+@IsGroup+','+@ActivityId,
         GETUTCDATE(),
         ISNULL(@AppUserId,0)
        );
END CATCH
END;
