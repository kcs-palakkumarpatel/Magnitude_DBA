-- =============================================
-- Author:			Vasu Patel
-- Create date:	12-Jan-2018
-- Description:	Application manager user as per establishmerights
-- Call:					dbo.GetAppUserByManagerRights '11601,13832', 1243
-- =============================================
CREATE PROCEDURE dbo.GetAppUserByManagerRights
    @EstablishmentId NVARCHAR(MAX),
    @UserId BIGINT
AS
BEGIN
SET NOCOUNT ON;
    DECLARE @Url NVARCHAR(500);
    SELECT @Url = KeyValue + N'AppUser/'
    FROM dbo.AAAAConfigSettings
    WHERE KeyName = 'DocViewerRootFolderPathCMS';
    SELECT AppUserId,
           Name, --+ CASE IsAreaManager WHEN 0 THEN '' ELSE ' [Manager]' END AS Name
           ISNULL(   (CASE
                          WHEN ImageName <> '' THEN
                              ISNULL(@Url + ImageName, '')
                          ELSE
                              ''
                      END
                     ),
                     ''
                 ) AS UserImageURL
    FROM dbo.AppUserEstablishment
        INNER JOIN dbo.AppUser
            ON AppUser.Id = AppUserEstablishment.AppUserId
    WHERE EstablishmentId IN
          (
              SELECT Data FROM dbo.Split(@EstablishmentId, ',')
          )
          AND dbo.AppUserEstablishment.IsDeleted = 0
          AND dbo.AppUser.IsDeleted = 0
          AND
          (
              IsAreaManager = 0
              OR AppUserId = @UserId
          )
          AND IsActive = 1
    UNION
    SELECT ManagerUserId AS AppUserId,
           Name, --+ ' [Manager]' AS Name
		    ISNULL(   (CASE
                          WHEN ImageName <> '' THEN
                              ISNULL(@Url + ImageName, '')
                          ELSE
                              ''
                      END
                     ),
                     ''
                 ) AS UserImageURL
    FROM dbo.AppManagerUserRights
        INNER JOIN dbo.AppUser
            ON dbo.AppUser.Id = AppManagerUserRights.ManagerUserId
               AND AppManagerUserRights.UserId = @UserId
               AND dbo.AppManagerUserRights.EstablishmentId IN
                   (
                       SELECT Data FROM dbo.Split(@EstablishmentId, ',')
                   )
               AND AppManagerUserRights.IsDeleted = 0
               AND IsActive = 1
               AND dbo.AppUser.IsDeleted = 0
    GROUP BY ManagerUserId,
             Name,ImageName
    ORDER BY Name ASC;
SET NOCOUNT OFF;
END;
