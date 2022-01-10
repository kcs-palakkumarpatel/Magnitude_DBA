﻿-- =============================================  
-- Author:      
-- Create date: 25-Sep-2017  
-- Description: Get In/Out Form Data Details in Action List Page.  
-- Call SP:   WSGetReportDetailsById 72965, 1  
-- =============================================  
CREATE PROCEDURE dbo.WSGetReportDetailsById_OriginalbeforePositionChange
    @ReportId BIGINT,
    @IsOut BIT
AS
BEGIN

    DECLARE @Url NVARCHAR(100),
            @GraphicImagePath NVARCHAR(100);

    --SELECT  @GraphicImagePath = KeyValue + 'UploadFiles/'  
    --FROM    dbo.AAAAConfigSettings  
    --WHERE   KeyName = 'DocViewerRootFolderPath';  

    SELECT @GraphicImagePath = KeyValue
    FROM dbo.AAAAConfigSettings
    WHERE KeyName = 'DocViewerRootFolderPathCMS';


    DECLARE @TempTable TABLE
    (
        Id BIGINT,
        QuestionTitle NVARCHAR(MAX),
        ShortName NVARCHAR(MAX),
        QuestionTypeId BIGINT,
        RepetitiveGroupCount INT,
        RepetitiveGroupNo INT,
        RepetitiveGroupName VARCHAR(100),
        Detail NVARCHAR(MAX),
        Url NVARCHAR(MAX),
        ThumbnilUrl NVARCHAR(MAX),
        QuestionId BIGINT,
        CaptureDate NVARCHAR(80),
        IsDeleted BIT,
        ImageHeight NVARCHAR(100),
        ImageWidth NVARCHAR(100),
        ImageAlign NVARCHAR(100),
		IsSignature bit
    );

    IF @IsOut = 0
    BEGIN
        --SELECT  @Url = KeyValue + 'UploadFiles/'  
        --FROM    dbo.AAAAConfigSettings  
        --WHERE   KeyName = 'WebAppUrl';  

        SELECT @Url = KeyValue
        FROM dbo.AAAAConfigSettings
        WHERE KeyName = 'DocViewerRootFolderPathWebApp';

        INSERT INTO @TempTable
        (
            Id,
            QuestionTitle,
            ShortName,
            QuestionTypeId,
            RepetitiveGroupCount,
            RepetitiveGroupNo,
            RepetitiveGroupName,
            Detail,
            Url,
            ThumbnilUrl,
            QuestionId,
            CaptureDate,
            IsDeleted,
            ImageHeight,
            ImageWidth,
            ImageAlign,
			IsSignature
        )
        SELECT Q.Id,
               Q.QuestionTitle,
               Q.ShortName,
               Q.QuestionTypeId,
               ISNULL(A.RepeatCount, 0),
               ISNULL(A.RepetitiveGroupId, 0),
               ISNULL(A.RepetitiveGroupName, ''),
               CASE Q.QuestionTypeId
                   WHEN 8 THEN
                       dbo.ChangeDateFormat(Detail, 'dd/MMM/yyyy')
                   WHEN 9 THEN
                       dbo.ChangeDateFormat(Detail, 'hh:mm AM/PM')
                   WHEN 22 THEN
                       dbo.ChangeDateFormat(Detail, 'dd/MMM/yyyy hh:mm AM/PM')
                   WHEN 1 THEN
                       dbo.GetOptionNameByQuestionId(A.QuestionId, A.Detail, @IsOut)
                   WHEN 23 THEN
                       Q.ImagePath
                   ELSE
                       ISNULL(Detail, '')
               END AS Detail,
               CASE Q.QuestionTypeId
                   WHEN 23 THEN
                       @GraphicImagePath + 'Questions/'
                   ELSE
                       @Url + 'Feedback/'
               END AS Url,
               CASE Q.QuestionTypeId
                   WHEN 23 THEN
                       @GraphicImagePath + 'Questions/'
                   ELSE
                       @Url + 'Feedback/'
               END AS ThumbnilUrl,
               Q.Id AS QuestionId,
               dbo.ChangeDateFormat(DATEADD(MINUTE, Am.TimeOffSet, Am.CreatedOn), 'dd/MMM/yyyy HH:mm AM/PM') AS CaptureDate,
               Am.IsDisabled,
               Q.ImageHeight,
               Q.ImageWidth,
               Q.ImageAlign,
			   Q.IsSignature
        FROM dbo.AnswerMaster AS Am
            INNER JOIN dbo.Questionnaire AS Qr
                ON Am.QuestionnaireId = Qr.Id
            INNER JOIN dbo.Questions AS Q
                ON Qr.Id = Q.QuestionnaireId
            LEFT OUTER JOIN dbo.Answers AS A
                ON Am.Id = A.AnswerMasterId
                   AND Q.Id = A.QuestionId
        WHERE Am.Id = @ReportId
              AND Q.IsDisplayInDetail = 1
              AND Q.QuestionTypeId NOT IN ( 25 )
              AND (
                      A.Id IS NOT NULL
                      OR (
                             Q.QuestionTypeId IN ( 16, 23 )
                             AND Q.IsDeleted = 0
                         )
                  )
        ORDER BY Position;

        ------------------------------------------------------------------------------------------------------------------  
        DECLARE @shortName NVARCHAR(MAX);
        DECLARE @Possition BIGINT;
        DECLARE @Questionnierid BIGINT;
        DECLARE @QuestionId BIGINT;
        DECLARE @QuestionTitle NVARCHAR(MAX);
        DECLARE @Start BIGINT = 1,
                @End BIGINT;

        SELECT @Questionnierid = QuestionnaireId
        FROM dbo.AnswerMaster
        WHERE Id = @ReportId;

        DECLARE @Reftable TABLE
        (
            Id BIGINT IDENTITY(1, 1),
            SeenclientQuestionId BIGINT,
            QuestionId BIGINT,
            possition BIGINT,
            shortName NVARCHAR(MAX),
            QuestionTitle NVARCHAR(MAX),
            QuestionTypeId BIGINT
        );
        INSERT @Reftable
        (
            SeenclientQuestionId,
            QuestionId,
            possition,
            shortName,
            QuestionTitle,
            QuestionTypeId
        )
        SELECT SeenClientQuestionIdRef,
               Id,
               Position,
               ShortName,
               QuestionTitle,
               QuestionTypeId
        FROM dbo.Questions
        WHERE QuestionnaireId = @Questionnierid
              AND SeenClientQuestionIdRef IS NOT NULL
              AND IsDisplayInDetail = 1 --- Add by Sunil For Bug 0000069891  
              AND IsDeleted = 0
              AND IsActive = 0;
        SET @Start = 1;
        SELECT @End = COUNT(*)
        FROM @Reftable;
        WHILE (@Start <= @End)
        BEGIN
            SELECT @QuestionId = QuestionId,
                   @shortName = shortName,
                   @Possition = possition,
                   @QuestionTitle = QuestionTitle
            FROM @Reftable
            WHERE Id = @Start;
            INSERT INTO @TempTable
            (
                Id,
                QuestionTitle,
                ShortName,
                QuestionTypeId,
                RepetitiveGroupCount,
                RepetitiveGroupNo,
                RepetitiveGroupName,
                Detail,
                Url,
                QuestionId,
                CaptureDate,
                IsDeleted
            )
            SELECT QuestionId,
                   @QuestionTitle,
                   @shortName,
                   QuestionTypeId,
                   0,
                   0,
                   '',
                   Detail,
                   '',
                   QuestionId,
                   dbo.ChangeDateFormat(GETUTCDATE(), 'dd/MMM/yyyy HH:mm AM/PM') AS CaptureDate,
                   0
            FROM dbo.SeenClientAnswers
            WHERE SeenClientAnswerMasterId IN (
                                                  SELECT SeenClientAnswerMasterId FROM dbo.AnswerMaster WHERE Id = @ReportId
                                              )
                  AND (
                          (ISNULL(SeenClientAnswerChildId, 0) = 0)
                          OR SeenClientAnswerChildId IN (
                                                            SELECT SeenClientAnswerChildId FROM dbo.AnswerMaster WHERE Id = @ReportId
                                                        )
                      )
                  AND QuestionId =
                  (
                      SELECT SeenclientQuestionId FROM @Reftable WHERE Id = @Start
                  );
            SET @Start = @Start + 1;
        END;
    ------------------------------------------------------------------------------------------------------------------------  
    END;
    ELSE
    BEGIN
        --SELECT  @Url = KeyValue + 'UploadFiles/'  
        --FROM    dbo.AAAAConfigSettings  
        --WHERE   KeyName = 'WebAppUrl';  

        SELECT @Url = KeyValue
        FROM dbo.AAAAConfigSettings
        WHERE KeyName = 'DocViewerRootFolderPathWebApp';

        INSERT INTO @TempTable
        (
            Id,
            QuestionTitle,
            ShortName,
            QuestionTypeId,
            RepetitiveGroupCount,
            RepetitiveGroupNo,
            RepetitiveGroupName,
            Detail,
            Url,
            ThumbnilUrl,
            QuestionId,
            CaptureDate,
            IsDeleted,
            ImageHeight,
            ImageWidth,
            ImageAlign,
			IsSignature
        )
        SELECT i.Id,
               i.QuestionTitle,
               i.ShortName,
               i.QuestionTypeId,
               i.RepetitiveGroupCount,
               i.RepetitiveGroupNo,
               i.RepetitiveGroupName,
               i.Detail,
               i.Url,
               i.ThumbnailUrl,
               i.QuestionId,
               i.CaptureDate,
               i.IsDeleted,
               i.ImageHeight,
               i.ImageWidth,
               i.ImageAlign,
			   i.IsSignature
        FROM
        (
            SELECT Q.Id,
                   Q.QuestionTitle,
                   Q.ShortName,
                   Q.QuestionTypeId,
                   CASE Q.QuestionTypeId
                       WHEN 8 THEN
                           dbo.ChangeDateFormat(Detail, 'dd/MMM/yyyy')
                       WHEN 9 THEN
                           dbo.ChangeDateFormat(Detail, 'hh:mm AM/PM')
                       WHEN 22 THEN
                           dbo.ChangeDateFormat(Detail, 'dd/MMM/yyyy hh:mm AM/PM')
                       WHEN 1 THEN
                           dbo.GetOptionNameByQuestionId(A.QuestionId, A.Detail, @IsOut)
                       WHEN 23 THEN
                           Q.ImagePath
                       ELSE
                           ISNULL(A.Detail, '')
                   END AS Detail,
                   CASE Q.QuestionTypeId
                       WHEN 23 THEN
                           @GraphicImagePath + 'SeenClientQuestions/'
                       ELSE
                           @Url + 'SeenClient/'
                   END AS Url,
                   CASE Q.QuestionTypeId
                       WHEN 23 THEN
                           @GraphicImagePath + 'SeenClientQuestions/'
                       ELSE
                           @Url + 'Thumbnail/'
                   END AS ThumbnailUrl,
                   Q.Id AS QuestionId,
                   dbo.ChangeDateFormat(DATEADD(MINUTE, Am.TimeOffSet, Am.CreatedOn), 'dd/MMM/yyyy HH:mm AM/PM') AS CaptureDate,
                   Am.IsDeleted,
                   Q.Position,
                   ISNULL(A.RepeatCount, 0) AS RepetitiveGroupCount,
                   ISNULL(A.RepetitiveGroupId, 0) AS RepetitiveGroupNo,
                   ISNULL(A.RepetitiveGroupName, '') AS RepetitiveGroupName,
                   Q.ImageHeight,
                   Q.ImageWidth,
                   Q.ImageAlign,
				   Q.IsSignature
            FROM dbo.SeenClientAnswerMaster AS Am
                INNER JOIN dbo.SeenClient AS Qr
                    ON Am.SeenClientId = Qr.Id
                INNER JOIN dbo.SeenClientQuestions AS Q
                    ON Qr.Id = Q.SeenClientId
                LEFT OUTER JOIN dbo.SeenClientAnswers AS A
                    ON Am.Id = A.SeenClientAnswerMasterId
                       AND Q.Id = A.QuestionId
            WHERE Am.Id = @ReportId
                  AND IsDisplayInDetail = 1
                  AND Q.QuestionTypeId NOT IN ( 25 )
                  AND (
                          A.Id IS NOT NULL
                          OR (
                                 Q.QuestionTypeId IN ( 16, 23 )
                                 AND Q.IsDeleted = 0
                             )
                      )
                  AND Q.ContactQuestionId IS NULL
        ) i
        GROUP BY i.Position,
                 i.Id,
                 i.QuestionTitle,
                 i.ShortName,
                 i.QuestionTypeId,
                 i.RepetitiveGroupCount,
                 i.RepetitiveGroupNo,
                 i.RepetitiveGroupName,
                 i.Detail,
                 i.Url,
                 i.ThumbnailUrl,
                 i.QuestionId,
                 i.CaptureDate,
                 i.IsDeleted,
                 i.ImageHeight,
                 i.ImageWidth,
                 i.ImageAlign,
				 i.IsSignature
        ORDER BY i.Position;

    END;

END;
SELECT ISNULL(Id, 0) AS Id,
       ISNULL(QuestionId, 0) AS QuestionId,
       ISNULL(QuestionTitle, '') AS QuestionTitle,
       ISNULL(ShortName, '') AS ShortName,
       ISNULL(QuestionTypeId, 0) AS QuestionTypeId,
       ISNULL(RepetitiveGroupCount, 0) AS RepetitiveGroupCount,
       ISNULL(RepetitiveGroupNo, 0) AS RepetitiveGroupNo,
       ISNULL(RepetitiveGroupName, '') AS RepetitiveGroupName,
       ISNULL(REPLACE(Detail, ',', ', '), '') AS Detail,
       ISNULL(Url, '') AS Url,
       ISNULL(ThumbnilUrl, '') AS ThumbnilUrl,
       ISNULL(CaptureDate, '') AS CaptureDate,
       ISNULL(IsDeleted, 0) AS IsDeleted,
       ImageHeight AS ImageHeight,
       ImageWidth AS ImageWidth,
       ImageAlign AS ImageAlign,
	   ISNULL(IsSignature,0) AS IsSignature
FROM @TempTable;
