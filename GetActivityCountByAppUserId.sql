CREATE PROCEDURE dbo.GetActivityCountByAppUserId @AppUserId BIGINT
AS
BEGIN
    SET NOCOUNT ON;
    SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

    DECLARE @AppUserContactMasterID BIGINT;

    SELECT @AppUserContactMasterID = CD.ContactMasterId
    FROM dbo.ContactDetails CD
        INNER JOIN dbo.AppUser AP
            ON AP.Email = CD.Detail
               AND AP.Id = @AppUserId
               AND ISNULL(CD.IsDeleted, 0) = 0
        INNER JOIN dbo.ContactMaster CM
            ON CM.Id = CD.ContactMasterId
               AND AP.GroupId = CM.GroupId;
    IF OBJECT_ID('tempdb..#ActivitybadgeCount', 'u') IS NOT NULL
        DROP TABLE #ActivitybadgeCount;

    CREATE TABLE #ActivitybadgeCount
    (
        ActivityId BIGINT,
        ActivityCount INT,
        AllowTaskAllocations BIT
    );

    IF OBJECT_ID('tempdb..#UnresolveCount', 'u') IS NOT NULL
        DROP TABLE #UnresolveCount;

    CREATE TABLE #UnresolveCount
    (
        ActivityId BIGINT,
        UnresolveCount INT
    );

    IF OBJECT_ID('tempdb..#Response', 'u') IS NOT NULL
        DROP TABLE #Response;
    CREATE TABLE #Response
    (
        ActivityId BIGINT,
        ResponseCount INT
    );

    IF OBJECT_ID('tempdb..#BadgeIn', 'u') IS NOT NULL
        DROP TABLE #BadgeIn;
    CREATE TABLE #BadgeIn
    (
        ActivityId BIGINT,
        InCount INT
    );


    IF OBJECT_ID('tempdb..#BadgeOut', 'u') IS NOT NULL
        DROP TABLE #BadgeOut;
    CREATE TABLE #BadgeOut
    (
        ActivityId BIGINT,
        OutCount INT
    );


    IF OBJECT_ID('tempdb..#ActivityUserTable', 'u') IS NOT NULL
        DROP TABLE #ActivityUserTable;
    CREATE TABLE #ActivityUserTable
    (
        ActivityId BIGINT,
        Userid BIGINT
    );

    IF OBJECT_ID('tempdb..#UserTable', 'u') IS NOT NULL
        DROP TABLE #UserTable;
    CREATE TABLE #UserTable
    (
        Id BIGINT IDENTITY,
        ActivityId BIGINT,
        ActivityType VARCHAR(10),
        LastDays INT,
        AllowTaskAllocations BIT
    );

    INSERT INTO #UserTable
    (
        ActivityId,
        ActivityType,
        LastDays,
        AllowTaskAllocations
    )
    SELECT DISTINCT
        EG.Id AS ActivityId,
        EG.EstablishmentGroupType AS ActivityType,
        ISNULL(UE.ActivityLastDays, 30),
        ISNULL(EG.AllowTaskAllocations, 0) AS AllowTaskAllocations
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
    FROM #UserTable UT
        INNER JOIN Establishment E
            ON UT.ActivityId = E.EstablishmentGroupId AND E.IsDeleted = 0;

    INSERT INTO #Count1
    SELECT t.ActivityId,
           1
    FROM #temp1 t
        INNER JOIN dbo.AppUserEstablishment aue
            ON aue.EstablishmentId = t.Id AND aue.IsDeleted = 0
        INNER JOIN dbo.AppUser au
            ON au.Id = aue.AppUserId
               AND au.IsAreaManager = 0
               AND au.IsActive = 1
               AND au.IsDeleted = 0
    UNION
    SELECT t.ActivityId,
           1
    FROM #temp1 t
        INNER JOIN dbo.AppUserEstablishment aue
            ON aue.EstablishmentId = t.Id  AND aue.IsDeleted = 0
        INNER JOIN dbo.AppUser au
            ON au.Id = aue.AppUserId
               AND AppUserId = @AppUserId
               AND au.IsActive = 1
               AND au.IsDeleted = 0
    UNION
    SELECT t.ActivityId,
           1
    FROM #temp1 t
        INNER JOIN AppManagerUserRights AMUR
            ON t.Id = AMUR.EstablishmentId
               AND AMUR.UserId = @AppUserId AND AMUR.IsDeleted = 0
        INNER JOIN dbo.AppUser AU
            ON AU.Id = AMUR.ManagerUserId
               AND AU.IsActive = 1
               AND AU.IsDeleted = 0;


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
    FROM #UserTable UT
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
            ON C1.ActivityId = E.EstablishmentGroupId AND E.IsDeleted = 0;

    IF (@IsManager = 1)
    BEGIN

        INSERT INTO #ActivityUserTable
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
                   AND AU.IsDeleted = 0
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
                   AND au.IsDeleted = 0
            INNER JOIN dbo.AppUserEstablishment AUE
                ON AUE.EstablishmentId = AMu.EstablishmentId;
    END;




    IF EXISTS (SELECT 1 FROM #Count0)
    BEGIN
        INSERT INTO #ActivityUserTable
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
        DECLARE @UserTable AS TABLE
        (
            userId BIGINT,
            ContactID BIGINT
        );
        INSERT INTO @UserTable
        (
            userId,
            ContactID
        )
        SELECT AUOM.ManagerUserId,
               (
                   SELECT TOP 1
                       CD.ContactMasterId
                   FROM dbo.ContactDetails CD
                       INNER JOIN dbo.AppUser AU
                           ON AU.Id = AUOM.ManagerUserId
                       INNER JOIN dbo.ContactMaster CM
                           ON CM.Id = CD.ContactMasterId
                              AND CM.GroupId = AU.GroupId AND CM.IsDeleted = 0
                   WHERE CD.QuestionTypeId = 10
                         AND AU.Email = CD.Detail
                         AND ISNULL(CD.IsDeleted, 0) = 0
                   ORDER BY CD.ContactMasterId DESC
               )
        FROM dbo.AppUserofManage AUOM
        WHERE AUOM.ApplicationUserId = @AppUserId
        UNION
        SELECT @AppUserId,
               (
                   SELECT TOP 1
                       CD.ContactMasterId
                   FROM dbo.ContactDetails CD
                       INNER JOIN dbo.AppUser AU
                           ON CD.Detail = AU.Email
                              AND AU.Id = @AppUserId
                              AND ISNULL(CD.IsDeleted, 0) = 0
					   INNER JOIN dbo.ContactMaster CM
                           ON CM.Id = CD.ContactMasterId
                              AND CM.GroupId = AU.GroupId AND CM.IsDeleted = 0
               ) AS ContactID;


        INSERT INTO #ActivityUserTable
        (
            Userid,
            ActivityId
        )
        SELECT U.Id AS UserId,
               C.ActivityId
        FROM dbo.AppUserEstablishment AS UE
            INNER JOIN dbo.AppUser AS LoginUser
                ON UE.AppUserId = LoginUser.Id
            INNER JOIN dbo.Establishment AS E
                ON UE.EstablishmentId = E.Id
            INNER JOIN dbo.AppUserEstablishment AS AppUser
                ON E.Id = AppUser.EstablishmentId
                   AND (
                           UE.EstablishmentType = AppUser.EstablishmentType
                           OR LoginUser.IsAreaManager = 1
                       )
            INNER JOIN @UserTable UTT
                ON UTT.userId = LoginUser.Id
            INNER JOIN dbo.AppUser AS U
                ON AppUser.AppUserId = U.Id
                   AND (
                           U.IsAreaManager = 0
                           OR U.Id = UTT.userId
                       )
            INNER JOIN #Count1 C
                ON 1 = 1
        WHERE U.Id = UTT.userId
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
            INNER JOIN dbo.Establishment AS E
                ON UE.EstablishmentId = E.Id
            INNER JOIN @UserTable UTT
                ON UTT.userId = LoginUser.Id
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
                           OR U.Id = UTT.userId
                       )
            INNER JOIN #Count0 C
                ON 1 = 1
        WHERE U.Id = UTT.userId
              AND E.IsDeleted = 0
              AND UE.IsDeleted = 0
              AND AppUser.IsDeleted = 0
              AND U.IsActive = 1
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
        INNER JOIN #UserTable UT
            ON UT.ActivityId = EST.EstablishmentGroupId
        INNER JOIN dbo.AppUserEstablishment
            ON AppUserEstablishment.EstablishmentId = EST.Id
               AND dbo.AppUserEstablishment.AppUserId = @AppUserId
               AND AppUserEstablishment.IsDeleted = 0;

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
        FROM #UserTable UT
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
            FROM #UserTable UT
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
                    FROM #UserTable UT
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
    CREATE TABLE #temp ([SeenClientAnswerMasterId] [BIGINT] NOT NULL);

    INSERT INTO #temp
    SELECT DISTINCT
        ISNULL(Am.SeenClientAnswerMasterId, 0)
    FROM dbo.AnswerMaster AS Am
        INNER JOIN #UserId
            ON (#UserId.userid = Am.AppUserId)
    WHERE Am.IsDeleted = 0
          AND Am.CreatedOn
          BETWEEN @Last30DaysDate AND DATEADD(MINUTE, Am.TimeOffSet, GETUTCDATE())
          AND Am.IsResolved = 'Unresolved'
          AND Am.SeenClientAnswerMasterId != 0;

    INSERT INTO #Response
    SELECT ActivityId,
           SUM(Data)
    FROM
    (
        SELECT COUNT(c.Id) AS Data,
               U.ActivityId
        FROM dbo.ContactDetails AS c
            INNER JOIN dbo.AppUser AS App
                ON c.Detail = App.Email
                   AND c.IsDeleted = 0
                   AND c.QuestionTypeId = 10
                   AND App.Id = @AppUserId
            INNER JOIN SeenClientAnswerMaster AS A
                ON 1 = 1
                   AND A.CreatedOn
                   BETWEEN @Last30DaysDate AND GETUTCDATE()
                   AND A.IsResolved = 'Unresolved'
                   AND A.IsDeleted = 0
            INNER JOIN #UserId U
                ON U.userid = A.AppUserId
            LEFT JOIN #temp t
                ON t.SeenClientAnswerMasterId = A.Id
            INNER JOIN AppUserEstablishment AUE
                ON A.EstablishmentId = AUE.EstablishmentId
                   AND AUE.AppUserId = @AppUserId
                   AND AUE.IsDeleted = 0
            INNER JOIN dbo.Establishment e
                ON e.Id = AUE.EstablishmentId
                   AND e.EstablishmentGroupId = U.ActivityId
                   AND e.IsDeleted = 0
            INNER JOIN dbo.SeenClientAnswerChild AS SA
                ON SA.ContactMasterId = c.ContactMasterId
                   AND SA.SeenClientAnswerMasterId = A.Id
        WHERE t.SeenClientAnswerMasterId IS NULL
        GROUP BY U.ActivityId
        UNION ALL
        SELECT COUNT(C.Id) AS Data,
               U.ActivityId
        FROM dbo.ContactDetails AS C
            INNER JOIN SeenClientAnswerMaster A
                ON C.ContactMasterId = A.ContactMasterId
                   AND A.CreatedOn
                   BETWEEN @Last30DaysDate AND GETUTCDATE()
                   AND A.IsResolved = 'Unresolved'
                   AND A.IsDeleted = 0
            INNER JOIN #UserId U
                ON U.userid = A.AppUserId
            INNER JOIN dbo.AppUser AS App
                ON App.Id = @AppUserId
                   AND C.Detail = App.Email
                   AND QuestionTypeId = 10
            INNER JOIN dbo.AppUserEstablishment AUE
                ON AUE.EstablishmentId = A.EstablishmentId
                   AND AUE.AppUserId = @AppUserId
                   AND AUE.IsDeleted = 0
            INNER JOIN dbo.Establishment e
                ON e.Id = AUE.EstablishmentId
                   AND e.EstablishmentGroupId = U.ActivityId
                   AND e.IsDeleted = 0
            LEFT JOIN #temp t
                ON t.SeenClientAnswerMasterId = A.Id
        WHERE t.SeenClientAnswerMasterId IS NULL
        GROUP BY U.ActivityId
    ) a
    GROUP BY ActivityId;

    INSERT INTO #ActivitybadgeCount
    SELECT UT.ActivityId,
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
           ) AS ActivityCount,
           UT.AllowTaskAllocations
    FROM #UserTable AS UT;
    DECLARE @IsAppManagerAvailable BIT = 0;
    IF EXISTS
    (
        SELECT 1
        FROM dbo.AppManagerUserRights
        WHERE UserId = @AppUserId
              AND ISNULL(IsDeleted, 0) = 0
    )
    BEGIN
        SET @IsAppManagerAvailable = 1;
    END;

    INSERT INTO #UnresolveCount
    SELECT UT.ActivityId,
           (CASE UT.ActivityType
                WHEN 'Sales' THEN
                (
                    SELECT COUNT(1)
                    FROM dbo.SeenClientAnswerMaster AS SCA
                        INNER JOIN #ActivityUserTable AS AUT
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
                    WHERE ISNULL(SCA.IsUnAllocated, 0) = 0
                          AND (
                                  (
                                      SCA.ContactMasterId IN (
                                                                 SELECT ContactID FROM @UserTable UTA WHERE UTA.userId = @AppUserId
                                                             )
                                      OR SCA.AppUserId = @AppUserId
                                      OR (
                                             ISNULL(SCA.ContactGroupId, 0) <> 0
                                             OR @AppUserContactMasterID IN (
                                                                               SELECT ContactMasterId
                                                                               FROM dbo.ContactGroupRelation
                                                                               WHERE ContactGroupId = SCA.ContactGroupId
                                                                                     AND ISNULL(IsDeleted, 0) = 0
                                                                           )
                                         )
                                  )
                                  OR @IsManager = 1
                              )
                          --AND (
                          --        @IsAppManagerAvailable = 0
                          --        OR (SCA.AppUserId IN (
                          --                                 SELECT AMR.ManagerUserId
                          --                                 FROM dbo.AppManagerUserRights AMR
                          --                                 WHERE AMR.UserId = @AppUserId
                          --                                       AND ISNULL(AMR.IsDeleted, 0) = 0
                          --                                       AND AMR.EstablishmentId = E.Id
                          --                                 UNION ALL
                          --                                 SELECT @AppUserId
                          --                             )
                          --           )
                          --    )
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
    FROM #UserTable AS UT;

    INSERT INTO #BadgeIn
    SELECT UT.ActivityId,
           (CASE UT.ActivityType
                WHEN 'Sales' THEN
                (
                    SELECT COUNT(1) AS INCount
                    FROM #ActivityUserTable AS AUT
                        INNER JOIN dbo.AppUser A
                            ON A.Id = AUT.Userid
                               AND AUT.ActivityId = UT.ActivityId
                        INNER JOIN AnswerMaster AM
                            ON AM.AppUserId = A.Id
                               AND AM.IsDeleted = 0
                               AND AM.CreatedOn
                               BETWEEN DATEADD(DAY, (UT.LastDays * -1), GETUTCDATE()) AND GETUTCDATE()
                        INNER JOIN dbo.Establishment E
                            ON E.Id = AM.EstablishmentId
                               AND E.EstablishmentGroupId = UT.ActivityId
                               AND E.Id IN (
                                               SELECT Id FROM #EstablishmentId WHERE ActivityId = UT.ActivityId
                                           )
                    WHERE (
                              AM.AppUserId = 0
                              OR A.IsAreaManager = 1
                              OR AM.AppUserId = A.Id
                          )
                )
                ELSE
            (
                SELECT COUNT(1) AS INCount
                FROM dbo.AnswerMaster AS AM
                    INNER JOIN dbo.Establishment E
                        ON AM.EstablishmentId = E.Id
                           AND E.EstablishmentGroupId = UT.ActivityId
                           AND E.Id IN (
                                           SELECT Id FROM #EstablishmentId WHERE ActivityId = UT.ActivityId
                                       )
                           AND AM.CreatedOn
                           BETWEEN DATEADD(DAY, (UT.LastDays * -1), GETUTCDATE()) AND GETUTCDATE()
                           AND AM.IsDeleted = 0
            )
            END
           ) AS InCount
    FROM #UserTable AS UT;


    INSERT INTO #BadgeOut
    SELECT UT.ActivityId,
           COUNT(1) AS OutCount
    FROM #ActivityUserTable AS AUT
        INNER JOIN #UserTable UT
            ON AUT.ActivityId = UT.ActivityId
        INNER JOIN dbo.SeenClientAnswerMaster AS SAM
            ON AUT.Userid = SAM.AppUserId
               AND SAM.CreatedOn
               BETWEEN DATEADD(DAY, (UT.LastDays * -1), GETUTCDATE()) AND GETUTCDATE()
               AND SAM.IsDeleted = 0
        INNER JOIN dbo.Establishment E
            ON E.Id = SAM.EstablishmentId
               AND E.EstablishmentGroupId = UT.ActivityId
               AND E.Id IN (
                               SELECT Id FROM #EstablishmentId WHERE ActivityId = UT.ActivityId
                           )
    GROUP BY UT.ActivityId;


    SELECT CAST(#ActivitybadgeCount.ActivityId AS INT) AS ActivityId,
           CAST(ISNULL(ActivityCount, 0) AS INT) AS ActivityCount,
           CAST(ISNULL(InCount, 0) AS INT) AS InCount,
           CAST(ISNULL(OutCount, 0) AS INT) AS OutCount,
           CAST(ISNULL(ResponseCount, 0) AS INT) AS ResponseCount,
           CAST(UnresolveCount AS INT) AS UnresolveCount,
           #ActivitybadgeCount.AllowTaskAllocations
    FROM #ActivitybadgeCount
        LEFT JOIN #BadgeIn
            ON #BadgeIn.ActivityId = #ActivitybadgeCount.ActivityId
        LEFT JOIN #BadgeOut
            ON #BadgeOut.ActivityId = #ActivitybadgeCount.ActivityId
        LEFT JOIN #Response
            ON #Response.ActivityId = #ActivitybadgeCount.ActivityId
        INNER JOIN #UnresolveCount
            ON #UnresolveCount.ActivityId = #ActivitybadgeCount.ActivityId;

    SET TRANSACTION ISOLATION LEVEL READ COMMITTED;
    SET NOCOUNT OFF;

END;
