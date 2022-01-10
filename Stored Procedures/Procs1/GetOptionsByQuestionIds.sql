-- =============================================
-- Author:		<Author,,Bhavik>
-- Create date: <Create Date,, 18 02 2021>
-- Description:	<Description,,GetOptionsById>
---- Call SP    :	GetOptionsByQuestionIds 59500,1,20,'Wheel Thrust Shaft Stamp'
-- Call SP    :	GetOptionsByQuestionIds 59501,1,200,'seeger'
-- =============================================
CREATE PROCEDURE [dbo].[GetOptionsByQuestionIds] 
	@QuestionsId BIGINT,
	@PageIndex BIGINT,
	@PageSize BIGINT,
	@Search nvarchar(max)
AS
BEGIN

    DECLARE @Url NVARCHAR(500);

    SELECT @Url = KeyValue + N'OptionImage/'
    FROM dbo.AAAAConfigSettings
    WHERE KeyName = 'DocViewerRootFolderPathCMS';

    --SELECT  dbo.[Options].[Id] AS Id,
    --       dbo.[Options].[QuestionId] AS QuestionId,
    --       QuestionTitle,
    --       dbo.[Options].[Position] AS Position,
    --       dbo.[Options].[Name] AS Name,
    --       dbo.[Options].[Value] AS Value,
    --       dbo.[Options].[DefaultValue] AS DefaultValue,
    --       dbo.Options.[Weight],
    --       dbo.Options.[Point],
    --       CASE Options.OptionImagePath
    --           WHEN NULL THEN
    --               ''
    --           ELSE
    --               @Url + Options.OptionImagePath
    --       END AS [OptionImagePath]
	SELECT 	dbo.[Options].[Name] AS Name
    FROM dbo.[Options]
        INNER JOIN dbo.[Questions]
            ON dbo.[Questions].Id = dbo.[Options].QuestionId
    WHERE dbo.[Options].IsDeleted = 0
          AND [QuestionId] = @QuestionsId
		  AND (@Search = '' OR dbo.[Options].[Name] LIKE '%' +  @Search + '%');
END;
