-- =============================================
-- Author:		Krishna Panchal
-- Create date: 18-Nov-2020
-- Description:	Get Options By QuestionnaireId For Mobile
-- Call SP:		WSGetOptionsByQuestionnaireIdForMobile 2244,'1970-01-01 00:00:00.00'
-- =============================================
CREATE PROCEDURE [dbo].[WSGetOptionsByQuestionnaireIdForMobile]
    @QuestionnaireId BIGINT,
    @LastServerDate DATETIME = '1970-01-01 00:00:00.00'
AS
BEGIN
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
END;
