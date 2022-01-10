-- =============================================
-- Author:		Krishna Panchal
-- Create date:	22-Jan-2021
-- Description:	Get allocated task list count User wise
-- Call SP    : dbo.GetAllocatedTaskListCountUserWise 7889,33337, 1246
-- =============================================
CREATE PROCEDURE [dbo].[GetAllocatedTaskListCountUserWise2]
    @ActivityId BIGINT,
    @EstablishmentId BIGINT,
    @AppUserId BIGINT
AS
BEGIN;
    DECLARE @Url NVARCHAR(500);
    SELECT @Url = KeyValue + N'AppUser/'
    FROM dbo.AAAAConfigSettings
    WHERE KeyName = 'DocViewerRootFolderPathCMS';

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
        LastDays INT
    );

    INSERT INTO #UserTable
    (
        ActivityId,
        ActivityType,
        LastDays
    )
    SELECT DISTINCT
           EG.Id AS ActivityId,
           EG.EstablishmentGroupType AS ActivityType,
           ISNULL(UE.ActivityLastDays, 30)
    FROM dbo.EstablishmentGroup
        (NOLOCK) AS EG
        INNER JOIN dbo.Establishment
        (NOLOCK) AS EST
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
               AND au.IsDeleted = 0
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
               AND au.IsDeleted = 0
    UNION
    SELECT t.ActivityId,
           1
    FROM #temp1 t
        INNER JOIN AppManagerUserRights AMUR
            ON t.Id = AMUR.EstablishmentId
               AND AMUR.UserId = @AppUserId
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
            ON C1.ActivityId = E.EstablishmentGroupId;

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
                   AND
                   (
                       UE.EstablishmentType = AppUser.EstablishmentType
                       OR LoginUser.IsAreaManager = 1
                   )
            INNER JOIN dbo.AppUser AS U
                ON AppUser.AppUserId = U.Id
                   AND
                   (
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
                   AND LoginUser.Id = @AppUserId
            INNER JOIN dbo.Establishment AS E
                ON UE.EstablishmentId = E.Id
            INNER JOIN dbo.AppUserEstablishment AS AppUser
                ON E.Id = AppUser.EstablishmentId
                   AND
                   (
                       UE.EstablishmentType = AppUser.EstablishmentType
                       OR LoginUser.IsAreaManager = 1
                   )
            INNER JOIN dbo.AppUser AS U
                ON AppUser.AppUserId = U.Id
                   AND
                   (
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
                   AND
                   (
                       UE.EstablishmentType = AppUser.EstablishmentType
                       OR LoginUser.IsAreaManager = 1
                   )
            INNER JOIN dbo.AppUser AS U
                ON AppUser.AppUserId = U.Id
                   AND
                   (
                       U.IsAreaManager = 0
                       OR U.Id = @AppUserId
                   )
            INNER JOIN #Count0 C
                ON 1 = 1
        WHERE U.Id = @AppUserId
              AND E.IsDeleted = 0
              AND UE.IsDeleted = 0
              AND AppUser.IsDeleted = 0
              AND U.IsActive = 1
              AND U.IsDeleted = 0;
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
    IF OBJECT_ID('tempdb..#AcitviyWiseCount', 'u') IS NOT NULL
        DROP TABLE #AcitviyWiseCount;
    CREATE TABLE #AcitviyWiseCount
    (
        ActivityCount BIGINT,
        ActivityId BIGINT,
        StatusId INT,
        AppUserId BIGINT,
        AppUserName VARCHAR(100)
    );

    INSERT INTO #AcitviyWiseCount
    (
        ActivityCount,
        ActivityId,
        StatusId,
        AppUserId,
        AppUserName
    )
    SELECT ISNULL(COUNT(1), 0),
           AUT.ActivityId,
           ES.StatusIconImageId AS statusId,
           SCA.AppUserId,
           AU.Name
    FROM dbo.SeenClientAnswerMaster AS SCA
        INNER JOIN #ActivityUserTable AS AUT
            ON AUT.Userid = SCA.AppUserId
               AND SCA.CreatedOn
               BETWEEN CAST(@Last30DaysDate AS DATE) AND GETUTCDATE()
               AND SCA.IsResolved = 'Unresolved'
               AND SCA.IsDeleted = 0
               AND ISNULL(SCA.IsUnAllocated, 0) = 0
        INNER JOIN #UserTable UT
            ON UT.ActivityId = AUT.ActivityId
               AND UT.ActivityType = 'Task'
        INNER JOIN dbo.Establishment AS E
            ON E.Id = SCA.EstablishmentId
               AND E.EstablishmentGroupId = UT.ActivityId
               AND E.IsDeleted = 0
        INNER JOIN dbo.AppUserEstablishment AUE
            ON AUE.EstablishmentId = E.Id
               AND AUE.AppUserId = @AppUserId
               AND AUE.IsDeleted = 0
        INNER JOIN dbo.StatusHistory AS SH
            ON SH.Id = SCA.StatusHistoryId
               AND SH.IsDeleted = 0
        INNER JOIN dbo.EstablishmentStatus AS ES
            ON ES.Id = SH.EstablishmentStatusId
               AND ES.IsDeleted = 0
       -- INNER JOIN dbo.StatusIconImage AS SI
           -- ON SI.Id = ES.StatusIconImageId
        INNER JOIN dbo.AppUser AU
            ON AU.Id = SCA.AppUserId
    WHERE UT.ActivityId = @ActivityId
          AND E.Id = @EstablishmentId
    GROUP BY ES.StatusIconImageId,
             AUT.ActivityId,
             SCA.AppUserId,
             AU.Name;

    IF OBJECT_ID('tempdb..#UserTotaltask', 'u') IS NOT NULL
        DROP TABLE #UserTotaltask;
    CREATE TABLE #UserTotaltask
    (
        Totaltask BIGINT,
        AppUserId BIGINT,
        AppUserName VARCHAR(100)
    );
    INSERT INTO #UserTotaltask
    SELECT SUM(ISNULL(ActivityCount, 0)) AS TotalTask,
           AppUserId,
           AppUserName
    FROM #AcitviyWiseCount
    GROUP BY AppUserId,
             AppUserName;

    IF OBJECT_ID('tempdb..#UserTotalCompleted', 'u') IS NOT NULL
        DROP TABLE #UserTotalCompleted;
    CREATE TABLE #UserTotalCompleted
    (
        Totaltask BIGINT,
        AppUserId BIGINT
    );
    INSERT INTO #UserTotalCompleted
    SELECT SUM(ISNULL(ActivityCount, 0)) AS TotalTask,
           AppUserId
    FROM #AcitviyWiseCount
    WHERE StatusId = 5
    GROUP BY AppUserId;

    SELECT UTT.AppUserName,
           UTT.AppUserId,
           UTT.Totaltask AS TotalTasks,
           ISNULL(UTC.Totaltask, 0) AS TotalCompleted,
           (
               SELECT TOP 1
                      CASE
                          WHEN ImageName <> '' THEN
                              ISNULL(@Url + ImageName, '')
                          ELSE
                              ''
                      END
               FROM dbo.AppUser
               WHERE Id = UTT.AppUserId
           ) AS UserImageURL
    FROM #UserTotaltask UTT
        LEFT JOIN #UserTotalCompleted UTC
            ON UTT.AppUserId = UTT.AppUserId;
END;
