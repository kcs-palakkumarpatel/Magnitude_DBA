-- =============================================
-- Author:		Vasu Patel
-- Create date: 04 May 2016
-- Description:	Get Manager User by Establishment id, Changes by Disha - 22-OCT-2016 for Sorting and Searching
-- Call: GetAppManagerUserByEstablishmentId '0,12581,1324,1356,11647,11648,11649,11650,1357,1313',0,'','Name asc'
-- =============================================
CREATE PROCEDURE [dbo].[GetAppManagerUserByEstablishmentId]
    @EstablishmentId NVARCHAR(MAX) ,
    @lgUserId BIGINT ,
    @Search NVARCHAR(500) = '' ,
    @Sort NVARCHAR(50)
AS
    BEGIN
	SET @Sort = 'EstablishmentName Asc'
        IF ( @lgUserId > 0 )
            BEGIN
                SELECT  R.Id ,
                        R.AppUserId AS AppUserId ,
                        R.ManagerName ,
                        R.EstablishmentName ,
                        R.EstablishmentId AS EstablishmentId ,
                        CAST(R.SelectedId AS BIGINT) AS SelectedId
                FROM    ( SELECT    ( CONVERT(NVARCHAR(10), AppUserId) + '|'
                                      + CONVERT(NVARCHAR(10), AppUserEstablishment.EstablishmentId) ) AS Id ,
                                    AppUserId ,
                                    Name AS ManagerName,
                                    EstablishmentName ,
                                    AppUserEstablishment.EstablishmentId ,
                                    ISNULL(dbo.AppManagerUserRights.Id, 0) AS SelectedId ,
                                    ROW_NUMBER() OVER ( ORDER BY CASE
                                                              WHEN @Sort = 'ManagerName ASC'
                                                              THEN dbo.AppUser.[Name]
                                                              END ASC, CASE
                                                              WHEN @Sort = 'ManagerName DESC'
                                                              THEN dbo.AppUser.[Name]
                                                              END DESC, CASE
                                                              WHEN @Sort = 'EstablishmentName Asc'
                                                              THEN dbo.Establishment.EstablishmentName
                                                              END ASC, CASE
                                                              WHEN @Sort = 'EstablishmentName DESC'
                                                              THEN dbo.Establishment.EstablishmentName
                                                              END DESC ) AS RowNum
                          FROM      dbo.AppUserEstablishment
                                    INNER JOIN dbo.AppUser ON AppUser.Id = AppUserEstablishment.AppUserId
                                                              AND IsActive = 1
                                    INNER JOIN dbo.Establishment ON Establishment.Id = AppUserEstablishment.EstablishmentId
                                    LEFT OUTER JOIN dbo.AppManagerUserRights ON AppUser.Id = dbo.AppManagerUserRights.ManagerUserId
                                                              AND AppUserEstablishment.EstablishmentId = dbo.AppManagerUserRights.EstablishmentId
                                                              AND dbo.AppManagerUserRights.IsDeleted = 0
                                                              AND UserId = @lgUserId
                          WHERE     AppUserEstablishment.EstablishmentId IN (
                                    SELECT  Data
                                    FROM    dbo.Split(@EstablishmentId, ',') )
                                    AND IsAreaManager = 1
                                    AND AppUserId != @lgUserId
                                    AND dbo.AppUserEstablishment.IsDeleted = 0
                                    AND IsActive = 1
                                    AND ( ISNULL(dbo.AppUser.[Name], '') LIKE '%'
                                          + @Search + '%'
                                          OR ISNULL(dbo.Establishment.EstablishmentName,
                                                    '') LIKE '%' + @Search
                                          + '%'
                                        )
                        ) AS R
                ORDER BY R.RowNum
            END
        ELSE
            BEGIN
                SELECT  R.Id ,
                        R.AppUserId AS AppUserId ,
                        R.ManagerName,
                        R.EstablishmentName ,
                        R.EstablishmentId,
                        CAST(R.SelectedId AS BIGINT) AS SelectedId
                FROM    ( SELECT    ( CONVERT(NVARCHAR(10), AppUserId) + ' | '
                                      + CONVERT(NVARCHAR(10), AppUserEstablishment.EstablishmentId) ) AS Id ,
                                    AppUserId ,
                                    Name AS ManagerName,
                                    EstablishmentName ,
                                    AppUserEstablishment.EstablishmentId ,
                                    0 AS SelectedId ,
                                    ROW_NUMBER() OVER ( ORDER BY CASE
                                                              WHEN @Sort = 'ManagerName ASC'
                                                              THEN dbo.AppUser.[Name]
                                                              END ASC, CASE
                                                              WHEN @Sort = 'ManagerName DESC'
                                                              THEN dbo.AppUser.[Name]
                                                              END DESC, CASE
                                                              WHEN @Sort = 'EstablishmentName Asc'
                                                              THEN dbo.Establishment.EstablishmentName
                                                              END ASC, CASE
                                                              WHEN @Sort = 'EstablishmentName DESC'
                                                              THEN dbo.Establishment.EstablishmentName
                                                              END DESC ) AS RowNum
                          FROM      dbo.AppUserEstablishment
                                    INNER JOIN dbo.AppUser ON AppUser.Id = AppUserEstablishment.AppUserId
                                                              AND IsActive = 1
                                    INNER JOIN dbo.Establishment ON Establishment.Id = AppUserEstablishment.EstablishmentId
                                                              AND AppUserEstablishment.IsDeleted = 0
                                    LEFT OUTER JOIN dbo.AppManagerUserRights ON AppUser.Id = dbo.AppManagerUserRights.ManagerUserId
                                                              AND AppUserEstablishment.EstablishmentId = dbo.AppManagerUserRights.EstablishmentId
                                                              AND dbo.AppManagerUserRights.IsDeleted = 0
                                                              AND dbo.AppUserEstablishment.AppUserId = 0
                          WHERE     AppUserEstablishment.EstablishmentId IN (
                                    SELECT  Data
                                    FROM    dbo.Split(@EstablishmentId, ',') )
                                    AND IsAreaManager = 1
                                    AND dbo.AppUserEstablishment.IsDeleted = 0
                                    AND ( ISNULL(dbo.AppUser.[Name], '') LIKE '%'
                                          + @Search + '%'
                                          OR ISNULL(dbo.Establishment.EstablishmentName,
                                                    '') LIKE '%' + @Search
                                          + '%'
                                        )
                        ) AS R
                ORDER BY R.RowNum
            END
    

    END
