-- =============================================
-- Author:			Vasu Patel
-- Create date:	12-Jan-2018
-- Description:	Application manager user as per establishmerights
-- Call :dbo.GetAppUserListByManagerRights '0,34494,34496,34495,34497,34498,34499',0
-- =============================================
CREATE PROCEDURE dbo.GetAppUserListByManagerRights
    @EstablishmentId NVARCHAR(MAX),
    @UserId BIGINT
AS
BEGIN
    DECLARE @Url NVARCHAR(500);
    SELECT @Url = KeyValue + N'AppUser/'
    FROM dbo.AAAAConfigSettings
    WHERE KeyName = 'DocViewerRootFolderPathCMS';
    SELECT DISTINCT
        AppUserId,
        Name,
        ISNULL(AM.ApplicationUserId, 0) AS SelectedId
    FROM dbo.AppUserEstablishment
        INNER JOIN dbo.AppUser AS AU
            ON AU.Id = AppUserEstablishment.AppUserId
        LEFT JOIN dbo.AppUserofManage AS AM
            ON AM.ApplicationUserId = AU.Id AND AM.IsDeleted = 0 AND AM.ManagerUserId = @UserId
    WHERE EstablishmentId IN (
                                 SELECT Data FROM dbo.Split(@EstablishmentId, ',')
                             )
          AND dbo.AppUserEstablishment.IsDeleted = 0
          AND AU.IsDeleted = 0
          AND AU.IsAreaManager = 0
          AND IsActive = 1
    ORDER BY Name ASC;
END;
