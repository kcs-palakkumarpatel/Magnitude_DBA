-- =============================================
-- Author : Krishna Panchal
-- Create On : 20-Jan-2021
-- Description : Get App User By EstablishmentId
-- GetAppUserForTaskAllocationByEstablishmentId 33360,18058,'',1,50
-- =============================================
CREATE PROCEDURE dbo.GetAppUserForTaskAllocationByEstablishmentId
    @UserId BIGINT,
    @SearchText VARCHAR(1000) = '',
    @Page INT = 1, /* Select Page No  */
    @Rows INT = 50
AS
BEGIN
    DECLARE @Url NVARCHAR(500);
    SELECT @Url = KeyValue + N'AppUser/'
    FROM dbo.AAAAConfigSettings
    WHERE KeyName = 'DocViewerRootFolderPathCMS';
    IF OBJECT_ID('tempdb..#UserTable', 'u') IS NOT NULL
        DROP TABLE #UserTable;
    CREATE TABLE #UserTable
    (
        Id BIGINT,
        AppUserName VARCHAR(1000),
        UserImageURL VARCHAR(1000)
    );

    INSERT INTO #UserTable
    (
        Id,
        AppUserName
    )
    SELECT AUE.AppUserId,
           AU.Name
    FROM dbo.AppUserEstablishment AUE
        INNER JOIN dbo.AppUser AU
            ON AU.Id = AUE.AppUserId
    WHERE AUE.EstablishmentId IN
          (
              SELECT EstablishmentId
              FROM dbo.AppUserEstablishment
              WHERE AppUserId = @UserId
          )
          AND AUE.IsDeleted = 0
          AND AU.IsDeleted = 0
          AND
          (
              AU.IsAreaManager = 0
              OR AUE.AppUserId = @UserId
          )
          AND AU.IsActive = 1
    UNION
    SELECT AUR.ManagerUserId AS AppUserId,
           AU.Name
    FROM dbo.AppManagerUserRights AUR
        INNER JOIN dbo.AppUser AU
            ON AU.Id = AUR.ManagerUserId
               AND AUR.UserId = @UserId
               AND AUR.EstablishmentId IN
                   (
                       SELECT EstablishmentId
                       FROM dbo.AppUserEstablishment
                       WHERE AppUserId = @UserId
                   )
               AND AUR.IsDeleted = 0
               AND AU.IsActive = 1
               AND AU.IsDeleted = 0
    GROUP BY AUR.ManagerUserId,
             AU.Name
    ORDER BY Name DESC OFFSET ((@Page - 1) * @Rows) ROWS FETCH NEXT @Rows ROWS ONLY;



    SELECT Id,
           AppUserName,
           ISNULL(
           (
               SELECT TOP 1
                      CASE
                          WHEN ImageName <> '' THEN
                              ISNULL(@Url + ImageName, '')
                          ELSE
                              ''
                      END
               FROM dbo.AppUser
               WHERE AppUser.Id = UT.Id
           ),
           ''
                 ) AS UserImageURL
    FROM #UserTable AS UT
    WHERE (
              (AppUserName LIKE '%' + @SearchText + '%')
              OR @SearchText = ''
          );

END;
