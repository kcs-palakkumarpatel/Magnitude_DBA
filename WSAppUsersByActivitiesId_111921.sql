
-- =============================================
-- Author:			Sunil Vaghasiya
-- Create date:	11-July-2017
-- Description:	Get All App User List by ActivityId
-- Call:dbo.WSAppUsersByActivitiesId 18058, '0', '0'
-- =============================================
CREATE PROCEDURE [dbo].[WSAppUsersByActivitiesId_111921]
    @AppUserId BIGINT,
    @ActivityId NVARCHAR(MAX),
	@EstablishmentIds NVARCHAR(MAX) =''
AS
BEGIN
    DECLARE @Count BIGINT = 0,
            @IsManager BIT,
            @EstablishmentId NVARCHAR(MAX);
    SELECT @IsManager = IsAreaManager
    FROM dbo.AppUser
    WHERE Id = @AppUserId;

    IF (@ActivityId = '0')
    BEGIN
        DECLARE @listStr NVARCHAR(MAX);
        SELECT @listStr = COALESCE(@listStr + ', ', '') + CONVERT(NVARCHAR(50), ES.EstablishmentGroupId)
        FROM dbo.Establishment AS ES
            INNER JOIN dbo.AppUserEstablishment
                ON AppUserEstablishment.EstablishmentId = ES.Id
        WHERE dbo.AppUserEstablishment.AppUserId = @AppUserId
        GROUP BY ES.EstablishmentGroupId;

        SET @ActivityId = @listStr;
    END;

    SELECT @EstablishmentId
        = COALESCE(@EstablishmentId + ', ', '') + CONVERT(NVARCHAR(50), ISNULL(dbo.Establishment.Id, ''))
    FROM dbo.Establishment
        INNER JOIN dbo.AppUserEstablishment
            ON AppUserEstablishment.EstablishmentId = Establishment.Id
    WHERE EstablishmentGroupId IN (
                                      SELECT Data FROM dbo.Split(@ActivityId, ',')
                                  )
								  AND (Establishment.Id IN (
                                      SELECT Data FROM dbo.Split(@EstablishmentIds, ',')
                                  ) OR @EstablishmentIds = '')
          AND dbo.AppUserEstablishment.AppUserId = @AppUserId;

    IF EXISTS
    (
        SELECT 1
        FROM dbo.Establishment AS EG
            INNER JOIN dbo.AppUserEstablishment AS AUE
                ON EG.Id = AUE.EstablishmentId
            INNER JOIN dbo.AppUser
                ON AppUser.Id = AUE.AppUserId
        WHERE EG.EstablishmentGroupId IN (
                                             SELECT Data FROM dbo.Split(@ActivityId, ',')
                                         )
              AND AUE.IsDeleted = 0
              AND IsAreaManager = 0
              AND IsActive = 1
        UNION
        SELECT 1
        FROM AppManagerUserRights
            INNER JOIN dbo.AppUser
                ON dbo.AppUser.Id = AppManagerUserRights.ManagerUserId
                   AND AppManagerUserRights.UserId = AppManagerUserRights.UserId
                   AND dbo.AppManagerUserRights.EstablishmentId IN (
                                                                       SELECT Data FROM dbo.Split(@EstablishmentId, ',')
                                                                   )
                   AND AppManagerUserRights.IsDeleted = 0
                   AND IsActive = 1
        GROUP BY ManagerUserId,
                 Name
    )
    BEGIN
        SET @Count = 1;
    END;

    DECLARE @TempTable TABLE
    (
        AppUserId BIGINT,
        Name NVARCHAR(500)
    );

    IF (@IsManager = 1)
    BEGIN
        PRINT 'print 1';
		PRINT @EstablishmentId
        IF (@Count > 0)
        BEGIN
		PRINT '2'
		BEGIN
			 INSERT INTO @TempTable
            (
                AppUserId,
                Name
            )
            SELECT AppUserId,
                   Name
            FROM dbo.AppUserEstablishment
                INNER JOIN dbo.AppUser
                    ON AppUser.Id = AppUserEstablishment.AppUserId
            WHERE EstablishmentId IN (
                                         SELECT Data FROM dbo.Split(@EstablishmentId, ',')
                                     )
                  AND dbo.AppUserEstablishment.IsDeleted = 0
                  AND IsAreaManager = 0
                  AND IsActive = 1
                  AND AppUser.IsDeleted = 0
            UNION
            SELECT ManagerUserId,
                   Name + ' [Manager]'
            FROM AppManagerUserRights
                INNER JOIN dbo.AppUser
                    ON dbo.AppUser.Id = AppManagerUserRights.ManagerUserId
                       AND AppManagerUserRights.UserId = AppManagerUserRights.UserId
                       AND dbo.AppManagerUserRights.EstablishmentId IN (
                                                                           SELECT Data FROM dbo.Split(
                                                                                                         @EstablishmentId,
                                                                                                         ','
                                                                                                     )
                                                                       )
                       AND AppManagerUserRights.IsDeleted = 0
                       AND IsActive = 1
                INNER JOIN dbo.AppUserEstablishment
                    ON AppManagerUserRights.EstablishmentId = AppUserEstablishment.EstablishmentId
            GROUP BY ManagerUserId,
                     Name;
        END
        END;
        ELSE
        BEGIN
		PRINT '3'
            INSERT INTO @TempTable
            (
                AppUserId,
                Name
            )
            SELECT U.Id AS UserId,
                   U.Name
            FROM dbo.AppUserEstablishment AS UE
                INNER JOIN dbo.AppUser AS LoginUser
                    ON UE.AppUserId = LoginUser.Id
                INNER JOIN dbo.Establishment AS E
                    ON UE.EstablishmentId = E.Id
                INNER JOIN dbo.EstablishmentGroup AS Eg
                    ON Eg.Id = E.EstablishmentGroupId
                INNER JOIN dbo.AppUserEstablishment AS AppUser
                    ON E.Id = AppUser.EstablishmentId
                       AND (
                               UE.EstablishmentType = AppUser.EstablishmentType
                               OR LoginUser.IsAreaManager = 1
                           )
                INNER JOIN dbo.AppUser AS U
                    ON AppUser.AppUserId = U.Id
                       AND U.IsAreaManager = 0
                LEFT JOIN dbo.Supplier AS S
                    ON U.SupplierId = S.Id
            WHERE E.IsDeleted = 0
                  AND UE.IsDeleted = 0
                  AND AppUser.IsDeleted = 0
                  AND U.IsDeleted = 0
                  AND E.Id IN (
                                  SELECT Data FROM dbo.Split(@EstablishmentId, ',')
                              );
        END;
    END;
    ELSE
    BEGIN
        INSERT INTO @TempTable
        (
            AppUserId,
            Name
        )
        SELECT U.Id AS UserId,
               U.Name
        FROM dbo.AppUserEstablishment AS UE
            INNER JOIN dbo.AppUser AS LoginUser
                ON UE.AppUserId = LoginUser.Id
            INNER JOIN dbo.Establishment AS E
                ON UE.EstablishmentId = E.Id
            INNER JOIN dbo.EstablishmentGroup AS Eg
                ON Eg.Id = E.EstablishmentGroupId
            INNER JOIN dbo.AppUserEstablishment AS AppUser
                ON E.Id = AppUser.EstablishmentId
                   AND (
                           UE.EstablishmentType = AppUser.EstablishmentType
                           OR LoginUser.IsAreaManager = 1
                       )
            INNER JOIN dbo.AppUser AS U
                ON AppUser.AppUserId = U.Id
                   AND U.IsAreaManager = 0
            LEFT JOIN dbo.Supplier AS S
                ON U.SupplierId = S.Id
        WHERE E.IsDeleted = 0
              AND UE.IsDeleted = 0
              AND AppUser.IsDeleted = 0
              AND U.IsDeleted = 0
              AND E.Id IN (
                              SELECT Data FROM dbo.Split(@EstablishmentId, ',')
                          );
    END;

    SELECT *
    FROM @TempTable
    GROUP BY AppUserId,
             Name
    ORDER BY Name ASC;
END;
