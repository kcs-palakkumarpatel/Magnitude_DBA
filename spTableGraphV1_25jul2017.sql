-- =============================================
-- Author:		<Author,,GD>
-- Create date: <Create Date,,22 Jul 2015>
-- Description:	<Description,,>
-- Call SP:	   dbo.spTableGraphV1 -2, '13503', 2491, '27 Jun 2017', 1, '1289,1338', 1, 'Growth', '',1338
-- =============================================
CREATE PROCEDURE dbo.spTableGraphV1_25jul2017
    @QuestionId BIGINT ,
    @EstablishmentId NVARCHAR(MAX) ,
    @ActivityId BIGINT ,
    @FromDate DATETIME ,
    @Type INT ,
    --@OptionId INT ,
    @UserId NVARCHAR(MAX) ,
    @IsOut BIT ,
    @Title NVARCHAR(500) ,
    @FilterOn NVARCHAR(50),
	@AppUserId BIGINT
AS
    BEGIN

	  DECLARE @listStr NVARCHAR(MAX);

	    DECLARE @OptionList NVARCHAR(MAX);
        IF ( @IsOut = 0 )
            BEGIN
                SELECT  @OptionList = COALESCE(@OptionList + ', ', '')
                        + CONVERT(NVARCHAR(50), ISNULL(Id, ''))
                FROM    dbo.Options
                WHERE   QuestionId = @QuestionId;
            END;
        ELSE
            BEGIN
                SELECT  @OptionList = COALESCE(@OptionList + ', ', '')
                        + CONVERT(NVARCHAR(50), ISNULL(Id, ''))
                FROM    dbo.SeenClientOptions
                WHERE   QuestionId = @QuestionId;
            END;
      
       IF ( @EstablishmentId = '0' )
        BEGIN
            SET @EstablishmentId = ( SELECT dbo.AllEstablishmentByAppUserAndActivity(@AppuserId,
                                                              @ActivityId)
                                   );
        END;
        
       DECLARE @CompareWithIndustry BIT = 1 ,
        @FixedBenchmark DECIMAL(18, 2)= 0;

       IF @UserId IS NULL
        BEGIN
            SET @UserId = '0';
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

        DECLARE @tblCount TABLE
            (
              Id BIGINT IDENTITY(1, 1) ,
              OptionId BIGINT NOT NULL ,
              Name NVARCHAR(250) NOT NULL
            );

        DECLARE @Result TABLE
            (
              Id BIGINT IDENTITY(1, 1) ,
              OptionId BIGINT NOT NULL ,
              Score DECIMAL(18, 2) NOT NULL ,
              Counts BIGINT NOT NULL ,
              BenchmarkScore DECIMAL(18, 2) NOT NULL ,
              BenchmarkCounts BIGINT NOT NULL
            );

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
            @QuestionTypeId BIGINT;

        SET @EstablishmentGroupType = 'Customer';
  
        SELECT TOP 1
                @QuestionnaireId = QuestionnaireId ,
                @TimeOffSet = TimeOffSet ,
                @SeenClientId = SeenClientId ,
                @UserId = CASE WHEN E.EstablishmentGroupId IS NULL
                                    AND Eg.EstablishmentGroupType = 'Customer'
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
                        @MaxRank = MaxRank ,
                        @DisplayType = DisplayType --,
                        --@QuestionIdList = QuestionId
                FROM    ReportSetting
                WHERE   QuestionnaireId = @QuestionnaireId
                        AND ReportType = 'Analysis';
            END;
        ELSE
            BEGIN
                SELECT  @MinRank = MinRank ,
                        @MaxRank = MaxRank ,
                        @DisplayType = DisplayType --,
                        --@QuestionIdList = QuestionId
                FROM    ReportSetting
                WHERE   SeenClientId = @SeenClientId
                        AND ReportType = 'Analysis';
            END;
  
        IF @QuestionId > 0
            BEGIN
                SET @QuestionIdList = '';
                IF @IsOut = 0
                    BEGIN
                        SELECT  @QuestionTypeId = QuestionTypeId
                        FROM    dbo.Questions
                        WHERE   Id = @QuestionId;
                    END;
                ELSE
                    BEGIN
                        SELECT  @QuestionTypeId = QuestionTypeId
                        FROM    dbo.SeenClientQuestions
                        WHERE   Id = @QuestionId;
                    END;
            END;
        ELSE
            BEGIN
                PRINT 'Numeric';
                SET @QuestionTypeId = 19;
                IF @IsOut = 0
                    BEGIN
                        SELECT  @QuestionIdList = COALESCE(@QuestionIdList
                                                           + ',', '')
                                + CONVERT(NVARCHAR(50), Id)
                        FROM    dbo.Questions
                        WHERE   QuestionnaireId = @QuestionnaireId
                                AND TableGroupName = @Title
                                AND QuestionTypeId = 19
                                AND IsDeleted = 0;
                    END;
                ELSE
                    BEGIN
                        SELECT  @QuestionIdList = COALESCE(@QuestionIdList
                                                           + ',', '')
                                + CONVERT(NVARCHAR(50), Id)
                        FROM    dbo.SeenClientQuestions
                        WHERE   SeenClientId = @SeenClientId
                                AND TableGroupName = @Title
                                AND QuestionTypeId = 19
                                AND IsDeleted = 0;
                    END;
            END;

        PRINT 'Questionnaire';
        PRINT @QuestionnaireId;
        PRINT 'SeenClient';
        PRINT @SeenClientId;
        PRINT 'Display Type';
        PRINT @DisplayType;
        PRINT 'Question';
        PRINT @QuestionIdList;
        PRINT 'Question Type Id';
        PRINT @QuestionTypeId;


        DECLARE @AnsStatus NVARCHAR(50) = '' ,
            @TranferFilter BIT = 0 ,
            @ActionFilter BIT = 0;

        IF @FilterOn = 'Resolved'
            BEGIN
                SET @AnsStatus = @FilterOn;
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
  
        --WHILE @Start <= @End 
        --    BEGIN
        --        INSERT  INTO @tblCount
        --                ( Name )
        --        VALUES  ( @Start )
	
        --        SET @Start += 1
        --    END

        IF @IsOut = 0
            BEGIN
                IF @QuestionTypeId = 7
                    BEGIN
                        INSERT  INTO @tblCount
                                ( OptionId, Name )
                                SELECT  1 ,
                                        'Yes';
                        INSERT  INTO @tblCount
                                ( OptionId, Name )
                                SELECT  2 ,
                                        'No';
                    END;
                ELSE
                    IF @QuestionTypeId = 19
                        BEGIN
                            INSERT  INTO @tblCount
                                    ( OptionId ,
                                      Name
                                    )
                                    SELECT  Id ,
                                            ShortName
                                    FROM    dbo.Questions
                                    WHERE   QuestionnaireId = @QuestionnaireId
                                            AND TableGroupName = @Title
                                            AND QuestionTypeId = 19
                                            AND IsDeleted = 0;
                        END;
                    ELSE
                        BEGIN
                            INSERT  INTO @tblCount
                                    ( OptionId ,
                                      Name 
                                    )
                                    SELECT  Id ,
                                            Name
                                    FROM    dbo.Options
                                    WHERE   QuestionId = @QuestionId
                                            AND IsDeleted = 0;
                        END;
            END;
        ELSE
            BEGIN
                IF @QuestionTypeId = 7
                    BEGIN
                        INSERT  INTO @tblCount
                                ( OptionId, Name )
                                SELECT  1 ,
                                        'Yes';
                        INSERT  INTO @tblCount
                                ( OptionId, Name )
                                SELECT  2 ,
                                        'No';
                    END;
                ELSE
                    IF @QuestionTypeId = 19
                        BEGIN
                            INSERT  INTO @tblCount
                                    ( OptionId ,
                                      Name
                                    )
                                    SELECT  Id ,
                                            ShortName
                                    FROM    dbo.SeenClientQuestions
                                    WHERE   SeenClientId = @SeenClientId
                                            AND TableGroupName = @Title
                                            AND QuestionTypeId = 19
                                            AND IsDeleted = 0;
                        END;
                    ELSE
                        BEGIN
                            INSERT  INTO @tblCount
                                    ( OptionId ,
                                      Name 
                                    )
                                    SELECT  Id ,
                                            Name
                                    FROM    dbo.SeenClientOptions
                                    WHERE   QuestionId = @QuestionId
                                            AND IsDeleted = 0;
                        END;
            END;

        SET @FromDate = CONVERT(DATE, @FromDate);
        SET @EndDate = CONVERT(DATE, @EndDate);
        PRINT 'From Date';
        PRINT @FromDate;
        PRINT 'End Date';
        PRINT @EndDate;

        DECLARE @YScore DECIMAL(18, 4) ,
            @YBScore DECIMAL(18, 4) ,
            @TotalEntry BIGINT ,
            @TodayEntry INT;

        IF @IsOut = 0
            BEGIN
                PRINT 'IN';
                SELECT  @TotalEntry = COUNT(AM.ReportId) ,
                        @TodayEntry = COUNT(DISTINCT AM.ReportId)
                FROM    dbo.View_AnswerMaster AS AM
                        INNER JOIN dbo.Answers AS A ON AM.ReportId = A.AnswerMasterId
                        INNER JOIN dbo.Questions AS Q ON Q.Id = A.QuestionId
                        INNER JOIN ( SELECT Data
                                     FROM   dbo.Split(@EstablishmentId, ',')
                                   ) AS RE ON ( RE.Data = AM.EstablishmentId
                                                OR @EstablishmentId = '0'
                                              )
                        INNER JOIN ( SELECT Data
                                     FROM   dbo.Split(@UserId, ',')
                                   ) AS RU ON RU.Data = AM.AppUserId
                                              OR @UserId = '0'
                        INNER JOIN ( SELECT Data
                                     FROM   dbo.Split(@QuestionIdList, ',')
                                   ) AS RQ ON RQ.Data = A.QuestionId
                                              OR Q.Id = @QuestionId
                WHERE   AM.ActivityId = @ActivityId
				AND ISNULL(AM.IsDisabled,0) = 0
                        AND ( IsResolved = @AnsStatus
                              OR @AnsStatus = ''
                            )
                        AND ( @TranferFilter = 0
                              OR AM.IsTransferred = 1
                            )
                        AND ( @ActionFilter = 0
                              OR AM.IsActioned = 1
                            )
                        AND CAST(AM.CreatedOn AS DATE) BETWEEN @FromDate
                                                       AND    @EndDate;

                IF @QuestionTypeId <> 19
                    BEGIN
                        INSERT  INTO @Result
                                ( OptionId ,
                                  Score ,
                                  Counts ,
                                  BenchmarkScore ,
                                  BenchmarkCounts
                                )
                                SELECT  CASE WHEN @QuestionTypeId = 7
                                             THEN ( CASE A.Detail
                                                      WHEN 'Yes' THEN 1
                                                      ELSE 2
                                                    END )
                                             WHEN @QuestionTypeId = 14
                                                  OR @QuestionTypeId = 15
                                             THEN ( CASE WHEN A.Detail LIKE 'Yes,'
                                                         THEN 1
                                                         ELSE 2
                                                    END )
                                             ELSE ISNULL(O.Data, '')
                                        END ,
                                        COUNT(1) ,
                                        @TotalEntry ,
                                        0 ,
                                        0
                                FROM    dbo.View_AnswerMaster AS AM
                                        INNER JOIN dbo.Answers AS A ON AM.ReportId = A.AnswerMasterId
                                        INNER JOIN dbo.Questions AS Q ON Q.Id = A.QuestionId
										INNER JOIN (SELECT Data FROM dbo.Split(@OptionList,',')) AS O ON O.Data = A.OptionId
                                        --CROSS APPLY dbo.Split(ISNULL(A.OptionId,''), ',') AS O
                                        INNER JOIN ( SELECT Data
                                                     FROM   dbo.Split(@EstablishmentId,
                                                              ',')
                                                   ) AS RE ON ( RE.Data = AM.EstablishmentId
                                                              OR @EstablishmentId = '0'
                                                              )
                                        INNER JOIN ( SELECT Data
                                                     FROM   dbo.Split(@UserId,
                                                              ',')
                                                   ) AS RU ON RU.Data = AM.AppUserId
                                                              OR @UserId = '0'
                                        INNER JOIN ( SELECT Data
                                                     FROM   dbo.Split(@QuestionIdList,
                                                              ',')
                                                   ) AS RQ ON RQ.Data = A.QuestionId
                                                              OR Q.Id = @QuestionId
                                WHERE   AM.ActivityId = @ActivityId
                                        AND O.Data IS NOT NULL
										AND ISNULL(AM.IsDisabled,0) = 0
                                        AND ( IsResolved = @AnsStatus
                                              OR @AnsStatus = ''
                                            )
                                        AND ( @TranferFilter = 0
                                              OR AM.IsTransferred = 1
                                            )
                                        AND ( @ActionFilter = 0
                                              OR AM.IsActioned = 1
                                            )
                                        AND CAST(AM.CreatedOn AS DATE) BETWEEN @FromDate
                                                              AND
                                                              @EndDate
                                GROUP BY CASE WHEN @QuestionTypeId = 7
                                              THEN ( CASE A.Detail
                                                       WHEN 'Yes' THEN 1
                                                       ELSE 2
                                                     END )
                                              WHEN @QuestionTypeId = 14
                                                   OR @QuestionTypeId = 15
                                              THEN ( CASE WHEN A.Detail LIKE 'Yes,'
                                                          THEN 1
                                                          ELSE 2
                                                     END )
                                              ELSE ISNULL(O.Data, '')
                                         END;
                    END;
                ELSE
                    BEGIN
                        PRINT 'Numeric';
                        INSERT  INTO @Result
                                ( OptionId ,
                                  Score ,
                                  Counts ,
                                  BenchmarkScore ,
                                  BenchmarkCounts
                                )
								SELECT Id, SUM(details) AS Details,TotalEntry,A,B FROM (
                                SELECT  Q.Id ,
                                        sum(CAST(A.Detail AS DECIMAL(18,2))) / MAX(A.RepeatCount) AS details ,
                                        @TotalEntry AS TotalEntry ,
                                          0 AS 'A' ,
                                        0 AS 'B',
										A.AnswerMasterId AS 'C'
                                FROM    dbo.View_AnswerMaster AS AM
                                        INNER JOIN dbo.Answers AS A ON AM.ReportId = A.AnswerMasterId
                                        INNER JOIN dbo.Questions AS Q ON Q.Id = A.QuestionId
                                        CROSS APPLY dbo.Split(ISNULL(OptionId,
                                                              ''), ',') AS O
                                        INNER JOIN ( SELECT Data
                                                     FROM   dbo.Split(@EstablishmentId,
                                                              ',')
                                                   ) AS RE ON ( RE.Data = AM.EstablishmentId
                                                              OR @EstablishmentId = '0'
                                                              )
                                        INNER JOIN ( SELECT Data
                                                     FROM   dbo.Split(@UserId,
                                                              ',')
                                                   ) AS RU ON RU.Data = AM.AppUserId
                                                              OR @UserId = '0'
                                        INNER JOIN ( SELECT Data
                                                     FROM   dbo.Split(@QuestionIdList,
                                                              ',')
                                                   ) AS RQ ON RQ.Data = A.QuestionId
                                                              OR Q.Id = @QuestionId
                                WHERE   AM.ActivityId = @ActivityId
                                        AND A.Detail IS NOT NULL
                                        AND A.Detail NOT LIKE '%[^0-9.]%'
                                        AND A.QuestionTypeId = 19
										AND ISNULL(AM.IsDisabled,0) = 0
                                        AND ( IsResolved = @AnsStatus
                                              OR @AnsStatus = ''
                                            )
                                        AND ( @TranferFilter = 0
                                              OR AM.IsTransferred = 1
                                            )
                                        AND ( @ActionFilter = 0
                                              OR AM.IsActioned = 1
                                            )
                                        AND CAST(AM.CreatedOn AS DATE) BETWEEN @FromDate
                                                              AND
                                                              @EndDate
                                GROUP BY Q.Id,A.AnswerMasterId) AS T GROUP BY T.id, T.A,T.B,TotalEntry;
                    END;
						/*BenchMark*/

                PRINT 'BenchMark';

                SELECT  @TotalEntry = COUNT(AM.ReportId)
                FROM    dbo.View_AnswerMaster AS AM
                        INNER JOIN dbo.Answers AS A ON AM.ReportId = A.AnswerMasterId
                        INNER JOIN dbo.Questions AS Q ON Q.Id = A.QuestionId
                        LEFT OUTER JOIN ( SELECT    Data
                                          FROM      dbo.Split(@EstablishmentId,
                                                              ',')
                                        ) AS RE ON ( RE.Data = AM.EstablishmentId
                                                     OR @EstablishmentId = '0'
                                                   )
                        LEFT OUTER JOIN ( SELECT    Data
                                          FROM      dbo.Split(@UserId, ',')
                                        ) AS RU ON RU.Data = AM.AppUserId
                                                   OR @UserId = '0'
                        INNER JOIN ( SELECT Data
                                     FROM   dbo.Split(@QuestionIdList, ',')
                                   ) AS RQ ON RQ.Data = A.QuestionId
                                              OR Q.Id = @QuestionId
                WHERE   AM.QuestionnaireId = @QuestionnaireId
				AND ISNULL(AM.IsDisabled,0) = 0
                        AND ( IsResolved = @AnsStatus
                              OR @AnsStatus = ''
                            )
                        AND ( @TranferFilter = 0
                              OR AM.IsTransferred = 1
                            )
                        AND ( @ActionFilter = 0
                              OR AM.IsActioned = 1
                            )
                        AND RE.Data IS NULL
                        AND ( RU.Data IS NULL
                              OR ( RU.Data = 0
                                   AND @IsTellUs = 0
                                 )
                            )
                        AND CAST(AM.CreatedOn AS DATE) BETWEEN @FromDate
                                                       AND    @EndDate;
                IF @QuestionTypeId <> 19
                    BEGIN
					PRINT 1
                        INSERT  INTO @Result
                                ( OptionId ,
                                  Score ,
                                  Counts ,
                                  BenchmarkScore ,
                                  BenchmarkCounts
                                )
                                SELECT  CASE WHEN @QuestionTypeId = 7
                                             THEN ( CASE A.Detail
                                                      WHEN 'Yes' THEN 1
                                                      ELSE 2
                                                    END )
                                             WHEN @QuestionTypeId = 14
                                                  OR @QuestionTypeId = 15
                                             THEN ( CASE WHEN A.Detail LIKE 'Yes,'
                                                         THEN 1
                                                         ELSE 2
                                                    END )
                                             ELSE ISNULL(O.Data, '')
                                        END ,
                                        0 ,
                                        0 ,
                                        COUNT(1) ,
                                        @TotalEntry
                                FROM    dbo.View_AnswerMaster AS AM
                                        INNER JOIN dbo.Answers AS A ON AM.ReportId = A.AnswerMasterId
                                        INNER JOIN dbo.Questions AS Q ON Q.Id = A.QuestionId
										INNER JOIN (SELECT Data FROM dbo.Split(@OptionList,',')) AS O ON O.Data = A.OptionId
                                        --CROSS APPLY dbo.Split(ISNULL(OptionId,''), ',') AS O
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
                                        INNER JOIN ( SELECT Data
                                                     FROM   dbo.Split(@QuestionIdList,
                                                              ',')
                                                   ) AS RQ ON RQ.Data = A.QuestionId
                                                              OR Q.Id = @QuestionId
                                WHERE   AM.QuestionnaireId = @QuestionnaireId
                                        AND O.Data IS NOT NULL
										AND ISNULL(AM.IsDisabled,0) = 0
                                        AND ( IsResolved = @AnsStatus
                                              OR @AnsStatus = ''
                                            )
                                        AND ( @TranferFilter = 0
                                              OR AM.IsTransferred = 1
                                            )
                                        AND ( @ActionFilter = 0
                                              OR AM.IsActioned = 1
                                            )
                                        AND RE.Data IS NULL
                                        AND ( RU.Data IS NULL
                                              OR ( RU.Data = 0
                                                   AND @IsTellUs = 0
                                                 )
                                            )
                                        AND CAST(AM.CreatedOn AS DATE) BETWEEN @FromDate
                                                              AND
                                                              @EndDate
                                GROUP BY CASE WHEN @QuestionTypeId = 7
                                              THEN ( CASE A.Detail
                                                       WHEN 'Yes' THEN 1
                                                       ELSE 2
                                                     END )
                                              WHEN @QuestionTypeId = 14
                                                   OR @QuestionTypeId = 15
                                              THEN ( CASE WHEN A.Detail LIKE 'Yes,'
                                                          THEN 1
                                                          ELSE 2
                                                     END )
                                              ELSE ISNULL(O.Data, '')
                                         END;
                    END;
                ELSE
                    BEGIN
					PRINT 2
                        INSERT  INTO @Result
                                ( OptionId ,
                                  Score ,
                                  Counts ,
                                  BenchmarkScore ,
                                  BenchmarkCounts
                                )
                                SELECT  Q.Id ,
                                        0 ,
                                        0 ,
                                        SUM(CAST(A.Detail AS DECIMAL(18,2))) ,
                                        @TotalEntry
                                FROM    dbo.View_AnswerMaster AS AM
                                        INNER JOIN dbo.Answers AS A ON AM.ReportId = A.AnswerMasterId
                                        INNER JOIN dbo.Questions AS Q ON Q.Id = A.QuestionId
                                        CROSS APPLY dbo.Split(ISNULL(OptionId,
                                                              ''), ',') AS O
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
                                        INNER JOIN ( SELECT Data
                                                     FROM   dbo.Split(@QuestionIdList,
                                                              ',')
                                                   ) AS RQ ON RQ.Data = A.QuestionId
                                                              OR Q.Id = @QuestionId
                                WHERE   AM.QuestionnaireId = @QuestionnaireId
                                        AND A.Detail IS NOT NULL
                                        AND A.Detail NOT LIKE '%[^0-9.]%'
                                        AND A.QuestionTypeId = 19
										AND ISNULL(AM.IsDisabled,0) = 0
                                        AND ( IsResolved = @AnsStatus
                                              OR @AnsStatus = ''
                                            )
                                        AND ( @TranferFilter = 0
                                              OR AM.IsTransferred = 1
                                            )
                                        AND ( @ActionFilter = 0
                                              OR AM.IsActioned = 1
                                            )
                                        AND RE.Data IS NULL
                                        AND ( RU.Data IS NULL
                                              OR ( RU.Data = 0
                                                   AND @IsTellUs = 0
                                                 )
                                            )
                                        AND CAST(AM.CreatedOn AS DATE) BETWEEN @FromDate
                                                              AND
                                                              @EndDate
                                GROUP BY Q.Id;
                    END;
            END;
        ELSE
            BEGIN
                PRINT 'OUT';
                SELECT  @TotalEntry = COUNT(DISTINCT AM.ReportId), --COUNT(AM.ReportId) ,
                        @TodayEntry = COUNT(DISTINCT AM.ReportId)
                FROM    dbo.View_SeenClientAnswerMaster AS AM
                        INNER JOIN dbo.SeenClientAnswers AS A ON AM.ReportId = A.SeenClientAnswerMasterId
                        INNER JOIN dbo.SeenClientQuestions AS Q ON Q.Id = A.QuestionId
                        INNER JOIN ( SELECT Data
                                     FROM   dbo.Split(@EstablishmentId, ',')
                                   ) AS RE ON ( RE.Data = AM.EstablishmentId
                                                OR @EstablishmentId = '0'
                                              )
                        INNER JOIN ( SELECT Data
                                     FROM   dbo.Split(@UserId, ',')
                                   ) AS RU ON RU.Data = AM.AppUserId
                                              OR @UserId = '0'
                        INNER JOIN ( SELECT Data
                                     FROM   dbo.Split(@QuestionIdList, ',')
                                   ) AS RQ ON RQ.Data = A.QuestionId
                                              OR Q.Id = @QuestionId
                WHERE   AM.ActivityId = @ActivityId
				AND ISNULL(AM.IsDisabled,0) = 0
                        AND ( IsResolved = @AnsStatus
                              OR @AnsStatus = ''
                            )
                        AND ( @TranferFilter = 0
                              OR AM.IsTransferred = 1
                            )
                        AND ( @ActionFilter = 0
                              OR AM.IsActioned = 1
                            )
                        AND CAST(AM.CreatedOn AS DATE) BETWEEN @FromDate
                                                       AND    @EndDate;

                IF @QuestionTypeId <> 19
                    BEGIN
                        INSERT  INTO @Result
                                ( OptionId ,
                                  Score ,
                                  Counts ,
                                  BenchmarkScore ,
                                  BenchmarkCounts
                                )
                                SELECT  CASE WHEN @QuestionTypeId = 7
                                             THEN ( CASE AM.Detail
                                                      WHEN 'Yes' THEN 1
                                                      ELSE 2
                                                    END )
                                             WHEN @QuestionTypeId = 14
                                                  OR @QuestionTypeId = 15
                                             THEN ( CASE WHEN AM.Detail LIKE 'Yes,'
                                                         THEN 1
                                                         ELSE 2
                                                    END )
                                             ELSE ISNULL(AM.Data, '')
                                        END ,
                                        COUNT(1) ,
                                        @TotalEntry ,
                                        0 ,
                                        0
								FROM (
									SELECT DISTINCT A.Detail,O.Data,am.ReportId
										FROM    dbo.View_SeenClientAnswerMaster AS AM
												INNER JOIN dbo.SeenClientAnswers AS A ON AM.ReportId = A.SeenClientAnswerMasterId
												INNER JOIN dbo.SeenClientQuestions AS Q ON Q.Id = A.QuestionId
												CROSS APPLY dbo.Split(ISNULL(OptionId,
																	  ''), ',') AS O
												INNER JOIN ( SELECT Data
															 FROM   dbo.Split(@EstablishmentId,
																	  ',')
														   ) AS RE ON ( RE.Data = AM.EstablishmentId
																	  OR @EstablishmentId = '0'
																	  )
												INNER JOIN ( SELECT Data
															 FROM   dbo.Split(@UserId,
																	  ',')
														   ) AS RU ON RU.Data = AM.AppUserId
																	  OR @UserId = '0'
												INNER JOIN ( SELECT Data
															 FROM   dbo.Split(@QuestionIdList,
																	  ',')
														   ) AS RQ ON RQ.Data = A.QuestionId
																	  OR Q.Id = @QuestionId
										WHERE   AM.ActivityId = @ActivityId
												AND O.Data IS NOT NULL
												AND ISNULL(AM.IsDisabled,0) = 0
												AND ( IsResolved = @AnsStatus
													  OR @AnsStatus = ''
													)
												AND ( @TranferFilter = 0
													  OR AM.IsTransferred = 1
													)
												AND ( @ActionFilter = 0
													  OR AM.IsActioned = 1
													)
												AND CAST(AM.CreatedOn AS DATE) BETWEEN @FromDate
																	  AND
																	  @EndDate
									) AS AM
									GROUP BY CASE WHEN @QuestionTypeId = 7
												  THEN ( CASE AM.Detail
														   WHEN 'Yes' THEN 1
														   ELSE 2
														 END )
												  WHEN @QuestionTypeId = 14
													   OR @QuestionTypeId = 15
												  THEN ( CASE WHEN AM.Detail LIKE 'Yes,'
															  THEN 1
															  ELSE 2
														 END )
												  ELSE ISNULL(AM.Data, '')
											 END;
                    END;
                ELSE
                    BEGIN
                        INSERT  INTO @Result
                                ( OptionId ,
                                  Score ,
                                  Counts ,
                                  BenchmarkScore ,
                                  BenchmarkCounts
                                )
								SELECT Id, SUM(details) / T.TotalEntry AS Details,TotalEntry,A,B FROM (
                                SELECT  Q.Id ,
										SUM(CAST(A.Detail AS DECIMAL(18,2))) / MAX(A.RepeatCount) AS details ,
                                        @TotalEntry AS TotalEntry,
                                        0 AS 'A',
                                        0 AS 'B',
										A.SeenClientAnswerMasterId AS 'C'
                                FROM    dbo.View_SeenClientAnswerMaster AS AM
                                        INNER JOIN dbo.SeenClientAnswers AS A ON AM.ReportId = A.SeenClientAnswerMasterId
                                        INNER JOIN dbo.SeenClientQuestions AS Q ON Q.Id = A.QuestionId
                                        CROSS APPLY dbo.Split(ISNULL(OptionId,
                                                              ''), ',') AS O
                                        INNER JOIN ( SELECT Data
                                                     FROM   dbo.Split(@EstablishmentId,
                                                              ',')
                                                   ) AS RE ON ( RE.Data = AM.EstablishmentId
                                                              OR @EstablishmentId = '0'
                                                              )
                                        INNER JOIN ( SELECT Data
                                                     FROM   dbo.Split(@UserId,
                                                              ',')
                                                   ) AS RU ON RU.Data = AM.AppUserId
                                                              OR @UserId = '0'
                                        INNER JOIN ( SELECT Data
                                                     FROM   dbo.Split(@QuestionIdList,
                                                              ',')
                                                   ) AS RQ ON RQ.Data = A.QuestionId
                                                              OR Q.Id = @QuestionId
                                WHERE   AM.ActivityId = @ActivityId
                                        AND A.Detail IS NOT NULL
                                        AND A.Detail NOT LIKE '%[^0-9.]%'
                                        AND A.QuestionTypeId = 19
										AND ISNULL(AM.IsDisabled,0) = 0
                                        AND ( IsResolved = @AnsStatus
                                              OR @AnsStatus = ''
                                            )
                                        AND ( @TranferFilter = 0
                                              OR AM.IsTransferred = 1
                                            )
                                        AND ( @ActionFilter = 0
                                              OR AM.IsActioned = 1
                                            )
                                        AND CAST(AM.CreatedOn AS DATE) BETWEEN @FromDate
                                                              AND
                                                              @EndDate
                        GROUP BY Q.Id,A.SeenClientAnswerMasterId ) AS T GROUP BY T.id, T.A,T.B,TotalEntry;
                    END;
						/*BenchMark*/
                SELECT  @TotalEntry = COUNT(AM.ReportId)
                FROM    dbo.View_SeenClientAnswerMaster AS AM
                        INNER JOIN dbo.SeenClientAnswers AS A ON AM.ReportId = A.SeenClientAnswerMasterId
                        INNER JOIN dbo.SeenClientQuestions AS Q ON Q.Id = A.QuestionId
                        LEFT OUTER JOIN ( SELECT    Data
                                          FROM      dbo.Split(@EstablishmentId,
                                                              ',')
                                        ) AS RE ON ( RE.Data = AM.EstablishmentId
                                                     OR @EstablishmentId = '0'
                                                   )
                        LEFT OUTER JOIN ( SELECT    Data
                                          FROM      dbo.Split(@UserId, ',')
                                        ) AS RU ON RU.Data = AM.AppUserId
                                                   OR @UserId = '0'
                        INNER JOIN ( SELECT Data
                                     FROM   dbo.Split(@QuestionIdList, ',')
                                   ) AS RQ ON RQ.Data = A.QuestionId
                                              OR Q.Id = @QuestionId
                WHERE   AM.SeenClientId = @SeenClientId
				AND ISNULL(AM.IsDisabled,0) = 0
                        AND ( IsResolved = @AnsStatus
                              OR @AnsStatus = ''
                            )
                        AND ( @TranferFilter = 0
                              OR AM.IsTransferred = 1
                            )
                        AND ( @ActionFilter = 0
                              OR AM.IsActioned = 1
                            )
                        AND RE.Data IS NULL
                        AND RU.Data IS NULL
                        AND CAST(AM.CreatedOn AS DATE) BETWEEN @FromDate
                                                       AND    @EndDate;
                IF @QuestionTypeId <> 19
                    BEGIN
                        INSERT  INTO @Result
                                ( OptionId ,
                                  Score ,
                                  Counts ,
                                  BenchmarkScore ,
                                  BenchmarkCounts
                                )
                                SELECT  CASE WHEN @QuestionTypeId = 7
                                             THEN ( CASE A.Detail
                                                      WHEN 'Yes' THEN 1
                                                      ELSE 2
                                                    END )
                                             WHEN @QuestionTypeId = 14
                                                  OR @QuestionTypeId = 15
                                             THEN ( CASE WHEN A.Detail LIKE 'Yes,'
                                                         THEN 1
                                                         ELSE 2
                                                    END )
                                             ELSE ISNULL(O.Data, '')
                                        END ,
                                        0 ,
                                        0 ,
                                        COUNT(1) ,
                                        @TotalEntry
                                FROM    dbo.View_SeenClientAnswerMaster AS AM
                                        INNER JOIN dbo.SeenClientAnswers AS A ON AM.ReportId = A.SeenClientAnswerMasterId
                                        INNER JOIN dbo.SeenClientQuestions AS Q ON Q.Id = A.QuestionId
                                        CROSS APPLY dbo.Split(ISNULL(OptionId,
                                                              ''), ',') AS O
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
                                        INNER JOIN ( SELECT Data
                                                     FROM   dbo.Split(@QuestionIdList,
                                                              ',')
                                                   ) AS RQ ON RQ.Data = A.QuestionId
                                                              OR Q.Id = @QuestionId
                                WHERE   AM.ActivityId = @ActivityId
                                        AND O.Data IS NOT NULL
										AND ISNULL(AM.IsDisabled,0) = 0
                                        AND ( IsResolved = @AnsStatus
                                              OR @AnsStatus = ''
                                            )
                                        AND ( @TranferFilter = 0
                                              OR AM.IsTransferred = 1
                                            )
                                        AND ( @ActionFilter = 0
                                              OR AM.IsActioned = 1
                                            )
                                        AND RE.Data IS NULL
                                        AND RU.Data IS NULL
                                        AND CAST(AM.CreatedOn AS DATE) BETWEEN @FromDate
                                                              AND
                                                              @EndDate
                                GROUP BY CASE WHEN @QuestionTypeId = 7
                                              THEN ( CASE A.Detail
                                                       WHEN 'Yes' THEN 1
                                                       ELSE 2
                                                     END )
                                              WHEN @QuestionTypeId = 14
                                                   OR @QuestionTypeId = 15
                                              THEN ( CASE WHEN A.Detail LIKE 'Yes,'
                                                          THEN 1
                                                          ELSE 2
                                                     END )
                                              ELSE ISNULL(O.Data, '')
                                         END;
                    END;
                ELSE
                    BEGIN
                        INSERT  INTO @Result
                                ( OptionId ,
                                  Score ,
                                  Counts ,
                                  BenchmarkScore ,
                                  BenchmarkCounts
                                )
                                SELECT  Q.Id ,
                                        0 ,
                                        0 ,
                                        SUM(CAST(A.Detail AS DECIMAL(18,2))) ,
                                        @TotalEntry
                                FROM    dbo.View_SeenClientAnswerMaster AS AM
                                        INNER JOIN dbo.SeenClientAnswers AS A ON AM.ReportId = A.SeenClientAnswerMasterId
                                        INNER JOIN dbo.SeenClientQuestions AS Q ON Q.Id = A.QuestionId
                                        CROSS APPLY dbo.Split(ISNULL(OptionId,
                                                              ''), ',') AS O
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
                                        INNER JOIN ( SELECT Data
                                                     FROM   dbo.Split(@QuestionIdList,
                                                              ',')
                                                   ) AS RQ ON RQ.Data = A.QuestionId
                                                              OR Q.Id = @QuestionId
                                WHERE   AM.ActivityId = @ActivityId
                                        AND A.Detail IS NOT NULL
                                        AND A.Detail NOT LIKE '%[^0-9.]%'
                                        AND A.QuestionTypeId = 19
										AND ISNULL(AM.IsDisabled,0) = 0
                                        AND ( IsResolved = @AnsStatus
                                              OR @AnsStatus = ''
                                            )
                                        AND ( @TranferFilter = 0
                                              OR AM.IsTransferred = 1
                                            )
                                        AND ( @ActionFilter = 0
                                              OR AM.IsActioned = 1
                                            )
                                        AND RE.Data IS NULL
                                        AND RU.Data IS NULL
                                        AND CAST(AM.CreatedOn AS DATE) BETWEEN @FromDate
                                                              AND
                                                              @EndDate
                                GROUP BY Q.Id;
                    END;
            END;          

        SELECT  Tc.OptionId ,
                Tc.Name ,
                ISNULL(SUM(R.Score), 0) AS YourScore ,
                CASE WHEN @QuestionTypeId = 19
                     THEN ( CASE WHEN ISNULL(SUM(R.Score), 0)
                                      + ISNULL(SUM(R.BenchmarkScore), 0) > 0
                                 THEN ISNULL(SUM(R.Score), 0) * 100.00
                                      / ( ISNULL(SUM(R.Score), 0)
                                          + ISNULL(SUM(R.BenchmarkScore), 0) )
                                 ELSE 0
                            END )
                     WHEN @QuestionTypeId = 7
                          OR @QuestionTypeId = 14
                          OR @QuestionTypeId = 15
                     THEN ( CASE WHEN ISNULL(SUM(R.Score), 0)
                                      + ISNULL(SUM(R.BenchmarkScore), 0) > 0
                                 THEN ISNULL(SUM(R.Score), 0) * 100.00
                                      / ( ISNULL(SUM(R.Score), 0)
                                          + ISNULL(SUM(R.BenchmarkScore), 0) )
                                 ELSE 0
                            END )
                     ELSE CAST(ISNULL(SUM(R.Score), 0)
                          / CASE ISNULL(SUM(R.Counts), 0)
                              WHEN 0 THEN 1
                              ELSE ISNULL(SUM(R.Counts), 0)
                            END * 100.0 AS DECIMAL(18, 2))
                END AS YourPerformance ,
                ISNULL(SUM(R.BenchmarkScore), 0) AS BenchmarkScore ,
                CASE WHEN @QuestionTypeId = 19
                     THEN ( CASE WHEN ISNULL(SUM(R.Score), 0)
                                      + ISNULL(SUM(R.BenchmarkScore), 0) > 0
                                 THEN ISNULL(SUM(R.BenchmarkScore), 0)
                                      * 100.00 / ( ISNULL(SUM(R.Score), 0)
                                                   + ISNULL(SUM(R.BenchmarkScore),
                                                            0) )
                                 ELSE 0
                            END )
                     WHEN @QuestionTypeId = 7
                          OR @QuestionTypeId = 14
                          OR @QuestionTypeId = 15
                     THEN ( CASE WHEN ISNULL(SUM(R.Score), 0)
                                      + ISNULL(SUM(R.BenchmarkScore), 0) > 0
                                 THEN ISNULL(SUM(R.BenchmarkScore), 0)
                                      * 100.00 / ( ISNULL(SUM(R.Score), 0)
                                                   + ISNULL(SUM(R.BenchmarkScore),
                                                            0) )
                                 ELSE 0
                            END )
                     ELSE CAST(ISNULL(SUM(R.BenchmarkScore), 0)
                          / CASE ISNULL(SUM(R.BenchmarkCounts), 0)
                              WHEN 0 THEN 1
                              ELSE ISNULL(SUM(R.BenchmarkCounts), 0)
                            END * 100.0 AS DECIMAL(18, 2))
                END AS BenchmarkPerformance ,
                @LocalTime AS LastUpdatedTime ,
                @FromDate AS StartDate ,
                @EndDate AS EndDate ,
                ISNULL(@TodayEntry, 0) AS TotalEntry
        FROM    @tblCount AS Tc
                LEFT OUTER JOIN @Result AS R ON Tc.OptionId = R.OptionId
        GROUP BY Tc.OptionId 
		, Tc.Name
		ORDER BY Tc.OptionId;
    END;
