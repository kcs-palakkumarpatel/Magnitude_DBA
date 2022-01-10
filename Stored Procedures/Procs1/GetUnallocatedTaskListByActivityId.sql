-- =============================================
-- Author:      Krishna Panchal
-- Create Date: 06-May-2021
-- Description: Get Unallocated Task List By ActivityId
-- SP call: GetUnallocatedTaskListByActivityId 5819, 6130,'0','','','',0,'',0,1,'',1,50
-- GetUnallocatedTaskListByActivityId 2101, 19553,'0','1824','','','','',0,0,'',1,50
-- =============================================
CREATE PROCEDURE [dbo].[GetUnallocatedTaskListByActivityId]
    @ActivityId BIGINT,
    @AppUserId BIGINT,
    @EstablishmentIds VARCHAR(MAX) = '0',
    @UserIds VARCHAR(MAX) = '',
    @FromDate DATETIME = NULL,
    @ToDate DATETIME = NULL,
    @SmileyType VARCHAR(100) = '',
    @StatusIds VARCHAR(200) = '',
    @IsForDeleted BIT = 0,
    @IsForUnallocated BIT = 0,
    @SearchText VARCHAR(100) = '',
    @Page INT = 1,
    @Rows INT = 50
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @EstablishmentId AS TABLE (id BIGINT);
    DECLARE @UserId AS TABLE
    (
        UserId VARCHAR(MAX),
        ContactMasterId BIGINT
    );
    DECLARE @Url NVARCHAR(100),
            @GraphicImagePath NVARCHAR(100),
            @ThumbnailUrl NVARCHAR(100),
            @Count BIGINT = 0,
            @IsManager BIT,
            @ServerDate DATETIME = GETUTCDATE();

    SELECT @Url = KeyValue,
           @ThumbnailUrl = KeyValue + N'Thumbnail/'
    FROM dbo.AAAAConfigSettings
    WHERE KeyName = 'DocViewerRootFolderPathWebApp';

    SELECT @GraphicImagePath = KeyValue
    FROM dbo.AAAAConfigSettings
    WHERE KeyName = 'DocViewerRootFolderPathCMS';

    IF (@EstablishmentIds = '0')
    BEGIN
        INSERT INTO @EstablishmentId
        SELECT EST.Id
        FROM dbo.Establishment AS EST WITH (NOLOCK)
            INNER JOIN dbo.AppUserEstablishment WITH (NOLOCK)
                ON EST.EstablishmentGroupId = @ActivityId
                   AND AppUserEstablishment.AppUserId = @AppUserId
                   AND AppUserEstablishment.EstablishmentId = EST.Id
                   AND AppUserEstablishment.IsDeleted = 0;
    END;
    ELSE
    BEGIN
        INSERT INTO @EstablishmentId
        SELECT Data
        FROM dbo.Split(@EstablishmentIds, ',');
    END;

    SELECT @IsManager = IsAreaManager
    FROM dbo.AppUser WITH (NOLOCK)
    WHERE Id = @AppUserId;

    IF EXISTS
    (
        SELECT 1
        FROM dbo.AppUserEstablishment WITH (NOLOCK)
            INNER JOIN dbo.AppUser WITH (NOLOCK)
                ON AppUser.Id = AppUserEstablishment.AppUserId
                   AND IsAreaManager = 0
                   AND IsActive = 1
                   AND AppUser.IsDeleted = 0
                   AND dbo.AppUserEstablishment.IsDeleted = 0
            INNER JOIN dbo.Vw_Establishment AS E WITH (NOLOCK)
                ON E.Id = AppUserEstablishment.EstablishmentId
                   AND E.EstablishmentGroupId = @ActivityId
        UNION
        SELECT 1
        FROM dbo.AppUserEstablishment WITH (NOLOCK)
            INNER JOIN dbo.AppUser WITH (NOLOCK)
                ON AppUser.Id = AppUserEstablishment.AppUserId
                   AND AppUserId = @AppUserId
                   AND AppUser.IsDeleted = 0
                   AND IsActive = 1
                   AND dbo.AppUserEstablishment.IsDeleted = 0
            INNER JOIN dbo.Vw_Establishment AS E WITH (NOLOCK)
                ON E.Id = AppUserEstablishment.EstablishmentId
                   AND E.EstablishmentGroupId = @ActivityId
    )
    BEGIN
        SET @Count = 1;
    END;

    IF @Count = 0
    BEGIN
        IF EXISTS
        (
            SELECT 1
            FROM AppManagerUserRights WITH (NOLOCK)
                INNER JOIN dbo.AppUser WITH (NOLOCK)
                    ON dbo.AppUser.Id = AppManagerUserRights.ManagerUserId
                       AND AppManagerUserRights.UserId = @AppUserId
                       AND AppManagerUserRights.IsDeleted = 0
                       AND IsActive = 1
                INNER JOIN @EstablishmentId e
                    ON e.id = AppManagerUserRights.EstablishmentId
        )
        BEGIN
            SET @Count = 1;
        END;
    END;

    IF (@IsManager = 1)
    BEGIN
        IF (@Count > 0)
        BEGIN
            INSERT INTO @UserId
            SELECT AppUserId,
                   (
                       SELECT TOP 1
                           CD.ContactMasterId
                       FROM dbo.ContactDetails CD WITH (NOLOCK)
                           INNER JOIN dbo.ContactMaster CM WITH (NOLOCK)
                               ON CM.Id = CD.ContactMasterId
                                  AND CM.GroupId = dbo.AppUser.GroupId
								  AND CM.IsDeleted = 0
								  AND CD.IsDeleted = 0
								  AND CD.IsDeleted = 0
                       WHERE CD.QuestionTypeId = 10
                             AND dbo.AppUser.Email = CD.Detail
                             AND ISNULL(CD.IsDeleted, 0) = 0
                       ORDER BY CD.ContactMasterId DESC
                   )
            FROM dbo.AppUserEstablishment WITH (NOLOCK)
                INNER JOIN dbo.AppUser WITH (NOLOCK)
                    ON AppUser.Id = AppUserEstablishment.AppUserId
                       AND AppUserId = @AppUserId
                       AND AppUser.IsDeleted = 0
                       AND dbo.AppUserEstablishment.IsDeleted = 0
                       AND IsActive = 1
                INNER JOIN @EstablishmentId e
                    ON e.id = dbo.AppUserEstablishment.EstablishmentId
            UNION
            SELECT AppUserId,
                   (
                       SELECT TOP 1
                           CD.ContactMasterId
                       FROM dbo.ContactDetails CD WITH (NOLOCK)
                           INNER JOIN dbo.ContactMaster CM WITH (NOLOCK)
                               ON CM.Id = CD.ContactMasterId
                                  AND CM.GroupId = dbo.AppUser.GroupId
								  AND CM.IsDeleted = 0
								  AND CD.IsDeleted = 0
                       WHERE CD.QuestionTypeId = 10
                             AND dbo.AppUser.Email = CD.Detail
                             AND ISNULL(CD.IsDeleted, 0) = 0
                       ORDER BY CD.ContactMasterId DESC
                   )
            FROM dbo.AppUserEstablishment WITH (NOLOCK)
                INNER JOIN dbo.AppUser WITH (NOLOCK)
                    ON AppUser.Id = AppUserEstablishment.AppUserId
                       AND IsAreaManager = 0
                       AND AppUser.IsDeleted = 0
                       AND dbo.AppUserEstablishment.IsDeleted = 0
                       AND IsActive = 1
                INNER JOIN @EstablishmentId e
                    ON e.id = dbo.AppUserEstablishment.EstablishmentId
            UNION
            SELECT ManagerUserId,
                   (
                       SELECT TOP 1
                           CD.ContactMasterId
                       FROM dbo.ContactDetails CD WITH (NOLOCK)
                           INNER JOIN dbo.ContactMaster CM WITH (NOLOCK)
                               ON CM.Id = CD.ContactMasterId
                                  AND CM.GroupId = dbo.AppUser.GroupId
								  AND CM.IsDeleted = 0
								  AND CD.IsDeleted = 0
                       WHERE CD.QuestionTypeId = 10
                             AND dbo.AppUser.Email = CD.Detail
                             AND ISNULL(CD.IsDeleted, 0) = 0
                       ORDER BY CD.ContactMasterId DESC
                   )
            FROM AppManagerUserRights WITH (NOLOCK)
                INNER JOIN dbo.AppUser WITH (NOLOCK)
                    ON dbo.AppUser.Id = AppManagerUserRights.ManagerUserId
                       AND AppManagerUserRights.UserId = @AppUserId
                       AND AppUser.IsDeleted = 0
                       AND AppManagerUserRights.IsDeleted = 0
                       AND IsActive = 1
                INNER JOIN @EstablishmentId e
                    ON e.id = AppManagerUserRights.EstablishmentId
                INNER JOIN dbo.AppUserEstablishment WITH (NOLOCK)
                    ON AppManagerUserRights.EstablishmentId = AppUserEstablishment.EstablishmentId;
        END;
        ELSE
        BEGIN
            INSERT INTO @UserId
            SELECT DISTINCT
                U.Id AS UserId,
                (
                    SELECT TOP 1
                        CD.ContactMasterId
                    FROM dbo.ContactDetails CD WITH (NOLOCK)
                        INNER JOIN dbo.ContactMaster CM WITH (NOLOCK)
                            ON CM.Id = CD.ContactMasterId
                               AND CM.GroupId = LoginUser.GroupId
							   AND CM.IsDeleted = 0
							   AND CD.IsDeleted = 0
                    WHERE CD.QuestionTypeId = 10
                          AND LoginUser.Email = CD.Detail
                          AND ISNULL(CD.IsDeleted, 0) = 0
                    ORDER BY CD.ContactMasterId DESC
                )
            FROM dbo.AppUserEstablishment AS UE
                INNER JOIN dbo.AppUser AS LoginUser WITH (NOLOCK)
                    ON UE.AppUserId = LoginUser.Id
                       AND LoginUser.Id = @AppUserId
                       AND LoginUser.IsDeleted = 0
                       AND UE.IsDeleted = 0
                INNER JOIN dbo.Vw_Establishment AS E
                    ON UE.EstablishmentId = E.Id
                       AND E.IsDeleted = 0
                INNER JOIN dbo.EstablishmentGroup AS Eg WITH (NOLOCK)
                    ON Eg.Id = E.EstablishmentGroupId
                INNER JOIN dbo.AppUserEstablishment AS AppUser WITH (NOLOCK)
                    ON E.Id = AppUser.EstablishmentId
                       AND (
                               UE.EstablishmentType = AppUser.EstablishmentType
                               OR LoginUser.IsAreaManager = 1
                           )
                INNER JOIN dbo.AppUser AS U WITH (NOLOCK)
                    ON AppUser.AppUserId = U.Id
                       AND (
                               U.IsAreaManager = 0
                               OR U.Id = @AppUserId
                           )
                       AND U.IsDeleted = 0
                       AND AppUser.IsDeleted = 0;
        END;
    END;
    ELSE
    BEGIN
        INSERT INTO @UserId
        SELECT U.Id AS UserId,
               (
                   SELECT TOP 1
                       CD.ContactMasterId
                   FROM dbo.ContactDetails CD WITH (NOLOCK)
                       INNER JOIN dbo.ContactMaster CM WITH (NOLOCK)
                           ON CM.Id = CD.ContactMasterId
                              AND CM.GroupId = LoginUser.GroupId
							  AND CM.IsDeleted = 0
							  AND CD.IsDeleted = 0
                   WHERE CD.QuestionTypeId = 10
                         AND LoginUser.Email = CD.Detail
                         AND ISNULL(CD.IsDeleted, 0) = 0
                   ORDER BY CD.ContactMasterId DESC
               )
        FROM dbo.AppUserEstablishment AS UE WITH (NOLOCK)
            INNER JOIN dbo.AppUser AS LoginUser WITH (NOLOCK)
                ON UE.AppUserId = LoginUser.Id
                   AND LoginUser.Id = @AppUserId
                   AND LoginUser.IsDeleted = 0
            INNER JOIN dbo.Establishment AS E WITH (NOLOCK)
                ON UE.EstablishmentId = E.Id
            INNER JOIN dbo.EstablishmentGroup AS Eg WITH (NOLOCK)
                ON Eg.Id = E.EstablishmentGroupId
            INNER JOIN dbo.AppUserEstablishment AS AppUser WITH (NOLOCK)
                ON E.Id = AppUser.EstablishmentId
                   AND (
                           UE.EstablishmentType = AppUser.EstablishmentType
                           OR LoginUser.IsAreaManager = 1
                       )
            INNER JOIN dbo.AppUser AS U WITH (NOLOCK)
                ON AppUser.AppUserId = U.Id
                   AND (
                           U.IsAreaManager = 0
                           OR U.Id = @AppUserId
                       )
        WHERE U.Id = @AppUserId
              AND E.IsDeleted = 0
              AND UE.IsDeleted = 0
              AND AppUser.IsDeleted = 0
              AND U.IsDeleted = 0;
    END;

    IF OBJECT_ID('tempdb..#TempTable', 'U') IS NOT NULL
        DROP TABLE #TempTable;
    CREATE TABLE #TempTable
    (
        ReportId BIGINT,
        EstablishmentId BIGINT,
        EstablishmentName VARCHAR(500),
        AppUserId BIGINT,
        UserName VARCHAR(100),
        IsOutStanding BIT,
        AnswerStatus NVARCHAR(10),
        TimeOffSet INT,
        CreatedOn DATETIME,
        UpdatedOn DATETIME,
        PI DECIMAL(18, 2),
        SmileType NVARCHAR(20),
        Latitude NVARCHAR(50),
        Longitude NVARCHAR(50),
        SeenClientAnswerMasterId BIGINT,
        ActivityId BIGINT,
        CaptureDate DATETIME,
        StatusId BIGINT,
        StatusName NVARCHAR(100),
        StatusImage NVARCHAR(1000),
        StatusTime NVARCHAR(100),
        StatusCounter NVARCHAR(100)
    );

    CREATE TABLE #FinalTempTable
    (
        ReportId BIGINT,
        EstablishmentId BIGINT,
        EstablishmentName VARCHAR(500),
        AppUserId BIGINT,
        UserName VARCHAR(100),
        IsOutStanding BIT,
        AnswerStatus NVARCHAR(10),
        TimeOffSet INT,
        CreatedOn DATETIME,
        UpdatedOn DATETIME,
        PI DECIMAL(18, 2),
        SmileType NVARCHAR(20),
        Latitude NVARCHAR(50),
        Longitude NVARCHAR(50),
        SeenClientAnswerMasterId BIGINT,
        ActivityId BIGINT,
        CaptureDate DATETIME,
        LogedByHeader VARCHAR(1000),
        StatusId BIGINT,
        StatusName NVARCHAR(100),
        StatusImage NVARCHAR(1000),
        StatusTime NVARCHAR(100),
        StatusCounter NVARCHAR(100),
        IsRecurringApplied BIT
    );

    IF (@IsForDeleted = 0)
    BEGIN
        INSERT INTO #TempTable
        (
            ReportId,
            EstablishmentId,
            EstablishmentName,
            AppUserId,
            UserName,
            IsOutStanding,
            AnswerStatus,
            TimeOffSet,
            CreatedOn,
            UpdatedOn,
            PI,
            SmileType,
            Latitude,
            Longitude,
            SeenClientAnswerMasterId,
            ActivityId,
            CaptureDate,
            StatusId,
            StatusName,
            StatusImage,
            StatusTime,
            StatusCounter
        )
        SELECT DISTINCT
            A.ReportId,
            A.EstablishmentId,
            A.EstablishmentName,
            ISNULL(A.UserId, 0) AS AppUserId,
            A.UserName,
            A.IsOutStanding,
            A.AnswerStatus,
            A.TimeOffSet,
            A.CreatedOn,
            dbo.ChangeDateFormat(A.UpdatedOn, 'dd/MMM/yy HH:mm') AS UpdatedOn,
            IIF(1 = 1, A.[PI], IIF(A.[PI] >= 0.00, A.[PI], -1)) AS PI,
            A.SmileType,
            A.Latitude,
            A.Longitude,
            A.SeenClientAnswerMasterId,
            A.ActivityId,
            dbo.ChangeDateFormat(A.CreatedOn, 'dd/MMM/yy HH:mm') AS CaptureDate,
            A.StatusId,
            A.StatusName,
            A.StatusImage,
            CASE
                WHEN A.StatusTime <> '' THEN
                (
                    SELECT FORMAT(CAST(A.StatusTime AS DATETIME), 'dd/MMM/yy HH:mm', 'en-us')
                )
                ELSE
                    ''
            END AS StatusTime,
            (CASE
                 WHEN A.StatusCounter <> '' THEN
                 (
                     SELECT dbo.DifferenceDatefun(
                                                     ISNULL(A.StatusTime, @ServerDate),
                                                     DATEADD(MINUTE, A.TimeOffSet, @ServerDate)
                                                 )
                 )
                 ELSE
                     ''
             END
            ) AS StatusCounter
        FROM dbo.View_AllAnswerMaster (NOLOCK) AS A
            INNER JOIN @EstablishmentId e
                ON A.EstablishmentId = e.id
            INNER JOIN @UserId AS U
                ON U.ContactMasterId = A.ContactMasterId
                   OR U.UserId = ISNULL(A.TransferFromUserId, 0)
                   OR A.UserId = 0
            LEFT OUTER JOIN dbo.FlagMaster AS F WITH (NOLOCK)
                ON F.ReportId = A.ReportId
                   AND F.Type IN ( 1, 2 )
                   AND F.AppUserId = A.UserId
            LEFT JOIN dbo.tblContact cnt WITH (NOLOCK)
                ON cnt.ContactMasterId = A.ContactMasterId
        WHERE A.ActivityId = @ActivityId
              AND (
                      (A.ContactMasterId IN (
                                                SELECT Data FROM dbo.Split(@UserIds, ',')
                                            )
                      )
                      OR @UserIds = ''
                  )
              AND (
                      (CAST(A.CreatedOn AS DATE)
              BETWEEN CAST((DATEADD(MINUTE, A.TimeOffSet, @FromDate)) AS DATE) AND CAST((DATEADD(
                                                                                                    MINUTE,
                                                                                                    A.TimeOffSet,
                                                                                                    @ToDate
                                                                                                )
                                                                                        ) AS DATE)
                      )
                      OR (
                             @FromDate = ''
                             AND @ToDate = ''
                         )
                  )
              AND (
                      (A.EstablishmentId IN (
                                                SELECT Data FROM dbo.Split(@EstablishmentIds, ',')
                                            )
                      )
                      OR @EstablishmentIds = '0'
                  )
              AND (
                      (A.SmileType IN (
                                          SELECT Data FROM dbo.Split(@SmileyType, ',')
                                      )
                      )
                      OR @SmileyType = ''
                  )
              AND A.AnswerStatus = 'Unresolved'
              AND A.IsOut = 1
              AND ISNULL(A.IsUnAllocated, 0) = CASE
                                                   WHEN @IsForUnallocated = 0 THEN
                                                       0
                                                   ELSE
                                                       1
                                               END
              AND (
                      @StatusIds = ''
                      OR (
                             SELECT SH.EstablishmentStatusId
                             FROM dbo.StatusHistory SH
                             WHERE SH.Id = A.StatusHistoryId
                         ) IN (
                                  SELECT Data FROM dbo.Split(@StatusIds, ',')
                              )
                  );
    --ORDER BY ReportId DESC OFFSET ((@Page - 1) * @Rows) ROWS FETCH NEXT @Rows ROWS ONLY;
    END;
    ELSE
    BEGIN
        INSERT INTO #TempTable
        (
            ReportId,
            EstablishmentId,
            EstablishmentName,
            AppUserId,
            UserName,
            IsOutStanding,
            AnswerStatus,
            TimeOffSet,
            CreatedOn,
            UpdatedOn,
            PI,
            SmileType,
            Latitude,
            Longitude,
            SeenClientAnswerMasterId,
            ActivityId,
            CaptureDate
        )
        SELECT DISTINCT
            A.ReportId,
            A.EstablishmentId,
            A.EstablishmentName,
            ISNULL(A.UserId, 0) AS AppUserId,
            A.UserName,
            A.IsOutStanding,
            A.AnswerStatus,
            A.TimeOffSet,
            A.CreatedOn,
            dbo.ChangeDateFormat(A.UpdatedOn, 'dd/MMM/yy HH:mm') AS UpdatedOn,
            IIF(1 = 1, A.[PI], IIF(A.[PI] >= 0.00, A.[PI], -1)) AS PI,
            A.SmileType,
            A.Latitude,
            A.Longitude,
            A.SeenClientAnswerMasterId,
            A.ActivityId,
            dbo.ChangeDateFormat(A.CreatedOn, 'dd/MMM/yy HH:mm') AS CaptureDate
        FROM dbo.View_AllDeletedAnswerMaster (NOLOCK) AS A
            INNER JOIN @EstablishmentId e
                ON A.EstablishmentId = e.id
            INNER JOIN @UserId AS U
                ON U.ContactMasterId = A.ContactMasterId
                   OR U.UserId = ISNULL(A.TransferFromUserId, 0)
                   OR A.UserId = 0
            LEFT OUTER JOIN dbo.FlagMaster AS F WITH (NOLOCK)
                ON F.ReportId = A.ReportId
                   AND F.Type IN ( 1, 2 )
                   AND F.AppUserId = A.UserId
            LEFT JOIN dbo.tblContact cnt
                ON cnt.ContactMasterId = A.ContactMasterId
        WHERE A.ActivityId = @ActivityId
              AND A.IsOut = 1
              AND ((CAST(A.DeletedOn AS DATE)
              BETWEEN CAST((DATEADD(MINUTE, A.TimeOffSet, DATEADD(DAY, -7, @ServerDate))) AS DATE) AND CAST((DATEADD(
                                                                                                                        MINUTE,
                                                                                                                        A.TimeOffSet,
                                                                                                                        @ServerDate
                                                                                                                    )
                                                                                                            ) AS DATE)
                   )
                  )
        ORDER BY A.ReportId;
    END;

    DECLARE @ReportIds AS TABLE
    (
        ReportId BIGINT,
        EstablishmentId BIGINT
    );
    INSERT INTO @ReportIds
    (
        ReportId,
        EstablishmentId
    )
    SELECT DISTINCT
        Am.Id AS ReportId,
        Am.EstablishmentId
    FROM dbo.SeenClientAnswerMaster AS Am WITH (NOLOCK)
        INNER JOIN dbo.AppUser U
            ON Am.AppUserId = U.Id
        INNER JOIN dbo.SeenClient AS Qr WITH (NOLOCK)
            ON Am.SeenClientId = Qr.Id
        INNER JOIN dbo.SeenClientQuestions AS Q WITH (NOLOCK)
            ON Qr.Id = Q.SeenClientId
               AND Q.IsDisplayInDetail = 1
               AND Q.QuestionTypeId NOT IN ( 25 )
        INNER JOIN dbo.SeenClientAnswers AS A WITH (NOLOCK)
            ON Am.Id = A.SeenClientAnswerMasterId
               AND Q.Id = A.QuestionId
               AND (
                       A.Id IS NOT NULL
                       OR (
                              Q.QuestionTypeId IN ( 16, 23 )
                              AND Q.IsDeleted = 0
                          )
                   )
               AND Q.ContactQuestionId IS NULL
               AND (
                       @SearchText = ''
                       OR (
                              A.Detail LIKE '%' + @SearchText + '%'
                              OR Am.Id LIKE '%' + @SearchText + '%'
                              OR U.Name LIKE '%' + @SearchText + '%'
                          )
                   )
        INNER JOIN #TempTable TT
            ON TT.ReportId = Am.Id;

    INSERT INTO #FinalTempTable
    (
        ReportId,
        EstablishmentId,
        EstablishmentName,
        AppUserId,
        UserName,
        IsOutStanding,
        AnswerStatus,
        TimeOffSet,
        CreatedOn,
        UpdatedOn,
        PI,
        SmileType,
        Latitude,
        Longitude,
        SeenClientAnswerMasterId,
        ActivityId,
        CaptureDate,
        LogedByHeader,
        StatusId,
        StatusName,
        StatusImage,
        StatusTime,
        StatusCounter,
        IsRecurringApplied
    )
    SELECT ISNULL(T.ReportId, 0) AS ReportId,
           ISNULL(T.EstablishmentId, 0) AS EstablishmentId,
           ISNULL(EstablishmentName, '') AS EstablishmentName,
           ISNULL(AppUserId, 0) AS AppUserId,
           ISNULL(UserName, '') AS UserName,
           ISNULL(IsOutStanding, 0) AS IsOutStanding,
           ISNULL(AnswerStatus, '') AS AnswerStatus,
           ISNULL(TimeOffSet, 0) AS TimeOffSet,
           ISNULL(CreatedOn, '') AS CreatedOn,
           ISNULL(UpdatedOn, '') AS UpdatedOn,
           ISNULL(PI, 0) AS PI,
           ISNULL(SmileType, '') AS SmileType,
           ISNULL(Latitude, '') AS Latitude,
           ISNULL(Longitude, '') AS Longitude,
           ISNULL(SeenClientAnswerMasterId, 0) AS SeenClientAnswerMasterId,
           ISNULL(ActivityId, 0) AS ActivityId,
           ISNULL(dbo.ChangeDateFormat(CaptureDate, 'dd/MMM/yy HH:mm'), '') AS CaptureDate,
           '' AS LogedByHeader,
           ISNULL(StatusId, 0) AS StatusId,
           ISNULL(StatusName, '') AS StatusName,
           ISNULL(StatusImage, '') AS StatusImage,
           ISNULL(StatusTime, '') AS StatusTime,
           ISNULL(StatusCounter, '') AS StatusCounter,
           (CASE
                WHEN EXISTS
                     (
                         SELECT 1
                         FROM dbo.RecurringSetting WITH (NOLOCK)
                         WHERE SeenClientAnswerMasterId = T.ReportId
                               AND ISNULL(IsDeleted, 0) = 0
                     ) THEN
                    1
                ELSE
                    0
            END
           ) AS IsRecurringApplied
    FROM #TempTable T
        INNER JOIN @ReportIds R
            ON R.ReportId = T.ReportId
    ORDER BY ReportId DESC OFFSET ((@Page - 1) * @Rows) ROWS FETCH NEXT @Rows ROWS ONLY;

    SELECT  ReportId,
        EstablishmentId,
        EstablishmentName,
        AppUserId,
        UserName,
        IsOutStanding,
        AnswerStatus,
        TimeOffSet,
        ISNULL(dbo.ChangeDateFormat(CreatedOn, 'dd/MMM/yy HH:mm'), '') AS CreatedOn,
        UpdatedOn,
        PI,
        SmileType,
        Latitude,
        Longitude,
        SeenClientAnswerMasterId,
        ActivityId,
        ISNULL(dbo.ChangeDateFormat(CaptureDate, 'dd/MMM/yy HH:mm'), '') AS CaptureDate,
        LogedByHeader,
        StatusId,
        StatusName,
        StatusImage,
        StatusTime,
        StatusCounter,
        IsRecurringApplied
    FROM #FinalTempTable;

    SELECT Am.Id AS ReferenceId,
           ISNULL(Q.Position, 0) AS QuestionPosition,
           ISNULL(Q.ChildPosition, 0) AS QuestionChildPosition,
           ISNULL(Q.Id, 0) AS QuestionId,
           ISNULL(Q.QuestionTitle, '') AS QuestionTitle,
           ISNULL(Q.ShortName, '') AS ShortName,
           ISNULL(Q.QuestionTypeId, 0) AS QuestionTypeId,
           ISNULL(A.RepeatCount, 0) AS RepetitiveGroupCount,
           ISNULL(A.RepetitiveGroupId, 0) AS RepetitiveGroupNo,
           ISNULL(A.RepetitiveGroupName, '') AS RepetitiveGroupName,
           ISNULL(   (CASE Q.QuestionTypeId
                          WHEN 8 THEN
                              dbo.ChangeDateFormat(Detail, 'dd/MMM/yy')
                          WHEN 9 THEN
                              dbo.ChangeDateFormat(Detail, 'hh:mm AM/PM')
                          WHEN 22 THEN
                              dbo.ChangeDateFormat(Detail, 'dd/MMM/yy HH:mm')
                          WHEN 1 THEN
                              dbo.GetOptionNameByQuestionId(A.QuestionId, A.Detail, 1)
                          WHEN 23 THEN
                              Q.ImagePath
                          WHEN 17 THEN
                              dbo.GetRefernceQuestionImagePath(Detail, 1,0)
                          ELSE
                              ISNULL(A.Detail, '')
                      END
                     ),
                     ''
                 ) AS Detail,
           CASE A.QuestionTypeId
               WHEN 23 THEN
                   @GraphicImagePath + 'SeenClientQuestions/'
               ELSE
                   @Url + 'SeenClient/'
           END AS URL,
           @ThumbnailUrl AS ThumbnailUrl,
           ISNULL(dbo.ChangeDateFormat(DATEADD(MINUTE, Am.TimeOffSet, Am.CreatedOn), 'dd/MMM/yy HH:mm'), '') AS CaptureDate,
           ISNULL(Am.IsDisabled, 0) AS IsDeleted,
           ISNULL(Q.ImageHeight, '') AS ImageHeight,
           ISNULL(Q.ImageWidth, '') AS ImageWidth,
           ISNULL(Q.ImageAlign, '') AS ImageAlign,
           ISNULL(Q.IsSignature, 0) AS IsSignature,
           ISNULL(Q.IsRepetitive, 0) AS IsRepetitive,
           ISNULL(   (CASE
                          WHEN Q.QuestionTypeId IN ( 1, 2, 5, 6, 18, 21, 7, 14, 15 ) THEN
                          (
                              SELECT dbo.IsSeenClientQuestionPositive(Am.Id, Q.Id, A.Id)
                          )
                          ELSE
                              0
                      END
                     ),
                     0
                 ) AS ItemType,
           ISNULL(Q.IsDisplayInSummary, 0) AS IsDisplayInSummary,
           Q.ImageHeight
    FROM dbo.SeenClientAnswerMaster AS Am WITH (NOLOCK)
        INNER JOIN dbo.SeenClient AS Qr WITH (NOLOCK)
            ON Am.SeenClientId = Qr.Id
        INNER JOIN dbo.SeenClientQuestions AS Q WITH (NOLOCK)
            ON Qr.Id = Q.SeenClientId
               AND Q.IsDisplayInDetail = 1
               AND Q.QuestionTypeId <> 25
               AND Q.ContactQuestionId IS NULL
        INNER JOIN dbo.SeenClientAnswers AS A WITH (NOLOCK)
            ON Am.Id = A.SeenClientAnswerMasterId
               AND Q.Id = A.QuestionId
               AND (
                       A.Id IS NOT NULL
                       OR (
                              Q.QuestionTypeId IN ( 16, 23 )
                              AND Q.IsDeleted = 0
                          )
                   )
        INNER JOIN #FinalTempTable R
            ON R.ReportId = Am.Id ORDER BY A.RepetitiveGroupId;



    SELECT COUNT(1) AS TotalRows
    FROM @ReportIds;

    DECLARE @CommaReportIds NVARCHAR(MAX);
    SELECT @CommaReportIds = COALESCE(@CommaReportIds + ', ', '') + CAST(ReportId AS NVARCHAR(10))
    FROM @ReportIds;
    SELECT @CommaReportIds AS TotalReportIds;

    DECLARE @CommaReportIdEstablishment NVARCHAR(MAX);
    SELECT @CommaReportIdEstablishment
        = COALESCE(@CommaReportIdEstablishment + ', ', '')
          + (CAST(ReportId AS NVARCHAR(10)) + ':' + CAST(EstablishmentId AS NVARCHAR(10)))
    FROM @ReportIds;
    SELECT @CommaReportIdEstablishment AS TotalReportIdEstablisment;

    SET NOCOUNT OFF;
END;
