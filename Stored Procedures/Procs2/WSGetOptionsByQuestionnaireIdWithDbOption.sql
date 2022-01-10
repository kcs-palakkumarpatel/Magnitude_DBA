-- =============================================
-- Author:		<Author,,GD>
-- Create date: <Create Date,,17 Jun 2015>
-- Description:	<Description,,>
-- Call SP:		WSGetOptionsByQuestionnaireId 983
-- =============================================
CREATE PROCEDURE [dbo].[WSGetOptionsByQuestionnaireIdWithDbOption] @QuestionnaireId BIGINT
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
    WHERE Q.QuestionnaireId = @QuestionnaireId
          AND O.IsDeleted = 0
    ORDER BY Q.Id,
             O.Position;
END;
