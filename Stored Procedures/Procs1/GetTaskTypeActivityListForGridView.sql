--	===============================================================
--	Author:			Krishna Panchal
--	Create date:	24-Dec-2020
--	Description:	Get all the task type activity detail for the grid view
--	Call SP:		dbo.GetTaskTypeActivityListForGridView 1246
--	===============================================================

CREATE PROCEDURE [dbo].[GetTaskTypeActivityListForGridView]
    @ActivityIds VARCHAR(MAX) = NULL,
    @EstablishmentId VARCHAR(MAX) = NULL,
    @FormStatus VARCHAR(10) = NULL,
    @UserId VARCHAR(MAX) = NULL,
    @DueDateID INT = NULL,
    @SearchText VARCHAR(1000) = NULL,
    @AppUserId BIGINT = NULL,
    @StartDate DATE = NULL,
    @EndDate DATE = NULL
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @EstablishmentCountByActivityId BIGINT;
    SELECT @EstablishmentCountByActivityId = KeyValue
    FROM dbo.AAAAConfigSettings
    WHERE KeyName = 'EstablishmentCountByActivityId';

    IF (@ActivityIds = '0')
    BEGIN
        DECLARE @listStr NVARCHAR(MAX);
        SELECT @listStr = COALESCE(@listStr + ', ', '') + CONVERT(NVARCHAR(50), ES.EstablishmentGroupId)
        FROM dbo.Establishment AS ES
            INNER JOIN dbo.AppUserEstablishment
                ON AppUserEstablishment.EstablishmentId = ES.Id
                   AND dbo.AppUserEstablishment.AppUserId = @AppUserId
        GROUP BY ES.EstablishmentGroupId;

        SET @ActivityIds = @listStr;
    END;

    --Today 
    IF (@DueDateID = '1')
    BEGIN
        SET @StartDate = GETUTCDATE();
        SET @EndDate = GETUTCDATE();
    END;

    --Tomorrow
    IF (@DueDateID = '2')
    BEGIN
        SET @StartDate =
        (
            SELECT DATEADD(DAY, 1, GETUTCDATE())
        );
        SET @EndDate =
        (
            SELECT DATEADD(DAY, 1, GETUTCDATE())
        );
    END;

    --This Week
    IF (@DueDateID = '3')
    BEGIN
        SET @StartDate =
        (
            SELECT DATEADD(DAY, 2 - DATEPART(WEEKDAY, GETUTCDATE()), CAST(GETUTCDATE() AS DATE))
        );
        SET @StartDate =
        (
            SELECT DATEADD(DAY, 8 - DATEPART(WEEKDAY, GETUTCDATE()), CAST(GETUTCDATE() AS DATE))
        );
    END;

    -- Next Week
    IF (@DueDateID = '4')
    BEGIN
        SET @StartDate =
        (
            SELECT DATEADD(DAY, 2 - DATEPART(WEEKDAY, GETUTCDATE()), CAST(GETUTCDATE() AS DATE))
        );
        SET @EndDate =
        (
            SELECT DATEADD(DAY, 8 - DATEPART(WEEKDAY, GETUTCDATE()), CAST(GETUTCDATE() AS DATE))
        );
        SET @StartDate =
        (
            SELECT DATEADD(DAY, 1, @EndDate)
        );
        SET @EndDate =
        (
            SELECT DATEADD(DAY, 7, @StartDate)
        );
    END;

    -- No Due Date
    IF (@DueDateID = '4')
    BEGIN
        SET @StartDate = NULL;
        SET @EndDate = NULL;
    END;


    IF OBJECT_ID('tempdb..#GridUserTable', 'u') IS NOT NULL
    DROP TABLE #GridUserTable;
    CREATE TABLE #GridUserTable
    (
        Id BIGINT IDENTITY,
        ActivityId BIGINT,
        ActivityName NVARCHAR(100),
        SeenClientId BIGINT,
        InProgressCount INT,
        PendingCount INT,
        LateCount INT,
        CompletedCount INT,
        ChatCount INT,
        TotalTaskCount INT,
        InProgressLableID INT,
        PendingLableID INT,
        LateLableID INT,
        CompletedLableID INT,
        TaskHeader NVARCHAR(500),
        NewTaskHeader NVARCHAR(500),
        AllocateTaskHeader NVARCHAR(500),
        ActivityTaskListLabel NVARCHAR(500)
    );

    INSERT INTO #GridUserTable
    (
        ActivityId,
        ActivityName,
        SeenClientId,
        InProgressCount,
        PendingCount,
        LateCount,
        CompletedCount,
        ChatCount,
        TotalTaskCount,
        InProgressLableID,
        PendingLableID,
        LateLableID,
        CompletedLableID,
        TaskHeader,
        NewTaskHeader,
        AllocateTaskHeader,
        ActivityTaskListLabel
    )
    SELECT DISTINCT
        EG.Id AS ActivityId,
        EG.EstablishmentGroupName AS ActivityName,
        EG.SeenClientId AS SeenClientId,
        10 AS InProgressCount,
        20 AS PendingCount,
        30 AS LateCount,
        40 AS CompletedCount,
        50 AS ChatCount,
        50 AS TotalTaskCount,
        2 AS InProgressLableID,
        1 AS PendingLableID,
        3 AS LateLableID,
        4 AS CompletedLableID,
        (
            SELECT TOP 1
                HeaderValue
            FROM dbo.HeaderSetting
            WHERE RTRIM(LTRIM(HeaderName)) = 'Task Activity'
                  AND EstablishmentGroupId = EG.Id
        ) AS TaskHeader,
        (
            SELECT TOP 1
                HeaderValue
            FROM dbo.HeaderSetting
            WHERE RTRIM(LTRIM(HeaderName)) = 'Add New Task'
                  AND EstablishmentGroupId = EG.Id
        ) AS NewTaskHeader,
        (
            SELECT TOP 1
                HeaderValue
            FROM dbo.HeaderSetting
            WHERE RTRIM(LTRIM(HeaderName)) = 'Allocate Tasks'
                  AND EstablishmentGroupId = EG.Id
        ) AS AllocateTaskHeader,
        (
            SELECT AliasName
            FROM dbo.EstablishmentGroupModuleAlias
            WHERE EstablishmentGroupId = EG.Id
                  AND AppModuleId = 1
        ) AS ActivityTaskListLabel
    FROM dbo.EstablishmentGroup AS EG
        INNER JOIN dbo.Vw_Establishment AS EST
            ON EST.EstablishmentGroupId = EG.Id
        INNER JOIN dbo.AppUserEstablishment UE
            ON UE.EstablishmentId = EST.Id
        INNER JOIN dbo.HowItWorks AS HW
            ON HW.Id = EG.HowItWorksId
        INNER JOIN dbo.Questionnaire AS QNR
            ON QNR.Id = EG.QuestionnaireId
    WHERE EG.IsDeleted = 0
          AND EST.IsDeleted = 0
          AND UE.AppUserId = @AppUserId
          AND EG.EstablishmentGroupType = 'Task'
          AND UE.IsDeleted = 0;

	--IF OBJECT_ID('tempdb..#UnresolvePendingCount', 'u') IS NOT NULL
 --       DROP TABLE #UnresolvePendingCount;
    
	--CREATE TABLE #UnresolvePendingCount
 --   (
 --       ActivityId BIGINT,
 --       PendingCount INT
 --   );

 --   IF OBJECT_ID('tempdb..#InProgressCount', 'u') IS NOT NULL
 --       DROP TABLE #InProgressCount;
 --   CREATE TABLE #InProgressCount
 --   (
 --       ActivityId BIGINT,
 --       InProgressCount INT
 --   );

 --   IF OBJECT_ID('tempdb..#LateCount', 'u') IS NOT NULL
 --       DROP TABLE #LateCount;
 --   CREATE TABLE #LateCount
 --   (
 --       ActivityId BIGINT,
 --       LateCount INT
 --   );

 --   IF OBJECT_ID('tempdb..#CompletedCount', 'u') IS NOT NULL
 --   DROP TABLE #CompletedCount;
 --   CREATE TABLE #CompletedCount
 --   (
 --       ActivityId BIGINT,
 --       OutCount INT
 --   );

	--IF OBJECT_ID('tempdb..#UserTable', 'u') IS NOT NULL
 --       DROP TABLE #UserTable;
 --   CREATE TABLE #UserTable
 --   (
 --       Id BIGINT IDENTITY,
 --       ActivityId BIGINT,
 --       ActivityType VARCHAR(10),
 --       LastDays INT
 --   );

	--INSERT INTO #UserTable
 --   (
 --       ActivityId,
 --       ActivityType,
 --       LastDays
 --   )
 --   SELECT DISTINCT
 --       EG.Id AS ActivityId,
 --       EG.EstablishmentGroupType AS ActivityType,
 --       ISNULL(UE.ActivityLastDays, 30)
 --   FROM dbo.EstablishmentGroup (NOLOCK) AS EG
 --       INNER JOIN dbo.Establishment (NOLOCK) AS EST
 --           ON EST.EstablishmentGroupId = EG.Id
 --              AND EG.IsDeleted = 0
 --              AND EST.IsDeleted = 0
 --       INNER JOIN dbo.AppUserEstablishment UE
 --           ON UE.EstablishmentId = EST.Id
 --              AND UE.AppUserId = @AppUserId
 --              AND UE.IsDeleted = 0

 --   DECLARE @IsManager BIT;

 --   SELECT @IsManager = IsAreaManager
 --   FROM dbo.AppUser
 --   WHERE Id = @AppUserId;

	-- IF OBJECT_ID('tempdb..#Count1', 'u') IS NOT NULL
 --       DROP TABLE #Count1;
 --   CREATE TABLE #Count1
 --   (
 --       ActivityId BIGINT,
 --       Count# BIT
 --   );
 --   IF OBJECT_ID('tempdb..#temp1', 'u') IS NOT NULL
 --       DROP TABLE #temp1;


 --   SELECT DISTINCT
 --       EstablishmentGroupId,
 --       UT.ActivityId,
 --       E.Id
 --   INTO #temp1
 --   FROM #UserTable UT
 --       INNER JOIN Establishment E
 --           ON UT.ActivityId = E.EstablishmentGroupId;

 --   INSERT INTO #Count1
 --   SELECT t.ActivityId,
 --          1
 --   FROM #temp1 t
 --       INNER JOIN dbo.AppUserEstablishment aue
 --           ON aue.EstablishmentId = t.Id
 --       INNER JOIN dbo.AppUser au
 --           ON au.Id = aue.AppUserId
 --              AND au.IsAreaManager = 0
 --              AND au.IsActive = 1
 --              AND au.IsDeleted = 0
 --   UNION
 --   SELECT t.ActivityId,
 --          1
 --   FROM #temp1 t
 --       INNER JOIN dbo.AppUserEstablishment aue
 --           ON aue.EstablishmentId = t.Id
 --       INNER JOIN dbo.AppUser au
 --           ON au.Id = aue.AppUserId
 --              AND AppUserId = @AppUserId
 --              AND au.IsActive = 1
 --              AND au.IsDeleted = 0
 --   UNION
 --   SELECT t.ActivityId,
 --          1
 --   FROM #temp1 t
 --       INNER JOIN AppManagerUserRights AMUR
 --           ON t.Id = AMUR.EstablishmentId
 --              AND AMUR.UserId = @AppUserId
 --       INNER JOIN dbo.AppUser AU
 --           ON AU.Id = AMUR.ManagerUserId
 --              AND AU.IsActive = 1
 --              AND AU.IsDeleted = 0

 --IF OBJECT_ID('tempdb..#Count0', 'u') IS NOT NULL
 --       DROP TABLE #Count0;
 --   CREATE TABLE #Count0
 --   (
 --       ActivityId BIGINT,
 --       Count# BIT
 --   );
 --   INSERT INTO #Count0
 --   SELECT UT.ActivityId,
 --          0
 --   FROM #UserTable UT
 --       LEFT JOIN #Count1 C1
 --           ON C1.ActivityId = UT.ActivityId
 --   WHERE C1.ActivityId IS NULL;

 --   IF OBJECT_ID('tempdb..#temp2', 'u') IS NOT NULL
 --       DROP TABLE #temp2;
 --   SELECT E.Id,
 --          C1.ActivityId
 --   INTO #temp2
 --   FROM #Count1 C1
 --       INNER JOIN Establishment E
 --           ON C1.ActivityId = E.EstablishmentGroupId;

 --   IF (@IsManager = 1)
 --   BEGIN
 --       INSERT INTO #ActivityUserTable
 --       (
 --           Userid,
 --           ActivityId
 --       )
 --       SELECT AUE.AppUserId,
 --              t.ActivityId
 --       FROM #temp2 t
 --           INNER JOIN AppUserEstablishment AUE
 --               ON t.Id = AUE.EstablishmentId
 --                  AND AUE.IsDeleted = 0
 --           INNER JOIN dbo.AppUser AU
 --               ON AU.Id = AUE.AppUserId
 --                  AND AU.IsAreaManager = 0
 --                  AND AU.IsActive = 1
 --                  AND AU.IsDeleted = 0
 --       UNION
 --       SELECT AUE.AppUserId,
 --              t.ActivityId
 --       FROM #temp2 t
 --           INNER JOIN AppUserEstablishment AUE
 --               ON t.Id = AUE.EstablishmentId
 --                  AND AUE.AppUserId = @AppUserId
 --                  AND AUE.IsDeleted = 0
 --           INNER JOIN dbo.AppUser AU
 --               ON AU.Id = AUE.AppUserId
 --                  AND AU.IsActive = 1
 --       UNION
 --       SELECT ManagerUserId,
 --              t.ActivityId
 --       FROM #temp2 t
 --           INNER JOIN AppManagerUserRights AMu
 --               ON AMu.EstablishmentId = t.Id
 --                  AND AMu.UserId = @AppUserId
 --                  AND AMu.IsDeleted = 0
 --           INNER JOIN dbo.AppUser au
 --               ON au.Id = AMu.ManagerUserId
 --                  AND au.IsActive = 1
 --                  AND au.IsDeleted = 0
 --           INNER JOIN dbo.AppUserEstablishment AUE
 --               ON AUE.EstablishmentId = AMu.EstablishmentId
 --   END;

	-- IF EXISTS (SELECT 1 FROM #Count0)
 --   BEGIN
 --       INSERT INTO #ActivityUserTable
 --       (
 --           Userid,
 --           ActivityId
 --       )
 --       SELECT DISTINCT
 --           U.Id AS UserId,
 --           C.ActivityId
 --       FROM dbo.AppUserEstablishment AS UE
 --           INNER JOIN dbo.AppUser AS LoginUser
 --               ON UE.AppUserId = LoginUser.Id
 --                  AND LoginUser.Id = @AppUserId
 --           INNER JOIN dbo.Establishment AS E
 --               ON UE.EstablishmentId = E.Id
 --           INNER JOIN dbo.AppUserEstablishment AS AppUser
 --               ON E.Id = AppUser.EstablishmentId
 --                  AND (
 --                          UE.EstablishmentType = AppUser.EstablishmentType
 --                          OR LoginUser.IsAreaManager = 1
 --                      )
 --           INNER JOIN dbo.AppUser AS U
 --               ON AppUser.AppUserId = U.Id
 --                  AND (
 --                          U.IsAreaManager = 0
 --                          OR U.Id = @AppUserId
 --                      )
 --           INNER JOIN #Count0 C
 --               ON 1 = 1
 --       WHERE E.IsDeleted = 0
 --             AND UE.IsDeleted = 0
 --             AND AppUser.IsDeleted = 0
 --             AND U.IsDeleted = 0
 --   END;

 --   IF (@IsManager = 0)
 --   BEGIN
 --       INSERT INTO #ActivityUserTable
 --       (
 --           Userid,
 --           ActivityId
 --       )
 --       SELECT U.Id AS UserId,
 --              C.ActivityId
 --       FROM dbo.AppUserEstablishment AS UE
 --           INNER JOIN dbo.AppUser AS LoginUser
 --               ON UE.AppUserId = LoginUser.Id
 --                  AND LoginUser.Id = @AppUserId
 --           INNER JOIN dbo.Establishment AS E
 --               ON UE.EstablishmentId = E.Id
 --           INNER JOIN dbo.AppUserEstablishment AS AppUser
 --               ON E.Id = AppUser.EstablishmentId
 --                  AND (
 --                          UE.EstablishmentType = AppUser.EstablishmentType
 --                          OR LoginUser.IsAreaManager = 1
 --                      )
 --           INNER JOIN dbo.AppUser AS U
 --               ON AppUser.AppUserId = U.Id
 --                  AND (
 --                          U.IsAreaManager = 0
 --                          OR U.Id = @AppUserId
 --                      )
 --           INNER JOIN #Count1 C
 --               ON 1 = 1
 --       WHERE U.Id = @AppUserId
 --             AND E.IsDeleted = 0
 --             AND UE.IsDeleted = 0
 --             AND AppUser.IsDeleted = 0
 --             AND U.IsDeleted = 0
 --       UNION
 --       SELECT U.Id AS UserId,
 --              C.ActivityId
 --       FROM dbo.AppUserEstablishment AS UE
 --           INNER JOIN dbo.AppUser AS LoginUser
 --               ON UE.AppUserId = LoginUser.Id
 --                  AND LoginUser.Id = @AppUserId
 --           INNER JOIN dbo.Establishment AS E
 --               ON UE.EstablishmentId = E.Id
 --           INNER JOIN dbo.AppUserEstablishment AS AppUser
 --               ON E.Id = AppUser.EstablishmentId
 --                  AND (
 --                          UE.EstablishmentType = AppUser.EstablishmentType
 --                          OR LoginUser.IsAreaManager = 1
 --                      )
 --           INNER JOIN dbo.AppUser AS U
 --               ON AppUser.AppUserId = U.Id
 --                  AND (
 --                          U.IsAreaManager = 0
 --                          OR U.Id = @AppUserId
 --                      )
 --           INNER JOIN #Count0 C
 --               ON 1 = 1
 --       WHERE U.Id = @AppUserId
 --             AND E.IsDeleted = 0
 --             AND UE.IsDeleted = 0
 --             AND AppUser.IsDeleted = 0
 --             AND U.IsActive = 1
 --             AND U.IsDeleted = 0
 --   END;


	--  IF OBJECT_ID('tempdb..#UserId', 'u') IS NOT NULL
 --       DROP TABLE #UserId;
 --   CREATE TABLE #UserId
 --   (
 --       userid BIGINT,
 --       ActivityId BIGINT
 --   );

 --   IF OBJECT_ID('tempdb..#EstablishmentId', 'u') IS NOT NULL
 --       DROP TABLE #EstablishmentId;

 --   SELECT DISTINCT
 --       EST.Id,
 --       UT.ActivityId
 --   INTO #EstablishmentId
 --   FROM dbo.Establishment AS EST
 --       INNER JOIN #UserTable UT
 --           ON UT.ActivityId = EST.EstablishmentGroupId
 --       INNER JOIN dbo.AppUserEstablishment
 --           ON AppUserEstablishment.EstablishmentId = EST.Id
 --              AND dbo.AppUserEstablishment.AppUserId = @AppUserId
	--		   AND appuserestablishment.IsDeleted=0

 --   IF OBJECT_ID('tempdb..#Count11', 'u') IS NOT NULL
 --       DROP TABLE #Count11;
 --   CREATE TABLE #Count11
 --   (
 --       ActivityId BIGINT,
 --       count# BIT
 --   );
 --   IF (@IsManager = 1)
 --   BEGIN
 --       INSERT INTO #Count11
 --       SELECT DISTINCT
 --           UT.ActivityId,
 --           1 AS count#
 --       FROM #UserTable UT
 --           INNER JOIN dbo.Establishment E
 --               ON UT.ActivityId = E.EstablishmentGroupId
 --           INNER JOIN dbo.AppUserEstablishment AUE
 --               ON E.Id = AUE.EstablishmentId
 --           INNER JOIN dbo.AppUser Au
 --               ON Au.Id = AUE.AppUserId
 --                  AND (
 --                          Au.IsAreaManager = 0
 --                          OR AUE.AppUserId = @AppUserId
 --                      )
 --                  AND Au.IsActive = 1
 --                  AND Au.IsDeleted = 0

 --       IF EXISTS
 --       (
 --           SELECT 1
 --           FROM #UserTable UT
 --               LEFT JOIN #Count11 C
 --                   ON C.ActivityId = UT.ActivityId
 --           WHERE C.ActivityId IS NULL
 --       )
 --       BEGIN
 --           INSERT INTO #Count11
 --           SELECT DISTINCT
 --               b.ActivityId,
 --               a.Count#
 --           FROM
 --           (
 --               SELECT DISTINCT
 --                   1 AS Count#
 --               FROM #EstablishmentId e
 --        INNER JOIN AppManagerUserRights
 --                       ON e.Id = AppManagerUserRights.EstablishmentId
 --                          AND AppManagerUserRights.UserId = @AppUserId
 --                   INNER JOIN dbo.AppUser
 --                       ON dbo.AppUser.Id = AppManagerUserRights.ManagerUserId
 --                          AND AppManagerUserRights.IsDeleted = 0
 --                          AND IsActive = 1
 --           ) a
 --               CROSS JOIN
 --               (
 --                   SELECT DISTINCT
 --                       UT.ActivityId
 --                   FROM #UserTable UT
 --                       LEFT JOIN #Count11 C
 --                           ON C.ActivityId = UT.ActivityId
 --                   WHERE C.ActivityId IS NULL
 --               ) b
 --       END;

 --       INSERT INTO #UserId
 --       SELECT AppUserId,
 --              C.ActivityId
 --       FROM #EstablishmentId E
 --           INNER JOIN #Count11 C
 --               ON C.ActivityId = E.ActivityId
 --           INNER JOIN dbo.AppUserEstablishment AUE
 --               ON E.Id = AUE.EstablishmentId
 --                  AND AUE.IsDeleted = 0
 --           INNER JOIN dbo.AppUser
 --               ON AppUser.Id = AUE.AppUserId
 --                  AND AppUser.IsDeleted = 0
 --                  AND IsActive = 1
 --       WHERE (
 --                 AppUserId = @AppUserId
 --                 OR IsAreaManager = 0
 --             )
 --       UNION
 --       SELECT ManagerUserId,
 --              C.ActivityId
 --       FROM #EstablishmentId e
 --           INNER JOIN #Count11 C
 --               ON C.ActivityId = e.ActivityId
 --           INNER JOIN AppManagerUserRights AMUR
 --               ON e.Id = AMUR.EstablishmentId
 --                  AND AMUR.UserId = @AppUserId
 --                  AND AMUR.IsDeleted = 0
 --           INNER JOIN dbo.AppUserEstablishment aue
 --               ON AMUR.EstablishmentId = aue.EstablishmentId
 --           INNER JOIN dbo.AppUser AU
 --               ON AU.Id = AMUR.ManagerUserId
 --                  AND AU.IsDeleted = 0
 --                  AND AU.IsActive = 1

 --   END;


    IF OBJECT_ID('tempdb..#ActivityUnreadCount', 'u') IS NOT NULL
        DROP TABLE #ActivityUnreadCount;
    CREATE TABLE #ActivityUnreadCount
    (
        ActivityId BIGINT,
        ActivityCount INT
    );

    INSERT INTO #ActivityUnreadCount
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
           ) AS ActivityCount
    FROM #GridUserTable AS UT;

    SELECT US.ActivityId,
           US.ActivityName,
           US.SeenClientId,
           US.InProgressCount,
           US.PendingCount,
           US.LateCount,
           US.CompletedCount,
           AC.ActivityCount AS ChatCount,
           US.TotalTaskCount,
           US.InProgressLableID,
           US.PendingLableID,
           US.LateLableID,
           US.CompletedLableID,
           US.TaskHeader,
           US.NewTaskHeader,
           US.AllocateTaskHeader,
           US.ActivityTaskListLabel
    FROM #GridUserTable AS US
        INNER JOIN #ActivityUnreadCount AS AC
            ON AC.ActivityId = US.ActivityId; 

    SELECT Id,
           LabelName,
           LabelColor
    FROM dbo.TaskGridLabel;
END;
