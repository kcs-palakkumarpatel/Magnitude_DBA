-- =============================================
-- Author:			Sunil Vaghasiya
-- Create date:	27-Apr-2017
-- Description:	Get Copy Capture Form Details
--Call:	dbo.GetSeenClientQuestionsAnswer 364064, 605, 226282, 0, '1',0,0
-- =============================================
CREATE PROCEDURE [dbo].[GetSeenClientQuestionsAnswer]
    @SeenClientAnswerMasterId BIGINT,
    @SeenClientId BIGINT,
    @ContactMasterId BIGINT,
    @IsContactGroup BIT,
    @ContactMasterIdList NVARCHAR(2000),
    @IsCopyCapture INT,
    @AutoSaveReportId BIGINT
AS
BEGIN
    DECLARE @Url NVARCHAR(150);

    SELECT @Url = KeyValue + 'SeenClientQuestions/'
    FROM dbo.AAAAConfigSettings
    WHERE KeyName = 'DocViewerRootFolderPathCMS';
    IF (@IsCopyCapture = 1 OR @IsCopyCapture = 2)
    BEGIN
        PRINT '1';
        SELECT QuestionId,
               QuestionTypeId,
               QuestionTitle,
               ShortName,
               [Required],
               [MaxLength],
               Hint,
               OptionsDisplayType,
               IsTitleBold,
               IsTitleItalic,
               IsTitleUnderline,
               TitleTextColor,
               Position,
               ChildPosition,
               EscalationRegex,
               ContactQuestionId,
               Answer,
               Margin,
               FontSize,
               ImagePath,
               DisplayInDetail,
               DisplayInList,
               IsCommentCompulsory,
               IsDecimal,
               IsSignature,
               RepetitiveGroupCount,
               RepetitiveGroupNo,
               RepetitiveGroupName,
               ImageHeight,
               ImageWidth,
               ImageAlign,
               IsRepetitive,
               TenderQuestionType,
               IsSingleSelect,
               AllowArithmeticOperation,
               Formula
        FROM
        (
            SELECT Q.Id AS QuestionId,
                   Q.QuestionTypeId,
                   Q.QuestionTitle,
                   Q.ShortName,
                   Q.[Required],
                   Q.[MaxLength],
                   ISNULL(Hint, '') AS Hint,
                   ISNULL(OptionsDisplayType, '') AS OptionsDisplayType,
                   Q.IsTitleBold,
                   Q.IsTitleItalic,
                   Q.IsTitleUnderline,
                   Q.TitleTextColor,
                   Q.Position,
                   Q.ChildPosition,
                   Q.EscalationRegex,
                   ISNULL(Q.ContactQuestionId, 0) AS ContactQuestionId,
                   CASE
                       WHEN @IsContactGroup = 0 THEN
                           CASE
                               WHEN Q.ContactQuestionId IS NOT NULL THEN
                   (CASE
                        WHEN ISNULL(
                             (
                                 SELECT TOP 1
                                     Detail
                                 FROM dbo.SeenClientAnswers
                                 WHERE SeenClientAnswerMasterId = AM.Id
                                       AND QuestionId = Q.Id
                             ),
                             ''
                                   ) IS NOT NULL THEN
                        (
                            SELECT TOP 1
                                Detail
                            FROM dbo.SeenClientAnswers
                            WHERE SeenClientAnswerMasterId = AM.Id
                                  AND QuestionId = Q.Id
                        )
                        ELSE
                    (
                        SELECT Detail
                        FROM dbo.ContactDetails
                        WHERE ContactQuestionId = Q.ContactQuestionId
                              AND ContactMasterId = @ContactMasterId
                    )
                    END
                   )
                               ELSE
                                   ISNULL(
                                   (
                                       SELECT TOP 1
                                           Detail
                                       FROM dbo.SeenClientAnswers
                                       WHERE SeenClientAnswerMasterId = AM.Id
                                             AND QuestionId = Q.Id
                                   ),
                                   ''
                                         )
                           END
                       ELSE
                           CASE
                               WHEN Q.ContactQuestionId IS NOT NULL THEN
                   (CASE
                        WHEN ISNULL(
                             (
                                 SELECT TOP 1
                                     Detail
                                 FROM dbo.SeenClientAnswers
                                 WHERE SeenClientAnswerMasterId = AM.Id
                                       AND QuestionId = Q.Id
                             ),
                             ''
                                   ) IS NOT NULL THEN
                        (
                            SELECT TOP 1
                                Detail
                            FROM dbo.SeenClientAnswers
                            WHERE SeenClientAnswerMasterId = AM.Id
                                  AND QuestionId = Q.Id
                        )
                        ELSE
                   (CASE
                        WHEN Q.QuestionTypeId IN ( 4, 10, 11 ) THEN
                   (dbo.ConcateString3Param(
                                               'ContactGroupDetail',
                                               @ContactMasterId,
                                               Q.ContactQuestionId,
                                               @ContactMasterIdList
                                           )
                   )
                        ELSE
                    (
                        SELECT TOP 1
                            Detail
                        FROM dbo.ContactDetails
                        WHERE ContactQuestionId = Q.ContactQuestionId
                              AND ContactMasterId IN (
                                                         SELECT TOP 1 Data FROM dbo.Split(@ContactMasterIdList, ',')
                                                     )
                    )
                    END
                   )
                    END
                   )
                               ELSE
                                   ISNULL(
                                   (
                                       SELECT TOP 1
                                           Detail
                                       FROM dbo.SeenClientAnswers
                                       WHERE SeenClientAnswerMasterId = AM.Id
                                             AND QuestionId = Q.Id
                                   ),
                                   ''
                                         )
                           END
                   END AS Answer,
                   0 AS RepetitiveGroupCount,
                   0 AS RepetitiveGroupNo,
                   '' AS RepetitiveGroupName,
                   Q.Margin,
                   Q.FontSize,
                   ISNULL(@Url + ImagePath, '') AS ImagePath,
                   Q.IsDisplayInDetail AS DisplayInDetail,
                   Q.IsDisplayInSummary AS DisplayInList,
                   Q.IsCommentCompulsory AS IsCommentCompulsory,
                   Q.IsDecimal,
                   Q.IsSignature,
                   Q.ImageHeight,
                   Q.ImageWidth,
                   Q.ImageAlign,
                   Q.IsRepetitive,
                   (CASE
                        WHEN Q.TenderQuestionType = 1 THEN
                            'ReleasedDate'
                        WHEN Q.TenderQuestionType = 2 THEN
                            'MobiExpiryDate'
                        WHEN Q.TenderQuestionType = 3 THEN
                            'GrayOutDate'
                        WHEN Q.TenderQuestionType = 4 THEN
                            'ReminderDate'
                        ELSE
                            ''
                    END
                   ) AS TenderQuestionType,
                   ISNULL(Q.IsSingleSelect, 0) AS IsSingleSelect,
                   ISNULL(Q.AllowArithmeticOperation, 0) AS AllowArithmeticOperation,
                   ISNULL(qc.Formula, '') AS Formula
            FROM dbo.SeenClientQuestions AS Q
                INNER JOIN dbo.SeenClientAnswerMaster AS AM
                    ON AM.SeenClientId = Q.SeenClientId
                LEFT JOIN dbo.QuestionCalculationItem qc
                    ON qc.QuestionId = Q.Id
                       AND qc.IsCapture = 1
                       AND qc.IsDeleted = 0
            WHERE AM.Id = @SeenClientAnswerMasterId
                  AND Q.SeenClientId = @SeenClientId
                  -- AND IsDisplayInDetail = 1
                  AND Q.IsDeleted = 0
                  AND Q.IsActive = 1
                  AND ISNULL(Q.IsRepetitive, 0) = 0
            UNION ALL
            SELECT DISTINCT
                Q.Id AS QuestionId,
                Q.QuestionTypeId,
                Q.QuestionTitle,
                Q.ShortName,
                Q.[Required],
                Q.[MaxLength],
                ISNULL(Hint, '') AS Hint,
                ISNULL(OptionsDisplayType, '') AS OptionsDisplayType,
                Q.IsTitleBold,
                Q.IsTitleItalic,
                Q.IsTitleUnderline,
                Q.TitleTextColor,
                Q.Position,
                Q.ChildPosition,
                Q.EscalationRegex,
                ISNULL(Q.ContactQuestionId, 0) AS ContactQuestionId,
                CASE
                    WHEN @IsContactGroup = 0 THEN
                        CASE
                            WHEN Q.ContactQuestionId IS NOT NULL THEN
                (CASE
                     WHEN ISNULL(
                          (
                              SELECT TOP 1
                                  Detail
                              FROM dbo.SeenClientAnswers
                              WHERE SeenClientAnswerMasterId = AM.Id
                                    AND QuestionId = Q.Id
                          ),
                          ''
                                ) IS NOT NULL THEN
                     (
                         SELECT TOP 1
                             Detail
                         FROM dbo.SeenClientAnswers
                         WHERE SeenClientAnswerMasterId = AM.Id
                               AND QuestionId = Q.Id
                     )
                     ELSE
                 (
                     SELECT Detail
                     FROM dbo.ContactDetails
                     WHERE ContactQuestionId = Q.ContactQuestionId
                           AND ContactMasterId = @ContactMasterId
                 )
                 END
                )
                            ELSE
                                ISNULL(SCA.Detail, '')
                        END
                    ELSE
                        CASE
                            WHEN Q.ContactQuestionId IS NOT NULL THEN
                                CASE
                                    WHEN Q.QuestionTypeId IN ( 4, 10, 11 ) THEN
                (dbo.ConcateString3Param(
                                            'ContactGroupDetail',
                                            @ContactMasterId,
                                            Q.ContactQuestionId,
                                            @ContactMasterIdList
                                        )
                )
                                    ELSE
                                (
                                    SELECT TOP 1
                                        Detail
                                    FROM dbo.ContactDetails
                                    WHERE ContactQuestionId = Q.ContactQuestionId
                                          AND ContactMasterId IN (
                                                                     SELECT TOP 1 Data FROM dbo.Split(
                                                                                                         @ContactMasterIdList,
                                                                                                         ','
                                                                                                     )
                                                                 )
                                )
                                END
                            ELSE
                                ISNULL(SCA.Detail, '')
                        END
                END AS Answer,
                ISNULL(SCA.RepeatCount, 0) AS RepetitiveGroupCount,
                ISNULL(SCA.RepetitiveGroupId, 0) AS RepetitiveGroupNo,
                ISNULL(SCA.RepetitiveGroupName, '') AS RepetitiveGroupName,
                Q.Margin,
                Q.FontSize,
                ISNULL(@Url + ImagePath, '') AS ImagePath,
                Q.IsDisplayInDetail AS DisplayInDetail,
                Q.IsDisplayInSummary AS DisplayInList,
                Q.IsCommentCompulsory AS IsCommentCompulsory,
                Q.IsDecimal,
                Q.IsSignature,
                Q.ImageHeight,
                Q.ImageWidth,
                Q.ImageAlign,
                Q.IsRepetitive,
                (CASE
                     WHEN Q.TenderQuestionType = 1 THEN
                         'ReleasedDate'
                     WHEN Q.TenderQuestionType = 2 THEN
                         'MobiExpiryDate'
                     WHEN Q.TenderQuestionType = 3 THEN
                         'GrayOutDate'
                     WHEN Q.TenderQuestionType = 4 THEN
                         'ReminderDate'
                     ELSE
                         ''
                 END
                ) AS TenderQuestionType,
                ISNULL(Q.IsSingleSelect, 0) AS IsSingleSelect,
                ISNULL(Q.AllowArithmeticOperation, 0) AS AllowArithmeticOperation,
                ISNULL(qc.Formula, '') AS Formula
            FROM dbo.SeenClientQuestions AS Q
                INNER JOIN dbo.SeenClientAnswerMaster AS AM
                    ON AM.SeenClientId = Q.SeenClientId
                INNER JOIN dbo.SeenClientAnswers AS SCA
                    ON SCA.SeenClientAnswerMasterId = AM.Id
                       AND SCA.QuestionId = Q.Id
                LEFT JOIN dbo.QuestionCalculationItem qc
                    ON qc.QuestionId = Q.Id
                       AND qc.IsCapture = 1
                       AND qc.IsDeleted = 0
            WHERE AM.Id = @SeenClientAnswerMasterId
                  AND Q.SeenClientId = @SeenClientId
                  --  AND IsDisplayInDetail = 1
                  AND Q.IsDeleted = 0
                  AND Q.IsActive = 1
                  AND ISNULL(SCA.RepetitiveGroupId, 0) > 0
        ) AS CD
        ORDER BY CD.Position,
                 CD.ChildPosition ASC;
    END;
    ELSE
    BEGIN
        PRINT '0';
        SELECT QuestionId,
               QuestionTypeId,
               QuestionTitle,
               ShortName,
               [Required],
               [MaxLength],
               Hint,
               OptionsDisplayType,
               IsTitleBold,
               IsTitleItalic,
               IsTitleUnderline,
               TitleTextColor,
               Position,
               ChildPosition,
               EscalationRegex,
               ContactQuestionId,
               Answer,
               Margin,
               FontSize,
               ImagePath,
               DisplayInDetail,
               DisplayInList,
               IsCommentCompulsory,
               IsDecimal,
               IsSignature,
               RepetitiveGroupCount,
               RepetitiveGroupNo,
               RepetitiveGroupName,
               ImageHeight,
               ImageWidth,
               ImageAlign,
               IsRepetitive,
               TenderQuestionType,
               IsSingleSelect,
               AllowArithmeticOperation,
               Formula
        FROM
        (
            SELECT Q.Id AS QuestionId,
                   Q.QuestionTypeId,
                   Q.QuestionTitle,
                   Q.ShortName,
                   Q.[Required],
                   Q.[MaxLength],
                   ISNULL(Hint, '') AS Hint,
                   ISNULL(OptionsDisplayType, '') AS OptionsDisplayType,
                   Q.IsTitleBold,
                   Q.IsTitleItalic,
                   Q.IsTitleUnderline,
                   Q.TitleTextColor,
                   Q.Position,
                   Q.ChildPosition,
                   Q.EscalationRegex,
                   ISNULL(Q.ContactQuestionId, 0) AS ContactQuestionId,
                   CASE
                       WHEN @IsContactGroup = 0 THEN
                           CASE
                               WHEN Q.ContactQuestionId IS NOT NULL THEN
                   (CASE
                        WHEN ISNULL(
                             (
                                 SELECT TOP 1
                                     Detail
                                 FROM dbo.SeenClientAnswersTemp
                                 WHERE SeenClientAnswerMasterId = AM.Id
                                       AND QuestionId = Q.Id
                             ),
                             ''
                                   ) IS NOT NULL THEN
                        (
                            SELECT TOP 1
                                Detail
                            FROM dbo.SeenClientAnswersTemp
                            WHERE SeenClientAnswerMasterId = AM.Id
                                  AND QuestionId = Q.Id
                        )
                        ELSE
                    (
                        SELECT Detail
                        FROM dbo.ContactDetails
                        WHERE ContactQuestionId = Q.ContactQuestionId
                              AND ContactMasterId = @ContactMasterId
                    )
                    END
                   )
                               ELSE
                                   ISNULL(
                                   (
                                       SELECT TOP 1
                                           Detail
                                       FROM dbo.SeenClientAnswersTemp
                                       WHERE SeenClientAnswerMasterId = AM.Id
                                             AND QuestionId = Q.Id
                                   ),
                                   ''
                                         )
                           END
                       ELSE
                           CASE
                               WHEN Q.ContactQuestionId IS NOT NULL THEN
                   (CASE
                        WHEN ISNULL(
                             (
                                 SELECT TOP 1
                                     Detail
                                 FROM dbo.SeenClientAnswersTemp
                                 WHERE SeenClientAnswerMasterId = AM.Id
                                       AND QuestionId = Q.Id
                             ),
                             ''
                                   ) IS NOT NULL THEN
                        (
                            SELECT TOP 1
                                Detail
                            FROM dbo.SeenClientAnswersTemp
                            WHERE SeenClientAnswerMasterId = AM.Id
                                  AND QuestionId = Q.Id
                        )
                        ELSE
                   (CASE
                        WHEN Q.QuestionTypeId IN ( 4, 10, 11 ) THEN
                   (dbo.ConcateString3Param(
                                               'ContactGroupDetail',
                                               @ContactMasterId,
                                               Q.ContactQuestionId,
                                               @ContactMasterIdList
                                           )
                   )
                        ELSE
                    (
                        SELECT TOP 1
                            Detail
                        FROM dbo.ContactDetails
                        WHERE ContactQuestionId = Q.ContactQuestionId
                              AND ContactMasterId IN (
                                                         SELECT TOP 1 Data FROM dbo.Split(@ContactMasterIdList, ',')
                                                     )
                    )
                    END
                   )
                    END
                   )
                               ELSE
                                   ISNULL(
                                   (
                                       SELECT TOP 1
                                           Detail
                                       FROM dbo.SeenClientAnswersTemp
                                       WHERE SeenClientAnswerMasterId = AM.Id
                                             AND QuestionId = Q.Id
                                   ),
                                   ''
                                         )
                           END
                   END AS Answer,
                   0 AS RepetitiveGroupCount,
                   0 AS RepetitiveGroupNo,
                   '' AS RepetitiveGroupName,
                   Q.Margin,
                   Q.FontSize,
                   ISNULL(@Url + ImagePath, '') AS ImagePath,
                   Q.IsDisplayInDetail AS DisplayInDetail,
                   Q.IsDisplayInSummary AS DisplayInList,
                   Q.IsCommentCompulsory AS IsCommentCompulsory,
                   Q.IsDecimal,
                   Q.IsSignature,
                   Q.ImageHeight,
                   Q.ImageWidth,
                   Q.ImageAlign,
                   Q.IsRepetitive,
                   (CASE
                        WHEN Q.TenderQuestionType = 1 THEN
                            'ReleasedDate'
                        WHEN Q.TenderQuestionType = 2 THEN
                            'MobiExpiryDate'
                        WHEN Q.TenderQuestionType = 3 THEN
                            'GrayOutDate'
                        WHEN Q.TenderQuestionType = 4 THEN
                            'ReminderDate'
                        ELSE
                            ''
                    END
                   ) AS TenderQuestionType,
                   ISNULL(Q.IsSingleSelect, 0) AS IsSingleSelect,
                   ISNULL(Q.AllowArithmeticOperation, 0) AS AllowArithmeticOperation,
                   ISNULL(qc.Formula, '') AS Formula
            FROM dbo.SeenClientQuestions AS Q
                INNER JOIN dbo.SeenClientAnswerMasterTemp AS AM
                    ON AM.SeenClientId = Q.SeenClientId
                LEFT JOIN dbo.QuestionCalculationItem qc
                    ON qc.QuestionId = Q.Id
                       AND qc.IsCapture = 1
                       AND qc.IsDeleted = 0
            WHERE AM.Id = @AutoSaveReportId
                  AND Q.SeenClientId = @SeenClientId
                  AND IsDisplayInDetail = 1
                  AND Q.IsDeleted = 0
                  AND Q.IsActive = 1
                  AND ISNULL(Q.IsRepetitive, 0) = 0
            UNION ALL
            SELECT DISTINCT
                Q.Id AS QuestionId,
                Q.QuestionTypeId,
                Q.QuestionTitle,
                Q.ShortName,
                Q.[Required],
                Q.[MaxLength],
                ISNULL(Hint, '') AS Hint,
                ISNULL(OptionsDisplayType, '') AS OptionsDisplayType,
                Q.IsTitleBold,
                Q.IsTitleItalic,
                Q.IsTitleUnderline,
                Q.TitleTextColor,
                Q.Position,
                Q.ChildPosition,
                Q.EscalationRegex,
                ISNULL(Q.ContactQuestionId, 0) AS ContactQuestionId,
                CASE
                    WHEN @IsContactGroup = 0 THEN
                        CASE
                            WHEN Q.ContactQuestionId IS NOT NULL THEN
                (CASE
                     WHEN ISNULL(
                          (
                              SELECT TOP 1
                                  Detail
                              FROM dbo.SeenClientAnswers
                              WHERE SeenClientAnswerMasterId = AM.Id
                                    AND QuestionId = Q.Id
                          ),
                          ''
                                ) IS NOT NULL THEN
                     (
                         SELECT TOP 1
                             Detail
                         FROM dbo.SeenClientAnswers
                         WHERE SeenClientAnswerMasterId = AM.Id
                               AND QuestionId = Q.Id
                     )
                     ELSE
                 (
                     SELECT Detail
                     FROM dbo.ContactDetails
                     WHERE ContactQuestionId = Q.ContactQuestionId
                           AND ContactMasterId = @ContactMasterId
                 )
                 END
                )
                            ELSE
                                ISNULL(SCA.Detail, '')
                        END
                    ELSE
                        CASE
                            WHEN Q.ContactQuestionId IS NOT NULL THEN
                                CASE
                                    WHEN Q.QuestionTypeId IN ( 4, 10, 11 ) THEN
                (dbo.ConcateString3Param(
                                            'ContactGroupDetail',
                                            @ContactMasterId,
                                            Q.ContactQuestionId,
                                            @ContactMasterIdList
                                        )
                )
                                    ELSE
                                (
                                    SELECT TOP 1
                                        Detail
                                    FROM dbo.ContactDetails
                                    WHERE ContactQuestionId = Q.ContactQuestionId
                                          AND ContactMasterId IN (
                                                                     SELECT TOP 1 Data FROM dbo.Split(
                                                                                                         @ContactMasterIdList,
                                                                                                         ','
                                                                                                     )
                                                                 )
                                )
                                END
                            ELSE
                                ISNULL(SCA.Detail, '')
                        END
                END AS Answer,
                ISNULL(SCA.RepeatCount, 0) AS RepetitiveGroupCount,
                ISNULL(SCA.RepetitiveGroupId, 0) AS RepetitiveGroupNo,
                ISNULL(SCA.RepetitiveGroupName, '') AS RepetitiveGroupName,
                Q.Margin,
                Q.FontSize,
                ISNULL(@Url + ImagePath, '') AS ImagePath,
                Q.IsDisplayInDetail AS DisplayInDetail,
                Q.IsDisplayInSummary AS DisplayInList,
                Q.IsCommentCompulsory AS IsCommentCompulsory,
                Q.IsDecimal,
                Q.IsSignature,
                Q.ImageHeight,
                Q.ImageWidth,
                Q.ImageAlign,
                Q.IsRepetitive,
                (CASE
                     WHEN Q.TenderQuestionType = 1 THEN
                         'ReleasedDate'
                     WHEN Q.TenderQuestionType = 2 THEN
                         'MobiExpiryDate'
                     WHEN Q.TenderQuestionType = 3 THEN
                         'GrayOutDate'
                     WHEN Q.TenderQuestionType = 4 THEN
                         'ReminderDate'
                     ELSE
                         ''
                 END
                ) AS TenderQuestionType,
                ISNULL(Q.IsSingleSelect, 0) AS IsSingleSelect,
                ISNULL(Q.AllowArithmeticOperation, 0) AS AllowArithmeticOperation,
                ISNULL(qc.Formula, '') AS Formula
            FROM dbo.SeenClientQuestions AS Q
                INNER JOIN dbo.SeenClientAnswerMasterTemp AS AM
                    ON AM.SeenClientId = Q.SeenClientId
                INNER JOIN dbo.SeenClientAnswersTemp AS SCA
                    ON SCA.SeenClientAnswerMasterId = AM.Id
                       AND SCA.QuestionId = Q.Id
                LEFT JOIN dbo.QuestionCalculationItem qc
                    ON qc.QuestionId = Q.Id
                       AND qc.IsCapture = 1
                       AND qc.IsDeleted = 0
            WHERE AM.Id = @AutoSaveReportId
                  AND Q.SeenClientId = @SeenClientId
                  --AND IsDisplayInDetail = 1
                  AND Q.IsDeleted = 0
                  AND Q.IsActive = 1
                  AND ISNULL(SCA.RepetitiveGroupId, 0) > 0
        ) AS CD
        ORDER BY CD.Position,
                 CD.ChildPosition ASC;
    END;
END;
