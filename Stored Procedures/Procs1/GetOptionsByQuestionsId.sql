-- =============================================
-- Author:		<Author,,GD>
-- Create date: <Create Date,, 30 May 2015>
-- Description:	<Description,,GetOptionsById>
-- Call SP    :	GetOptionsByQuestionsId 59500
-- =============================================
CREATE PROCEDURE [dbo].[GetOptionsByQuestionsId] @QuestionsId BIGINT
AS
BEGIN

    DECLARE @Url NVARCHAR(500);

    SELECT @Url = KeyValue + N'OptionImage/'
    FROM dbo.AAAAConfigSettings
    WHERE KeyName = 'DocViewerRootFolderPathCMS';

    SELECT  dbo.[Options].[Id] AS Id,
           dbo.[Options].[QuestionId] AS QuestionId,
           QuestionTitle,
           dbo.[Options].[Position] AS Position,
           dbo.[Options].[Name] AS Name,
           dbo.[Options].[Value] AS Value,
           dbo.[Options].[DefaultValue] AS DefaultValue,
           dbo.Options.[Weight],
           dbo.Options.[Point],
           CASE Options.OptionImagePath
               WHEN NULL THEN
                   ''
               ELSE
                   @Url + Options.OptionImagePath
           END AS [OptionImagePath]
    FROM dbo.[Options]
        INNER JOIN dbo.[Questions]
            ON dbo.[Questions].Id = dbo.[Options].QuestionId
    WHERE dbo.[Options].IsDeleted = 0
          AND [QuestionId] = @QuestionsId;
END;
