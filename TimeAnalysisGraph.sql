-- =============================================
-- Author:		<Vasu Patel>
-- Create date: <27 Apr 2017>
-- Description:	<Time Analycis Calculation>
-- Call: TimeAnalysisGraph '13410',2433,'18 sep 2017', 3,'Resolved','0',1,'',1243
-- Call: TimeAnalysisGraph '1596',1177,'18 sep 2017', 4,'Resolved','0',0,'',0
-- =============================================
CREATE PROCEDURE [dbo].[TimeAnalysisGraph]
    @EstablishmentId VARCHAR(2000) ,
    @ActivityId BIGINT ,
    @FromDate DATETIME ,
    @Type INT ,
    @ChartType VARCHAR(50) ,
    @UserId VARCHAR(2000) ,
    @IsOut BIT ,
    @FilterOn NVARCHAR(50) ,
    @AppuserId BIGINT
AS
    BEGIN

	/* Declare  */
		DECLARE @TimeOffSet INT; 
		DECLARE @listStr NVARCHAR(MAX);
		 DECLARE @ActivityType NVARCHAR(50);

		  DECLARE @tblCount TABLE
            (
              Id BIGINT IDENTITY(1, 1) ,
              Name BIGINT NOT NULL
            );
        DECLARE @YourScore DECIMAL(18,0);
        DECLARE @BenchmarkYourScore DECIMAL(18,0);
        DECLARE @TotalEntry BIGINT;
        DECLARE @OutOfTotalEntry BIGINT;
		DECLARE @BenchmarkOutOftoatlEntry BIGINT;
		
        DECLARE @End BIGINT ,
        @Start BIGINT = 1;

        DECLARE @EndDate DATETIME ,
		@LocalTime DATETIME;

		DECLARE @MinRank INT;
        DECLARE @MaxRank INT;
		DECLARE @Performace DECIMAL(18,0);

        SELECT TOP 1
                @TimeOffSet = E.TimeOffSet
        FROM    dbo.EstablishmentGroup AS Eg
                INNER JOIN dbo.Establishment AS E ON Eg.Id = E.EstablishmentGroupId
        WHERE   Eg.Id = @ActivityId
                AND E.IsDeleted = 0;
      
        IF ( @EstablishmentId = '0' )
            BEGIN
                SET @EstablishmentId = ( SELECT dbo.AllEstablishmentByAppUserAndActivity(@AppuserId,
                                                              @ActivityId)
                                       );
            END;
      
       
        SELECT  @ActivityType = EstablishmentGroupType
        FROM    dbo.EstablishmentGroup
        WHERE   Id = @ActivityId;
        IF ( @UserId = '0'
             AND @ActivityType != 'Customer'
           )
            BEGIN
                SET @UserId = ( SELECT  dbo.AllUserSelected(@AppuserId,
                                                            @EstablishmentId,
                                                            @ActivityId)
                              );
            END;
			ELSE IF ( @UserId = '0'
             AND @ActivityType = 'Customer')
            BEGIN
				--SELECT TOP 1 @UserId = AppUserId FROM dbo.AppUserEstablishment WHERE EstablishmentId IN (SELECT data FROM dbo.Split(@EstablishmentId,','))
				SELECT @UserId = COALESCE(@UserId+',' ,'') + CONVERT(VARCHAR(10), AppUserId) FROM dbo.AppUserEstablishment WHERE EstablishmentId IN (SELECT data FROM dbo.Split(@EstablishmentId,','))
			END
            
SELECT  @LocalTime = DATEADD(MINUTE, @TimeOffSet, GETUTCDATE());
        IF @Type = 1
            BEGIN
                SET @End = 24;          
                IF CONVERT(DATE, @FromDate) >= CONVERT(DATE, @LocalTime)
                    BEGIN
                        SET @FromDate = CONVERT(DATE, @LocalTime);
                        SET @End = DATEPART(HOUR, @LocalTime);
                    END;
                SET @EndDate =  DATEADD(d,1,@FromDate);
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

/* Start YourScore */
/*Declare*/
        DECLARE @TimeAnalycis TABLE
            (
              Sno INT ,
              Id BIGINT ,
              OutCreatedOn DATETIME ,
              FirstAction DATETIME ,
              InForm DATETIME ,
              Resolved DATETIME
            );
        DECLARE @Result TABLE
            (
              Name INT ,
              DisplayName VARCHAR(15) ,
              Actions INT,
			  Score INT
            );

			        DECLARE @BenchmarkTimeAnalycis TABLE
            (
              Sno INT ,
              Id BIGINT ,
              OutCreatedOn DATETIME ,
              FirstAction DATETIME ,
              InForm DATETIME ,
              Resolved DATETIME
            );
        DECLARE @BenchmarkResult TABLE
            (
              Name INT ,
              DisplayName VARCHAR(15) ,
              Actions INT,
			  Score INT
            );

/*Logic*/
IF(@IsOut = 1)
BEGIN
        INSERT  INTO @TimeAnalycis
                ( Sno ,
                  Id ,
                  OutCreatedOn ,
                  FirstAction ,
                  InForm ,
                  Resolved
                )
                SELECT  CASE @Type
                          WHEN 1 THEN DATEPART(HOUR, T.CreatedOn)
                          WHEN 2 THEN DATEPART(DW, T.CreatedOn)
                          WHEN 3 THEN DATEPART(DAY, T.CreatedOn)
                          ELSE DATEPART(MONTH, T.CreatedOn)
                        END AS Sno ,
                        T.Id ,
                        T.CreatedOn ,
                        T.FirstAction ,
                        T.InForm ,
                        T.Resolved
                FROM    ( SELECT    SA.Id ,
                                    SA.CreatedOn ,
                                    MIN(FA.CreatedOn) AS FirstAction ,
                                    MIN(A.CreatedOn) AS InForm ,
                                    CL.CreatedOn AS Resolved
                          FROM      dbo.SeenClientAnswerMaster SA
                                    LEFT JOIN dbo.AnswerMaster A ON A.SeenClientAnswerMasterId = SA.Id
                                                              AND A.Id IS NOT NULL
                                    LEFT JOIN dbo.CloseLoopAction AS CL ON CL.SeenClientAnswerMasterId = SA.Id
                                                              AND SA.IsResolved = 'Resolved'
                                                              AND CL.[Conversation] LIKE '%Resolved%'
                                                              AND CL.CreatedOn IS NOT NULL
                                    LEFT JOIN dbo.CloseLoopAction AS FA ON FA.SeenClientAnswerMasterId = SA.Id
                                                              AND FA.CreatedOn IS NOT NULL
                                    INNER JOIN dbo.Establishment AS E ON E.Id = SA.EstablishmentId
                                                              AND E.IsDeleted = 0
                                                              AND E.EstablishmentGroupId = @ActivityId
                          WHERE     SA.EstablishmentId IN (
                                    SELECT  Data
                                    FROM    dbo.Split(@EstablishmentId, ',') )
                                    AND SA.AppUserId IN (
                                    SELECT  Data
                                    FROM    dbo.Split(@UserId, ',') )
                                    AND SA.IsDeleted = 0
                                    AND SA.CreatedOn BETWEEN @FromDate AND @EndDate
                          GROUP BY  SA.Id ,
                                    SA.CreatedOn ,
                                    CL.CreatedOn ,
                                    A.CreatedOn
                        ) AS T;

						/* Start Benchmark */

        INSERT  INTO @BenchmarkTimeAnalycis
                ( Sno ,
                  Id ,
                  OutCreatedOn ,
                  FirstAction ,
                  InForm ,
                  Resolved
                )
                SELECT  CASE @Type
                          WHEN 1 THEN DATEPART(HOUR, T.CreatedOn)
                          WHEN 2 THEN DATEPART(DW, T.CreatedOn)
                          WHEN 3 THEN DATEPART(DAY, T.CreatedOn)
                          ELSE DATEPART(MONTH, T.CreatedOn)
                        END AS Sno ,
                        T.Id ,
                        T.CreatedOn ,
                        T.FirstAction ,
                        T.InForm ,
                        T.Resolved
                FROM    (SELECT SA.Id ,
                                    SA.CreatedOn ,
                                    MIN(FA.CreatedOn) AS FirstAction ,
                                    MIN(A.CreatedOn) AS InForm ,
                                    CL.CreatedOn AS Resolved
                          FROM      dbo.SeenClientAnswerMaster SA
                                    LEFT JOIN dbo.AnswerMaster A ON A.SeenClientAnswerMasterId = SA.Id
                                                              AND A.Id IS NOT NULL
                                    LEFT JOIN dbo.CloseLoopAction AS CL ON CL.SeenClientAnswerMasterId = SA.Id
                                                              AND SA.IsResolved = 'Resolved'
                                                              AND CL.[Conversation] LIKE '%Resolved%'
                                                              AND CL.CreatedOn IS NOT NULL
                                    LEFT JOIN dbo.CloseLoopAction AS FA ON FA.SeenClientAnswerMasterId = SA.Id
                                                              AND FA.CreatedOn IS NOT NULL
                                    INNER JOIN dbo.Establishment AS E ON E.Id = SA.EstablishmentId
                                                              AND E.IsDeleted = 0
                                                              AND E.EstablishmentGroupId = @ActivityId
                          WHERE     
									(SA.EstablishmentId IN (
                                    SELECT  Data
                                    FROM    dbo.Split(@EstablishmentId, ',') ))
         --                           Or SA.AppUserId NOT IN (
         --                           SELECT  Data
         --                           FROM    dbo.Split(@UserId, ',') ))
                                    AND 
									SA.IsDeleted = 0
                                    AND SA.CreatedOn BETWEEN @FromDate AND @EndDate
                          GROUP BY  SA.Id ,
                                    SA.CreatedOn ,
                                    CL.CreatedOn ,
                                    A.CreatedOn
                        ) AS T;

END
ELSE
BEGIN

	        INSERT  INTO @TimeAnalycis
                ( Sno ,
                  Id ,
                  OutCreatedOn ,
                  FirstAction ,
                  InForm ,
                  Resolved
                )
                SELECT  CASE @Type
                          WHEN 1 THEN DATEPART(HOUR, T.CreatedOn)
                          WHEN 2 THEN DATEPART(DW, T.CreatedOn)
                          WHEN 3 THEN DATEPART(DAY, T.CreatedOn)
                          ELSE DATEPART(MONTH, T.CreatedOn)
                        END AS Sno ,
                        T.Id ,
                        T.CreatedOn ,
                        T.FirstAction ,
                        T.InForm ,
                        T.Resolved
                FROM    ( SELECT    SA.Id ,
                                    SA.CreatedOn ,
                                    MIN(FA.CreatedOn) AS FirstAction ,
                                    NULL AS InForm ,
                                    MAX(CL.CreatedOn) AS Resolved
                          FROM      dbo.AnswerMaster SA
									LEFT JOIN dbo.CloseLoopAction AS CL ON CL.AnswerMasterId = SA.Id
                                                              AND SA.IsResolved = 'Resolved'
                                                              AND CL.[Conversation] LIKE '%Resolved%'
                                                              AND CL.CreatedOn IS NOT NULL
                                    LEFT JOIN dbo.CloseLoopAction AS FA ON FA.AnswerMasterId = SA.Id
                                                              AND FA.CreatedOn IS NOT NULL
                                    INNER JOIN dbo.Establishment AS E ON E.Id = SA.EstablishmentId
                                                              AND E.IsDeleted = 0
                                                              AND E.EstablishmentGroupId = @ActivityId
                          WHERE     SA.EstablishmentId IN (
                                    SELECT  Data
                                    FROM    dbo.Split(@EstablishmentId, ',') )
                                    AND (SA.AppUserId IN (
                                    SELECT  Data
                                    FROM    dbo.Split(@UserId, ',')) 
									OR @UserId = '0')
                                    AND SA.IsDeleted = 0
                                    AND SA.CreatedOn BETWEEN @FromDate AND @EndDate
                          GROUP BY  SA.Id ,
                                    SA.CreatedOn ,
                                    CL.CreatedOn 
                        ) AS T;

INSERT  INTO @BenchmarkTimeAnalycis
                ( Sno ,
                  Id ,
                  OutCreatedOn ,
                  FirstAction ,
                  InForm ,
                  Resolved
                )
                SELECT  CASE @Type
                          WHEN 1 THEN DATEPART(HOUR, T.CreatedOn)
                          WHEN 2 THEN DATEPART(DW, T.CreatedOn)
                          WHEN 3 THEN DATEPART(DAY, T.CreatedOn)
                          ELSE DATEPART(MONTH, T.CreatedOn)
                        END AS Sno ,
                        T.Id ,
                        T.CreatedOn ,
                        T.FirstAction ,
                        T.InForm ,
                        T.Resolved
                FROM    (SELECT SA.Id ,
                                    SA.CreatedOn ,
                                    MIN(FA.CreatedOn) AS FirstAction ,
                                    Null AS InForm ,
                                    MAX(CL.CreatedOn) AS Resolved
                          FROM     dbo.AnswerMaster SA 
                                    LEFT JOIN dbo.CloseLoopAction AS CL ON CL.AnswerMasterId = SA.Id
                                                              AND SA.IsResolved = 'Resolved'
                                                              AND CL.[Conversation] LIKE '%Resolved%'
                                                              AND CL.CreatedOn IS NOT NULL
                                    LEFT JOIN dbo.CloseLoopAction AS FA ON FA.AnswerMasterId = SA.Id
                                                              AND FA.CreatedOn IS NOT NULL
                                    INNER JOIN dbo.Establishment AS E ON E.Id = SA.EstablishmentId
                                                              AND E.IsDeleted = 0
                                                              AND E.EstablishmentGroupId = @ActivityId
                          WHERE     
									(SA.EstablishmentId IN (
                                    SELECT  Data
                                    FROM    dbo.Split(@EstablishmentId, ',') ))
         --                           Or SA.AppUserId IN (
         --                           SELECT  Data
         --                           FROM    dbo.Split(@UserId, ',') ))
                                    AND 
									SA.IsDeleted = 0
                                    AND SA.CreatedOn BETWEEN @FromDate AND @EndDate
                          GROUP BY  SA.Id ,
                                    SA.CreatedOn ,
                                    CL.CreatedOn 
                        ) AS T;
END

IF (@ChartType = 'In Form')
BEGIN
        INSERT  INTO @Result
                ( Name ,
                  DisplayName ,
                  Actions,
				  Score
                )
                SELECT  Id AS Name ,
                        CASE @Type
                          WHEN 2
                          THEN CONVERT(VARCHAR(3), DATENAME(DW, TC.Name - 2))
                          ELSE CONVERT(VARCHAR(5), TC.Name)
                        END AS 'DisplayName' ,
                        ISNULL(T.ChartType, 0) AS Actions,
						ISNULL(T.Score,0) AS Score
                FROM    ( SELECT    Name ,
                                    CASE @Type
                                      WHEN 2
                                      THEN CONVERT(VARCHAR(3), DATENAME(DW,
                                                              [@tblCount].Name
                                                              - 2))
                                      ELSE CONVERT(VARCHAR(5), [@tblCount].Name)
                                    END AS DisplayName , DATEDIFF(MINUTE, MIN(OutCreatedOn),
                                                        ISNULL(MIN(InForm),
                                                              MIN(OutCreatedOn)))
                                     AS 'ChartType',
									(DATEDIFF(MINUTE, MIN(OutCreatedOn),
                                                        ISNULL(MIN(InForm),
                                                              MIN(OutCreatedOn))))
                                    AS 'Score'
                          FROM      @tblCount
                                    LEFT OUTER JOIN @TimeAnalycis ON [@tblCount].Name = [@TimeAnalycis].Sno
                          WHERE     (@ChartType = 'First Action' AND FirstAction IS not NULL)
									OR (@ChartType = 'In Form' AND InForm IS NOT NULL )
									OR (@ChartType = 'Resolved' AND Resolved IS NOT NULL) 
                          GROUP BY  Name 
                        ) AS T
                        RIGHT OUTER JOIN @tblCount AS TC ON TC.Name = T.Name;
END
ELSE IF (@ChartType = 'Resolved')
BEGIN
        INSERT  INTO @Result
                ( Name ,
                  DisplayName ,
                  Actions,
				  Score
                )
                SELECT  Id AS Name ,
                        CASE @Type
                          WHEN 2
                          THEN CONVERT(VARCHAR(3), DATENAME(DW, TC.Name - 2))
                          ELSE CONVERT(VARCHAR(5), TC.Name)
                        END AS 'DisplayName' ,
                        ISNULL(T.ChartType, 0) AS Actions,
						ISNULL(T.Score,0) AS Score
                FROM    ( SELECT    Name ,
                                    CASE @Type
                                      WHEN 2
                                      THEN CONVERT(VARCHAR(3), DATENAME(DW,
                                                              [@tblCount].Name
                                                              - 2))
                                      ELSE CONVERT(VARCHAR(5), [@tblCount].Name)
                                    END AS DisplayName ,
									DATEDIFF(MINUTE, MAX(OutCreatedOn),
                                                        ISNULL(MAX(Resolved),
                                                              MAX(OutCreatedOn))) AS 'ChartType',
									DATEDIFF(MINUTE, MAX(OutCreatedOn),
                                                        ISNULL(MAX(Resolved),
                                                              MAX(OutCreatedOn))) AS 'Score'
                          FROM      @tblCount
                                    LEFT OUTER JOIN @TimeAnalycis ON [@tblCount].Name = [@TimeAnalycis].Sno
                          WHERE     (@ChartType = 'First Action' AND FirstAction IS not NULL)
									OR (@ChartType = 'In Form' AND InForm IS NOT NULL )
									OR (@ChartType = 'Resolved' AND Resolved IS NOT NULL) 
                          GROUP BY  Name
                        ) AS T
                        RIGHT OUTER JOIN @tblCount AS TC ON TC.Name = T.Name;
						END
                        
/* End YourScore */


        INSERT  INTO @BenchmarkResult
                ( Name ,
                  DisplayName ,
                  Actions,
				  Score
                )
                SELECT  Id AS Name ,
                        CASE @Type
                          WHEN 2
                          THEN CONVERT(VARCHAR(3), DATENAME(DW, TC.Name - 2))
                          ELSE CONVERT(VARCHAR(5), TC.Name)
                        END AS 'DisplayName' ,
                        ISNULL(T.ChartType, 0) AS Actions,
						ISNULL(T.Score,0) AS Score
                FROM    ( SELECT    Name ,
                                    CASE @Type
                                      WHEN 2
                                      THEN CONVERT(VARCHAR(3), DATENAME(DW,
                                                              [@tblCount].Name
                                                              - 2))
                                      ELSE CONVERT(VARCHAR(5), [@tblCount].Name)
                                    END AS DisplayName ,
                                    CASE @ChartType
                                      WHEN 'First Action'
                                      THEN AVG(DATEDIFF(MINUTE, OutCreatedOn,
                                                        ISNULL(FirstAction,
                                                              OutCreatedOn)))
                                      WHEN 'In Form'
                                      THEN AVG(DATEDIFF(MINUTE, OutCreatedOn,
                                                        ISNULL(InForm,
                                                              OutCreatedOn)))
                                      WHEN 'Resolved'
                                      THEN AVG(DATEDIFF(MINUTE, OutCreatedOn,
                                                        ISNULL(Resolved,
                                                              OutCreatedOn)))
                                    END AS 'ChartType',
									CASE @ChartType
                                      WHEN 'First Action'
                                      THEN SUM(DATEDIFF(MINUTE, OutCreatedOn,
                                                        ISNULL(FirstAction,
                                                              OutCreatedOn)))
                                      WHEN 'In Form'
                                      THEN SUM(DATEDIFF(MINUTE, OutCreatedOn,
                                                        ISNULL(InForm,
                                                              OutCreatedOn)))
                                      WHEN 'Resolved'
                                      THEN DATEDIFF(MINUTE, MAX(OutCreatedOn),
                                                        ISNULL(MAX(Resolved),
                                                              MAX(OutCreatedOn)))
                                    END AS 'Score'
                          FROM      @tblCount
                                    LEFT OUTER JOIN @BenchmarkTimeAnalycis ON [@tblCount].Name = [@BenchmarkTimeAnalycis].Sno
                          WHERE     (  (@ChartType = 'First Action' AND FirstAction IS not NULL)
									OR (@ChartType = 'In Form' AND InForm IS NOT NULL )
									OR (@ChartType = 'Resolved' AND Resolved IS NOT NULL) 
                                    )
                          GROUP BY  Name
                        ) AS T
                        RIGHT OUTER JOIN @tblCount AS TC ON TC.Name = T.Name;
/* End Benchmark */

        SELECT  @MinRank = CASE MIN(Actions)
                             WHEN 0 THEN 1
                             ELSE MIN(Actions) - 1
                           END
        FROM    @Result;
        SELECT  @MaxRank = MAX(Actions) + 1
        FROM    @Result;

		  SELECT  @TotalEntry = COUNT(DISTINCT Id)
        FROM    @TimeAnalycis; 

        IF ( @ChartType = 'First Action' )
            BEGIN
                SELECT  @OutOfTotalEntry = COUNT(DISTINCT Id)
                FROM    @TimeAnalycis
                WHERE   FirstAction IS NOT NULL;

				SELECT  @BenchmarkOutOftoatlEntry = COUNT(DISTINCT Id)
                FROM    @BenchmarkTimeAnalycis
                WHERE   FirstAction IS NOT NULL;
				
            END;
        ELSE
            IF ( @ChartType = 'In Form' )
                BEGIN
                    SELECT  @OutOfTotalEntry = COUNT(DISTINCT Id)
                    FROM    @TimeAnalycis
                    WHERE   InForm IS NOT NULL;

					SELECT  @BenchmarkOutOftoatlEntry = COUNT(DISTINCT Id)
                FROM    @BenchmarkTimeAnalycis
                    WHERE   InForm IS NOT NULL;
                END;
            ELSE
                IF ( @ChartType = 'Resolved' )
                    BEGIN
                        SELECT  @OutOfTotalEntry = COUNT(DISTINCT Id)
                        FROM    @TimeAnalycis
                        WHERE   Resolved IS NOT NULL;

						SELECT  @BenchmarkOutOftoatlEntry = COUNT(DISTINCT Id)
						FROM    @BenchmarkTimeAnalycis
						WHERE   Resolved IS NOT NULL;
                    END;
					 
	    SELECT  @YourScore = SUM(Score) / CASE @OutOfTotalEntry WHEN 0 THEN 1 ELSE @OutOfTotalEntry end
        FROM    @Result;
        SELECT  @BenchmarkYourScore = SUM(Score) / CASE @BenchmarkOutOftoatlEntry WHEN 0 THEN 1 ELSE @BenchmarkOutOftoatlEntry end
        FROM    @BenchmarkResult;
		
        --SET  @Performace = (@YourScore - @BenchmarkYourScore) / CASE ISNULL(@YourScore, 0)
        --                              WHEN 0 THEN 1
        --                              ELSE @YourScore
        --                            END  * 100;

		SET  @Performace = (@YourScore - @BenchmarkYourScore)
					
SELECT  * ,
                @YourScore AS 'YourScore' ,
                @BenchmarkYourScore AS BenchmarkScore ,
                @Performace AS 'Performance' ,
                @TotalEntry AS 'TotalEntry' ,
                @OutOfTotalEntry AS 'OutOfTotalEntry' ,
                @MinRank AS [MinRank] ,
                @MaxRank AS [MaxRank] ,
                @LocalTime AS LastUpdatedTime ,
                @FromDate AS StartDate ,
                @EndDate AS EndDate ,
                0 AS DisplayType
        FROM    @Result;
    END;
