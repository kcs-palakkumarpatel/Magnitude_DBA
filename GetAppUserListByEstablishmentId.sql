CREATE PROCEDURE dbo.GetAppUserListByEstablishmentId
    @ActivityId BIGINT,
    @AppUserId BIGINT,
    @EstablishmentIds VARCHAR(MAX) = '0',
    @SearchText VARCHAR(500) = ''
AS
BEGIN

SET NOCOUNT ON;
    DECLARE @EstablishmentList AS TABLE (Id BIGINT);
    IF (@EstablishmentIds = '0')
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
        FROM dbo.Split(@EstablishmentIds, ',');
    END;

    DECLARE @FinalTbl AS TABLE
    (
        AppUserId BIGINT,
        Name VARCHAR(200),
        ContactMasterId BIGINT
    );

    INSERT INTO @FinalTbl
    (
        AppUserId,
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
           ) AS ContactMasterId
    FROM dbo.AppUserEstablishment AUE WITH (NOLOCK)
        INNER JOIN dbo.AppUser AU WITH (NOLOCK)
            ON AU.Id = AUE.AppUserId
        INNER JOIN @EstablishmentList EL
            ON EL.Id = AUE.EstablishmentId
        INNER JOIN dbo.AppUserofManage AOM WITH (NOLOCK)
            ON AOM.ApplicationUserId = AU.Id
               AND AOM.ManagerUserId = @AppUserId
               AND ISNULL(AOM.IsDeleted, 0) = 0
    WHERE AUE.IsDeleted = 0
          AND AU.IsDeleted = 0
          AND (
                  AU.IsAreaManager = 0
                  OR AUE.AppUserId = @AppUserId
              )
          AND AU.IsActive = 1
          AND (
                  @SearchText = ''
                  OR AU.Name LIKE '%' + @SearchText + '%'
              )
    UNION
    SELECT TOP 1
        @AppUserId AS AppUserId,
        AU.Name,
        CD.ContactMasterId AS ContactMasterId
    FROM dbo.ContactDetails CD WITH (NOLOCK)
        INNER JOIN dbo.AppUser AU WITH (NOLOCK)
            ON CD.Detail = AU.Email
               AND AU.Id = @AppUserId
               AND ISNULL(CD.IsDeleted, 0) = 0
			    INNER JOIN dbo.ContactMaster CM ON CM.GroupId = AU.GroupId AND CM.Id = CD.ContactMasterId
        INNER JOIN dbo.AppUserEstablishment AUE WITH (NOLOCK)
            ON AUE.AppUserId = @AppUserId
			AND AUE.IsDeleted = 0
        INNER JOIN @EstablishmentList E
            ON E.Id = AUE.EstablishmentId
    WHERE (
              @SearchText = ''
              OR AU.Name LIKE '%' + @SearchText + '%'
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
    WHERE (
              @SearchText = ''
              OR AU.Name LIKE '%' + @SearchText + '%'
          )
    GROUP BY AMUR.ManagerUserId,
             AU.Name,
             AU.Email,
             AU.GroupId
    ORDER BY Name ASC;

    SELECT *
    FROM @FinalTbl
    WHERE ISNULL(ContactMasterId, 0) <> 0;

SET NOCOUNT OFF;
END;
