
-- =============================================
-- Author:			Sunil Vaghasiya
-- Create date:	24-Apr-2017
-- Description:	Get all active questions by questionnaire id for mobi form 363617
-- Call SP    :		dbo.GetMobiForm 978,363950,0,10
-- =============================================
CREATE PROCEDURE [dbo].[GetMobiForm]
(
    @QuestionnaireId BIGINT,
    @SeenClientAnswerMasterId BIGINT,
    @SeenClientAnswerChildId BIGINT,
    @AnswerMasterId BIGINT = 0
)
AS
BEGIN
    SET NOCOUNT ON;
	SET DEADLOCK_PRIORITY NORMAL;
	
	BEGIN TRY
    DECLARE @blIsIntroductoryMessage BIT;
    IF @QuestionnaireId = 0
       AND @SeenClientAnswerMasterId > 0
    BEGIN
        SELECT @QuestionnaireId = QuestionnaireId,
               @blIsIntroductoryMessage = E.ShowIntroductoryOnMobi
        FROM dbo.SeenClientAnswerMaster AS SAM WITH (NOLOCK)
            INNER JOIN dbo.Establishment AS E WITH (NOLOCK)
                ON SAM.EstablishmentId = E.Id
            INNER JOIN dbo.EstablishmentGroup AS Eg WITH (NOLOCK)
                ON E.EstablishmentGroupId = Eg.Id
        WHERE SAM.Id = @SeenClientAnswerMasterId;
    END;

    DECLARE @Url NVARCHAR(150);
    SELECT @Url = KeyValue + 'Questions/'
    FROM dbo.AAAAConfigSettings WITH (NOLOCK)
    WHERE KeyName = 'DocViewerRootFolderPathCMS';

    DECLARE @ImageUrl NVARCHAR(150);

    SELECT @ImageUrl = KeyValue + N'SeenClient/'
    FROM dbo.AAAAConfigSettings WITH (NOLOCK)
    WHERE KeyName = 'DocViewerRootFolderPathWebApp';

    --SELECT  @Url = KeyValue + 'UploadFiles/Questions/'
    --FROM    dbo.AAAAConfigSettings
    --WHERE   KeyName = 'DocViewerRootFolderPath';

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
           ISNULL(   (CASE
                          WHEN Q.QuestionTypeId = 17 THEN
                     (CASE
                          WHEN SA.Detail <> '' THEN
                          (
                              SELECT STUFF(
                                     (
                                         SELECT ',' + EE.Detail
                                         FROM
                                         (
                                             SELECT (@ImageUrl + Data) AS Detail,
                                                    Id
                                             FROM dbo.Split((SA.Detail), ',')
                                         ) EE
                                         FOR XML PATH('')
                                     ),
                                     1,
                                     1,
                                     ''
                                          ) AS listStr
                          )
                          ELSE
                              ''
                      END
                     )
                          ELSE
                              SA.Detail
                      END
                     ),
                     ''
                 ) Detail,
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
           ISNULL(Q.IsForReminder, 0) AS IsForReminder,
           ISNULL(Q.IsSingleSelect, 0) AS IsSingleSelect,
           ISNULL(Q.AllowArithmeticOperation, 0) AS IsAllowArithmeticOperation,
           ISNULL(QC.Formula, '') AS ArithmeticFormula,
           ISNULL(Q.MinLength, 0) AS MinLength
    FROM dbo.[Questions] AS Q WITH (NOLOCK)
        LEFT OUTER JOIN dbo.SeenClientQuestions AS SQ WITH (NOLOCK)
            ON Q.SeenClientQuestionIdRef = SQ.Id
        LEFT OUTER JOIN dbo.SeenClientAnswers AS SA WITH (NOLOCK)
            ON SQ.Id = SA.QuestionId
               AND SA.SeenClientAnswerMasterId = @SeenClientAnswerMasterId
               AND (
                       @SeenClientAnswerChildId = 0
                       OR SA.SeenClientAnswerChildId = @SeenClientAnswerChildId
                   )
        LEFT JOIN dbo.Questionnaire [QUE] WITH (NOLOCK)
            ON Q.QuestionnaireId = QUE.Id
        LEFT JOIN dbo.ControlStyle [CS] WITH (NOLOCK)
            ON QUE.ControlStyleId = CS.Id
        LEFT OUTER JOIN dbo.Answers AS A WITH (NOLOCK)
            ON A.QuestionId = Q.Id
               AND A.AnswerMasterId = @AnswerMasterId
        LEFT JOIN dbo.QuestionCalculationItem AS QC WITH (NOLOCK)
            ON QC.QuestionId = Q.Id
               AND QC.IsCapture = 0
    WHERE Q.IsActive = 1
          AND Q.IsDeleted = 0
          AND Q.QuestionnaireId = @QuestionnaireId
    ORDER BY Q.Position ASC;
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
         'dbo.GetMobiForm',
         N'DATABASE',
         ERROR_MESSAGE(),
         ('ERROR_NUMBER=' + CONVERT(VARCHAR(100), ERROR_NUMBER()) + ',ERROR_STATE='
          + CONVERT(VARCHAR(20), ERROR_STATE()) + ',ERROR_SEVERITY=' + CONVERT(VARCHAR(20), ERROR_SEVERITY())
         )  ,
         GETUTCDATE(),
         N'',
         @QuestionnaireId+','+@SeenClientAnswerMasterId+','+@SeenClientAnswerChildId+','+@AnswerMasterId,
         GETUTCDATE(),
         N''
        );
END CATCH
    SET NOCOUNT OFF;
END;
