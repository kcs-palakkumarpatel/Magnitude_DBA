-- =============================================
-- Author:			bhavik patel
-- Create date:	18-Jan-2021
-- Description:	<Description,,[GetSeenClientQuestionsByClientId]>
-- Call SP    :		[GetSeenClientQuestionsByClientId] 1898,1,1500
-- =============================================
CREATE PROCEDURE dbo.GetSeenClientQuestionsByClientId 
	 @SeenClientId BIGINT,
	 @PageIndex INT = 1,
     @PageSize INT = 10
AS
BEGIN
 SET NOCOUNT ON;
    DECLARE @Url NVARCHAR(150);
	DECLARE @RecordCount INT,
			@recordCntQuery VARCHAR(MAX),
            @SelectQuery VARCHAR(MAX),
            @PageSizeQuery VARCHAR(MAX),
			@OrderBy varchar(max)

    SELECT @Url = KeyValue + N'SeenClientQuestions/'
    FROM dbo.AAAAConfigSettings
    WHERE KeyName = 'DocViewerRootFolderPathCMS';

    DECLARE @DefaultOptions TABLE
    (
        Id INT,
        QuestionTypeId INT
    );
    create table #DefaultQuestionIds 
    (
        QuestionId INT
    );
   
   SET @RecordCount = 0;
    SET @recordCntQuery = '';
    SET @PageSizeQuery = '';

	 SET @OrderBy = 'FinalTbl.Position,ChildPosition';

	IF (@PageSize <> '-1')
    BEGIN
        SET @PageSizeQuery
            = ' WHERE RowNumber BETWEEN((' + CAST(@PageIndex AS VARCHAR(10)) + '-1) * ' + CAST(@PageSize AS VARCHAR(10))
              + ' + 1) AND ((((' + CAST(@PageIndex AS VARCHAR(10)) + ' - 1) * ' + CAST(@PageSize AS VARCHAR(10))
              + ' + 1) + ' + CAST(@PageSize AS VARCHAR(10)) + ') - 1)';
    END;

	 SET @SelectQuery
        = '
    SELECT  *,CEILING(CAST(FinalTbl.RecordCount AS DECIMAL(10, 2)) / CAST(' + CAST(@PageSize AS VARCHAR(10))
          + ' AS DECIMAL(10, 2))) AS PageCount          
    FROM
    (
       SELECT 	RecordCount = COUNT(*) OVER (),
			     ROW_NUMBER() OVER
           (
                  ORDER BY  dbo.[SeenClientQuestions].[Position] ASC
            ) AS RowNumber,
			 dbo.[SeenClientQuestions].[Id] AS Id,
           dbo.[SeenClientQuestions].[SeenClientId] AS SeenClientId,
           dbo.[SeenClientQuestions].[Position] AS Position,
           ISNULL(dbo.SeenClientQuestions.ChildPosition, 0) AS ChildPosition,
           dbo.[SeenClientQuestions].[QuestionTypeId] AS QuestionTypeId,
           dbo.[SeenClientQuestions].[QuestionTitle] AS QuestionTitle,
           dbo.[SeenClientQuestions].[ShortName] AS ShortName,
           dbo.[SeenClientQuestions].[Required] AS Required,
           dbo.[SeenClientQuestions].[IsDisplayInSummary] AS IsDisplayInSummary,
           dbo.[SeenClientQuestions].[IsRepetitive] AS IsRepetitive,
           dbo.[SeenClientQuestions].QuestionsGroupNo AS RepetitiveQuestionsGroupNo,
           dbo.[SeenClientQuestions].QuestionsGroupName AS RepetitiveQuestionsGroupName,
           dbo.[SeenClientQuestions].[IsDisplayInDetail] AS IsDisplayInDetail,
           dbo.[SeenClientQuestions].[MaxLength] AS MaxLength,
           dbo.[SeenClientQuestions].[Hint] AS Hint,
           dbo.[SeenClientQuestions].[EscalationRegex] AS EscalationRegex,
           dbo.[SeenClientQuestions].[KeyName] AS KeyName,
           dbo.[SeenClientQuestions].[GroupId] AS GroupId,
           dbo.[SeenClientQuestions].[OptionsDisplayType] AS OptionsDisplayType,
           dbo.[SeenClientQuestions].IsTitleBold,
           dbo.[SeenClientQuestions].IsTitleItalic,
           dbo.[SeenClientQuestions].IsTitleUnderline,
           dbo.[SeenClientQuestions].TitleTextColor,
           dbo.[SeenClientQuestions].ContactQuestionId,
           dbo.[SeenClientQuestions].TableGroupName,
           dbo.[SeenClientQuestions].[EscalationValue] AS EscalationValue,
           dbo.[SeenClientQuestions].[DisplayInGraphs] AS DisplayInGraphs,
           dbo.[SeenClientQuestions].[DisplayInTableView] AS DisplayInTableView,
           ISNULL(   CASE
                         WHEN QuestionTypeId IN ( 5, 6, 18, 21 ) THEN
                         (
                             SELECT SUM([Weight])
                             FROM dbo.SeenClientOptions
                             WHERE QuestionId = dbo.[SeenClientQuestions].Id
                                   AND IsDeleted = 0
                         )
                         ELSE
                             [Weight]
                     END,
                     0
                 ) [Weight],
           WeightForYes,
           WeightForNo,
           Qt.QuestionTypeName,
           dbo.[SeenClientQuestions].Margin,
           dbo.[SeenClientQuestions].FontSize,
           ISNULL(
           (
               SELECT COUNT(1)
               FROM Questions
               WHERE SeenClientQuestionIdRef = SeenClientQuestions.Id
                     AND IsDeleted = 0
           ),
           0
                 ) AS ReferenceId,
           ISNULL(ImagePath, '''') AS ImagePath,
           IsActive,
           IsCommentCompulsory AS IsCommentCompulsory,
           IsDecimal AS AllowDecimal,
           IsSignature AS IsSignature,
           dbo.[SeenClientQuestions].ImageHeight AS ImageHeight,
           dbo.[SeenClientQuestions].ImageWidth AS ImageWidth,
           dbo.[SeenClientQuestions].ImageAlign AS ImageAlign,
           dbo.[SeenClientQuestions].CalculationOptions AS CalculationOptions,
           dbo.[SeenClientQuestions].SummaryOption AS SummaryOption,
           ISNULL(dbo.[SeenClientQuestions].IsValidateUsingQR, 0) AS IsValidateUsingQR,
           CASE
               WHEN EXISTS
                    (
                        SELECT 1
                        FROM   #DefaultQuestionIds 
                        WHERE QuestionId = dbo.[SeenClientQuestions].Id
                    ) THEN
                   1
               ELSE
                   0
           END AS IsEditableForDefault
    FROM dbo.[SeenClientQuestions]
        INNER JOIN dbo.[SeenClient]
            ON dbo.[SeenClient].Id = dbo.[SeenClientQuestions].SeenClientId
        INNER JOIN dbo.QuestionType AS Qt
            ON Qt.Id = QuestionTypeId
    WHERE dbo.[SeenClientQuestions].IsDeleted = 0
          AND [SeenClientId] = '''+convert(varchar(10),@SeenClientId)+'''  
    ) AS FinalTbl ' + @PageSizeQuery  + ' ORDER BY ' + @OrderBy + ' ';

    EXEC (@SelectQuery);
  
END;
