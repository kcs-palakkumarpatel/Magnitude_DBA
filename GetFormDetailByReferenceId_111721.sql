
-- =============================================
-- Author:			D3
-- Create date:	22-Dec-2017
-- Description:	Get In/Out Form Data Details in Feedback detail Page.
-- Call SP:	GetFormDetailByReferenceId 60722,0
-- Call SP:	GetFormDetailByReferenceId 979401,1
-- =============================================
CREATE PROCEDURE [dbo].[GetFormDetailByReferenceId_111721]
    @ReportId BIGINT,
    @IsOut BIT
AS
BEGIN
    --SET @ReportId = 160153;
    --SET @IsOut = 0;
    --SET @ReportId = 363759;
    --SET @IsOut = 1;

    DECLARE @Url NVARCHAR(100),
            @GraphicImagePath NVARCHAR(100),
            @ThumbnailUrl NVARCHAR(100);

    SELECT @GraphicImagePath = KeyValue
    FROM dbo.AAAAConfigSettings
    WHERE KeyName = 'DocViewerRootFolderPathCMS';


    --SELECT  @GraphicImagePath = KeyValue + 'UploadFiles/'
    --   FROM    dbo.AAAAConfigSettings
    --   WHERE   KeyName = 'DocViewerRootFolderPath';

    DECLARE @TempTable TABLE
    (
        QuestionPosition INT,
        QuestionChildPosition INT,
        QuestionId BIGINT,
        QuestionTitle NVARCHAR(MAX),
        ShortName NVARCHAR(MAX),
        QuestionTypeId BIGINT,
        RepetitiveGroupCount INT,
        RepetitiveGroupNo INT,
        RepetitiveGroupName VARCHAR(500),
        Detail VARCHAR(MAX),
        Url VARCHAR(MAX),
        ThumbnailUrl VARCHAR(MAX),
        CaptureDate NVARCHAR(80),
        IsDeleted BIT,
        ImageHeight NVARCHAR(100),
        ImageWidth NVARCHAR(100),
        ImageAlign NVARCHAR(100),
        IsSignature BIT,
        IsRepetitive BIT,
        IsDisplayInSummary BIT,
        ItemType INT,
		IsSingleSelect BIT
    );

    IF @IsOut = 0
    BEGIN
        PRINT '1';
        SELECT @Url = KeyValue,
               @ThumbnailUrl = KeyValue + N'Thumbnail/'
        FROM dbo.AAAAConfigSettings
        WHERE KeyName = 'DocViewerRootFolderPathWebApp';

        INSERT INTO @TempTable
        (
            QuestionPosition,
            QuestionChildPosition,
            QuestionId,
            QuestionTitle,
            ShortName,
            QuestionTypeId,
            RepetitiveGroupCount,
            RepetitiveGroupNo,
            RepetitiveGroupName,
            Detail,
            Url,
            ThumbnailUrl,
            CaptureDate,
            IsDeleted,
            ImageHeight,
            ImageWidth,
            ImageAlign,
            IsSignature,
            IsRepetitive,
            IsDisplayInSummary,
            ItemType,
			IsSingleSelect
        )
        SELECT Q.Position,
               Q.ChildPosition,
               Q.Id,
               Q.QuestionTitle,
               Q.ShortName,
               Q.QuestionTypeId,
               ISNULL(A.RepeatCount, 0),
               ISNULL(A.RepetitiveGroupId, 0),
               ISNULL(A.RepetitiveGroupName, ''),
               CASE Q.QuestionTypeId
                   WHEN 8 THEN
                       dbo.ChangeDateFormat(Detail, 'dd/MMM/yy')
                   WHEN 9 THEN
                       dbo.ChangeDateFormat(Detail, 'HH:mm')
                   WHEN 22 THEN
                       dbo.ChangeDateFormat(Detail, 'dd/MMM/yy HH:mm')
                   WHEN 1 THEN
                       dbo.GetOptionNameByQuestionId(A.QuestionId, A.Detail, @IsOut)
                   WHEN 23 THEN
                       Q.ImagePath
                   WHEN 17 THEN
                       CASE
                           WHEN Q.SeenClientQuestionIdRef IS NULL THEN
                               dbo.GetRefernceQuestionImagePath(Detail, 0, 0)
                           ELSE
                               dbo.GetRefernceQuestionImagePath(Detail, 1, 0)
                       END
                   -- dbo.GetRefernceQuestionImagePath(Detail, 0)
                   --CASE Q.SeenClientQuestionIdRef WHEN NULL THEN 
                   --dbo.GetRefernceQuestionImagePath(Detail, 0)
                   --ELSE
                   --   ISNULL(Detail, '')
                   --END
                   ELSE
                       ISNULL(Detail, '')
               END AS Detail,
               CASE Q.QuestionTypeId
                   WHEN 23 THEN
                       @GraphicImagePath + 'Questions/'
                   ELSE
                       @Url + 'Feedback/'
               END AS Url,
               @ThumbnailUrl AS ThumbnailUrl,
               dbo.ChangeDateFormat(DATEADD(MINUTE, Am.TimeOffSet, Am.CreatedOn), 'dd/MMM/yy HH:mm AM/PM') AS CaptureDate,
               Am.IsDisabled,
               Q.ImageHeight,
               Q.ImageWidth,
               Q.ImageAlign,
               Q.IsSignature,
               Q.IsRepetitive,
               Q.IsDisplayInSummary,
                 (CASE
                    WHEN Q.QuestionTypeId IN ( 1, 2, 5, 6, 18, 21, 7, 14, 15 ) THEN
                    (
                        SELECT dbo.IsQuestionnaireQuestionPositive(Am.Id, Q.Id, A.Id)
                    )
                    ELSE
                        0
                END
               ) AS ItemType,
			   ISNULL(Q.IsSingleSelect,0) AS IsSingleSelect
        FROM dbo.AnswerMaster AS Am
            INNER JOIN dbo.Questionnaire AS Qr
                ON Am.QuestionnaireId = Qr.Id
            INNER JOIN dbo.Questions AS Q
                ON Qr.Id = Q.QuestionnaireId
            INNER JOIN dbo.Answers AS A
                ON Am.Id = A.AnswerMasterId
                   AND Q.Id = A.QuestionId
        WHERE Am.Id = @ReportId
              AND Q.IsDisplayInDetail = 1
              AND Q.QuestionTypeId NOT IN ( 25 )
              AND
              (
                  A.Id IS NOT NULL
                  OR
                  (
                      Q.QuestionTypeId IN ( 16, 23 )
                      AND Q.IsDeleted = 0
                  )
              )
        ORDER BY A.RepetitiveGroupId,
                 A.RepeatCount,
                 Q.Position,
                 Q.ChildPosition;
        ------------------------------------------------------------------------------------------------------------------
        DECLARE @shortName NVARCHAR(MAX);
        DECLARE @Possition BIGINT;
        DECLARE @Questionnierid BIGINT;
        DECLARE @QuestionId BIGINT;
        DECLARE @QuestionTitle NVARCHAR(MAX);
        DECLARE @Start BIGINT = 1,
                @End BIGINT;
        DECLARE @IsSignature BIT;

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
            QuestionTypeId BIGINT,
            IsSignature BIT
        );
        INSERT @Reftable
        (
            SeenclientQuestionId,
            QuestionId,
            possition,
            shortName,
            QuestionTitle,
            QuestionTypeId,
            IsSignature
        )
        SELECT SeenClientQuestionIdRef,
               Id,
               Position,
               ShortName,
               QuestionTitle,
               QuestionTypeId,
               IsSignature
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
                   @QuestionTitle = QuestionTitle,
                   @IsSignature = IsSignature
            FROM @Reftable
            WHERE Id = @Start;

            INSERT INTO @TempTable
            (
                QuestionPosition,
                QuestionChildPosition,
                QuestionId,
                QuestionTitle,
                ShortName,
                QuestionTypeId,
                RepetitiveGroupCount,
                RepetitiveGroupNo,
                RepetitiveGroupName,
                Detail,
                Url,
                ThumbnailUrl,
                CaptureDate,
                IsDeleted,
                IsSignature,
                IsRepetitive,
                IsDisplayInSummary,
                ItemType,
				IsSingleSelect
            )
            SELECT 0,
                   0,
                   QuestionId,
                   @QuestionTitle,
                   @shortName,
                   QuestionTypeId,
                   0,
                   0,
                   '',
                   CASE QuestionTypeId
                       WHEN 17 THEN
                           dbo.GetRefernceQuestionImagePath(Detail, 1, 0)
                       ELSE
                           Detail
                   END AS Detail,
                   '',
                   '',
                   dbo.ChangeDateFormat(GETUTCDATE(), 'dd/MMM/yy HH:mm AM/PM') AS CaptureDate,
                   0,
                   @IsSignature,
                   0,
                   1,
                   0,
				   0
            FROM dbo.SeenClientAnswers
            WHERE SeenClientAnswerMasterId IN
                  (
                      SELECT SeenClientAnswerMasterId FROM dbo.AnswerMaster WHERE Id = @ReportId
                  )
                  AND
                  (
                      (ISNULL(SeenClientAnswerChildId, 0) = 0)
                      OR SeenClientAnswerChildId IN
                         (
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
        SELECT @Url = KeyValue,
               @ThumbnailUrl = KeyValue + N'Thumbnail/'
        FROM dbo.AAAAConfigSettings
        WHERE KeyName = 'DocViewerRootFolderPathWebApp';


        --SELECT  @Url = KeyValue + 'UploadFiles/' ,
        --               @ThumbnailUrl = KeyValue + 'UploadFiles/Thumbnail/'
        --       FROM    dbo.AAAAConfigSettings
        --       WHERE   KeyName = 'WebAppUrl';

        INSERT INTO @TempTable
        (
            QuestionPosition,
            QuestionChildPosition,
            QuestionId,
            QuestionTitle,
            ShortName,
            QuestionTypeId,
            RepetitiveGroupCount,
            RepetitiveGroupNo,
            RepetitiveGroupName,
            Detail,
            Url,
            ThumbnailUrl,
            CaptureDate,
            IsDeleted,
            ImageHeight,
            ImageWidth,
            ImageAlign,
            IsSignature,
            IsRepetitive,
            IsDisplayInSummary,
            ItemType,
			IsSingleSelect
        )
        SELECT i.Position,
               i.ChildPosition,
               i.QuestionId,
               i.QuestionTitle,
               i.ShortName,
               i.QuestionTypeId,
               i.RepetitiveGroupCount,
               i.RepetitiveGroupNo,
               i.RepetitiveGroupName,
               i.Detail,
               i.URL,
               i.ThumbnailUrl,
               i.CaptureDate,
               i.IsDisabled,
               i.ImageHeight,
               i.ImageWidth,
               i.ImageAlign,
               i.IsSignature,
               i.IsRepetitive,
               i.IsDisplayInSummary,
               i.ItemType,
			   i.IsSingleSelect
        FROM
        (
            SELECT Q.Id,
                   Q.QuestionTitle,
                   Q.ShortName,
                   Q.QuestionTypeId,
                   CASE Q.QuestionTypeId
                       WHEN 8 THEN
                           dbo.ChangeDateFormat(Detail, 'dd/MMM/yy')
                       WHEN 9 THEN
                           dbo.ChangeDateFormat(Detail, 'HH:mm')
                       WHEN 22 THEN
                           dbo.ChangeDateFormat(Detail, 'dd/MMM/yy HH:mm')
                       WHEN 1 THEN
                           dbo.GetOptionNameByQuestionId(A.QuestionId, A.Detail, @IsOut)
                       WHEN 23 THEN
                           Q.ImagePath
                       WHEN 17 THEN
                           dbo.GetRefernceQuestionImagePath(Detail, 1, 0)
                       ELSE
                           ISNULL(A.Detail, '')
                   END AS Detail,
                   CASE Q.QuestionTypeId
                       WHEN 23 THEN
                           @GraphicImagePath + 'SeenClientQuestions/'
                       ELSE
                           @Url + 'SeenClient/'
                   END AS URL,
                   @ThumbnailUrl AS ThumbnailUrl,
                   Q.Id AS QuestionId,
                   dbo.ChangeDateFormat(DATEADD(MINUTE, Am.TimeOffSet, Am.CreatedOn), 'dd/MMM/yy HH:mm AM/PM') AS CaptureDate,
                   Am.IsDisabled,
                   Q.ImageHeight,
                   Q.ImageWidth,
                   Q.ImageAlign,
                   Q.IsSignature,
                   Q.IsRepetitive,
                   Q.Position,
                   Q.ChildPosition,
                   ISNULL(A.RepeatCount, 0) AS RepetitiveGroupCount,
                   ISNULL(A.RepetitiveGroupId, 0) AS RepetitiveGroupNo,
                   ISNULL(A.RepetitiveGroupName, '') AS RepetitiveGroupName,
                   Q.IsDisplayInSummary,
                     (CASE
                    WHEN Q.QuestionTypeId IN ( 1, 2, 5, 6, 18, 21, 7, 14, 15 ) THEN
                    (
                        SELECT dbo.IsQuestionnaireQuestionPositive(Am.Id, Q.Id, A.Id)
                    )
                    ELSE
                        0
                END
               ) AS ItemType,
				   ISNULL(Q.IsSingleSelect,0) AS IsSingleSelect
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
                  AND
                  (
                      A.Id IS NOT NULL
                      OR
                      (
                          Q.QuestionTypeId IN ( 16, 23 )
                          AND Q.IsDeleted = 0
                      )
                  )
                  AND Q.ContactQuestionId IS NULL
        ) i
        GROUP BY i.Position,
                 i.ChildPosition,
                 i.Id,
                 i.QuestionTitle,
                 i.ShortName,
                 i.QuestionTypeId,
                 i.RepetitiveGroupCount,
                 i.RepetitiveGroupNo,
                 i.RepetitiveGroupName,
                 i.Detail,
                 i.URL,
                 i.ThumbnailUrl,
                 i.QuestionId,
                 i.CaptureDate,
                 i.IsDisabled,
                 i.ImageHeight,
                 i.ImageWidth,
                 i.ImageAlign,
                 i.IsSignature,
                 i.IsRepetitive,
                 i.IsDisplayInSummary,
                 i.ItemType,
				 i.IsSingleSelect;
    END;
END;


SELECT ISNULL(QuestionPosition, 0) AS QuestionPosition,
       ISNULL(QuestionChildPosition, 0) AS QuestionChildPosition,
       ISNULL(QuestionId, 0) AS QuestionId,
       ISNULL(QuestionTitle, '') AS QuestionTitle,
       ISNULL(ShortName, '') AS ShortName,
       ISNULL(QuestionTypeId, 0) AS QuestionTypeId,
       ISNULL(RepetitiveGroupCount, 0) AS RepetitiveGroupCount,
       ISNULL(RepetitiveGroupNo, 0) AS RepetitiveGroupNo,
       ISNULL(RepetitiveGroupName, '') AS RepetitiveGroupName,
       ISNULL(Detail, '') AS Detail,
       ISNULL(Url, '') AS URL,
       ISNULL(ThumbnailUrl, '') AS ThumbnailUrl,
       ISNULL(CaptureDate, '') AS CaptureDate,
       ISNULL(IsDeleted, 0) AS IsDeleted,
       ISNULL(ImageHeight, '') AS ImageHeight,
       ISNULL(ImageWidth, '') AS ImageWidth,
       ISNULL(ImageAlign, '') AS ImageAlign,
       ISNULL(IsSignature, 0) AS IsSignature,
       ISNULL(IsRepetitive, 0) AS IsRepetitive,
       ISNULL(IsDisplayInSummary, 0) AS IsDisplayInSummary,
       ISNULL(ItemType, 0) AS ItemType,
	   ISNULL(IsSingleSelect,0) AS IsSingleSelect
FROM @TempTable
ORDER BY QuestionPosition,
         QuestionChildPosition;

