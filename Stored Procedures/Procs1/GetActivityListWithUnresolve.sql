--	=============================================
--	Author:			Anant bhatt
--	Create date:	01-APR-2020
--	Description:	
--	Call SP:	dbo.GetActivityListWithUnresolve 1243
--	=============================================
CREATE PROCEDURE [dbo].[GetActivityListWithUnresolve]
    @AppUserId BIGINT
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @ActivitybadgeCount AS TABLE
    (
        ActivityId BIGINT,
        ActivityName NVARCHAR(500),
        ActivityCount INT
    );

    DECLARE @UnresolveCount AS TABLE
    (
        ActivityId BIGINT,
        UnresolveCount INT
    );

    DECLARE @ActivityUserTable TABLE
    (
        ActivityId BIGINT,
        Userid BIGINT
    );

    DECLARE @UserTable AS TABLE
    (
        Id BIGINT IDENTITY,
        ActivityId BIGINT,
        ActivityName NVARCHAR(500),
        ActivityType VARCHAR(10),
        LastDays INT
    );
    INSERT INTO @UserTable
    (
        ActivityId,
        ActivityName,
        ActivityType,
        LastDays
    )
    SELECT DISTINCT
        EG.Id AS ActivityId,
        EG.EstablishmentGroupName AS ActivityName,
        EG.EstablishmentGroupType AS ActivityType,
        ISNULL(UE.ActivityLastDays, 30)
    FROM dbo.EstablishmentGroup (NOLOCK) AS EG
        INNER JOIN dbo.Establishment (NOLOCK) AS EST
            ON EST.EstablishmentGroupId = EG.Id
               AND EG.IsDeleted = 0
               AND EST.IsDeleted = 0
        INNER JOIN dbo.AppUserEstablishment UE
            ON UE.EstablishmentId = EST.Id
               AND UE.AppUserId = @AppUserId
               AND UE.IsDeleted = 0;
    DECLARE @IsManager BIT;
    SELECT @IsManager = IsAreaManager
    FROM dbo.AppUser
    WHERE Id = @AppUserId;

    IF OBJECT_ID('tempdb..#Count1', 'u') IS NOT NULL
        DROP TABLE #Count1;
    CREATE TABLE #Count1
    (
        ActivityId BIGINT,
        Count# BIT
    );
    IF OBJECT_ID('tempdb..#temp1', 'u') IS NOT NULL
        DROP TABLE #temp1;
    SELECT DISTINCT
        EstablishmentGroupId,
        UT.ActivityId,
        E.Id
    INTO #temp1
    FROM @UserTable UT
        INNER JOIN Establishment E
            ON UT.ActivityId = E.EstablishmentGroupId;
    INSERT INTO #Count1
    SELECT t.ActivityId,
           1
    FROM #temp1 t
        INNER JOIN dbo.AppUserEstablishment aue
            ON aue.EstablishmentId = t.Id
        INNER JOIN dbo.AppUser au
            ON au.Id = aue.AppUserId
               AND au.IsAreaManager = 0
               AND au.IsActive = 1
    UNION
    SELECT t.ActivityId,
           1
    FROM #temp1 t
        INNER JOIN dbo.AppUserEstablishment aue
            ON aue.EstablishmentId = t.Id
        INNER JOIN dbo.AppUser au
            ON au.Id = aue.AppUserId
               AND AppUserId = @AppUserId
               AND au.IsActive = 1
    UNION
    SELECT t.ActivityId,
           1
    FROM #temp1 t
        INNER JOIN AppManagerUserRights AMUR
            ON t.Id = AMUR.EstablishmentId
               AND AMUR.UserId = @AppUserId
        INNER JOIN dbo.AppUser AU
            ON AU.Id = AMUR.ManagerUserId
               AND AU.IsActive = 1;
    IF OBJECT_ID('tempdb..#Count0', 'u') IS NOT NULL
        DROP TABLE #Count0;
    CREATE TABLE #Count0
    (
        ActivityId BIGINT,
        Count# BIT
    );
    INSERT INTO #Count0
    SELECT UT.ActivityId,
           0
    FROM @UserTable UT
        LEFT JOIN #Count1 C1
            ON C1.ActivityId = UT.ActivityId
    WHERE C1.ActivityId IS NULL;
    IF OBJECT_ID('tempdb..#temp2', 'u') IS NOT NULL
        DROP TABLE #temp2;
    SELECT E.Id,
           C1.ActivityId
    INTO #temp2
    FROM #Count1 C1
        INNER JOIN Establishment E
            ON C1.ActivityId = E.EstablishmentGroupId;
    IF (@IsManager = 1)
    BEGIN

        INSERT INTO @ActivityUserTable
        (
            Userid,
            ActivityId
        )
        SELECT AUE.AppUserId,
               t.ActivityId
        FROM #temp2 t
            INNER JOIN AppUserEstablishment AUE
                ON t.Id = AUE.EstablishmentId
                   AND AUE.IsDeleted = 0
            INNER JOIN dbo.AppUser AU
                ON AU.Id = AUE.AppUserId
                   AND AU.IsAreaManager = 0
                   AND AU.IsActive = 1
        UNION
        SELECT AUE.AppUserId,
               t.ActivityId
        FROM #temp2 t
            INNER JOIN AppUserEstablishment AUE
                ON t.Id = AUE.EstablishmentId
                   AND AUE.AppUserId = @AppUserId
                   AND AUE.IsDeleted = 0
            INNER JOIN dbo.AppUser AU
                ON AU.Id = AUE.AppUserId
                   AND AU.IsActive = 1
        UNION
        SELECT ManagerUserId,
               t.ActivityId
        FROM #temp2 t
            INNER JOIN AppManagerUserRights AMu
                ON AMu.EstablishmentId = t.Id
                   AND AMu.UserId = @AppUserId
                   AND AMu.IsDeleted = 0
            INNER JOIN dbo.AppUser au
                ON au.Id = AMu.ManagerUserId
                   AND au.IsActive = 1
            INNER JOIN dbo.AppUserEstablishment AUE
                ON AUE.EstablishmentId = AMu.EstablishmentId;
    END;
    IF EXISTS (SELECT 1 FROM #Count0)
    BEGIN
        INSERT INTO @ActivityUserTable
        (
            Userid,
            ActivityId
        )
        SELECT DISTINCT
            U.Id AS UserId,
            C.ActivityId
        FROM dbo.AppUserEstablishment AS UE
            INNER JOIN dbo.AppUser AS LoginUser
                ON UE.AppUserId = LoginUser.Id
                   AND LoginUser.Id = @AppUserId
            INNER JOIN dbo.Establishment AS E
                ON UE.EstablishmentId = E.Id
            INNER JOIN dbo.AppUserEstablishment AS AppUser
                ON E.Id = AppUser.EstablishmentId
                   AND (
                           UE.EstablishmentType = AppUser.EstablishmentType
                           OR LoginUser.IsAreaManager = 1
                       )
            INNER JOIN dbo.AppUser AS U
                ON AppUser.AppUserId = U.Id
                   AND (
                           U.IsAreaManager = 0
                           OR U.Id = @AppUserId
                       )
            INNER JOIN #Count0 C
                ON 1 = 1
        WHERE E.IsDeleted = 0
              AND UE.IsDeleted = 0
              AND AppUser.IsDeleted = 0
              AND U.IsDeleted = 0;
    END;
    IF (@IsManager = 0)
    BEGIN
        INSERT INTO @ActivityUserTable
        (
            Userid,
            ActivityId
        )
        SELECT U.Id AS UserId,
               C.ActivityId
        FROM dbo.AppUserEstablishment AS UE
            INNER JOIN dbo.AppUser AS LoginUser
                ON UE.AppUserId = LoginUser.Id
                   AND LoginUser.Id = @AppUserId
            INNER JOIN dbo.Establishment AS E
                ON UE.EstablishmentId = E.Id
            INNER JOIN dbo.AppUserEstablishment AS AppUser
                ON E.Id = AppUser.EstablishmentId
                   AND (
                           UE.EstablishmentType = AppUser.EstablishmentType
                           OR LoginUser.IsAreaManager = 1
                       )
            INNER JOIN dbo.AppUser AS U
                ON AppUser.AppUserId = U.Id
                   AND (
                           U.IsAreaManager = 0
                           OR U.Id = @AppUserId
                       )
            INNER JOIN #Count1 C
                ON 1 = 1
        WHERE U.Id = @AppUserId
              AND E.IsDeleted = 0
              AND UE.IsDeleted = 0
              AND AppUser.IsDeleted = 0
              AND U.IsDeleted = 0
        UNION
        SELECT U.Id AS UserId,
               C.ActivityId
        FROM dbo.AppUserEstablishment AS UE
            INNER JOIN dbo.AppUser AS LoginUser
                ON UE.AppUserId = LoginUser.Id
                   AND LoginUser.Id = @AppUserId
            INNER JOIN dbo.Establishment AS E
                ON UE.EstablishmentId = E.Id
            INNER JOIN dbo.AppUserEstablishment AS AppUser
                ON E.Id = AppUser.EstablishmentId
                   AND (
                           UE.EstablishmentType = AppUser.EstablishmentType
                           OR LoginUser.IsAreaManager = 1
                       )
            INNER JOIN dbo.AppUser AS U
                ON AppUser.AppUserId = U.Id
                   AND (
                           U.IsAreaManager = 0
                           OR U.Id = @AppUserId
                       )
            INNER JOIN #Count0 C
                ON 1 = 1
        WHERE U.Id = @AppUserId
              AND E.IsDeleted = 0
              AND UE.IsDeleted = 0
              AND AppUser.IsDeleted = 0
              AND U.IsDeleted = 0;


    END;
    IF OBJECT_ID('tempdb..#UserId', 'u') IS NOT NULL
        DROP TABLE #UserId;
    CREATE TABLE #UserId
    (
        userid BIGINT,
        ActivityId BIGINT
    );
    IF OBJECT_ID('tempdb..#EstablishmentId', 'u') IS NOT NULL
        DROP TABLE #EstablishmentId;
    SELECT DISTINCT
        EST.Id,
        UT.ActivityId
    INTO #EstablishmentId
    FROM dbo.Establishment AS EST
        INNER JOIN @UserTable UT
            ON UT.ActivityId = EST.EstablishmentGroupId
        INNER JOIN dbo.AppUserEstablishment
            ON AppUserEstablishment.EstablishmentId = EST.Id
               AND dbo.AppUserEstablishment.AppUserId = @AppUserId;
    IF OBJECT_ID('tempdb..#Count11', 'u') IS NOT NULL
        DROP TABLE #Count11;
    CREATE TABLE #Count11
    (
        ActivityId BIGINT,
        count# BIT
    );
    IF (@IsManager = 1)
    BEGIN
        INSERT INTO #Count11
        SELECT DISTINCT
            UT.ActivityId,
            1 AS count#
        FROM @UserTable UT
            INNER JOIN dbo.Establishment E
                ON UT.ActivityId = E.EstablishmentGroupId
            INNER JOIN dbo.AppUserEstablishment AUE
                ON E.Id = AUE.EstablishmentId
            INNER JOIN dbo.AppUser Au
                ON Au.Id = AUE.AppUserId
                   AND (
                           Au.IsAreaManager = 0
                           OR AUE.AppUserId = @AppUserId
                       )
                   AND Au.IsActive = 1
                   AND Au.IsDeleted = 0;

        IF EXISTS
        (
            SELECT 1
            FROM @UserTable UT
                LEFT JOIN #Count11 C
                    ON C.ActivityId = UT.ActivityId
            WHERE C.ActivityId IS NULL
        )
        BEGIN
            INSERT INTO #Count11
            SELECT DISTINCT
                b.ActivityId,
                a.Count#
            FROM
            (
                SELECT DISTINCT
                    1 AS Count#
                FROM #EstablishmentId e
                    INNER JOIN AppManagerUserRights
                        ON e.Id = AppManagerUserRights.EstablishmentId
                           AND AppManagerUserRights.UserId = @AppUserId
                    INNER JOIN dbo.AppUser
                        ON dbo.AppUser.Id = AppManagerUserRights.ManagerUserId
                           AND AppManagerUserRights.IsDeleted = 0
                           AND IsActive = 1
            ) a
                CROSS JOIN
                (
                    SELECT DISTINCT
                        UT.ActivityId
                    FROM @UserTable UT
                        LEFT JOIN #Count11 C
                            ON C.ActivityId = UT.ActivityId
                    WHERE C.ActivityId IS NULL
                ) b;
        END;

        INSERT INTO #UserId
        SELECT AppUserId,
               C.ActivityId
        FROM #EstablishmentId E
            INNER JOIN #Count11 C
                ON C.ActivityId = E.ActivityId
            INNER JOIN dbo.AppUserEstablishment AUE
                ON E.Id = AUE.EstablishmentId
                   AND AUE.IsDeleted = 0
            INNER JOIN dbo.AppUser
                ON AppUser.Id = AUE.AppUserId
                   AND AppUser.IsDeleted = 0
                   AND IsActive = 1
        WHERE (
                  AppUserId = @AppUserId
                  OR IsAreaManager = 0
              )
        UNION
        SELECT ManagerUserId,
               C.ActivityId
        FROM #EstablishmentId e
            INNER JOIN #Count11 C
                ON C.ActivityId = e.ActivityId
            INNER JOIN AppManagerUserRights AMUR
                ON e.Id = AMUR.EstablishmentId
                   AND AMUR.UserId = @AppUserId
                   AND AMUR.IsDeleted = 0
            INNER JOIN dbo.AppUserEstablishment aue
                ON AMUR.EstablishmentId = aue.EstablishmentId
            INNER JOIN dbo.AppUser AU
                ON AU.Id = AMUR.ManagerUserId
                   AND AU.IsDeleted = 0
                   AND AU.IsActive = 1;
    END;
    DECLARE @Last30DaysDate DATETIME;
    SET @Last30DaysDate = DATEADD(   DAY,
                                     -
                                     (
                                         SELECT TOP 1
                                             CAST(KeyValue AS BIGINT)
                                         FROM dbo.AAAAConfigSettings
                                         WHERE KeyName = 'LastFormDays'
                                     ),
                                     GETUTCDATE()
                                 );
    IF OBJECT_ID('tempdb..#temp', 'u') IS NOT NULL
        DROP TABLE #temp;
    CREATE TABLE #temp
    (
        [SeenClientAnswerMasterId] [BIGINT] NOT NULL,
        ActivityId BIGINT
    );
    INSERT INTO #temp
    SELECT A.SeenClientAnswerMasterId,
           UT.ActivityId
    FROM dbo.View_AllAnswerMaster AS A
        INNER JOIN #UserId
            ON (
                   #UserId.userid = A.UserId
                   OR #UserId.userid = ISNULL(A.TransferFromUserId, 0)
                   OR A.UserId = 0
               )
        INNER JOIN @UserTable UT
            ON UT.ActivityId = #UserId.ActivityId
               AND A.AnswerStatus = 'Unresolved'
               AND A.CreatedOn
               BETWEEN @Last30DaysDate AND DATEADD(MINUTE, A.TimeOffSet, GETUTCDATE())
               AND A.SeenClientAnswerMasterId != 0
    GROUP BY A.SeenClientAnswerMasterId,
             UT.ActivityId;
    INSERT INTO @ActivitybadgeCount
    SELECT UT.ActivityId,
           UT.ActivityName,
           (
               SELECT
                   (
                       SELECT COUNT(1) AS Count1
                       FROM dbo.PendingNotificationWeb AS PNW
                           INNER JOIN dbo.AppUser A
                               ON A.Id = PNW.AppUserId
                           INNER JOIN dbo.SeenClientAnswerMaster SA
                               ON SA.Id = PNW.RefId
                           INNER JOIN dbo.Vw_Establishment E
                               ON E.Id = SA.EstablishmentId
                       WHERE PNW.AppUserId = @AppUserId
                             AND IsRead = 0
                             AND PNW.IsDeleted = 0
                             AND SA.IsDeleted = 0
                             AND ModuleId IN ( 8, 12 )
                             AND (
                                     A.IsAreaManager = 1
                                     OR SA.AppUserId = PNW.AppUserId
                                 )
                             AND E.EstablishmentGroupId = UT.ActivityId
                   ) +
                   (
                       SELECT COUNT(1) AS Count1
                       FROM dbo.PendingNotificationWeb AS PNW
                           INNER JOIN dbo.AppUser A
                               ON A.Id = PNW.AppUserId
                           INNER JOIN dbo.AnswerMaster AM
                               ON AM.Id = PNW.RefId
                           INNER JOIN dbo.Vw_Establishment E
                               ON E.Id = AM.EstablishmentId
                       WHERE PNW.AppUserId = @AppUserId
                             AND IsRead = 0
                             AND PNW.IsDeleted = 0
                             AND AM.IsDeleted = 0
                             AND ModuleId IN ( 7, 11 )
                             AND (
                                     AM.AppUserId = 0
                                     OR A.IsAreaManager = 1
                                     OR AM.AppUserId = PNW.AppUserId
                                 )
                             AND E.EstablishmentGroupId = UT.ActivityId
                   )
           ) AS ActivityCount
    FROM @UserTable AS UT;
    INSERT INTO @UnresolveCount
    SELECT UT.ActivityId,
           (CASE UT.ActivityType
                WHEN 'Sales' THEN
                (
                    SELECT COUNT(1)
                    FROM dbo.SeenClientAnswerMaster AS SCA
                        INNER JOIN @ActivityUserTable AS AUT
                            ON AUT.ActivityId = UT.ActivityId
                               AND AUT.Userid = SCA.AppUserId
                               AND SCA.CreatedOn
                               BETWEEN CAST(@Last30DaysDate AS DATE) AND GETUTCDATE()
                               AND SCA.IsResolved = 'Unresolved'
                               AND SCA.IsDeleted = 0
                        INNER JOIN dbo.Establishment AS E
                            ON E.Id = SCA.EstablishmentId
                               AND E.EstablishmentGroupId = UT.ActivityId
                               AND E.IsDeleted = 0
                        INNER JOIN dbo.AppUserEstablishment
                            ON AppUserEstablishment.EstablishmentId = E.Id
                               AND AppUserEstablishment.AppUserId = @AppUserId
                               AND dbo.AppUserEstablishment.IsDeleted = 0
                )
                ELSE
            (
                SELECT COUNT(1)
                FROM dbo.AnswerMaster AS AM
                    INNER JOIN dbo.Establishment AS E
                        ON E.Id = AM.EstablishmentId
                           AND E.EstablishmentGroupId = UT.ActivityId
                           AND E.IsDeleted = 0
                           AND AM.CreatedOn
                           BETWEEN CAST(@Last30DaysDate AS DATE) AND GETUTCDATE()
                           AND AM.IsResolved = 'Unresolved'
                           AND AM.IsDeleted = 0
                    INNER JOIN dbo.AppUserEstablishment
                        ON AppUserEstablishment.EstablishmentId = E.Id
                           AND AppUserEstablishment.AppUserId = @AppUserId
                           AND dbo.AppUserEstablishment.IsDeleted = 0
            )
            END
           ) AS UnresolveCount
    FROM @UserTable AS UT;

    SELECT CAST([@ActivitybadgeCount].ActivityId AS INT) AS ActivityId,
           [@ActivitybadgeCount].ActivityName AS ActivityName,          
           CAST(UnresolveCount AS INT) AS UnresolveCount
    FROM @ActivitybadgeCount
        INNER JOIN @UnresolveCount
            ON [@UnresolveCount].ActivityId = [@ActivitybadgeCount].ActivityId;

    SET NOCOUNT OFF;
END;
