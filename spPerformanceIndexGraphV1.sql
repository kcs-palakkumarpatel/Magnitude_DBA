-- =============================================
-- Author:		<Author,,GD>
-- Create date: <Create Date,,18 Nov 2015>
-- Description:	<Description,,>
-- Call SP:		spPerformanceIndexGraphV1 '13410', 2433, '07 Sep 2017', 1, -1, '0', 0, '',1246
-- Call SP:		spPerformanceIndexGraphV1 '1596', 1177, '18 Sep 2017', 1, -1, '0', 0, '',1243
-- =============================================
CREATE PROCEDURE [dbo].[spPerformanceIndexGraphV1]
    @EstablishmentId NVARCHAR(MAX) ,
    @ActivityId BIGINT ,
    @FromDate DATETIME ,
    @Type INT ,
    @OptionId INT ,
    @UserId NVARCHAR(MAX) ,
    @IsOut BIT ,
    @FilterOn NVARCHAR(50),
	@AppuserId BIGINT
AS
    BEGIN

        IF ( @EstablishmentId = '0' )
        BEGIN
            SET @EstablishmentId = ( SELECT dbo.AllEstablishmentByAppUserAndActivity(@AppuserId,
                                                              @ActivityId)
                                   );
        END;
      
       DECLARE @ActivityType NVARCHAR(50);
       SELECT   @ActivityType = EstablishmentGroupType
       FROM     dbo.EstablishmentGroup
       WHERE    Id = @ActivityId;
       IF ( @UserId = '0'
            AND @ActivityType != 'Customer'
          )
        BEGIN
            SET @UserId = ( SELECT  dbo.AllUserSelected(@AppuserId,
                                                        @EstablishmentId,
                                                        @ActivityId)
                          );
        END;
		ELSE IF (@UserId = '0' AND @ActivityType = 'Customer')
		BEGIN
		DECLARE @NewUser NVARCHAR(max);
			SELECT @NewUser = COALESCE(@NewUser+',' ,'') + CONVERT(VARCHAR(10), AppUserId) FROM dbo.AppUserEstablishment WHERE EstablishmentId IN (SELECT data FROM dbo.Split(@EstablishmentId,','))
			SET @UserId = @NewUser
		END
        
        DECLARE @tblCount TABLE
            (
              Id BIGINT IDENTITY(1, 1) ,
              Name BIGINT NOT NULL
            );

        DECLARE @Result TABLE
            (
              Id BIGINT IDENTITY(1, 1) ,
              Name BIGINT NOT NULL ,
              Score DECIMAL(18, 2) NOT NULL ,
              Counts BIGINT NOT NULL ,
              BenchmarkScore DECIMAL(18, 2) NOT NULL ,
              BenchmarkCounts BIGINT NOT NULL
            );

			 DECLARE @FinalResult TABLE
            (
              Name BIGINT NOT NULL ,
              Score DECIMAL(18, 2) NOT NULL ,
              Counts BIGINT NOT NULL ,
              BenchmarkScore DECIMAL(18, 2) NOT NULL ,
              BenchmarkCounts BIGINT NOT NULL
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
            @IsTellUs BIT;

        SET @EstablishmentGroupType = 'Customer';
  
        SELECT TOP 1
                @QuestionnaireId = QuestionnaireId ,
                @TimeOffSet = TimeOffSet ,
                @SeenClientId = SeenClientId ,
                --@UserId = CASE WHEN Eg.EstablishmentGroupType = 'Customer'
                --               THEN '0'
                --               ELSE @UserId
                --          END ,
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
                        @MaxRank = MaxRank ,
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
                        @MaxRank = MaxRank ,
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

        PRINT 'Questionnaire';
        PRINT @QuestionnaireId;
        PRINT 'SeenClient';
        PRINT @SeenClientId;
        PRINT 'Display Type';
        PRINT @DisplayType;
        PRINT 'Question';
        PRINT @QuestionIdList;
		PRINT 'ActivityType'
		PRINT @ActivityType

        DECLARE @AnsStatus NVARCHAR(50) = '' ,
            @TranferFilter BIT = 0 ,
            @ActionFilter INT = 0 ,
            @isPositive NVARCHAR(50) = '' ,
            @IsOutStanding BIT = 0;

        IF ( @FilterOn = 'Resolved'
             OR @FilterOn = 'Unresolved'
           )
            BEGIN
                SET @AnsStatus = @FilterOn;
            END;
        ELSE
            IF @FilterOn = 'Neutral'
                BEGIN
                    SET @isPositive = 'Neutral';
                END;
            ELSE
                IF @FilterOn = 'Transferred'
                    BEGIN
                        SET @TranferFilter = 1;
                    END;
                ELSE
                    IF @FilterOn = 'Actioned'
                        BEGIN
                            SET @ActionFilter = 1;
                        END;
                    ELSE
                        IF @FilterOn = 'Unactioned'
                            BEGIN
                                SET @ActionFilter = 2;
                            END;
                        ELSE
                            IF @FilterOn = 'OutStanding'
                                BEGIN
                                    SET @IsOutStanding = 1;
                                END;
        PRINT @FilterOn;
        PRINT @AnsStatus;
        PRINT @TranferFilter;
        PRINT @ActionFilter;
        PRINT @IsOutStanding;

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
        ELSE
            IF @Type = 2
                BEGIN
                    SET @End = 7;
                    SET @FromDate = CONVERT(DATE, DATEADD(wk,
                                                          DATEDIFF(wk, 7,
                                                              @FromDate), 6));
                    SET @EndDate = DATEADD(DAY, 6, @FromDate);
                    IF CONVERT(DATE, @EndDate) >= CONVERT(DATE, @LocalTime)
                        BEGIN                                      
                            SET @EndDate = @LocalTime;
                            SET @End = DATEPART(DW, @LocalTime);
                        END;
                END;
            ELSE
                IF @Type = 3
                    BEGIN
                        SET @FromDate = DATEADD(DAY,
                                                1 - DATEPART(DAY, @FromDate),
                                                @FromDate);
                        SET @EndDate = DATEADD(DAY, -1,
                                               DATEADD(MONTH, 1, @FromDate));
                        IF CONVERT(DATE, @EndDate) >= CONVERT(DATE, @LocalTime)
                            BEGIN                                      
                                SET @EndDate = @LocalTime;
                            END;
                        SET @End = DATEPART(DAY, @EndDate);
                    END;
                ELSE
                    IF @Type = 4
                        BEGIN
                            SET @FromDate = DATEADD(DAY,
                                                    1 - DATEPART(DAY,
                                                              @FromDate),
                                                    @FromDate);
                            SET @FromDate = DATEADD(MONTH,
                                                    1 - DATEPART(MONTH,
                                                              @FromDate),
                                                    @FromDate);
                            SET @EndDate = DATEADD(DAY, -1,
                                                   DATEADD(YEAR, 1, @FromDate));
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
        SET @EndDate = CONVERT(DATE, @EndDate);
        PRINT 'From Date';
        PRINT @FromDate;
        PRINT 'End Date';
        PRINT @EndDate;
        IF @DisplayType = 0
            BEGIN
                PRINT 'Display Type 0 - EI Question Id';
                IF @IsOut = 0
                    BEGIN
                        PRINT 'IN';
                        INSERT  INTO @Result
                                ( Name ,
                                  Score ,
                                  Counts ,
                                  BenchmarkScore ,
                                  BenchmarkCounts
                                )
                              SELECT T.CreatedOn, AVG(T.Detail),
                                        COUNT(DISTINCT T.Id) AS Total ,
                                        0 ,
                                        0
							 FROM (
							    SELECT  CASE @Type
                                          WHEN 1
                                          THEN DATEPART(HOUR, CreatedOn)
                                          WHEN 2 THEN DATEPART(DW, CreatedOn)
                                          WHEN 3 THEN DATEPART(DAY, CreatedOn)
                                          ELSE DATEPART(MONTH, CreatedOn)
                                        END AS CreatedOn ,
                                        --SUM(QPI) AS Detail ,
                                        ( SUM(Weight) * 100 ) / CASE SUM(MaxWeight) WHEN  0 THEN 1 ELSE SUM(maxweight) end AS Detail ,
                                        COUNT(DISTINCT AM.Id) AS Total ,
                                        0 BenchmarkScore ,
                                        0 BenchmarkCounts,
										AM.Id
                                FROM    ( SELECT    AM.CreatedOn ,
                                                    AVG(A.Weight) AS  Weight ,
                                                    AM.ReportId AS Id,
                                                    CASE AVG(A.Weight) WHEN 0 THEN 0 ELSE Q.MaxWeight END AS MaxWeight
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
                                                    --INNER JOIN ( SELECT
                                                    --          Data
                                                    --          FROM
                                                    --          dbo.Split(@QuestionIdList,
                                                    --          ',')
                                                    --          ) AS RQ ON RQ.Data = Q.Id
                                          WHERE     Q.QuestionTypeId IN ( 1, 5,
                                                              6, 7, 18, 21 )
                                                    AND Q.DisplayInGraphs = 1
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
                                        GROUP BY  AM.CreatedOn ,
                                                    AM.ReportId ,
                                                    Q.MaxWeight ,
                                                    Q.Id
                                        ) AS AM
                                GROUP BY CASE @Type
                                           WHEN 1
                                           THEN DATEPART(HOUR, CreatedOn)
                                           WHEN 2 THEN DATEPART(DW, CreatedOn)
                                           WHEN 3
                                           THEN DATEPART(DAY, CreatedOn)
                                           ELSE DATEPART(MONTH, CreatedOn) end, am.Id) AS T GROUP BY T.CreatedOn
						/*BenchMark*/
                        PRINT 'BenchMark';
                        IF ( @CompareWithIndustry = 1 )
                            BEGIN
                                PRINT 'BenchMark123';
                                INSERT  INTO @Result
                                        ( Name ,
                                          Score ,
                                          Counts ,
                                          BenchmarkScore ,
                                          BenchmarkCounts
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
                                                SUM(QPI) AS Detail ,
                                                COUNT(DISTINCT AM.Id) AS Total
                                        FROM    ( SELECT    AM.CreatedOn ,
                                                            A.QPI ,
                                                            A.Id
                                                  FROM      dbo.View_AnswerMaster
                                                            AS AM
                                                            INNER JOIN dbo.Answers
                                                            AS A ON AM.ReportId = A.AnswerMasterId
                                                            INNER JOIN dbo.Questions Q ON A.QuestionId = Q.Id
                                                            Inner JOIN ( SELECT
                                                              Data
                                                              FROM
                                                              dbo.Split(@EstablishmentId,
                                                              ',')
                                                              ) AS RE ON ( RE.Data = AM.EstablishmentId
                                                              OR @EstablishmentId = '0'
                                                              )
                                                            --LEFT OUTER JOIN ( SELECT
                                                            --  Data
                                                            --  FROM
                                                            --  dbo.Split(@UserId,
                                                            --  ',')
                                                            --  ) AS RU ON RU.Data = AM.AppUserId
                                                            --  OR @UserId = '0'
                                                    --INNER JOIN ( SELECT
                                                    --          Data
                                                    --          FROM
                                                    --          dbo.Split(@QuestionIdList,
                                                    --          ',')
                                                    --          ) AS RQ ON RQ.Data = Q.Id
                                                  WHERE     Q.QuestionTypeId IN (
                                                            1, 5, 6, 7, 18, 21 )
                                                            AND Q.DisplayInGraphs = 1
                                                            AND AM.QuestionnaireId = @QuestionnaireId
                                                            AND RE.Data IS NULL
                                                            AND ISNULL(AM.IsDisabled,
                                                              0) = 0
                                                            --AND ( RU.Data IS NULL
                                                              --OR ( RU.Data = 0
                                                              --AND @IsTellUs = 0
                                                              --)
                                                              --)
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
                                          BenchmarkCounts
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
                                                1
                                        FROM    ( SELECT    AM.CreatedOn ,
                                                            A.QPI ,
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
                                                    --INNER JOIN ( SELECT
                                                    --          Data
                                                    --          FROM
                                                    --          dbo.Split(@QuestionIdList,
                                                    --          ',')
                                                    --          ) AS RQ ON RQ.Data = Q.Id
                                                  WHERE     Q.QuestionTypeId IN (
                                                            1, 5, 6, 7, 18, 21 )
                                                            AND Q.DisplayInGraphs = 1
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
                        PRINT 'OUT';
                        INSERT  INTO @Result
                                ( Name ,
                                  Score ,
                                  Counts ,
                                  BenchmarkScore ,
                                  BenchmarkCounts
                                )
						SELECT T.CreatedOn, AVG(T.Detail),
                                        COUNT(DISTINCT T.Id) AS Total ,
                                        0 ,
                                        0
							 FROM (
							    SELECT  CASE @Type
                                          WHEN 1
                                          THEN DATEPART(HOUR, CreatedOn)
                                          WHEN 2 THEN DATEPART(DW, CreatedOn)
                                          WHEN 3 THEN DATEPART(DAY, CreatedOn)
                                          ELSE DATEPART(MONTH, CreatedOn)
                                        END AS CreatedOn ,
                                        --SUM(QPI) AS Detail ,
                                        ( SUM(Weight) * 100 ) / CASE SUM(MaxWeight) WHEN 0 THEN 1 ELSE SUM(MaxWeight) end AS Detail ,
                                        COUNT(DISTINCT AM.Id) AS Total ,
                                        0 BenchmarkScore ,
                                        0 BenchmarkCounts,
										AM.Id
                                FROM    ( SELECT    AM.CreatedOn ,
                                                    AVG(A.Weight) AS Weight ,
                                                    AM.ReportId AS Id ,
                                                    CASE AVG(A.Weight)
                                                      WHEN 0 THEN 0
                                                      ELSE Q.MaxWeight
                                                    END AS MaxWeight
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
                                                    --INNER JOIN ( SELECT
                                                    --          Data
                                                    --          FROM
                                                    --          dbo.Split(@QuestionIdList,
                                                    --          ',')
                                                    --          ) AS RQ ON RQ.Data = Q.Id
                                          WHERE     Q.QuestionTypeId IN ( 1, 5,6, 7, 18, 21 )
                                                    AND Q.DisplayInGraphs = 1
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
                                          GROUP BY  AM.CreatedOn ,
                                                    AM.ReportId ,
                                                    Q.MaxWeight ,
                                                    Q.Id
                                        ) AS AM
                                GROUP BY CASE @Type
                                           WHEN 1
                                           THEN DATEPART(HOUR, CreatedOn)
                                           WHEN 2 THEN DATEPART(DW, CreatedOn)
                                           WHEN 3
                                           THEN DATEPART(DAY, CreatedOn)
                                           ELSE DATEPART(MONTH, CreatedOn) end, am.Id) AS T GROUP BY T.CreatedOn

						/*BenchMark*/
						PRINT '2222'
                        IF ( @CompareWithIndustry = 1 )
                            BEGIN
                                INSERT  INTO @Result
                                        ( Name ,
                                          Score ,
                                          Counts ,
                                          BenchmarkScore ,
                                          BenchmarkCounts
                                        )
										SELECT T.CreatedOn, 
										0,
										0,
										AVG(T.Detail),
                                        COUNT(DISTINCT T.Id) AS Total 
							 FROM (
							    SELECT CASE @Type
                                          WHEN 1
                                          THEN DATEPART(HOUR, CreatedOn)
                                          WHEN 2 THEN DATEPART(DW, CreatedOn)
                                          WHEN 3 THEN DATEPART(DAY, CreatedOn)
                                          ELSE DATEPART(MONTH, CreatedOn)
                                        END AS CreatedOn ,
                                        --SUM(QPI) AS Detail ,
                                        ( SUM(Weight) * 100 ) /CASE SUM(ISNULL(MaxWeight,0)) WHEN 0 THEN 1 ELSE SUM(ISNULL(MaxWeight,0)) END AS Detail ,
                                        COUNT(DISTINCT AM.Id) AS Total ,
                                        0 BenchmarkScore ,
                                        0 BenchmarkCounts,
										AM.Id FROM (
                                        SELECT     AM.CreatedOn , AVG(ISNULL(A.Weight,0)) AS Weight ,
                                                    AM.ReportId AS Id ,
                                                    CASE AVG(A.Weight)
                                                      WHEN 0 THEN 0
                                                      ELSE Q.MaxWeight
                                                    END AS MaxWeight
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
                                                            --LEFT OUTER JOIN ( SELECT
                                                            --  Data
                                                            --  FROM
                                                            --  dbo.Split(@UserId,
                                                            --  ',')
                                                            --  ) AS RU ON RU.Data = AM.AppUserId
                                                            --  OR @UserId = '0'
                                                    --INNER JOIN ( SELECT
                                                    --          Data
                                                    --          FROM
                                                    --          dbo.Split(@QuestionIdList,
                                                    --          ',')
                                                    --          ) AS RQ ON RQ.Data = Q.Id
                                                  WHERE     Q.QuestionTypeId IN (
                                                            1, 5, 6, 7, 18, 21 )
                                                            AND Q.DisplayInGraphs = 1
                                                            AND AM.SeenClientId = @SeenClientId
                                                            AND RE.Data IS NULL
                                                            --AND RU.Data IS NULL
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
															     GROUP BY  AM.CreatedOn ,
                                                    AM.ReportId ,
                                                    Q.MaxWeight ,
                                                    Q.Id
                                                ) AS AM
                                GROUP BY CASE @Type
                                           WHEN 1
                                           THEN DATEPART(HOUR, CreatedOn)
                                           WHEN 2 THEN DATEPART(DW, CreatedOn)
                                           WHEN 3
                                           THEN DATEPART(DAY, CreatedOn)
                                           ELSE DATEPART(MONTH, CreatedOn) end, am.Id) AS T GROUP BY T.CreatedOn
                            END;
                        ELSE
                            BEGIN
                                INSERT  INTO @Result
                                        ( Name ,
                                          Score ,
                                          Counts ,
                                          BenchmarkScore ,
                                          BenchmarkCounts
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
                                                1
                                        FROM    ( SELECT    AM.CreatedOn ,
                                                            A.QPI ,
                                                            A.Id
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
                                                    --INNER JOIN ( SELECT
                                                    --          Data
                                                    --          FROM
                                                    --          dbo.Split(@QuestionIdList,
                                                    --          ',')
                                                    --          ) AS RQ ON RQ.Data = Q.Id
                                                  WHERE     Q.QuestionTypeId IN (
                                                            1, 5, 6, 7, 18, 21 )
                                                            AND Q.DisplayInGraphs = 1
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
                        

                    END;
            END;
        DECLARE @YScore DECIMAL(18, 4) ,
            @YBScore DECIMAL(18, 4) ,
            @TotalEntry BIGINT;
			PRINT '1'
        IF @DisplayType = 0
            BEGIN
			PRINT '2'
                IF @IsOut = 0
                    BEGIN
                        SELECT  @YScore = ROUND(SUM(Detail * 1.00) / SUM(Cnt
                                                              * 1.00), 4)
                        FROM    ( SELECT    SUM(A.QPI) AS Detail ,
                                            COUNT(DISTINCT A.Id) AS Cnt ,
                                            A.QuestionId
                                  FROM      dbo.View_AnswerMaster AS AM
                                            INNER JOIN dbo.Answers AS A ON AM.ReportId = A.AnswerMasterId
                                            INNER JOIN dbo.Questions Q ON A.QuestionId = Q.Id
                                            INNER JOIN ( SELECT
                                                              Data
                                                         FROM dbo.Split(@EstablishmentId,
                                                              ',')
                                                       ) AS RE ON ( RE.Data = AM.EstablishmentId
                                                              OR @EstablishmentId = '0'
                                                              )
                                            INNER JOIN ( SELECT
                                                              Data
                                                         FROM dbo.Split(@UserId,
                                                              ',')
                                                       ) AS RU ON RU.Data = AM.AppUserId
                                                              OR @UserId = '0'
                                            --INNER JOIN ( SELECT
                                            --                  Data
                                            --             FROM dbo.Split(@QuestionIdList,
                                            --                  ',')
                                            --           ) AS RQ ON RQ.Data = Q.Id
                                  WHERE     Q.QuestionTypeId IN ( 1, 5, 6, 7,
                                                              18, 21 )
                                            AND Q.DisplayInGraphs = 1
                                            AND AM.ActivityId = @ActivityId
                                            AND AM.QuestionnaireId = @QuestionnaireId
                                            AND ISNULL(AM.IsDisabled, 0) = 0
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
                                SELECT  @YBScore = ROUND(SUM(Detail * 1.00)
                                                         / SUM(Cnt * 1.00), 4)
                                FROM    ( SELECT    SUM(A.QPI) AS Detail ,
                                                    COUNT(DISTINCT A.Id) AS Cnt ,
                                                    A.QuestionId
                                          FROM      dbo.View_AnswerMaster AS AM
                                                    INNER JOIN dbo.Answers AS A ON AM.ReportId = A.AnswerMasterId
                                                    INNER JOIN dbo.Questions Q ON A.QuestionId = Q.Id
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
                                            --INNER JOIN ( SELECT
                                            --                  Data
                                            --             FROM dbo.Split(@QuestionIdList,
                                            --                  ',')
                                            --           ) AS RQ ON RQ.Data = Q.Id
                                          WHERE     Q.QuestionTypeId IN ( 1, 5,
                                                              6, 7, 18, 21 )
                                                    AND Q.DisplayInGraphs = 1
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
                                PRINT '5555555';
                                SELECT  @YBScore = @FixedBenchmark;
                                PRINT @YBScore;
                            END;
                    END;
                ELSE
                    BEGIN
								/*SeenClient*/
                        SELECT  @YScore = ROUND(SUM(Detail * 1.00) / SUM(Cnt
                                                              * 1.00), 4)
                        FROM    ( SELECT    SUM(A.QPI) AS Detail ,
                                            COUNT(DISTINCT A.Id) AS Cnt ,
											--COUNT(DISTINCT AM.ReportId) AS Cnt ,
                                            A.QuestionId
                                  FROM      dbo.View_SeenClientAnswerMaster AS AM
                                            INNER JOIN dbo.SeenClientAnswers
                                            AS A ON AM.ReportId = A.SeenClientAnswerMasterId
                                            INNER JOIN dbo.SeenClientQuestions Q ON A.QuestionId = Q.Id
                                            INNER JOIN ( SELECT
                                                              Data
                                                         FROM dbo.Split(@EstablishmentId,
                                                              ',')
                                                       ) AS RE ON ( RE.Data = AM.EstablishmentId
                                                              OR @EstablishmentId = '0'
                                                              )
                                            INNER JOIN ( SELECT
                                                              Data
                                                         FROM dbo.Split(@UserId,
                                                              ',')
                                                       ) AS RU ON RU.Data = AM.AppUserId
                                                              OR @UserId = '0'
                                            --INNER JOIN ( SELECT
                                            --                  Data
                                            --             FROM dbo.Split(@QuestionIdList,
                                            --                  ',')
                                            --           ) AS RQ ON RQ.Data = Q.Id
                                  WHERE     Q.QuestionTypeId IN ( 1, 5, 6, 7,
                                                              18, 21 )
                                            AND Q.DisplayInGraphs = 1
                                            AND AM.ActivityId = @ActivityId
                                            AND AM.SeenClientId = @SeenClientId
                                            AND ISNULL(AM.IsDisabled, 0) = 0
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
                                SELECT  @YBScore = ROUND(SUM(Detail * 1.00)
                                                         / SUM(Cnt * 1.00), 4)
                                FROM    ( SELECT    SUM(A.QPI) AS Detail ,
                                                    COUNT(DISTINCT A.Id) AS Cnt ,
											--COUNT(DISTINCT AM.ReportId) AS Cnt ,
                                                    A.QuestionId
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
                                            --INNER JOIN ( SELECT
                                            --                  Data
                                            --             FROM dbo.Split(@QuestionIdList,
                                            --                  ',')
                                            --           ) AS RQ ON RQ.Data = Q.Id
                                          WHERE     Q.QuestionTypeId IN ( 1, 5,
                                                              6, 7, 18, 21 )
                                                    AND Q.DisplayInGraphs = 1
                                                    AND AM.SeenClientId = @SeenClientId
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
                                SELECT  @YBScore = @FixedBenchmark;
                            END;
                                
                    END;

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
                                AND ( IsResolved = @AnsStatus
                                      OR @AnsStatus = ''
                                    )
                                AND ( @TranferFilter = 0
                                      OR Am.IsTransferred = 1
                                    )
                                AND ( @ActionFilter = 0
                                      OR ( ( @ActionFilter = 1
                                             AND Am.IsActioned = 1
                                           )
                                           OR ( @ActionFilter = 2
                                                AND Am.IsActioned = 0
                                                AND Am.IsResolved = 'Unresolved'
                                              )
                                         )
                                    )
                                AND ( @isPositive = ''
                                      OR Am.IsPositive = @isPositive
                                    )
                                AND ( @IsOutStanding = 0
                                      OR Am.IsOutStanding = 1
                                    )
                                AND CAST(Am.CreatedOn AS DATE) BETWEEN @FromDate
                                                              AND
                                                              @EndDate;

                        SELECT  @YScore = dbo.PICalculationForGraph(@ActivityId,
                                                              @FromDate,
                                                              @EndDate,
                                                              @QuestionnaireId,
                                                              @IsOut, @UserId,@EstablishmentId,0);
                        IF ( @CompareWithIndustry = 1 )
                            BEGIN
                                SELECT  @YBScore = dbo.PIBenchmarkCalculationForGraph(@ActivityId,
                                                              @FromDate,
                                                              @EndDate,
                                                              @QuestionnaireId,
                                                              @IsOut, @UserId,@EstablishmentId,0);
                            END;
                        ELSE
                            BEGIN
                                SELECT  @YBScore = @FixedBenchmark;
                            END;
					PRINT '@YBScore==' + CONVERT(NVARCHAR(10),@YBScore)
					PRINT '@YScore==' + CONVERT(NVARCHAR(10),@YScore)
					PRINT @ActivityId
					PRINT @FromDate
					PRINT @EndDate
					PRINT @QuestionnaireId
					PRINT @IsOut
					PRINT @UserId
					PRINT @EstablishmentId

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
                                AND ( IsResolved = @AnsStatus
                                      OR @AnsStatus = ''
                                    )
                                AND ( @TranferFilter = 0
                                      OR Am.IsTransferred = 1
                                    )
                                AND ( @ActionFilter = 0
                                      OR ( ( @ActionFilter = 1
                                             AND Am.IsActioned = 1
                                           )
                                           OR ( @ActionFilter = 2
                                                AND Am.IsActioned = 0
                                                AND Am.IsResolved = 'Unresolved'
                                              )
                                         )
                                    )
                                AND ( @isPositive = ''
                                      OR Am.IsPositive = @isPositive
                                    )
                                AND ( @IsOutStanding = 0
                                      OR Am.IsOutStanding = 1
                                    )
                                AND CAST(Am.CreatedOn AS DATE) BETWEEN @FromDate
                                                              AND
                                                              @EndDate;

                        SELECT  @YScore = dbo.PICalculationForGraph(@ActivityId,
                                                              @FromDate,
                                                              @EndDate,
                                                              @SeenClientId,
                                                              @IsOut, @UserId,@EstablishmentId,0);
                        IF ( @CompareWithIndustry = 1 )
                            BEGIN
                                SELECT  @YBScore = dbo.PIBenchmarkCalculationForGraph(@ActivityId,
                                                              @FromDate,
                                                              @EndDate,
                                                              @SeenClientId,
                                                              @IsOut, @UserId,@EstablishmentId,0);
                            END;
                        ELSE
                            BEGIN
                                SELECT  @YBScore = @FixedBenchmark;
                            END;
                    
				
                    END;

					

                --SELECT  @MaxRank = MAX(ROUND((Score / CASE Counts
                --                                 WHEN 0 THEN 1
                --                                 ELSE Counts
                --                               END),0) + 10)
                SELECT  @MaxRank = MAX(Score) + 10
                FROM    @Result;
                --GROUP BY ROUND((Score / CASE Counts
                --                                 WHEN 0 THEN 1
                --                                 ELSE Counts
                --                               END),0) + 10;


                --SELECT  @MinRank = MIN(Score / CASE Counts
                --                                 WHEN 0 THEN 1
                --                                 ELSE Counts
                --                               END) - 10
                --FROM    @Result
                --GROUP BY Name;

                --SELECT  @MinRank = ISNULL(MIN(Score) - 1, @MinRank)
                --FROM    @Result;

                --IF @MinRank = -1
                SET @MinRank = 0;

				-------- 28092016 -------
				--Benchmark COUNT issue ON Graph
				-- Issue on Graph X axis repeat no. Ticket No 0000044751
				-------- 28092016 -------

				INSERT INTO @FinalResult
				        ( Name ,
				          Score ,
				          Counts ,
				          BenchmarkScore ,
				          BenchmarkCounts
				        )
				SELECT	  Name ,
				          SUM(ISNULL(Score,0)) ,
				          SUM(ISNULL(Counts,0)) ,
				          SUM(ISNULL(BenchmarkScore,0)) ,
				          SUM(ISNULL(BenchmarkCounts,0)) FROM @Result GROUP BY Name

				


                SELECT  [@tblCount].Name ,
                        ROUND(SUM(ISNULL(Score, 0)), 0) AS Score ,
                        ROUND(SUM(ISNULL(Counts, 0)), 0) AS Counts ,
                        ROUND(SUM(ISNULL(BenchmarkScore, 0)), 0) AS BenchmarkScore ,
                        ROUND(SUM(ISNULL(BenchmarkCounts, 0)), 0) AS BenchmarkCounts ,
                        ROUND(ISNULL(Score, 0), 0) AS QScore ,
						  --ROUND((SUM(ISNULL(Score, 0)) / CASE SUM(ISNULL(Counts, 0))
        --                                          WHEN 0 THEN 1
        --                                          ELSE SUM(ISNULL(Counts, 0))
        --                                        END),0) AS QScore ,
                        --ROUND((SUM(ISNULL(Score, 0)) / CASE SUM(ISNULL(Counts, 0))
                        --                          WHEN 0 THEN 1
                        --                          ELSE SUM(ISNULL(Counts, 0))
                        --                        END),0) AS QScore ,
                        ROUND(( SUM(ISNULL(BenchmarkScore, 0))
                                / CASE SUM(ISNULL(BenchmarkCounts, 0))
                                    WHEN 0 THEN 1
                                    ELSE SUM(ISNULL(BenchmarkCounts, 0))
                                  END ), 0) AS QBenchmarkScore ,
                        ROUND(ISNULL(@YScore, 0), 0) AS YScore ,
                        ROUND(ISNULL(@YBScore, 0), 0) AS YBScore ,
						ROUND(ISNULL(@YScore, 0), 0) - ROUND(ISNULL(@YBScore, 0), 0) AS Performance ,
                        --ROUND(( ( ISNULL(@YScore, 0) - ISNULL(@YBScore, 0) )
                        --        / CASE ISNULL(@YScore, 0)
                        --            WHEN 0 THEN 1
                        --            ELSE ISNULL(@YScore, 0)
                        --          END * 100 ), 0) AS Performance ,
                        ISNULL(@TotalEntry, 0) AS TotalEntry ,
                        CASE @Type
                          WHEN 2
                          THEN CONVERT(VARCHAR(1), DATENAME(DW,
                                                            [@tblCount].Name
                                                            - 2))
                          ELSE CONVERT(VARCHAR(5), [@tblCount].Name)
                        END AS DisplayName ,
                        ISNULL(@MinRank, 0) AS MinRank ,
                        ISNULL(@MaxRank, 0) AS MaxRank ,
                        @LocalTime AS LastUpdatedTime ,
                        @FromDate AS StartDate ,
                        @EndDate AS EndDate ,
                        @DisplayType AS DisplayType
                FROM    @tblCount
                        LEFT OUTER JOIN @FinalResult ON [@tblCount].Name = [@FinalResult].Name
						--LEFT OUTER JOIN @Result ON [@tblCount].Name = [@Result].Name
                GROUP BY [@tblCount].Name ,
                        Score
                ORDER BY [@tblCount].Name;                  
            END;
    END;
