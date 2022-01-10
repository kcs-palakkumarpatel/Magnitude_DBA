-- =============================================
-- Author:	
-- Create date:	28-Sep-2017
-- Description:	
-- Call SP:		dbo.GetThemeImageByGroupId 201, 'ThemeMDPI'
-- =============================================
CREATE PROCEDURE [dbo].[GetThemeImageByGroupId]
    @GroupId BIGINT ,
    @Resolution NVARCHAR(50)
AS 
    BEGIN
        DECLARE @Url NVARCHAR(500), @ThemeId BIGINT = 0;

        SELECT  @Url = KeyValue + 'Themes/'
        FROM    dbo.AAAAConfigSettings
        WHERE   KeyName = 'DocViewerRootFolderPathCMS'

		      --  SELECT  @Url = KeyValue + 'UploadFiles/Themes/'
        --FROM    dbo.AAAAConfigSettings
        --WHERE   KeyName = 'DocViewerRootFolderPath'

		SELECT  @ThemeId = ThemeId FROM dbo.[Group] WHERE Id=@GroupId;

        SELECT  ThemeId ,
                Resolution ,
                [FileName] ,
                @Url + CONVERT(NVARCHAR(10), ThemeId) + '/' + Resolution + '/'
                + [FileName] AS ThemeUrl
        FROM    dbo.ThemeImage
        WHERE   ThemeId = @ThemeId
                AND Resolution = @Resolution;
                
    END
