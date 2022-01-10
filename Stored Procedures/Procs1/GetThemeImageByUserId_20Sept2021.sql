-- =============================================
-- Author:	
-- Create date:	21-Nov-2017
-- Description:	
-- Call SP:		dbo.GetThemeImageByUserId 467, 'ThemeMDPI'
-- =============================================
CREATE PROCEDURE [dbo].[GetThemeImageByUserId_20Sept2021]
    @UserId BIGINT ,
    @Resolution NVARCHAR(50)
AS 
    BEGIN
        DECLARE @Url NVARCHAR(500), @ThemeId BIGINT = 0;

        SELECT  @Url = KeyValue + 'Themes/'
        FROM    dbo.AAAAConfigSettings
        WHERE   KeyName = 'DocViewerRootFolderPathCMS'

  --	  SELECT  @Url = KeyValue + 'UploadFiles/Themes/'
  --      FROM    dbo.AAAAConfigSettings
  --      WHERE   KeyName = 'DocViewerRootFolderPath'

		SELECT  @ThemeId = ThemeId FROM dbo.[Group] WHERE EXISTS (SELECT  GroupId FROM dbo.AppUser WHERE Id=@UserId)

        SELECT  ThemeId ,
                Resolution ,
                [FileName] ,
                @Url + CONVERT(NVARCHAR(10), ThemeId) + '/' + Resolution + '/'
                + [FileName] AS ThemeUrl
        FROM    dbo.ThemeImage
        WHERE   ThemeId = @ThemeId
                AND Resolution = @Resolution
				AND [FileName] = 'WebBg.png';
                
    END
