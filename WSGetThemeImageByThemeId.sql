
-- =============================================
-- Author:		<Author,,GD>
-- Create date: <Create Date,,10 Jun 2015>
-- Description:	<Description,,>
-- Call SP:		WSGetThemeImageByThemeId 1, 'ThemeMDPI', null
-- =============================================
CREATE PROCEDURE [dbo].[WSGetThemeImageByThemeId]
    @ThemeId BIGINT ,
    @Resolution NVARCHAR(50) ,
    @LastServerDate DATETIME
AS 
    BEGIN
	SET DEADLOCK_PRIORITY NORMAL;
	
	BEGIN TRY
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
         'dbo.WSGetThemeImageByThemeId',
         N'DATABASE',
         ERROR_MESSAGE(),
         ('ERROR_NUMBER=' + CONVERT(VARCHAR(100), ERROR_NUMBER()) + ',ERROR_STATE='
          + CONVERT(VARCHAR(20), ERROR_STATE()) + ',ERROR_SEVERITY=' + CONVERT(VARCHAR(20), ERROR_SEVERITY())
         )  ,
         GETUTCDATE(),
         ISNULL(@ThemeId,0),
         @ThemeId+','+@Resolution+','+@LastServerDate,
         GETUTCDATE(),
         N''
        );
END CATCH
    END
