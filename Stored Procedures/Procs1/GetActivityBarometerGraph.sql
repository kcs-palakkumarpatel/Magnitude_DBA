-- =============================================
-- Author:			D3
-- Create date:	05-Jan-2018
-- Description:	
-- Call SP:			dbo.GetActivityBarometerGraph
-- =============================================
CREATE PROCEDURE [dbo].[GetActivityBarometerGraph]
     (
      @AppUserId BIGINT ,
      @ActivityId BIGINT ,
      @EstablishmentId NVARCHAR(MAX) ,
      @UserId NVARCHAR(MAX) ,
	  @FromDate DATETIME,
	  @ToDate DATETIME,
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
      @FilterOn NVARCHAR(Max) ,
      @AnswerMaster BIGINT = 0
    )
AS
  BEGIN
   SET  NOCOUNT  OFF;

	  DECLARE @listStr NVARCHAR(MAX), @SelectUserId VARCHAR(20) = '';
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
		SET @SelectUserId = '0';
            SET @UserId = ( SELECT  dbo.AllUserSelected_Graph(@AppuserId, @EstablishmentId, @ActivityId) );
        END;

        DECLARE @Result TABLE
            (
              Name VARCHAR(255) NULL ,
              Score BIGINT NULL ,
              Counts BIGINT NOT NULL ,
              BenchmarkScore BIGINT NULL ,
              BenchmarkCounts BIGINT  NULL
            );

        DECLARE @End BIGINT ,
            @Start BIGINT = 1;

	---# For Changes Graph Category.
	DECLARE @EndDate DATETIME , @LocalTime DATETIME, @DaysDiff INT = 0, @CategoryType INT = 1;
  --   SET @DaysDiff = DATEDIFF(DAY, @FromDate, @ToDate);
	 --IF @DaysDiff > 0
	 --BEGIN
	 --    SET @CategoryType = 1;
	 --END;

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

        DECLARE @AnsStatus NVARCHAR(50) = '' ,
            @TranferFilter BIT = 0 ,
             @ActionFilter INT = 0,
			@isPositive NVARCHAR(50) = '',
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

	DECLARE @QuestionSearchTable AS TABLE
			(
				ReportId BIGINT
			)

		IF (@FilterOn <> '')
			BEGIN
			INSERT INTO @QuestionSearchTable
			        ( ReportId )
			EXEC dbo.QustionSearchForFilter @EstablishmentId,@FilterOn,@IsOut
			END
            ELSE
			BEGIN
			 INSERT @QuestionSearchTable
			         ( ReportId )
			 VALUES  ( 0  -- ReportId - bigint
			           )
            END

        IF @IsOut = 0
            BEGIN
					INSERT INTO @Result
					        ( 
					          Name ,
					          Score ,
					          Counts ,
					          BenchmarkScore ,
					          BenchmarkCounts
					        )
                        SELECT  
								CASE @CategoryType WHEN 1
                                           THEN CONVERT(VARCHAR(10), CreatedOn, 105)
                                           ELSE CONVERT(VARCHAR(14), CreatedOn, 120) + '00:00'
                                         END ,
                                COUNT(AppUserId) AS Detail ,
                                COUNT(AppUserId) AS Total ,
                                0 ,
                                0
                        FROM    ( SELECT    Am.AppUserId ,
                                            Am.CreatedOn
                                  FROM      dbo.View_AnswerMaster AS Am
								  INNER JOIN @QuestionSearchTable QS ON (QS.ReportId = Am.ReportId OR QS.ReportId = 0)
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
											AND CAST(Am.CreatedOn AS DATE) BETWEEN CAST(@FromDate AS DATE) AND CAST(@ToDate AS DATE)
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
                                ) AS AM
                         GROUP BY  CASE @CategoryType
                                   WHEN 1 THEN CONVERT(VARCHAR(10), CreatedOn, 105)
                                   ELSE CONVERT(VARCHAR(14), CreatedOn, 120) + '00:00'
                                   END

						/*BenchMark*/
               INSERT INTO @Result
					        ( 
					          Name ,
					          Score ,
					          Counts ,
					          BenchmarkScore ,
					          BenchmarkCounts
					        )
                        SELECT  CASE @CategoryType WHEN 1
                                           THEN CONVERT(VARCHAR(10), CreatedOn, 105)
                                           ELSE CONVERT(VARCHAR(14), CreatedOn, 120) + '00:00'
                                         END ,
                                0 ,
                                0 ,
                                COUNT(AppUserId) AS Detail ,
                                COUNT(AppUserId) AS Total
                        FROM    ( SELECT    Am.AppUserId ,
                                            Am.CreatedOn
                                  FROM      dbo.View_AnswerMaster AS Am
								  INNER JOIN @QuestionSearchTable QS ON (QS.ReportId = Am.ReportId OR QS.ReportId = 0)
                                           --INNER JOIN ( SELECT Data FROM dbo.Split(@EstablishmentId, ',') ) AS RE ON ( RE.Data = Am.EstablishmentId OR @EstablishmentId = '0' )
                                  WHERE     Am.QuestionnaireId = @QuestionnaireId
											AND am.ActivityId = @ActivityId
                                            AND ISNULL(Am.IsDisabled, 0) = 0
											AND CAST(Am.CreatedOn AS DATE) BETWEEN CAST(@FromDate AS DATE) AND CAST(@ToDate AS DATE)
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
                                ) AS AM
								GROUP BY  CASE @CategoryType
                                          WHEN 1 THEN CONVERT(VARCHAR(10), CreatedOn, 105)
                                          ELSE CONVERT(VARCHAR(14), CreatedOn, 120) + '00:00'
                                          END
            END;
        ELSE
            BEGIN
                INSERT INTO @Result
					        ( 
					          Name ,
					          Score ,
					          Counts ,
					          BenchmarkScore ,
					          BenchmarkCounts
					        )
                        SELECT  
										CASE @CategoryType WHEN 1
                                           THEN CONVERT(VARCHAR(10), CreatedOn, 105)
                                           ELSE CONVERT(VARCHAR(14), CreatedOn, 120) + '00:00'
                                         END ,
                                COUNT(AppUserId) AS Detail ,
                                COUNT(AppUserId) AS Total ,
                                0 ,
                                0
                        FROM    ( SELECT    Am.AppUserId ,
                                            Am.CreatedOn
                                  FROM      dbo.View_SeenClientAnswerMaster AS Am
								  INNER JOIN @QuestionSearchTable QS ON (QS.ReportId = Am.ReportId OR QS.ReportId = 0)
                                            INNER JOIN ( SELECT Data FROM dbo.Split(@EstablishmentId, ',') ) AS RE ON ( RE.Data = Am.EstablishmentId OR @EstablishmentId = '0' )
                                            INNER JOIN ( SELECT Data FROM dbo.Split(@UserId, ',') ) AS RU ON RU.Data = Am.AppUserId OR @UserId = '0'
                                  WHERE     Am.ActivityId = @ActivityId
                                            AND Am.SeenClientId = @SeenClientId
                                            AND ISNULL(Am.IsDisabled, 0) = 0
											AND CAST(Am.CreatedOn AS DATE) BETWEEN CAST(@FromDate AS DATE) AND CAST(@ToDate AS DATE)
                                            AND ( IsResolved = @AnsStatus OR @AnsStatus = '' )
                                            AND ( @TranferFilter = 0 OR Am.IsTransferred = 1 )
                                            AND ( @ActionFilter = 0 OR ((@ActionFilter = 1 AND AM.IsActioned=1) OR (@ActionFilter=2 AND AM.IsActioned = 0 AND AM.IsResolved = 'Unresolved')))
											AND (@isPositive = ''OR	AM.IsPositive = @isPositive )
											AND (@IsOutStanding = 0 OR Am.IsOutStanding = 1)
                                ) AS AM
								GROUP BY CASE @CategoryType WHEN 1
                                           THEN CONVERT(VARCHAR(10), CreatedOn, 105)
                                           ELSE CONVERT(VARCHAR(14), CreatedOn, 120) + '00:00'
                                         END

						/*BenchMark*/
                 INSERT INTO @Result
					        ( 
					          Name ,
					          Score ,
					          Counts ,
					          BenchmarkScore ,
					          BenchmarkCounts
					        )
                        SELECT  
								 CASE @CategoryType WHEN 1
                                           THEN CONVERT(VARCHAR(10), CreatedOn, 105)
                                           ELSE CONVERT(VARCHAR(14), CreatedOn, 120) + '00:00'
                                         END ,
                                0 ,
                                0 ,
                                COUNT(AppUserId) AS Detail ,
                                COUNT(AppUserId) AS Total
                        FROM    ( SELECT    Am.AppUserId ,
                                            Am.CreatedOn
                                  FROM      dbo.View_SeenClientAnswerMaster AS Am
								  INNER JOIN @QuestionSearchTable QS ON (QS.ReportId = Am.ReportId OR QS.ReportId = 0)
                                            --INNER JOIN ( SELECT Data FROM dbo.Split(@EstablishmentId, ',') ) AS RE ON ( RE.Data = Am.EstablishmentId OR @EstablishmentId = '0' )
                                  WHERE     Am.SeenClientId = @SeenClientId
											AND am.ActivityId = @ActivityId
                                            AND ISNULL(Am.IsDisabled, 0) = 0
											AND CAST(Am.CreatedOn AS DATE) BETWEEN CAST(@FromDate AS DATE) AND CAST(@ToDate AS DATE)
                                            AND ( IsResolved = @AnsStatus OR @AnsStatus = '' ) 
                                            AND ( @TranferFilter = 0 OR Am.IsTransferred = 1 )
                                           AND ( @ActionFilter = 0 OR ((@ActionFilter = 1 AND AM.IsActioned=1) OR (@ActionFilter=2 AND AM.IsActioned = 0 AND AM.IsResolved = 'Unresolved')))
											AND (@isPositive = ''OR	AM.IsPositive = @isPositive )
											AND (@IsOutStanding = 0 OR Am.IsOutStanding = 1)
                                ) AS AM
								GROUP BY CASE @CategoryType WHEN 1
                                           THEN CONVERT(VARCHAR(10), CreatedOn, 105)
                                           ELSE CONVERT(VARCHAR(14), CreatedOn, 120) + '00:00'
                                         END

            END;
        DECLARE @YScore DECIMAL(18, 2) ,
            @YBScore DECIMAL(18, 2) ,
            @TotalEntry BIGINT ,
            @UserCount DECIMAL(18, 2);

        IF ( @UserId = '0' )
            BEGIN
                IF @ActivityType != 'Customer'
                BEGIN
                    SELECT  @UserCount = COUNT(DISTINCT AUE.AppUserId)
                FROM    dbo.Establishment AS E
                        INNER JOIN dbo.EstablishmentGroup AS Eg ON Eg.Id = E.EstablishmentGroupId
                        INNER JOIN AppUserEstablishment AS AUE ON AUE.EstablishmentId = E.Id AND AUE.IsDeleted = 0
                WHERE   E.IsDeleted = 0
                        AND Eg.SeenClientId = @SeenClientId
                END
				ELSE
				BEGIN
				    SELECT  @UserCount = COUNT(DISTINCT AUE.AppUserId)
                FROM    dbo.Establishment AS E
                        INNER JOIN dbo.EstablishmentGroup AS Eg ON Eg.Id = E.EstablishmentGroupId
                        INNER JOIN AppUserEstablishment AS AUE ON AUE.EstablishmentId = E.Id AND AUE.IsDeleted = 0
                WHERE   E.IsDeleted = 0
                         AND Eg.QuestionnaireId = @QuestionnaireId
				END
            END;
        ELSE
            BEGIN
			 SELECT   @UserCount = COUNT(DISTINCT AppUserId) 
                        FROM    ( SELECT    Am.AppUserId ,
                                            Am.CreatedOn
                                  FROM      dbo.View_SeenClientAnswerMaster AS Am
                                            INNER JOIN ( SELECT Data FROM dbo.Split(@EstablishmentId, ',') ) AS RE ON ( RE.Data = Am.EstablishmentId OR @EstablishmentId = '0' )
                                  WHERE     Am.SeenClientId = @SeenClientId
											AND am.ActivityId = @ActivityId
                                            AND ISNULL(Am.IsDisabled, 0) = 0
											AND CAST(Am.CreatedOn AS DATE) BETWEEN CAST(@FromDate AS DATE) AND CAST(@ToDate AS DATE)
                                            AND ( IsResolved = @AnsStatus OR @AnsStatus = '' )
                                            AND ( @TranferFilter = 0 OR Am.IsTransferred = 1 )
                                           AND ( @ActionFilter = 0 OR ((@ActionFilter = 1 AND AM.IsActioned=1) OR (@ActionFilter=2 AND AM.IsActioned = 0 AND AM.IsResolved = 'Unresolved')))
											AND (@isPositive = '' OR	AM.IsPositive = @isPositive )
											AND (@IsOutStanding = 0 OR Am.IsOutStanding = 1)
                                ) AS AM
            END;

        SELECT  @YScore = SUM(ISNULL(Counts, 0)) FROM    @Result;
		
        SELECT  @YBScore = SUM(BenchmarkCounts) FROM    @Result;

        SELECT  @TotalEntry = SUM(ISNULL(Counts, 0)) FROM    @Result;
		
        SELECT  @MaxRank = ISNULL(MAX(R.Data), 0) + 1
        FROM    ( SELECT    SUM(ISNULL(Counts, 0)) AS Data FROM      @Result GROUP BY  Name ) AS R;
		
		DECLARE @SelectedUserCount DECIMAL(18,2) = 0.00;

		IF ( @SelectUserId = '0' )
		BEGIN
		    SET  @SelectedUserCount = 1;
			SET  @UserCount = 1;
		END
		ELSE
		BEGIN
		    SELECT @SelectedUserCount = COUNT(Data) FROM dbo.Split(@UserId, ',')
		END
		
		--SELECT @SelectedUserCount AS SelectedUserCount;
		--SELECT @UserCount AS AllUserCount;

SELECT	ISNULL(Name, '') AS xAxisValue,
		          CAST(ROUND((SUM(ISNULL(Score, 0)) ) ,0) AS BIGINT) AS UserScore,
				  CAST(ROUND((SUM(ISNULL(BenchmarkScore, 0))), 0) AS BIGINT)  AS UserBenchmarkScore ,
		          ISNULL(@YScore, 0) AS EveryoneScore ,
		          ISNULL(@YBScore, 0) AS EveryoneBenchmarkScore ,
		          SUM(ISNULL(BenchmarkCounts, 0)) AS BenchmarkCounts,
				  ISNULL(@YScore -  @YBScore, 0) AS Performance,
				  ISNULL(@TotalEntry, 0) AS TotalEntry ,
				  ISNULL(@MinRank, 0) AS MinRank ,
                  ISNULL(@MaxRank, 0)  AS MaxRank ,
                  ISNULL(@LocalTime, GETUTCDATE()) AS LastUpdatedTime
				  FROM @Result
				  GROUP BY ISNULL(Name, '')
		  
    END;

