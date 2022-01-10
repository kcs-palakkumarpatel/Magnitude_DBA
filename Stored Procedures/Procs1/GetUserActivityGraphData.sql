-- =============================================
-- Author:      Krishna Panchal
-- Create Date: 22-Jun-2021
-- Description: Get Unallocated Task List By ActivityId
-- GetUserActivityGraphData 18261,7963,0,0,'','',3
-- =============================================
CREATE PROCEDURE [dbo].[GetUserActivityGraphData]
    @AppUserId BIGINT,
    @ActivityId BIGINT,
    @EstablishmentId NVARCHAR(MAX) = '0',
    @UserId NVARCHAR(MAX) = '0',
    @FilterOn NVARCHAR(MAX) = '',
    @StatusIds VARCHAR(MAX) = '',
    @DateFilterId INT = 3
AS
BEGIN
    SET NOCOUNT ON;

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

    DECLARE @UserInfo AS TABLE
    (
        Id BIGINT,
        Name VARCHAR(100),
        ContactMasterId BIGINT
    );

    DECLARE @EstablishmentList AS TABLE (Id BIGINT);
    IF (@EstablishmentId = '0')
    BEGIN
        INSERT @EstablishmentList
        SELECT E.Id AS EstablishmentId
        FROM dbo.AppUserEstablishment AS UE WITH (NOLOCK)
            INNER JOIN dbo.Establishment AS E WITH (NOLOCK)
                ON UE.EstablishmentId = E.Id
        WHERE UE.AppUserId = @AppUserId
              AND E.IsDeleted = 0
              AND UE.IsDeleted = 0
              AND E.EstablishmentGroupId = @ActivityId;
    END;
    ELSE
    BEGIN
        INSERT INTO @EstablishmentList
        SELECT Data
        FROM dbo.Split(@EstablishmentId, ',');
    END;

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
               FROM dbo.ContactDetails CD WITH (NOLOCK)
                   INNER JOIN dbo.ContactMaster CM WITH (NOLOCK)
                       ON CM.Id = CD.ContactMasterId
                          AND CM.GroupId = AU.GroupId
						  AND CM.IsDeleted = 0
               WHERE CD.QuestionTypeId = 10
                     AND AU.Email = CD.Detail
                     AND ISNULL(CD.IsDeleted, 0) = 0
               ORDER BY CD.ContactMasterId DESC
           )
    FROM dbo.AppUserEstablishment AUE WITH (NOLOCK)
        INNER JOIN dbo.AppUser AU WITH (NOLOCK)
            ON AU.Id = AUE.AppUserId
        INNER JOIN @EstablishmentList EL
            ON EL.Id = AUE.EstablishmentId
    --INNER JOIN dbo.AppUserofManage AOM
    --    ON AOM.ApplicationUserId = AU.Id
    --       AND AOM.ManagerUserId = @AppUserId
    --       AND ISNULL(AOM.IsDeleted, 0) = 0
    WHERE AUE.IsDeleted = 0
          AND AU.IsDeleted = 0
          AND (
                  AU.IsAreaManager = 0
                  OR AUE.AppUserId = @AppUserId
              )
          AND AU.IsActive = 1
          AND (
                  (AU.Id IN (
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
               FROM dbo.ContactDetails CD WITH (NOLOCK)
                   INNER JOIN dbo.ContactMaster CM WITH (NOLOCK)
                       ON CM.Id = CD.ContactMasterId
                          AND CM.GroupId = AU.GroupId
						  AND CM.IsDeleted = 0
               WHERE CD.QuestionTypeId = 10
                     AND AU.Email = CD.Detail
                     AND ISNULL(CD.IsDeleted, 0) = 0
               ORDER BY CD.ContactMasterId DESC
           ) AS ContactMasterId
    FROM dbo.AppManagerUserRights AMUR WITH (NOLOCK)
        INNER JOIN @EstablishmentList EL
            ON EL.Id = AMUR.EstablishmentId
        INNER JOIN dbo.AppUser AU WITH (NOLOCK)
            ON AU.Id = AMUR.ManagerUserId
               AND AMUR.UserId = @AppUserId
               AND AMUR.IsDeleted = 0
               AND AU.IsActive = 1
               AND AU.IsDeleted = 0
               AND (
                       (AU.Id IN (
                                     SELECT Data FROM dbo.Split(@UserId, ',')
                                 )
                       )
                       OR @UserId = '0'
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

    DECLARE @Capture AS TABLE
    (
        AppUserId BIGINT,
        IsResolved VARCHAR(100)
    );
    INSERT @Capture
    (
        AppUserId,
        IsResolved
    )
    SELECT UI.Id,
           SCA.IsResolved
    FROM dbo.SeenClientAnswerMaster SCA WITH (NOLOCK)
        INNER JOIN @UserInfo UI
            ON UI.Id = SCA.AppUserId
        INNER JOIN dbo.EstablishmentGroup EG WITH (NOLOCK)
            ON EG.Id = @ActivityId
               AND EG.SeenClientId = SCA.SeenClientId
        INNER JOIN dbo.Establishment E WITH (NOLOCK)
            ON E.Id = SCA.EstablishmentId
               AND E.EstablishmentGroupId = EG.Id
			   AND E.IsDeleted = 0
    WHERE ISNULL(SCA.IsDeleted, 0) = 0
          AND (
                  @FilterOn = ''
                  OR SCA.IsPositive = @FilterOn
              )
          AND ISNULL(SCA.IsUnAllocated, 0) = 0
          AND (
                  (SCA.EstablishmentId IN (
                                              SELECT Data FROM dbo.Split(@EstablishmentId, ',')
                                          )
                  )
                  OR @EstablishmentId = '0'
              )
          AND CAST(SCA.CreatedOn AS DATE)
          BETWEEN CAST((DATEADD(MINUTE, E.TimeOffSet, @FromDate)) AS DATE) AND CAST((DATEADD(
                                                                                                MINUTE,
                                                                                                E.TimeOffSet,
                                                                                                @ToDate
                                                                                            )
                                                                                    ) AS DATE);


    SELECT Id AS AppUserId,
           Name AS AppUserName,
           ISNULL(
           (
               SELECT TOP 1
                   CASE
                       WHEN ISNULL(SH.StatusDateTime, '') <> '' THEN
                           dbo.ChangeDateFormat(SH.StatusDateTime, 'dd/MMM/yy HH:mm')
                       ELSE
                           ''
                   END AS StatusDateTime
               FROM dbo.StatusHistory SH WITH (NOLOCK)
                   INNER JOIN dbo.SeenClientAnswerMaster SCM WITH (NOLOCK)
                       ON SCM.Id = SH.ReferenceNo
                   INNER JOIN dbo.EstablishmentGroup EG WITH (NOLOCK)
                       ON EG.Id = @ActivityId
                          AND EG.SeenClientId = SCM.SeenClientId
                   INNER JOIN dbo.Establishment E WITH (NOLOCK)
                       ON E.Id = SCM.EstablishmentId
                          AND E.EstablishmentGroupId = EG.Id
						  AND E.IsDeleted = 0
               WHERE SH.UserId = UI.Id
                     AND ISNULL(SH.IsDeleted, 0) = 0
                     AND ISNULL(SCM.IsDeleted, 0) = 0
                     AND ISNULL(SCM.IsUnAllocated, 0) = 0
                     AND (
                             @FilterOn = ''
                             OR SCM.IsPositive = @FilterOn
                         )
                     AND CAST(SH.CreatedOn AS DATE)
                     BETWEEN CAST((DATEADD(MINUTE, E.TimeOffSet, @FromDate)) AS DATE) AND CAST((DATEADD(
                                                                                                           MINUTE,
                                                                                                           E.TimeOffSet,
                                                                                                           @ToDate
                                                                                                       )
                                                                                               ) AS DATE)
               ORDER BY SH.Id DESC
           ),
           ''
                 ) AS StatusSet,
           ISNULL(
           (
               SELECT ISNULL(COUNT(C.AppUserId), 0)
               FROM @Capture C
               WHERE UI.Id = C.AppUserId
               GROUP BY C.AppUserId
           ),
           0
                 ) AS TotalCaptured,
           ISNULL(
           (
               SELECT COUNT(*)
               FROM dbo.AnswerMaster AM WITH (NOLOCK)
                   INNER JOIN dbo.SeenClientAnswerMaster SCAM WITH (NOLOCK)
                       ON SCAM.Id = AM.SeenClientAnswerMasterId
                   INNER JOIN dbo.EstablishmentGroup EG WITH (NOLOCK)
                       ON EG.SeenClientId = SCAM.SeenClientId
                   INNER JOIN dbo.Establishment E WITH (NOLOCK)
                       ON E.EstablishmentGroupId = EG.Id
                          AND E.Id = SCAM.EstablishmentId
						  AND E.IsDeleted = 0
               WHERE AM.ContactAppUserId = UI.Id
                     AND ISNULL(AM.IsDeleted, 0) = 0
                     AND EG.Id = @ActivityId
                     AND ISNULL(SCAM.IsDeleted, 0) = 0
                     AND ISNULL(SCAM.IsUnAllocated, 0) = 0
                     AND (
                             @FilterOn = ''
                             OR AM.IsPositive = @FilterOn
                         )
                     AND CAST(AM.CreatedOn AS DATE)
                     BETWEEN CAST((DATEADD(MINUTE, E.TimeOffSet, @FromDate)) AS DATE) AND CAST((DATEADD(
                                                                                                           MINUTE,
                                                                                                           E.TimeOffSet,
                                                                                                           @ToDate
                                                                                                       )
                                                                                               ) AS DATE)
           ),
           0
                 ) AS TotalResponse,
           ISNULL(
           (
               SELECT COUNT(*)
               FROM dbo.StatusHistory SH
                   INNER JOIN dbo.SeenClientAnswerMaster SCM WITH (NOLOCK)
                       ON SCM.Id = SH.ReferenceNo
                   INNER JOIN dbo.EstablishmentGroup EG WITH (NOLOCK)
                       ON EG.Id = @ActivityId
                          AND EG.SeenClientId = SCM.SeenClientId
                   INNER JOIN dbo.Establishment E WITH (NOLOCK)
                       ON E.Id = SCM.EstablishmentId
                          AND E.EstablishmentGroupId = EG.Id
						  AND E.IsDeleted = 0
               WHERE SH.UserId = UI.Id
                     AND ISNULL(SH.IsDeleted, 0) = 0
                     AND ISNULL(SCM.IsDeleted, 0) = 0
                     AND ISNULL(SCM.IsUnAllocated, 0) = 0
                     AND (
                             @FilterOn = ''
                             OR SCM.IsPositive = @FilterOn
                         )
                     AND CAST(SH.CreatedOn AS DATE)
                     BETWEEN CAST((DATEADD(MINUTE, E.TimeOffSet, @FromDate)) AS DATE) AND CAST((DATEADD(
                                                                                                           MINUTE,
                                                                                                           E.TimeOffSet,
                                                                                                           @ToDate
                                                                                                       )
                                                                                               ) AS DATE)
               GROUP BY SH.UserId
           ),
           0
                 ) AS TotalStatusChanged,
           ISNULL(
           (
               SELECT COUNT(*)
               FROM dbo.CloseLoopAction CLA WITH (NOLOCK)
                   INNER JOIN dbo.SeenClientAnswerMaster SCAM WITH (NOLOCK)
                       ON SCAM.Id = CLA.SeenClientAnswerMasterId
                   INNER JOIN dbo.EstablishmentGroup EG WITH (NOLOCK)
                       ON EG.SeenClientId = SCAM.SeenClientId
                   INNER JOIN dbo.Establishment E WITH (NOLOCK)
                       ON E.EstablishmentGroupId = EG.Id
                          AND E.Id = SCAM.EstablishmentId
						  AND E.IsDeleted = 0
               WHERE CLA.AppUserId = UI.Id
                     AND EG.Id = @ActivityId
                     AND (CLA.Conversation NOT LIKE '%Resolved - Ref#%')
                     AND ISNULL(CLA.IsDeleted, 0) = 0
                     AND (
                             @FilterOn = ''
                             OR SCAM.IsPositive = @FilterOn
                         )
                     AND ISNULL(SCAM.IsDeleted, 0) = 0
                     AND ISNULL(SCAM.IsUnAllocated, 0) = 0
                     AND ISNULL(CLA.IsDeleted, 0) = 0
                     AND CAST(CLA.CreatedOn AS DATE)
                     BETWEEN CAST((DATEADD(MINUTE, E.TimeOffSet, @FromDate)) AS DATE) AND CAST((DATEADD(
                                                                                                           MINUTE,
                                                                                                           E.TimeOffSet,
                                                                                                           @ToDate
                                                                                                       )
                                                                                               ) AS DATE)
               GROUP BY CLA.AppUserId
           ),
           0
                 ) TotalChat,
           ISNULL(
           (
               SELECT ISNULL(COUNT(C.AppUserId), 0)
               FROM @Capture C
               WHERE UI.Id = C.AppUserId
                     AND C.IsResolved = 'Resolved'
               GROUP BY C.AppUserId
           ),
           0
                 ) AS TotalResolved,
           ISNULL(
           (
               SELECT ISNULL(COUNT(C.AppUserId), 0)
               FROM @Capture C
               WHERE UI.Id = C.AppUserId
                     AND C.IsResolved = 'Unresolved'
               GROUP BY C.AppUserId
           ),
           0
                 ) AS TotalUnResolved
    FROM @UserInfo UI;

    SET NOCOUNT OFF;
END;

