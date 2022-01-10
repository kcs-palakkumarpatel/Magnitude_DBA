
-- =============================================
-- Author:		<Author,,GD>
-- Create date: <Create Date,,17 Jun 2015>
-- Description:	<Description,,>
-- Call SP:		WSGetOptionsByQuestionnaireId_OfflineAPI 2244
-- Drop procedure WSGetOptionsByQuestionnaireId_OfflineAPI
-- =============================================
CREATE PROCEDURE [dbo].[WSGetOptionsByQuestionnaireId_OfflineAPI]
    @QuestionnaireId BIGINT,
    @LastServerDate DATETIME = '1970-01-01 00:00:00.00'
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
           END AS [OptionImagePath],
           ISNULL(O.IsHTTPHeader, 0) AS IsHTTPHeader,
           ISNULL(O.ReferenceQuestionId, 0) AS ReferenceQuestionId,
           ISNULL(O.FromRef, 0) AS FromRef,
           (CASE
                WHEN @LastServerDate = '1970-01-01 00:00:00.00' THEN
                    1
                WHEN ISNULL(O.DeletedOn, '') <> '' THEN
                    3 -- Deleted
                WHEN ISNULL(O.UpdatedOn, '') <> '' THEN
                    2 -- Updated
                ELSE
                    1 --Added
            END
           ) AS [Action]
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
    WHERE (
              ISNULL(O.IsDeleted, 0) = 0
              OR @LastServerDate <> '1970-01-01 00:00:00.00'
          )
          AND Q.QuestionnaireId = @QuestionnaireId
          AND Q.QuestionTypeId <> 26
          AND
          (
              ISNULL(O.UpdatedOn, O.CreatedOn) >= @LastServerDate
              OR ISNULL(O.DeletedOn, '') >= @LastServerDate
          )
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
         'dbo.WSGetOptionsByQuestionnaireId_OfflineAPI',
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
