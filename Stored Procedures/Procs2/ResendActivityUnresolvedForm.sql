ALTER PROCEDURE dbo.ResendActivityUnresolvedForm
    -- Add the parameters for the stored procedure here
    @ActivityId BIGINT,
    @AppUserId BIGINT
AS
BEGIN
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
        ActivityName NVARCHAR(500),
        ActivityType VARCHAR(10),
        LastDays INT
    );
    INSERT INTO #UserTable
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

    --DECLARE @Last30DaysDate DATETIME;
    --SET @Last30DaysDate = DATEADD(   DAY,
    --                                 -
    --                                 (
    --                                     SELECT TOP 1
    --                                         CAST(KeyValue AS BIGINT)
    --                                     FROM dbo.AAAAConfigSettings
    --                                     WHERE KeyName = 'LastFormDays'
    --                                 ),
    --                                 GETUTCDATE()
    --                             );


    DECLARE @TempTableId TABLE
    (
        Id BIGINT IDENTITY(1, 1),
        SeenClientAnswerMasterId BIGINT,
        SeenClientAnswerChildId BIGINT,
        EstablishmentId BIGINT,
        AppuserId BIGINT,
        EncryptedId nvarchar(500)
    );
    INSERT INTO @TempTableId
    (
        SeenClientAnswerMasterId,
        SeenClientAnswerChildId,
        EstablishmentId,
        AppuserId,
        EncryptedId
    )
    SELECT SCA.Id,
           ISNULL(c.Id,0),
           E.Id,
           @AppUserId,
           NULL
    FROM dbo.SeenClientAnswerMaster AS SCA
        INNER JOIN #ActivityUserTable AS AUT
            ON AUT.ActivityId = @ActivityId
               AND AUT.Userid = SCA.AppUserId
               --AND SCA.CreatedOn
               --BETWEEN CAST(@Last30DaysDate AS DATE) AND GETUTCDATE()
               AND SCA.IsResolved = 'Unresolved'
               AND SCA.IsDeleted = 0
        LEFT JOIN dbo.SeenClientAnswerChild c
            ON SCA.Id = c.SeenClientAnswerMasterId
        INNER JOIN dbo.Establishment AS E
            ON E.Id = SCA.EstablishmentId
               AND E.EstablishmentGroupId = @ActivityId
               AND E.IsDeleted = 0
        INNER JOIN dbo.AppUserEstablishment
            ON AppUserEstablishment.EstablishmentId = E.Id
               AND AppUserEstablishment.AppUserId = @AppUserId
               AND dbo.AppUserEstablishment.IsDeleted = 0;
    SELECT *
    FROM @TempTableId;
--DECLARE @TempTablePendingEmail TABLE
--(
--    Id BIGINT IDENTITY(1, 1),
--    EmailId nvarchar(MAX),
--    EmailText nvarchar(MAX),
--    EmailSubject nvarchar(MAX),
--    ReplyTo nvarchar(MAX)
--);
--DECLARE @TempTablePendingSMS TABLE
--(
--    Id BIGINT IDENTITY(1, 1),
--    MobileNumber nvarchar(1000),
--    SMSText nvarchar(MAX)
--);


--DECLARE @Counter INT,
--        @TotalCount INT;
--SET @Counter = 1;
--SET @TotalCount =
--(
--    SELECT COUNT(*) FROM @TempTableId
--);
--WHILE (@Counter <= @TotalCount)
--BEGIN
--    DECLARE @seenclientMasterId BIGINT;
--    SELECT @seenclientMasterId = SeenClientAnswerMasterId
--    FROM @TempTableId
--    WHERE Id = @Counter;

--    INSERT INTO @TempTablePendingEmail
--    (
--        EmailId,
--        EmailSubject,
--        EmailText,
--        ReplyTo
--    )
--    SELECT EmailId,
--           EmailSubject,
--           EmailText,
--           ReplyTo
--    FROM dbo.PendingEmail
--    WHERE RefId = @seenclientMasterId
--    GROUP BY EmailId,
--             EmailSubject,
--             EmailText,
--             ReplyTo;
--    SELECT *
--    FROM @TempTablePendingEmail;
--    INSERT INTO dbo.PendingEmail
--    (
--        ModuleId,
--        EmailId,
--        EmailText,
--        EmailSubject,
--        RefId,
--        Counter,
--        ScheduleDateTime,
--        CreatedBy,
--        ReplyTo
--    )
--    SELECT 3,
--           EmailId,
--           EmailText,
--           EmailSubject,
--           @seenclientMasterId,
--           0,
--           GETUTCDATE(),
--           @AppUserId,
--           ReplyTo
--    FROM @TempTablePendingEmail;



--    INSERT INTO @TempTablePendingSMS
--    (
--        MobileNumber,
--        SMSText
--    )
--    SELECT MobileNo,
--           SMSText
--    FROM dbo.PendingSMS
--    WHERE RefId = @seenclientMasterId
--    GROUP BY MobileNo,
--             SMSText;
--    SELECT *
--    FROM @TempTablePendingSMS;
--    INSERT INTO dbo.PendingSMS
--    (
--        ModuleId,
--        MobileNo,
--        SMSText,
--        IsSent,
--        ScheduleDateTime,
--        RefId,
--        CreatedOn,
--        CreatedBy
--    )
--    SELECT 3,
--           MobileNumber,
--           SMSText,
--           0,
--           GETUTCDATE(),
--           @seenclientMasterId,
--           GETUTCDATE(),
--           @AppUserId
--    FROM @TempTablePendingSMS;

--    SET @Counter = @Counter + 1;
--    DELETE FROM @TempTablePendingEmail;
--    DELETE FROM @TempTablePendingSMS;
--    CONTINUE;
--END;

END;
