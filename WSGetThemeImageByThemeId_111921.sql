
-- =============================================
-- Author:		<Author,,GD>
-- Create date: <Create Date,,10 Jun 2015>
-- Description:	<Description,,>
-- Call SP:		WSGetThemeImageByThemeId 1, 'ThemeMDPI', null
-- =============================================
CREATE PROCEDURE [dbo].[WSGetThemeImageByThemeId_111921]
    @ThemeId BIGINT ,
    @Resolution NVARCHAR(50) ,
    @LastServerDate DATETIME
AS 
    BEGIN
        DECLARE @Url NVARCHAR(500)

        --SELECT  @Url = KeyValue + 'UploadFiles/Themes/'
        --FROM    dbo.AAAAConfigSettings
        --WHERE   KeyName = 'DocViewerRootFolderPath'

		SELECT  @Url = KeyValue + 'Themes/'
        FROM    dbo.AAAAConfigSettings
        WHERE   KeyName = 'DocViewerRootFolderPathCMS'


        SELECT  ThemeId ,
                Resolution ,
                [FileName] ,
                @Url + CONVERT(NVARCHAR(10), ThemeId) + '/' + Resolution + '/'
                + [FileName] AS ThemeUrl
        FROM    dbo.ThemeImage
        WHERE   ThemeId = @ThemeId
                AND Resolution = @Resolution
                AND ( CreatedOn >= @LastServerDate
                      OR @LastServerDate IS NULL
                    )
    END
