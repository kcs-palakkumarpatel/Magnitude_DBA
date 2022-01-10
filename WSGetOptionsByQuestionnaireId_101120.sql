-- =============================================
-- Author:		<Author,,GD>
-- Create date: <Create Date,,17 Jun 2015>
-- Description:	<Description,,>
-- Call SP:		WSGetOptionsByQuestionnaireId_101120 2244
-- =============================================
CREATE PROCEDURE [dbo].[WSGetOptionsByQuestionnaireId_101120] 
	@QuestionnaireId BIGINT
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
		CASE O.OptionImagePath WHEN NULL THEN '' ELSE @Url + O.OptionImagePath END AS [OptionImagePath],
		ISNULL(O.IsHTTPHeader,0) AS IsHTTPHeader,
		ISNULL(O.ReferenceQuestionId,0) AS ReferenceQuestionId,
		ISNULL(O.FromRef,0) AS FromRef
    FROM dbo.Options AS O
    INNER JOIN dbo.Questions AS Q ON O.QuestionId = Q.Id AND Q.IsDeleted = 0
    LEFT JOIN dbo.RoutingLogic AS RL ON RL.OptionId = O.Id AND RL.IsDeleted = 0
    LEFT JOIN dbo.Questions AS QU ON RL.QueueQuestionId = QU.Id AND QU.IsDeleted = 0
    WHERE Q.QuestionnaireId = @QuestionnaireId
          AND O.IsDeleted = 0
		  AND Q.QuestionTypeId !=26
    ORDER BY Q.Id,O.Position;
END;

