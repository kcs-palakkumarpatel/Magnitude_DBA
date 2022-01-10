CREATE PROCEDURE [dbo].[GetActivityListWithPendingCountByAppUserId]
    @AppUserId BIGINT,
    @IsAllocated BIT = 0
AS
BEGIN
    SET NOCOUNT ON;
    IF OBJECT_ID('tempdb..#ActivityUserTable', 'u') IS NOT NULL
        DROP TABLE #ActivityUserTable;
    CREATE TABLE #ActivityUserTable
    (
        ActivityId BIGINT,
        Userid BIGINT
    );

    DECLARE @Url NVARCHAR(500);
    SELECT @Url = KeyValue + N'ActivityImage/'
    FROM dbo.AAAAConfigSettings WITH (NOLOCK)
    WHERE KeyName = 'DocViewerRootFolderPathCMS';

    IF OBJECT_ID('tempdb..#UserTable', 'u') IS NOT NULL
        DROP TABLE #UserTable;
    CREATE TABLE #UserTable
    (
        Id BIGINT IDENTITY,
        ActivityId BIGINT,
        ActivityType VARCHAR(10),
        LastDays INT,
        ActivityName VARCHAR(1000),
        ActivityImage VARCHAR(1000),
        DisplaySequence INT,
        StatusTimeSetting INT,
        SeenClientId BIGINT,
        QuestionnaireId BIGINT,
        IsTellUsSubmitted BIT,
        AppUserId BIGINT,
        QuestionnaireType NVARCHAR(20)
    );

    INSERT INTO #UserTable
    (
        ActivityId,
        ActivityType,
        LastDays,
        ActivityName,
        ActivityImage,
        DisplaySequence,
        StatusTimeSetting,
        SeenClientId,
        QuestionnaireId,
        IsTellUsSubmitted,
        AppUserId,
        QuestionnaireType
    )
    SELECT DISTINCT
        EG.Id AS ActivityId,
        EG.EstablishmentGroupType AS ActivityType,
        ISNULL(UE.ActivityLastDays, 30),
        EG.EstablishmentGroupName,
        EG.ActivityImagePath,
        IIF(
            ISNULL(
            (
                SELECT IIF(ISNULL(MAX(ActivitySequence), 0) = 0, EG.DisplaySequence, MAX(ActivitySequence))
                FROM dbo.AppUserEstablishment
                WHERE AppUserId = @AppUserId
                      AND EstablishmentId IN (
                                                 SELECT Id
                                                 FROM dbo.Establishment
                                                 WHERE EstablishmentGroupId = EG.Id
												 AND AppUserId = @AppUserId
                                                       AND IsDeleted = 0
                                             )
            ),
            0
                  ) = 0,
            99999,
        (
            SELECT IIF(ISNULL(MAX(ActivitySequence), 0) = 0, EG.DisplaySequence, MAX(ActivitySequence))
            FROM dbo.AppUserEstablishment
            WHERE AppUserId = @AppUserId
                  AND EstablishmentId IN (
                                             SELECT Id
                                             FROM dbo.Establishment
                                             WHERE EstablishmentGroupId = EG.Id
											 AND AppUserId = @AppUserId
                                                   AND IsDeleted = 0
                                         )
        )) AS DisplaySequence,
        ISNULL(UE.StatusSettings, 0) AS StatusTimeSetting,
        EG.SeenClientId,
        EG.QuestionnaireId,
        dbo.IsTellUsSubmitted(@AppUserId, EG.Id) AS IsTellUsSubmitted,
        @AppUserId,
        (
            SELECT QuestionnaireType
            FROM dbo.Questionnaire
            WHERE Id = EG.QuestionnaireId
        ) AS QuestionnaireType
    FROM dbo.EstablishmentGroup AS EG WITH (NOLOCK)
        INNER JOIN dbo.Establishment AS EST WITH (NOLOCK)
            ON EST.EstablishmentGroupId = EG.Id
               AND EG.IsDeleted = 0
               AND EST.IsDeleted = 0
        INNER JOIN dbo.AppUserEstablishment UE WITH (NOLOCK)
            ON UE.EstablishmentId = EST.Id
               AND UE.AppUserId = @AppUserId
               AND UE.IsDeleted = 0
    WHERE (
              @IsAllocated = 0
              OR ISNULL(EG.AllowTaskAllocations, 0) = 1
          );

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
        INNER JOIN Establishment E WITH (NOLOCK)
            ON UT.ActivityId = E.EstablishmentGroupId;

    INSERT INTO #Count1
    SELECT t.ActivityId,
           1
    FROM #temp1 t
        INNER JOIN dbo.AppUserEstablishment aue WITH (NOLOCK)
            ON aue.EstablishmentId = t.Id
        INNER JOIN dbo.AppUser au WITH (NOLOCK)
            ON au.Id = aue.AppUserId
               AND (au.IsAreaManager = 0 OR AppUserId = @AppUserId)
               AND au.IsActive = 1
               AND au.IsDeleted = 0
    --UNION
    --SELECT t.ActivityId,
    --       1
    --FROM #temp1 t
    --    INNER JOIN dbo.AppUserEstablishment aue WITH (NOLOCK)
    --        ON aue.EstablishmentId = t.Id
    --    INNER JOIN dbo.AppUser au WITH (NOLOCK)
    --        ON au.Id = aue.AppUserId
    --           AND AppUserId = @AppUserId
    --           AND au.IsActive = 1
    --           AND au.IsDeleted = 0
    UNION
    SELECT t.ActivityId,
           1
    FROM #temp1 t
        INNER JOIN AppManagerUserRights AMUR WITH (NOLOCK)
            ON t.Id = AMUR.EstablishmentId
               AND AMUR.UserId = @AppUserId
        INNER JOIN dbo.AppUser AU WITH (NOLOCK)
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
        INNER JOIN Establishment E WITH (NOLOCK)
            ON C1.ActivityId = E.EstablishmentGroupId;
    DECLARE @UserTable AS TABLE
    (
        userId BIGINT,
        ContactID BIGINT
    );
    IF (@IsAllocated = 1)
    BEGIN
        IF (@IsManager = 1)
        BEGIN

            INSERT INTO #ActivityUserTable
            (
                Userid,
                ActivityId
            )
            SELECT
                (
                    SELECT TOP 1
                        CD.ContactMasterId
                    FROM dbo.ContactDetails CD WITH (NOLOCK)
                        INNER JOIN dbo.ContactMaster CM WITH (NOLOCK)
                            ON CM.Id = CD.ContactMasterId
                               AND CM.GroupId = AU.GroupId
                    WHERE CD.QuestionTypeId = 10
                          AND AU.Email = CD.Detail
                          AND ISNULL(CD.IsDeleted, 0) = 0
                    ORDER BY CD.ContactMasterId DESC
                ) AS AppUserId,
                t.ActivityId
            FROM #temp2 t
                INNER JOIN AppUserEstablishment AUE WITH (NOLOCK)
                    ON t.Id = AUE.EstablishmentId
                       AND AUE.IsDeleted = 0
                INNER JOIN dbo.AppUser AU WITH (NOLOCK)
                    ON AU.Id = AUE.AppUserId
                       AND AU.IsAreaManager = 0
                       AND AU.IsActive = 1
                       AND AU.IsDeleted = 0
                INNER JOIN dbo.AppUserofManage AOM WITH (NOLOCK)
                    ON AOM.ApplicationUserId = AU.Id
                       AND AOM.ManagerUserId = @AppUserId
                       AND ISNULL(AOM.IsDeleted, 0) = 0
            UNION
            SELECT
                (
                    SELECT TOP 1
                        CD.ContactMasterId
                    FROM dbo.ContactDetails CD WITH (NOLOCK)
                        INNER JOIN dbo.ContactMaster CM
                            ON CM.Id = CD.ContactMasterId
                               AND CM.GroupId = AU.GroupId
                    WHERE CD.QuestionTypeId = 10
                          AND AU.Email = CD.Detail
                          AND ISNULL(CD.IsDeleted, 0) = 0
                    ORDER BY CD.ContactMasterId DESC
                ) AS AppUserId,
                t.ActivityId
            FROM #temp2 t
                INNER JOIN AppUserEstablishment AUE WITH (NOLOCK)
                    ON t.Id = AUE.EstablishmentId
                       AND AUE.IsDeleted = 0
                INNER JOIN dbo.AppUser AU WITH (NOLOCK)
                    ON AU.Id = @AppUserId
            UNION
            SELECT AUE.AppUserId,
                   t.ActivityId
            FROM #temp2 t
                INNER JOIN AppUserEstablishment AUE WITH (NOLOCK)
                    ON t.Id = AUE.EstablishmentId
                       AND AUE.AppUserId = @AppUserId
                       AND AUE.IsDeleted = 0
                INNER JOIN dbo.AppUser AU WITH (NOLOCK)
                    ON AU.Id = AUE.AppUserId
                       AND AU.IsActive = 1
                INNER JOIN dbo.AppUserofManage AOM WITH (NOLOCK)
                    ON AOM.ApplicationUserId = AU.Id
                       AND AOM.ManagerUserId = @AppUserId
                       AND ISNULL(AOM.IsDeleted, 0) = 0
            UNION
            SELECT
                (
                    SELECT TOP 1
                        CD.ContactMasterId
                    FROM dbo.ContactDetails CD
                        INNER JOIN dbo.ContactMaster CM WITH (NOLOCK)
                            ON CM.Id = CD.ContactMasterId
                               AND CM.GroupId = AU.GroupId
                    WHERE CD.QuestionTypeId = 10
                          AND AU.Email = CD.Detail
                          AND ISNULL(CD.IsDeleted, 0) = 0
                    ORDER BY CD.ContactMasterId DESC
                ) AS AppUserId,
                t.ActivityId
            FROM #temp2 t
                INNER JOIN AppManagerUserRights AMu WITH (NOLOCK)
                    ON AMu.EstablishmentId = t.Id
                       AND AMu.UserId = @AppUserId
                       AND AMu.IsDeleted = 0
                INNER JOIN dbo.AppUser au WITH (NOLOCK)
                    ON au.Id = AMu.ManagerUserId
                       AND au.IsActive = 1
                       AND au.IsDeleted = 0
                INNER JOIN dbo.AppUserEstablishment AUE WITH (NOLOCK)
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
                (
                    SELECT TOP 1
                        CD.ContactMasterId
                    FROM dbo.ContactDetails CD WITH (NOLOCK)
                        INNER JOIN dbo.ContactMaster CM WITH (NOLOCK)
                            ON CM.Id = CD.ContactMasterId
                               AND CM.GroupId = LoginUser.GroupId
                    WHERE CD.QuestionTypeId = 10
                          AND LoginUser.Email = CD.Detail
                          AND ISNULL(CD.IsDeleted, 0) = 0
                    ORDER BY CD.ContactMasterId DESC
                ) AS UserId,
                C.ActivityId
            FROM dbo.AppUserEstablishment AS UE WITH (NOLOCK)
                INNER JOIN dbo.AppUser AS LoginUser WITH (NOLOCK)
                    ON UE.AppUserId = LoginUser.Id
                       AND LoginUser.Id = @AppUserId
                INNER JOIN dbo.AppUserofManage AOM WITH (NOLOCK)
                    ON AOM.ApplicationUserId = LoginUser.Id
                       AND AOM.ManagerUserId = @AppUserId
                       AND ISNULL(AOM.IsDeleted, 0) = 0
                INNER JOIN dbo.Establishment AS E WITH (NOLOCK)
                    ON UE.EstablishmentId = E.Id
                INNER JOIN dbo.AppUserEstablishment AS AppUser WITH (NOLOCK)
                    ON E.Id = AppUser.EstablishmentId
                       AND (
                               UE.EstablishmentType = AppUser.EstablishmentType
                               OR LoginUser.IsAreaManager = 1
                           )
                INNER JOIN dbo.AppUser AS U WITH (NOLOCK)
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

            INSERT INTO @UserTable
            (
                userId
            )
            SELECT ManagerUserId
            FROM dbo.AppUserofManage WITH (NOLOCK)
            WHERE ApplicationUserId = @AppUserId
            UNION
            SELECT @AppUserId;

            INSERT INTO #ActivityUserTable
            (
                Userid,
                ActivityId
            )
            SELECT
                (
                    SELECT TOP 1
                        CD.ContactMasterId
                    FROM dbo.ContactDetails CD WITH (NOLOCK)
                        INNER JOIN dbo.ContactMaster CM WITH (NOLOCK)
                            ON CM.Id = CD.ContactMasterId
                               AND CM.GroupId = LoginUser.GroupId
                    WHERE CD.QuestionTypeId = 10
                          AND LoginUser.Email = CD.Detail
                          AND ISNULL(CD.IsDeleted, 0) = 0
                    ORDER BY CD.ContactMasterId DESC
                ) AS UserId,
                C.ActivityId
            FROM dbo.AppUserEstablishment AS UE WITH (NOLOCK)
                INNER JOIN dbo.AppUser AS LoginUser WITH (NOLOCK)
                    ON UE.AppUserId = LoginUser.Id
                INNER JOIN dbo.AppUserofManage AOM WITH (NOLOCK)
                    ON AOM.ApplicationUserId = LoginUser.Id
                       AND AOM.ManagerUserId = @AppUserId
                       AND ISNULL(AOM.IsDeleted, 0) = 0
                INNER JOIN @UserTable UTT
                    ON UTT.userId = LoginUser.Id
                INNER JOIN dbo.Establishment AS E WITH (NOLOCK)
                    ON UE.EstablishmentId = E.Id
                INNER JOIN dbo.AppUserEstablishment AS AppUser WITH (NOLOCK)
                    ON E.Id = AppUser.EstablishmentId
                       AND (
                               UE.EstablishmentType = AppUser.EstablishmentType
                               OR LoginUser.IsAreaManager = 1
                           )
                INNER JOIN dbo.AppUser AS U WITH (NOLOCK)
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
            FROM dbo.AppUserEstablishment AS UE WITH (NOLOCK)
                INNER JOIN dbo.AppUser AS LoginUser WITH (NOLOCK)
                    ON UE.AppUserId = LoginUser.Id
                INNER JOIN dbo.AppUserofManage AOM WITH (NOLOCK)
                    ON AOM.ApplicationUserId = LoginUser.Id
                       AND AOM.ManagerUserId = @AppUserId
                       AND ISNULL(AOM.IsDeleted, 0) = 0
                INNER JOIN @UserTable UTT
                    ON UTT.userId = LoginUser.Id
                INNER JOIN dbo.Establishment AS E WITH (NOLOCK)
                    ON UE.EstablishmentId = E.Id
                INNER JOIN dbo.AppUserEstablishment AS AppUser WITH (NOLOCK)
                    ON E.Id = AppUser.EstablishmentId
                       AND (
                               UE.EstablishmentType = AppUser.EstablishmentType
                               OR LoginUser.IsAreaManager = 1
                           )
                INNER JOIN dbo.AppUser AS U WITH (NOLOCK)
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
    END;
    ELSE
    BEGIN
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
                INNER JOIN AppUserEstablishment AUE WITH (NOLOCK)
                    ON t.Id = AUE.EstablishmentId
                       AND AUE.IsDeleted = 0
                INNER JOIN dbo.AppUser AU WITH (NOLOCK)
                    ON AU.Id = AUE.AppUserId
                       AND AU.IsAreaManager = 0
                       AND AU.IsActive = 1
                       AND AU.IsDeleted = 0
            UNION
            SELECT AUE.AppUserId,
                   t.ActivityId
            FROM #temp2 t
                INNER JOIN AppUserEstablishment AUE WITH (NOLOCK)
                    ON t.Id = AUE.EstablishmentId
                       AND AUE.AppUserId = @AppUserId
                       AND AUE.IsDeleted = 0
                INNER JOIN dbo.AppUser AU WITH (NOLOCK)
                    ON AU.Id = AUE.AppUserId
                       AND AU.IsActive = 1
            UNION
            SELECT ManagerUserId,
                   t.ActivityId
            FROM #temp2 t
                INNER JOIN AppManagerUserRights AMu WITH (NOLOCK)
                    ON AMu.EstablishmentId = t.Id
                       AND AMu.UserId = @AppUserId
                       AND AMu.IsDeleted = 0
                INNER JOIN dbo.AppUser au WITH (NOLOCK)
                    ON au.Id = AMu.ManagerUserId
                       AND au.IsActive = 1
                       AND au.IsDeleted = 0
                INNER JOIN dbo.AppUserEstablishment AUE WITH (NOLOCK)
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
            FROM dbo.AppUserEstablishment AS UE WITH (NOLOCK)
                INNER JOIN dbo.AppUser AS LoginUser WITH (NOLOCK)
                    ON UE.AppUserId = LoginUser.Id
                       AND LoginUser.Id = @AppUserId
                INNER JOIN dbo.Establishment AS E WITH (NOLOCK)
                    ON UE.EstablishmentId = E.Id
                INNER JOIN dbo.AppUserEstablishment AS AppUser WITH (NOLOCK)
                    ON E.Id = AppUser.EstablishmentId
                       AND (
                               UE.EstablishmentType = AppUser.EstablishmentType
                               OR LoginUser.IsAreaManager = 1
                           )
                INNER JOIN dbo.AppUser AS U WITH (NOLOCK)
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

            INSERT INTO @UserTable
            (
                userId,
                ContactID
            )
            SELECT AUOM.ManagerUserId,
                   (
                       SELECT TOP 1
                           CD.ContactMasterId
                       FROM dbo.ContactDetails CD WITH (NOLOCK)
                           INNER JOIN dbo.AppUser AU WITH (NOLOCK)
                               ON AU.Id = AUOM.ManagerUserId
                           INNER JOIN dbo.ContactMaster CM WITH (NOLOCK)
                               ON CM.Id = CD.ContactMasterId
                                  AND CM.GroupId = AU.GroupId
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
                       FROM dbo.ContactDetails CD WITH (NOLOCK)
                           INNER JOIN dbo.AppUser AU WITH (NOLOCK)
                               ON CD.Detail = AU.Email
                                  AND AU.Id = @AppUserId
                                  AND ISNULL(CD.IsDeleted, 0) = 0
                           INNER JOIN dbo.ContactMaster CM WITH (NOLOCK)
                               ON CM.Id = CD.ContactMasterId
                                  AND CM.GroupId = AU.GroupId
                   ) AS ContactID;


            INSERT INTO #ActivityUserTable
            (
                Userid,
                ActivityId
            )
            SELECT U.Id AS UserId,
                   C.ActivityId
            FROM dbo.AppUserEstablishment AS UE WITH (NOLOCK)
                INNER JOIN dbo.AppUser AS LoginUser WITH (NOLOCK)
                    ON UE.AppUserId = LoginUser.Id
                INNER JOIN dbo.Establishment AS E WITH (NOLOCK)
                    ON UE.EstablishmentId = E.Id
                INNER JOIN dbo.AppUserEstablishment AS AppUser WITH (NOLOCK)
                    ON E.Id = AppUser.EstablishmentId
                       AND (
                               UE.EstablishmentType = AppUser.EstablishmentType
                               OR LoginUser.IsAreaManager = 1
                           )
                INNER JOIN @UserTable UTT
                    ON UTT.userId = LoginUser.Id
                INNER JOIN dbo.AppUser AS U WITH (NOLOCK)
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
            FROM dbo.AppUserEstablishment AS UE WITH (NOLOCK)
                INNER JOIN dbo.AppUser AS LoginUser WITH (NOLOCK)
                    ON UE.AppUserId = LoginUser.Id
                INNER JOIN dbo.Establishment AS E WITH (NOLOCK)
                    ON UE.EstablishmentId = E.Id
                INNER JOIN @UserTable UTT
                    ON UTT.userId = LoginUser.Id
                INNER JOIN dbo.AppUserEstablishment AS AppUser WITH (NOLOCK)
                    ON E.Id = AppUser.EstablishmentId
                       AND (
                               UE.EstablishmentType = AppUser.EstablishmentType
                               OR LoginUser.IsAreaManager = 1
                           )
                INNER JOIN dbo.AppUser AS U WITH (NOLOCK)
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
    FROM dbo.Establishment AS EST WITH (NOLOCK)
        INNER JOIN #UserTable UT
            ON UT.ActivityId = EST.EstablishmentGroupId
        INNER JOIN dbo.AppUserEstablishment WITH (NOLOCK)
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
            INNER JOIN dbo.Establishment E WITH (NOLOCK)
                ON UT.ActivityId = E.EstablishmentGroupId
            INNER JOIN dbo.AppUserEstablishment AUE WITH (NOLOCK)
                ON E.Id = AUE.EstablishmentId
            INNER JOIN dbo.AppUser Au WITH (NOLOCK)
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
                    INNER JOIN AppManagerUserRights WITH (NOLOCK)
                        ON e.Id = AppManagerUserRights.EstablishmentId
                           AND AppManagerUserRights.UserId = @AppUserId
                    INNER JOIN dbo.AppUser WITH (NOLOCK)
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
            INNER JOIN dbo.AppUserEstablishment AUE WITH (NOLOCK)
                ON E.Id = AUE.EstablishmentId
                   AND AUE.IsDeleted = 0
            INNER JOIN dbo.AppUser WITH (NOLOCK)
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
            INNER JOIN AppManagerUserRights AMUR WITH (NOLOCK)
                ON e.Id = AMUR.EstablishmentId
                   AND AMUR.UserId = @AppUserId
                   AND AMUR.IsDeleted = 0
            INNER JOIN dbo.AppUserEstablishment aue WITH (NOLOCK)
                ON AMUR.EstablishmentId = aue.EstablishmentId
            INNER JOIN dbo.AppUser AU WITH (NOLOCK)
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
    FROM dbo.AnswerMaster AS Am WITH (NOLOCK)
        INNER JOIN #UserId
            ON (#UserId.userid = Am.AppUserId)
    WHERE Am.IsDeleted = 0
          AND Am.CreatedOn
          BETWEEN @Last30DaysDate AND DATEADD(MINUTE, Am.TimeOffSet, GETUTCDATE())
          AND Am.IsResolved = 'Unresolved'
          AND Am.SeenClientAnswerMasterId != 0;

    IF (@IsAllocated = 1)
    BEGIN
        SELECT UT.ActivityId,
               UT.ActivityName,
               UT.ActivityType,
               (CASE UT.ActivityType
                    WHEN 'Sales' THEN
                    (
                        SELECT COUNT(1)
                        FROM dbo.SeenClientAnswerMaster AS SCA WITH (NOLOCK)
                            INNER JOIN #ActivityUserTable AS AUT
                                ON AUT.ActivityId = UT.ActivityId
                                   AND AUT.Userid = SCA.ContactMasterId
                                   AND SCA.CreatedOn
                                   BETWEEN CAST(@Last30DaysDate AS DATE) AND GETUTCDATE()
                                   AND SCA.IsResolved = 'Unresolved'
                                   AND SCA.IsDeleted = 0
                            INNER JOIN dbo.Establishment AS E WITH (NOLOCK)
                                ON E.Id = SCA.EstablishmentId
                                   AND E.EstablishmentGroupId = UT.ActivityId
                                   AND E.IsDeleted = 0
                            INNER JOIN dbo.AppUserEstablishment WITH (NOLOCK)
                                ON AppUserEstablishment.EstablishmentId = E.Id
                                   AND AppUserEstablishment.AppUserId = @AppUserId
                                   AND dbo.AppUserEstablishment.IsDeleted = 0
                        WHERE ISNULL(SCA.IsUnAllocated, 0) = 0
                    )
                    ELSE
                (
                    SELECT COUNT(1)
                    FROM dbo.AnswerMaster AS AM
                        INNER JOIN dbo.Establishment AS E WITH (NOLOCK)
                            ON E.Id = AM.EstablishmentId
                               AND E.EstablishmentGroupId = UT.ActivityId
                               AND E.IsDeleted = 0
                               AND AM.CreatedOn
                               BETWEEN CAST(@Last30DaysDate AS DATE) AND GETUTCDATE()
                               AND AM.IsResolved = 'Unresolved'
                               AND AM.IsDeleted = 0
                        INNER JOIN dbo.AppUserEstablishment WITH (NOLOCK)
                            ON AppUserEstablishment.EstablishmentId = E.Id
                               AND AppUserEstablishment.AppUserId = @AppUserId
                               AND dbo.AppUserEstablishment.IsDeleted = 0
                )
                END
               ) AS UnresolveCount,
               ISNULL(   (CASE
                              WHEN UT.ActivityImage <> '' THEN
                                  ISNULL(@Url + UT.ActivityImage, '')
                              ELSE
                                  ''
                          END
                         ),
                         ''
                     ) AS ActivityImage,
               ISNULL(
               (
                   SELECT TOP 1
                       ISNULL(HeaderValue, 'Unresolved Count')
                   FROM dbo.HeaderSetting
                   WHERE EstablishmentGroupId = UT.ActivityId
                         AND HeaderName = 'UnResolved Count'
               ),
               'Unresolved Count'
                     ) AS PendingHeader,
               StatusTimeSetting,
               ISNULL(SeenClientId, 0) AS SeenClientId,
               ISNULL(QuestionnaireId, 0) AS QuestionnaireId,
               ISNULL(IsTellUsSubmitted, 0) AS IsTellUsSubmitted,
               AppUserId,
               ISNULL(QuestionnaireType, '') AS QuestionnaireType
        FROM #UserTable AS UT
        ORDER BY UT.DisplaySequence,
                 UT.ActivityName ASC;
    END;
    ELSE
    BEGIN
        SELECT UT.ActivityId,
               UT.ActivityName,
               UT.ActivityType,
               (CASE UT.ActivityType
                    WHEN 'Sales' THEN
                    (
                        SELECT COUNT(1)
                        FROM dbo.SeenClientAnswerMaster AS SCA WITH (NOLOCK)
                            INNER JOIN #ActivityUserTable AS AUT
                                ON AUT.ActivityId = UT.ActivityId
                                   AND AUT.Userid = SCA.AppUserId
                                   AND SCA.CreatedOn
                                   BETWEEN CAST(@Last30DaysDate AS DATE) AND GETUTCDATE()
                                   AND SCA.IsResolved = 'Unresolved'
                                   AND SCA.IsDeleted = 0
                            INNER JOIN dbo.Establishment AS E WITH (NOLOCK)
                                ON E.Id = SCA.EstablishmentId
                                   AND E.EstablishmentGroupId = UT.ActivityId
                                   AND E.IsDeleted = 0
                            INNER JOIN dbo.AppUserEstablishment WITH (NOLOCK)
                                ON AppUserEstablishment.EstablishmentId = E.Id
                                   AND AppUserEstablishment.AppUserId = @AppUserId
                                   AND dbo.AppUserEstablishment.IsDeleted = 0
                        WHERE ISNULL(SCA.IsUnAllocated, 0) = 0
                    )
                    ELSE
                (
                    SELECT COUNT(1)
                    FROM dbo.AnswerMaster AS AM WITH (NOLOCK)
                        INNER JOIN dbo.Establishment AS E WITH (NOLOCK)
                            ON E.Id = AM.EstablishmentId
                               AND E.EstablishmentGroupId = UT.ActivityId
                               AND E.IsDeleted = 0
                               AND AM.CreatedOn
                               BETWEEN CAST(@Last30DaysDate AS DATE) AND GETUTCDATE()
                               AND AM.IsResolved = 'Unresolved'
                               AND AM.IsDeleted = 0
                        INNER JOIN dbo.AppUserEstablishment WITH (NOLOCK)
                            ON AppUserEstablishment.EstablishmentId = E.Id
                               AND AppUserEstablishment.AppUserId = @AppUserId
                               AND dbo.AppUserEstablishment.IsDeleted = 0
                )
                END
               ) AS UnresolveCount,
               ISNULL(   (CASE
                              WHEN UT.ActivityImage <> '' THEN
                                  ISNULL(@Url + UT.ActivityImage, '')
                              ELSE
                                  ''
                          END
                         ),
                         ''
                     ) AS ActivityImage,
               ISNULL(
               (
                   SELECT TOP 1
                       ISNULL(HeaderValue, 'Unresolved Count')
                   FROM dbo.HeaderSetting
                   WHERE EstablishmentGroupId = UT.ActivityId
                         AND HeaderName = 'UnResolved Count'
               ),
               'Unresolved Count'
                     ) AS PendingHeader,
               StatusTimeSetting,
               ISNULL(SeenClientId, 0) AS SeenClientId,
               ISNULL(QuestionnaireId, 0) AS QuestionnaireId,
               ISNULL(IsTellUsSubmitted, 0) AS IsTellUsSubmitted,
               AppUserId,
               ISNULL(QuestionnaireType, '') AS QuestionnaireType
        FROM #UserTable AS UT
        ORDER BY UT.DisplaySequence,
                 UT.ActivityName;
    END;
	SET NOCOUNT OFF;
END;
