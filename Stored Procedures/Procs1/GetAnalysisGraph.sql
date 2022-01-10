-- =============================================
-- Author:			Sunil Vaghasiya
-- Create date:	29-Sep-2017
-- Description:	
-- Call SP:			dbo.GetAnalysisGraph
-- =============================================
CREATE PROCEDURE [dbo].[GetAnalysisGraph]
    (
      @AppUserId BIGINT ,
      @ActivityId BIGINT ,
      @EstablishmentId NVARCHAR(MAX) ,
      @UserId NVARCHAR(MAX) ,
      @FromDate DATETIME ,
      @ToDate DATETIME ,
      @IsOut BIT ,
      @ReportId BIGINT ,
      @FormStatus VARCHAR(50) ,
      @ReadUnread VARCHAR(50) ,
      @isAction VARCHAR(50) ,
      @FormActionText VARCHAR(500) ,
      @FormActionTemplate VARCHAR(1000) ,
      @isUnreadChat BIT ,
      @isRecursion BIT ,
      @isResend BIT ,
      @isTransfer BIT ,
      @Type INT ,
      @FilterOn NVARCHAR(50) ,
      @QuestionId BIGINT ,
      @OptionId INT
    )
AS
     BEGIN

IF @Type = 0
   BEGIN
		SET    @Type = 1;
   END
	  DECLARE @listStr NVARCHAR(MAX);
	  	  IF ( @EstablishmentId = '0' )
        BEGIN
            SET @EstablishmentId = ( SELECT dbo.AllEstablishmentByAppUserAndActivity(@AppuserId, @ActivityId) );
        END;
      
       DECLARE @ActivityType NVARCHAR(50);
       SELECT   @ActivityType = EstablishmentGroupType
       FROM     dbo.EstablishmentGroup
       WHERE    Id = @ActivityId;
       IF ( @UserId = '0' AND @ActivityType != 'Customer' )
        BEGIN
            SET @UserId = ( SELECT  dbo.AllUserSelected(@AppuserId, @EstablishmentId, @ActivityId) );
        END;


        DECLARE @tblCount TABLE
            (
              Id BIGINT IDENTITY(1, 1) ,
              NAME BIGINT NOT NULL
            );

        DECLARE @Result TABLE
            (
              Id BIGINT IDENTITY(1, 1) ,
              NAME BIGINT NOT NULL ,
              Score DECIMAL(18, 2) NOT NULL ,
              Counts BIGINT NOT NULL ,
              BenchmarkScore DECIMAL(18, 2) NOT NULL ,
              BenchmarkCounts BIGINT NOT NULL,
			  TotalEntry BIGINT NOT NULL 
            );

        DECLARE @CompareWithIndustry BIT = 1 ,
				@FixedBenchmark DECIMAL(18, 2)= 0;

        DECLARE @End BIGINT ,
            @Start BIGINT = 1;

        DECLARE @EndDate DATETIME ,
				@LocalTime DATETIME;
  
        DECLARE @QuestionnaireId BIGINT ,
            @SeenClientId BIGINT ,
            @EstId BIGINT ,
            @MinRank INT ,
            @MaxRank INT ,
            @DisplayType INT ,
            @QuestionIdList NVARCHAR(MAX) ,
            @TimeOffSet INT ,
            @EstablishmentGroupType NVARCHAR(50) ,
            @IsTellUs BIT ,
            @ToatlWaitage DECIMAL(18, 2) ,
            @ToatlBenchMarkWaitage DECIMAL(18, 0);

        SET @EstablishmentGroupType = 'Customer';
          SELECT TOP 1
                @QuestionnaireId = QuestionnaireId ,
				@SeenClientId = SeenClientId ,
                @TimeOffSet = TimeOffSet ,
                @UserId = CASE WHEN Eg.EstablishmentGroupType = 'Customer'
                               THEN '0'
                               ELSE @UserId
                          END ,
                @IsTellUs = CASE WHEN E.EstablishmentGroupId IS NULL
                                      AND Eg.EstablishmentGroupType = 'Customer'
                                 THEN 1
                                 ELSE 0
                            END
        FROM    dbo.EstablishmentGroup AS Eg
                INNER JOIN dbo.Establishment AS E ON Eg.Id = E.EstablishmentGroupId
        WHERE   Eg.Id = @ActivityId
                AND E.IsDeleted = 0;
	
        SELECT  @LocalTime = DATEADD(MINUTE, @TimeOffSet, GETUTCDATE());

        IF @IsOut = 0
            BEGIN
                SELECT  @MinRank = MinRank ,
                        @MaxRank = 105 ,
                        @DisplayType = DisplayType ,
                        @QuestionIdList = QuestionId
                FROM    ReportSetting
                WHERE   QuestionnaireId = @QuestionnaireId
                        AND ReportType = 'Analysis';

                SELECT  @FixedBenchmark = FixedBenchMark ,
                        @CompareWithIndustry = CASE CompareType
                                                 WHEN 2 THEN 0
                                                 ELSE 1
                                               END
                FROM    dbo.Questionnaire
                WHERE   CompareType = 2
                        AND Id = @QuestionnaireId;
            END;
        ELSE
            BEGIN
			
                SELECT  @MinRank = MinRank ,
                        @MaxRank = 100 ,
                        @DisplayType = DisplayType ,
                        @QuestionIdList = QuestionId
                FROM    ReportSetting
                WHERE   SeenClientId = @SeenClientId
                        AND ReportType = 'Analysis';

                SELECT  @FixedBenchmark = FixedBenchMark ,
                        @CompareWithIndustry = CASE CompareType
                                                 WHEN 2 THEN 0
                                                 ELSE 1
                                               END
                FROM    dbo.SeenClient
                WHERE   CompareType = 2
                        AND Id = @SeenClientId;
            END;
  
        IF @QuestionId > 0
            BEGIN
                SET @QuestionIdList = '';
            END;


        DECLARE @AnsStatus NVARCHAR(50) = '' ,
            @TranferFilter BIT = 0 ,
            @ActionFilter INT = 0 ,
            @isPositive NVARCHAR(50) = '' ,
            @IsOutStanding BIT = 0;

 IF (@FormStatus = 'Resolved' OR @FormStatus = 'Unresolved')
            BEGIN
                SET @AnsStatus = @FormStatus;
            END;
				ELSE IF @FilterOn = 'Neutral'
		BEGIN
			SET @isPositive = 'Neutral'
		END;
        
    IF @isTransfer = 1
	 BEGIN
	     SET @TranferFilter = 1;
	 END;

IF @isAction = 'Action'
  BEGIN
      SET @ActionFilter = 1;
  END;
ELSE IF @isAction = 'UnAction'
BEGIN
SET @ActionFilter = 2;
END;

IF @ReadUnread = 'Unread'
BEGIN
    SET @IsOutStanding = 1;
END;
ELSE IF @ReadUnread = 'Read'
BEGIN
SET @IsOutStanding = 0;
END;

DECLARE @ViewFromDate DATETIME = @FromDate;
      IF @Type = 1
            BEGIN
                SET @End = 24;          
                IF CONVERT(DATE, @ViewFromDate) >= CONVERT(DATE, @LocalTime)
                    BEGIN
                        SET @ViewFromDate = CONVERT(DATE, @LocalTime);
                        SET @End = DATEPART(HOUR, @LocalTime);
                    END;
                SET @EndDate = @ViewFromDate;
            END;
        ELSE
            IF @Type = 2
                BEGIN
                    SET @End = 7;
                    SET @ViewFromDate = CONVERT(DATE, DATEADD(wk,
                                                          DATEDIFF(wk, 7,
                                                              @ViewFromDate), 6));
                    SET @EndDate = DATEADD(DAY, 6, @ViewFromDate);
                    IF CONVERT(DATE, @EndDate) >= CONVERT(DATE, @LocalTime)
                        BEGIN                                      
                            SET @EndDate = @LocalTime;
                            SET @End = DATEPART(DW, @LocalTime);
                        END;
                END;
            ELSE
                IF @Type = 3
                    BEGIN
                        SET @ViewFromDate = DATEADD(DAY,
                                                1 - DATEPART(DAY, @ViewFromDate),
                                                @ViewFromDate);
                        SET @EndDate = DATEADD(DAY, -1,
                                               DATEADD(MONTH, 1, @ViewFromDate));
                        IF CONVERT(DATE, @EndDate) >= CONVERT(DATE, @LocalTime)
                            BEGIN                                      
                                SET @EndDate = @LocalTime;
                            END;
                        SET @End = DATEPART(DAY, @EndDate);
                    END;
                ELSE
                    IF @Type = 4
                        BEGIN
                            SET @ViewFromDate = DATEADD(DAY,
                                                    1 - DATEPART(DAY,
                                                              @ViewFromDate),
                                                    @ViewFromDate);
                            SET @ViewFromDate = DATEADD(MONTH,
                                                    1 - DATEPART(MONTH,
                                                              @ViewFromDate),
                                                    @ViewFromDate);
                            SET @EndDate = DATEADD(DAY, -1,
                                                   DATEADD(YEAR, 1, @ViewFromDate));
                            IF CONVERT(DATE, @EndDate) >= CONVERT(DATE, @LocalTime)
                                BEGIN                                      
                                    SET @EndDate = @LocalTime;
                                END;
                            SET @End = DATEPART(MONTH, @EndDate);
                        END;
  
        WHILE @Start <= @End
            BEGIN
                INSERT  INTO @tblCount
                        ( Name )
                VALUES  ( @Start );
	
                SET @Start += 1;
            END;

        SET @FromDate = CONVERT(DATE, @FromDate);
        SET @EndDate = CONVERT(DATE, @ToDate);

        IF @DisplayType = 0
            BEGIN
               -- PRINT 'Display Type 0 - EI Question Id';
                IF @IsOut = 0
                    BEGIN

                        INSERT  INTO @Result
                                ( Name ,
                                  Score ,
                                  Counts ,
                                  BenchmarkScore ,
                                  BenchmarkCounts,
								  TotalEntry
                                )
                                SELECT  CASE @Type
                                          WHEN 1
                                          THEN DATEPART(HOUR, CreatedOn)
                                          WHEN 2 THEN DATEPART(DW, CreatedOn)
                                          WHEN 3 THEN DATEPART(DAY, CreatedOn)
                                          ELSE DATEPART(MONTH, CreatedOn)
                                        END ,
                                        SUM(CAST(ISNULL(Detail, '') AS BIGINT)) AS Detail ,
										SUM([Counts]) AS Total,
                                        --COUNT(DISTINCT AM.Id) AS Total ,
                                        0 ,
                                        0,
										COUNT(DISTINCT AM.Id)
                                FROM    ( SELECT    AM.CreatedOn ,
                                                    A.QPI AS Detail ,
                                                    A.Id,
													CASE ISNULL(A.Detail,'') WHEN '' THEN 0 ELSE 1 END AS [Counts]
													--AM.ReportId AS Id
                                          FROM      dbo.View_AnswerMaster AS AM
                                                    INNER JOIN dbo.Answers AS A ON AM.ReportId = A.AnswerMasterId
                                                    INNER JOIN dbo.Questions Q ON A.QuestionId = Q.Id
                                                    INNER JOIN ( SELECT
                                                              Data
                                                              FROM
                                                              dbo.Split(@EstablishmentId,
                                                              ',')
                                                              ) AS RE ON ( RE.Data = AM.EstablishmentId
                                                              OR @EstablishmentId = '0'
                                                              )
                                                    INNER JOIN ( SELECT
                                                              Data
                                                              FROM
                                                              dbo.Split(@UserId,
                                                              ',')
                                                              ) AS RU ON RU.Data = AM.AppUserId
                                                              OR @UserId = '0'
                                                    INNER JOIN ( SELECT
                                                              Data
                                                              FROM
                                                              dbo.Split(@QuestionIdList,
                                                              ',')
                                                              ) AS RQ ON RQ.Data = Q.Id
                                                              OR Q.Id = @QuestionId
                                          WHERE     Q.DisplayInGraphs = 1
													--Q.QuestionTypeId = 1 AND
                                                    --AND Q.IsActive = 1
                                                    AND AM.ActivityId = @ActivityId
                                                    AND AM.QuestionnaireId = @QuestionnaireId
                                                    AND ISNULL(AM.IsDisabled,
                                                              0) = 0
                                                    AND ( IsResolved = @AnsStatus
                                                          OR @AnsStatus = ''
                                                        )
                                                    AND ( @TranferFilter = 0
                                                          OR AM.IsTransferred = 1
                                                        )
                                                    AND ( @ActionFilter = 0
                                                          OR ( ( @ActionFilter = 1
                                                              AND AM.IsActioned = 1
                                                              )
                                                              OR ( @ActionFilter = 2
                                                              AND AM.IsActioned = 0
                                                              AND AM.IsResolved = 'Unresolved'
                                                              )
                                                             )
                                                        )
                                                    AND ( @isPositive = ''
                                                          OR AM.IsPositive = @isPositive
                                                        )
                                                    AND ( @IsOutStanding = 0
                                                          OR AM.IsOutStanding = 1
                                                        )
                                                    AND CAST(AM.CreatedOn AS DATE) BETWEEN @FromDate
                                                              AND
                                                              @EndDate
                                        ) AS AM
                                GROUP BY CASE @Type
                                           WHEN 1
                                           THEN DATEPART(HOUR, CreatedOn)
                                           WHEN 2 THEN DATEPART(DW, CreatedOn)
                                           WHEN 3
                                           THEN DATEPART(DAY, CreatedOn)
                                           ELSE DATEPART(MONTH, CreatedOn)
                                         END;
						/*BenchMark*/
                       --- PRINT 'BenchMark';
                      ----  PRINT @CompareWithIndustry;
                        IF ( @CompareWithIndustry = 1 )
                            BEGIN
                                INSERT  INTO @Result
                                        ( Name ,
                                          Score ,
                                          Counts ,
                                          BenchmarkScore ,
                                          BenchmarkCounts,
										  TotalEntry
                                        )
                                        SELECT  CASE @Type
                                                  WHEN 1
                                                  THEN DATEPART(HOUR,
                                                              CreatedOn)
                                                  WHEN 2
                                                  THEN DATEPART(DW, CreatedOn)
                                                  WHEN 3
                                                  THEN DATEPART(DAY, CreatedOn)
                                                  ELSE DATEPART(MONTH,
                                                              CreatedOn)
                                                END ,
                                                0 ,
                                                0 ,
                                                SUM(CAST(ISNULL(Detail, '') AS BIGINT)) AS Detail ,
                                                SUM([Counts]) AS Total,
												0
                                        FROM    ( SELECT    AM.CreatedOn ,
                                                            A.QPI AS Detail ,
                                                            A.Id,
															CASE A.Detail WHEN '' THEN 0 ELSE 1 END AS [Counts]
															--AM.ReportId AS Id
                                                  FROM      dbo.View_AnswerMaster
                                                            AS AM
                                                            INNER JOIN dbo.Answers
                                                            AS A ON AM.ReportId = A.AnswerMasterId
                                                            INNER JOIN dbo.Questions Q ON A.QuestionId = Q.Id
                                                           INNER JOIN ( SELECT
                                                              Data
                                                              FROM
                                                              dbo.Split(@EstablishmentId,
                                                              ',')
                                                              ) AS RE ON ( RE.Data = AM.EstablishmentId
                                                              OR @EstablishmentId = '0'
                                                              )

                                                            INNER JOIN ( SELECT
                                                              Data
                                                              FROM
                                                              dbo.Split(@QuestionIdList,
                                                              ',')
                                                              ) AS RQ ON RQ.Data = Q.Id
                                                              OR Q.Id = @QuestionId
                                                  WHERE     --Q.QuestionTypeId = 1
                                                            Q.DisplayInGraphs = 1
                                                    --AND Q.IsActive = 1
                                                            AND AM.QuestionnaireId = @QuestionnaireId
                                                            AND RE.Data IS NULL
                                                            AND ISNULL(AM.IsDisabled,
                                                              0) = 0

                                                            AND ( IsResolved = @AnsStatus
                                                              OR @AnsStatus = ''
                                                              )
                                                            AND ( @TranferFilter = 0
                                                              OR AM.IsTransferred = 1
                                                              )
                                                            AND ( @ActionFilter = 0
                                                              OR ( ( @ActionFilter = 1
                                                              AND AM.IsActioned = 1
                                                              )
                                                              OR ( @ActionFilter = 2
                                                              AND AM.IsActioned = 0
                                                              AND AM.IsResolved = 'Unresolved'
                                                              )
                                                              )
                                                              )
                                                            AND ( @isPositive = ''
                                                              OR AM.IsPositive = @isPositive
                                                              )
                                                            AND ( @IsOutStanding = 0
                                                              OR AM.IsOutStanding = 1
                                                              )
                                                            AND CAST(AM.CreatedOn AS DATE) BETWEEN @FromDate
                                                              AND
                                                              @EndDate
                                                ) AS AM
                                        GROUP BY CASE @Type
                                                   WHEN 1
                                                   THEN DATEPART(HOUR,
                                                              CreatedOn)
                                                   WHEN 2
                                                   THEN DATEPART(DW, CreatedOn)
                                                   WHEN 3
                                                   THEN DATEPART(DAY,
                                                              CreatedOn)
                                                   ELSE DATEPART(MONTH,
                                                              CreatedOn)
                                                 END;
                            END;
                        ELSE
                            BEGIN
                                INSERT  INTO @Result
                                        ( Name ,
                                          Score ,
                                          Counts ,
                                          BenchmarkScore ,
                                          BenchmarkCounts,
										  TotalEntry
                                        )
                                        SELECT  CASE @Type
                                                  WHEN 1
                                                  THEN DATEPART(HOUR,
                                                              CreatedOn)
                                                  WHEN 2
                                                  THEN DATEPART(DW, CreatedOn)
                                                  WHEN 3
                                                  THEN DATEPART(DAY, CreatedOn)
                                                  ELSE DATEPART(MONTH,
                                                              CreatedOn)
                                                END ,
                                                0 ,
                                                0 ,
                                                @FixedBenchmark ,
                                                1,
												0
                                        FROM    ( SELECT    AM.CreatedOn ,
                                                            A.QPI AS Detail ,
                                                            A.Id

                                                  FROM      dbo.View_AnswerMaster
                                                            AS AM
                                                            INNER JOIN dbo.Answers
                                                            AS A ON AM.ReportId = A.AnswerMasterId
                                                            INNER JOIN dbo.Questions Q ON A.QuestionId = Q.Id
                                                            INNER JOIN ( SELECT
                                                              Data
                                                              FROM
                                                              dbo.Split(@EstablishmentId,
                                                              ',')
                                                              ) AS RE ON ( RE.Data = AM.EstablishmentId
                                                              OR @EstablishmentId = '0'
                                                              )
                                                            INNER JOIN ( SELECT
                                                              Data
                                                              FROM
                                                              dbo.Split(@UserId,
                                                              ',')
                                                              ) AS RU ON RU.Data = AM.AppUserId
                                                              OR @UserId = '0'
                                                            INNER JOIN ( SELECT
                                                              Data
                                                              FROM
                                                              dbo.Split(@QuestionIdList,
                                                              ',')
                                                              ) AS RQ ON RQ.Data = Q.Id
                                                              OR Q.Id = @QuestionId
                                                  WHERE     Q.DisplayInGraphs = 1

                                                            AND AM.ActivityId = @ActivityId
                                                            AND AM.QuestionnaireId = @QuestionnaireId
                                                            AND ISNULL(AM.IsDisabled,
                                                              0) = 0
                                                            AND ( IsResolved = @AnsStatus
                                                              OR @AnsStatus = ''
                                                              )
                                                            AND ( @TranferFilter = 0
                                                              OR AM.IsTransferred = 1
                                                              )
                                                            AND ( @ActionFilter = 0
                                                              OR ( ( @ActionFilter = 1
                                                              AND AM.IsActioned = 1
                                                              )
                                                              OR ( @ActionFilter = 2
                                                              AND AM.IsActioned = 0
                                                              AND AM.IsResolved = 'Unresolved'
                                                              )
                                                              )
                                                              )
                                                            AND ( @isPositive = ''
                                                              OR AM.IsPositive = @isPositive
                                                              )
                                                            AND ( @IsOutStanding = 0
                                                              OR AM.IsOutStanding = 1
                                                              )
                                                            AND CAST(AM.CreatedOn AS DATE) BETWEEN @FromDate
                                                              AND
                                                              @EndDate
                                                ) AS AM
                                        GROUP BY CASE @Type
                                                   WHEN 1
                                                   THEN DATEPART(HOUR,
                                                              CreatedOn)
                                                   WHEN 2
                                                   THEN DATEPART(DW, CreatedOn)
                                                   WHEN 3
                                                   THEN DATEPART(DAY,
                                                              CreatedOn)
                                                   ELSE DATEPART(MONTH,
                                                              CreatedOn)
                                                 END;
                            END;
                    END;
                ELSE --Seenclient
                    BEGIN
                        PRINT 'OUT123';
                        INSERT  INTO @Result
                                ( Name ,
                                  Score ,
                                  Counts ,
                                  BenchmarkScore,
                                  BenchmarkCounts,
								  TotalEntry
                                )
                                SELECT  CASE @Type
                                          WHEN 1
                                          THEN DATEPART(HOUR, CreatedOn)
                                          WHEN 2 THEN DATEPART(DW, CreatedOn)
                                          WHEN 3 THEN DATEPART(DAY, CreatedOn)
                                          ELSE DATEPART(MONTH, CreatedOn)
                                        END ,
                                        SUM(CAST(ISNULL(Detail, 0) AS DECIMAL(18,2))) AS Detail,

										SUM([Counts]) AS Total,
                                        0,
                                        0,
										COUNT(DISTINCT AM.Id)
                                FROM    ( SELECT  DISTINCT
                                                    AM.CreatedOn ,
													SUM(A.QPI) * 1.0
                                                / CASE SUM(CASE ISNULL(A.Detail,
                                                              '')
                                                             WHEN '' THEN 0
                                                             ELSE 1
                                                           END)
                                                    WHEN 0 THEN 1
                                                    ELSE SUM(CASE ISNULL(A.Detail,
                                                              '')
                                                              WHEN '' THEN 0
                                                              ELSE 1
                                                             END)
                                                  END AS Detail,

                                                    AM.ReportId AS Id,
													CASE A.Detail WHEN '' THEN 0 ELSE 1 END AS [Counts]
                                          FROM      dbo.View_SeenClientAnswerMaster
                                                    AS AM
                                                    INNER JOIN dbo.SeenClientAnswers
                                                    AS A ON AM.ReportId = A.SeenClientAnswerMasterId
                                                    INNER JOIN dbo.SeenClientQuestions Q ON A.QuestionId = Q.Id
                                                    INNER JOIN ( SELECT
                                                              Data
                                                              FROM
                                                              dbo.Split(@EstablishmentId,
                                                              ',')
                                                              ) AS RE ON ( RE.Data = AM.EstablishmentId
                                                              OR @EstablishmentId = '0'
                                                              )
                                                    INNER JOIN ( SELECT
                                                              Data
                                                              FROM
                                                              dbo.Split(@UserId,
                                                              ',')
                                                              ) AS RU ON RU.Data = AM.AppUserId
                                                              OR @UserId = '0'
                                                    INNER JOIN ( SELECT
                                                              Data
                                                              FROM
                                                              dbo.Split(@QuestionIdList,
                                                              ',')
                                                              ) AS RQ ON RQ.Data = Q.Id
                                                              OR Q.Id = @QuestionId
                                          WHERE     --Q.QuestionTypeId = 1
                                                    Q.DisplayInGraphs = 1
													AND Isnull(A.RepetitiveGroupId,0) = 0
                                                    AND AM.ActivityId = @ActivityId
                                                    AND AM.SeenClientId = @SeenClientId
                                                    AND ISNULL(AM.IsDisabled,
                                                              0) = 0
                                                    AND ( IsResolved = @AnsStatus
                                                          OR @AnsStatus = ''
                                                        )
                                                    AND ( @TranferFilter = 0
                                                          OR AM.IsTransferred = 1
                                                        )
                                                    AND ( @ActionFilter = 0
                                                          OR AM.IsActioned = 1
                                                        )
                                                    AND ( @isPositive = ''
                                                          OR AM.IsPositive = @isPositive
                                                        )
                                                    AND ( @IsOutStanding = 0
                                                          OR AM.IsOutStanding = 1
                                                        )
                                                    AND CAST(AM.CreatedOn AS DATE) BETWEEN @FromDate
                                                              AND
                                                              @EndDate
															  GROUP BY 
													AM.CreatedOn ,
                                                    AM.ReportId,
													 CASE A.Detail WHEN '' THEN 0 ELSE 1 END ) AS AM
                                GROUP BY CASE @Type
                                           WHEN 1
                                           THEN DATEPART(HOUR, CreatedOn)
                                           WHEN 2 THEN DATEPART(DW, CreatedOn)
                                           WHEN 3
                                           THEN DATEPART(DAY, CreatedOn)
                                           ELSE DATEPART(MONTH, CreatedOn)
                                         END;

					INSERT  INTO @Result
                                ( Name ,
                                  Score ,
                                  Counts ,
                                  BenchmarkScore,
                                  BenchmarkCounts,
								  TotalEntry
                                )
                                SELECT  CASE @Type
                                          WHEN 1
                                          THEN DATEPART(HOUR, CreatedOn)
                                          WHEN 2 THEN DATEPART(DW, CreatedOn)
                                          WHEN 3 THEN DATEPART(DAY, CreatedOn)
                                          ELSE DATEPART(MONTH, CreatedOn)
                                        END ,
                                        SUM(CAST(ISNULL(Detail, 0) AS DECIMAL(18,2))) AS Detail,

										SUM([Counts]) AS Total,
                                        0,
                                        0,
										COUNT(DISTINCT AM.Id)
                                FROM    ( SELECT  DISTINCT
                                                    AM.CreatedOn ,
													 (AVG(A.Weight) * 100 ) / AVG(Q.MaxWeight) AS Detail,

                                                    AM.ReportId AS Id,
													SUM(CASE ISNULL(A.Detail,'') WHEN '' THEN 0 ELSE 1 END) AS [Counts]
                                          FROM      dbo.View_SeenClientAnswerMaster
                                                    AS AM
                                                    INNER JOIN dbo.SeenClientAnswers
                                                    AS A ON AM.ReportId = A.SeenClientAnswerMasterId
                                                    INNER JOIN dbo.SeenClientQuestions Q ON A.QuestionId = Q.Id
                                                    INNER JOIN ( SELECT
                                                              Data
                                                              FROM
                                                              dbo.Split(@EstablishmentId,
                                                              ',')
                                                              ) AS RE ON ( RE.Data = AM.EstablishmentId
                                                              OR @EstablishmentId = '0'
                                                              )
                                                    INNER JOIN ( SELECT
                                                              Data
                                                              FROM
                                                              dbo.Split(@UserId,
                                                              ',')
                                                              ) AS RU ON RU.Data = AM.AppUserId
                                                              OR @UserId = '0'
                                                    INNER JOIN ( SELECT
                                                              Data
                                                              FROM
                                                              dbo.Split(@QuestionIdList,
                                                              ',')
                                                              ) AS RQ ON RQ.Data = Q.Id
                                                              OR Q.Id = @QuestionId
                                          WHERE     --Q.QuestionTypeId = 1
                                                    Q.DisplayInGraphs = 1
													AND Isnull(A.RepetitiveGroupId,0) != 0
                                                    AND AM.ActivityId = @ActivityId
                                                    AND AM.SeenClientId = @SeenClientId
                                                    AND ISNULL(AM.IsDisabled,
                                                              0) = 0
                                                    AND ( IsResolved = @AnsStatus
                                                          OR @AnsStatus = ''
                                                        )
                                                    AND ( @TranferFilter = 0
                                                          OR AM.IsTransferred = 1
                                                        )
                                                    AND ( @ActionFilter = 0
                                                          OR AM.IsActioned = 1
                                                        )
                                                    AND ( @isPositive = ''
                                                          OR AM.IsPositive = @isPositive
                                                        )
                                                    AND ( @IsOutStanding = 0
                                                          OR AM.IsOutStanding = 1
                                                        )
                                                    AND CAST(AM.CreatedOn AS DATE) BETWEEN @FromDate
                                                              AND
                                                              @EndDate
															  GROUP BY 
													AM.CreatedOn ,
                                                    AM.ReportId

													 ) AS AM
                                GROUP BY CASE @Type
                                           WHEN 1
                                           THEN DATEPART(HOUR, CreatedOn)
                                           WHEN 2 THEN DATEPART(DW, CreatedOn)
                                           WHEN 3
                                           THEN DATEPART(DAY, CreatedOn)
                                           ELSE DATEPART(MONTH, CreatedOn)
                                         END;

						/*BenchMark*/
                        IF ( @CompareWithIndustry = 1 )
                            BEGIN
                                PRINT '11111111111';
                                INSERT  INTO @Result
                                        ( Name ,
                                          Score ,
                                          Counts ,
                                          BenchmarkScore ,
                                          BenchmarkCounts,
										  TotalEntry
                                        )
                                        SELECT  CASE @Type
                                                  WHEN 1
                                                  THEN DATEPART(HOUR,
                                                              CreatedOn)
                                                  WHEN 2
                                                  THEN DATEPART(DW, CreatedOn)
                                                  WHEN 3
                                                  THEN DATEPART(DAY, CreatedOn)
                                                  ELSE DATEPART(MONTH,
                                                              CreatedOn)
                                                END ,
                                                0 ,
                                                0 ,
                                                SUM(CAST(ISNULL(Detail, '') AS DECIMAL(18,2))) AS Detail ,

												SUM([Counts]) AS Total,
												0
                                        FROM    ( SELECT    AM.CreatedOn ,
                                                            A.QPI AS Detail ,
                                                            A.Id,
															CASE A.Detail WHEN '' THEN 0 ELSE 1 END AS [Counts]

                                                  FROM      dbo.View_SeenClientAnswerMaster
                                                            AS AM
                                                            INNER JOIN dbo.SeenClientAnswers
                                                            AS A ON AM.ReportId = A.SeenClientAnswerMasterId
                                                            INNER JOIN dbo.SeenClientQuestions Q ON A.QuestionId = Q.Id
                                                            Inner JOIN ( SELECT
                                                              Data
                                                              FROM
                                                              dbo.Split(@EstablishmentId,
                                                              ',')
                                                              ) AS RE ON ( RE.Data = AM.EstablishmentId
                                                              OR @EstablishmentId = '0'
                                                              )

                                                            INNER JOIN ( SELECT
                                                              Data
                                                              FROM
                                                              dbo.Split(@QuestionIdList,
                                                              ',')
                                                              ) AS RQ ON RQ.Data = Q.Id
                                                              OR Q.Id = @QuestionId
                                                  WHERE  
                                                            Q.DisplayInGraphs = 1
																    AND AM.ActivityId = @ActivityId
                                                            AND AM.SeenClientId = @SeenClientId

                                                            AND ISNULL(AM.IsDisabled,
                                                              0) = 0

                                                            AND ( IsResolved = @AnsStatus
                                                              OR @AnsStatus = ''
                                                              )
                                                            AND ( @TranferFilter = 0
                                                              OR AM.IsTransferred = 1
                                                              )
                                                            AND ( @ActionFilter = 0
                                                              OR ( ( @ActionFilter = 1
                                                              AND AM.IsActioned = 1
                                                              )
                                                              OR ( @ActionFilter = 2
                                                              AND AM.IsActioned = 0
                                                              AND AM.IsResolved = 'Unresolved'
                                                              )
                                                              )
                                                              )
                                                            AND ( @isPositive = ''
                                                              OR AM.IsPositive = @isPositive
                                                              )
                                                            AND ( @IsOutStanding = 0
                                                              OR AM.IsOutStanding = 1
                                                              )
                                                            AND CAST(AM.CreatedOn AS DATE) BETWEEN @FromDate
                                                              AND
                                                              @EndDate
                                                ) AS AM
                                        GROUP BY CASE @Type
                                                   WHEN 1
                                                   THEN DATEPART(HOUR,
                                                              CreatedOn)
                                                   WHEN 2
                                                   THEN DATEPART(DW, CreatedOn)
                                                   WHEN 3
                                                   THEN DATEPART(DAY,
                                                              CreatedOn)
                                                   ELSE DATEPART(MONTH,
                                                              CreatedOn)
                                                 END;
                            END;
                        ELSE
                            BEGIN
                                INSERT  INTO @Result
                                        ( Name ,
                                          Score ,
                                          Counts ,
                                          BenchmarkScore ,
                                          BenchmarkCounts,
										  TotalEntry
                                        )
                                        SELECT  CASE @Type
                                                  WHEN 1
                                                  THEN DATEPART(HOUR,
                                                              CreatedOn)
                                                  WHEN 2
                                                  THEN DATEPART(DW, CreatedOn)
                                                  WHEN 3
                                                  THEN DATEPART(DAY, CreatedOn)
                                                  ELSE DATEPART(MONTH,
                                                              CreatedOn)
                                                END ,
                                                0 ,
                                                0 ,
                                                @FixedBenchmark ,
                                                1,
												0
                                        FROM    ( SELECT  DISTINCT
                                                            AM.CreatedOn ,
                                                            A.QPI AS Detail ,
                                                            AM.ReportId AS Id
                                                  FROM      dbo.View_SeenClientAnswerMaster
                                                            AS AM
                                                            INNER JOIN dbo.SeenClientAnswers
                                                            AS A ON AM.ReportId = A.SeenClientAnswerMasterId
                                                            INNER JOIN dbo.SeenClientQuestions Q ON A.QuestionId = Q.Id
                                                            INNER JOIN ( SELECT
                                                              Data
                                                              FROM
                                                              dbo.Split(@EstablishmentId,
                                                              ',')
                                                              ) AS RE ON ( RE.Data = AM.EstablishmentId
                                                              OR @EstablishmentId = '0'
                                                              )
                                                            INNER JOIN ( SELECT
                                                              Data
                                                              FROM
                                                              dbo.Split(@UserId,
                                                              ',')
                                                              ) AS RU ON RU.Data = AM.AppUserId
                                                              OR @UserId = '0'
                                                            INNER JOIN ( SELECT
                                                              Data
                                                              FROM
                                                              dbo.Split(@QuestionIdList,
                                                              ',')
                                                              ) AS RQ ON RQ.Data = Q.Id
                                                              OR Q.Id = @QuestionId
                                                  WHERE     --Q.QuestionTypeId = 1
                                                            Q.DisplayInGraphs = 1
                                                            AND AM.ActivityId = @ActivityId
                                                            AND AM.SeenClientId = @SeenClientId
                                                            AND ISNULL(AM.IsDisabled,
                                                              0) = 0
                                                            AND ( IsResolved = @AnsStatus
                                                              OR @AnsStatus = ''
                                                              )
                                                            AND ( @TranferFilter = 0
                                                              OR AM.IsTransferred = 1
                                                              )
                                                            AND ( @ActionFilter = 0
                                                              OR AM.IsActioned = 1
                                                              )
                                                            AND ( @isPositive = ''
                                                              OR AM.IsPositive = @isPositive
                                                              )
                                                            AND ( @IsOutStanding = 0
                                                              OR AM.IsOutStanding = 1
                                                              )
                                                            AND CAST(AM.CreatedOn AS DATE) BETWEEN @FromDate
                                                              AND
                                                              @EndDate
                                                ) AS AM
                                        GROUP BY CASE @Type
                                                   WHEN 1
                                                   THEN DATEPART(HOUR,
                                                              CreatedOn)
                                                   WHEN 2
                                                   THEN DATEPART(DW, CreatedOn)
                                                   WHEN 3
                                                   THEN DATEPART(DAY,
                                                              CreatedOn)
                                                   ELSE DATEPART(MONTH,
                                                              CreatedOn)
                                                 END;
                            END;
                    END;
            END;
        ELSE
            BEGIN
                PRINT 'Display Type 1 Count Wise Graph - NPS';
                IF @IsOut = 0
                    BEGIN
                        INSERT  INTO @Result
                                ( Name ,
                                  Score ,
                                  Counts ,
                                  BenchmarkScore ,
                                  BenchmarkCounts,
								  TotalEntry
                                )
                                SELECT  CASE @Type
                                          WHEN 1
                                          THEN DATEPART(HOUR, CreatedOn)
                                          WHEN 2 THEN DATEPART(DW, CreatedOn)
                                          WHEN 3 THEN DATEPART(DAY, CreatedOn)
                                          ELSE DATEPART(MONTH, CreatedOn)
                                        END ,
                                        COUNT(AM.Id) AS Detail ,
                                        --COUNT(AM.Id) AS Total ,
										SUM([Counts]) AS Total,
                                        0 ,
                                        0,
										COUNT(DISTINCT AM.Id)
                                FROM    ( SELECT    AM.CreatedOn ,
                                                    A.QPI AS Detail ,
                                                    A.Id,
													CASE A.Detail WHEN '' THEN 0 ELSE 1 END AS [Counts]
													--AM.ReportId AS Id
                                          FROM      dbo.View_AnswerMaster AS AM
                                                    INNER JOIN dbo.Answers AS A ON AM.ReportId = A.AnswerMasterId
                                                    INNER JOIN dbo.Questions Q ON A.QuestionId = Q.Id
                                                    INNER JOIN ( SELECT
                                                              Data
                                                              FROM
                                                              dbo.Split(@EstablishmentId,
                                                              ',')
                                                              ) AS RE ON ( RE.Data = AM.EstablishmentId
                                                              OR @EstablishmentId = '0'
                                                              )
                                                    INNER JOIN ( SELECT
                                                              Data
                                                              FROM
                                                              dbo.Split(@UserId,
                                                              ',')
                                                              ) AS RU ON RU.Data = AM.AppUserId
                                                              OR @UserId = '0'
                                          WHERE     Q.Id = @QuestionId
                                                    --AND Q.IsActive = 1
                                                    AND AM.ActivityId = @ActivityId
                                                    AND AM.QuestionnaireId = @QuestionnaireId
                                                    AND ISNULL(AM.IsDisabled,
                                                              0) = 0
                                                    AND ( IsResolved = @AnsStatus
                                                          OR @AnsStatus = ''
                                                        )
                                                    AND ( @TranferFilter = 0
                                                          OR AM.IsTransferred = 1
                                                        )
                                                    AND ( @ActionFilter = 0
                                                          OR ( ( @ActionFilter = 1
                                                              AND AM.IsActioned = 1
                                                              )
                                                              OR ( @ActionFilter = 2
                                                              AND AM.IsActioned = 0
                                                              AND AM.IsResolved = 'Unresolved'
                                                              )
                                                             )
                                                        )
                                                    AND ( @isPositive = ''
                                                          OR AM.IsPositive = @isPositive
                                                        )
                                                    AND ( @IsOutStanding = 0
                                                          OR AM.IsOutStanding = 1
                                                        )
                                                    AND CAST(AM.CreatedOn AS DATE) BETWEEN @FromDate
                                                              AND
                                                              @EndDate
                                                    AND @OptionId IN (
                                                    SELECT  Data
                                                    FROM    dbo.Split(A.OptionId,
                                                              ',') )
                                        ) AS AM
                                GROUP BY CASE @Type
                                           WHEN 1
                                           THEN DATEPART(HOUR, CreatedOn)
                                           WHEN 2 THEN DATEPART(DW, CreatedOn)
                                           WHEN 3
                                           THEN DATEPART(DAY, CreatedOn)
                                           ELSE DATEPART(MONTH, CreatedOn)
                                         END;
                                         /*BenchMark*/
                        INSERT  INTO @Result
                                ( Name ,
                                  Score ,
                                  Counts ,
                                  BenchmarkScore ,
                                  BenchmarkCounts,
								  TotalEntry
                                )
                                SELECT  CASE @Type
                                          WHEN 1
                                          THEN DATEPART(HOUR, CreatedOn)
                                          WHEN 2 THEN DATEPART(DW, CreatedOn)
                                          WHEN 3 THEN DATEPART(DAY, CreatedOn)
                                          ELSE DATEPART(MONTH, CreatedOn)
                                        END ,
                                        0 ,
                                        0 ,
                                        COUNT(AM.Id) AS Detail ,
										SUM([Counts]) AS Total,
										COUNT(DISTINCT AM.Id)

                                FROM    ( SELECT    AM.CreatedOn ,
                                                    A.QPI AS Detail ,
                                                    A.Id,
													CASE A.Detail WHEN '' THEN 0 ELSE 1 END AS [Counts]

                                          FROM      dbo.View_AnswerMaster AS AM
                                                    INNER JOIN dbo.Answers AS A ON AM.ReportId = A.AnswerMasterId
                                                    INNER JOIN dbo.Questions Q ON A.QuestionId = Q.Id
                                                    INNER JOIN ( SELECT
                                                              Data
                                                              FROM
                                                              dbo.Split(@EstablishmentId,
                                                              ',')
                                                              ) AS RE ON ( RE.Data = AM.EstablishmentId
                                                              OR @EstablishmentId = '0'
                                                              )

                                          WHERE     Q.Id = @QuestionId
                                                    AND RE.Data IS NULL
                                                    AND ISNULL(AM.IsDisabled,
                                                              0) = 0

                                                    AND AM.QuestionnaireId = @QuestionnaireId
                                                    AND ( IsResolved = @AnsStatus
                                                          OR @AnsStatus = ''
                                                        )
                                                    AND ( @TranferFilter = 0
                                                          OR AM.IsTransferred = 1
                                                        )
                                                    AND ( @ActionFilter = 0
                                                          OR ( ( @ActionFilter = 1
                                                              AND AM.IsActioned = 1
                                                              )
                                                              OR ( @ActionFilter = 2
                                                              AND AM.IsActioned = 0
                                                              AND AM.IsResolved = 'Unresolved'
                                                              )
                                                             )
                                                        )
                                                    AND ( @isPositive = ''
                                                          OR AM.IsPositive = @isPositive
                                                        )
                                                    AND ( @IsOutStanding = 0
                                                          OR AM.IsOutStanding = 1
                                                        )
                                                    AND CAST(AM.CreatedOn AS DATE) BETWEEN @FromDate
                                                              AND
                                                              @EndDate
                                                    AND @OptionId IN (
                                                    SELECT  Data
                                                    FROM    dbo.Split(A.OptionId,
                                                              ',') )
                                        ) AS AM
                                GROUP BY CASE @Type
                                           WHEN 1
                                           THEN DATEPART(HOUR, CreatedOn)
                                           WHEN 2 THEN DATEPART(DW, CreatedOn)
                                           WHEN 3
                                           THEN DATEPART(DAY, CreatedOn)
                                           ELSE DATEPART(MONTH, CreatedOn)
                                         END;
                    END;
                ELSE
                    BEGIN
                        INSERT  INTO @Result
                                ( Name ,
                                  Score ,
                                  Counts ,
                                  BenchmarkScore ,
                                  BenchmarkCounts,
								  TotalEntry
                                )
                                SELECT  CASE @Type
                                          WHEN 1
                                          THEN DATEPART(HOUR, CreatedOn)
                                          WHEN 2 THEN DATEPART(DW, CreatedOn)
                                          WHEN 3 THEN DATEPART(DAY, CreatedOn)
                                          ELSE DATEPART(MONTH, CreatedOn)
                                        END ,
                                        COUNT(AM.Id) AS Detail ,
										SUM([Counts]) AS Total,
                                        --COUNT(AM.Id) AS Total ,
                                        0 ,
                                        0,
										COUNT(DISTINCT AM.Id)
                                FROM    ( SELECT    AM.CreatedOn ,
                                                    A.QPI AS Detail ,
                                                    A.Id,
													CASE A.Detail WHEN '' THEN 0 ELSE 1 END AS [Counts]
													--AM.ReportId AS Id
                                          FROM      dbo.View_SeenClientAnswerMaster
                                                    AS AM
                                                    INNER JOIN dbo.SeenClientAnswers
                                                    AS A ON AM.ReportId = A.SeenClientAnswerMasterId
                                                    INNER JOIN dbo.SeenClientQuestions Q ON A.QuestionId = Q.Id
                                                    INNER JOIN ( SELECT
                                                              Data
                                                              FROM
                                                              dbo.Split(@EstablishmentId,
                                                              ',')
                                                              ) AS RE ON ( RE.Data = AM.EstablishmentId
                                                              OR @EstablishmentId = '0'
                                                              )
                                                    INNER JOIN ( SELECT
                                                              Data
                                                              FROM
                                                              dbo.Split(@UserId,
                                                              ',')
                                                              ) AS RU ON RU.Data = AM.AppUserId
                                                              OR @UserId = '0'
                                          WHERE     Q.Id = @QuestionId
                                                    AND AM.SeenClientId = @SeenClientId
                                                    AND AM.ActivityId = @ActivityId
                                                    AND ISNULL(AM.IsDisabled,
                                                              0) = 0
                                                    AND ( IsResolved = @AnsStatus
                                                          OR @AnsStatus = ''
                                                        )
                                                    AND ( @TranferFilter = 0
                                                          OR AM.IsTransferred = 1
                                                        )
                                                    AND ( @ActionFilter = 0
                                                          OR ( ( @ActionFilter = 1
                                                              AND AM.IsActioned = 1
                                                              )
                                                              OR ( @ActionFilter = 2
                                                              AND AM.IsActioned = 0
                                                              AND AM.IsResolved = 'Unresolved'
                                                              )
                                                             )
                                                        )
                                                    AND ( @isPositive = ''
                                                          OR AM.IsPositive = @isPositive
                                                        )
                                                    AND ( @IsOutStanding = 0
                                                          OR AM.IsOutStanding = 1
                                                        )
                                                    AND CAST(AM.CreatedOn AS DATE) BETWEEN @FromDate
                                                              AND
                                                              @EndDate
                                                    AND @OptionId IN (
                                                    SELECT  Data
                                                    FROM    dbo.Split(A.OptionId,
                                                              ',') )
                                        ) AS AM
                                GROUP BY CASE @Type
                                           WHEN 1
                                           THEN DATEPART(HOUR, CreatedOn)
                                           WHEN 2 THEN DATEPART(DW, CreatedOn)
                                           WHEN 3
                                           THEN DATEPART(DAY, CreatedOn)
                                           ELSE DATEPART(MONTH, CreatedOn)
                                         END;
  /*BenchMark*/                                       
                        INSERT  INTO @Result
                                ( Name ,
                                  Score ,
                                  Counts ,
                                  BenchmarkScore ,
                                  BenchmarkCounts,
								  TotalEntry
                                )
                                SELECT  CASE @Type
                                          WHEN 1
                                          THEN DATEPART(HOUR, CreatedOn)
                                          WHEN 2 THEN DATEPART(DW, CreatedOn)
                                          WHEN 3 THEN DATEPART(DAY, CreatedOn)
                                          ELSE DATEPART(MONTH, CreatedOn)
                                        END ,
                                        0 ,
                                        0 ,
                                        COUNT(AM.Id) AS Detail ,
										SUM([Counts]) AS Total,
										COUNT(DISTINCT AM.Id)
                                FROM    ( SELECT    AM.CreatedOn ,
                                                    A.QPI AS Detail ,
                                                    A.Id,
													CASE A.Detail WHEN '' THEN 0 ELSE 1 END AS [Counts]
                                          FROM      dbo.View_SeenClientAnswerMaster
                                                    AS AM
                                                    INNER JOIN dbo.SeenClientAnswers
                                                    AS A ON AM.ReportId = A.SeenClientAnswerMasterId
                                                    INNER JOIN dbo.SeenClientQuestions Q ON A.QuestionId = Q.Id
                                                    LEFT OUTER JOIN ( SELECT
                                                              Data
                                                              FROM
                                                              dbo.Split(@EstablishmentId,
                                                              ',')
                                                              ) AS RE ON ( RE.Data = AM.EstablishmentId
                                                              OR @EstablishmentId = '0'
                                                              )
                                                    LEFT OUTER JOIN ( SELECT
                                                              Data
                                                              FROM
                                                              dbo.Split(@UserId,
                                                              ',')
                                                              ) AS RU ON RU.Data = AM.AppUserId
                                                              OR @UserId = '0'
                                          WHERE     Q.Id = @QuestionId
                                                    AND RE.Data IS NULL
                                                    AND RU.Data IS NULL
                                                    AND AM.SeenClientId = @SeenClientId
                                                    AND ISNULL(AM.IsDisabled,
                                                              0) = 0
                                                    AND ( IsResolved = @AnsStatus
                                                          OR @AnsStatus = ''
                                                        )
                                                    AND ( @TranferFilter = 0
                                                          OR AM.IsTransferred = 1
                                                        )
                                                    AND ( @ActionFilter = 0
                                                          OR ( ( @ActionFilter = 1
                                                              AND AM.IsActioned = 1
                                                              )
                                                              OR ( @ActionFilter = 2
                                                              AND AM.IsActioned = 0
                                                              AND AM.IsResolved = 'Unresolved'
                                                              )
                                                             )
                                                        )
                                                    AND ( @isPositive = ''
                                                          OR AM.IsPositive = @isPositive
                                                        )
                                                    AND ( @IsOutStanding = 0
                                                          OR AM.IsOutStanding = 1
                                                        )
                                                    AND CAST(AM.CreatedOn AS DATE) BETWEEN @FromDate
                                                              AND
                                                              @EndDate
                                                    AND @OptionId IN (
                                                    SELECT  Data
                                                    FROM    dbo.Split(A.OptionId,
                                                              ',') )
                                        ) AS AM
                                GROUP BY CASE @Type
                                           WHEN 1
                                           THEN DATEPART(HOUR, CreatedOn)
                                           WHEN 2 THEN DATEPART(DW, CreatedOn)
                                           WHEN 3
                                           THEN DATEPART(DAY, CreatedOn)
                                           ELSE DATEPART(MONTH, CreatedOn)
                                         END;
                    END;
            END;

        IF ( @IsOut = 1 )
            BEGIN
                PRINT 'ActivityId';
                PRINT @ActivityId;
                SELECT  @ToatlWaitage = dbo.PICalculationForGraphNew(@ActivityId,
                                                              @FromDate,
                                                              @EndDate,
                                                              @SeenClientId,
                                                              @IsOut, @UserId,
                                                              @EstablishmentId,
                                                              @QuestionId,@FormStatus,@ReadUnread,@isAction,@isTransfer);
                SELECT  @ToatlBenchMarkWaitage = dbo.PIBenchmarkCalculationForGraph(@ActivityId,
                                                              @FromDate,
                                                              @EndDate,
                                                              @SeenClientId,
                                                              @IsOut, @UserId,
                                                              @EstablishmentId,
                                                              @QuestionId);
	
            END;
        ELSE
            BEGIN
                SELECT  @ToatlWaitage = dbo.PICalculationForGraphNew(@ActivityId,
                                                              @FromDate,
                                                              @EndDate,
                                                              @QuestionnaireId,
                                                              @IsOut, @UserId,
                                                              @EstablishmentId,
                                                              @QuestionId,@FormStatus,@ReadUnread,@isAction,@isTransfer);
                SELECT  @ToatlBenchMarkWaitage = dbo.PIBenchmarkCalculationForGraph(@ActivityId,
                                                              @FromDate,
                                                              @EndDate,
                                                              @QuestionnaireId,
                                                              @IsOut, @UserId,
                                                              @EstablishmentId,
                                                              @QuestionId);
	
            END;




        DECLARE @YScore DECIMAL(18, 4) ,
            @YBScore DECIMAL(18, 4) ,
            @TotalEntry BIGINT;
        IF @DisplayType = 0
            BEGIN
                IF @QuestionId < 0
                    BEGIN
                        IF @IsOut = 0
                            BEGIN
                                SELECT  @YScore = ROUND(SUM(Detail * 1.00)
                                                        / SUM(Cnt * 1.00), 4)
                                FROM    ( SELECT    SUM(CAST(ISNULL(A.QPI, '') AS BIGINT)) AS Detail ,
													SUM(CASE ISNULL(A.Detail,'') WHEN '' THEN 0 ELSE 1 END) AS Cnt,
                                                    A.QuestionId
                                          FROM      dbo.View_AnswerMaster AS AM
                                                    INNER JOIN dbo.Answers AS A ON AM.ReportId = A.AnswerMasterId
                                                    INNER JOIN dbo.Questions Q ON A.QuestionId = Q.Id
                                                    INNER JOIN ( SELECT
                                                              Data
                                                              FROM
                                                              dbo.Split(@EstablishmentId,
                                                              ',')
                                                              ) AS RE ON ( RE.Data = AM.EstablishmentId
                                                              OR @EstablishmentId = '0'
                                                              )
                                                    INNER JOIN ( SELECT
                                                              Data
                                                              FROM
                                                              dbo.Split(@UserId,
                                                              ',')
                                                              ) AS RU ON RU.Data = AM.AppUserId
                                                              OR @UserId = '0'
                                                    INNER JOIN ( SELECT
                                                              Data
                                                              FROM
                                                              dbo.Split(@QuestionIdList,
                                                              ',')
                                                              ) AS RQ ON RQ.Data = Q.Id
                                                              OR Q.Id = @QuestionId
                                          WHERE     Q.QuestionTypeId = 1
                                                    AND AM.ActivityId = @ActivityId
                                                    AND AM.QuestionnaireId = @QuestionnaireId
                                                    AND ISNULL(AM.IsDisabled,
                                                              0) = 0
                                                    AND ( IsResolved = @AnsStatus
                                                          OR @AnsStatus = ''
                                                        )
                                                    AND ( @TranferFilter = 0
                                                          OR AM.IsTransferred = 1
                                                        )
                                                    AND ( @ActionFilter = 0
                                                          OR ( ( @ActionFilter = 1
                                                              AND AM.IsActioned = 1
                                                              )
                                                              OR ( @ActionFilter = 2
                                                              AND AM.IsActioned = 0
                                                              AND AM.IsResolved = 'Unresolved'
                                                              )
                                                             )
                                                        )
                                                    AND ( @isPositive = ''
                                                          OR AM.IsPositive = @isPositive
                                                        )
                                                    AND ( @IsOutStanding = 0
                                                          OR AM.IsOutStanding = 1
                                                        )
                                                    AND CAST(AM.CreatedOn AS DATE) BETWEEN @FromDate
                                                              AND
                                                              @EndDate
                                          GROUP BY  A.QuestionId
                                        ) AS AM;
                        
                                IF ( @CompareWithIndustry = 1 )
                                    BEGIN
                                        SELECT  @YBScore = ROUND(SUM(Detail
                                                              * 1.00)
                                                              / SUM(Cnt * 1.00),
                                                              4)
                                        FROM    ( SELECT    SUM(CAST(ISNULL(A.QPI,
                                                              '') AS BIGINT)) AS Detail ,
                                                            COUNT(DISTINCT A.Id) AS Cnt ,
                                                            A.QuestionId
                                                  FROM      dbo.View_AnswerMaster
                                                            AS AM
                                                            INNER JOIN dbo.Answers
                                                            AS A ON AM.ReportId = A.AnswerMasterId
                                                            INNER JOIN dbo.Questions Q ON A.QuestionId = Q.Id
                                                            INNER JOIN ( SELECT
                                                              Data
                                                              FROM
                                                              dbo.Split(@EstablishmentId,
                                                              ',')
                                                              ) AS RE ON ( RE.Data = AM.EstablishmentId
                                                              OR @EstablishmentId = '0'
                                                              )
                                                            INNER JOIN ( SELECT
                                                              Data
                                                              FROM
                                                              dbo.Split(@UserId,
                                                              ',')
                                                              ) AS RU ON RU.Data = AM.AppUserId
                                                              OR @UserId = '0'
                                                            INNER JOIN ( SELECT
                                                              Data
                                                              FROM
                                                              dbo.Split(@QuestionIdList,
                                                              ',')
                                                              ) AS RQ ON RQ.Data = Q.Id
                                                              OR Q.Id = @QuestionId
                                                  WHERE   
                                                            Q.DisplayInGraphs = 1
                                                 
                                                            AND AM.QuestionnaireId = @QuestionnaireId
                                                            AND RE.Data IS NULL
                                                            AND ISNULL(AM.IsDisabled,
                                                              0) = 0
                                                            AND ( RU.Data IS NULL
                                                              OR ( RU.Data = 0
                                                              AND @IsTellUs = 0
                                                              )
                                                              )
                                                            AND ( IsResolved = @AnsStatus
                                                              OR @AnsStatus = ''
                                                              )
                                                            AND ( @TranferFilter = 0
                                                              OR AM.IsTransferred = 1
                                                              )
                                                            AND ( @ActionFilter = 0
                                                              OR ( ( @ActionFilter = 1
                                                              AND AM.IsActioned = 1
                                                              )
                                                              OR ( @ActionFilter = 2
                                                              AND AM.IsActioned = 0
                                                              AND AM.IsResolved = 'Unresolved'
                                                              )
                                                              )
                                                              )
                                                            AND ( @isPositive = ''
                                                              OR AM.IsPositive = @isPositive
                                                              )
                                                            AND ( @IsOutStanding = 0
                                                              OR AM.IsOutStanding = 1
                                                              )
                                                            AND CAST(AM.CreatedOn AS DATE) BETWEEN @FromDate
                                                              AND
                                                              @EndDate
                                                  GROUP BY  A.QuestionId
                                                ) AS AM;
                                    END;
                                ELSE
                                    BEGIN
                                        PRINT '======= 1 YBScore =====';
                                        SELECT  @YBScore = @FixedBenchmark;
                                    END;
                            END;
                        ELSE
                            BEGIN
								/*SeenClient*/
                                SELECT  @YScore = ROUND(SUM(Detail * 1.00)
                                                        / SUM(Cnt * 1.00), 4)
                                FROM    ( SELECT    SUM(CAST(ISNULL(A.QPI, '') AS BIGINT)) AS Detail ,
								SUM(CASE ISNULL(A.Detail,'') WHEN '' THEN 0 ELSE 1 END) AS Cnt,
                                                    A.QuestionId
                                          FROM      dbo.View_SeenClientAnswerMaster
                                                    AS AM
                                                    INNER JOIN dbo.SeenClientAnswers
                                                    AS A ON AM.ReportId = A.SeenClientAnswerMasterId
                                                    INNER JOIN dbo.SeenClientQuestions Q ON A.QuestionId = Q.Id
                                                    INNER JOIN ( SELECT
                                                              Data
                                                              FROM
                                                              dbo.Split(@EstablishmentId,
                                                              ',')
                                                              ) AS RE ON ( RE.Data = AM.EstablishmentId
                                                              OR @EstablishmentId = '0'
                                                              )
                                                    INNER JOIN ( SELECT
                                                              Data
                                                              FROM
                                                              dbo.Split(@UserId,
                                                              ',')
                                                              ) AS RU ON RU.Data = AM.AppUserId
                                                              OR @UserId = '0'
                                                    INNER JOIN ( SELECT
                                                              Data
                                                              FROM
                                                              dbo.Split(@QuestionIdList,
                                                              ',')
                                                              ) AS RQ ON RQ.Data = Q.Id
                                                              OR Q.Id = @QuestionId
                                          WHERE    
                                                    Q.DisplayInGraphs = 1
                                                    AND AM.ActivityId = @ActivityId
                                                    AND AM.SeenClientId = @SeenClientId
                                                    AND ISNULL(AM.IsDisabled,
                                                              0) = 0
                                                    AND ( IsResolved = @AnsStatus
                                                          OR @AnsStatus = ''
                                                        )
                                                    AND ( @TranferFilter = 0
                                                          OR AM.IsTransferred = 1
                                                        )
                                                    AND ( @ActionFilter = 0
                                                          OR ( ( @ActionFilter = 1
                                                              AND AM.IsActioned = 1
                                                              )
                                                              OR ( @ActionFilter = 2
                                                              AND AM.IsActioned = 0
                                                              AND AM.IsResolved = 'Unresolved'
                                                              )
                                                             )
                                                        )
                                                    AND CAST(AM.CreatedOn AS DATE) BETWEEN @FromDate
                                                              AND
                                                              @EndDate
                                          GROUP BY  A.QuestionId
                                        ) AS AM;
                        
                                IF ( @CompareWithIndustry = 1 )
                                    BEGIN
                                        SELECT  @YBScore = ROUND(SUM(Detail
                                                              * 1.00)
                                                              / SUM(Cnt * 1.00),
                                                              4)
                                        FROM    ( SELECT    SUM(CAST(ISNULL(A.QPI,
                                                              '') AS BIGINT)) AS Detail ,
                                                            COUNT(DISTINCT A.Id) AS Cnt ,
                                                            A.QuestionId
                                                  FROM      dbo.View_SeenClientAnswerMaster
                                                            AS AM
                                                            INNER JOIN dbo.SeenClientAnswers
                                                            AS A ON AM.ReportId = A.SeenClientAnswerMasterId
                                                            INNER JOIN dbo.SeenClientQuestions Q ON A.QuestionId = Q.Id
                                                            INNER JOIN ( SELECT
                                                              Data
                                                              FROM
                                                              dbo.Split(@EstablishmentId,
                                                              ',')
                                                              ) AS RE ON ( RE.Data = AM.EstablishmentId
                                                              OR @EstablishmentId = '0'
                                                              )
                                                            INNER JOIN ( SELECT
                                                              Data
                                                              FROM
                                                              dbo.Split(@UserId,
                                                              ',')
                                                              ) AS RU ON RU.Data = AM.AppUserId
                                                              OR @UserId = '0'
                                                            INNER JOIN ( SELECT
                                                              Data
                                                              FROM
                                                              dbo.Split(@QuestionIdList,
                                                              ',')
                                                              ) AS RQ ON RQ.Data = Q.Id
                                                              OR Q.Id = @QuestionId
                                                  WHERE  
                                                            Q.DisplayInGraphs = 1
                                                            AND AM.SeenClientId = @SeenClientId
                                                            AND RE.Data IS NULL
                                                            AND ISNULL(AM.IsDisabled,
                                                              0) = 0
                                                            AND ( IsResolved = @AnsStatus
                                                              OR @AnsStatus = ''
                                                              )
                                                            AND ( @TranferFilter = 0
                                                              OR AM.IsTransferred = 1
                                                              )
                                                            AND ( @ActionFilter = 0
                                                              OR ( ( @ActionFilter = 1
                                                              AND AM.IsActioned = 1
                                                              )
                                                              OR ( @ActionFilter = 2
                                                              AND AM.IsActioned = 0
                                                              AND AM.IsResolved = 'Unresolved'
                                                              )
                                                              )
                                                              )
                                                            AND ( @isPositive = ''
                                                              OR AM.IsPositive = @isPositive
                                                              )
                                                            AND ( @IsOutStanding = 0
                                                              OR AM.IsOutStanding = 1
                                                              )
                                                            AND CAST(AM.CreatedOn AS DATE) BETWEEN @FromDate
                                                              AND
                                                              @EndDate
                                                  GROUP BY  A.QuestionId
                                                ) AS AM;
                                    END;
                                ELSE
                                    BEGIN
                                        SELECT  @YBScore = @FixedBenchmark;
                                    END;
                            END;
                    END;
                ELSE
                    BEGIN
					    SELECT  @YScore = ROUND(SUM(ISNULL(Score, 0))
                                                / CASE SUM(ISNULL(Counts, 0))
                                                    WHEN 0 THEN 1
                                                    ELSE SUM(Counts)
                                                  END, 4) ,
                                @YBScore = ROUND(SUM(ISNULL(BenchmarkScore, 0))
                                                 / CASE SUM(ISNULL(BenchmarkCounts,
                                                              0))
                                                     WHEN 0 THEN 1
                                                     ELSE SUM(BenchmarkCounts)
                                                   END, 4) ,
                                @TotalEntry = SUM(ISNULL(TotalEntry, 0))
                        FROM    @Result;
                    END;
                IF @QuestionId < 0
                    BEGIN
                        IF @IsOut = 0
                            BEGIN
                                SELECT  @TotalEntry = COUNT(1)
                                FROM    dbo.View_AnswerMaster AS Am
                                        INNER JOIN ( SELECT Data
                                                     FROM   dbo.Split(@EstablishmentId,
                                                              ',')
                                                   ) AS RE ON ( RE.Data = Am.EstablishmentId
                                                              OR @EstablishmentId = '0'
                                                              )
                                        INNER JOIN ( SELECT Data
                                                     FROM   dbo.Split(@UserId,
                                                              ',')
                                                   ) AS RU ON RU.Data = Am.AppUserId
                                                              OR @UserId = '0'
                                WHERE   Am.ActivityId = @ActivityId
                                        AND ISNULL(Am.IsDisabled, 0) = 0
                                        AND CAST(Am.CreatedOn AS DATE) BETWEEN @FromDate
                                                              AND
                                                              @EndDate;
                            END;
                        ELSE
                            BEGIN
                                SELECT  @TotalEntry = COUNT(1)
                                FROM    dbo.View_SeenClientAnswerMaster AS Am
                                        INNER JOIN ( SELECT Data
                                                     FROM   dbo.Split(@EstablishmentId,
                                                              ',')
                                                   ) AS RE ON ( RE.Data = Am.EstablishmentId
                                                              OR @EstablishmentId = '0'
                                                              )
                                        INNER JOIN ( SELECT Data
                                                     FROM   dbo.Split(@UserId,
                                                              ',')
                                                   ) AS RU ON RU.Data = Am.AppUserId
                                                              OR @UserId = '0'
                                WHERE   Am.ActivityId = @ActivityId
                                        AND ISNULL(Am.IsDisabled, 0) = 0
                                        AND CAST(Am.CreatedOn AS DATE) BETWEEN @FromDate
                                                              AND
                                                              @EndDate;
                            END;                              
                    END;
					/* SELECT * FROM @Result*/
                SELECT  [@tblCount].Name ,
                        ROUND(SUM(ISNULL(Score, 0)), 0) AS Score ,
                        ROUND(SUM(ISNULL(Counts, 0)), 0) AS Counts ,
                        ROUND(SUM(ISNULL(BenchmarkScore, 0)), 0) AS BenchmarkScore ,
                        ROUND(SUM(ISNULL(BenchmarkCounts, 0)), 0) AS BenchmarkCounts ,
						ROUND(( SUM(ISNULL(Score, 0))
                                / CASE SUM(ISNULL(Counts, 0))
                                    WHEN 0 THEN 1
                                    ELSE SUM(ISNULL(Counts, 0))
                                  END ), 0) AS QScore ,
                        ROUND(( SUM(ISNULL(BenchmarkScore, 0))
                                / CASE SUM(ISNULL(BenchmarkCounts, 0))
                                    WHEN 0 THEN 1
                                    ELSE SUM(ISNULL(BenchmarkCounts, 0))
                                  END ), 0) AS QBenchmarkScore ,
                        ROUND(ISNULL(@ToatlWaitage, 0), 0) AS YScore ,
                        CASE @CompareWithIndustry WHEN 1 THEN ROUND(ISNULL(@ToatlBenchMarkWaitage, 0), 0) 
						ELSE
                        ROUND(( SUM(ISNULL(BenchmarkScore, 0))
                                / CASE SUM(ISNULL(BenchmarkCounts, 0))
                                    WHEN 0 THEN 1
                                    ELSE SUM(ISNULL(BenchmarkCounts, 0))
                                  END ), 0) END AS YBScore ,
								  ROUND( ISNULL(@ToatlWaitage, 0)
                                  -  (CASE @CompareWithIndustry WHEN 1 THEN ROUND(ISNULL(@ToatlBenchMarkWaitage, 0), 0) 
						ELSE
                        ROUND(SUM(ISNULL(BenchmarkScore, 0)), 0) END),0) AS Performance ,
                        ISNULL(@TotalEntry, 0) AS TotalEntry ,
                        CASE @Type
                          WHEN 2
                          THEN CONVERT(VARCHAR(1), DATENAME(DW,
                                                            [@tblCount].Name
                                                            - 2))
                          ELSE CONVERT(VARCHAR(5), [@tblCount].Name)
                        END AS DisplayName ,
                        @MinRank AS MinRank ,
                        @MaxRank AS MaxRank ,
                        @LocalTime AS LastUpdatedTime ,
                        @FromDate AS StartDate ,
                        @EndDate AS EndDate ,
                        @DisplayType AS DisplayType
                FROM    @tblCount
                        LEFT OUTER JOIN @Result ON [@tblCount].Name = [@Result].Name
                GROUP BY [@tblCount].Name
                ORDER BY [@tblCount].Name;                  
            END;
        ELSE
            IF @DisplayType = 1
                BEGIN
                    IF @IsOut = 0
                        BEGIN
                            SELECT  @TotalEntry = COUNT(1)
                            FROM    dbo.View_AnswerMaster AS Am
                                    INNER JOIN ( SELECT Data
                                                 FROM   dbo.Split(@EstablishmentId,
                                                              ',')
                                               ) AS RE ON ( RE.Data = Am.EstablishmentId
                                                            OR @EstablishmentId = '0'
                                                          )
                                    INNER JOIN ( SELECT Data
                                                 FROM   dbo.Split(@UserId, ',')
                                               ) AS RU ON RU.Data = Am.AppUserId
                                                          OR @UserId = '0'
                            WHERE   Am.ActivityId = @ActivityId
                                    AND ISNULL(Am.IsDisabled, 0) = 0
                                    AND CAST(Am.CreatedOn AS DATE) BETWEEN @FromDate
                                                              AND
                                                              @EndDate;
                        END;
                    ELSE
                        BEGIN
                            SELECT  @TotalEntry = COUNT(1)
                            FROM    dbo.View_SeenClientAnswerMaster AS Am
                                    INNER JOIN ( SELECT Data
                                                 FROM   dbo.Split(@EstablishmentId,
                                                              ',')
                                               ) AS RE ON ( RE.Data = Am.EstablishmentId
                                                            OR @EstablishmentId = '0'
                                                          )
                                    INNER JOIN ( SELECT Data
                                                 FROM   dbo.Split(@UserId, ',')
                                               ) AS RU ON RU.Data = Am.AppUserId
                                                          OR @UserId = '0'
                            WHERE   Am.ActivityId = @ActivityId
                                    AND ISNULL(Am.IsDisabled, 0) = 0
                                    AND CAST(Am.CreatedOn AS DATE) BETWEEN @FromDate
                                                              AND
                                                              @EndDate;
                        END;
                    SELECT  @YScore = ROUND(SUM(ISNULL(Score, 0)), 4)
                    FROM    @Result;
                    SELECT  @YBScore = ROUND(SUM(ISNULL(BenchmarkScore, 0)), 4)
                    FROM    @Result;

                    SELECT  @MaxRank = ISNULL(MAX(Data), 0) + 1
                    FROM    ( SELECT    SUM(Score) AS Data
                              FROM      @Result
                              GROUP BY  Name
                            ) AS R;
					
                    SELECT  [@tblCount].Name ,
                            SUM(ISNULL(Score, 0)) AS Score ,
                            SUM(ISNULL(Counts, 0)) AS Counts ,
                            SUM(ISNULL(BenchmarkScore, 0)) AS BenchmarkScore ,
                            SUM(ISNULL(BenchmarkCounts, 0)) AS BenchmarkCounts ,
                            SUM(ISNULL(Score, 0)) AS QScore ,
                            SUM(ISNULL(BenchmarkScore, 0)) AS QBenchmarkScore ,
                            ROUND(ISNULL(@ToatlWaitage, 0), 0) AS YScore ,
                            CASE @CompareWithIndustry WHEN 1 THEN ISNULL(@ToatlBenchMarkWaitage, 0) ELSE SUM(ISNULL(BenchmarkScore, 0)) end AS YBScore ,
							 ROUND(ISNULL(@ToatlWaitage, 0), 0) -  (CASE @CompareWithIndustry WHEN 1 THEN ISNULL(@ToatlBenchMarkWaitage, 0) ELSE SUM(ISNULL(BenchmarkScore, 0)) END) AS Performance,
                            ISNULL(@TotalEntry, 0) AS TotalEntry ,
                            CASE @Type
                              WHEN 2
                              THEN CONVERT(VARCHAR(1), DATENAME(DW,
                                                              [@tblCount].Name
                                                              - 2))
                              ELSE CONVERT(VARCHAR(5), [@tblCount].Name)
                            END AS DisplayName ,
                            @MinRank AS MinRank ,
                            @MaxRank AS MaxRank ,
                            @LocalTime AS LastUpdatedTime ,
                            @FromDate AS StartDate ,
                            @EndDate AS EndDate ,
                            @DisplayType AS DisplayType
                    FROM    @tblCount
                            LEFT OUTER JOIN @Result ON [@tblCount].Name = [@Result].Name
                    GROUP BY [@tblCount].Name
                    ORDER BY [@tblCount].Name;                  
                END;
            ELSE
                IF @DisplayType = 2
                    BEGIN
                        SELECT  @MaxRank = CAST(( SUM(Score) * 100
                                                  / CASE ISNULL(ISNULL(SUM(Counts),
                                                              0)
                                                              + ISNULL(SUM(Score),
                                                              0), 0)
                                                      WHEN 0 THEN 1
                                                      ELSE ISNULL(SUM(Counts),
                                                              0)
                                                           + ISNULL(SUM(Score),
                                                              0)
                                                    END ) AS NUMERIC(18, 2))
                                + 1
                        FROM    @Result
                        GROUP BY Name;
						
                        SELECT  [@tblCount].Name ,
                                SUM(ISNULL(Score, 0)) AS Score ,
                                SUM(ISNULL(Counts, 0)) AS Counts ,
                                SUM(ISNULL(BenchmarkScore, 0)) AS BenchmarkScore ,
                                SUM(ISNULL(BenchmarkCounts, 0)) AS BenchmarkCounts ,
                                SUM(ISNULL(Score, 0)) AS QScore ,
                                SUM(ISNULL(BenchmarkScore, 0)) AS QBenchmarkScore ,
                                ROUND(ISNULL(@YScore, 0), 0) AS YScore ,
								SUM(ISNULL(BenchmarkScore, 0)) AS YBScore ,
								ROUND(ISNULL(@YScore, 0), 0) - SUM(ISNULL(BenchmarkScore, 0)) AS Performance ,
                                ISNULL(@TotalEntry, 0) AS TotalEntry ,
                                CASE @Type
                                  WHEN 2
                                  THEN CONVERT(VARCHAR(1), DATENAME(DW,
                                                              [@tblCount].Name
                                                              - 2))
                                  ELSE CONVERT(VARCHAR(5), [@tblCount].Name)
                                END AS DisplayName ,
                                @MinRank AS MinRank ,
                                @MaxRank AS MaxRank ,
                                @LocalTime AS LastUpdatedTime ,
                                @FromDate AS StartDate ,
                                @EndDate AS EndDate ,
                                @DisplayType AS DisplayType
                        FROM    @tblCount
                                LEFT OUTER JOIN @Result ON [@tblCount].Name = [@Result].Name
                        GROUP BY [@tblCount].Name
                        ORDER BY [@tblCount].Name;
                    END;
    END;
