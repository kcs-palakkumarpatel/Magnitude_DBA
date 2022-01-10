-- =============================================
-- Author:			Sunil Vaghasiya
-- Create date:	27-Apr-2017
-- Description:	Get Copy Capture Form Details
--Call:	dbo.GetSeenClientQuestionsAnswer 111957, 1682, 31722, 0, '' 
-- =============================================
CREATE PROCEDURE [dbo].[GetSeenClientQuestionsAnswer_new]
    @SeenClientAnswerMasterId BIGINT,
    @SeenClientId BIGINT,
    @ContactMasterId BIGINT,
    @IsContactGroup BIT,
    @ContactMasterIdList NVARCHAR(2000)
AS
BEGIN
    DECLARE @Url NVARCHAR(150);
    DECLARE @ContactDetails NVARCHAR(MAX);

    SELECT @Url = KeyValue + 'SeenClientQuestions/'
    FROM dbo.AAAAConfigSettings
    WHERE KeyName = 'DocViewerRootFolderPathCMS';

    --  SELECT  @Url = KeyValue + 'UploadFiles/SeenClientQuestions/'
    --FROM    dbo.AAAAConfigSettings
    --WHERE   KeyName = 'DocViewerRootFolderPath';

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
           ImageAlign
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
               Q.EscalationRegex,
               ISNULL(Q.ContactQuestionId, 0) AS ContactQuestionId,
               CASE
                   WHEN @IsContactGroup = 0 THEN
                       CASE
                           WHEN Q.ContactQuestionId IS NOT NULL THEN
                           (
						    ISNULL((SELECT TOP 1 Detail FROM dbo.SeenClientAnswers WHERE SeenClientAnswerMasterId = AM.Id AND QuestionId = Q.Id),(SELECT Detail FROM dbo.ContactDetails WHERE ContactQuestionId = Q.ContactQuestionId AND ContactMasterId = @ContactMasterId))
                               
                           )
                           ELSE
                               ISNULL((SELECT TOP 1 Detail FROM dbo.SeenClientAnswers WHERE SeenClientAnswerMasterId = AM.Id AND QuestionId = Q.Id),'')
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
               Q.ImageAlign
        FROM dbo.SeenClientQuestions AS Q
            INNER JOIN dbo.SeenClientAnswerMaster AS AM
                ON AM.SeenClientId = Q.SeenClientId
        WHERE AM.Id = @SeenClientAnswerMasterId
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
            Q.EscalationRegex,
            ISNULL(Q.ContactQuestionId, 0) AS ContactQuestionId,
            CASE
                WHEN @IsContactGroup = 0 THEN
                    CASE
                        WHEN Q.ContactQuestionId IS NOT NULL THEN
                        (
                            SELECT Detail
                            FROM dbo.ContactDetails
                            WHERE ContactQuestionId = Q.ContactQuestionId
                                  AND ContactMasterId = @ContactMasterId
                        )
                        ELSE
                            ISNULL(SCA.Detail, '')
                    END
                ELSE
                    CASE
                        WHEN Q.ContactQuestionId IS NOT NULL THEN
                            CASE
                                WHEN Q.QuestionTypeId IN ( 4, 10, 11 ) THEN
            (dbo.ConcateString3Param('ContactGroupDetail', @ContactMasterId, Q.ContactQuestionId, @ContactMasterIdList))
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
            Q.ImageAlign
        FROM dbo.SeenClientQuestions AS Q
            INNER JOIN dbo.SeenClientAnswerMaster AS AM
                ON AM.SeenClientId = Q.SeenClientId
            INNER JOIN dbo.SeenClientAnswers AS SCA
                ON SCA.SeenClientAnswerMasterId = AM.Id
                   AND SCA.QuestionId = Q.Id
        WHERE AM.Id = @SeenClientAnswerMasterId
              AND Q.SeenClientId = @SeenClientId
              AND IsDisplayInDetail = 1
              AND Q.IsDeleted = 0
              AND Q.IsActive = 1
              AND ISNULL(SCA.RepetitiveGroupId, 0) > 0
    ) AS CD
    ORDER BY CD.Position ASC;
END;
