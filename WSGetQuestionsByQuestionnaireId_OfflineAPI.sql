
-- =============================================
-- Author:		<Author,,GD>
-- Create date: <Create Date,,12 Jun 2015>
-- Description:	<Description,,>
-- Call SP:		WSGetQuestionsByQuestionnaireId_OfflineAPI 26, '1970-01-01 00:00:00.00'
-- Drop procedure WSGetQuestionsByQuestionnaireId_OfflineAPI
-- =============================================
CREATE PROCEDURE [dbo].[WSGetQuestionsByQuestionnaireId_OfflineAPI]
    @QuestionnaireId BIGINT,
    @LastServerDate DATETIME = '1970-01-01 00:00:00.00'
AS
BEGIN
	SET DEADLOCK_PRIORITY NORMAL;
	
	BEGIN TRY
    DECLARE @Url NVARCHAR(150);
    SELECT @Url = KeyValue + N'Questions/'
    FROM dbo.AAAAConfigSettings
    WHERE KeyName = 'DocViewerRootFolderPathCMS';
    SELECT Q.Id AS QuestionId,
           QuestionTypeId,
           QuestionTitle,
           ShortName,
           [Required],
           [MaxLength],
           ISNULL(Hint, '') AS Hint,
           ISNULL(OptionsDisplayType, '') AS OptionsDisplayType,
           IsTitleBold,
           IsTitleItalic,
           IsTitleUnderline,
           TitleTextColor,
           Position,
           EscalationRegex,
           Margin,
           FontSize,
           ISNULL(@Url + ImagePath, '') AS ImagePath,
           Q.IsCommentCompulsory AS IsCommentCompulsory,
           IsAnonymous AS IsAnonymous,
           Q.IsDisplayInDetail AS DisplayInDetail,
           Q.IsDisplayInSummary AS DisplayInList,
           Q.IsDecimal AS IsDecimal,
           Q.IsSignature AS IsSignature,
           Q.[IsRepetitive] AS IsRepetitive,
           Q.QuestionsGroupNo AS QuestionsGroupNo,
           Q.QuestionsGroupName AS QuestionsGroupName,
           Q.ImageHeight AS ImageHeight,
           Q.ImageWidth AS ImageWidth,
           Q.ImageAlign AS ImageAlign,
           Q.CalculationOptions AS CalculationOptions,
           Q.SummaryOption AS SummaryOption,
           (CASE
                WHEN @LastServerDate = '1970-01-01 00:00:00.00' THEN
                    1 
                WHEN ISNULL(Q.DeletedOn, '') <> '' THEN
                    3 -- Deleted
                WHEN ISNULL(Q.UpdatedOn, '') <> '' THEN
                    2 -- Updated
                ELSE
                    1 --Added
            END
           ) AS [Action],
		   ISNULL(Q.IsSingleSelect,0) AS IsSingleSelect
    FROM dbo.Questions AS Q
    WHERE (
              ISNULL(Q.IsDeleted, 0) = 0
              OR @LastServerDate <> '1970-01-01 00:00:00.00'
          )
          AND Q.IsActive = 1
          AND QuestionnaireId = @QuestionnaireId
          AND
          (
              ISNULL(Q.UpdatedOn, Q.CreatedOn) >= @LastServerDate
              OR ISNULL(Q.DeletedOn, '') >= @LastServerDate
          )
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
         'dbo.WSGetQuestionsByQuestionnaireId_OfflineAPI',
         N'DATABASE',
         ERROR_MESSAGE(),
         ('ERROR_NUMBER=' + CONVERT(VARCHAR(100), ERROR_NUMBER()) + ',ERROR_STATE='
          + CONVERT(VARCHAR(20), ERROR_STATE()) + ',ERROR_SEVERITY=' + CONVERT(VARCHAR(20), ERROR_SEVERITY())
         )  ,
         GETUTCDATE(),
         ISNULL(@QuestionnaireId,0),
         @QuestionnaireId+','+@LastServerDate,
         GETUTCDATE(),
         N''
        );
END CATCH
END;
