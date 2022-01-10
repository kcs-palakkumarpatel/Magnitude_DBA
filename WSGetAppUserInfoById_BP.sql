-- =============================================
-- Author:		<Author,,GD>
-- Create date: <Create Date,,04 Jul 2015>
-- Description:	<Description,,>
-- Call SP:		WSGetAppUserInfoById 313, null
-- =============================================
CREATE PROCEDURE dbo.WSGetAppUserInfoById_BP
    @AppUserId BIGINT ,
    @LastServerDate DATETIME
AS 
    BEGIN
        DECLARE @Url NVARCHAR(500)
        SELECT  @Url = KeyValue + 'AppUser/'
        FROM    dbo.AAAAConfigSettings
        WHERE   KeyName = 'DocViewerRootFolderPathCMS'
        
        SELECT DISTINCT U.Id ,
                Name ,
                Email ,
                Mobile ,
                IsAreaManager ,
                ISNULL(@Url + ImageName, '') AS ImageUrl
        FROM    dbo.AppUser U LEFT JOIN 
					dbo.DefaultContact  DC ON DC.AppUserId = @AppUserId AND U.Id = DC.AppUserId 
        WHERE   U.Id = @AppUserId
                AND ( ISNULL(U.UpdatedOn, U.CreatedOn) >= ISNULL(@LastServerDate,'1970-01-01')
                      --OR @LastServerDate IS NULL
                    ) OR (ISNULL(DC.UpdatedOn, DC.CreatedOn) >= ISNULL(@LastServerDate,'1970-01-01'))
                      --OR @LastServerDate IS NULL)
    END
