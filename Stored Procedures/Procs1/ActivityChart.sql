-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- Call :EXEC dbo.ActivityChart @Id = 2, @GroupId = '', @EstablishmentId = '', @FromDate = '08-04-2019', @Todate = '2019-04-09', @OrderBy = ''          
-- =============================================
CREATE PROCEDURE dbo.ActivityChart
    @Id BIGINT = '',
    @GroupId NVARCHAR(MAX) = '',
    @EstablishmentId NVARCHAR(MAX) = '',
    @FromDate DATE = '',
    @Todate DATE = '',
    @OrderBy NVARCHAR(50) = 'DESC'
AS
BEGIN
    --IF (@OrderBy = '')
    --BEGIN
    --    SET @OrderBy = 'DESC';
    --END;
    DECLARE @UserId NVARCHAR(MAX);
    DECLARE @ActivityId NVARCHAR(MAX);
    DECLARE @AppUserId NVARCHAR(MAX);
    DECLARE @sqlText NVARCHAR(MAX);
    IF OBJECT_ID('tempdb..#TempAppuserId', 'U') IS NOT NULL
        DROP TABLE #TempAppuserId;
    CREATE TABLE #TempAppuserId (AppUserId BIGINT);

    IF OBJECT_ID('tempdb..#TempGropuId', 'U') IS NOT NULL
        DROP TABLE #TempGropuId;
    CREATE TABLE #TempGropuId (GropuId BIGINT);

    IF OBJECT_ID('tempdb..#TempEstablisment', 'U') IS NOT NULL
        DROP TABLE #TempEstablisment;
    CREATE TABLE #TempEstablisment (EstablishmentId BIGINT);

    IF OBJECT_ID('tempdb..#TempActivityId', 'U') IS NOT NULL
        DROP TABLE #TempActivityId;
    CREATE TABLE #TempActivityId (ActivityId BIGINT);


    INSERT INTO #TempAppuserId
    (
        AppUserId
    )
    SELECT Id
    FROM dbo.AppUser
    WHERE CreatedBy = @Id;
    SELECT @AppUserId = COALESCE(@AppUserId + ', ', '') + CONVERT(NVARCHAR(50), ISNULL(AppUserId, ''))
    FROM #TempAppuserId
    GROUP BY AppUserId;
    IF (@GroupId = '' OR @GroupId IS NULL)
    BEGIN
        INSERT INTO #TempGropuId
        (
            GropuId
        )
        SELECT DISTINCT
            GroupId
        FROM dbo.AppUser
        WHERE Id IN (
                        SELECT Data FROM dbo.Split(@AppUserId, ',')
                    );
        SELECT @GroupId = COALESCE(@GroupId + ', ', '') + CONVERT(NVARCHAR(50), ISNULL(GropuId, ''))
        FROM #TempGropuId
        GROUP BY GropuId;
        SET @GroupId = SUBSTRING(@GroupId, 2, 8000);
    END;
    IF (@EstablishmentId = '' OR @EstablishmentId IS NULL)
    BEGIN
        INSERT INTO #TempEstablisment
        (
            EstablishmentId
        )
        SELECT Id
        FROM dbo.Establishment
        WHERE GroupId IN (
                             SELECT Data FROM dbo.Split(@GroupId, ',')
                         );
        SELECT @EstablishmentId
            = COALESCE(@EstablishmentId + ', ', '') + CONVERT(NVARCHAR(50), ISNULL(EstablishmentId, ''))
        FROM #TempEstablisment
        GROUP BY EstablishmentId;
        SET @EstablishmentId = SUBSTRING(@EstablishmentId, 2, 8000);
    END;
    INSERT INTO #TempActivityId
    (
        ActivityId
    )
    SELECT EstablishmentGroupId
    FROM dbo.Establishment
    WHERE Id IN (
                    SELECT Data FROM dbo.Split(@EstablishmentId, ',')
                );
    SELECT @ActivityId = COALESCE(@ActivityId + ', ', '') + CONVERT(NVARCHAR(50), ISNULL(ActivityId, ''))
    FROM #TempActivityId
    GROUP BY ActivityId;

    DECLARE @Chart TABLE
    (
        GroupName NVARCHAR(MAX),
        GroupId BIGINT,
        FinalTotal BIGINT
    );


    SET @sqlText
        = 'SELECT TOP 5
        CombineTable.EstablishmentGroupName,
        CombineTable.GroupId,
        SUM(Total) AS [FinalTotal]
    FROM
    (
        SELECT ES.EstablishmentGroupId,
               ES.GroupId,
               EG.EstablishmentGroupName,
               COUNT(1) AS Total
        FROM dbo.SeenClientAnswerMaster AS SAM
            INNER JOIN dbo.Vw_Establishment AS ES
                ON SAM.EstablishmentId = ES.Id
            INNER JOIN dbo.[Group] AS GP
                ON ES.GroupId = GP.Id
            INNER JOIN dbo.EstablishmentGroup AS EG
                ON EG.GroupId = GP.Id
                   AND ES.EstablishmentGroupId = EG.Id
				 WHERE SAM.IsDeleted = 0
				   AND SAM.CreatedOn
             BETWEEN ''' + CONVERT(VARCHAR(19), @FromDate, 120) + ''' AND ''' + CONVERT(VARCHAR(19), DATEADD(d, 1, @ToDate), 120);
    IF @GroupId IS NOT NULL
       AND @GroupId <> ''
       AND @GroupId <> ' '
        SET @sqlText = @sqlText + ''' AND es.GROUPID in (' + @GroupId + ')';
    IF @EstablishmentId IS NOT NULL
       AND @EstablishmentId <> ''
       AND @EstablishmentId <> ' '
        SET @sqlText = @sqlText + 'and ES.id in ( ' + @EstablishmentId + ')';
    SET @sqlText
        = @sqlText
          + 'GROUP BY ES.EstablishmentGroupId,
                 ES.GroupId,
                 EG.EstablishmentGroupName
        UNION ALL
        SELECT ES.EstablishmentGroupId,
               ES.GroupId,
               EG.EstablishmentGroupName,
               COUNT(1) AS Total
        FROM dbo.AnswerMaster AS AM
            INNER JOIN Vw_Establishment AS ES
                ON AM.EstablishmentId = ES.Id
            INNER JOIN dbo.[Group] AS GP
                ON ES.GroupId = GP.Id
            INNER JOIN dbo.EstablishmentGroup AS EG
                ON EG.GroupId = GP.Id
                   AND ES.EstablishmentGroupId = EG.Id
				WHERE AM.IsDeleted = 0
				  AND AM.CreatedOn
                BETWEEN ''' + CONVERT(VARCHAR(19), @FromDate, 120) + ''' AND '''+ CONVERT(VARCHAR(19), DATEADD(d, 1, @ToDate), 120)
    IF @GroupId IS NOT NULL
       AND @GroupId <> ''
       AND @GroupId <> ' '
        SET @sqlText = @sqlText + ''' AND es.GROUPID in (' + @GroupId + ')';

    IF @EstablishmentId IS NOT NULL
       AND @EstablishmentId <> ''
       AND @EstablishmentId <> ' '
        SET @sqlText = @sqlText + 'and ES.id in ( ' + @EstablishmentId + ')';
    SET @sqlText
        = @sqlText
          + 'GROUP BY ES.EstablishmentGroupId,
                 ES.GroupId,
                 EG.EstablishmentGroupName
    ) CombineTable
    GROUP BY CombineTable.EstablishmentGroupName,
             CombineTable.GroupId
    ORDER BY FinalTotal ' + @OrderBy + '';
    INSERT INTO @Chart
    (
        GroupName,
        GroupId,
        FinalTotal
    )
    EXEC (@sqlText);
    DECLARE @TotalSum BIGINT;
    SELECT @TotalSum = SUM(FinalTotal)
    FROM @Chart;
    SELECT *,
           CAST(((FinalTotal * 100) / @TotalSum) AS BIGINT) AS [Percentage]
    FROM @Chart;
END;
