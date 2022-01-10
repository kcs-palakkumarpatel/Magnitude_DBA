


-- =============================================
-- Author: Vasudev patel	
-- Create date:	17-12-2019
-- Description:	Get FeedBack Form Questions List by Capture ID For Advanced filter 
-- Call: FeedbackFormQuestionOptionList
-- =============================================
CREATE PROCEDURE [dbo].[FeedbackFormQuestionOptionList] (@QuestionnaireFormId BIGINT)
AS
BEGIN
	SET DEADLOCK_PRIORITY NORMAL;
	
	BEGIN TRY
    DECLARE @Url NVARCHAR(500);

    SELECT @Url = KeyValue + N'OptionImage/'
    FROM dbo.AAAAConfigSettings
    WHERE KeyName = 'DocViewerRootFolderPathCMS';

    SELECT O.Id AS OptionId,
           Name AS OptionName,
           DefaultValue AS IsDefaultValue,
           Q.Id AS QuestionId,
           O.Value AS OptionValue,
           ISNULL(RL.QueueQuestionId, 0) AS QueueQuestionId,
           ISNULL(QU.IsRepetitive, 0) AS [IsRepetitive],
           CASE O.OptionImagePath
               WHEN NULL THEN
                   ''
               ELSE
                   @Url + O.OptionImagePath
           END AS [OptionImagePath]
    FROM dbo.Options AS O
        INNER JOIN dbo.Questions AS Q
            ON O.QuestionId = Q.Id
               AND Q.IsDeleted = 0
        LEFT JOIN dbo.RoutingLogic AS RL
            ON RL.OptionId = O.Id
               AND RL.IsDeleted = 0
        LEFT JOIN dbo.Questions AS QU
            ON RL.QueueQuestionId = QU.Id
               AND QU.IsDeleted = 0
    WHERE Q.QuestionnaireId = @QuestionnaireFormId
          AND O.IsDeleted = 0
          AND Q.QuestionTypeId != 26
    ORDER BY Q.Id,
             O.Position;

    SELECT QuestionnaireId AS FeedBackFormId,
           Id AS QuestionId,
           QuestionTypeId,
           ShortName AS QuestionName,
           [Required],
           Position,
           ISNULL(Hint, '') AS Hint,
           IsDecimal,
           IsRepetitive,
           [MaxLength],
           MaxWeight,
           [Weight],
           WeightForNo,
           WeightForYes
    FROM dbo.Questions
    WHERE QuestionTypeId NOT IN ( 16, 17, 25, 27, 23 )
          AND IsDeleted = 0
          AND IsActive = 1
          AND QuestionnaireId = @QuestionnaireFormId
    ORDER BY Position ASC;
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
         'dbo.FeedbackFormQuestionOptionList',
         N'DATABASE',
         ERROR_MESSAGE(),
         ('ERROR_NUMBER=' + CONVERT(VARCHAR(100), ERROR_NUMBER()) + ',ERROR_STATE='
          + CONVERT(VARCHAR(20), ERROR_STATE()) + ',ERROR_SEVERITY=' + CONVERT(VARCHAR(20), ERROR_SEVERITY())
         )  ,
         GETUTCDATE(),
         N'',
         @QuestionnaireFormId,
         GETUTCDATE(),
         N''
        );
END CATCH

END;
