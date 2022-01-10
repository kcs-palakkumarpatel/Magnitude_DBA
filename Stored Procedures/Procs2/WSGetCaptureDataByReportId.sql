-- =============================================
-- Author:		Vasudev Patel
-- Create date: 28 Dec 2016
-- Description:	Get Capture data by reported id
-- Call: WSGetCaptureDataByReportId 34833
-- =============================================
CREATE PROCEDURE dbo.WSGetCaptureDataByReportId
    -- Add the parameters for the stored procedure here
    @ReportId BIGINT
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN
     DECLARE @Url NVARCHAR(100),
                @GraphicImagePath NVARCHAR(100);

        SELECT @GraphicImagePath = KeyValue
        FROM dbo.AAAAConfigSettings WITH (NOLOCK)
        WHERE KeyName = 'DocViewerRootFolderPathCMS';

        DECLARE @TempTable TABLE
        (
            Id BIGINT,
            QuestionTitle NVARCHAR(MAX),
            ShortName NVARCHAR(MAX),
            QuestionTypeId BIGINT,
            Detail NVARCHAR(MAX),
            Url NVARCHAR(MAX),
            QuestionId BIGINT,
            CaptureDate NVARCHAR(80),
            IsDeleted BIT
        );

        SELECT @Url = KeyValue
        FROM dbo.AAAAConfigSettings
        WHERE KeyName = 'DocViewerRootFolderPathWebApp';

        INSERT INTO @TempTable
        (
            Id,
            QuestionTitle,
            ShortName,
            QuestionTypeId,
            Detail,
            Url,
            QuestionId,
            CaptureDate,
            IsDeleted
        )
        SELECT i.Id,
               i.QuestionTitle,
               i.ShortName,
               i.QuestionTypeId,
               i.Detail,
               i.Url,
               i.QuestionId,
               i.CaptureDate,
               i.IsDeleted
        FROM
        (
            SELECT Q.Id,
                   Q.QuestionTitle,
                   Q.ShortName,
                   Q.QuestionTypeId,
                   CASE Q.QuestionTypeId
                       WHEN 8 THEN
                           dbo.ChangeDateFormat(Detail, 'yyyy-MM-dd HH:mm:ss')
                       WHEN 9 THEN
                           dbo.ChangeDateFormat(Detail, 'yyyy-MM-dd HH:mm:ss')
                       WHEN 22 THEN
                           dbo.ChangeDateFormat(Detail, 'yyyy-MM-dd HH:mm:ss')
                       WHEN 1 THEN
                           dbo.GetOptionNameByQuestionId(A.QuestionId, A.Detail, 1)
                       WHEN 23 THEN
                           Q.ImagePath
                       ELSE
                           ISNULL(A.Detail, '')
                   END AS Detail,
                   @Url + 'SeenClient/' AS Url,
                   Q.Id AS QuestionId,
                   dbo.ChangeDateFormat(DATEADD(MINUTE, Am.TimeOffSet, Am.CreatedOn), 'MM/dd/yyyy HH:mm AM/PM') AS CaptureDate,
                   Am.IsDeleted,
                   Q.Position
            FROM dbo.SeenClientAnswerMaster AS Am WITH (NOLOCK)
                INNER JOIN dbo.SeenClient AS Qr WITH (NOLOCK)
                    ON Am.SeenClientId = Qr.Id
                INNER JOIN dbo.SeenClientQuestions AS Q WITH (NOLOCK)
                    ON Qr.Id = Q.SeenClientId
                LEFT OUTER JOIN dbo.SeenClientAnswers AS A WITH (NOLOCK)
                    ON Am.Id = A.SeenClientAnswerMasterId
                       AND Q.Id = A.QuestionId
            WHERE Am.Id = @ReportId
                  --AND IsDisplayInDetail = 1
                  AND Q.IsActive = 1
                  AND Q.IsRepetitive = 0
                  AND (
                          A.Id IS NOT NULL
                          OR ( -- Q.QuestionTypeId IN ( 16, 23 )
                          --AND 
                          Q.IsDeleted = 0
                             )
                      )
        --AND Q.ContactQuestionId IS NULL
        ) i
        GROUP BY i.Position,
                 i.Id,
                 i.QuestionTitle,
                 i.ShortName,
                 i.QuestionTypeId,
                 i.Detail,
                 i.Url,
                 i.QuestionId,
                 i.CaptureDate,
                 i.IsDeleted
        ORDER BY i.Position;

        SELECT QuestionTitle,
               QuestionTypeId,
               CASE QuestionTypeId
                   WHEN 19 THEN
                       Detail  --IOS In Decimal number space issue solve - Anant bhatt
                   ELSE
                       REPLACE(Detail, ',', ', ')
               END Detail,
               Url,
               QuestionId
        FROM @TempTable;
    END;
END;
