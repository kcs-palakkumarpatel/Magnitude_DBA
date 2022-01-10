-- =============================================
-- Author:		Krishna Panchal
-- Create date: 13-11-2020
-- Description:	Get all active questions by questionnaire id for mobi form 363617
-- Call SP    :		dbo.GetMobiFormForMobile 4329,0,0,0,'2020-01-01 00:00:00.00'
-- =============================================

CREATE PROCEDURE [dbo].[GetMobiFormForMobile]
(
    @QuestionnaireId BIGINT,
    @SeenClientAnswerMasterId BIGINT,
    @SeenClientAnswerChildId BIGINT,
    @AnswerMasterId BIGINT = 0,
    @LastServerDate DATETIME = '1970-01-01 00:00:00.00'
)
AS
BEGIN
    --DECLARE @blIsIntroductoryMessage BIT;
    IF @QuestionnaireId = 0
       AND @SeenClientAnswerMasterId > 0
    BEGIN
        SELECT @QuestionnaireId = QuestionnaireId
        FROM dbo.SeenClientAnswerMaster AS SAM
            INNER JOIN dbo.Establishment AS E
                ON SAM.EstablishmentId = E.Id
            INNER JOIN dbo.EstablishmentGroup AS Eg
                ON E.EstablishmentGroupId = Eg.Id
        WHERE SAM.Id = @SeenClientAnswerMasterId;
    END;

    DECLARE @Url NVARCHAR(150);
    SELECT @Url = KeyValue + N'Questions/'
    FROM dbo.AAAAConfigSettings
    WHERE KeyName = 'DocViewerRootFolderPathCMS';

    SELECT Q.Id AS Id,
           Q.QuestionnaireId AS QuestionnaireId,
           Q.Position AS Position,
           Q.ChildPosition AS ChildPosition,
           Q.QuestionTypeId AS QuestionTypeId,
           Q.QuestionTitle AS QuestionTitle,
           Q.ShortName AS ShortName,
           Q.IsActive AS IsActive,
           Q.[Required] AS Required,
           Q.IsDisplayInSummary AS IsDisplayInSummary,
           Q.IsDisplayInDetail AS IsDisplayInDetail,
           Q.[MaxLength] AS MaxLength,
           ISNULL(Q.Hint, '') AS Hint,
           Q.EscalationRegex AS EscalationRegex,
           ISNULL(Q.OptionsDisplayType, '') AS OptionsDisplayType,
           Q.SeenClientQuestionIdRef AS SeenClientQuestionIdRef,
           Q.IsTitleBold,
           Q.IsTitleItalic,
           Q.IsTitleUnderline,
           Q.TitleTextColor,
           Q.FontSize,
           Q.Margin,
           ISNULL(SQ.QuestionTitle, '') AS SeenClientQuestionTitle,
           ISNULL(SA.Detail, ISNULL(A.Detail, '')) AS Detail,
           ISNULL(SQ.Id, 0) AS SeenClientQuestionId,
           ISNULL(@Url + Q.ImagePath, '') AS ImagePath,
           Q.IsCommentCompulsory AS IsCommentCompulsory,
           Q.IsAnonymous AS IsAnonymous,
           ISNULL(Q.IsDecimal, 0) AS IsDecimal,
           ISNULL(Q.IsSignature, 0) AS IsSignature,
           ISNULL(Q.IsRepetitive, 0) AS IsRepetitive,
           ISNULL(Q.QuestionsGroupNo, 0) AS RepetitiveGroupNo,
           ISNULL(Q.QuestionsGroupName, '') AS RepetitiveGroupName,
           Q.ImageHeight AS ImageHeight,
           Q.ImageWidth AS ImageWidth,
           Q.ImageAlign AS ImageAlign,
           Q.CalculationOptions AS CalculationOptions,
           Q.SummaryOption AS SummaryOption,
           ISNULL(Q.IsDefaultDisplay, 0) AS [IsDefaultDisplay],
           ISNULL(QUE.ControlStyleId, 1) AS [ControlStyleId],
           ISNULL(CS.ControlStyleName, 'Advance') AS [ControlStyleName],
           ISNULL(Q.IsRoutingOnGroup, 0) AS IsRoutingOnGroup,
           ISNULL(Q.IsValidateUsingQR, 0) AS isQRType,
           (CASE
                WHEN ISNULL(Q.DeletedOn, '') <> '' THEN
                    3 -- Deleted
                WHEN ISNULL(Q.UpdatedOn, '') <> '' THEN
                    2 -- Updated
                ELSE
                    1 --Added
            END
           ) AS [Action]
    FROM dbo.[Questions] AS Q
        LEFT OUTER JOIN dbo.SeenClientQuestions AS SQ
            ON Q.SeenClientQuestionIdRef = SQ.Id
        LEFT OUTER JOIN dbo.SeenClientAnswers AS SA
            ON SQ.Id = SA.QuestionId
               AND SA.SeenClientAnswerMasterId = @SeenClientAnswerMasterId
               AND
               (
                   @SeenClientAnswerChildId = 0
                   OR SA.SeenClientAnswerChildId = @SeenClientAnswerChildId
               )
        LEFT JOIN dbo.Questionnaire [QUE]
            ON Q.QuestionnaireId = QUE.Id
        LEFT JOIN dbo.ControlStyle [CS]
            ON QUE.ControlStyleId = CS.Id
        LEFT OUTER JOIN dbo.Answers AS A
            ON A.QuestionId = Q.Id
               AND A.AnswerMasterId = @AnswerMasterId
    WHERE (
              ISNULL(Q.IsDeleted,0) = 0
              OR @LastServerDate <> '1970-01-01 00:00:00.00'
          )
          AND Q.IsActive = 1
          AND Q.QuestionnaireId = @QuestionnaireId
          AND
          (
              ISNULL(Q.UpdatedOn, Q.CreatedOn) >= @LastServerDate
              OR ISNULL(Q.DeletedOn, '') >= @LastServerDate
          )
    ORDER BY Q.Position ASC;
END;
