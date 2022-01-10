-- =============================================
-- Author:		<Author,,GD>
-- Create date: <Create Date,,15 Jul 2015>
-- Description:	<Description,,>
-- Call SP:		spActivityBarometerGraphV1 '13410', 2433, '07 Sep 2017', 1, '0', 0,'',1246
-- =============================================
CREATE PROCEDURE [dbo].[spActivityBarometerGraphV1]
    @EstablishmentId NVARCHAR(MAX) ,
    @ActivityId BIGINT ,
    @FromDate DATETIME ,
    @Type INT ,
    @UserId NVARCHAR(MAX) ,
    @IsOut BIT ,
    @FilterOn NVARCHAR(50),
	@AppuserId BIGINT
AS
   BEGIN
   set Nocount off;  
	  DECLARE @listStr NVARCHAR(MAX);
      
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
            END;
  
        PRINT 'Questionnaire';
        PRINT @QuestionnaireId;
        PRINT 'SeenClient';
        PRINT @SeenClientId;
        PRINT 'Display Type';
        PRINT @DisplayType;
        PRINT 'Question';
        PRINT @QuestionIdList;
		PRINT 'User'
		PRINT @UserId

        DECLARE @AnsStatus NVARCHAR(50) = '' ,
            @TranferFilter BIT = 0 ,
             @ActionFilter INT = 0,
			@isPositive NVARCHAR(50) = '',
			@IsOutStanding BIT = 0;

      IF (@FilterOn = 'Resolved' OR @FilterOn = 'Unresolved')
            BEGIN
                SET @AnsStatus = @FilterOn;
            END;
				ELSE IF @FilterOn = 'Neutral'
		BEGIN
			SET @isPositive = 'Neutral'
		END
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
					ELSE IF @FilterOn = 'Unactioned'
					BEGIN
					SET @ActionFilter = 2;
					END
			ELSE IF @FilterOn = 'OutStanding'
			BEGIN
				SET @IsOutStanding = 1;
			END
			                    
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
        IF @IsOut = 0
            BEGIN
                INSERT  INTO @Result
                        ( Name ,
                          Score ,
                          Counts ,
                          BenchmarkScore ,
                          BenchmarkCounts
                        )
                        SELECT  CASE @Type
                                  WHEN 1 THEN DATEPART(HOUR, CreatedOn)
                                  WHEN 2 THEN DATEPART(DW, CreatedOn)
                                  WHEN 3 THEN DATEPART(DAY, CreatedOn)
                                  ELSE DATEPART(MONTH, CreatedOn)
                                END ,
                                COUNT(AppUserId) AS Detail ,
                                COUNT(AppUserId) AS Total ,
                                0 ,
                                0
                        FROM    ( SELECT    Am.AppUserId ,
                                            Am.CreatedOn
                                  FROM      dbo.View_AnswerMaster AS Am
                                            INNER JOIN ( SELECT
                                                              Data
                                                         FROM dbo.Split(@EstablishmentId,
                                                              ',')
                                                       ) AS RE ON ( RE.Data = Am.EstablishmentId
                                                              OR @EstablishmentId = '0'
                                                              )
                                            INNER JOIN ( SELECT
                                                              Data
                                                         FROM dbo.Split(@UserId,
                                                              ',')
                                                       ) AS RU ON RU.Data = Am.AppUserId
                                                              OR @UserId = '0'
                                  WHERE     Am.ActivityId = @ActivityId
                                            AND Am.QuestionnaireId = @QuestionnaireId
                                            AND ISNULL(Am.IsDisabled, 0) = 0
                                            AND ( IsResolved = @AnsStatus
                                                  OR @AnsStatus = ''
                                                )
                                            AND ( @TranferFilter = 0
                                                  OR Am.IsTransferred = 1
                                                )
                                             AND ( @ActionFilter = 0 
														 OR ((@ActionFilter = 1 AND AM.IsActioned=1) OR (@ActionFilter=2 AND AM.IsActioned = 0 AND AM.IsResolved = 'Unresolved')))
													AND (@isPositive = ''
															OR	AM.IsPositive = @isPositive
													)
											 AND (@IsOutStanding = 0 OR Am.IsOutStanding = 1)
                                            AND CAST(Am.CreatedOn AS DATE) BETWEEN @FromDate
                                                              AND
                                                              @EndDate
                                ) AS AM
                        GROUP BY CASE @Type
                                   WHEN 1 THEN DATEPART(HOUR, CreatedOn)
                                   WHEN 2 THEN DATEPART(DW, CreatedOn)
                                   WHEN 3 THEN DATEPART(DAY, CreatedOn)
                                   ELSE DATEPART(MONTH, CreatedOn)
                                 END;
						/*BenchMark*/
                INSERT  INTO @Result
                        ( Name ,
                          Score ,
                          Counts ,
                          BenchmarkScore ,
                          BenchmarkCounts
                                
                        )
                        SELECT  CASE @Type
                                  WHEN 1 THEN DATEPART(HOUR, CreatedOn)
                                  WHEN 2 THEN DATEPART(DW, CreatedOn)
                                  WHEN 3 THEN DATEPART(DAY, CreatedOn)
                                  ELSE DATEPART(MONTH, CreatedOn)
                                END ,
                                0 ,
                                0 ,
                                COUNT(AppUserId) AS Detail ,
                                COUNT(AppUserId) AS Total
                        FROM    ( SELECT    Am.AppUserId ,
                                            Am.CreatedOn
                                  FROM      dbo.View_AnswerMaster AS Am
                                           INNER JOIN ( SELECT
                                                              Data
                                                              FROM
                                                              dbo.Split(@EstablishmentId,
                                                              ',')
                                                            ) AS RE ON ( RE.Data = Am.EstablishmentId
                                                              OR @EstablishmentId = '0'
                                                              )
                                            --LEFT OUTER JOIN ( SELECT
                                            --                  Data
                                            --                  FROM
                                            --                  dbo.Split(@UserId,
                                            --                  ',')
                                            --                ) AS RU ON RU.Data = Am.AppUserId
                                            --                  OR @UserId = '0'
                                  WHERE     Am.QuestionnaireId = @QuestionnaireId
											AND am.ActivityId = @ActivityId
                                            --AND RE.Data IS NULL
                                            AND ISNULL(Am.IsDisabled, 0) = 0
                                            --AND ( RU.Data IS NULL
                                            --      OR ( RU.Data = 0
                                            --           AND @IsTellUs = 0
                                            --         )
                                            --    )
                                            AND ( IsResolved = @AnsStatus
                                                  OR @AnsStatus = ''
                                                )
                                            AND ( @TranferFilter = 0
                                                  OR Am.IsTransferred = 1
                                                )
                                            AND ( @ActionFilter = 0 
														 OR ((@ActionFilter = 1 AND AM.IsActioned=1) OR (@ActionFilter=2 AND AM.IsActioned = 0 AND AM.IsResolved = 'Unresolved')))
													AND (@isPositive = ''
															OR	AM.IsPositive = @isPositive
													)
													AND (@IsOutStanding = 0 OR Am.IsOutStanding = 1)
                                            AND CAST(Am.CreatedOn AS DATE) BETWEEN @FromDate
                                                              AND
                                                              @EndDate
                                ) AS AM
                        GROUP BY CASE @Type
                                   WHEN 1 THEN DATEPART(HOUR, CreatedOn)
                                   WHEN 2 THEN DATEPART(DW, CreatedOn)
                                   WHEN 3 THEN DATEPART(DAY, CreatedOn)
                                   ELSE DATEPART(MONTH, CreatedOn)
                                 END;
            END;
        ELSE
            BEGIN
			PRINT '======= Out === 1'
                INSERT  INTO @Result
                        ( Name ,
                          Score ,
                          Counts ,
                          BenchmarkScore ,
                          BenchmarkCounts
                        )
                        SELECT  CASE @Type
                                  WHEN 1 THEN DATEPART(HOUR, CreatedOn)
                                  WHEN 2 THEN DATEPART(DW, CreatedOn)
                                  WHEN 3 THEN DATEPART(DAY, CreatedOn)
                                  ELSE DATEPART(MONTH, CreatedOn)
                                END ,
                                COUNT(AppUserId) AS Detail ,
                                COUNT(AppUserId) AS Total ,
                                0 ,
                                0
                        FROM    ( SELECT    Am.AppUserId ,
                                            Am.CreatedOn
                                  FROM      dbo.View_SeenClientAnswerMaster AS Am
                                            INNER JOIN ( SELECT
                                                              Data
                                                         FROM dbo.Split(@EstablishmentId,
                                                              ',')
                                                       ) AS RE ON ( RE.Data = Am.EstablishmentId
                                                              OR @EstablishmentId = '0'
                                                              )
                                            INNER JOIN ( SELECT
                                                              Data
                                                         FROM dbo.Split(@UserId,
                                                              ',')
                                                       ) AS RU ON RU.Data = Am.AppUserId
                                                              OR @UserId = '0'
                                  WHERE     Am.ActivityId = @ActivityId
                                            AND Am.SeenClientId = @SeenClientId
                                            AND ISNULL(Am.IsDisabled, 0) = 0
                                            AND ( IsResolved = @AnsStatus
                                                  OR @AnsStatus = ''
                                                )
                                            AND ( @TranferFilter = 0
                                                  OR Am.IsTransferred = 1
                                                )
                                            AND ( @ActionFilter = 0 
														 OR ((@ActionFilter = 1 AND AM.IsActioned=1) OR (@ActionFilter=2 AND AM.IsActioned = 0 AND AM.IsResolved = 'Unresolved')))
													AND (@isPositive = ''
															OR	AM.IsPositive = @isPositive
													)
													AND (@IsOutStanding = 0 OR Am.IsOutStanding = 1)
                                            AND CAST(Am.CreatedOn AS DATE) BETWEEN @FromDate
                                                              AND
                                                              @EndDate
                                ) AS AM
                        GROUP BY CASE @Type
                                   WHEN 1 THEN DATEPART(HOUR, CreatedOn)
                                   WHEN 2 THEN DATEPART(DW, CreatedOn)
                                   WHEN 3 THEN DATEPART(DAY, CreatedOn)
                                   ELSE DATEPART(MONTH, CreatedOn)
                                 END;
						/*BenchMark*/
                INSERT  INTO @Result
                        ( Name ,
                          Score ,
                          Counts ,
                          BenchmarkScore ,
                          BenchmarkCounts  
                        )
                        SELECT  CASE @Type
                                  WHEN 1 THEN DATEPART(HOUR, CreatedOn)
                                  WHEN 2 THEN DATEPART(DW, CreatedOn)
                                  WHEN 3 THEN DATEPART(DAY, CreatedOn)
                                  ELSE DATEPART(MONTH, CreatedOn)
                                END ,
                                0 ,
                                0 ,
                                COUNT(AppUserId) AS Detail ,
                                COUNT(AppUserId) AS Total
                        FROM    ( SELECT    Am.AppUserId ,
                                            Am.CreatedOn
                                  FROM      dbo.View_SeenClientAnswerMaster AS Am
                                            INNER JOIN ( SELECT
                                                              Data
                                                              FROM
                                                              dbo.Split(@EstablishmentId,
                                                              ',')
                                                            ) AS RE ON ( RE.Data = Am.EstablishmentId
                                                              OR @EstablishmentId = '0'
                                                              )
                                            --LEFT OUTER JOIN ( SELECT
                                            --                  Data
                                            --                  FROM
                                            --                  dbo.Split(@UserId,
                                            --                  ',')
                                            --                ) AS RU ON RU.Data = Am.AppUserId
                                            --                  OR @UserId = '0'
                                  WHERE     Am.SeenClientId = @SeenClientId
											AND am.ActivityId = @ActivityId
                                            AND ISNULL(Am.IsDisabled, 0) = 0
                                            --AND RE.Data IS NULL
                                            --AND ( RU.Data IS NULL
                                            --      OR ( RU.Data = 0
                                            --           AND @IsTellUs = 0
                                            --         )
                                            --    )
											--AND am.AppUserId NOT IN ( SELECT
           --                                                   Data
           --                                                   FROM
           --                                                   dbo.Split(@UserId,
           --                                                   ',')
           --                                                 )
                                            AND ( IsResolved = @AnsStatus
                                                  OR @AnsStatus = ''
                                                )
                                            AND ( @TranferFilter = 0
                                                  OR Am.IsTransferred = 1
                                                )
                                           AND ( @ActionFilter = 0 
														 OR ((@ActionFilter = 1 AND AM.IsActioned=1) OR (@ActionFilter=2 AND AM.IsActioned = 0 AND AM.IsResolved = 'Unresolved')))
													AND (@isPositive = ''
															OR	AM.IsPositive = @isPositive
													)
													AND (@IsOutStanding = 0 OR Am.IsOutStanding = 1)
                                            AND CAST(Am.CreatedOn AS DATE) BETWEEN @FromDate
                                                              AND
                                                              @EndDate
                                ) AS AM
                        GROUP BY CASE @Type
                                   WHEN 1 THEN DATEPART(HOUR, CreatedOn)
                                   WHEN 2 THEN DATEPART(DW, CreatedOn)
                                   WHEN 3 THEN DATEPART(DAY, CreatedOn)
                                   ELSE DATEPART(MONTH, CreatedOn)
                                 END;
            END;
        DECLARE @YScore DECIMAL(18, 2) ,
            @YBScore DECIMAL(18, 2) ,
            @TotalEntry BIGINT ,
            @UserCount DECIMAL(18,2);

        --SELECT  @UserCount = COUNT(DISTINCT AUE.AppUserId)
        --FROM    dbo.Establishment AS E
        --        INNER JOIN dbo.EstablishmentGroup AS Eg ON Eg.Id = E.EstablishmentGroupId
        --        INNER JOIN AppUserEstablishment AS AUE ON AUE.EstablishmentId = E.Id
        --                                                  AND AUE.IsDeleted = 0
        --        LEFT OUTER JOIN ( SELECT    Data
        --                          FROM      dbo.Split(@UserId, ',')
        --                        ) AS RU ON RU.Data = AUE.AppUserId
        --                                   OR @UserId = '0'
        --WHERE   E.IsDeleted = 0
        --        AND Eg.SeenClientId = @SeenClientId;

        IF ( @UserId = '0' )
            BEGIN
                SELECT  @UserCount = COUNT(DISTINCT AUE.AppUserId)
                FROM    dbo.Establishment AS E
                        INNER JOIN dbo.EstablishmentGroup AS Eg ON Eg.Id = E.EstablishmentGroupId
                        INNER JOIN AppUserEstablishment AS AUE ON AUE.EstablishmentId = E.Id
                                                              AND AUE.IsDeleted = 0
                        --LEFT OUTER JOIN ( SELECT    Data
                        --                  FROM      dbo.Split(@UserId, ',')
                        --                ) AS RU ON RU.Data = AUE.AppUserId
                        --                           OR @UserId = '0'
                WHERE   E.IsDeleted = 0
                        AND Eg.SeenClientId = @SeenClientId
                        --AND AUE.AppUserId NOT IN (
                        --SELECT  Data
                        --FROM    dbo.Split(@UserId, ',') );
            END;
        ELSE
            BEGIN

			 SELECT   @UserCount = COUNT(DISTINCT AppUserId) 
                        FROM    ( SELECT    Am.AppUserId ,
                                            Am.CreatedOn
                                  FROM      dbo.View_SeenClientAnswerMaster AS Am
                                            INNER JOIN ( SELECT
                                                              Data
                                                              FROM
                                                              dbo.Split(@EstablishmentId,
                                                              ',')
                                                            ) AS RE ON ( RE.Data = Am.EstablishmentId
                                                              OR @EstablishmentId = '0'
                                                              )
                                            --LEFT OUTER JOIN ( SELECT
                                            --                  Data
                                            --                  FROM
                                            --                  dbo.Split(@UserId,
                                            --                  ',')
                                            --                ) AS RU ON RU.Data = Am.AppUserId
                                            --                  OR @UserId = '0'
                                  WHERE     Am.SeenClientId = @SeenClientId
											AND am.ActivityId = @ActivityId
                                            AND ISNULL(Am.IsDisabled, 0) = 0
                                            --AND RE.Data IS NULL
                                            --AND ( RU.Data IS NULL
                                            --      OR ( RU.Data = 0
                                            --           AND @IsTellUs = 0
                                            --         )
                                            --    )
											--AND am.AppUserId NOT IN ( SELECT
           --                                                   Data
           --                                                   FROM
           --                                                   dbo.Split(@UserId,
           --                                                   ',')
           --                                                 )
                                            AND ( IsResolved = @AnsStatus
                                                  OR @AnsStatus = ''
                                                )
                                            AND ( @TranferFilter = 0
                                                  OR Am.IsTransferred = 1
                                                )
                                           AND ( @ActionFilter = 0 
														 OR ((@ActionFilter = 1 AND AM.IsActioned=1) OR (@ActionFilter=2 AND AM.IsActioned = 0 AND AM.IsResolved = 'Unresolved')))
													AND (@isPositive = ''
															OR	AM.IsPositive = @isPositive
													)
													AND (@IsOutStanding = 0 OR Am.IsOutStanding = 1)
                                            AND CAST(Am.CreatedOn AS DATE) BETWEEN @FromDate
                                                              AND
                                                              @EndDate
                                ) AS AM
                       


                --SELECT  @UserCount = COUNT(DISTINCT AUE.AppUserId)
                --FROM    dbo.Establishment AS E
                --        INNER JOIN dbo.EstablishmentGroup AS Eg ON Eg.Id = E.EstablishmentGroupId
                --        INNER JOIN AppUserEstablishment AS AUE ON AUE.EstablishmentId = E.Id
                --                                              AND AUE.IsDeleted = 0
                --        LEFT OUTER JOIN ( SELECT    Data
                --                          FROM      dbo.Split(@UserId, ',')
                --                        ) AS RU ON RU.Data = AUE.AppUserId
                --                                   OR @UserId = '0'
                --WHERE   E.IsDeleted = 0
                --        AND Eg.SeenClientId = @SeenClientId
                --        AND AUE.AppUserId NOT IN (
                --        --SELECT  AppUserId
                --        --FROM    AppUserEstablishment
                --        --WHERE   EstablishmentId = @EstablishmentId and AUE.AppUserId IN (
                --        SELECT  Data
                --        FROM    dbo.Split(@UserId, ','));
            END;
        SELECT  @YScore = SUM(ISNULL(Counts, 0)) --/ CASE @UserCount WHEN 0 THEN 1 ELSE @UserCount END  --CASE ISNULL((SELECT COUNT(data) FROM dbo.Split(@UserId, ',')),0) WHEN 0 THEN 1 ELSE (SELECT COUNT(data) FROM dbo.Split(@UserId, ',')) END
        FROM    @Result;
		PRINT 'UserCount'
		PRINT @UserCount
        SELECT  @YBScore = SUM(BenchmarkCounts) --/ CASE @UserCount WHEN 0 THEN 1 ELSE @UserCount END 
        FROM    @Result;

        SELECT  @TotalEntry = SUM(ISNULL(Counts, 0))
        FROM    @Result;
		
        SELECT  @MaxRank = ISNULL(MAX(R.Data), 0) + 1
        FROM    ( SELECT    SUM(ISNULL(Counts, 0)) AS Data
                  FROM      @Result
                  GROUP BY  Name
                ) AS R;

        SELECT  [@tblCount].Name ,
                SUM(ISNULL(Score, 0)) AS QScore ,
				SUM(ISNULL(BenchmarkScore, 0)) AS QBenchmarkScore,
                --SUM(ISNULL(BenchmarkScore, 0))
                --/ CASE SUM(ISNULL(BenchmarkCounts, 0))
                --    WHEN 0 THEN 1
                --    ELSE SUM(ISNULL(BenchmarkCounts, 0))
                --  END AS QBenchmarkScore ,
                ISNULL(@YScore, 0) AS YScore ,
                ROUND(ISNULL(@YBScore, 0),0) AS YBScore ,
				ISNULL(@YScore, 0) -  ROUND(ISNULL(@YBScore, 0),0) AS Performance,
                --( ISNULL(@YScore, 0) - ISNULL(@YBScore, 0) )
                --/ CASE ISNULL(@YScore, 0)
                --    WHEN 0 THEN 1
                --    ELSE ISNULL(@YScore, 0)
                --  END * 100 AS Performance ,
                ISNULL(@TotalEntry, 0) AS TotalEntry ,
                CASE @Type
                  WHEN 2
                  THEN CONVERT(VARCHAR(1), DATENAME(DW, [@tblCount].Name - 2))
                  ELSE CONVERT(VARCHAR(5), [@tblCount].Name)
                END AS DisplayName ,
                @MinRank AS MinRank ,
                @MaxRank AS MaxRank ,
                @LocalTime AS LastUpdatedTime ,
                @FromDate AS StartDate ,
                @EndDate AS EndDate ,
                ISNULL(@DisplayType,0) AS DisplayType
        FROM    @tblCount
                LEFT OUTER JOIN @Result ON [@tblCount].Name = [@Result].Name
        GROUP BY [@tblCount].Name
        ORDER BY [@tblCount].Name;         
		
		  
    END;
