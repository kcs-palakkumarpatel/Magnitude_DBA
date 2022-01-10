-- =============================================
-- Author:			Krishna Panchal
-- Create date:
-- Description:
-- Call SP:		dbo.GetTableGraphDataByQuestionId 5201, 7653,'0','0','','','',72991,'Region'
-- =============================================
CREATE PROCEDURE dbo.GetTableGraphDataByQuestionId
    @AppUserId BIGINT,
    @ActivityId BIGINT,
    @EstablishmentId NVARCHAR(MAX) = '0',
    @UserId NVARCHAR(MAX) = '',
    @FromDate DATETIME = '',
    @ToDate DATETIME = '',
    @FormStatus VARCHAR(50) = '',
    @QuestionId BIGINT,
    @Title NVARCHAR(500) = ''
AS
BEGIN

SET NOCOUNT ON;

    DECLARE @OptionList NVARCHAR(MAX);
    SELECT @OptionList = COALESCE(@OptionList + ', ', '') + CONVERT(NVARCHAR(50), ISNULL(Id, ''))
    FROM dbo.SeenClientOptions
    WHERE QuestionId = @QuestionId;
    IF (@EstablishmentId = '0')
    BEGIN
        SET @EstablishmentId =
        (
            SELECT dbo.AllEstablishmentByAppUserAndActivity(@AppUserId, @ActivityId)
        );
    END;
    IF @UserId IS NULL
    BEGIN
        SET @UserId = N'0';
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
                   SELECT Data FROM dbo.Split(@UserId, ',')
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
            ON CD.QuestionTypeId = 10 AND CD.Detail = AU.Email
               AND AU.Id = @AppUserId
               AND ISNULL(CD.IsDeleted, 0) = 0
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
                        SELECT Data FROM dbo.Split(@UserId, ',')
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
    FROM dbo.AppManagerUserRights AMUR WITH(NOLOCK)
        INNER JOIN dbo.AppUser AU WITH(NOLOCK)
            ON AU.Id = AMUR.ManagerUserId
               AND AMUR.UserId = @AppUserId
               AND AMUR.IsDeleted = 0
               AND AU.IsActive = 1
               AND AU.IsDeleted = 0
               AND
               (
                   (AMUR.UserId IN
                    (
                        SELECT Data FROM dbo.Split(@UserId, ',')
                    )
                   )
                   OR @UserId = '0'
               )
               AND AMUR.EstablishmentId IN
                   (
                       SELECT Data FROM dbo.Split(@EstablishmentId, ',')
                   )
    GROUP BY AMUR.ManagerUserId,
             AU.Name,
             AU.ImageName,
             AU.Email,
             AU.Mobile,
             AU.GroupId
    ORDER BY Name ASC;

    DECLARE @tblCount TABLE
    (
        Id BIGINT IDENTITY(1, 1),
        OptionId BIGINT NOT NULL,
        NAME NVARCHAR(500) NOT NULL
    );
    DECLARE @Result TABLE
    (
        Id BIGINT IDENTITY(1, 1),
        OptionId BIGINT NOT NULL,
        Score DECIMAL(18, 2) NOT NULL,
        IsResolved VARCHAR(100)
    );
    DECLARE @EndDate DATETIME;

    DECLARE @SeenClientId BIGINT,
            @QuestionIdList NVARCHAR(MAX),
            @QuestionTypeId BIGINT;
    SELECT TOP 1
           @SeenClientId = Eg.SeenClientId,
           @UserId = CASE
                         WHEN E.EstablishmentGroupId IS NULL
                              AND Eg.EstablishmentGroupType = 'Customer' THEN
                             '0'
                         ELSE
                             @UserId
                     END
    FROM dbo.EstablishmentGroup AS Eg WITH(NOLOCK)
        INNER JOIN dbo.Establishment AS E WITH(NOLOCK)
            ON Eg.Id = E.EstablishmentGroupId
    WHERE Eg.Id = @ActivityId
          AND E.IsDeleted = 0;
    IF @QuestionId > 0
    BEGIN
        SET @QuestionIdList = N'';
        BEGIN
            SELECT @QuestionTypeId = QuestionTypeId
            FROM dbo.SeenClientQuestions WITH(NOLOCK)
            WHERE Id = @QuestionId;
        END;
    END;
    ELSE
    BEGIN
        PRINT 'Numeric';
        SET @QuestionTypeId = 19;
        BEGIN
            SELECT @QuestionIdList = COALESCE(@QuestionIdList + ',', '') + CONVERT(NVARCHAR(50), Id)
            FROM dbo.SeenClientQuestions WITH(NOLOCK)
            WHERE SeenClientId = @SeenClientId
                  AND TableGroupName = @Title
                  AND QuestionTypeId = 19
                  AND IsDeleted = 0;
        END;
    END;

    DECLARE @AnsStatus NVARCHAR(50) = '';
        SET @AnsStatus = @FormStatus;

    SET @FromDate = CONVERT(DATE, @FromDate);
    SET @EndDate = CONVERT(DATE, @ToDate);

    BEGIN
        IF @QuestionTypeId = 7
        BEGIN
            INSERT INTO @tblCount
            (
                OptionId,
                Name
            )
            SELECT 1,
                   'Yes';
            INSERT INTO @tblCount
            (
                OptionId,
                Name
            )
            SELECT 2,
                   'No';
        END;
        ELSE IF @QuestionTypeId = 19
        BEGIN
            INSERT INTO @tblCount
            (
                OptionId,
                Name
            )
            SELECT Id,
                   ShortName
            FROM dbo.SeenClientQuestions WITH(NOLOCK)
            WHERE SeenClientId = @SeenClientId
                  AND TableGroupName = @Title
                  AND QuestionTypeId = 19
                  AND IsDeleted = 0;
        END;
        ELSE
        BEGIN
            INSERT INTO @tblCount
            (
                OptionId,
                Name
            )
            SELECT Id,
                   Name
            FROM dbo.SeenClientOptions WITH(NOLOCK)
            WHERE QuestionId = @QuestionId
                  AND IsDeleted = 0
                  AND Name != '-- Select --';
        END;
    END;

    SET @FromDate = CONVERT(DATE, @FromDate);
    SET @EndDate = CONVERT(DATE, @EndDate);

    BEGIN
        IF @QuestionTypeId <> 19
        BEGIN
            INSERT INTO @Result
            (
                OptionId,
                Score,
                IsResolved
            )
            SELECT CASE
                       WHEN @QuestionTypeId = 7 THEN
                (CASE AM.Detail
                     WHEN 'Yes' THEN
                         1
                     ELSE
                         2
                 END
                )
                       WHEN @QuestionTypeId = 14
                            OR @QuestionTypeId = 15 THEN
                (CASE
                     WHEN AM.Detail LIKE 'Yes,' THEN
                         1
                     ELSE
                         2
                 END
                )
                       ELSE
                           ISNULL(AM.Data, '')
                   END,
                   COUNT(1),
                   IsResolved
            FROM
            (
                SELECT DISTINCT
                       A.Detail,
                       O.Data,
                       AM.ReportId,
                       AM.IsResolved
                FROM dbo.View_SeenClientAnswerMaster AS AM
                    INNER JOIN dbo.SeenClientAnswers AS A WITH(NOLOCK)
                        ON AM.ReportId = A.SeenClientAnswerMasterId
                    INNER JOIN dbo.SeenClientQuestions AS Q WITH(NOLOCK)
                        ON Q.Id = A.QuestionId
                    CROSS APPLY dbo.Split(ISNULL(OptionId, ''), ',') AS O
                    INNER JOIN
                    (SELECT Data FROM dbo.Split(@EstablishmentId, ',') ) AS RE
                        ON (
                               RE.Data = AM.EstablishmentId
                               OR @EstablishmentId = '0'
                           )
                    INNER JOIN
                    (SELECT UIT.ContactMasterId FROM @UserInfo UIT) AS RU
                        ON RU.ContactMasterId = AM.ContactMasterId
                           OR @UserId = '0'
                    INNER JOIN
                    (SELECT Data FROM dbo.Split(@QuestionIdList, ',') ) AS RQ
                        ON RQ.Data = A.QuestionId
                           OR Q.Id = @QuestionId
                WHERE AM.ActivityId = @ActivityId
                      AND AM.IsUnAllocated = 0
                      AND O.Data IS NOT NULL
                      AND ISNULL(AM.IsDisabled, 0) = 0
                      AND
                      (
                          AM.IsPositive = @AnsStatus
                          OR @AnsStatus = ''
                      )
                      AND CAST(AM.CreatedOn AS DATE)
                      BETWEEN @FromDate AND @EndDate
					  AND (IsResolved = @FormStatus OR @FormStatus = '')
					  AND EstablishmentId In (SELECT Data FROM dbo.Split(@EstablishmentId, ','))
            ) AS AM
            GROUP BY CASE
                         WHEN @QuestionTypeId = 7 THEN
                (CASE AM.Detail
                     WHEN 'Yes' THEN
                         1
                     ELSE
                         2
                 END
                )
                         WHEN @QuestionTypeId = 14
                              OR @QuestionTypeId = 15 THEN
                (CASE
                     WHEN AM.Detail LIKE 'Yes,' THEN
                         1
                     ELSE
                         2
                 END
                )
                         ELSE
                             ISNULL(AM.Data, '')
                     END,
                     AM.IsResolved;
        END;
        ELSE
        BEGIN
            INSERT INTO @Result
            (
                OptionId,
                Score,
                IsResolved
            )
            SELECT Id,
                   SUM(ISNULL(details,0)) / CASE ISNULL(T.TotalEntry, 1)
                                      WHEN 0 THEN
                                          1
                                      ELSE
                                          ISNULL(T.TotalEntry, 1)
                                  END AS Details,
                   IsResolved
            FROM
            (
                SELECT Q.Id,
                       SUM(ISNULL(CAST(A.Detail AS DECIMAL(18, 2)),0)) / CASE MAX(ISNULL(A.RepeatCount, 1))
                                                                   WHEN 0 THEN
                                                                       1
                                                                   ELSE
                                                                       MAX(ISNULL(A.RepeatCount, 1))
                                                               END AS details,
                       0 AS TotalEntry,
                       A.SeenClientAnswerMasterId AS 'C',
                       AM.IsResolved
                FROM dbo.View_SeenClientAnswerMaster AS AM
                    INNER JOIN dbo.SeenClientAnswers AS A WITH(NOLOCK)
                        ON AM.ReportId = A.SeenClientAnswerMasterId
                    INNER JOIN dbo.SeenClientQuestions AS Q WITH(NOLOCK)
                        ON Q.Id = A.QuestionId
                    CROSS APPLY dbo.Split(ISNULL(OptionId, ''), ',') AS O
                    INNER JOIN
                    (SELECT Data FROM dbo.Split(@EstablishmentId, ',') ) AS RE
                        ON (
                               RE.Data = AM.EstablishmentId
                               OR @EstablishmentId = '0'
                           )
                    INNER JOIN
                    (SELECT UIT.ContactMasterId FROM @UserInfo UIT) AS RU
                        ON RU.ContactMasterId = AM.ContactMasterId
                           OR @UserId = '0'
                    INNER JOIN
                    (SELECT Data FROM dbo.Split(@QuestionIdList, ',') ) AS RQ
                        ON RQ.Data = A.QuestionId
                           OR Q.Id = @QuestionId
                WHERE AM.ActivityId = @ActivityId
                      AND AM.IsUnAllocated = 0
                      AND A.Detail IS NOT NULL
                      AND A.Detail NOT LIKE '%[^0-9.]%'
                      AND A.QuestionTypeId = 19
                      AND ISNULL(AM.IsDisabled, 0) = 0
                      AND
                      (
                          AM.IsPositive = @AnsStatus
                          OR @AnsStatus = ''
                      )
                      AND CAST(AM.CreatedOn AS DATE)
                      BETWEEN @FromDate AND @EndDate
					   AND (IsResolved = @FormStatus OR @FormStatus = '')
					  AND EstablishmentId In (SELECT Data FROM dbo.Split(@EstablishmentId, ','))
                GROUP BY Q.Id,
                         A.SeenClientAnswerMasterId,
                         AM.IsResolved
            ) AS T
            GROUP BY T.Id,
                     TotalEntry,
                     T.IsResolved;
        END;
        IF @QuestionTypeId <> 19
        BEGIN
            INSERT INTO @Result
            (
                OptionId,
                Score,
                IsResolved
            )
            SELECT CASE
                       WHEN @QuestionTypeId = 7 THEN
                (CASE AM.Detail
                     WHEN 'Yes' THEN
                         1
                     ELSE
                         2
                 END
                )
                       WHEN @QuestionTypeId = 14
                            OR @QuestionTypeId = 15 THEN
                (CASE
                     WHEN AM.Detail LIKE 'Yes,' THEN
                         1
                     ELSE
                         2
                 END
                )
                       ELSE
                           ISNULL(AM.Data, '')
                   END,
                   0,
                   IsResolved
            FROM
            (
                SELECT DISTINCT
                       A.Detail,
                       O.Data,
                       AM.ReportId,
                       AM.IsResolved
                FROM dbo.View_SeenClientAnswerMaster AS AM
                    INNER JOIN dbo.SeenClientAnswers AS A WITH(NOLOCK)
                        ON AM.ReportId = A.SeenClientAnswerMasterId
                    INNER JOIN dbo.SeenClientQuestions AS Q WITH(NOLOCK)
                        ON Q.Id = A.QuestionId
                    CROSS APPLY dbo.Split(ISNULL(OptionId, ''), ',') AS O
                    INNER JOIN
                    (SELECT Data FROM dbo.Split(@QuestionIdList, ',') ) AS RQ
                        ON RQ.Data = A.QuestionId
                           OR Q.Id = @QuestionId
                WHERE AM.ActivityId = @ActivityId
                      AND AM.IsUnAllocated = 0
                      AND O.Data IS NOT NULL
                      AND ISNULL(AM.IsDisabled, 0) = 0
                      AND
                      (
                          AM.IsPositive = @AnsStatus
                          OR @AnsStatus = ''
                      )
                      AND CAST(AM.CreatedOn AS DATE)
                      BETWEEN @FromDate AND @EndDate
					   AND (IsResolved = @FormStatus OR @FormStatus = '')
					  AND EstablishmentId In (SELECT Data FROM dbo.Split(@EstablishmentId, ','))
            ) AS AM
            GROUP BY CASE
                         WHEN @QuestionTypeId = 7 THEN
                (CASE AM.Detail
                     WHEN 'Yes' THEN
                         1
                     ELSE
                         2
                 END
                )
                         WHEN @QuestionTypeId = 14
                              OR @QuestionTypeId = 15 THEN
                (CASE
                     WHEN AM.Detail LIKE 'Yes,' THEN
                         1
                     ELSE
                         2
                 END
                )
                         ELSE
                             ISNULL(AM.Data, '')
                     END,
                     AM.IsResolved;
        END;
        ELSE
        BEGIN
            INSERT INTO @Result
            (
                OptionId,
                Score,
                IsResolved
            )
            SELECT Q.Id,
                   0,
                   IsResolved
            FROM dbo.View_SeenClientAnswerMaster AS AM
                INNER JOIN dbo.SeenClientAnswers AS A WITH(NOLOCK)
                    ON AM.ReportId = A.SeenClientAnswerMasterId
                INNER JOIN dbo.SeenClientQuestions AS Q WITH(NOLOCK)
                    ON Q.Id = A.QuestionId
                INNER JOIN
                (SELECT Data FROM dbo.Split(@OptionList, ',') ) AS O
                    ON O.Data = A.OptionId
                INNER JOIN
                (SELECT Data FROM dbo.Split(@QuestionIdList, ',') ) AS RQ
                    ON RQ.Data = A.QuestionId
                       OR Q.Id = @QuestionId
            WHERE AM.ActivityId = @ActivityId
                  AND AM.IsUnAllocated = 0
                  AND A.Detail IS NOT NULL
                  AND A.Detail NOT LIKE '%[^0-9.]%'
                  AND A.QuestionTypeId = 19
                  AND ISNULL(AM.IsDisabled, 0) = 0
                  AND
                  (
                      AM.IsPositive = @AnsStatus
                      OR @AnsStatus = ''
                  )
                  AND CAST(AM.CreatedOn AS DATE)
                  BETWEEN @FromDate AND @EndDate
				   AND (IsResolved = @FormStatus OR @FormStatus = '')
					  AND EstablishmentId In (SELECT Data FROM dbo.Split(@EstablishmentId, ','))
            GROUP BY Q.Id,
                     AM.IsResolved;
        END;
    END;

    SELECT Tc.OptionId,
           Tc.Name,
           ISNULL(SUM(ISNULL(R.Score,0)), 0) AS AllCounts,
           ISNULL(
           (
               SELECT SUM(ISNULL(Score,0))
               FROM @Result
               WHERE IsResolved = 'Unresolved'
                     AND OptionId = Tc.OptionId
           ),
           0
                 ) AS OpenCounts,
           @QuestionId AS QuestionId,
           @Title AS Title
    FROM @tblCount AS Tc
        LEFT OUTER JOIN @Result AS R
            ON Tc.OptionId = R.OptionId
    GROUP BY Tc.OptionId,
             Tc.Name
    ORDER BY Tc.OptionId;

SET NOCOUNT OFF;
END;


