-- =============================================
-- Author:			D#3
-- Create date:	19-Feb-2018
-- Description:	
-- Call SP:			dbo.GetItemViewPerformanceIndexGraph 1243,1941,'0','0','19 Jan 2018','20 Feb 2018',1,0,'All','All','','','',0,0,0,0,0,null,0
-- =============================================
CREATE PROCEDURE [dbo].[GetItemViewPerformanceIndexGraph]
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
      @AnswerMaster BIGINT = 0
    )
AS
   BEGIN

DECLARE @listStr NVARCHAR(MAX), @ActivityType NVARCHAR(50);
DECLARE @Result AS TABLE (
      Displayname VARCHAR(100) NOT NULL ,
      Score DECIMAL(18, 2) NOT NULL ,
      Counts BIGINT NOT NULL ,
      BenchmarkScore DECIMAL(18, 2) NOT NULL ,
      BenchmarkCounts BIGINT NOT NULL ,
      TotalEntry BIGINT NOT NULL,
	  DisplayDateTime DATETIME NOT NULL
    );

        IF ( @EstablishmentId = '0' )
        BEGIN
            SET @EstablishmentId = ( SELECT dbo.AllEstablishmentByAppUserAndActivity(@AppuserId, @ActivityId) );
        END;
      
SELECT   @ActivityType = EstablishmentGroupType  FROM     dbo.EstablishmentGroup WITH(NOLOCK) WHERE    Id = @ActivityId; 
       
IF ( @UserId = '0' AND @ActivityType != 'Customer' )
        BEGIN
            SET @UserId = ( SELECT  dbo.AllUserSelected(@AppuserId, @EstablishmentId, @ActivityId) );
        END
ELSE IF (@UserId = '0' AND @ActivityType = 'Customer')
		BEGIN
		DECLARE @NewUser NVARCHAR(max);
			SELECT @NewUser = COALESCE(@NewUser+',' ,'') + CONVERT(VARCHAR(10), AppUserId) FROM dbo.AppUserEstablishment WITH(NOLOCK) WHERE EstablishmentId IN (SELECT data FROM dbo.Split(@EstablishmentId,','))
			SET @UserId = @NewUser
		END

DECLARE @EndDate DATETIME, @LocalTime DATETIME;


        DECLARE @CompareWithIndustry BIT = 1 ,
            @FixedBenchmark DECIMAL(18, 2)= 0;

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
                @IsTellUs = CASE WHEN E.EstablishmentGroupId IS NULL AND Eg.EstablishmentGroupType = 'Customer' THEN 1 ELSE 0 END
        FROM    dbo.EstablishmentGroup AS Eg WITH(NOLOCK)
                INNER JOIN dbo.Establishment AS E WITH(NOLOCK) ON Eg.Id = E.EstablishmentGroupId
        WHERE   Eg.Id = @ActivityId
                AND E.IsDeleted = 0;

SELECT @LocalTime = DATEADD(MINUTE, @TimeOffSet, GETUTCDATE());

        IF @IsOut = 0
            BEGIN
                SELECT  @MinRank = MinRank ,
                        @MaxRank = MaxRank ,
                        @DisplayType = DisplayType ,
                        @QuestionIdList = QuestionId
                FROM    dbo.ReportSetting WITH(NOLOCK)
                WHERE   QuestionnaireId = @QuestionnaireId
                        AND ReportType = 'Analysis';

                SELECT  @FixedBenchmark = FixedBenchMark ,
                        @CompareWithIndustry = CASE CompareType
                                                 WHEN 2 THEN 0
                                                 ELSE 1
                                               END
                FROM    dbo.Questionnaire WITH(NOLOCK)
                WHERE   CompareType = 2
                        AND Id = @QuestionnaireId;
            END
        ELSE
            BEGIN
                SELECT  @MinRank = MinRank ,
                        @MaxRank = MaxRank ,
                        @DisplayType = DisplayType ,
                        @QuestionIdList = QuestionId
                FROM    dbo.ReportSetting WITH(NOLOCK)
                WHERE   SeenClientId = @SeenClientId
                        AND ReportType = 'Analysis';

                SELECT  @FixedBenchmark = FixedBenchMark ,
                        @CompareWithIndustry = CASE CompareType
                                                 WHEN 2 THEN 0
                                                 ELSE 1
                                               END
                FROM    dbo.SeenClient WITH(NOLOCK)
                WHERE   CompareType = 2
                        AND Id = @SeenClientId;
            END;

DECLARE @AnsStatus NVARCHAR(50) = '' , @TranferFilter BIT = 0 , @ActionFilter INT = 0 , @isPositive NVARCHAR(50) = '' , @IsOutStanding BIT = 0;
IF (@FormStatus = 'Resolved'
    OR @FormStatus = 'Unresolved' ) BEGIN
SET @AnsStatus = @FormStatus;

END;

ELSE IF @FilterOn = 'Neutral' BEGIN
SET @isPositive = 'Neutral';

END;

IF @isTransfer = 1 BEGIN
SET @TranferFilter = 1;

END;

IF @isAction = 'Action' BEGIN
SET @ActionFilter = 1;

END;

ELSE IF @isAction = 'UnAction' BEGIN
SET @ActionFilter = 2;

END;

IF @ReadUnread = 'Unread' BEGIN
SET @IsOutStanding = 1;

END;

ELSE IF @ReadUnread = 'Read' BEGIN
SET @IsOutStanding = 0;
END;

SET @FromDate = CONVERT(DATE, @FromDate);
SET @EndDate = CONVERT(DATE, @ToDate);

        IF @DisplayType = 0
            BEGIN
                IF @IsOut = 0
                    BEGIN
/*--------------------------------------------In Type---------------------------------------------------*/
                        INSERT INTO @Result
                                ( Displayname ,
                                  Score ,
                                  Counts ,
                                  BenchmarkScore ,
                                  BenchmarkCounts ,
                                  TotalEntry ,
                                  DisplayDateTime
                                )
                              SELECT 
										T.CreatedOn, 
										AVG(T.Detail),
                                        COUNT(DISTINCT T.Id) AS Total ,
                                        0,
                                        0,
										0 ,
										T.CreatedOnDate
							 FROM (
							    SELECT  CONVERT(VARCHAR(9), AM.CreatedOn, 6) AS CreatedOn ,
                                        ((SUM(AM.[Weight]) * 100 ) / CASE SUM(AM.MaxWeight) WHEN  0 THEN 1 ELSE SUM(AM.MaxWeight) END) AS Detail ,
										AM.Id AS Id,
										AM.CreatedOn AS CreatedOnDate
                                FROM    ( SELECT    AM.CreatedOn ,
                                                    AVG(A.[Weight]) AS [Weight] ,
                                                    AM.ReportId AS Id,
                                                    CASE AVG(A.[Weight]) WHEN 0 THEN 0 ELSE Q.MaxWeight END AS MaxWeight
                                          FROM      dbo.View_AnswerMaster AS AM
                                                    INNER JOIN dbo.Answers AS A WITH(NOLOCK) ON AM.ReportId = A.AnswerMasterId
                                                    INNER JOIN dbo.Questions Q WITH(NOLOCK) ON A.QuestionId = Q.Id
                                                    INNER JOIN ( SELECT Data FROM dbo.Split(@EstablishmentId, ',') ) AS RE ON ( RE.Data = AM.EstablishmentId OR @EstablishmentId = '0' )
                                                    INNER JOIN ( SELECT Data FROM dbo.Split(@UserId, ',') ) AS RU ON RU.Data = AM.AppUserId OR @UserId = '0' 
                                          WHERE     Q.QuestionTypeId IN ( 1, 5, 6, 7, 18, 21 )
                                                    AND Q.DisplayInGraphs = 1
                                                    AND AM.ActivityId = @ActivityId
                                                    AND AM.QuestionnaireId = @QuestionnaireId
                                                    AND ISNULL(AM.IsDisabled, 0) = 0
                                                    AND ( IsResolved = @AnsStatus OR @AnsStatus = '' ) 
                                                    AND ( @TranferFilter = 0 OR AM.IsTransferred = 1 ) 
                                                    AND ( @ActionFilter = 0 OR ( ( @ActionFilter = 1 AND AM.IsActioned = 1 ) OR ( @ActionFilter = 2 AND AM.IsActioned = 0 AND AM.IsResolved = 'Unresolved' ) ) )
                                                    AND ( @isPositive = '' OR AM.IsPositive = @isPositive )
                                                    AND ( @IsOutStanding = 0 OR AM.IsOutStanding = 1 )
                                                    AND CAST(AM.CreatedOn AS DATE) BETWEEN @FromDate AND @EndDate
                                        GROUP BY   AM.CreatedOn , AM.ReportId, Q.MaxWeight
                                        ) AS AM
                                GROUP BY 	  CONVERT(VARCHAR(9), AM.CreatedOn, 6) , AM.Id , AM.CreatedOn
										   ) AS T GROUP BY  T.CreatedOn , T.CreatedOnDate

/*--------------------------------------------BenchMark---------------------------------------------------*/
				IF ( @CompareWithIndustry = 1 )
					BEGIN
                               INSERT INTO @Result
                                ( Displayname ,
                                  Score ,
                                  Counts ,
                                  BenchmarkScore ,
                                  BenchmarkCounts ,
                                  TotalEntry ,
                                  DisplayDateTime
                                ) SELECT  CONVERT(VARCHAR(9), AM.CreatedOn, 6),
                                                0 ,
                                                0 ,
                                                SUM(AM.QPI) AS Detail ,
                                                COUNT(DISTINCT AM.Id) AS Total,
												0,
												AM.CreatedOn
                                        FROM    ( SELECT    AM.CreatedOn ,
                                                            A.QPI ,
                                                            A.Id
                                                  FROM  dbo.View_AnswerMaster AS AM
                                                            INNER JOIN dbo.Answers AS A WITH(NOLOCK) ON AM.ReportId = A.AnswerMasterId
                                                            INNER JOIN dbo.Questions Q WITH(NOLOCK) ON A.QuestionId = Q.Id
                                                            INNER JOIN ( SELECT Data FROM dbo.Split(@EstablishmentId, ',') ) AS RE ON ( RE.Data = AM.EstablishmentId OR @EstablishmentId = '0' )
                                                  WHERE     Q.QuestionTypeId IN ( 1, 5, 6, 7, 18, 21 )
                                                            AND Q.DisplayInGraphs = 1
                                                            AND AM.QuestionnaireId = @QuestionnaireId
                                                            AND RE.Data IS NULL
                                                           AND ISNULL(AM.IsDisabled, 0) = 0
                                                    AND ( IsResolved = @AnsStatus OR @AnsStatus = '' ) 
                                                    AND ( @TranferFilter = 0 OR AM.IsTransferred = 1 ) 
                                                    AND ( @ActionFilter = 0 OR ( ( @ActionFilter = 1 AND AM.IsActioned = 1 ) OR ( @ActionFilter = 2 AND AM.IsActioned = 0 AND AM.IsResolved = 'Unresolved' ) ) )
                                                    AND ( @isPositive = '' OR AM.IsPositive = @isPositive )
                                                    AND ( @IsOutStanding = 0 OR AM.IsOutStanding = 1 )
                                                    AND CAST(AM.CreatedOn AS DATE) BETWEEN @FromDate AND @EndDate
                                                ) AS AM
                                        GROUP BY CONVERT(VARCHAR(9), AM.CreatedOn, 6) , AM.CreatedOn;
				END
			ELSE
				BEGIN
                                 INSERT INTO @Result
                                ( Displayname ,
                                  Score ,
                                  Counts ,
                                  BenchmarkScore ,
                                  BenchmarkCounts ,
                                  TotalEntry ,
                                  DisplayDateTime
                                ) SELECT  
												CONVERT(VARCHAR(9), AM.CreatedOn, 6), 
												0, 
												0, 
												@FixedBenchmark,
												1,
												0,
												AM.CreatedOn
                                        FROM    ( SELECT    AM.CreatedOn ,
                                                            A.QPI ,
                                                            A.Id
                                                  FROM  dbo.View_AnswerMaster AS AM
                                                            INNER JOIN dbo.Answers AS A WITH(NOLOCK) ON AM.ReportId = A.AnswerMasterId
                                                            INNER JOIN dbo.Questions Q WITH(NOLOCK) ON A.QuestionId = Q.Id
                                                            INNER JOIN ( SELECT Data FROM dbo.Split(@EstablishmentId, ',') ) AS RE ON (RE.Data = AM.EstablishmentId OR @EstablishmentId = '0')
                                                            INNER JOIN ( SELECT Data FROM dbo.Split(@UserId, ',') ) AS RU ON (RU.Data = AM.AppUserId OR @UserId = '0' )
                                                   WHERE     Q.QuestionTypeId IN ( 1, 5, 6, 7, 18, 21 )
                                                            AND Q.DisplayInGraphs = 1
                                                            AND AM.QuestionnaireId = @QuestionnaireId
                                                            AND RE.Data IS NULL
                                                           AND ISNULL(AM.IsDisabled, 0) = 0
                                                    AND ( IsResolved = @AnsStatus OR @AnsStatus = '' ) 
                                                    AND ( @TranferFilter = 0 OR AM.IsTransferred = 1 ) 
                                                    AND ( @ActionFilter = 0 OR ( ( @ActionFilter = 1 AND AM.IsActioned = 1 ) OR ( @ActionFilter = 2 AND AM.IsActioned = 0 AND AM.IsResolved = 'Unresolved' ) ) )
                                                    AND ( @isPositive = '' OR AM.IsPositive = @isPositive )
                                                    AND ( @IsOutStanding = 0 OR AM.IsOutStanding = 1 )
                                                    AND CAST(AM.CreatedOn AS DATE) BETWEEN @FromDate AND @EndDate
                                                ) AS AM
                                        GROUP BY CONVERT(VARCHAR(9), AM.CreatedOn, 6) , AM.CreatedOn
				END;
	END
ELSE
	BEGIN
/*--------------------------------------------Seenclient Out Type---------------------------------------------------*/
                        INSERT INTO @Result
                                ( Displayname ,
                                  Score ,
                                  Counts ,
                                  BenchmarkScore ,
                                  BenchmarkCounts ,
                                  TotalEntry ,
                                  DisplayDateTime
                                )
						SELECT	T.CreatedOn, 
										AVG(T.Detail),
                                        COUNT(DISTINCT T.Id) AS Total ,
                                        0 BenchmarkScore ,
                                        0 BenchmarkCounts,
                                        0,
										T.DisplayDate
							 FROM (
							    SELECT  CONVERT(VARCHAR(9), AM.CreatedOn, 6) AS CreatedOn ,
                                        ( SUM([AM].[Weight]) * 100 ) / CASE SUM(MaxWeight) WHEN 0 THEN 1 ELSE SUM(MaxWeight) END AS Detail ,
                                        COUNT(DISTINCT AM.Id) AS Total ,
										AM.Id,
										AM.CreatedOn AS DisplayDate
                                FROM ( 
											SELECT 
													AM.CreatedOn ,
                                                    AVG(A.[Weight]) AS [Weight] ,
                                                    AM.ReportId AS Id ,
                                                    CASE AVG(A.[Weight]) WHEN 0 THEN 0 ELSE Q.MaxWeight END AS MaxWeight
                                          FROM      dbo.View_SeenClientAnswerMaster AS AM
                                                    INNER JOIN dbo.SeenClientAnswers AS A WITH(NOLOCK) ON AM.ReportId = A.SeenClientAnswerMasterId
                                                    INNER JOIN dbo.SeenClientQuestions Q WITH(NOLOCK) ON A.QuestionId = Q.Id
													INNER JOIN ( SELECT Data FROM dbo.Split(@EstablishmentId, ',') ) AS RE ON (RE.Data = AM.EstablishmentId OR @EstablishmentId = '0')
                                                    INNER JOIN ( SELECT Data FROM dbo.Split(@UserId, ',') ) AS RU ON (RU.Data = AM.AppUserId OR @UserId = '0' )
											WHERE     Q.QuestionTypeId IN ( 1, 5,6, 7, 18, 21 )
                                                    AND Q.DisplayInGraphs = 1
                                                    AND AM.ActivityId = @ActivityId
                                                    AND AM.SeenClientId = @SeenClientId
													AND ISNULL(AM.IsDisabled, 0) = 0
                                                    AND ( IsResolved = @AnsStatus OR @AnsStatus = '' ) 
                                                    AND ( @TranferFilter = 0 OR AM.IsTransferred = 1 ) 
                                                    AND ( @ActionFilter = 0 OR ( ( @ActionFilter = 1 AND AM.IsActioned = 1 ) OR ( @ActionFilter = 2 AND AM.IsActioned = 0 AND AM.IsResolved = 'Unresolved' ) ) )
                                                    AND ( @isPositive = '' OR AM.IsPositive = @isPositive )
                                                    AND ( @IsOutStanding = 0 OR AM.IsOutStanding = 1 )
                                                    AND CAST(AM.CreatedOn AS DATE) BETWEEN @FromDate AND @EndDate
                                          GROUP BY   AM.CreatedOn , AM.ReportId, Q.MaxWeight
                                        ) AS AM
                                GROUP BY  CONVERT(VARCHAR(9), AM.CreatedOn, 6) , AM.Id , AM.CreatedOn
								) AS T GROUP BY  T.CreatedOn , T.DisplayDate
 
/*--------------------------------------------BenchMark---------------------------------------------------*/
				IF ( @CompareWithIndustry = 1 )
					BEGIN
                               INSERT INTO @Result
                                ( Displayname ,
                                  Score ,
                                  Counts ,
                                  BenchmarkScore ,
                                  BenchmarkCounts ,
                                  TotalEntry ,
                                  DisplayDateTime
                                ) SELECT  CONVERT(VARCHAR(9), AM.CreatedOn, 6),
										0,
										COUNT(DISTINCT AM.Id) ,
										AVG(AM.Weight),
                                        ( SUM(Weight) * 100 ) /CASE SUM(ISNULL(AM.MaxWeight,0)) WHEN 0 THEN 1 ELSE SUM(ISNULL(AM.MaxWeight,0)) END AS Detail ,
                                        0,
                                        AM.CreatedOn
								FROM (
                                        SELECT     AM.CreatedOn , 
													AVG(ISNULL(A.[Weight], 0)) AS [Weight] ,
                                                    AM.ReportId AS Id ,
                                                    CASE AVG(A.Weight) WHEN 0 THEN 0 ELSE Q.MaxWeight END AS MaxWeight
                                                  FROM      dbo.View_SeenClientAnswerMaster
                                                            AS AM
                                                            INNER JOIN dbo.SeenClientAnswers 
                                                            AS A WITH(NOLOCK) ON AM.ReportId = A.SeenClientAnswerMasterId
                                                            INNER JOIN dbo.SeenClientQuestions Q WITH(NOLOCK) ON A.QuestionId = Q.Id
                                                            INNER JOIN ( SELECT Data FROM dbo.Split(@EstablishmentId, ',') ) AS RE ON ( RE.Data = AM.EstablishmentId OR @EstablishmentId = '0' )
                                                  WHERE     Q.QuestionTypeId IN ( 1, 5, 6, 7, 18, 21 )
                                                            AND Q.DisplayInGraphs = 1
                                                            AND AM.SeenClientId = @SeenClientId
                                                            AND RE.Data IS NULL
                                                           AND ISNULL(AM.IsDisabled, 0) = 0
                                                    AND ( IsResolved = @AnsStatus OR @AnsStatus = '' ) 
                                                    AND ( @TranferFilter = 0 OR AM.IsTransferred = 1 ) 
                                                    AND ( @ActionFilter = 0 OR ( ( @ActionFilter = 1 AND AM.IsActioned = 1 ) OR ( @ActionFilter = 2 AND AM.IsActioned = 0 AND AM.IsResolved = 'Unresolved' ) ) )
                                                    AND ( @isPositive = '' OR AM.IsPositive = @isPositive )
                                                    AND ( @IsOutStanding = 0 OR AM.IsOutStanding = 1 )
                                                    AND CAST(AM.CreatedOn AS DATE) BETWEEN @FromDate AND @EndDate
													GROUP BY AM.CreatedOn , AM.ReportId, Q.MaxWeight
                                                ) AS AM
                                        GROUP BY CONVERT(VARCHAR(9), AM.CreatedOn, 6) , AM.CreatedOn;
				END
			ELSE
				BEGIN
                                 INSERT INTO @Result
                                ( Displayname ,
                                  Score ,
                                  Counts ,
                                  BenchmarkScore ,
                                  BenchmarkCounts ,
                                  TotalEntry ,
                                  DisplayDateTime
                                ) SELECT  
												CONVERT(VARCHAR(9), AM.CreatedOn, 6), 
												0, 
												0, 
												@FixedBenchmark,
												1,
												0,
												AM.CreatedOn
                                        FROM    ( SELECT    AM.CreatedOn ,
                                                            A.QPI ,
                                                            A.Id
                                                  FROM      dbo.View_SeenClientAnswerMaster
                                                            AS AM
                                                            INNER JOIN dbo.SeenClientAnswers 
                                                            AS A WITH(NOLOCK) ON AM.ReportId = A.SeenClientAnswerMasterId
                                                            INNER JOIN dbo.SeenClientQuestions Q WITH(NOLOCK) ON A.QuestionId = Q.Id
                                                            INNER JOIN ( SELECT Data FROM dbo.Split(@EstablishmentId, ',') ) AS RE ON (RE.Data = AM.EstablishmentId OR @EstablishmentId = '0')
                                                            INNER JOIN ( SELECT Data FROM dbo.Split(@UserId, ',') ) AS RU ON (RU.Data = AM.AppUserId OR @UserId = '0' )
                                                   WHERE     Q.QuestionTypeId IN ( 1, 5, 6, 7, 18, 21 )
                                                            AND Q.DisplayInGraphs = 1
                                                            AND AM.ActivityId = @ActivityId
                                                            AND AM.SeenClientId = @SeenClientId
                                                           AND ISNULL(AM.IsDisabled, 0) = 0
                                                    AND ( IsResolved = @AnsStatus OR @AnsStatus = '' ) 
                                                    AND ( @TranferFilter = 0 OR AM.IsTransferred = 1 ) 
                                                    AND ( @ActionFilter = 0 OR ( ( @ActionFilter = 1 AND AM.IsActioned = 1 ) OR ( @ActionFilter = 2 AND AM.IsActioned = 0 AND AM.IsResolved = 'Unresolved' ) ) )
                                                    AND ( @isPositive = '' OR AM.IsPositive = @isPositive )
                                                    AND ( @IsOutStanding = 0 OR AM.IsOutStanding = 1 )
                                                    AND CAST(AM.CreatedOn AS DATE) BETWEEN @FromDate AND @EndDate
                                                ) AS AM
                                        GROUP BY CONVERT(VARCHAR(9), AM.CreatedOn, 6) , AM.CreatedOn
									END;
                            END;
                    END;

        DECLARE @YScore DECIMAL(18, 4) ,
            @YBScore DECIMAL(18, 4) ,
            @TotalEntry BIGINT;

        IF @DisplayType = 0
            BEGIN
                IF @IsOut = 0
                    BEGIN
                        SELECT  @YScore = ROUND(SUM(Detail * 1.00) / SUM(Cnt * 1.00), 4)
                        FROM    ( SELECT    SUM(A.QPI) AS Detail ,
                                            COUNT(DISTINCT A.Id) AS Cnt ,
                                            A.QuestionId
                                  FROM      dbo.View_AnswerMaster AS AM
                                            INNER JOIN dbo.Answers AS A WITH(NOLOCK) ON AM.ReportId = A.AnswerMasterId
                                            INNER JOIN dbo.Questions Q WITH(NOLOCK) ON A.QuestionId = Q.Id
                                            INNER JOIN ( SELECT Data FROM dbo.Split(@EstablishmentId, ',') ) AS RE ON (RE.Data = AM.EstablishmentId OR @EstablishmentId = '0')
                                            INNER JOIN ( SELECT Data FROM dbo.Split(@UserId, ',') ) AS RU ON (RU.Data = AM.AppUserId OR @UserId = '0' )
                                  WHERE     Q.QuestionTypeId IN ( 1, 5, 6, 7, 18, 21 )
                                            AND Q.DisplayInGraphs = 1
                                            AND AM.ActivityId = @ActivityId
                                            AND AM.QuestionnaireId = @QuestionnaireId
                                                  AND ISNULL(AM.IsDisabled, 0) = 0
                                                    AND ( IsResolved = @AnsStatus OR @AnsStatus = '' ) 
                                                    AND ( @TranferFilter = 0 OR AM.IsTransferred = 1 ) 
                                                    AND ( @ActionFilter = 0 OR ( ( @ActionFilter = 1 AND AM.IsActioned = 1 ) OR ( @ActionFilter = 2 AND AM.IsActioned = 0 AND AM.IsResolved = 'Unresolved' ) ) )
                                                    AND ( @isPositive = '' OR AM.IsPositive = @isPositive )
                                                    AND ( @IsOutStanding = 0 OR AM.IsOutStanding = 1 )
                                                    AND CAST(AM.CreatedOn AS DATE) BETWEEN @FromDate AND @EndDate
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
                                                    INNER JOIN dbo.Answers AS A WITH(NOLOCK) ON AM.ReportId = A.AnswerMasterId
                                                    INNER JOIN dbo.Questions Q WITH(NOLOCK) ON A.QuestionId = Q.Id
                                                    LEFT OUTER JOIN ( SELECT Data FROM dbo.Split(@EstablishmentId, ',') ) AS RE ON (RE.Data = AM.EstablishmentId OR @EstablishmentId = '0')
													LEFT OUTER JOIN ( SELECT Data FROM dbo.Split(@UserId, ',') ) AS RU ON (RU.Data = AM.AppUserId OR @UserId = '0' )
                                          WHERE     Q.QuestionTypeId IN ( 1, 5, 6, 7, 18, 21 )
                                                    AND Q.DisplayInGraphs = 1
                                                    AND AM.QuestionnaireId = @QuestionnaireId
                                                    AND RE.Data IS NULL
                                                    AND ISNULL(AM.IsDisabled, 0) = 0
                                                    AND ( IsResolved = @AnsStatus OR @AnsStatus = '' ) 
                                                    AND ( @TranferFilter = 0 OR AM.IsTransferred = 1 ) 
                                                    AND ( @ActionFilter = 0 OR ( ( @ActionFilter = 1 AND AM.IsActioned = 1 ) OR ( @ActionFilter = 2 AND AM.IsActioned = 0 AND AM.IsResolved = 'Unresolved' ) ) )
                                                    AND ( @isPositive = '' OR AM.IsPositive = @isPositive )
                                                    AND ( @IsOutStanding = 0 OR AM.IsOutStanding = 1 )
                                                    AND CAST(AM.CreatedOn AS DATE) BETWEEN @FromDate AND @EndDate
                                          GROUP BY  A.QuestionId
                                        ) AS AM;
                            END;
                        ELSE
                            BEGIN
                                SELECT  @YBScore = @FixedBenchmark;
                            END;
                    END;
                ELSE
                    BEGIN
								/*SeenClient*/
                        SELECT  @YScore = ROUND(SUM(Detail * 1.00) / SUM(Cnt
                                                              * 1.00), 4)
                        FROM    ( SELECT    SUM(A.QPI) AS Detail ,
                                            COUNT(DISTINCT A.Id) AS Cnt ,
                                            A.QuestionId
                                  FROM      dbo.View_SeenClientAnswerMaster AS AM
                                            INNER JOIN dbo.SeenClientAnswers
                                            AS A WITH(NOLOCK) ON AM.ReportId = A.SeenClientAnswerMasterId
                                            INNER JOIN dbo.SeenClientQuestions Q WITH(NOLOCK) ON A.QuestionId = Q.Id
											INNER JOIN ( SELECT Data FROM dbo.Split(@EstablishmentId, ',') ) AS RE ON (RE.Data = AM.EstablishmentId OR @EstablishmentId = '0')
                                            INNER JOIN ( SELECT Data FROM dbo.Split(@UserId, ',') ) AS RU ON (RU.Data = AM.AppUserId OR @UserId = '0' )
                                  WHERE     Q.QuestionTypeId IN ( 1, 5, 6, 7, 18, 21 )
                                            AND Q.DisplayInGraphs = 1
                                            AND AM.ActivityId = @ActivityId
                                            AND AM.SeenClientId = @SeenClientId
                                            AND ISNULL(AM.IsDisabled, 0) = 0
                                                    AND ( IsResolved = @AnsStatus OR @AnsStatus = '' ) 
                                                    AND ( @TranferFilter = 0 OR AM.IsTransferred = 1 ) 
                                                    AND ( @ActionFilter = 0 OR ( ( @ActionFilter = 1 AND AM.IsActioned = 1 ) OR ( @ActionFilter = 2 AND AM.IsActioned = 0 AND AM.IsResolved = 'Unresolved' ) ) )
                                                    AND ( @isPositive = '' OR AM.IsPositive = @isPositive )
                                                    AND ( @IsOutStanding = 0 OR AM.IsOutStanding = 1 )
                                                    AND CAST(AM.CreatedOn AS DATE) BETWEEN @FromDate AND @EndDate
                                  GROUP BY  A.QuestionId
                                ) AS AM;
                    
                        IF ( @CompareWithIndustry = 1 )
                            BEGIN    
                                SELECT  @YBScore = ROUND(SUM(Detail * 1.00)
                                                         / SUM(Cnt * 1.00), 4)
                                FROM    ( SELECT    SUM(A.QPI) AS Detail ,
                                                    COUNT(DISTINCT A.Id) AS Cnt ,
                                                    A.QuestionId
                                          FROM      dbo.View_SeenClientAnswerMaster
                                                    AS AM
                                                    INNER JOIN dbo.SeenClientAnswers
                                                    AS A WITH(NOLOCK) ON AM.ReportId = A.SeenClientAnswerMasterId
                                                    INNER JOIN dbo.SeenClientQuestions Q WITH(NOLOCK) ON A.QuestionId = Q.Id
                                                    LEFT OUTER JOIN ( SELECT Data FROM dbo.Split(@EstablishmentId, ',') ) AS RE ON (RE.Data = AM.EstablishmentId OR @EstablishmentId = '0')
													LEFT OUTER JOIN ( SELECT Data FROM dbo.Split(@UserId, ',') ) AS RU ON (RU.Data = AM.AppUserId OR @UserId = '0' )
                                          WHERE     Q.QuestionTypeId IN ( 1, 5, 6, 7, 18, 21 )
                                                    AND Q.DisplayInGraphs = 1
                                                    AND AM.SeenClientId = @SeenClientId
                                                    AND RE.Data IS NULL
                                                    AND ISNULL(AM.IsDisabled, 0) = 0
                                                    AND ( IsResolved = @AnsStatus OR @AnsStatus = '' ) 
                                                    AND ( @TranferFilter = 0 OR AM.IsTransferred = 1 ) 
                                                    AND ( @ActionFilter = 0 OR ( ( @ActionFilter = 1 AND AM.IsActioned = 1 ) OR ( @ActionFilter = 2 AND AM.IsActioned = 0 AND AM.IsResolved = 'Unresolved' ) ) )
                                                    AND ( @isPositive = '' OR AM.IsPositive = @isPositive )
                                                    AND ( @IsOutStanding = 0 OR AM.IsOutStanding = 1 )
                                                    AND CAST(AM.CreatedOn AS DATE) BETWEEN @FromDate AND @EndDate
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
                                INNER JOIN ( SELECT Data FROM dbo.Split(@EstablishmentId, ',') ) AS RE ON (RE.Data = AM.EstablishmentId OR @EstablishmentId = '0')
								INNER JOIN ( SELECT Data FROM dbo.Split(@UserId, ',') ) AS RU ON (RU.Data = AM.AppUserId OR @UserId = '0' )
                        WHERE   Am.ActivityId = @ActivityId
                                AND ISNULL(AM.IsDisabled, 0) = 0
                                                    AND ( IsResolved = @AnsStatus OR @AnsStatus = '' ) 
                                                    AND ( @TranferFilter = 0 OR AM.IsTransferred = 1 ) 
                                                    AND ( @ActionFilter = 0 OR ( ( @ActionFilter = 1 AND AM.IsActioned = 1 ) OR ( @ActionFilter = 2 AND AM.IsActioned = 0 AND AM.IsResolved = 'Unresolved' ) ) )
                                                    AND ( @isPositive = '' OR AM.IsPositive = @isPositive )
                                                    AND ( @IsOutStanding = 0 OR AM.IsOutStanding = 1 )
                                                    AND CAST(AM.CreatedOn AS DATE) BETWEEN @FromDate AND @EndDate

                        SELECT  @YScore = dbo.PICalculationForGraphNew(@ActivityId,
                                                              @FromDate,
                                                              @EndDate,
                                                              @QuestionnaireId,
                                                              @IsOut, @UserId,@EstablishmentId,0,@FormStatus,@ReadUnread,@isAction,@isTransfer);
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
				
                    END;
                ELSE
                    BEGIN
                        SELECT  @TotalEntry = COUNT(1)
                        FROM    dbo.View_SeenClientAnswerMaster AS Am
                                INNER JOIN ( SELECT Data FROM dbo.Split(@EstablishmentId, ',') ) AS RE ON (RE.Data = AM.EstablishmentId OR @EstablishmentId = '0')
								INNER JOIN ( SELECT Data FROM dbo.Split(@UserId, ',') ) AS RU ON (RU.Data = AM.AppUserId OR @UserId = '0' )
                        WHERE   Am.ActivityId = @ActivityId
                                AND ISNULL(AM.IsDisabled, 0) = 0
                                                    AND ( IsResolved = @AnsStatus OR @AnsStatus = '' ) 
                                                    AND ( @TranferFilter = 0 OR AM.IsTransferred = 1 ) 
                                                    AND ( @ActionFilter = 0 OR ( ( @ActionFilter = 1 AND AM.IsActioned = 1 ) OR ( @ActionFilter = 2 AND AM.IsActioned = 0 AND AM.IsResolved = 'Unresolved' ) ) )
                                                    AND ( @isPositive = '' OR AM.IsPositive = @isPositive )
                                                    AND ( @IsOutStanding = 0 OR AM.IsOutStanding = 1 )
                                                    AND CAST(AM.CreatedOn AS DATE) BETWEEN @FromDate AND @EndDate

                        SELECT  @YScore = dbo.PICalculationForGraphNew(@ActivityId,
                                                              @FromDate,
                                                              @EndDate,
                                                              @SeenClientId,
                                                              @IsOut, @UserId,@EstablishmentId,0,@FormStatus,@ReadUnread,@isAction,@isTransfer);
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

                SELECT  @MaxRank = MAX(Score) + 10
                FROM    @Result;
         
                SET @MinRank = 0;

DECLARE @FinalResult TABLE
            (
              Name VARCHAR(500) NOT NULL ,
			  DisplayDate DATE NULL,
              Score DECIMAL(18, 2) NOT NULL ,
              Counts BIGINT NOT NULL ,
              BenchmarkScore DECIMAL(18, 2) NOT NULL ,
              BenchmarkCounts BIGINT NOT NULL
            );

INSERT INTO @FinalResult
        ( Name ,
          DisplayDate ,
          Score ,
          Counts ,
          BenchmarkScore ,
          BenchmarkCounts
        ) SELECT	  Displayname ,
				CONVERT(DATE, DisplayDateTime) AS DisplayDateTime,
						ROUND(SUM(ISNULL(Score, 0)), 0) AS Score ,
                        ROUND(SUM(ISNULL(Counts, 0)), 0) AS Counts ,
                        ROUND(SUM(ISNULL(BenchmarkScore, 0)), 0) AS BenchmarkScore ,
                        ROUND(SUM(ISNULL(BenchmarkCounts, 0)), 0) AS BenchmarkCounts
			FROM @Result 
			GROUP BY  CONVERT(DATE, DisplayDateTime) , Displayname

 SELECT Displayname AS [DisplayName],
		CONVERT(DATE, DisplayDateTime) AS DisplayDateTime,
						100.00 AS Score ,
                        [@FinalResult].Counts AS Counts ,
                        [@FinalResult].BenchmarkScore AS BenchmarkScore ,
                        [@FinalResult].BenchmarkCounts AS BenchmarkCounts ,
						--100.00 AS QScore ,
                        ROUND(ISNULL(AVG([@Result].Score), 0), 0) AS QScore ,
                        ROUND(( SUM(ISNULL([@Result].BenchmarkScore, 0))
                                / CASE SUM(ISNULL([@Result].BenchmarkCounts, 0))
                                    WHEN 0 THEN 1
                                    ELSE SUM(ISNULL([@Result].BenchmarkCounts, 0))
                                  END ), 0) AS QBenchmarkScore ,
                        ROUND(ISNULL(@YScore, 0), 0) AS YScore ,
                        ROUND(ISNULL(@YBScore, 0), 0) AS YBScore ,
						ROUND(ISNULL(@YScore, 0), 0) - ROUND(ISNULL(@YBScore, 0), 0) AS Performance ,
                        ISNULL(@TotalEntry, 0) AS TotalEntry ,
                        ISNULL(@MinRank, 0) AS MinRank ,
                        ISNULL(@MaxRank, 0) AS MaxRank ,
                        @LocalTime AS LastUpdatedTime ,
                        @FromDate AS StartDate ,
                        @EndDate AS EndDate ,
                        @DisplayType AS DisplayType
FROM @Result
LEFT OUTER JOIN @FinalResult ON [@Result].Displayname = [@FinalResult].Name
GROUP BY   CONVERT(DATE, DisplayDateTime) ,
           --ROUND(ISNULL([@Result].Score, 0), 0) ,
           Displayname ,
           [@FinalResult].Score ,
           [@FinalResult].Counts ,
           [@FinalResult].BenchmarkScore ,
           [@FinalResult].BenchmarkCounts
ORDER BY CONVERT(DATE, DisplayDateTime) 

            END;
    END;
