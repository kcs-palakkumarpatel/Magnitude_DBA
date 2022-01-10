-- =============================================
-- Author:			Sunil Vaghasiya
-- Create date:	04-July-2017
-- Description:	
-- Call SP:			dbo.spSnapshotGraph '2', 3, '17 Mar 2016', 1, '1,30022', 0,''
-- =============================================
CREATE PROCEDURE dbo.spSnapshotGraphV1_Backup
    @EstablishmentId NVARCHAR(MAX) ,
    @ActivityId BIGINT ,
    @FromDate DATETIME ,
    @Type INT ,
    @UserId NVARCHAR(MAX) ,
    @IsOut BIT ,
    @FilterOn NVARCHAR(50) ,
    @AppUserId BIGINT ,
    @AnswerMaster BIGINT = 0
AS
    BEGIN
        DECLARE @Tbl TABLE
            (
              Id BIGINT IDENTITY(1, 1) ,
              QId BIGINT NOT NULL ,
              ShortName NVARCHAR(1000) NOT NULL ,
              Escalation BIGINT NOT NULL ,
              Position INT
            );

        DECLARE @Result TABLE
            (
              Id BIGINT IDENTITY(1, 1) ,
              QId BIGINT NOT NULL ,
              Score DECIMAL(18, 2) NOT NULL ,
              Counts BIGINT NOT NULL ,
              [PI] DECIMAL(18, 2) NOT NULL ,
              BenchmarkScore DECIMAL(18, 2) NOT NULL ,
              BenchmarkCounts BIGINT NOT NULL ,
              BenchmarkPI DECIMAL(18, 2) NOT NULL,
			  TotalEntry int NOT NULL
            );

        DECLARE @FinalResult TABLE
            (
              StartDate DATETIME NOT NULL ,
              EndDate DATETIME NOT NULL ,
              LastUpdatedDate DATETIME NOT NULL ,
              ShortName NVARCHAR(1000) ,
              Counts INT ,
              Score DECIMAL(18, 2) ,
              PerformanceBanchMark DECIMAL(18, 2) ,
              YourScore DECIMAL(18, 2) ,
              BenchMarkScore DECIMAL(18, 2) ,
              PerformanceBenchMarkScore DECIMAL(18, 2) ,
              MinRank INT ,
              MaxRank INT ,
              GroupType INT,
			  TotalEntry int NOT NULL
            );


        DECLARE @listStr NVARCHAR(MAX);
        IF ( @EstablishmentId = '0' )
            BEGIN
                SET @EstablishmentId = ( SELECT dbo.AllEstablishmentByAppUserAndActivity(@AppUserId,
                                                              @ActivityId)
                                       );
            END;
        -- PRINT @EstablishmentId;
        
        DECLARE @CompareWithIndustry BIT = 1 ,
            @FixedBenchmark DECIMAL(18, 2)= 0;

        IF @UserId IS NULL
            BEGIN
                SET @UserId = '0';
            END;

        DECLARE @ActivityType NVARCHAR(50);
        SELECT  @ActivityType = EstablishmentGroupType
        FROM    dbo.EstablishmentGroup
        WHERE   Id = @ActivityId;
        IF ( @UserId = '0'
             AND @ActivityType != 'Customer'
           )
            BEGIN
                SET @UserId = ( SELECT  dbo.AllUserSelected(@AppUserId,
                                                            @EstablishmentId,
                                                            @ActivityId)
                              );
            END;
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
                        IF @FilterOn = 'OutStanding'
                            BEGIN
                                SET @IsOutStanding = 1;
                            END;

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
            @ToatlBenchMarkWaitage DECIMAL(18, 2);

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
        FROM    dbo.Establishment AS E
                INNER JOIN dbo.EstablishmentGroup AS Eg ON E.EstablishmentGroupId = Eg.Id
        WHERE   E.IsDeleted = 0
                AND Eg.Id = @ActivityId;

        SELECT  @LocalTime = DATEADD(MINUTE, @TimeOffSet, GETUTCDATE());

       ----  PRINT 'QuestionnaireId';
       ----  PRINT @QuestionnaireId;
       ----  PRINT 'SeenclientId';
       ----  PRINT @SeenClientId;

		/* Report Setting */
        IF @IsOut = 0
            BEGIN
                SELECT  @MinRank = MinRank ,
                        @MaxRank = CASE DisplayType
                                     WHEN 0 THEN MaxRank + 1
                                     ELSE 105
                                   END ,
                        @DisplayType = DisplayType
                FROM    ReportSetting
                WHERE   QuestionnaireId = @QuestionnaireId
                        AND ReportType = 'SnapShot';

                DECLARE @QuestionnaireFormType NVARCHAR(10);

                SELECT  @FixedBenchmark = FixedBenchMark ,
                        @CompareWithIndustry = CASE CompareType
                                                 WHEN 2 THEN 0
                                                 ELSE 1
                                               END ,
                        @QuestionnaireFormType = QuestionnaireFormType
                FROM    dbo.Questionnaire
                WHERE   CompareType = 2
                        AND Id = @QuestionnaireId; 						

                IF @QuestionnaireFormType <> 'Test'
                    SELECT  @QuestionIdList = COALESCE(@QuestionIdList + ',','')
                            + CONVERT(NVARCHAR(50), ISNULL(QuestionsID, ''))
                    FROM    ( SELECT    Questions.Id AS QuestionsID
                              FROM      Questionnaire
                                        INNER JOIN Questions ON Questionnaire.Id = Questions.QuestionnaireId
                              WHERE     ( Questionnaire.QuestionnaireType = 'EI' )
                                        AND ( Questions.QuestionTypeId IN ( 1,
                                                              5, 6, 7, 18, 21 ) )
                                        AND ( Questionnaire.Id = @QuestionnaireId )
                                        AND ( Questionnaire.IsDeleted = 0 )
                                        AND ( Questions.IsDeleted = 0 )
                                        AND ( Questions.DisplayInGraphs = 1 )
                            ) AS QueId;
                ELSE
                    SELECT  @QuestionIdList = COALESCE(@QuestionIdList + ',',
                                                       '')
                            + CONVERT(NVARCHAR(50), ISNULL(QuestionsID, ''))
                    FROM    ( SELECT    Questions.Id AS QuestionsID
                              FROM      Questionnaire
                                        INNER JOIN Questions ON Questionnaire.Id = Questions.QuestionnaireId
                              WHERE     ( Questionnaire.QuestionnaireType = 'EI' )
                                        AND ( Questions.QuestionTypeId IN ( 1,
                                                              5, 6,  --- (5,7,21)
                                                              7, 18, 21 ) )
                                        AND ( Questionnaire.Id = @QuestionnaireId )
                                        AND ( Questionnaire.IsDeleted = 0 )
                                        AND ( Questions.IsDeleted = 0 )
                                        AND ( Questions.DisplayInGraphs = 1 )
                            ) AS QueId;
            END;
        ELSE
            BEGIN
                SELECT  @MinRank = MinRank ,
                        @MaxRank = CASE DisplayType
                                     WHEN 0 THEN MaxRank + 1
                                     ELSE 105
                                   END ,
                        @DisplayType = DisplayType
                FROM    ReportSetting
                WHERE   SeenClientId = @SeenClientId
                        AND ReportType = 'SnapShot';

                SELECT  @FixedBenchmark = FixedBenchMark ,
                        @CompareWithIndustry = CASE CompareType
                                                 WHEN 2 THEN 0
                                                 ELSE 1
                                               END
                FROM    dbo.SeenClient
                WHERE   CompareType = 2
                        AND Id = @SeenClientId;

              
                SELECT  @QuestionIdList = COALESCE(@QuestionIdList + ',', '')
                        + CONVERT(NVARCHAR(50), ISNULL(QuestionsID, ''))
                FROM    ( SELECT    SeenClientQuestions.Id AS QuestionsID
                          FROM      dbo.SeenClient
                                    INNER JOIN dbo.SeenClientQuestions ON SeenClientQuestions.SeenClientId = SeenClient.Id
                          WHERE     ( SeenClientType = 'EI' )
                                    AND ( SeenClientQuestions.QuestionTypeId IN (
                                          1, 5, 6, 7, 18, 21 ) )
                                    AND ( SeenClient.Id = @SeenClientId )
                                    AND ( SeenClientQuestions.IsDeleted = 0 )
                                    AND ( SeenClientQuestions.DisplayInGraphs = 1 )
                        ) AS QueId; 
            END;
        
       ----  PRINT 'Question List';
       ----  PRINT @QuestionIdList;

		/*Time Period Calculation*/
        IF @Type = 1
            BEGIN
                IF CONVERT(DATE, @FromDate) >= CONVERT(DATE, @LocalTime)
                    BEGIN
                        SET @FromDate = CONVERT(DATE, @LocalTime);
                    END;
                SET @EndDate = @FromDate;
            END;
        ELSE
            IF @Type = 2
                BEGIN
                    SET @FromDate = CONVERT(DATE, DATEADD(wk,
                                                          DATEDIFF(wk, 7,
                                                              @FromDate), 6));
                    SET @EndDate = DATEADD(DAY, 6, @FromDate);
                    IF CONVERT(DATE, @EndDate) >= CONVERT(DATE, @LocalTime)
                        BEGIN                                      
                            SET @EndDate = @LocalTime;
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
                        END;
                    ELSE
                        IF @Type = 5
                            BEGIN
                            IF ( @IsOut = 0 )
                                BEGIN
                                    SELECT  @FromDate = CONVERT(DATE, CreatedOn)
                                    FROM    dbo.AnswerMaster
                                    WHERE   Id = @AnswerMaster;
                                END;
                            ELSE
                                BEGIN
                                    SELECT  @FromDate = CONVERT(DATE, CreatedOn)
                                    FROM    dbo.SeenClientAnswerMaster
                                    WHERE   Id = @AnswerMaster;
                                END;
                                --IF CONVERT(DATE, @FromDate) >= CONVERT(DATE, @LocalTime)
                                --    BEGIN
                                --        SET @FromDate = CONVERT(DATE, @LocalTime);
                                --    END;
                                SET @EndDate = @FromDate;
                            END;

        SET @FromDate = CONVERT(DATE, @FromDate);
        SET @EndDate = CONVERT(DATE, @EndDate);
        -- PRINT @FromDate;
        -- PRINT @EndDate;


        IF ( @IsOut = 1 )
            BEGIN
            ----    PRINT '1';
                SELECT  @ToatlWaitage = dbo.PICalculationForGraph_Snapshot(@ActivityId,
                                                              @FromDate,
                                                              @EndDate,
                                                              @SeenClientId,
                                                              @IsOut, @UserId,
                                                              @EstablishmentId,
            0, @AnswerMaster);
		----	PRINT '0';
                SELECT  @ToatlBenchMarkWaitage = dbo.PIBenchmarkCalculationForGraph(@ActivityId,
                                                              @FromDate,
                                                              @EndDate,
                                                              @SeenClientId,
                                                              @IsOut, @UserId,
                                                              @EstablishmentId,
                                                              0);
----	PRINT '2';
            END;
        ELSE
            BEGIN
                SELECT  @ToatlWaitage = dbo.PICalculationForGraph_Snapshot(@ActivityId,
                                                              @FromDate,
                                                              @EndDate,
                                                              @QuestionnaireId,
                                                              @IsOut, @UserId,
                                                              @EstablishmentId,
                                                              0, @AnswerMaster);
                SELECT  @ToatlBenchMarkWaitage = dbo.PIBenchmarkCalculationForGraph(@ActivityId,
                                                              @FromDate,
                                                              @EndDate,
                                                              @QuestionnaireId,
                                                              @IsOut, @UserId,
                                                              @EstablishmentId,
                                                              0);	

            END;

        DECLARE @QuestionCount BIGINT;
        DECLARE @YScore DECIMAL(18, 2) ,
            @YBScore DECIMAL(18, 2) ,
            @TotalEntry BIGINT;      

		/*Fetch Question List*/
        IF @IsOut = 0
            BEGIN
                INSERT  INTO @Tbl
				SELECT  Id ,
                                ShortName ,
                                Q.EscalationRegex ,
                                Q.Position
                        FROM    dbo.Questions AS Q
                                INNER JOIN ( SELECT Data FROM   dbo.Split(@QuestionIdList, ',') ) AS RQ ON Q.Id = RQ.Data 
                        WHERE   Q.IsDeleted = 0
                                AND Q.DisplayInGraphs = 1
                        ORDER BY Position;
            END;
        ELSE
            BEGIN
                INSERT  INTO @Tbl
                        SELECT  Id ,
                                ShortName ,
                                Q.EscalationRegex ,
                                Q.Position
                        FROM    dbo.SeenClientQuestions AS Q
                                INNER JOIN ( SELECT Data FROM   dbo.Split(@QuestionIdList, ',') ) AS RQ ON Q.Id = RQ.Data
                        WHERE   Q.IsDeleted = 0
                                AND Q.DisplayInGraphs = 1
                        ORDER BY Position;
            END;      
        SELECT  @QuestionCount = COUNT(1) FROM    @Tbl;

        IF @QuestionCount = 0
            BEGIN
                INSERT  INTO @Tbl
                        SELECT  1 ,
                                'NA' ,
                                0 ,
                                0;
            END;
        IF @DisplayType = 0 /*EI*/
            BEGIN
                IF @IsOut = 0 /*EI = Feedback*/
                    BEGIN               
                        IF ( @AnswerMaster != 0 )
                            BEGIN
                                INSERT  INTO @Result
                                        ( QId ,
                                          Score ,
                                          Counts ,
                                          [PI] ,
                                          BenchmarkScore ,
                                          BenchmarkCounts ,
                                          BenchmarkPI,
										  TotalEntry
                                        )
                                        SELECT  Q.Id ,
                                                SUM(A.QPI) * 1.0
                                                / CASE SUM(CASE ISNULL(A.Detail,'') WHEN '' THEN 0 ELSE 1 END)
                                                    WHEN 0 THEN 1
                                                    ELSE SUM(CASE ISNULL(A.Detail,'') WHEN '' THEN 0 ELSE 1 END)
                                                  END ,
                                                --COUNT(Am.ReportId) ,
												SUM(CASE ISNULL(A.Detail,'') WHEN '' THEN 0 ELSE 1 END),
                                                SUM(A.QPI) * 1.0
                                                / CASE COUNT(Am.ReportId)
                                                    WHEN 0 THEN 1
                                                    ELSE COUNT(Am.ReportId)
                                                  END ,
                                                0 ,
                                                0 ,
                                                0,
												COUNT(DISTINCT Am.ReportId)
                                        FROM    dbo.View_AnswerMaster AS Am
                                                INNER JOIN dbo.Answers AS A ON Am.ReportId = A.AnswerMasterId
                                                INNER JOIN dbo.Questions Q ON A.QuestionId = Q.Id
                                                              AND Q.DisplayInGraphs = 1
                                  INNER JOIN ( SELECT
                                                              Data
                                                             FROM
                                                              dbo.Split(@EstablishmentId,
                                                              ',')
                                                           ) AS RE ON ( RE.Data = Am.EstablishmentId
                                                              OR @EstablishmentId = '0'
                                                              )
                                                INNER JOIN ( SELECT
                                                              Data
                                                             FROM
                                                              dbo.Split(@QuestionIdList,
                                                              ',')
                                                           ) AS RQ ON ( RQ.Data = Q.Id
                                                              OR RQ.Data = 0
                                                              )
                                        --INNER JOIN ( SELECT Data
                                        --             FROM   dbo.Split(@UserId,
                                        --                      ',')
                                        --           ) AS RU ON (RU.Data = Am.AppUserId
                                        --                      OR @UserId = '0')
                                        WHERE   ActivityId = @ActivityId
												AND A.RepetitiveGroupId = 0
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
                                                AND Am.ReportId = @AnswerMaster
                                        GROUP BY Q.Id;

										/* For Group repetitive Item */

										INSERT  INTO @Result
                                        ( QId ,
                                          Score ,
                                          Counts ,
                                          [PI] ,
                                          BenchmarkScore ,
                                          BenchmarkCounts ,
                                          BenchmarkPI,
										  TotalEntry
                                        )
                                        SELECT  Id ,
                                                SUM(T.Detail) / CASE ISNULL(SUM(T.Counts),0) WHEN 0 THEN 1 ELSE SUM(T.Counts) END ,
                                                SUM(T.Counts) ,
                                                SUM(T.PI) ,
                                                SUM(T.Banchmarkcount) ,
                                                SUM(T.BankchmarkScore) ,
                                                SUM(T.BanckmarkPI),
												COUNT(T.ReportId)
                                        FROM    ( SELECT    Am.ReportId ,
                                                            Q.Id ,
                                                            SUM(A.QPI) * 1.0
                                                            / CASE CASE MAX(A.Detail)
                                                              WHEN '' THEN 0
                                                              ELSE 1
                                                              END
                                                              WHEN 0 THEN 1
                                                              ELSE CASE MAX(A.Detail)
                                                              WHEN '' THEN 0
                                                              ELSE 1
                                                              END
                                                              END AS Detail ,
                                                            CASE MAX(A.Detail)
                                                              WHEN '' THEN 0
                                                              ELSE 1
                                                            END AS [Counts] ,
                                                            SUM(A.QPI) * 1.0
                                                            / CASE COUNT(Am.ReportId)
                                                              WHEN 0 THEN 1
                                                              ELSE COUNT(Am.ReportId)
                                                              END AS [PI] ,
                                                            0 AS Banchmarkcount ,
                                                            0 AS BankchmarkScore ,
                                                            0 AS BanckmarkPI
                                                  FROM      dbo.View_AnswerMaster
                                                            AS Am
                                                            INNER JOIN dbo.Answers
                                                            AS A ON Am.ReportId = A.AnswerMasterId
                                                            INNER JOIN dbo.Questions Q ON A.QuestionId = Q.Id
                                                              AND Q.DisplayInGraphs = 1
                                                            INNER JOIN ( SELECT
                                                              Data
                                                              FROM
                                                              dbo.Split(@EstablishmentId,
                                                              ',')
                                                              ) AS RE ON ( RE.Data = Am.EstablishmentId
                                                              OR @EstablishmentId = '0'
                                                              )
                                                            INNER JOIN ( SELECT
                                                              Data
                                                              FROM
                                                              dbo.Split(@QuestionIdList,
                                                              ',')
                                                              ) AS RQ ON ( RQ.Data = Q.Id
                                                              OR RQ.Data = 0
                                                              )
                                                  WHERE     ActivityId = @ActivityId
															AND A.RepetitiveGroupId != 0
                                                            AND ISNULL(Am.IsDisabled,
                                                              0) = 0
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
                                                            AND Am.ReportId = @AnswerMaster
                                                  GROUP BY  Q.Id ,
                                                            Am.ReportId
                                                ) AS T
                                        GROUP BY T.Id;

										/* For Group repetitive Item */
                            END;
                        ELSE
                            BEGIN
                                INSERT  INTO @Result
                                        ( QId ,
                                          Score ,
                                          Counts ,
                                          [PI] ,
                                          BenchmarkScore ,
                                          BenchmarkCounts ,
                                          BenchmarkPI,
										  TotalEntry
                                  )
                                        SELECT  Q.Id ,
                                                SUM(A.QPI) * 1.0
                                                / CASE SUM(CASE ISNULL(A.Detail,'') WHEN '' THEN 0 ELSE 1 END)
                                                    WHEN 0 THEN 1
                                                    ELSE SUM(CASE ISNULL(A.Detail,'') WHEN '' THEN 0 ELSE 1 END)
                                                  END ,
                                                --COUNT(Am.ReportId) ,
												SUM(CASE ISNULL(A.Detail,'') WHEN '' THEN 0 ELSE 1 END),
                                                SUM(A.QPI) * 1.0
                                                / CASE SUM(CASE ISNULL(A.Detail,'') WHEN '' THEN 0 ELSE 1 END)
                                                    WHEN 0 THEN 1
                                                    ELSE SUM(CASE ISNULL(A.Detail,'') WHEN '' THEN 0 ELSE 1 END)
                                                  END ,
                                                0 ,
                                                0 ,
                                                0,
												COUNT(Am.ReportId)
                                        FROM    dbo.View_AnswerMaster AS Am
                                                INNER JOIN dbo.Answers AS A ON Am.ReportId = A.AnswerMasterId
                                                INNER JOIN dbo.Questions Q ON A.QuestionId = Q.Id
                                                              AND Q.DisplayInGraphs = 1
                                                INNER JOIN ( SELECT
                                                              Data
                                                             FROM
                                                              dbo.Split(@EstablishmentId,
                                                              ',')
                                                           ) AS RE ON ( RE.Data = Am.EstablishmentId
                                                              OR @EstablishmentId = '0'
                                                              )
                                                INNER JOIN ( SELECT
                                                              Data
                                                             FROM
                                                              dbo.Split(@QuestionIdList,
                                                              ',')
                                                           ) AS RQ ON RQ.Data = Q.Id
                                                INNER JOIN ( SELECT
                                                              Data
                                                             FROM
                                                              dbo.Split(@UserId,
                                                              ',')
                                                           ) AS RU ON RU.Data = Am.AppUserId
                                                              OR @UserId = '0'
                                        WHERE   ActivityId = @ActivityId
												AND A.RepetitiveGroupId = 0
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
                                                              @EndDate
															
                                        GROUP BY Q.Id;

								/* For Group repetitive Item */	
								---PRINT 'Done'
									INSERT  INTO @Result
                                        ( QId ,
                                          Score ,
                                          Counts ,
                                          [PI] ,
                                          BenchmarkScore ,
                                          BenchmarkCounts ,
                                          BenchmarkPI,
										  TotalEntry
                                  )
                                        SELECT  Id ,
                                                SUM(T.Detail) / CASE ISNULL(SUM(T.Counts),0) WHEN 0 THEN 1 ELSE SUM(T.Counts) END ,
                                                SUM(T.Counts) ,
                                                SUM(T.PI) ,
                                                SUM(T.Banchmarkcount) ,
                                                SUM(T.BankchmarkScore) ,
                                                SUM(T.BanckmarkPI),
												COUNT(T.ReportId)
                                        FROM    ( SELECT    Am.ReportId ,
                                                            Q.Id ,
                                                            SUM(A.QPI) * 1.0
                                                            / CASE CASE MAX(A.Detail)
                                                              WHEN '' THEN 0
                                                              ELSE 1
                                                              END
                                                              WHEN 0 THEN 1
                                                              ELSE CASE MAX(A.Detail)
                                                              WHEN '' THEN 0
                                                              ELSE 1
                                                              END
                                                              END AS Detail ,
                                                            CASE MAX(A.Detail)
                                                              WHEN '' THEN 0
                                                              ELSE 1
                                                            END AS [Counts] ,
                                                            SUM(A.QPI) * 1.0
                                                            / CASE COUNT(Am.ReportId)
                                                              WHEN 0 THEN 1
                                                              ELSE COUNT(Am.ReportId)
                                                              END AS [PI] ,
                                                            0 AS Banchmarkcount ,
                                                            0 AS BankchmarkScore ,
                                                            0 AS BanckmarkPI
                                        FROM    dbo.View_AnswerMaster AS Am
                                                INNER JOIN dbo.Answers AS A ON Am.ReportId = A.AnswerMasterId
                                                INNER JOIN dbo.Questions Q ON A.QuestionId = Q.Id
                                                              AND Q.DisplayInGraphs = 1
                                                INNER JOIN ( SELECT
                                                              Data
                                                             FROM
                                                              dbo.Split(@EstablishmentId,
                                                              ',')
                                                           ) AS RE ON ( RE.Data = Am.EstablishmentId
                                                              OR @EstablishmentId = '0'
                                                              )
                                                INNER JOIN ( SELECT
                                                              Data
                                                             FROM
                                                              dbo.Split(@QuestionIdList,
                                                              ',')
                                                           ) AS RQ ON RQ.Data = Q.Id
                                                INNER JOIN ( SELECT
                                                              Data
                                                             FROM
                                                              dbo.Split(@UserId,
                                                              ',')
                                                           ) AS RU ON RU.Data = Am.AppUserId
                                                              OR @UserId = '0'
                                        WHERE   ActivityId = @ActivityId
												AND A.RepetitiveGroupId != 0
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
                                                              @EndDate
                                            GROUP BY  Q.Id ,
                                                            Am.ReportId
                                                ) AS T
                                        GROUP BY T.Id;

							    /* For Group repetitive Item */

                            END;
                        IF @CompareWithIndustry = 1
                            BEGIN
                                 --PRINT 'innnn';
                                IF ( @AnswerMaster != 0 )
                                    BEGIN
                                        INSERT  INTO @Result
                                                ( QId ,
                                                  Score ,
                                                  Counts ,
                                                  [PI] ,
                                                  BenchmarkScore ,
                                                  BenchmarkCounts ,
                                                  BenchmarkPI,
												  TotalEntry
                                                )
                                                SELECT  Q.Id ,
                                                        0 ,
                                                        0 ,
                                                        0 ,
                                                        ( SUM(ISNULL(A.Weight,
                                                              0)) * 100 )
                                                        / CASE SUM(ISNULL(Q.MaxWeight,
                                                              0))
                                                            WHEN 0 THEN 1
                                                            ELSE SUM(Q.MaxWeight)
                                                          END ,
                                                --SUM(A.QPI) * 1.0
                                                --/ CASE COUNT(Am.ReportId)
                                                --    WHEN 0 THEN 1
                                                --    ELSE COUNT(Am.ReportId)
                                                --  END ,
                                                --SUM(A.QPI) * 1.0
                                                --/ CASE COUNT(Am.ReportId)
                                                --    WHEN 0 THEN 1
                                                --    ELSE COUNT(Am.ReportId)
                                                --  END ,
                                                        COUNT(Am.ReportId) ,
                                                        ( SUM(A.Weight) * 100 )
                                                        / CASE SUM(ISNULL(Q.MaxWeight,
                                                              0))
                                                            WHEN 0 THEN 1
                                                            ELSE SUM(Q.MaxWeight)
                                                          END,
														  0
                                                FROM    dbo.View_AnswerMaster
                                                        AS Am
                                                        INNER JOIN dbo.Answers
                                                        AS A ON Am.ReportId = A.AnswerMasterId
                                                        INNER JOIN dbo.Questions Q ON A.QuestionId = Q.Id
                                                              AND Q.DisplayInGraphs = 1
                                                        LEFT OUTER JOIN ( SELECT
                                                              Data
                                                              FROM
                                                              dbo.Split(@EstablishmentId,
                                                              ',')
                                                              ) AS RE ON ( RE.Data = Am.EstablishmentId
                                                              OR @EstablishmentId = '0'
                                                              )
                                                        INNER JOIN ( SELECT
                                                              Data
                                                              FROM
                                                              dbo.Split(@QuestionIdList,
                                                              ',')
                                                              ) AS RQ ON RQ.Data = Q.Id
                                                        --LEFT OUTER JOIN ( SELECT
                                                        --      Data
                                                        --      FROM
                                                        --      dbo.Split(@UserId,
                                                        --      ',')
                                                        --      ) AS RU ON RU.Data = Am.AppUserId
                                                        --      OR @UserId = '0'
                                                WHERE   Am.QuestionnaireId = @QuestionnaireId
														AND A.RepetitiveGroupId = 0
                                                        AND ISNULL(Am.IsDisabled,
                                                              0) = 0
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
                                               AND RE.Data IS NULL
                                                        --AND ( RU.Data IS NULL
                                                        --      OR ( RU.Data = 0
                                                        --      AND @IsTellUs = 0
                                                        --      )
                                                        --    )
                                                        AND Am.ReportId = @AnswerMaster
                                                GROUP BY Q.Id;
										
										 /* For Group repetitive Item */

										INSERT  INTO @Result
                                                ( QId ,
                                                  Score ,
                                                  Counts ,
                                                  [PI] ,
                                                  BenchmarkScore ,
                                                  BenchmarkCounts ,
                                                  BenchmarkPI,
												  TotalEntry
                                                )
                                                SELECT  T.Id ,
                                                0,
                                                0,
                                                0,
                                                SUM(T.Detail) / CASE ISNULL(SUM(T.Counts),0) WHEN 0 THEN 1 ELSE SUM(T.Counts) END,
                                                SUM(T.Counts),
                                                SUM(T.PI) ,
												COUNT(T.ReportId)
                                        FROM    ( SELECT    Am.ReportId ,
                                                            Q.Id ,
                                                            0 AS Score ,
                                                            0  AS Counts,
                                                            0 AS [PI],
															SUM(A.QPI) * 1.0
                                                            / CASE CASE MAX(A.Detail)
                                                              WHEN '' THEN 0
                                                              ELSE 1
                                                              END
                                                              WHEN 0 THEN 1
                                                              ELSE CASE MAX(A.Detail)
                                                              WHEN '' THEN 0
                                                              ELSE 1
                                                              END
                                                              END AS Detail ,
                                                            CASE MAX(A.Detail)
                                                              WHEN '' THEN 0
                                                              ELSE 1
                                                            END AS [BanchmarkCounts] ,
                                                            SUM(A.QPI) * 1.0
                                                            / CASE COUNT(Am.ReportId)
                                                              WHEN 0 THEN 1
                                                              ELSE COUNT(Am.ReportId)
                                                              END AS [BanchmarkPI] 
                                                FROM    dbo.View_AnswerMaster
                                                        AS Am
                                                        INNER JOIN dbo.Answers AS A ON Am.ReportId = A.AnswerMasterId
                                                        INNER JOIN dbo.Questions Q ON A.QuestionId = Q.Id
                                                              AND Q.DisplayInGraphs = 1
                                                        LEFT OUTER JOIN ( SELECT
                                                              Data
                                                              FROM
                                                              dbo.Split(@EstablishmentId,
                                                              ',')
                                                              ) AS RE ON ( RE.Data = Am.EstablishmentId
                                                              OR @EstablishmentId = '0'
                                                              )
                                                        INNER JOIN ( SELECT
                                                              Data
                                                              FROM
                                                              dbo.Split(@QuestionIdList,
                                                              ',')
                                                              ) AS RQ ON RQ.Data = Q.Id
                                                        --LEFT OUTER JOIN ( SELECT
                                                        --      Data
                                                        --      FROM
                                                        --      dbo.Split(@UserId,
                                                        --      ',')
                                                        --      ) AS RU ON RU.Data = Am.AppUserId
                                                        --      OR @UserId = '0'
                                                WHERE   Am.QuestionnaireId = @QuestionnaireId
														AND A.RepetitiveGroupId != 0
                                                        AND ISNULL(Am.IsDisabled,
                                                              0) = 0
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
                                               AND RE.Data IS NULL
                                                        --AND ( RU.Data IS NULL
                                                        --      OR ( RU.Data = 0
                                                        --      AND @IsTellUs = 0
                                                        --      )
                                                        --    )
                                                        AND Am.ReportId = @AnswerMaster
                                                 GROUP BY  Q.Id ,
                                                            Am.ReportId
                                                ) AS T
                                        GROUP BY T.Id;
										
										 /* For Group repetitive Item */

                                    END;
                                ELSE
                                    BEGIN
                                        INSERT  INTO @Result
                                                ( QId ,
                                                  Score ,
                                                  Counts ,
                                                  [PI] ,
                                                  BenchmarkScore ,
                                                  BenchmarkCounts ,
                                                  BenchmarkPI,
												  TotalEntry
                                                )
                                                SELECT  Q.Id ,
                                                        0 ,
                                                        0 ,
                                                        0 ,
                                                        ( SUM(ISNULL(A.Weight,
                                                              0)) * 100 )
                                                        / CASE SUM(ISNULL(Q.MaxWeight,
                                                              0))
                                                            WHEN 0 THEN 1
                                                            ELSE SUM(Q.MaxWeight)
                                                          END ,
                                                --SUM(A.QPI) * 1.0
                                                --/ CASE COUNT(Am.ReportId)
                                                --    WHEN 0 THEN 1
                                                --    ELSE COUNT(Am.ReportId)
                                                --  END ,
                                                --SUM(A.QPI) * 1.0
                                                --/ CASE COUNT(Am.ReportId)
                                                --    WHEN 0 THEN 1
                                                --    ELSE COUNT(Am.ReportId)
                                                --  END ,
                                                        COUNT(Am.ReportId) ,
                                                        ( SUM(A.Weight) * 100 )
                                                        / CASE SUM(ISNULL(Q.MaxWeight,
                                                              0))
                                                            WHEN 0 THEN 1
                                                            ELSE SUM(Q.MaxWeight)
                                                          END,
														  0
                                                FROM    dbo.View_AnswerMaster
                                                        AS Am
                                                        INNER JOIN dbo.Answers
                                                        AS A ON Am.ReportId = A.AnswerMasterId
                                                        INNER JOIN dbo.Questions Q ON A.QuestionId = Q.Id
                                                              AND Q.DisplayInGraphs = 1
                                                        LEFT OUTER JOIN ( SELECT
                                                              Data
              FROM
                                                              dbo.Split(@EstablishmentId,
                                                              ',')
                                                              ) AS RE ON ( RE.Data = Am.EstablishmentId
                                                              OR @EstablishmentId = '0'
                                                              )
                                                        INNER JOIN ( SELECT
                                                              Data
                                                              FROM
                                                              dbo.Split(@QuestionIdList,
                                                              ',')
                                                              ) AS RQ ON RQ.Data = Q.Id
                                                        LEFT OUTER JOIN ( SELECT
                                                              Data
                                                              FROM
                                                              dbo.Split(@UserId,
                                                              ',')
                                                              ) AS RU ON RU.Data = Am.AppUserId
                                                              OR @UserId = '0'
                                                WHERE   Am.QuestionnaireId = @QuestionnaireId
														AND a.RepetitiveGroupId = 0
                                                        AND ISNULL(Am.IsDisabled,
                                                              0) = 0
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
                                                        AND RE.Data IS NULL
                                                        AND ( RU.Data IS NULL
                                                              OR ( RU.Data = 0
                                                              AND @IsTellUs = 0
                                                              )
                                                            )
                                                        AND CAST(Am.CreatedOn AS DATE) BETWEEN @FromDate
                AND
                                                              @EndDate
                                                GROUP BY Q.Id;

												 /* For Group repetitive Item */
													INSERT  INTO @Result
                                                ( QId ,
                                                  Score ,
                                                  Counts ,
                                                  [PI] ,
                                                  BenchmarkScore ,
                                                  BenchmarkCounts ,
                                                  BenchmarkPI,
												  TotalEntry
                                                )
                                                 SELECT  Id ,
                                                0,
                                                0,
                                                0,
                                                SUM(T.Detail) / SUM(T.Banchmarkcounts),
                                                SUM(T.Banchmarkcounts),
                                                SUM(T.BanckmarkPI) ,
												COUNT(T.ReportId)
                                        FROM    ( SELECT    Am.ReportId ,
                                                            Q.Id ,
                                                            0 AS Score ,
                                                            0 AS Counts ,
                                                            0 AS [PI],
															SUM(A.QPI) * 1.0
                                                            / CASE CASE MAX(A.Detail)
                                                              WHEN '' THEN 0
                                                              ELSE 1
                                                              END
                                                              WHEN 0 THEN 1
                                                              ELSE CASE MAX(A.Detail)
                                                              WHEN '' THEN 0
                                                              ELSE 1
                                                              END
                                                              END AS Detail,
                                                            CASE MAX(A.Detail)
                                                              WHEN '' THEN 0
                                                              ELSE 1
                                                            END AS [Banchmarkcounts] ,
                                                            SUM(A.QPI) * 1.0
                                                            / CASE COUNT(Am.ReportId)
                                                              WHEN 0 THEN 1
                                                              ELSE COUNT(Am.ReportId)
                                                              END AS [BanckmarkPI] 
                                                FROM    dbo.View_AnswerMaster
                                                        AS Am
                                                        INNER JOIN dbo.Answers
                                                        AS A ON Am.ReportId = A.AnswerMasterId
                                                        INNER JOIN dbo.Questions Q ON A.QuestionId = Q.Id
                                                              AND Q.DisplayInGraphs = 1
                                                        LEFT OUTER JOIN ( SELECT
                                                              Data
              FROM
                                                              dbo.Split(@EstablishmentId,
                                                              ',')
                                                              ) AS RE ON ( RE.Data = Am.EstablishmentId
                                                              OR @EstablishmentId = '0'
                                                              )
                                                        INNER JOIN ( SELECT
                                                              Data
                                                              FROM
                                                              dbo.Split(@QuestionIdList,
                                                              ',')
                                                              ) AS RQ ON RQ.Data = Q.Id
                                                        LEFT OUTER JOIN ( SELECT
                                                              Data
                                                              FROM
                                                              dbo.Split(@UserId,
                                                              ',')
                                                              ) AS RU ON RU.Data = Am.AppUserId
                                                              OR @UserId = '0'
                                                WHERE   Am.QuestionnaireId = @QuestionnaireId
														AND a.RepetitiveGroupId != 0
                                                        AND ISNULL(Am.IsDisabled,
                                                              0) = 0
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
                                                        AND RE.Data IS NULL
                                                        AND ( RU.Data IS NULL
                                                              OR ( RU.Data = 0
                                                              AND @IsTellUs = 0
                                                              )
                                                            )
                                                        AND CAST(Am.CreatedOn AS DATE) BETWEEN @FromDate
                AND
                                                              @EndDate
                                                 GROUP BY  Q.Id ,
                                                            Am.ReportId
                                                ) AS T
                                        GROUP BY T.Id;
												 /* For Group repetitive Item */
                                    END;
                            END;
                        ELSE
                            BEGIN
                                INSERT  INTO @Result
                                        ( QId ,
                                          Score ,
                                          Counts ,
                                          [PI] ,
                                          BenchmarkScore ,
                                          BenchmarkCounts ,
                                          BenchmarkPI,
										  TotalEntry
                                        )
                                        SELECT  Id ,
                                                0 ,
                                                0 ,
                                                0 ,
                                                @FixedBenchmark ,
                                                1 ,
                                                @FixedBenchmark,
												0
                                        FROM    @Tbl;
                            END;
                    END;
                ELSE /*EI =  SeenClient*/
                    BEGIN
					----PRINT '========++++++'
					----PRINT @QuestionIdList
					IF(@AnswerMaster != 0)
					BEGIN
					 INSERT  INTO @Result
                                ( QId ,
                                  Score ,
                                  Counts ,
                                  [PI] ,
                                  BenchmarkScore ,
                                  BenchmarkCounts ,
                                  BenchmarkPI,
								  TotalEntry
                                )
                                SELECT  Q.Id ,
                                        SUM(A.QPI) * 1.0
                                        / CASE SUM(CASE ISNULL(A.Detail,'') WHEN '' THEN 0 ELSE 1 END)
                                            WHEN 0 THEN 1
                                            ELSE SUM(CASE ISNULL(A.Detail,'') WHEN '' THEN 0 ELSE 1 END)
                                          END ,
										  SUM(CASE ISNULL(A.Detail,'') WHEN '' THEN 0 ELSE 1 END),
                                        --COUNT(Am.ReportId) ,
                                        SUM(A.QPI) * 1.0
                                        / CASE COUNT(Am.ReportId)
                                            WHEN 0 THEN 1
                                            ELSE COUNT(Am.ReportId)
                                          END ,
                                        0 ,
                                        0 ,
                                        0,
										COUNT(Am.ReportId)
                                FROM    dbo.View_SeenClientAnswerMaster AS Am
                                        INNER JOIN dbo.SeenClientAnswers AS A ON Am.ReportId = A.SeenClientAnswerMasterId
                                        INNER JOIN dbo.SeenClientQuestions Q ON A.QuestionId = Q.Id
                                                              AND Q.DisplayInGraphs = 1
                                        INNER JOIN ( SELECT Data
                                                     FROM   dbo.Split(@EstablishmentId,
                                                              ',')
                                                   ) AS RE ON ( RE.Data = Am.EstablishmentId
                                                              OR @EstablishmentId = '0'
                                                              )
                                        INNER JOIN ( SELECT Data
                                                     FROM   dbo.Split(@QuestionIdList,
                                                              ',')
                                                   ) AS RQ ON RQ.Data = Q.Id
                                        --INNER JOIN ( SELECT Data
                                        --  FROM   dbo.Split(@UserId,
                                        --                      ',')
                                        --           ) AS RU ON RU.Data = Am.AppUserId
                                        --                      OR @UserId = '0'
                                WHERE   ActivityId = @ActivityId
										AND A.RepetitiveGroupId = 0
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
                                                              @EndDate
															       AND Am.ReportId = @AnswerMaster
                                GROUP BY Q.Id;

								/* For Gropu Repetitive Item */

								INSERT  INTO @Result
                                ( QId ,
                                  Score ,
                                  Counts ,
                                  [PI] ,
                                  BenchmarkScore ,
                                  BenchmarkCounts ,
                                  BenchmarkPI,
								  TotalEntry
                                )
                                SELECT id,AVG(T.Detail),SUM(T.Counts),AVG(T.PI),0,0,0,COUNT(DISTINCT T.ReportId) FROM ( SELECT  Q.Id ,
										(AVG(A.Weight) * 100 ) / AVG(Q.MaxWeight) AS Detail,
                                        SUM(CASE ISNULL(A.Detail,'') WHEN '' THEN 0 ELSE 1 END) AS Counts ,
                                        SUM(A.QPI) * 1.0
                                        / CASE COUNT(Am.ReportId)
                                            WHEN 0 THEN 1
                                            ELSE COUNT(Am.ReportId)
                                          END AS [PI],
                                        0 AS BenchmarkScore,
                                        0 AS BenchmarkCounts,
                                        0 AS BenchmarkPI,
										--COUNT(Am.ReportId) AS TotalEntry,
										Am.ReportId
                                FROM    dbo.View_SeenClientAnswerMaster AS Am
                                        INNER JOIN dbo.SeenClientAnswers AS A ON Am.ReportId = A.SeenClientAnswerMasterId
                                        INNER JOIN dbo.SeenClientQuestions Q ON A.QuestionId = Q.Id
                                                              AND Q.DisplayInGraphs = 1
                                        INNER JOIN ( SELECT Data
                                                     FROM   dbo.Split(@EstablishmentId,
                                                       ',')
                                                   ) AS RE ON ( RE.Data = Am.EstablishmentId
                                                              OR @EstablishmentId = '0'
                                                              )
                                        INNER JOIN ( SELECT Data
                                                     FROM   dbo.Split(@QuestionIdList,
                                                              ',')
                                                   ) AS RQ ON RQ.Data = Q.Id
                                        INNER JOIN ( SELECT Data
                                                     FROM   dbo.Split(@UserId,
                                                              ',')
                                                   ) AS RU ON RU.Data = Am.AppUserId
                                                              OR @UserId = '0'
                                WHERE   ActivityId = @ActivityId
										AND A.RepetitiveGroupId != 0
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
                                                              @EndDate
															       AND Am.ReportId = @AnswerMaster
                                GROUP BY Q.Id,Am.ReportId) AS T GROUP BY T.Id

								/* For Gropu Repetitive Item */
					END
                    ELSE
					BEGIN
					PRINT 'Done'
                        INSERT  INTO @Result
                                ( QId ,
                                  Score ,
                                  Counts ,
                                  [PI] ,
                                  BenchmarkScore ,
                                  BenchmarkCounts ,
                                  BenchmarkPI,
								  TotalEntry
                                )
                                SELECT  Q.Id ,
										--(AVG(A.Weight) * 100 ) / AVG(Q.MaxWeight) AS Detail,
                                        SUM(A.QPI) * 1.0
                                        / CASE SUM(CASE ISNULL(A.Detail,'') WHEN '' THEN 0 ELSE 1 END)
                                            WHEN 0 THEN 1
                                            ELSE SUM(CASE ISNULL(A.Detail,'') WHEN '' THEN 0 ELSE 1 END)
                                          END ,
										SUM(CASE ISNULL(A.Detail,'') WHEN '' THEN 0 ELSE 1 END),
                                        --COUNT(Am.ReportId) ,
                                        SUM(A.QPI) * 1.0
                                        / CASE SUM(CASE ISNULL(A.Detail,'') WHEN '' THEN 0 ELSE 1 END)
                                            WHEN 0 THEN 1
                                            ELSE SUM(CASE ISNULL(A.Detail,'') WHEN '' THEN 0 ELSE 1 END)
                                          END ,
                                        0 ,
                                        0 ,
                                        0,
										COUNT(Am.ReportId)
                                FROM    dbo.View_SeenClientAnswerMaster AS Am
                                        INNER JOIN dbo.SeenClientAnswers AS A ON Am.ReportId = A.SeenClientAnswerMasterId
                                        INNER JOIN dbo.SeenClientQuestions Q ON A.QuestionId = Q.Id
                                                              AND Q.DisplayInGraphs = 1
                                        INNER JOIN ( SELECT Data
                                                     FROM   dbo.Split(@EstablishmentId,
                                                       ',')
                                                   ) AS RE ON ( RE.Data = Am.EstablishmentId
                                                              OR @EstablishmentId = '0'
                                                              )
                                        INNER JOIN ( SELECT Data
                                                     FROM   dbo.Split(@QuestionIdList,
                                                              ',')
                                                   ) AS RQ ON RQ.Data = Q.Id
                                        INNER JOIN ( SELECT Data
                                                     FROM   dbo.Split(@UserId,
                                                              ',')
                                                   ) AS RU ON RU.Data = Am.AppUserId
                                                              OR @UserId = '0'
                                WHERE   ActivityId = @ActivityId
										AND A.RepetitiveGroupId = 0
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
                                                              @EndDate
                                GROUP BY Q.Id;

								/* For Gropu Repetitive Item */

								INSERT  INTO @Result
                                ( QId ,
                                  Score ,
                                  Counts ,
                                  [PI] ,
                                  BenchmarkScore ,
                                  BenchmarkCounts ,
                                  BenchmarkPI,
								  TotalEntry
                                )
                                SELECT id,SUM(T.PI) / CASE ISNULL(SUM(T.Counts),0) WHEN 0 THEN 1 ELSE SUM(T.Counts) END,
								SUM(T.Counts),
								SUM(T.PI)
								,0
								,0
								,0
								,COUNT(DISTINCT T.ReportId) 
								FROM ( SELECT  Q.Id ,
										SUM(A.QPI) * 1.0 / CASE CASE MAX(A.Detail) WHEN '' THEN 0 ELSE 1 END
                                            WHEN 0 THEN 1
                                            ELSE CASE MAX(A.Detail) WHEN '' THEN 0 ELSE 1 END
                                          END AS Detail,
                                     	CASE MAX(A.Detail) WHEN '' THEN 0 ELSE 1 END AS [Counts],
                                        SUM(A.QPI) * 1.0
                                        / CASE COUNT(Am.ReportId)
                                            WHEN 0 THEN 1
                                            ELSE COUNT(Am.ReportId)
                                          END AS [PI],
                                        0 AS BenchmarkScore,
                                        0 AS BenchmarkCounts,
                                        0 AS BenchmarkPI,
										--COUNT(Am.ReportId) AS TotalEntry,
										Am.ReportId
                                FROM    dbo.View_SeenClientAnswerMaster AS Am
                                        INNER JOIN dbo.SeenClientAnswers AS A ON Am.ReportId = A.SeenClientAnswerMasterId
                                        INNER JOIN dbo.SeenClientQuestions Q ON A.QuestionId = Q.Id
                                                              AND Q.DisplayInGraphs = 1
                                        INNER JOIN ( SELECT Data
                                                     FROM   dbo.Split(@EstablishmentId,
                                                       ',')
                                                   ) AS RE ON ( RE.Data = Am.EstablishmentId
                                                              OR @EstablishmentId = '0'
                                                              )
                                        INNER JOIN ( SELECT Data
                                                     FROM   dbo.Split(@QuestionIdList,
                                                              ',')
                                                   ) AS RQ ON RQ.Data = Q.Id
                                        INNER JOIN ( SELECT Data
                                                     FROM   dbo.Split(@UserId,
                                                              ',')
                                                   ) AS RU ON RU.Data = Am.AppUserId
                                                              OR @UserId = '0'
                                WHERE   ActivityId = @ActivityId
										AND A.RepetitiveGroupId != 0
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
                                                              @EndDate
                                GROUP BY Q.Id,Am.ReportId) AS T GROUP BY T.Id

								/* For Gropu Repetitive Item */
 END
 
                        IF @CompareWithIndustry = 1
                           BEGIN
                                -- PRINT '++++++++++++++++';
								IF(@AnswerMaster != 0)
								BEGIN
                                INSERT  INTO @Result
                                        ( QId ,
                                          Score ,
                                          Counts ,
                                          [PI] ,
                                          BenchmarkScore ,
                                          BenchmarkCounts ,
                                          BenchmarkPI,
										  TotalEntry
                                        )
                                        SELECT  Q.Id ,
                                                0 ,
                                                0 ,
                                                0 ,
                                                ( SUM(A.Weight) * 100 )
                                                / CASE SUM(ISNULL(Q.MaxWeight,
                                                              0))
                                                    WHEN 0 THEN 1
                                                 ELSE SUM(Q.MaxWeight)
                                                  END ,
                                                --SUM(A.QPI) * 1.0
                                                --/ CASE COUNT(Am.ReportId)
                                                --    WHEN 0 THEN 1
                                                --    ELSE COUNT(Am.ReportId)
                                                --  END ,
                                                COUNT(Am.ReportId) ,
                                                ( SUM(A.Weight) * 100 )
                                                / CASE SUM(ISNULL(Q.MaxWeight,
                                                              0))
                                                    WHEN 0 THEN 1
                                                    ELSE SUM(Q.MaxWeight)
                                                  END,
												  0
                                                --SUM(A.QPI) * 1.0
                                                --/ CASE COUNT(Am.ReportId)
                                                --    WHEN 0 THEN 1
                                                --    ELSE COUNT(Am.ReportId)
                                                --  END
                                        FROM    dbo.View_SeenClientAnswerMaster
                                                AS Am
                                                INNER JOIN dbo.SeenClientAnswers
                                                AS A ON Am.ReportId = A.SeenClientAnswerMasterId
                                                INNER JOIN dbo.SeenClientQuestions Q ON A.QuestionId = Q.Id
                                                              AND Q.DisplayInGraphs = 1
                                                LEFT OUTER JOIN ( SELECT
                                                              Data
                                                              FROM
                                                              dbo.Split(@EstablishmentId,
                                                              ',')
                                                              ) AS RE ON ( RE.Data = Am.EstablishmentId
                                                              OR @EstablishmentId = '0'
                                                              )
                                                INNER JOIN ( SELECT
                                                              Data
                                                             FROM
                                                              dbo.Split(@QuestionIdList,
                                                              ',')
                                                           ) AS RQ ON RQ.Data = Q.Id
                                                --LEFT OUTER JOIN ( SELECT
                                                --              Data
                                                --              FROM
                                                --              dbo.Split(@UserId,
                                                --              ',')
                                                --              ) AS RU ON RU.Data = Am.AppUserId
                                                --              OR @UserId = '0'
                                        WHERE   Am.SeenClientId = @SeenClientId
												AND a.RepetitiveGroupId = 0
                                                AND Am.ActivityId = @ActivityId
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
                                                AND RE.Data IS NOT NULL
                                                AND Am.AppUserId NOT IN (
                                                SELECT  Data
                                                FROM    dbo.Split(@UserId, ',') )
                                                AND CAST(Am.CreatedOn AS DATE) BETWEEN @FromDate
                                                              AND
                                                              @EndDate
															  AND Am.ReportId = @AnswerMaster
                                        GROUP BY Q.Id;

										/* For Gropu Repetitive Item */
									INSERT  INTO @Result
                                        ( QId ,
                                          Score ,
                                          Counts ,
                                          [PI] ,
                                          BenchmarkScore ,
                                          BenchmarkCounts ,
                                          BenchmarkPI,
										  TotalEntry
                                        )
                                           SELECT  Id ,
                                                0,
                                                0,
                                                0,
                                                SUM(T.Detail) / CASE ISNULL(SUM(T.Counts),0) WHEN 0 THEN 1 ELSE SUM(T.Counts) END,
                                                SUM(T.Counts),
                                                SUM(T.PI) ,
												COUNT(T.ReportId)
                                        FROM    ( SELECT    Am.ReportId ,
                                                            Q.Id ,
                                                            0 AS Score ,
                                                            0 AS BankchmarkScore ,
                                                            0 AS BanckmarkPI,
															SUM(A.QPI) * 1.0
                                                            / CASE CASE MAX(A.Detail)
                                                              WHEN '' THEN 0
                                                              ELSE 1
                                                              END
                                                              WHEN 0 THEN 1
                                                              ELSE CASE MAX(A.Detail)
                                                              WHEN '' THEN 0
                                                              ELSE 1
                                                              END
                                                              END AS Detail,
                                                            CASE MAX(A.Detail)
                                                              WHEN '' THEN 0
                                                              ELSE 1
                                                            END AS [Counts] ,
                                                            SUM(A.QPI) * 1.0
                                                            / CASE COUNT(Am.ReportId)
                                                              WHEN 0 THEN 1
                                                              ELSE COUNT(Am.ReportId)
                                                              END AS [PI] 
                                        FROM    dbo.View_SeenClientAnswerMaster
                                                AS Am
                                                INNER JOIN dbo.SeenClientAnswers
                                                AS A ON Am.ReportId = A.SeenClientAnswerMasterId
                                                INNER JOIN dbo.SeenClientQuestions Q ON A.QuestionId = Q.Id
                                                              AND Q.DisplayInGraphs = 1
                                                LEFT OUTER JOIN ( SELECT
                                                              Data
                                                              FROM
                                                              dbo.Split(@EstablishmentId,
                                                              ',')
                                                              ) AS RE ON ( RE.Data = Am.EstablishmentId
                                                              OR @EstablishmentId = '0'
                                                              )
                                                INNER JOIN ( SELECT
                                                              Data
                                                             FROM
                                                              dbo.Split(@QuestionIdList,
                                                              ',')
                                                           ) AS RQ ON RQ.Data = Q.Id
                                                --LEFT OUTER JOIN ( SELECT
                                                --              Data
                                                --              FROM
                                                --              dbo.Split(@UserId,
                                                --              ',')
                                                --              ) AS RU ON RU.Data = Am.AppUserId
                                                --              OR @UserId = '0'
                                        WHERE   Am.SeenClientId = @SeenClientId
												AND A.RepetitiveGroupId = 0
												AND a.RepetitiveGroupId != 0
                                                AND Am.ActivityId = @ActivityId
                                                AND ISNULL(Am.IsDisabled, 0) = 0
                                                AND ( IsResolved = @AnsStatus
                                                      OR @AnsStatus = ''
                                                    )
                                                AND ( @TranferFilter = 0
													OR Am.IsTransferred = 1)
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
                                                AND RE.Data IS NOT NULL
                                                AND Am.AppUserId NOT IN (
                                                SELECT  Data
                                                FROM    dbo.Split(@UserId, ',') )
                                                AND CAST(Am.CreatedOn AS DATE) BETWEEN @FromDate
                                                              AND
                                                              @EndDate
															  AND Am.ReportId = @AnswerMaster
                                          GROUP BY  Q.Id ,
                                                            Am.ReportId
                                                ) AS T
                                        GROUP BY T.Id;
										/* For Gropu Repetitive Item */
										END
								ELSE
                                BEGIN
										  INSERT  INTO @Result
                                        ( QId ,
                                          Score ,
                                          Counts ,
                                          [PI] ,
                                          BenchmarkScore ,
                                          BenchmarkCounts ,
                                          BenchmarkPI,
										  TotalEntry
                                        )
                                        SELECT  Q.Id ,
                                                0 ,
                                                0 ,
                                                0 ,
                                                ( SUM(A.Weight) * 100 )
                                                / CASE SUM(ISNULL(Q.MaxWeight,
                                                              0))
                                                    WHEN 0 THEN 1
                                                    ELSE SUM(Q.MaxWeight)
                                                  END ,
                                                --SUM(A.QPI) * 1.0
                                                --/ CASE COUNT(Am.ReportId)
                                                --    WHEN 0 THEN 1
                                                --    ELSE COUNT(Am.ReportId)
                                                --  END ,
                                                COUNT(Am.ReportId) ,
                                                ( SUM(A.Weight) * 100 )
                                                / CASE SUM(ISNULL(Q.MaxWeight,
                                                              0))
                                                    WHEN 0 THEN 1
                                                    ELSE SUM(Q.MaxWeight)
                                                  END,
												  0
                                                --SUM(A.QPI) * 1.0
                                         --/ CASE COUNT(Am.ReportId)
                                                --    WHEN 0 THEN 1
                                                --    ELSE COUNT(Am.ReportId)
                                                --  END
                                        FROM    dbo.View_SeenClientAnswerMaster
                                                AS Am
                                                INNER JOIN dbo.SeenClientAnswers
                                                AS A ON Am.ReportId = A.SeenClientAnswerMasterId
                                                INNER JOIN dbo.SeenClientQuestions Q ON A.QuestionId = Q.Id
                                                              AND Q.DisplayInGraphs = 1
                                                LEFT OUTER JOIN ( SELECT
                                                              Data
                                                              FROM
                                                              dbo.Split(@EstablishmentId,
                                                              ',')
                                                              ) AS RE ON ( RE.Data = Am.EstablishmentId
                                                              OR @EstablishmentId = '0'
                                                              )
                                                INNER JOIN ( SELECT
                                                              Data
                                                             FROM
                                                              dbo.Split(@QuestionIdList,
                                                              ',')
                                                           ) AS RQ ON RQ.Data = Q.Id
                                                --LEFT OUTER JOIN ( SELECT
                                                --              Data
                                                --              FROM
                                                --              dbo.Split(@UserId,
                                                --              ',')
                                                --              ) AS RU ON RU.Data = Am.AppUserId
                                                --              OR @UserId = '0'
                                        WHERE   Am.SeenClientId = @SeenClientId
												AND a.RepetitiveGroupId = 0
                                                AND Am.ActivityId = @ActivityId
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
                                                AND RE.Data IS NOT NULL
                                                AND Am.AppUserId NOT IN (
                                                SELECT  Data
                                                FROM    dbo.Split(@UserId, ',') )
                                                AND CAST(Am.CreatedOn AS DATE) BETWEEN @FromDate
                                                              AND
                                                              @EndDate
                                        GROUP BY Q.Id;
									
									/* For Gropu Repetitive Item */					

									INSERT  INTO @Result
                                        ( QId ,
                                          Score ,
                                          Counts ,
                                          [PI] ,
                                          BenchmarkScore ,
                                          BenchmarkCounts ,
                                          BenchmarkPI,
										  TotalEntry
                                        )
                                     SELECT  Id ,
                                                0,
                                                0,
                                                0,
                                                SUM(T.Detail) / CASE ISNULL(SUM(T.Counts),0) WHEN 0 THEN 1 ELSE SUM(T.Counts) END,
                                                SUM(T.Counts),
                                                SUM(T.PI) ,
												COUNT(T.ReportId)
                                        FROM    ( SELECT    Am.ReportId ,
                                                            Q.Id ,
                                                            0 AS Score ,
                                                            0 AS BankchmarkScore ,
                                                            0 AS BanckmarkPI,
															SUM(A.QPI) * 1.0
                                                            / CASE CASE MAX(A.Detail)
                                                              WHEN '' THEN 0
                                                              ELSE 1
                                                              END
                                                              WHEN 0 THEN 1
                                                              ELSE CASE MAX(A.Detail)
                                                              WHEN '' THEN 0
                                                              ELSE 1
                                                              END
                                                              END AS Detail,
                                                            CASE MAX(A.Detail)
                                                              WHEN '' THEN 0
                                                              ELSE 1
                                                            END AS [Counts] ,
                                                            SUM(A.QPI) * 1.0
                                                            / CASE COUNT(Am.ReportId)
                                                              WHEN 0 THEN 1
                                                              ELSE COUNT(Am.ReportId)
                                                              END AS [PI] 
                                        FROM    dbo.View_SeenClientAnswerMaster
                                                AS Am
                                                INNER JOIN dbo.SeenClientAnswers
                                                AS A ON Am.ReportId = A.SeenClientAnswerMasterId
                                                INNER JOIN dbo.SeenClientQuestions Q ON A.QuestionId = Q.Id
                                                              AND Q.DisplayInGraphs = 1
                                                LEFT OUTER JOIN ( SELECT
                                                              Data
                                                              FROM
                                                              dbo.Split(@EstablishmentId,
                                                              ',')
                                                              ) AS RE ON ( RE.Data = Am.EstablishmentId
                                                              OR @EstablishmentId = '0'
                                                              )
                                                INNER JOIN ( SELECT
                                                              Data
                                                             FROM
                                                              dbo.Split(@QuestionIdList,
                                                              ',')
                                                           ) AS RQ ON RQ.Data = Q.Id
                                                --LEFT OUTER JOIN ( SELECT
                                                --              Data
                                                --              FROM
                                                --              dbo.Split(@UserId,
                                                --              ',')
                                                --              ) AS RU ON RU.Data = Am.AppUserId
                                                --              OR @UserId = '0'
                                        WHERE   Am.SeenClientId = @SeenClientId
												AND a.RepetitiveGroupId != 0  
                                                AND Am.ActivityId = @ActivityId
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
                                                AND RE.Data IS NOT NULL
                                                AND Am.AppUserId NOT IN (
                                                SELECT  Data
                                                FROM    dbo.Split(@UserId, ',') )
                                                AND CAST(Am.CreatedOn AS DATE) BETWEEN @FromDate
                                                              AND
                                                              @EndDate
                                        GROUP BY  Q.Id ,
                                                            Am.ReportId
                                                ) AS T
                                        GROUP BY T.Id;

										END
                                        
                                -- PRINT '++++++++++++++++';
                            END;
                        ELSE
                            BEGIN
                                INSERT  INTO @Result
                                        ( QId ,
                                          Score ,
                                          Counts ,
                                          [PI] ,
                                          BenchmarkScore ,
                                          BenchmarkCounts ,
                                          BenchmarkPI,
										  TotalEntry
                                        )
                                        SELECT  Id ,
                                                0 ,
                                                0 ,
                                                0 ,
                                                @FixedBenchmark ,
                                                1 ,
                                                @FixedBenchmark,
												0
                                        FROM    @Tbl;
                            END;
                    END;
				/*Your Score - Benchmark Score*/
                IF @CompareWithIndustry = 1
                    BEGIN
                        SELECT  @YScore = ROUND(SUM(Score)
                                                / CASE ISNULL(@QuestionCount,
                                                              0)
                                                    WHEN 0 THEN 0.01
                                                    ELSE ISNULL(@QuestionCount,
                                                              0)
                                                  END, 2) ,
                                @YBScore = ROUND(SUM(BenchmarkScore)
                                                 / CASE ISNULL(@QuestionCount,
                                                              0)
                                                     WHEN 0 THEN 0.01
                                                     ELSE ISNULL(@QuestionCount,
                                                              0)
                                                   END, 2) ,
                                @TotalEntry = SUM(ISNULL(Counts, 0)--+ ISNULL(BenchmarkCounts, 0)
										  )
                        FROM    @Result;
                    END;
 
                ELSE
                    BEGIN
                        SELECT  @YScore = ROUND(SUM([PI])
                                                / CASE ISNULL(@QuestionCount,
                                                              0)
                                                    WHEN 0 THEN 0.01
                                                    ELSE ISNULL(@QuestionCount,
                                                              0)
                                                  END, 2) ,
                                @YBScore = ROUND(SUM(BenchmarkPI)
                                                 / CASE ISNULL(@QuestionCount,
                                               0)
                                                     WHEN 0 THEN 0.01
                                                     ELSE ISNULL(@QuestionCount,
                                                              0)
                                                   END, 2) ,
                                @TotalEntry = SUM(ISNULL(Counts, 0)--+ ISNULL(BenchmarkCounts, 0)
										  )
                        FROM    @Result;

						
                    END;
					    --SELECT * FROM @Result
					    --SELECT * FROM @Tbl
                -- PRINT '############';
                -- PRINT @QuestionCount;			
				/*Total Entry Count*/
                IF @IsOut = 0
                    BEGIN
                        IF ( @AnswerMaster != 0 )
                            BEGIN
                                SET @TotalEntry = 1;
                            END;
                        ELSE
                            BEGIN
                                SELECT  @TotalEntry = COUNT(DISTINCT Am.ReportId)
                                FROM    dbo.View_AnswerMaster AS Am
                                        INNER JOIN dbo.Answers AS A ON Am.ReportId = A.AnswerMasterId
                                        INNER JOIN dbo.Questions Q ON A.QuestionId = Q.Id
                                        INNER JOIN ( SELECT Data
                                                     FROM   dbo.Split(@EstablishmentId,
                                                              ',')
                                                   ) AS RE ON ( RE.Data = Am.EstablishmentId
                                                              OR @EstablishmentId = '0'
                                                              )
                                        INNER JOIN ( SELECT Data
                                                     FROM   dbo.Split(@QuestionIdList,
                                                              ',')
                                                   ) AS RQ ON RQ.Data = Q.Id
                                        INNER JOIN ( SELECT Data
                                                     FROM   dbo.Split(@UserId,
                                                              ',')
                                                   ) AS RU ON RU.Data = Am.AppUserId
                                                              OR @UserId = '0'
                                WHERE   ActivityId = @ActivityId
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
                            END;
                    END;
                ELSE
                    BEGIN
                        IF ( @AnswerMaster != 0 )
                            BEGIN
                                SET @TotalEntry = 1;
                            END;
                        ELSE
                            BEGIN
                                SELECT  @TotalEntry = COUNT(DISTINCT Am.ReportId)
                                FROM    dbo.View_SeenClientAnswerMaster AS Am
                                        INNER JOIN dbo.SeenClientAnswers AS A ON Am.ReportId = A.SeenClientAnswerMasterId
                                        INNER JOIN dbo.SeenClientQuestions Q ON A.QuestionId = Q.Id
                                                              AND Q.DisplayInGraphs = 1
                                        INNER JOIN ( SELECT Data
                                                     FROM   dbo.Split(@EstablishmentId,
                                                              ',')
                                                   ) AS RE ON ( RE.Data = Am.EstablishmentId
                                                              OR @EstablishmentId = '0'
                                                              )
                                        INNER JOIN ( SELECT Data
                                                     FROM   dbo.Split(@QuestionIdList,
                                                              ',')
                                                   ) AS RQ ON RQ.Data = Q.Id
                                        INNER JOIN ( SELECT Data
                                                     FROM   dbo.Split(@UserId,
                                                              ',')
                                                   ) AS RU ON RU.Data = Am.AppUserId
                                                              OR @UserId = '0'
                                WHERE   ActivityId = @ActivityId
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
                            END;
                                                              
                    END;
                -- PRINT 'Total Entry1';
                -- PRINT @TotalEntry;
                -- PRINT 'Tell Us1';
                -- PRINT @IsTellUs;
				IF @TotalEntry > 0
                    BEGIN
                        IF @CompareWithIndustry = 1
                            BEGIN
                                /* PRINT '====111======';
								 PRINT @ToatlWaitage 
								 PRINT @ToatlBenchMarkWaitage
								 PRINT '====111======';*/
                                SELECT  @MinRank = MIN(Score) ,
                                        @MaxRank = MAX(Score) + 10
                                FROM    @Result;

								DELETE FROM @Result  WHERE Counts = 0 AND TotalEntry = 0 /* DT. 22-May-2017 for Remove Dublicate Entry*/

                                INSERT  INTO @FinalResult
                                        ( StartDate ,
                                          EndDate ,
                                          LastUpdatedDate ,
                                          ShortName ,
                                          Counts ,
                                          Score ,
                                          PerformanceBanchMark ,
                                          YourScore ,
                                          BenchMarkScore ,
                                          PerformanceBenchMarkScore ,
                                          MinRank ,
                                          MaxRank ,
                                          GroupType,
										  TotalEntry
                                        )
                                        SELECT  @FromDate AS StartDate ,
                                                @EndDate AS EndDate ,
                                                @LocalTime AS LastUpdatedDate ,
                                                ShortName ,
												[@Result].Counts AS Counts ,
                                                --@TotalEntry AS Counts ,
                                                ISNULL(ROUND(SUM(Score), 0), 0) AS Score ,
												ROUND(( ( CASE SUM(Score)
                                                            WHEN 0 THEN 0.01
                                                            ELSE SUM(Score)
                                                          END
                                                          - SUM(BenchmarkScore) )
                                                        / CASE SUM(Score)
                                                            WHEN 0 THEN 0.01
                                                            ELSE SUM(Score)
                                                          END * 100 ), 0) AS PerformanceBenchmark ,
                                                --ISNULL(@YScore, 0) AS YourScore ,
                                                ROUND(@ToatlWaitage, 0) AS YourScore ,
                                                --ROUND(ISNULL(@YBScore, 0),0) AS BenchmarkScore ,
                                                ROUND(ISNULL(@ToatlBenchMarkWaitage,
                                                             0), 0) AS BenchmarkScore ,
                                                ROUND((( ISNULL(@ToatlWaitage,
                                                              0)
                                                          - ISNULL(@ToatlBenchMarkWaitage,
                                                              0) )
                                                        / CASE ISNULL(@ToatlWaitage,
                                                              0)
                                                            WHEN 0 THEN 1
                                                            ELSE ISNULL(@ToatlWaitage,
                                                              0)
                                                          END * 100 ), 0) AS PerformanceBenchmarkScore ,
                                                --( ISNULL(@YScore, 0)
                                                --  - ISNULL(@YBScore, 0) )
                                                --/ CASE ISNULL(@YScore, 0)
                                                --    WHEN 0 THEN 1
                                                --    ELSE ISNULL(@YScore, 0)
                                                --  END * 100 AS PerformanceBenchmarkScore ,
                                                @MinRank AS MinRank ,
                                                @MaxRank AS MaxRank ,
                                                @DisplayType AS GroupType,
												TotalEntry
                                        FROM    @Tbl
                                                LEFT OUTER JOIN @Result ON [@Result].QId = [@Tbl].QId
                                        WHERE   [@Tbl].QId > 0
                                        GROUP BY [@Tbl].QId ,
                                                ShortName ,
                                                Position,
												[@Result].counts,
												TotalEntry
                                        ORDER BY [@Tbl].Position; /* Changed By Disha - 04-OCT-2016 - Order By Position instead of QId */

                            END;
                        ELSE
                            BEGIN
                                SELECT  @MinRank = 0 ,
                                        @MaxRank = 105
                                FROM    @Result;

                                DELETE FROM @Result  WHERE Counts = 0 AND TotalEntry = 0 /* DT. 22-May-2017 for Remove Dublicate Entry*/

                                INSERT  INTO @FinalResult
                                        ( StartDate ,
                                          EndDate ,
                                          LastUpdatedDate ,
                                          ShortName ,
                                          Counts ,
                                          Score ,
                                          PerformanceBanchMark ,
                                          YourScore ,
                                          BenchMarkScore ,
                                          PerformanceBenchMarkScore ,
                                          MinRank ,
                                          MaxRank ,
                                          GroupType,
										  TotalEntry
                                        )
                                        SELECT  @FromDate AS StartDate ,
                                                @EndDate AS EndDate ,
                                                @LocalTime AS LastUpdatedDate ,
                                                ShortName ,
                                                @TotalEntry AS Counts ,
                                                ISNULL(ROUND(SUM([PI]), 0), 0) AS Score ,
                                                --( CASE SUM([PI])
                                                --    WHEN 0 THEN 0.01
                                                --    ELSE SUM([PI])
                                                --  END - SUM(BenchmarkPI) )
                                                --/ CASE SUM([PI])
                                                --    WHEN 0 THEN 0.01
                                                --    ELSE SUM([PI])
                                                --  END * 100 AS PerformanceBenchmark ,
                                                ROUND(@FixedBenchmark, 0) AS PerformanceBenchmark ,
                                                --ISNULL(@YScore, 0) AS YourScore ,
                                                ROUND(@ToatlWaitage, 0) AS YourScore ,
												ROUND(@FixedBenchmark, 0) AS BenchmarkScore ,
                                                --ROUND(ISNULL(@YBScore, 0), 0) AS BenchmarkScore ,
                                                ROUND(( ( ISNULL(@ToatlWaitage,
                                                              0)
                                                          - ISNULL(@YBScore, 0) )
                       / CASE ISNULL(@ToatlWaitage,
                                                              0)
                                                            WHEN 0 THEN 1
                                                            ELSE ISNULL(@ToatlWaitage,
                                                              0)
                                                          END * 100 ), 0) AS PerformanceBenchmarkScore ,
                                                --( ISNULL(@YScore, 0)
                                                --  - ISNULL(@YBScore, 0) )
                                                --/ CASE ISNULL(@YScore, 0)
                                                --    WHEN 0 THEN 1
                                                --    ELSE ISNULL(@YScore, 0)
                                                --  END * 100 AS PerformanceBenchmarkScore ,
                                                @MinRank AS MinRank ,
                                                @MaxRank AS MaxRank ,
                                                @DisplayType AS GroupType,
												ISNULL(TotalEntry,0)
                                        FROM    @Tbl
                                                LEFT OUTER JOIN @Result ON [@Result].QId = [@Tbl].QId
                                        WHERE   [@Tbl].QId > 0
                                        GROUP BY [@Tbl].QId ,
                                                ShortName ,
                                                Position,
												TotalEntry
                                        ORDER BY [@Tbl].Position; /* Changed By Disha - 04-OCT-2016 - Order By Position instead of QId */
                            END;
                    END;
                ELSE
                    BEGIN
                        IF @CompareWithIndustry = 1
                            BEGIN 
                                INSERT  INTO @FinalResult
                                        SELECT  @FromDate AS StartDate ,
                                                @EndDate AS EndDate ,
                                                @LocalTime AS LastUpdatedDate ,
                                                '' ,
                                                Counts AS Counts ,
                                                AVG(ISNULL(Score, 0)) AS Score ,
                                                0 AS PerformanceBenchmark ,
                                                0 AS YourScore ,
                                                ROUND(ISNULL(@ToatlBenchMarkWaitage,
                                                             0), 0) AS BenchmarkScore ,
                                                0 AS PerformanceBenchmarkScore ,
                                                @MinRank AS MinRank ,
                                                @MaxRank AS MaxRank ,
                                                @DisplayType AS GroupType,
												ISNULL(TotalEntry,0)
                                        FROM    @Tbl
                                                LEFT OUTER JOIN @Result ON [@Result].QId = [@Tbl].QId
                                        WHERE   [@Tbl].QId > 0
                                        GROUP BY [@Tbl].QId ,
                                                ShortName ,
                                                Position ,
                                                Counts,
												TotalEntry
                                        ORDER BY [@Tbl].Position; /* Changed By Disha - 04-OCT-2016 - Order By Position instead of QId */
                            END;
                        ELSE
                            INSERT  INTO @FinalResult
                                    SELECT  @FromDate AS StartDate ,
                                            @EndDate AS EndDate ,
                                            @LocalTime AS LastUpdatedDate ,
                                            '' ,
                                            0 AS Counts ,
                                            0 AS Score ,
                                            0 AS PerformanceBenchmark ,
                                            0 AS YourScore ,
                                            @FixedBenchmark AS BenchmarkScore ,
                                            0 AS PerformanceBenchmarkScore ,
                                            @MinRank AS MinRank ,
                                            @MaxRank AS MaxRank ,
                                            @DisplayType AS GroupType,
											ISNULL(TotalEntry,0)
                                    FROM    @Tbl
                                            LEFT OUTER JOIN @Result ON [@Result].QId = [@Tbl].QId
                                    WHERE   [@Tbl].QId > 0
                                    GROUP BY [@Tbl].QId ,
                                            ShortName ,
                                            Position,
											TotalEntry
                                    ORDER BY [@Tbl].Position; /* Changed By Disha - 04-OCT-2016 - Order By Position instead of QId */
                    END;  
            END;
        ELSE
            BEGIN
                -- PRINT 'Part 2 (NPS)';

                DECLARE @tblScore TABLE
                    (
                      EstablishmentId BIGINT ,
                      GroupId BIGINT ,
                      ShortName NVARCHAR(50) ,
                      AnsId BIGINT
                    );

                DECLARE @FinalValue TABLE
                    (
                      ShortName NVARCHAR(50) ,
                      Score DECIMAL(18, 2) NOT NULL ,
                      BenchMarkScore DECIMAL(18, 2) NOT NULL
                    );              

                DECLARE @TotalCount INT ,
                    @YourPrometer DECIMAL(18, 4) ,
                    @YourDetractor DECIMAL(18, 4) ,
                    @IndustryPrometer DECIMAL(18, 4) ,
                    @IndustryDetractor DECIMAL(18, 4);

                DECLARE @CustomersPromoter NVARCHAR(50) = 'Promoters' ,
                    @CustomersPassive NVARCHAR(50)  = 'Passive' ,
                    @CustomerDetractor NVARCHAR(50) = 'Detractors';     

                IF @IsOut = 0
                    BEGIN
                        INSERT  INTO @tblScore
                                SELECT  Am.EstablishmentId ,
                                        Am.ActivityId ,
                                        CASE WHEN SUM(CAST(ISNULL(Detail, '') AS BIGINT))
                                                  / CASE COUNT(Am.ReportId)
                                                      WHEN 0 THEN 1
                                                      ELSE COUNT(Am.ReportId)
                                                    END >= 9
                                             THEN @CustomersPromoter
                                             WHEN SUM(CAST(ISNULL(Detail, '') AS BIGINT))
                                                  / CASE COUNT(Am.ReportId)
                                                      WHEN 0 THEN 1
                                                      ELSE COUNT(Am.ReportId)
                                                    END IN ( 7, 8 )
                                             THEN @CustomersPassive
                                             ELSE @CustomerDetractor
                                        END ,
                                        Am.ReportId
                                FROM    dbo.View_AnswerMaster AS Am
                                        INNER JOIN dbo.Answers AS A ON Am.ReportId = A.AnswerMasterId
                                        INNER JOIN dbo.Questions Q ON A.QuestionId = Q.Id
                                                              AND Q.DisplayInGraphs = 1
                      INNER JOIN ( SELECT Data
                                                     FROM   dbo.Split(@EstablishmentId,
                                                              ',')
                                                   ) AS RE ON ( RE.Data = Am.EstablishmentId
                                                              OR @EstablishmentId = '0'
                                                              )
                                        INNER JOIN ( SELECT Data
                                                     FROM   dbo.Split(@QuestionIdList,
                                                              ',')
                                                   ) AS RQ ON RQ.Data = Q.Id
                                        INNER JOIN ( SELECT Data
                                                     FROM   dbo.Split(@UserId,
                                                              ',')
                                                   ) AS RU ON RU.Data = Am.AppUserId
                                                              OR @UserId = '0'
                                WHERE   ActivityId = @ActivityId
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
                                        AND Q.QuestionTypeId = 2
                                        AND CAST(Am.CreatedOn AS DATE) BETWEEN @FromDate
                                                              AND
                                                              @EndDate
                                GROUP BY Am.EstablishmentId ,
                                        Am.ActivityId ,
                                        Am.ReportId;
                    END;
                ELSE
                    BEGIN
                        INSERT  INTO @tblScore
                                SELECT  Am.EstablishmentId ,
                                        Am.ActivityId ,
                                        CASE WHEN SUM(CAST(ISNULL(Detail, '') AS BIGINT))
                                                  / CASE COUNT(Am.ReportId)
                                                      WHEN 0 THEN 1
                                                      ELSE COUNT(Am.ReportId)
                                                    END >= 9
                                             THEN @CustomersPromoter
                                             WHEN SUM(CAST(ISNULL(Detail, '') AS BIGINT))
                                                  / CASE COUNT(Am.ReportId)
                                                      WHEN 0 THEN 1
                                                      ELSE COUNT(Am.ReportId)
                                                    END IN ( 7, 8 )
                                             THEN @CustomersPassive
                                             ELSE @CustomerDetractor
                                        END ,
                                        Am.ReportId
                                FROM    dbo.View_SeenClientAnswerMaster AS Am
                                        INNER JOIN dbo.SeenClientAnswers AS A ON Am.ReportId = A.SeenClientAnswerMasterId
                                        INNER JOIN dbo.SeenClientQuestions Q ON A.QuestionId = Q.Id
                                                              AND Q.DisplayInGraphs = 1
                                        INNER JOIN ( SELECT Data
                                                     FROM   dbo.Split(@EstablishmentId,
                                                              ',')
                                                   ) AS RE ON ( RE.Data = Am.EstablishmentId
                                                              OR @EstablishmentId = '0'
                                                              )
                                        INNER JOIN ( SELECT Data
                                                     FROM   dbo.Split(@QuestionIdList,
                                                              ',')
                                                   ) AS RQ ON RQ.Data = Q.Id
                                        INNER JOIN ( SELECT Data
                                                     FROM   dbo.Split(@UserId,
                                                              ',')
                                                   ) AS RU ON RU.Data = Am.AppUserId
                                                              OR @UserId = '0'
                                WHERE   ActivityId = @ActivityId
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
                                        AND Q.QuestionTypeId = 2
                                        AND CAST(Am.CreatedOn AS DATE) BETWEEN @FromDate
                                                              AND
                                                              @EndDate
                                GROUP BY Am.EstablishmentId ,
                                        Am.ActivityId ,
          Am.ReportId;
                    END;

                SELECT  @TotalCount = SUM(Total)
                FROM    ( SELECT    ShortName ,
                                    COUNT(1) AS Total
                          FROM      @tblScore
                          GROUP BY  ShortName
                        ) AS R;
				

                SELECT  @YourDetractor = ( COUNT(1) * 100.0 / @TotalCount )
                FROM    @tblScore
                WHERE   ShortName = @CustomerDetractor
                GROUP BY ShortName;

                SELECT  @YourPrometer = ( COUNT(1) * 100.0 / @TotalCount )
                FROM    @tblScore
                WHERE   ShortName = @CustomersPromoter
                GROUP BY ShortName;

                INSERT  INTO @FinalValue
                        SELECT  ShortName AS ShortName ,
                                ROUND(( COUNT(1) * 100.0 / @TotalCount ), 2) AS Score ,
                                0
                        FROM    @tblScore
                        GROUP BY ShortName;

                DELETE  FROM @tblScore;

                IF @IsOut = 0
                    BEGIN
                        INSERT  INTO @tblScore
                                SELECT  Am.EstablishmentId ,
                                        Am.ActivityId ,
                                        CASE WHEN SUM(CAST(ISNULL(Detail, '') AS BIGINT))
                                                  / CASE COUNT(Am.ReportId)
                                                      WHEN 0 THEN 1
                                                      ELSE COUNT(Am.ReportId)
                                                    END >= 9
                                             THEN @CustomersPromoter
                                             WHEN SUM(CAST(ISNULL(Detail, '') AS BIGINT))
                                                  / CASE COUNT(Am.ReportId)
                                                      WHEN 0 THEN 1
                                                      ELSE COUNT(Am.ReportId)
                                                    END IN ( 7, 8 )
                                             THEN @CustomersPassive
                                             ELSE @CustomerDetractor
                                        END ,
                                        Am.ReportId
                                FROM    dbo.View_AnswerMaster AS Am
                                        INNER JOIN dbo.Answers AS A ON Am.ReportId = A.AnswerMasterId
                                        INNER JOIN dbo.Questions Q ON A.QuestionId = Q.Id
                                                              AND Q.DisplayInGraphs = 1
                                        LEFT OUTER JOIN ( SELECT
                                                              Data
                                                          FROM
                                                              dbo.Split(@EstablishmentId,
                                                              ',')
                                                        ) AS RE ON ( RE.Data = Am.EstablishmentId
                                                              OR @EstablishmentId = '0'
                                                              )
                                        INNER JOIN ( SELECT Data
                                                     FROM   dbo.Split(@QuestionIdList,
                                                              ',')
                                                   ) AS RQ ON RQ.Data = Q.Id
                                        LEFT OUTER JOIN ( SELECT
                                                              Data
                                                          FROM
                                                              dbo.Split(@UserId,
            ',')
                                                        ) AS RU ON RU.Data = Am.AppUserId
                                                              OR @UserId = '0'
                                WHERE   Q.QuestionTypeId = 2
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
                                        AND Am.QuestionnaireId = @QuestionnaireId
                                        AND Q.IsActive = 1
                                        AND RE.Data IS NULL
                                        AND RU.Data IS NULL
                                        AND CAST(Am.CreatedOn AS DATE) BETWEEN @FromDate
                                                              AND
                                                              @EndDate
                                GROUP BY Am.EstablishmentId ,
                                        Am.ActivityId ,
                                        Am.ReportId;
                    END;
                ELSE
                    BEGIN
                        INSERT  INTO @tblScore
                                SELECT  Am.EstablishmentId ,
                                        Am.ActivityId ,
                                        CASE WHEN SUM(CAST(ISNULL(Detail, '') AS BIGINT))
                                                  / CASE COUNT(Am.ReportId)
                                                      WHEN 0 THEN 1
                                                      ELSE COUNT(Am.ReportId)
                                                    END >= 9
                                             THEN @CustomersPromoter
                                             WHEN SUM(CAST(ISNULL(Detail, '') AS BIGINT))
                                                  / CASE COUNT(Am.ReportId)
                                                      WHEN 0 THEN 1
                                                      ELSE COUNT(Am.ReportId)
                                                    END IN ( 7, 8 )
                                             THEN @CustomersPassive
                                             ELSE @CustomerDetractor
                                        END ,
                                        Am.ReportId
                                FROM    dbo.View_SeenClientAnswerMaster AS Am
                                        INNER JOIN dbo.SeenClientAnswers AS A ON Am.ReportId = A.SeenClientAnswerMasterId
                                        INNER JOIN dbo.SeenClientQuestions Q ON A.QuestionId = Q.Id
                                                              AND Q.DisplayInGraphs = 1
                                        LEFT OUTER JOIN ( SELECT
                                                              Data
                                                          FROM
                                                              dbo.Split(@EstablishmentId,
                                                              ',')
                                                        ) AS RE ON ( RE.Data = Am.EstablishmentId
                                                              OR @EstablishmentId = '0'
                                                              )
                                        INNER JOIN ( SELECT Data
                                                     FROM   dbo.Split(@QuestionIdList,
                                                              ',')
                                                   ) AS RQ ON RQ.Data = Q.Id
                                        LEFT OUTER JOIN ( SELECT
                                                              Data
                                                          FROM
                                                              dbo.Split(@UserId,
                                                              ',')
                                                        ) AS RU ON RU.Data = Am.AppUserId
                                                              OR @UserId = '0'
                                WHERE   Q.QuestionTypeId = 2
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
                                        AND Am.SeenClientId = @SeenClientId
                                --AND Q.IsActive = 1
                                        AND RE.Data IS NULL
                                        AND RU.Data IS NULL
                                        AND CAST(Am.CreatedOn AS DATE) BETWEEN @FromDate
                                                              AND
                                                              @EndDate
                                GROUP BY Am.EstablishmentId ,
                                        Am.ActivityId ,
                                        Am.ReportId;
                    END;                  
                SELECT  @TotalCount = SUM(Total)
                FROM    ( SELECT    ShortName ,
                                    COUNT(1) AS Total
                          FROM      @tblScore
                         GROUP BY  ShortName
                        ) AS R;

                INSERT  INTO @FinalValue
                        SELECT  ShortName AS ShortName ,
                                0 ,
                                ( COUNT(1) * 100.0 / @TotalCount ) AS BM
                        FROM    @tblScore
                        GROUP BY ShortName;

                
                SELECT  @IndustryDetractor = ( SUM(Score) - SUM(BenchMarkScore) )
                        / CASE SUM(Score)
                            WHEN 0 THEN 1
                            ELSE SUM(Score)
                          END * 100
                FROM    @FinalValue
                WHERE   ShortName = @CustomerDetractor
                GROUP BY ShortName;

                SELECT  @IndustryPrometer = ( SUM(Score) - SUM(BenchMarkScore) )
                        / CASE SUM(Score)
                            WHEN 0 THEN 1
                            ELSE SUM(Score)
                          END * 100
                FROM    @FinalValue
                WHERE   ShortName = @CustomersPromoter
                GROUP BY ShortName;

                SELECT  @TotalEntry = COUNT(1)
                FROM    @FinalValue;

                -- PRINT @TotalEntry;
                -- PRINT @TotalEntry;

                IF @TotalEntry > 0
                    BEGIN
                         PRINT 'TEST123';
                        INSERT  INTO @FinalResult
                                SELECT  @FromDate AS StartDate ,
                                        @EndDate AS EndDate ,
                                        @LocalTime AS LastUpdatedDate ,
                                        ShortName ,
                                        @TotalEntry AS Counts ,
                                        ROUND(SUM(Score), 0) AS Score ,
                                        ROUND(( ( SUM(Score) - 6 )
                                                / CASE SUM(Score)
                                                    WHEN 0 THEN 1
                                                    ELSE SUM(Score)
                                                  END * 100 ), 0) AS PerformanceBanchMark ,
                                        --ROUND(( ISNULL(@YourPrometer, 0)
                                        --        - ISNULL(@YourDetractor, 0) ),
                                        --      2) AS YourScore ,
                                        ROUND(@ToatlWaitage, 0) AS YourScore ,
                                        ROUND(ISNULL(@IndustryPrometer, 0)
                                              - ISNULL(@IndustryDetractor, 0),
                                              0) AS BenchMarkScore ,
                                        ROUND(( ( ROUND(( ISNULL(@YourPrometer,
                                                              0)
                                                          - ISNULL(@YourDetractor,
                                                              0) ), 2)
                                                  - ( ISNULL(@IndustryPrometer,
                                                             0)
                                                      - ISNULL(@IndustryDetractor,
                                                              0) ) )
                                                / CASE ROUND(( ISNULL(@YourPrometer,
                                                              0)
                                                              - ISNULL(@YourDetractor,
                                                              0) ), 2)
                                                    WHEN 0 THEN 1
                                                    ELSE ROUND(( ISNULL(@YourPrometer,
                                                              0)
                                                              - ISNULL(@YourDetractor,
                                                              0) ), 2)
                                                  END * 100 ), 0) AS PerformanceBenchmarkScore ,
                                        @MinRank AS MinRank ,
                                        @MaxRank AS MaxRank ,
                                        @DisplayType AS GroupType,
										@TotalEntry
                                FROM    @FinalValue
                                GROUP BY ShortName
                                ORDER BY ShortName DESC;
                    END;
                ELSE
                    BEGIN
                        -- PRINT 'Test444';
                        INSERT  INTO @FinalResult
                                SELECT  @FromDate AS StartDate ,
                                        @EndDate AS EndDate ,
                                        @LocalTime AS LastUpdatedDate ,
                                        '' ,
                                        0 AS Counts ,
                                        0 AS Score ,
                                        0 AS PerformanceBenchmark ,
                                        0 AS YourScore ,
                                        0 AS BenchmarkScore ,
                                        0 AS PerformanceBenchmarkScore ,
                                        @MinRank AS MinRank ,
                                        @MaxRank AS MaxRank ,
                                        @DisplayType AS GroupType,
										TotalEntry
                                FROM    @Tbl
                                        LEFT OUTER JOIN @Result ON [@Result].QId = [@Tbl].QId
                                WHERE   [@Tbl].QId > 0
                                GROUP BY [@Tbl].QId ,
                                        ShortName ,
                                        Position,
										TotalEntry
                                ORDER BY [@Tbl].Position; /* Changed By Disha - 04-OCT-2016 - Order By Position instead of QId */
                    END;
            END;

        SELECT  StartDate ,
                EndDate ,
                LastUpdatedDate ,
                ShortName ,
                ISNULL(Counts, 0) AS Counts ,
                Score ,
                PerformanceBanchMark ,
                YourScore ,
                CASE @AnswerMaster
                  WHEN 0 THEN BenchMarkScore
                  ELSE 0
                END AS BenchMarkScore ,
                PerformanceBenchMarkScore ,
                MinRank ,
                MaxRank ,
                GroupType,
				TotalEntry
        FROM    @FinalResult;
    END;


