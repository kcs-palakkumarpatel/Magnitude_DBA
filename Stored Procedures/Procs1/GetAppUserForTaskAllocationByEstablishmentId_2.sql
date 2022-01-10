-- =============================================
-- Author : Krishna Panchal
-- Create On : 20-Jan-2021
-- Description : Get App User By EstablishmentId
-- GetAppUserForTaskAllocationByEstablishmentId_2 33337
-- =============================================
CREATE PROCEDURE [dbo].[GetAppUserForTaskAllocationByEstablishmentId_2]
    @EstablishmentId BIGINT,
    @SearchText VARCHAR(1000) = '',
    @Page INT = 1, /* Select Page No  */
    @Rows INT = 50
AS
BEGIN

DECLARE @Url NVARCHAR(500)
        SELECT  @Url = KeyValue + 'AppUser/'
        FROM    dbo.AAAAConfigSettings
        WHERE   KeyName = 'DocViewerRootFolderPathCMS'
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
    SELECT AE.AppUserId,
           AU.Name
    FROM dbo.AppUserEstablishment AE
        INNER JOIN dbo.AppUser AU
            ON AU.Id = AE.AppUserId
        LEFT OUTER JOIN dbo.ContactRoleDetails CRD
            ON CRD.AppUserId = AU.Id
        LEFT OUTER JOIN dbo.ContactRoleEstablishment CRE
            ON CRE.EstablishmentId = AE.EstablishmentId
               AND CRE.ContactRoleId = CRD.ContactRoleId
    WHERE 
		 AU.Id NOT IN (Select DISTINCT AppUserId from SeenClientAnswerMaster where EstablishmentId = @EstablishmentId and IsDeleted = 0 and IsUnAllocated = 0 and IsResolved = 'Unresolved')
		 AND AE.EstablishmentId IN
          (
              SELECT Data FROM dbo.Split(@EstablishmentId, ',')
          )
          AND AU.IsDeleted = 0
          AND AU.IsActive = 1
          AND AE.IsDeleted = 0
          AND
          (
              (AU.Name LIKE '%' + @SearchText + '%')
              OR @SearchText = ''
          )
    GROUP BY AE.AppUserId,
             AU.Name,
             CRD.Id
    ORDER BY AU.Name DESC OFFSET ((@Page - 1) * @Rows) ROWS FETCH NEXT @Rows ROWS ONLY;

    SELECT Id,
           AppUserName,
           ISNULL(
               (SELECT TOP 1
                      CASE
                          WHEN ImageName <> '' THEN
                              ISNULL(@Url + ImageName, '')
                          ELSE
                              ''
                      END FROM dbo.AppUser WHERE AppUser.Id = #UserTable.Id
           ),'') AS UserImageURL
    FROM #UserTable;

END;
