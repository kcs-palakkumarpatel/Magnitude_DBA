-- =============================================
-- Author:		Vasu Patel
-- Create date: 06 May 2016
-- Description:	Application manager user as per establishmerights
-- Call: GetAppUserByManagerRights '1,2',30024
-- =============================================
CREATE PROCEDURE [dbo].[WSGetAppUserByManagerRights] 
	-- Add the parameters for the stored procedure here
    @EstablishmentId NVARCHAR(MAX) ,
    @UserId BIGINT
AS
    BEGIN

        SELECT  AppUserId ,
                Name,
				EstablishmentType,
				AppUserEstablishment.EstablishmentId
        FROM    dbo.AppUserEstablishment
                INNER JOIN dbo.AppUser ON AppUser.Id = AppUserEstablishment.AppUserId
        WHERE   EstablishmentId IN ( SELECT Data FROM dbo.Split(@EstablishmentId, ',') )
                AND dbo.AppUserEstablishment.IsDeleted = 0 AND dbo.AppUser.IsDeleted = 0
                AND (IsAreaManager = 0 OR AppUserId = @UserId)
				AND IsActive = 1
        UNION
        SELECT  ManagerUserId ,
                Name,--+ ' [Manager]',
				EstablishmentType,
				AppUserEstablishment.EstablishmentId
        FROM    appmanageruserRights
                INNER JOIN dbo.AppUser ON dbo.AppUser.Id = appmanageruserRights.managerUserid AND  appmanageruserRights.userId = @UserId
                                          AND dbo.appmanageruserRights.EstablishmentId IN (SELECT Data FROM dbo.Split(@EstablishmentId, ','))
                                          AND appmanageruserRights.IsDeleted = 0 AND IsActive = 1 AND dbo.AppUser.IsDeleted = 0
				INNER JOIN dbo.AppUserEstablishment ON appManageruserrights.EstablishmentId = AppUserEstablishment.EstablishmentId
        GROUP BY ManagerUserId ,
                NAME,EstablishmentType,AppUserEstablishment.EstablishmentId;


				

			--	SELECT * FROM dbo.AppManagerUserRights
			-- select * from appuser where id = 30024
			

        --SELECT  AppUserId ,
        --        Name
        --FROM    dbo.AppUserEstablishment
        --        INNER JOIN dbo.AppUser ON AppUser.Id = AppUserEstablishment.AppUserId
        --WHERE   EstablishmentId IN (
        --        SELECT  EstabilshmentId
        --        FROM    dbo.AppManagerUserRights
        --        WHERE   EstabilshmentId IN (
        --                SELECT  Data
        --                FROM    dbo.Split(@EstablishmentId, ',') )
        --                AND IsDeleted = 0
        --                AND UserId = @UserId
        --        GROUP BY EstabilshmentId )
        --        AND dbo.AppUserEstablishment.IsDeleted = 0
        --GROUP BY AppUserId ,
        --        Name;
    END;


	--SELECT * FROM dbo.AppUserEstablishment WHERE EstablishmentId = 231
