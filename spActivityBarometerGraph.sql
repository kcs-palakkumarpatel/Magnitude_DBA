/*
=============================================
Author:			<Author,,GD>
Create date:	<Create Date,,15 Jul 2015>
Description:	<Description,,>
Call SP:		spActivityBarometerGraph '1241', 859, '29 Mar 2016', 1, '294', 1,''
=============================================
*/
CREATE PROCEDURE [dbo].[spActivityBarometerGraph]
    @EstablishmentId NVARCHAR(MAX),
    @ActivityId BIGINT,
    @FromDate DATETIME,
    @Type INT,
    @UserId NVARCHAR(MAX),
    @IsOut BIT,
    @FilterOn NVARCHAR(50)
AS
BEGIN
	SET NOCOUNT ON

	DECLARE @listStr NVARCHAR(MAX);
    DECLARE @ActivityType NVARCHAR(50);
    DECLARE @tblCount TABLE (Id BIGINT IDENTITY(1, 1), Name BIGINT NOT NULL);
    DECLARE @Result TABLE (
		Id BIGINT IDENTITY(1, 1),
		Name BIGINT NOT NULL,
		Score DECIMAL(18, 2) NOT NULL,
		Counts BIGINT NOT NULL,
		BenchmarkScore DECIMAL(18, 2) NOT NULL,
        BenchmarkCounts BIGINT NOT NULL);

    DECLARE @End BIGINT
    DECLARE @Start BIGINT = 1

    DECLARE @EndDate DATETIME
    DECLARE @LocalTime DATETIME
  
    DECLARE @QuestionnaireId BIGINT
    DECLARE @SeenClientId BIGINT
    DECLARE @EstId BIGINT
    DECLARE @MinRank INT
    DECLARE @MaxRank INT
    DECLARE @DisplayType INT
    DECLARE @QuestionIdList NVARCHAR(MAX)
    DECLARE @TimeOffSet INT
    DECLARE @EstablishmentGroupType NVARCHAR(50)
    DECLARE @IsTellUs BIT

	CREATE TABLE #Id (IdNo BIGINT);
	CREATE TABLE #User (UserId BIGINT);

	IF (@EstablishmentId = '0')
        BEGIN
			SELECT @listStr = COALESCE(@listStr + ', ', '') + CONVERT(NVARCHAR(50), ISNULL(Id, ''))
			FROM dbo.Establishment
			WHERE EstablishmentGroupId = @ActivityId;

            SET @EstablishmentId = @listStr;
        END;

	SET @listStr = '';
    SELECT @ActivityType = EstablishmentGroupType FROM dbo.EstablishmentGroup WHERE Id = @ActivityId;
    
	IF (@UserId = '0' AND @ActivityType != 'Customer')
		BEGIN
			INSERT INTO #Id(IdNo)
			SELECT data FROM dbo.Split(@EstablishmentId,',')


            SELECT @listStr = COALESCE(@listStr + ', ', '') + CONVERT(NVARCHAR(50), ISNULL(AppUserId, ''))
            FROM dbo.AppUserEstablishment A
            INNER JOIN #Id I ON A.EstablishmentId = I.IdNo

            SET @UserId = @listStr;
        END;


	TRUNCATE TABLE #Id

	INSERT INTO #Id(IdNo)
	SELECT data FROM dbo.Split(@EstablishmentId,',')

	INSERT INTO #User(UserId)
	SELECT Data FROM dbo.Split(@UserId,',')


    SET @EstablishmentGroupType = 'Customer';
    
	SELECT TOP 1 @QuestionnaireId = QuestionnaireId,@TimeOffSet = E.TimeOffSet,@SeenClientId = SeenClientId,
	@IsTellUs = CASE WHEN E.EstablishmentGroupId IS NULL AND Eg.EstablishmentGroupType = 'Customer' THEN 1 ELSE 0 END
    FROM dbo.EstablishmentGroup AS Eg
    INNER JOIN dbo.Establishment AS E ON Eg.Id = E.EstablishmentGroupId
    WHERE Eg.Id = @ActivityId 
	AND E.IsDeleted = 0;

    SELECT  @LocalTime = DATEADD(MINUTE, @TimeOffSet, GETUTCDATE());

    IF @IsOut = 0
		BEGIN
			SELECT @MinRank = MinRank,@MaxRank = MaxRank,@DisplayType = DisplayType,@QuestionIdList = QuestionId
            FROM ReportSetting
            WHERE QuestionnaireId = @QuestionnaireId
            AND ReportType = 'Analysis';
        END;
    ELSE
        BEGIN
            SELECT @MinRank = MinRank,@MaxRank = MaxRank,@DisplayType = DisplayType,@QuestionIdList = QuestionId
            FROM ReportSetting
            WHERE SeenClientId = @SeenClientId
            AND ReportType = 'Analysis';
        END;
  
    DECLARE @AnsStatus NVARCHAR(50) = ''
    DECLARE @TranferFilter BIT = 0
    DECLARE @ActionFilter INT = 0
	DECLARE @isPositive NVARCHAR(50) = ''
	DECLARE @IsOutStanding BIT = 0

    IF (@FilterOn = 'Resolved' OR @FilterOn = 'Unresolved') SET @AnsStatus = @FilterOn;
	IF @FilterOn = 'Neutral' SET @isPositive = 'Neutral'
    IF @FilterOn = 'Transferred' SET @TranferFilter = 1;
    IF @FilterOn = 'Actioned' SET @ActionFilter = 1;
	IF @FilterOn = 'Unactioned' SET @ActionFilter = 2;
	IF @FilterOn = 'OutStanding' SET @IsOutStanding = 1;
			                    
    IF @Type = 1
        BEGIN
            SET @End = 24;          
            IF CONVERT(DATE, @FromDate) >= CONVERT(DATE, @LocalTime)
                BEGIN
                    SET @FromDate = CONVERT(DATE, @LocalTime);
                    SET @End = DATEPART(HOUR, @LocalTime);
                END;
            SET @EndDate = @FromDate;
        END;

    IF @Type = 2
        BEGIN
            SET @End = 7;
            SET @FromDate = CONVERT(DATE, DATEADD(wk,DATEDIFF(wk, 7,@FromDate), 6));
            SET @EndDate = DATEADD(DAY, 6, @FromDate);
                
			IF CONVERT(DATE, @EndDate) >= CONVERT(DATE, @LocalTime)
                BEGIN                                      
                    SET @EndDate = @LocalTime;
                    SET @End = DATEPART(DW, @LocalTime);
                END;
        END;

    IF @Type = 3
        BEGIN
            SET @FromDate = DATEADD(DAY,1 - DATEPART(DAY, @FromDate),@FromDate);
            SET @EndDate = DATEADD(DAY, -1,DATEADD(MONTH, 1, @FromDate));
                    
			IF CONVERT(DATE, @EndDate) >= CONVERT(DATE, @LocalTime)
                BEGIN                                      
                    SET @EndDate = @LocalTime;
                END;
            SET @End = DATEPART(DAY, @EndDate);
        END;

    IF @Type = 4
        BEGIN
            SET @FromDate = DATEADD(DAY,1 - DATEPART(DAY,@FromDate),@FromDate);
            SET @FromDate = DATEADD(MONTH,1 - DATEPART(MONTH,@FromDate),@FromDate);
            SET @EndDate = DATEADD(DAY, -1,DATEADD(YEAR, 1, @FromDate));
			IF CONVERT(DATE, @EndDate) >= CONVERT(DATE, @LocalTime)
                BEGIN                                      
                    SET @EndDate = @LocalTime;
                END;
            SET @End = DATEPART(MONTH, @EndDate);
        END;
  
	INSERT INTO @tblCount(Name)
  	SELECT TOP (@End) ROW_NUMBER()OVER(ORDER BY (SELECT 1)) AS RN 
	FROM sys.objects

    SET @FromDate = CONVERT(DATE, @FromDate);
    SET @EndDate = CONVERT(DATE, @EndDate);
    IF @IsOut = 0
        BEGIN
            INSERT INTO @Result(Name,Score,Counts,BenchmarkScore,BenchmarkCounts)
            SELECT CASE @Type
				WHEN 1 THEN DATEPART(HOUR, CreatedOn)
				WHEN 2 THEN DATEPART(DW, CreatedOn)
				WHEN 3 THEN DATEPART(DAY, CreatedOn)
            ELSE 
				DATEPART(MONTH, CreatedOn) 
			END,
            COUNT(AppUserId) AS Detail,COUNT(AppUserId) AS Total,0,0
            FROM (
				SELECT Am.AppUserId,Am.CreatedOn
				FROM dbo.View_AnswerMaster AS Am
                INNER JOIN #Id AS RE ON (RE.IdNo = Am.EstablishmentId OR @EstablishmentId = '0')
				INNER JOIN #User AS RU ON RU.UserId = Am.AppUserId OR @UserId = '0'
            WHERE Am.ActivityId = @ActivityId
            AND Am.QuestionnaireId = @QuestionnaireId
            AND ISNULL(Am.IsDisabled, 0) = 0
            AND (IsResolved = @AnsStatus OR @AnsStatus = '')
            AND (@TranferFilter = 0 OR Am.IsTransferred = 1)
            AND (@ActionFilter = 0  
				OR ((@ActionFilter = 1 AND AM.IsActioned=1) 
				OR (@ActionFilter=2 AND AM.IsActioned = 0 AND AM.IsResolved = 'Unresolved')))
			AND (@isPositive = '' OR	AM.IsPositive = @isPositive)
			AND (@IsOutStanding = 0 OR Am.IsOutStanding = 1)
            AND CAST(Am.CreatedOn AS DATE) BETWEEN @FromDate AND @EndDate) AS AM
            GROUP BY CASE @Type
				WHEN 1 THEN DATEPART(HOUR, CreatedOn)
                WHEN 2 THEN DATEPART(DW, CreatedOn)
                WHEN 3 THEN DATEPART(DAY, CreatedOn)
                ELSE 
					DATEPART(MONTH, CreatedOn)
            END;
				
			/*BenchMark*/
            INSERT INTO @Result (Name,Score,Counts,BenchmarkScore,BenchmarkCounts)
            SELECT CASE @Type
					WHEN 1 THEN DATEPART(HOUR, CreatedOn)
                    WHEN 2 THEN DATEPART(DW, CreatedOn)
                    WHEN 3 THEN DATEPART(DAY, CreatedOn)
            ELSE 
				DATEPART(MONTH, CreatedOn)
            END,
			0,0,COUNT(AppUserId) AS Detail,COUNT(AppUserId) AS Total
            FROM (
				SELECT Am.AppUserId,Am.CreatedOn FROM dbo.View_AnswerMaster AS Am
                LEFT OUTER JOIN #Id AS RE ON (RE.IdNo = Am.EstablishmentId OR @EstablishmentId = '0')
                LEFT OUTER JOIN #User AS RU ON RU.UserId = Am.AppUserId OR @UserId = '0'
                WHERE Am.QuestionnaireId = @QuestionnaireId
                AND RE.IdNo IS NULL
                AND ISNULL(Am.IsDisabled, 0) = 0
                AND (RU.UserId IS NULL OR (RU.UserId = 0 AND @IsTellUs = 0))
                AND (IsResolved = @AnsStatus OR @AnsStatus = '')
                AND (@TranferFilter = 0 OR Am.IsTransferred = 1)
                AND (@ActionFilter = 0  
					OR ((@ActionFilter = 1 AND AM.IsActioned=1) 
					OR (@ActionFilter=2 AND AM.IsActioned = 0 AND AM.IsResolved = 'Unresolved')))
				AND (@isPositive = '' OR AM.IsPositive = @isPositive)
				AND (@IsOutStanding = 0 OR Am.IsOutStanding = 1)
				AND CAST(Am.CreatedOn AS DATE) BETWEEN @FromDate AND @EndDate
			) AS AM
            GROUP BY CASE @Type 
				WHEN 1 THEN DATEPART(HOUR, CreatedOn)
				WHEN 2 THEN DATEPART(DW, CreatedOn)
				WHEN 3 THEN DATEPART(DAY, CreatedOn)
            ELSE 
				DATEPART(MONTH, CreatedOn) 
			END;
        END;
    ELSE
        BEGIN
			INSERT INTO @Result(Name,Score,Counts,BenchmarkScore,BenchmarkCounts)
            SELECT CASE @Type 
				WHEN 1 THEN DATEPART(HOUR, CreatedOn)
                WHEN 2 THEN DATEPART(DW, CreatedOn)
                WHEN 3 THEN DATEPART(DAY, CreatedOn)
            ELSE 
				DATEPART(MONTH, CreatedOn) 
			END,
            COUNT(AppUserId) AS Detail,COUNT(AppUserId) AS Total,0,0
            FROM (
				SELECT Am.AppUserId,Am.CreatedOn
				FROM dbo.View_SeenClientAnswerMaster AS Am
				INNER JOIN #Id AS RE ON (RE.IdNo = Am.EstablishmentId OR @EstablishmentId = '0')
				INNER JOIN #User AS RU ON RU.UserId = Am.AppUserId OR @UserId = '0'
				WHERE Am.ActivityId = @ActivityId
				AND Am.SeenClientId = @SeenClientId
                AND ISNULL(Am.IsDisabled, 0) = 0
                AND (IsResolved = @AnsStatus OR @AnsStatus = '')
                AND (@TranferFilter = 0 OR Am.IsTransferred = 1)
                AND (@ActionFilter = 0 
					OR ((@ActionFilter = 1 AND AM.IsActioned=1) 
					OR (@ActionFilter=2 AND AM.IsActioned = 0 AND AM.IsResolved = 'Unresolved')))
				AND (@isPositive = '' OR AM.IsPositive = @isPositive)
				AND (@IsOutStanding = 0 OR Am.IsOutStanding = 1)
                AND CAST(Am.CreatedOn AS DATE) BETWEEN @FromDate AND @EndDate
			) AS AM
			GROUP BY CASE @Type 
				WHEN 1 THEN DATEPART(HOUR, CreatedOn)
				WHEN 2 THEN DATEPART(DW, CreatedOn)
                WHEN 3 THEN DATEPART(DAY, CreatedOn)
            ELSE 
				DATEPART(MONTH, CreatedOn) 
			END;
					
			/*BenchMark*/
			INSERT INTO @Result(Name,Score,Counts,BenchmarkScore,BenchmarkCounts)
            SELECT CASE @Type
				WHEN 1 THEN DATEPART(HOUR, CreatedOn)
                WHEN 2 THEN DATEPART(DW, CreatedOn)
                WHEN 3 THEN DATEPART(DAY, CreatedOn)
            ELSE 
				DATEPART(MONTH, CreatedOn)
            END,
            0,0,COUNT(AppUserId) AS Detail,COUNT(AppUserId) AS Total
			FROM (
				SELECT Am.AppUserId,Am.CreatedOn FROM dbo.View_SeenClientAnswerMaster AS Am
				LEFT OUTER JOIN #Id AS RE ON (RE.IdNo = Am.EstablishmentId OR @EstablishmentId = '0')
                LEFT OUTER JOIN #User AS RU ON RU.UserId = Am.AppUserId OR @UserId = '0' 
				WHERE Am.SeenClientId = @SeenClientId
                AND ISNULL(Am.IsDisabled, 0) = 0
                AND RE.IdNo IS NULL
                AND (IsResolved = @AnsStatus OR @AnsStatus = '')
                AND (@TranferFilter = 0 OR Am.IsTransferred = 1)
                AND (@ActionFilter = 0 OR ((@ActionFilter = 1 AND AM.IsActioned=1) OR (@ActionFilter=2 AND AM.IsActioned = 0 AND AM.IsResolved = 'Unresolved')))
				AND (@isPositive = '' OR AM.IsPositive = @isPositive)
				AND (@IsOutStanding = 0 OR Am.IsOutStanding = 1)
                AND CAST(Am.CreatedOn AS DATE) BETWEEN @FromDate AND @EndDate) AS AM
                GROUP BY CASE @Type
					WHEN 1 THEN DATEPART(HOUR, CreatedOn)
                    WHEN 2 THEN DATEPART(DW, CreatedOn)
                    WHEN 3 THEN DATEPART(DAY, CreatedOn)
                ELSE 
					DATEPART(MONTH, CreatedOn)
                END;
		END;

        DECLARE @YScore DECIMAL(18, 2)
        DECLARE @YBScore DECIMAL(18, 2)
        DECLARE @TotalEntry BIGINT
        DECLARE @UserCount DECIMAL(18,2)

        SELECT @UserCount = COUNT(DISTINCT AUE.AppUserId)
        FROM dbo.Establishment AS E
        INNER JOIN dbo.EstablishmentGroup AS Eg ON Eg.Id = E.EstablishmentGroupId
        INNER JOIN AppUserEstablishment AS AUE ON AUE.EstablishmentId = E.Id AND AUE.IsDeleted = 0
        /*LEFT OUTER JOIN #User AS RU ON RU.UserId = AUE.AppUserId OR @UserId = '0'*/
		WHERE E.IsDeleted = 0 
		AND Eg.SeenClientId = @SeenClientId
        AND AUE.AppUserId NOT IN (SELECT UserId FROM #User);

        SELECT @YScore = SUM(ISNULL(Counts, 0)) FROM @Result;
        SELECT @YBScore = SUM(BenchmarkCounts) / CASE @UserCount WHEN 0 THEN 1 ELSE @UserCount END FROM @Result;
        SET @TotalEntry = @YScore
		
        SELECT @MaxRank = ISNULL(MAX(R.Data), 0) + 1
        FROM (
			SELECT SUM(ISNULL(Counts, 0)) AS Data
            FROM @Result
            GROUP BY  Name
        ) AS R;

        SELECT [@tblCount].Name,SUM(ISNULL(Score, 0)) AS QScore,SUM(ISNULL(BenchmarkScore, 0)) / 
		CASE SUM(ISNULL(BenchmarkCounts, 0)) WHEN 0 THEN 1 ELSE SUM(ISNULL(BenchmarkCounts, 0)) END AS QBenchmarkScore,
        ISNULL(@YScore, 0) AS YScore,ISNULL(@YBScore, 0) AS YBScore,(ISNULL(@YScore, 0) - ISNULL(@YBScore, 0)) / 
		CASE ISNULL(@YScore, 0) WHEN 0 THEN 1 ELSE ISNULL(@YScore, 0) END * 100 AS Performance,ISNULL(@TotalEntry, 0) AS TotalEntry,
		CASE @Type WHEN 2 THEN CONVERT(VARCHAR(1), DATENAME(DW, [@tblCount].Name - 2)) ELSE CONVERT(VARCHAR(5), [@tblCount].Name) END AS DisplayName,
        @MinRank AS MinRank,@MaxRank AS MaxRank,@LocalTime AS LastUpdatedTime,@FromDate AS StartDate,@EndDate AS EndDate,ISNULL(@DisplayType,0) AS DisplayType
        FROM @tblCount
        LEFT OUTER JOIN @Result ON [@tblCount].Name = [@Result].Name
        GROUP BY [@tblCount].Name
        ORDER BY [@tblCount].Name;         

		SET NOCOUNT OFF
END;