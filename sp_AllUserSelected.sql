-- =============================================  
-- Author:  <Author,,Name>  
-- Create date: <Create Date, ,>  
-- Description: <Description, ,>  
-- select dbo.AllUserSelected(313,'1356',919)  

-- =============================================  
CREATE PROCEDURE [dbo].[sp_AllUserSelected]  
@AppUserId BIGINT,
        @EstablishmentId NVARCHAR(MAX),
        @ActivityId BIGINT

AS  
BEGIN

    DECLARE @Count BIGINT = 0;
    DECLARE @IsManager BIT;

    SELECT @IsManager = IsAreaManager
    FROM dbo.AppUser
    WHERE Id = @AppUserId;


    IF (@EstablishmentId = '0')
    BEGIN

        DECLARE @listStr NVARCHAR(MAX);
        SELECT @listStr = COALESCE(@listStr + ', ', '') + CONVERT(NVARCHAR(50), ISNULL(EST.Id, ''))
        FROM dbo.Vw_Establishment AS EST
            INNER JOIN dbo.AppUserEstablishment
                ON EST.EstablishmentGroupId = @ActivityId
                   AND AppUserEstablishment.EstablishmentId = EST.Id
        WHERE dbo.AppUserEstablishment.AppUserId = @AppUserId;

        SET @EstablishmentId = @listStr;
    END;


    IF EXISTS
    (
        SELECT 1
        FROM dbo.AppUserEstablishment AUE
            INNER JOIN dbo.Vw_Establishment AS E
                ON E.EstablishmentGroupId = @ActivityId
                   AND E.Id = AUE.EstablishmentId
                   AND AUE.IsDeleted = 0
            INNER JOIN dbo.AppUser AU
                ON AU.Id = AUE.AppUserId
                   AND (
                           AU.IsAreaManager = 0
                           OR AUE.AppUserId = @AppUserId
                       )
                   AND AU.IsActive = 1
    )
    BEGIN
        SET @Count = 1;
    END;


    IF @Count = 0
    BEGIN
        IF EXISTS
        (
            SELECT 1
            FROM AppManagerUserRights AMU
                INNER JOIN
                (SELECT Data FROM dbo.Split(@EstablishmentId, ',') ) AS E
                    ON E.Data = AMU.EstablishmentId
                       AND AMU.UserId = @AppUserId
                       AND AMU.IsDeleted = 0
                INNER JOIN dbo.AppUser AU
                    ON AU.Id = AMU.ManagerUserId
                       AND AU.IsActive = 1
        )
        BEGIN
            SET @Count = 1;
        END;
    END;


    -- DECLARE @TempTable TABLE
    CREATE TABLE #TempTable (UserId BIGINT);

    --DECLARE @TempUserTable TABLE
    CREATE TABLE #TempUserTable (UserId BIGINT);

    IF (@IsManager = 1)
    BEGIN
        IF (@Count > 0)
        BEGIN
            INSERT INTO #TempUserTable
            (
                UserId
            )
			SELECT AUE.AppUserId
			FROM dbo.AppUserEstablishment AUE
			INNER JOIN
			(SELECT Data FROM dbo.Split(@EstablishmentId, ',') ) AS E
			ON E.Data = AUE.EstablishmentId
				AND AUE.IsDeleted = 0
			INNER JOIN dbo.AppUser AU
			ON AU.Id = AUE.AppUserId
				AND (
						AU.IsAreaManager = 0
						OR AUE.AppUserId = @AppUserId
					)
				AND AU.IsActive = 1
            UNION
            SELECT AMUR.ManagerUserId
            FROM AppManagerUserRights AMUR
			 INNER JOIN
                (SELECT Data FROM dbo.Split(@EstablishmentId, ',') ) AS E
                    ON E.Data = AMUR.EstablishmentId
                       AND AMUR.IsDeleted = 0
                INNER JOIN dbo.AppUser
                    ON dbo.AppUser.Id = AMUR.ManagerUserId
                       AND AMUR.UserId = @AppUserId
               
                       AND IsActive = 1
                INNER JOIN dbo.AppUserEstablishment AUE
                    ON AMUR.EstablishmentId = AUE.EstablishmentId
            GROUP BY ManagerUserId;


            INSERT INTO #TempTable
            (
                UserId
            )
            SELECT UserId
            FROM #TempUserTable;
        END;
        ELSE
        BEGIN
            INSERT INTO #TempTable
            (
                UserId
            )
            SELECT U.Id AS UserId
            FROM dbo.AppUserEstablishment AS UE
                INNER JOIN dbo.AppUser AS LoginUser
                    ON LoginUser.Id = @AppUserId
                       AND  UE.AppUserId = LoginUser.Id
					       AND UE.IsDeleted = 0
                INNER JOIN dbo.Vw_Establishment AS E
                    ON UE.EstablishmentId = E.Id    AND	 E.IsDeleted = 0
                INNER JOIN dbo.EstablishmentGroup AS Eg
                    ON Eg.Id = E.EstablishmentGroupId
                INNER JOIN dbo.AppUserEstablishment AS AppUser
                    ON E.Id = AppUser.EstablishmentId
                       AND (
                               UE.EstablishmentType = AppUser.EstablishmentType
                               OR LoginUser.IsAreaManager = 1
                           ) AND AppUser.IsDeleted = 0
                INNER JOIN dbo.AppUser AS U
                    ON AppUser.AppUserId = U.Id
                       AND (
                               U.IsAreaManager = 0
                               OR U.Id = @AppUserId
                           )
				AND U.IsDeleted = 0;
        END;
    END;
    ELSE
    BEGIN
        INSERT INTO #TempTable
        (
            UserId
        )
        SELECT U.Id AS UserId
        FROM dbo.AppUserEstablishment AS UE
            INNER JOIN dbo.AppUser AS LoginUser
                ON 
                    LoginUser.Id = @AppUserId AND UE.AppUserId = LoginUser.Id AND UE.IsDeleted = 0
            INNER JOIN dbo.Vw_Establishment AS E
                ON UE.EstablishmentId = E.Id  AND E.IsDeleted = 0
            INNER JOIN dbo.EstablishmentGroup AS Eg
                ON Eg.Id = E.EstablishmentGroupId
            INNER JOIN dbo.AppUserEstablishment AS AppUser
                ON E.Id = AppUser.EstablishmentId
                   AND (
                           UE.EstablishmentType = AppUser.EstablishmentType
                           OR LoginUser.IsAreaManager = 1
                       ) AND AppUser.IsDeleted = 0
            INNER JOIN dbo.AppUser AS U
                ON AppUser.AppUserId = U.Id
                   AND (
                           U.IsAreaManager = 0
                           OR U.Id = @AppUserId
                       )
			  AND	 U.Id = @AppUserId
              AND U.IsDeleted = 0;
    END;



    DECLARE @listStrFinal NVARCHAR(MAX);
    BEGIN
        SELECT @listStrFinal = COALESCE(@listStrFinal + ', ', '') + CONVERT(NVARCHAR(50), ISNULL(UserId, ''))
        FROM #TempTable
        GROUP BY UserId
        ORDER BY UserId;
    END;

    SELECT @listStrFinal;
--     RETURN @listStrFinal;  
END;
