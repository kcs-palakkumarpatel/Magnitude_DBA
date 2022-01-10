-- =============================================
-- Author : Krishna Panchal
-- Create On : 20-Jan-2021
-- Description : Get App User By EstablishmentId
-- GetAppUserForTaskAllocationByEstablishmentId 33360,18058,'',1,50
-- =============================================
CREATE PROCEDURE [dbo].[GetAppUserForTaskAllocationByEstablishmentId_Backup]

    @EstablishmentId BIGINT,
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
    SELECT AppUserId,
           Name
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
           Name --+ ' [Manager]' AS Name
    FROM AppManagerUserRights
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
             Name
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
                 ) AS UserImageURL,
				 (CASE
                WHEN (
                     (
                         SELECT TOP 1
                                Id
                         FROM dbo.SeenClientAnswerMaster
                         WHERE ContactMasterId IN
                               (
                                   SELECT CM.Id
                                   FROM dbo.ContactMaster AS CM
                                       INNER JOIN dbo.ContactDetails AS CD
                                           ON CD.ContactMasterId = CM.Id
                                       INNER JOIN dbo.AppUser AS AP
                                           ON AP.Email = CD.Detail
                                              AND AP.GroupId = CM.GroupId
                                   WHERE CM.IsDeleted = 0
                                         AND CD.QuestionTypeId IN ( 10 )
                                         AND CD.Detail <> ''
                                         AND AP.Id = UT.Id
                               )
                               AND IsDeleted = 0
                               AND IsUnAllocated = 0
                               AND EstablishmentId = @EstablishmentId
                     ) > 0
                     ) THEN
                    1
                ELSE
                    0
            END
           ) AS IsTaskAllocated
    FROM #UserTable AS UT
    WHERE (
              (AppUserName LIKE '%' + @SearchText + '%')
              OR @SearchText = ''
          );

END;
