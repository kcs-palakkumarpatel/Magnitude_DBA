
--SET QUOTED_IDENTIFIER ON|OFF
--SET ANSI_NULLS ON|OFF
--GO
-- Exec GETGraphINOUTCount 6225,6651,0
CREATE PROCEDURE [dbo].[GETGraphINOUTCount]
    @ActivityId BIGINT,
    @AppUserId BIGINT,
    @IsOut BIT
AS
BEGIN
    SET NOCOUNT ON;
	SET DEADLOCK_PRIORITY NORMAL;
	
	BEGIN TRY
    DECLARE @Result AS TABLE
    (
        InOut VARCHAR(10),
        Data VARCHAR(MAX)
    );
    DECLARE @LastDays BIGINT;
    DECLARE @ActivityType VARCHAR(10);

    CREATE TABLE #ActivityUserTable
    (
        ActivityId BIGINT,
        Userid BIGINT
    );

    IF OBJECT_ID('tempdb..#EstablishmentId', 'u') IS NOT NULL
        DROP TABLE #EstablishmentId;

    SELECT DISTINCT
        EST.Id,
        EST.EstablishmentGroupId
    INTO #EstablishmentId
    FROM dbo.Establishment AS EST
        INNER JOIN dbo.AppUserEstablishment
            ON AppUserEstablishment.EstablishmentId = EST.Id
               AND dbo.AppUserEstablishment.AppUserId = @AppUserId
               AND EST.EstablishmentGroupId = @ActivityId
			   AND AppUserEstablishment.IsDeleted=0
    OPTION (RECOMPILE);

    INSERT INTO #ActivityUserTable
    SELECT ActivityId,
           UserId
    FROM dbo.AllUserSelectedForActivity(@AppUserId, @ActivityId);

    SELECT DISTINCT
        @LastDays = ISNULL(UE.ActivityLastDays, 30),
        @ActivityType = UE.EstablishmentType
    FROM dbo.EstablishmentGroup (NOLOCK) AS EG
        INNER JOIN dbo.Vw_Establishment (NOLOCK) AS EST
            ON EST.EstablishmentGroupId = EG.Id
        INNER JOIN dbo.AppUserEstablishment UE
            ON UE.EstablishmentId = EST.Id
    WHERE EG.IsDeleted = 0
          AND EST.IsDeleted = 0
          AND UE.AppUserId = @AppUserId
          AND UE.IsDeleted = 0
          AND EG.Id = @ActivityId;

    IF OBJECT_ID('tempdb..#intflag', 'U') IS NOT NULL
        DROP TABLE #intflag;
    IF OBJECT_ID('tempdb..#intflag_temp', 'U') IS NOT NULL
        DROP TABLE #intflag_temp;
    IF OBJECT_ID('tempdb..#t', 'U') IS NOT NULL
        DROP TABLE #t;
    IF OBJECT_ID('tempdb..#Result', 'U') IS NOT NULL
        DROP TABLE #Result;

    CREATE TABLE #t
    (
        id BIGINT,
        value VARCHAR(MAX)
    );

    CREATE TABLE #intflag
    (
        id BIGINT,
        value VARCHAR(MAX)
    );

    CREATE TABLE #intflag_temp
    (
        Id BIGINT,
        [InOutCount] BIGINT
    );

    DECLARE @intFlag INT;
    SET @intFlag = 1;
    WHILE (@intFlag <= @LastDays)
    BEGIN
        INSERT INTO #intflag
        (
            id,
            value
        )
        SELECT @intFlag,
               '';
        SET @intFlag = @intFlag + 1;
    END;

    IF (@ActivityType = 'Sales')
    BEGIN
        INSERT INTO #intflag_temp
        SELECT DATEDIFF(DAY, AM.CreatedOn, (GETUTCDATE() + 1)) Id,
               COUNT(AM.Id) AS [InOutCount]
        FROM dbo.AnswerMaster AS AM
            INNER JOIN dbo.Vw_Establishment E
                ON E.Id = AM.EstablishmentId
            INNER JOIN dbo.AppUser A
                ON (AM.AppUserId = A.Id)
            INNER JOIN
            (
                SELECT AUT.Userid
                FROM #ActivityUserTable AS AUT
                WHERE AUT.ActivityId = @ActivityId
            ) AS U
                ON U.Userid = A.Id
        WHERE AM.IsDeleted = 0
              AND (
                      AM.AppUserId = 0
                      OR A.IsAreaManager = 1
                      OR AM.AppUserId = A.Id
                  )
              AND E.EstablishmentGroupId = @ActivityId
              AND E.Id IN (
                              SELECT Id FROM #EstablishmentId WHERE EstablishmentGroupId = @ActivityId
                          )
              AND AM.CreatedOn
              BETWEEN DATEADD(DAY, (@LastDays * -1), GETUTCDATE()) AND GETUTCDATE()
        GROUP BY DATEDIFF(DAY, AM.CreatedOn, (GETUTCDATE() + 1));
    END;
    ELSE
    BEGIN
        INSERT INTO #intflag_temp
        SELECT DATEDIFF(DAY, AM.CreatedOn, (GETUTCDATE() + 1)) id,
               COUNT(AM.Id) AS [value]
        FROM dbo.AnswerMaster AS AM
            INNER JOIN dbo.Vw_Establishment E
                ON AM.EstablishmentId = E.Id
        WHERE AM.IsDeleted = 0
              AND E.EstablishmentGroupId = @ActivityId
              AND E.Id IN (
                              SELECT Id FROM #EstablishmentId WHERE EstablishmentGroupId = @ActivityId
                          )
              AND AM.CreatedOn
              BETWEEN DATEADD(DAY, (@LastDays * -1), GETUTCDATE()) AND GETUTCDATE()
        GROUP BY DATEDIFF(DAY, AM.CreatedOn, (GETUTCDATE() + 1));
    END;

    INSERT INTO #t
    SELECT f.id,
           ISNULL(t.InOutCount, 0) AS [value]
    FROM #intflag_temp t
        RIGHT JOIN #intflag f
            ON t.Id = f.id;

    INSERT INTO @Result
    SELECT TOP 1
        'IN',
        STUFF(
                 (
                     SELECT ', ' + CAST(value AS VARCHAR(10)) [text()]
                     FROM #t
                     FOR XML PATH(''), TYPE
                 ).value('.', 'NVARCHAR(MAX)'),
                 1,
                 2,
                 ' '
             ) List_Output
    FROM #t;

    DELETE FROM #intflag_temp;
    DELETE FROM #t;

    INSERT INTO #intflag_temp
    SELECT DATEDIFF(DAY, SAM.CreatedOn, (GETUTCDATE() + 1)) id,
           COUNT(SAM.Id) AS [value]
    FROM dbo.SeenClientAnswerMaster AS SAM
        INNER JOIN dbo.Vw_Establishment E
            ON E.Id = SAM.EstablishmentId
        INNER JOIN
        (
            SELECT AUT.Userid
            FROM #ActivityUserTable AS AUT
            WHERE AUT.ActivityId = @ActivityId
        ) AS U
            ON U.Userid = SAM.AppUserId
    WHERE SAM.IsDeleted = 0
          AND E.EstablishmentGroupId = @ActivityId
          AND E.Id IN (
                          SELECT Id FROM #EstablishmentId WHERE EstablishmentGroupId = @ActivityId
                      )
          AND SAM.CreatedOn
          BETWEEN DATEADD(DAY, (@LastDays * -1), GETUTCDATE()) AND GETUTCDATE()
    GROUP BY DATEDIFF(DAY, SAM.CreatedOn, (GETUTCDATE() + 1));

    INSERT INTO #t
    SELECT f.id,
           ISNULL(t.InOutCount, 0) AS [value]
    FROM #intflag_temp t
        RIGHT JOIN #intflag f
            ON t.Id = f.id;

    INSERT INTO @Result
    SELECT TOP 1
        'OUT',
        STUFF(
                 (
                     SELECT ', ' + CAST(value AS VARCHAR(10)) [text()]
                     FROM #t
                     FOR XML PATH(''), TYPE
                 ).value('.', 'NVARCHAR(MAX)'),
                 1,
                 2,
                 ' '
             ) List_Output
    FROM #t;

    SELECT InOut,
           REPLACE([Data], ' ', '') AS [Data]
    FROM @Result;
	END TRY

BEGIN CATCH
	INSERT INTO dbo.ErrorLog
        (
            PageId,
            MethodName,
            ErrorType,
            ErrorMessage,
            ErrorDetails,
            ErrorDate,
            UserId,
            Solution,
            CreatedOn,
            CreatedBy
        )
        VALUES
        (ERROR_LINE(),
         'dbo.GETGraphINOUTCount',
         N'DATABASE',
         ERROR_MESSAGE(),
         ('ERROR_NUMBER=' + CONVERT(VARCHAR(100), ERROR_NUMBER()) + ',ERROR_STATE='
          + CONVERT(VARCHAR(20), ERROR_STATE()) + ',ERROR_SEVERITY=' + CONVERT(VARCHAR(20), ERROR_SEVERITY())
         )  ,
         GETUTCDATE(),
         ISNULL(@AppUserId,0),
         @ActivityId+','+@AppUserId+','+@IsOut,
         GETUTCDATE(),
         ISNULL(@AppUserId,0)
        );
END CATCH
SET NOCOUNT OFF;
END;
