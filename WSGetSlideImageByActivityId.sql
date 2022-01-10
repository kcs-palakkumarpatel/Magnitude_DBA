
-- =============================================
-- Author:		<Author,,GD>
-- Create date: <Create Date,,25 Jun 2015>
-- Description:	<Description,,>
-- Call SP:		WSGetSlideImageByActivityId 7, 'ThemeMDPI'
-- =============================================
CREATE PROCEDURE [dbo].[WSGetSlideImageByActivityId]
    @ActivityId BIGINT ,
    @Resolution NVARCHAR(50)
AS 
    BEGIN
	SET DEADLOCK_PRIORITY NORMAL;
	
	BEGIN TRY
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
         'dbo.WSGetSlideImageByActivityId',
         N'DATABASE',
         ERROR_MESSAGE(),
         ('ERROR_NUMBER=' + CONVERT(VARCHAR(100), ERROR_NUMBER()) + ',ERROR_STATE='
          + CONVERT(VARCHAR(20), ERROR_STATE()) + ',ERROR_SEVERITY=' + CONVERT(VARCHAR(20), ERROR_SEVERITY())
         )  ,
         GETUTCDATE(),
         ISNULL(@ActivityId,0),
         @ActivityId+','+@Resolution,
         GETUTCDATE(),
         N''
        );
END CATCH
    END
