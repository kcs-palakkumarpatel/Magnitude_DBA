
-- =============================================
-- Author:		<Author,,GD>
-- Create date: <Create Date,,25 Jun 2015>
-- Description:	<Description,,>
-- Call SP:		WSGetSlideImageByActivityId 7, 'ThemeMDPI'
-- =============================================
CREATE PROCEDURE [dbo].[WSGetSlideImageByActivityId_111921]
    @ActivityId BIGINT ,
    @Resolution NVARCHAR(50)
AS 
    BEGIN
        DECLARE @Url NVARCHAR(500)
        SELECT  @Url = KeyValue + 'Slides/'
        FROM    dbo.AAAAConfigSettings
        WHERE   KeyName = 'DocViewerRootFolderPathCMS'

        SELECT  EstablishmentGroupId AS ActivityId,
                Resolution ,
                [FileName] ,
                @Url + CONVERT(NVARCHAR(10), EstablishmentGroupId) + '/'
                + Resolution + '/' + [FileName] AS ThemeUrl
        FROM    dbo.EstablishmentGroupImage
        WHERE   EstablishmentGroupId = @ActivityId
                AND Resolution = @Resolution
        ORDER BY [FileName]
    END
