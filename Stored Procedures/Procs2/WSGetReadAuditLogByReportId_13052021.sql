

-- WSGetReadAuditLogByReportId 979255,1,'','29/Apr/21 08:50','29/Apr/21 08:55','','','','2021-04-30 04:13:26.000',1
CREATE PROCEDURE [dbo].[WSGetReadAuditLogByReportId_13052021]
    @ReportId BIGINT,
    @isOut BIT,
    @UserIds VARCHAR(1000) = '',
    @FromDate VARCHAR(50) = NULL,
    @ToDate VARCHAR(50) = NULL,
    @SearchText VARCHAR(1000) = '',
    @SortExpression VARCHAR(100) = '',
    @SortOrder VARCHAR(10) = '',
    @CurrenDateTime DATETIME = '',
    @isFromMobile BIT = 0
AS
SET NOCOUNT ON;
BEGIN
    DECLARE @EstablishmentID BIGINT;
    IF (@isOut = 0)
    BEGIN
        SET @EstablishmentID =
        (
            SELECT TOP 1
                   EstablishmentId
            FROM dbo.AnswerMaster WITH(NOLOCK)
            WHERE Id = @ReportId
                  AND IsDeleted = 0
        );
    END;
    ELSE
        SET @EstablishmentID =
    (
        SELECT TOP 1
               EstablishmentId
        FROM dbo.SeenClientAnswerMaster WITH(NOLOCK)
        WHERE Id = @ReportId
              AND IsDeleted = 0
    )   ;
END;
DECLARE @TimeOffSet BIGINT;
SET @TimeOffSet =
(
    SELECT TOP 1
           TimeOffSet
    FROM dbo.Establishment WITH(NOLOCK)
    WHERE Id = @EstablishmentID
          AND IsDeleted = 0
);
IF (@CurrenDateTime = '')
BEGIN
    SET @CurrenDateTime = GETDATE();
END;
DECLARE @StartDate DATETIME,
        @EndDate DATETIME,
        @DateDiff INT = 0,
        @IsFilterApplyed BIT = 0;

IF (@isFromMobile = 0)
BEGIN
    SELECT @DateDiff = DATEDIFF(MINUTE, @CurrenDateTime, GETUTCDATE());
END;

IF (@FromDate IS NULL AND @ToDate IS NULL)
BEGIN
    SELECT @StartDate = DATEADD(MONTH, -1, DATEADD(MINUTE, @TimeOffSet, GETUTCDATE()));
    SET @EndDate = DATEADD(MINUTE, @TimeOffSet, GETUTCDATE());
END;
ELSE
BEGIN
    SET @IsFilterApplyed = 1;
    IF (@isFromMobile = 0)
    BEGIN
        SET @StartDate = DATEADD(MINUTE, 330, @FromDate);;
        SET @EndDate = DATEADD(MINUTE, 330, @ToDate);
    END;
    ELSE
    BEGIN
        SET @StartDate = DATEADD(MINUTE, 0, @FromDate);
        SET @EndDate = DATEADD(MINUTE, 0, @ToDate);
    END;
END;

IF (@isFromMobile = 0)
BEGIN
    SET @FromDate = DATEADD(MINUTE, 330, @FromDate);
    SET @ToDate = DATEADD(MINUTE, 330, @ToDate);
END;
ELSE
BEGIN
    SET @FromDate = DATEADD(MINUTE, 0, @FromDate);
    SET @ToDate = DATEADD(MINUTE, 0, @ToDate);
END;
BEGIN
    DECLARE @TempTable AS TABLE
    (
        Id BIGINT,
        Name VARCHAR(1000),
        ReadOn NVARCHAR(1000),
        TotalCount BIGINT
    );

    INSERT @TempTable
    (
        Id,
        Name,
        ReadOn,
        TotalCount
    )
    SELECT DISTINCT
           AU.Id,
           AU.Name,
           ISNULL(
           (
               SELECT TOP 1
                      ISNULL(FORMAT(CAST(RH.ReadOn AS DATETIME), 'dd/MMM/yy HH:mm', 'en-us'), '-') AS LastReadOn
               FROM dbo.ReportAuditLog_History RH WITH(NOLOCK)
               WHERE ISNULL(IsDeleted, 0) = 0
                     AND RH.isOut = @isOut
                     AND RH.EstablishmentId = @EstablishmentID
                     AND RH.ReportId = @ReportId
                     AND RH.AppUserId = AU.Id
                     AND
                     (
                         (CAST(RH.ReadOn AS DATETIME)
                     BETWEEN @FromDate AND @ToDate
                         )
                         OR @FromDate IS NULL
                     )
               ORDER BY ReadOn DESC
           ),
           '-'
                 ) AS ReadOn,
           (ISNULL(
            (
                SELECT DISTINCT
                       ISNULL(COUNT(DISTINCT ISNULL(FORMAT(CAST(R.ReadOn AS DATETIME), 'dd/MMM/yy HH:mm', 'en-us'), '-')), 0) AS TotalCount
                FROM dbo.ReportAuditLog_History R WITH(NOLOCK)
                WHERE ISNULL(IsDeleted, 0) = 0
                      AND isOut = @isOut
                      AND EstablishmentId = @EstablishmentID
                      AND ReportId = @ReportId
                      AND AppUserId = AU.Id
                      AND (CAST(R.ReadOn AS DATETIME)
                      BETWEEN @StartDate AND @EndDate
                          )
                GROUP BY AppUserId
            ),
            0
                  )
           ) AS TotalCount
    FROM dbo.AppUserEstablishment AUE WITH(NOLOCK)
        LEFT JOIN dbo.ReportAuditLog_History RAL WITH(NOLOCK)
            ON RAL.AppUserId = AUE.AppUserId
               AND RAL.ReportId = @ReportId
        LEFT JOIN dbo.AppUser AU WITH(NOLOCK)
            ON AU.Id = AUE.AppUserId
    WHERE AUE.IsDeleted = 0
          AND AUE.EstablishmentId = @EstablishmentID
          AND AU.IsActive = 1
          AND AU.IsDeleted = 0
          AND
          (
              (AU.Id IN
               (
                   SELECT Data FROM dbo.Split(@UserIds, ',')
               )
              )
              OR @UserIds = ''
          )
          AND
          (
              (AU.Name LIKE '%' + @SearchText + '%')
              OR @SearchText = ''
          )
    ORDER BY ReadOn DESC;

    IF (@SortExpression <> '')
    BEGIN
        SELECT Id,
               Name,
               ReadOn,
               TotalCount
        FROM @TempTable
        WHERE (
                  @IsFilterApplyed = 0
                  OR TotalCount <> 0
              )
        ORDER BY CASE
                     WHEN @SortExpression = 'ReadBy'
                          AND @SortOrder = 'ASC' THEN
                         Name
                 END ASC,
                 CASE
                     WHEN @SortExpression = 'ReadBy'
                          AND @SortOrder = 'DESC' THEN
                         Name
                 END DESC,
                 CASE
                     WHEN @SortExpression = 'ReadOn'
                          AND @SortOrder = 'ASC' THEN
                         ReadOn
                 END ASC,
                 CASE
                     WHEN @SortExpression = 'ReadOn'
                          AND @SortOrder = 'DESC' THEN
                         ReadOn
                 END DESC,
                 CASE
                     WHEN @SortExpression = 'TotalCount'
                          AND @SortOrder = 'ASC' THEN
                         TotalCount
                 END ASC,
                 CASE
                     WHEN @SortExpression = 'TotalCount'
                          AND @SortOrder = 'DESC' THEN
                         TotalCount
                 END DESC;
    END;
    ELSE
    BEGIN
        SELECT Id,
               Name,
               ReadOn,
               TotalCount
        FROM @TempTable
        WHERE (
                  @IsFilterApplyed = 0
                  OR TotalCount <> 0
              )
        ORDER BY ReadOn DESC;
    END;

END;
SET NOCOUNT OFF;
