-- =============================================
-- Author:      Krishna Panchal
-- Create Date: 18-May-2021
-- Description: Get Unallocated Task List By ActivityId
-- SP call: GetUnallocatedTaskListByActivityId 5819, 6130,'0','',NULL,NULL,0,'',0,1,'',1,50
-- GetProductIssueInfoGraphData 1246, 1931,'0','0',1,'','','',4
-- =============================================

CREATE PROCEDURE [dbo].[GetProductIssueInfoGraphData]
	@AppUserId BIGINT ,
    @ActivityId BIGINT,
    @EstablishmentId NVARCHAR(MAX) = '0',
    @UserId NVARCHAR(MAX) = '',
    @IsOut BIT = 1,
    @FormStatus VARCHAR(50) = '',
    @FilterOn NVARCHAR(MAX) = '',
    @StatusIds VARCHAR(MAX) = '',
    @DateFilterId INT = 3
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @SelectUserId VARCHAR(20) = '';
    DECLARE @ServerDate DATETIME = GETUTCDATE(),
            @FromDate DATETIME = '',
            @ToDate DATETIME = '';

    IF (@DateFilterId = 1)
    BEGIN
        SET @FromDate = @ServerDate;
        SET @ToDate = @ServerDate;
    END;
    ELSE IF (@DateFilterId = 2)
    BEGIN
        SET @FromDate = DATEADD(DAY, -5, @ServerDate);
        SET @ToDate = @ServerDate;
    END;
    ELSE IF (@DateFilterId = 3)
    BEGIN
        SET @FromDate = DATEADD(DAY, -30, @ServerDate);
        SET @ToDate = @ServerDate;
    END;
    ELSE IF (@DateFilterId = 4)
    BEGIN
        SET @FromDate = DATEADD(MONTH, -6, @ServerDate);
        SET @ToDate = @ServerDate;
    END;
    ELSE IF (@DateFilterId = 5)
    BEGIN
        SET @FromDate = DATEADD(YEAR, -1, @ServerDate);
        SET @ToDate = @ServerDate;
    END;
    ELSE IF (@DateFilterId = 6)
    BEGIN
        SET @FromDate = DATEADD(YEAR, -5, @ServerDate);
        SET @ToDate = @ServerDate;
    END;
    ELSE IF (@DateFilterId = 7)
    BEGIN
        SET @FromDate = DATEADD(YEAR, -5, @ServerDate);
        SET @ToDate = @ServerDate;
    END;

    IF (@EstablishmentId = '0')
    BEGIN
        SET @EstablishmentId =
        (
            SELECT dbo.AllEstablishmentByAppUserAndActivity(@AppUserId, @ActivityId)
        );
    END;

    DECLARE @ActivityType NVARCHAR(50);
    SELECT @ActivityType = EstablishmentGroupType
    FROM dbo.EstablishmentGroup
    WHERE Id = @ActivityId;
    DECLARE @UserInfo AS TABLE
    (
        Id BIGINT,
        Name VARCHAR(100),
        ContactMasterId BIGINT
    );

    SET @SelectUserId = '0';
    INSERT INTO @UserInfo
    (
        Id,
        Name,
        ContactMasterId
    )
    SELECT AUE.AppUserId,
           AU.Name,
           (
               SELECT TOP 1
                      CD.ContactMasterId
               FROM dbo.ContactDetails CD WITH(NOLOCK)
                   INNER JOIN dbo.ContactMaster CM WITH(NOLOCK) 
                       ON CM.Id = CD.ContactMasterId
                          AND CM.GroupId = AU.GroupId
						    AND CM.IsDeleted = 0
               WHERE CD.QuestionTypeId = 10
                     AND AU.Email = CD.Detail
                     AND ISNULL(CD.IsDeleted, 0) = 0
               ORDER BY CD.ContactMasterId DESC
           )
    FROM dbo.AppUserEstablishment AUE WITH(NOLOCK) 
        INNER JOIN dbo.AppUser AU WITH(NOLOCK) 
            ON AU.Id = AUE.AppUserId
               AND AUE.EstablishmentId IN
                   (
                       SELECT Data FROM dbo.Split(@EstablishmentId, ',')
                   )
        --INNER JOIN dbo.AppUserofManage AOM
        --    ON AOM.ApplicationUserId = AU.Id
        --       AND AOM.ManagerUserId = @AppUserId
        --       AND ISNULL(AOM.IsDeleted, 0) = 0
    WHERE AUE.IsDeleted = 0
          AND AU.IsDeleted = 0
          AND
          (
              AU.IsAreaManager = 0
              OR AUE.AppUserId = @AppUserId
          )
          AND AU.IsActive = 1
          AND
          (
              (AUE.AppUserId IN
               (
                   SELECT Data FROM dbo.Split(@UserId,',')
               )
              )
              OR @UserId = '0'
          )
    UNION
    SELECT TOP 1
           @AppUserId AS AppUserId,
           AU.Name,
           CD.ContactMasterId AS ContactMasterId
    FROM dbo.ContactDetails CD WITH(NOLOCK) 
        INNER JOIN dbo.AppUser AU WITH(NOLOCK) 
            ON CD.Detail = AU.Email
               AND AU.Id = @AppUserId
               AND ISNULL(CD.IsDeleted, 0) = 0
			   AND AU.IsDeleted = 0
        INNER JOIN dbo.AppUserEstablishment AUE WITH(NOLOCK) 
            ON AUE.AppUserId = @AppUserId
               AND AUE.EstablishmentId IN
                   (
                       SELECT Data FROM dbo.Split(@EstablishmentId, ',')
                   )
               AND
               (
                   (AUE.AppUserId IN
                    (
                        SELECT Data FROM dbo.Split(@UserId,',')
                    )
                   )
                   OR @UserId = '0'
               )
    UNION
    SELECT AMUR.ManagerUserId AS AppUserId,
           AU.Name,
           (
               SELECT TOP 1
                      CD.ContactMasterId
               FROM dbo.ContactDetails CD WITH(NOLOCK) 
                   INNER JOIN dbo.ContactMaster CM WITH(NOLOCK) 
                       ON CM.Id = CD.ContactMasterId
                          AND CM.GroupId = AU.GroupId
						  AND CM.IsDeleted = 0
               WHERE CD.QuestionTypeId = 10
                     AND AU.Email = CD.Detail
                     AND ISNULL(CD.IsDeleted, 0) = 0
               ORDER BY CD.ContactMasterId DESC
           ) AS ContactMasterId
    FROM dbo.AppManagerUserRights AMUR  WITH(NOLOCK) 
        INNER JOIN dbo.AppUser AU WITH(NOLOCK) 
            ON AU.Id = AMUR.ManagerUserId
               AND AMUR.UserId = @AppUserId
               AND AMUR.IsDeleted = 0
               AND AU.IsActive = 1
               AND AU.IsDeleted = 0
               AND
               (
                   (AMUR.ManagerUserId IN
                    (
                        SELECT Data FROM dbo.Split(@UserId,',')
                    )
                   )
                   OR @UserId = '0'
               )
               AND AMUR.EstablishmentId IN
                   (
                       SELECT Data FROM dbo.Split(@EstablishmentId, ',')
                   )
        --INNER JOIN dbo.AppUserofManage AOM
        --    ON AOM.ApplicationUserId = AU.Id
        --       AND AOM.ManagerUserId = @AppUserId
        --       AND ISNULL(AOM.IsDeleted, 0) = 0
    GROUP BY AMUR.ManagerUserId,
             AU.Name,
             AU.ImageName,
             AU.Email,
             AU.Mobile,
             AU.GroupId
    ORDER BY Name ASC;

    DECLARE @Result TABLE
    (
        Name VARCHAR(255) NULL,
        Score BIGINT NULL,
        Counts BIGINT NOT NULL,
        BenchmarkScore BIGINT NULL,
        BenchmarkCounts BIGINT NULL,
        ReportId BIGINT,
        Longitude DECIMAL(18, 2),
        Latitude DECIMAL(18, 2)
    );

    DECLARE @End BIGINT,
            @Start BIGINT = 1;

    ---# For Changes Graph Category.
    DECLARE @EndDate DATETIME,
            @LocalTime DATETIME,
            @DaysDiff INT = 0,
            @CategoryType INT = 1;

    DECLARE @QuestionnaireId BIGINT,
            @SeenClientId BIGINT,
            @EstId BIGINT,
            @MinRank INT,
            @MaxRank INT,
            @DisplayType INT,
            @QuestionIdList NVARCHAR(MAX),
            @TimeOffSet INT,
            @EstablishmentGroupType NVARCHAR(50),
            @IsTellUs BIT;

    SET @EstablishmentGroupType = N'Customer';

    SELECT TOP 1
           @QuestionnaireId = QuestionnaireId,
           @TimeOffSet = TimeOffSet,
           @SeenClientId = SeenClientId,
           @IsTellUs = CASE
                           WHEN E.EstablishmentGroupId IS NULL
                                AND Eg.EstablishmentGroupType = 'Customer' THEN
                               1
                           ELSE
                               0
                       END
    FROM dbo.EstablishmentGroup AS Eg WITH(NOLOCK) 
        INNER JOIN dbo.Establishment AS E WITH(NOLOCK) 
            ON Eg.Id = E.EstablishmentGroupId
			 AND EG.IsDeleted = 0
    WHERE Eg.Id = @ActivityId
          AND E.IsDeleted = 0;

    SELECT @LocalTime = DATEADD(MINUTE, @TimeOffSet, GETUTCDATE());

    IF @IsOut = 0
    BEGIN
        SELECT @MinRank = MinRank,
               @MaxRank = MaxRank,
               @DisplayType = DisplayType,
               @QuestionIdList = QuestionId
        FROM dbo.ReportSetting WITH(NOLOCK) 
        WHERE QuestionnaireId = @QuestionnaireId
              AND ReportType = 'Analysis';
    END;
    ELSE
    BEGIN
        SELECT @MinRank = MinRank,
               @MaxRank = MaxRank,
               @DisplayType = DisplayType,
               @QuestionIdList = QuestionId
        FROM dbo.ReportSetting WITH(NOLOCK)
        WHERE SeenClientId = @SeenClientId
              AND ReportType = 'Analysis';
    END;

    DECLARE @AnsStatus NVARCHAR(50) = '',
            @isPositive NVARCHAR(50) = '';

    IF (@FormStatus = 'Resolved' OR @FormStatus = 'Unresolved')
    BEGIN
        SET @AnsStatus = @FormStatus;
    END;
    
        SET @isPositive = @FilterOn;
    

    DECLARE @QuestionSearchTable AS TABLE
    (
        ReportId BIGINT
    );

    IF (@FilterOn <> '')
    BEGIN
        INSERT INTO @QuestionSearchTable
        (
            ReportId
        )
        EXEC dbo.QustionSearchForFilter @EstablishmentId, '', @IsOut;
    END;
    ELSE
    BEGIN
        INSERT @QuestionSearchTable
        (
            ReportId
        )
        VALUES
        (0  -- ReportId - bigint
            );
    END;

    IF @IsOut = 0
    BEGIN
        INSERT INTO @Result
        (
            Name,
            Score,
            Counts,
            BenchmarkScore,
            BenchmarkCounts,
            ReportId,
            Longitude,
            Latitude
        )
        SELECT CASE @CategoryType
                   WHEN 1 THEN
                       CONVERT(VARCHAR(10), CreatedOn, 105)
                   ELSE
                       CONVERT(VARCHAR(14), CreatedOn, 120) + '00:00'
               END,
               COUNT(AppUserId) AS Detail,
               COUNT(AppUserId) AS Total,
               0,
               0,
               ReportId,
               Longitude,
               Latitude
        FROM
        (
            SELECT Am.AppUserId,
                   Am.CreatedOn,
                   Am.ReportId,
                   Am.Longitude,
                   Am.Latitude
            FROM dbo.View_AnswerMaster AS Am
                INNER JOIN @QuestionSearchTable QS
                    ON (
                           QS.ReportId = Am.ReportId
                           OR QS.ReportId = 0
                       )
                INNER JOIN
                (SELECT Data FROM dbo.Split(@EstablishmentId, ',') ) AS RE
                    ON (
                           RE.Data = Am.EstablishmentId
                           OR @EstablishmentId = '0'
                       )
                --INNER JOIN
                --(SELECT UIT.Id FROM @UserInfo UIT) AS RU
                --    ON RU.Id = Am.AppUserId
            WHERE Am.ActivityId = @ActivityId
                  AND Am.QuestionnaireId = @QuestionnaireId
                  AND ISNULL(Am.IsDisabled, 0) = 0
                  AND CAST(Am.CreatedOn AS DATE)
                  BETWEEN CAST((DATEADD(MINUTE, Am.TimeOffSet, @FromDate)) AS DATE) AND CAST((DATEADD(
                                                                                                         MINUTE,
                                                                                                         Am.TimeOffSet,
                                                                                                         @ToDate
                                                                                                     )
                                                                                             ) AS DATE)
                  AND
                  (
                      @EstablishmentId = '0'
                      OR (Am.EstablishmentId IN
                          (
                              SELECT Data FROM dbo.Split(@EstablishmentId, ',')
                          )
                         )
                  )
				   AND
                  (
                      @UserId = '0'
                      OR (Am.AppUserId IN
                          (
                              SELECT UIT.Id FROM @UserInfo UIT
                          )
                         )
                  )
                  AND
                  (
                      Am.IsResolved = @AnsStatus
                      OR @AnsStatus = ''
                  )
                  AND
                  (
                      @isPositive = ''
                      OR Am.IsPositive = @isPositive
                  )
                  AND
                  (
                      @StatusIds = ''
                      OR
                      (
                          SELECT SH.EstablishmentStatusId
                          FROM dbo.StatusHistory SH WITH(NOLOCK) 
                          WHERE SH.Id = Am.StatusHistoryId
                      ) IN
                      (
                          SELECT Data FROM dbo.Split(@StatusIds, ',')
                      )
                  )
        ) AS AM
        GROUP BY CASE @CategoryType
                     WHEN 1 THEN
                         CONVERT(VARCHAR(10), CreatedOn, 105)
                     ELSE
                         CONVERT(VARCHAR(14), CreatedOn, 120) + '00:00'
                 END,
                 AM.ReportId,
                 AM.Longitude,
                 AM.Latitude;

        /*BenchMark*/
        INSERT INTO @Result
        (
            Name,
            Score,
            Counts,
            BenchmarkScore,
            BenchmarkCounts,
            ReportId,
            Longitude,
            Latitude
        )
        SELECT CASE @CategoryType
                   WHEN 1 THEN
                       CONVERT(VARCHAR(10), CreatedOn, 105)
                   ELSE
                       CONVERT(VARCHAR(14), CreatedOn, 120) + '00:00'
               END,
               0,
               0,
               COUNT(AppUserId) AS Detail,
               COUNT(AppUserId) AS Total,
               AM.ReportId,
               AM.Longitude,
               AM.Latitude
        FROM
        (
            SELECT AM.AppUserId,
                   AM.CreatedOn,
                   AM.ReportId,
                   AM.Longitude,
                   AM.Latitude
            FROM dbo.View_AnswerMaster AS AM
                INNER JOIN @QuestionSearchTable QS
                    ON (
                           QS.ReportId = AM.ReportId
                           OR QS.ReportId = 0
                       )
					   --INNER JOIN
        --        (SELECT UIT.Id FROM @UserInfo UIT) AS RU
        --            ON RU.Id = Am.AppUserId
            WHERE AM.QuestionnaireId = @QuestionnaireId
                  AND AM.ActivityId = @ActivityId
                  AND ISNULL(AM.IsDisabled, 0) = 0
                  AND CAST(AM.CreatedOn AS DATE)
                  BETWEEN CAST((DATEADD(MINUTE, AM.TimeOffSet, @FromDate)) AS DATE) AND CAST((DATEADD(
                                                                                                         MINUTE,
                                                                                                         AM.TimeOffSet,
                                                                                                         @ToDate
                                                                                                     )
                                                                                             ) AS DATE)
                  AND
                  (
                      @EstablishmentId = '0'
                      OR (AM.EstablishmentId IN
                          (
                              SELECT Data FROM dbo.Split(@EstablishmentId, ',')
                          )
                         )
                  )
				   AND
                  (
                      @UserId = '0'
                      OR (Am.AppUserId IN
                          (
                              SELECT UIT.Id FROM @UserInfo UIT
                          )
                         )
                  )
                  AND
                  (
                      AM.IsResolved = @AnsStatus
                      OR @AnsStatus = ''
                  )
                  AND
                  (
                      @isPositive = ''
                      OR AM.IsPositive = @isPositive
                  )
                  AND
                  (
                      @StatusIds = ''
                      OR
                      (
                          SELECT SH.EstablishmentStatusId
                          FROM dbo.StatusHistory SH WITH(NOLOCK) 
                          WHERE SH.Id = AM.StatusHistoryId
                      ) IN
                      (
                          SELECT Data FROM dbo.Split(@StatusIds, ',')
                      )
                  )
        ) AS AM
        GROUP BY CASE @CategoryType
                     WHEN 1 THEN
                         CONVERT(VARCHAR(10), CreatedOn, 105)
                     ELSE
                         CONVERT(VARCHAR(14), CreatedOn, 120) + '00:00'
                 END,
                 AM.ReportId,
                 AM.Longitude,
                 AM.Latitude;
    END;
    ELSE
    BEGIN
        INSERT INTO @Result
        (
            Name,
            Score,
            Counts,
            BenchmarkScore,
            BenchmarkCounts,
            ReportId,
            Longitude,
            Latitude
        )
        SELECT CASE @CategoryType
                   WHEN 1 THEN
                       CONVERT(VARCHAR(10), AM.CreatedOn, 105)
                   ELSE
                       CONVERT(VARCHAR(14), AM.CreatedOn, 120) + '00:00'
               END,
               COUNT(AppUserId) AS Detail,
               COUNT(AppUserId) AS Total,
               0,
               0,
               AM.ReportId,
               AM.Longitude,
               AM.Latitude
        FROM
        (
            SELECT AM.AppUserId,
                   AM.CreatedOn,
                   AM.ReportId,
                   AM.Latitude,
                   AM.Longitude
            FROM dbo.View_SeenClientAnswerMaster AS AM
                INNER JOIN @QuestionSearchTable QS
                    ON (
                           QS.ReportId = AM.ReportId
                           OR QS.ReportId = 0
                       )
                INNER JOIN
                (SELECT Data FROM dbo.Split(@EstablishmentId, ',') ) AS RE
                    ON (
                           RE.Data = AM.EstablishmentId
                           OR @EstablishmentId = '0'
                       )
                --INNER JOIN
                --(SELECT ContactMasterId FROM @UserInfo) AS RU
                --    ON RU.ContactMasterId = AM.ContactMasterId
            WHERE AM.ActivityId = @ActivityId
                  AND AM.SeenClientId = @SeenClientId
                  AND AM.IsUnAllocated = 0
                  AND ISNULL(AM.IsDisabled, 0) = 0
                  AND CAST(AM.CreatedOn AS DATE)
                  BETWEEN CAST((DATEADD(MINUTE, AM.TimeOffSet, @FromDate)) AS DATE) AND CAST((DATEADD(
                                                                                                         MINUTE,
                                                                                                         AM.TimeOffSet,
                                                                                                         @ToDate
                                                                                                     )
                                                                                             ) AS DATE)
                  AND
                  (
                      @EstablishmentId = '0'
                      OR (AM.EstablishmentId IN
                          (
                              SELECT Data FROM dbo.Split(@EstablishmentId, ',')
                          )
                         )
                  )
				   AND
                  (
                      @UserId = '0'
                      OR ( AM.ContactMasterId IN
                          (
                              SELECT UIT.ContactMasterId FROM @UserInfo UIT
                          )
                         )
                  )
                  AND
                  (
                      IsResolved = @AnsStatus
                      OR @AnsStatus = ''
                  )
                  AND
                  (
                      @isPositive = ''
                      OR AM.IsPositive = @isPositive
                  )
                  AND
                  (
                      @StatusIds = ''
                      OR
                      (
                          SELECT SH.EstablishmentStatusId
                          FROM dbo.StatusHistory SH WITH(NOLOCK) 
                          WHERE SH.Id = AM.StatusHistoryId
                      ) IN
                      (
                          SELECT Data FROM dbo.Split(@StatusIds, ',')
                      )
                  )
        ) AS AM
        GROUP BY CASE @CategoryType
                     WHEN 1 THEN
                         CONVERT(VARCHAR(10), CreatedOn, 105)
                     ELSE
                         CONVERT(VARCHAR(14), CreatedOn, 120) + '00:00'
                 END,
                 AM.ReportId,
                 AM.Longitude,
                 AM.Latitude;

        /*BenchMark*/
        INSERT INTO @Result
        (
            Name,
            Score,
            Counts,
            BenchmarkScore,
            BenchmarkCounts,
            ReportId,
            Longitude,
            Latitude
        )
        SELECT CASE @CategoryType
                   WHEN 1 THEN
                       CONVERT(VARCHAR(10), CreatedOn, 105)
                   ELSE
                       CONVERT(VARCHAR(14), CreatedOn, 120) + '00:00'
               END,
               0,
               0,
               COUNT(AppUserId) AS Detail,
               COUNT(AppUserId) AS Total,
               ReportId,
               Longitude,
               Latitude
        FROM
        (
            SELECT Am.AppUserId,
                   Am.CreatedOn,
                   Am.ReportId,
                   Am.Longitude,
                   Am.Latitude
            FROM dbo.View_SeenClientAnswerMaster AS Am
                INNER JOIN @QuestionSearchTable QS
                    ON (
                           QS.ReportId = Am.ReportId
                           OR QS.ReportId = 0
                       )
					       --INNER JOIN
            --    (SELECT ContactMasterId FROM @UserInfo) AS RU
            --        ON RU.ContactMasterId = AM.ContactMasterId
            WHERE Am.SeenClientId = @SeenClientId
                  AND Am.ActivityId = @ActivityId
                  AND Am.IsUnAllocated = 0
                  AND ISNULL(Am.IsDisabled, 0) = 0
                  AND CAST(Am.CreatedOn AS DATE)
                  BETWEEN CAST((DATEADD(MINUTE, Am.TimeOffSet, @FromDate)) AS DATE) AND CAST((DATEADD(
                                                                                                         MINUTE,
                                                                                                         Am.TimeOffSet,
                                                                                                         @ToDate
                                                                                                     )
                                                                                             ) AS DATE)
                  AND
                  (
                      @EstablishmentId = '0'
                      OR (Am.EstablishmentId IN
                          (
                              SELECT Data FROM dbo.Split(@EstablishmentId, ',')
                          )
                         )
                  )
				   AND
                  (
                      @UserId = '0'
                      OR ( AM.ContactMasterId IN
                          (
                              SELECT UIT.ContactMasterId FROM @UserInfo UIT
                          )
                         )
                  )
                  AND
                  (
                      Am.IsResolved = @AnsStatus
                      OR @AnsStatus = ''
                  )
                  AND
                  (
                      @isPositive = ''
                      OR Am.IsPositive = @isPositive
                  )
                  AND
                  (
                      @StatusIds = ''
                      OR
                      (
                          SELECT SH.EstablishmentStatusId
                          FROM dbo.StatusHistory SH
                          WHERE SH.Id = Am.StatusHistoryId
                      ) IN
                      (
                          SELECT Data FROM dbo.Split(@StatusIds, ',')
                      )
                  )
        ) AS AM
        GROUP BY CASE @CategoryType
                     WHEN 1 THEN
                         CONVERT(VARCHAR(10), CreatedOn, 105)
                     ELSE
                         CONVERT(VARCHAR(14), CreatedOn, 120) + '00:00'
                 END,
                 AM.ReportId,
                 AM.Longitude,
                 AM.Latitude;

    END;
    DECLARE @YScore DECIMAL(18, 2),
            @YBScore DECIMAL(18, 2),
            @TotalEntry BIGINT,
            @UserCount DECIMAL(18, 2);

    IF (@UserId = '0')
    BEGIN
        IF @ActivityType != 'Customer'
        BEGIN
            SELECT @UserCount = COUNT(DISTINCT AUE.AppUserId)
            FROM dbo.Establishment AS E WITH(NOLOCK) 
                INNER JOIN dbo.EstablishmentGroup AS Eg WITH(NOLOCK) 
                    ON Eg.Id = E.EstablishmentGroupId
					 AND EG.IsDeleted = 0
                INNER JOIN dbo.AppUserEstablishment AS AUE WITH(NOLOCK) 
                    ON AUE.EstablishmentId = E.Id
                       AND AUE.IsDeleted = 0
            WHERE E.IsDeleted = 0
                  AND Eg.SeenClientId = @SeenClientId;
        END;
        ELSE
        BEGIN
            SELECT @UserCount = COUNT(DISTINCT AUE.AppUserId)
            FROM dbo.Establishment AS E
                INNER JOIN dbo.EstablishmentGroup AS Eg WITH(NOLOCK) 
                    ON Eg.Id = E.EstablishmentGroupId
					 AND EG.IsDeleted = 0
                INNER JOIN dbo.AppUserEstablishment AS AUE WITH(NOLOCK) 
                    ON AUE.EstablishmentId = E.Id
                       AND AUE.IsDeleted = 0
            WHERE E.IsDeleted = 0
                  AND Eg.QuestionnaireId = @QuestionnaireId;
        END;
    END;
    ELSE
    BEGIN
        SELECT @UserCount = COUNT(DISTINCT AppUserId)
        FROM
        (
            SELECT Am.AppUserId,
                   Am.CreatedOn
            FROM dbo.View_SeenClientAnswerMaster AS Am
                INNER JOIN
                (SELECT Data FROM dbo.Split(@EstablishmentId, ',') ) AS RE
                    ON (
                           RE.Data = Am.EstablishmentId
                           OR @EstablishmentId = '0'
                       )
            WHERE Am.SeenClientId = @SeenClientId
                  AND Am.ActivityId = @ActivityId
                  AND Am.IsUnAllocated = 0
                  AND ISNULL(Am.IsDisabled, 0) = 0
                  AND CAST(Am.CreatedOn AS DATE)
                  BETWEEN CAST((DATEADD(MINUTE, Am.TimeOffSet, @FromDate)) AS DATE) AND CAST((DATEADD(
                                                                                                         MINUTE,
                                                                                                         Am.TimeOffSet,
                                                                                                         @ToDate
                                                                                                     )
                                                                                             ) AS DATE)
                  AND
                  (
                      Am.IsResolved = @AnsStatus
                      OR @AnsStatus = ''
                  )
                  AND
                  (
                      @isPositive = ''
                      OR Am.IsPositive = @isPositive
                  )
                  AND
                  (
                      @StatusIds = ''
                      OR
                      (
                          SELECT SH.EstablishmentStatusId
                          FROM dbo.StatusHistory SH WITH(NOLOCK) 
                          WHERE SH.Id = Am.StatusHistoryId
                      ) IN
                      (
                          SELECT Data FROM dbo.Split(@StatusIds, ',')
                      )
                  )
        ) AS AM;
    END;

    SELECT @YScore = SUM(ISNULL(Counts, 0))
    FROM @Result;

    SELECT @YBScore = SUM(BenchmarkCounts)
    FROM @Result;

    SELECT @TotalEntry = SUM(ISNULL(Counts, 0))
    FROM @Result;

    SELECT @MaxRank = ISNULL(MAX(R.Data), 0) + 1
    FROM
    (
        SELECT SUM(ISNULL(Counts, 0)) AS Data
        FROM @Result
        GROUP BY Name
    ) AS R;

    DECLARE @SelectedUserCount DECIMAL(18, 2) = 0.00;

    IF (@SelectUserId = '0')
    BEGIN
        SET @SelectedUserCount = 1;
        SET @UserCount = 1;
    END;
    ELSE
    BEGIN
        SELECT @SelectedUserCount = COUNT(Data)
        FROM dbo.Split(@UserId, ',');
    END;

    SELECT ISNULL(Name, '') AS xAxisValue,
           CAST(ROUND((SUM(ISNULL(Score, 0))), 0) AS BIGINT) AS UserScore,
           CAST(ROUND((SUM(ISNULL(BenchmarkScore, 0))), 0) AS BIGINT) AS UserBenchmarkScore,
           ISNULL(@YScore, 0) AS EveryoneScore,
           ISNULL(@YBScore, 0) AS EveryoneBenchmarkScore,
           SUM(ISNULL(BenchmarkCounts, 0)) AS BenchmarkCounts,
           ISNULL(@YScore - @YBScore, 0) AS Performance,
           ISNULL(@TotalEntry, 0) AS TotalEntry,
           ISNULL(@MinRank, 0) AS MinRank,
           ISNULL(@MaxRank, 0) AS MaxRank,
           ISNULL(@LocalTime, GETUTCDATE()) AS LastUpdatedTime
    FROM @Result 
    GROUP BY ISNULL(Name, '') ORDER BY ISNULL(Name, '') ;

    SELECT ReportId,
           ISNULL(Longitude, 0) AS Longitude,
           ISNULL(Latitude, 0) AS Latitude
    FROM @Result
    GROUP BY ISNULL(Name, ''),
             ReportId,
             ISNULL(Latitude, 0),
             ISNULL(Longitude, 0);

SET NOCOUNT OFF;
END;
