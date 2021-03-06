
-- =============================================
-- Author:		<Author,,GD>
-- Create date: <Create Date,,17 Jun 2015>
-- Description:	<Description,,>
-- Call SP:		WSGetOptionsByQuestionnaireId 2244
-- =============================================
CREATE PROCEDURE [dbo].[WSGetOptionsByQuestionnaireId] @QuestionnaireId BIGINT
AS
BEGIN
    SET NOCOUNT ON;
	SET DEADLOCK_PRIORITY NORMAL;
	
	BEGIN TRY
    DECLARE @Url NVARCHAR(500);

    SELECT @Url = KeyValue + N'OptionImage/'
    FROM dbo.AAAAConfigSettings WITH (NOLOCK)
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
           END AS [OptionImagePath],
           ISNULL(O.IsHTTPHeader, 0) AS IsHTTPHeader,
           ISNULL(O.ReferenceQuestionId, 0) AS ReferenceQuestionId,
           ISNULL(O.FromRef, 0) AS FromRef
    FROM dbo.Options AS O WITH (NOLOCK)
        INNER JOIN dbo.Questions AS Q WITH (NOLOCK)
            ON O.QuestionId = Q.Id
               AND Q.IsDeleted = 0
        LEFT JOIN dbo.RoutingLogic AS RL WITH (NOLOCK)
            ON RL.OptionId = O.Id
               AND RL.IsDeleted = 0
        LEFT JOIN dbo.Questions AS QU WITH (NOLOCK)
            ON RL.QueueQuestionId = QU.Id
               AND QU.IsDeleted = 0
    WHERE Q.QuestionnaireId = @QuestionnaireId
          AND O.IsDeleted = 0
          AND Q.QuestionTypeId != 26
    ORDER BY Q.Id,
             O.Position;
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
         'dbo.WSGetOptionsByQuestionnaireId',
         N'DATABASE',
         ERROR_MESSAGE(),
         ('ERROR_NUMBER=' + CONVERT(VARCHAR(100), ERROR_NUMBER()) + ',ERROR_STATE='
          + CONVERT(VARCHAR(20), ERROR_STATE()) + ',ERROR_SEVERITY=' + CONVERT(VARCHAR(20), ERROR_SEVERITY())
         )  ,
         GETUTCDATE(),
         ISNULL(@QuestionnaireId,0),
         @QuestionnaireId,
         GETUTCDATE(),
         N''
        );
END CATCH
    SET NOCOUNT OFF;
END;
