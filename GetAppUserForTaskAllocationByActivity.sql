-- =============================================
-- Author : Krishna Panchal
-- Create On : 13-May-2021
-- Description : Get App User By Activity Id
-- GetAppUserForTaskAllocationByActivity 8123,18310,'0','','','',1,50
-- =============================================
CREATE PROCEDURE dbo.GetAppUserForTaskAllocationByActivity
    @ActivityId BIGINT,
    @AppUserId BIGINT,
    @EstablishmentIds VARCHAR(MAX) = '0',
    @UserIds VARCHAR(MAX) = '',
    @FromDate DATETIME = '',
    @ToDate DATETIME = '',
    @SmileyType VARCHAR(100) = '',
    @StatusIds VARCHAR(200) = '',
    @Page INT = 1,
    @Rows INT = 50
AS
BEGIN

SET NOCOUNT ON;
    DECLARE @Url NVARCHAR(500);
    SELECT @Url = KeyValue + N'AppUser/'
    FROM dbo.AAAAConfigSettings
    WHERE KeyName = 'DocViewerRootFolderPathCMS';

    IF (@SmileyType = 'Positive')
    BEGIN
        SET @SmileyType = 'Positive';
    END;

    DECLARE @UserInfo AS TABLE
    (
        Id BIGINT,
        Name VARCHAR(100),
        ImageURL VARCHAR(500),
        Email VARCHAR(200),
        Mobile VARCHAR(20),
        CompanyName VARCHAR(200),
        ContactMasterId BIGINT,
        IsManager BIT
    );

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

    INSERT INTO @UserInfo
    (
        Id,
        Name,
        ImageURL,
        Email,
        Mobile,
        CompanyName,
        ContactMasterId,
        IsManager
    )
    SELECT AUE.AppUserId,
           AU.Name,
           ISNULL(   (CASE
                          WHEN AU.ImageName <> '' THEN
                              ISNULL(@Url + AU.ImageName, '')
                          ELSE
                              ''
                      END
                     ),
                     ''
                 ) AS UserImageURL,
           AU.Email,
           AU.Mobile,
           (
               SELECT GroupName FROM dbo.[Group] WHERE Id = AU.GroupId
           ) AS CompanyName,
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
           ),
           AU.IsAreaManager
    FROM dbo.AppUserEstablishment AUE WITH (NOLOCK)
        INNER JOIN dbo.AppUser AU WITH (NOLOCK)
            ON AU.Id = AUE.AppUserId
			AND AU.IsDeleted = 0
        INNER JOIN dbo.AppUserofManage AOM WITH (NOLOCK)
            ON AOM.ApplicationUserId = AU.Id
               AND AOM.ManagerUserId = @AppUserId
               AND ISNULL(AOM.IsDeleted, 0) = 0
        INNER JOIN @EstablishmentList EL
            ON EL.Id = AUE.EstablishmentId
    WHERE AUE.IsDeleted = 0
          AND AU.IsDeleted = 0
          AND (
                  AU.IsAreaManager = 0
                  OR AUE.AppUserId = @AppUserId
              )
          AND AU.IsActive = 1
          AND (
                  (AUE.AppUserId IN (
                                        SELECT Data FROM dbo.Split(@UserIds, ',')
                                    )
                  )
                  OR @UserIds = ''
              )
    UNION
    SELECT TOP 1
        @AppUserId AS AppUserId,
        AU.Name,
        ISNULL(   (CASE
                       WHEN AU.ImageName <> '' THEN
                           ISNULL(@Url + AU.ImageName, '')
                       ELSE
                           ''
                   END
                  ),
                  ''
              ) AS UserImageURL,
        AU.Email,
        AU.Mobile,
        (
            SELECT GroupName FROM dbo.[Group] WHERE Id = AU.GroupId
        ) AS CompanyName,
        CD.ContactMasterId AS ContactMasterId,
        AU.IsAreaManager
    FROM dbo.ContactDetails CD WITH (NOLOCK)
        INNER JOIN dbo.AppUser AU WITH (NOLOCK)
            ON CD.Detail = AU.Email
               AND AU.Id = @AppUserId
               AND ISNULL(CD.IsDeleted, 0) = 0
        INNER JOIN dbo.ContactMaster CM WITH (NOLOCK)
            ON CM.Id = CD.ContactMasterId
			AND CM.IsDeleted = 0
               AND CM.GroupId = AU.GroupId
        INNER JOIN dbo.AppUserEstablishment AUE WITH (NOLOCK)
            ON AUE.AppUserId = @AppUserId
			AND AUE.IsDeleted = 0
        INNER JOIN @EstablishmentList E
            ON E.Id = AUE.EstablishmentId
    WHERE (
              (AU.Id IN (
                            SELECT Data FROM dbo.Split(@UserIds, ',')
                        )
              )
              OR @UserIds = ''
          )
    UNION
    SELECT AMUR.ManagerUserId AS AppUserId,
           AU.Name,
           ISNULL(   (CASE
                          WHEN AU.ImageName <> '' THEN
                              ISNULL(@Url + AU.ImageName, '')
                          ELSE
                              ''
                      END
                     ),
                     ''
                 ) AS UserImageURL,
           AU.Email,
           AU.Mobile,
           (
               SELECT GroupName FROM dbo.[Group] WHERE Id = AU.GroupId
           ) AS CompanyName,
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
           ) AS ContactMasterId,
           AU.IsAreaManager
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
                       (AMUR.ManagerUserId IN (
                                                  SELECT Data FROM dbo.Split(@UserIds, ',')
                                              )
                       )
                       OR @UserIds = ''
                   )
    GROUP BY AMUR.ManagerUserId,
             AU.Name,
             AU.ImageName,
             AU.Email,
             AU.Mobile,
             AU.GroupId,
             AU.IsAreaManager
    ORDER BY Name ASC;

    DECLARE @FinalInfo AS TABLE
    (
        Id BIGINT,
        Name VARCHAR(100),
        ImageURL VARCHAR(500),
        Email VARCHAR(200),
        Mobile VARCHAR(20),
        CompanyName VARCHAR(200),
        ContactMasterId BIGINT,
        IsManager BIT
    );

    INSERT INTO @FinalInfo
    (
        Id,
        Name,
        ImageURL,
        Email,
        Mobile,
        CompanyName,
        ContactMasterId,
        IsManager
    )
    SELECT Id,
           Name,
           ImageURL,
           Email,
           Mobile,
           CompanyName,
           ContactMasterId,
           IsManager
    FROM @UserInfo
    ORDER BY Name ASC OFFSET ((@Page - 1) * @Rows) ROWS FETCH NEXT @Rows ROWS ONLY;

    DECLARE @ManagerList AS TABLE
    (
        ManagerId BIGINT,
        UserId BIGINT,
        Name VARCHAR(MAX)
    );
    DECLARE @ManagerListUserWise AS TABLE
    (
        UserId BIGINT,
        Name VARCHAR(MAX)
    );
    INSERT INTO @ManagerList
    (
        ManagerId,
        UserId,
        Name
    )
    SELECT DISTINCT
        AMUR.ManagerUserId,
        AMUR.ApplicationUserId,
        AU.Name
    FROM dbo.AppUserofManage AMUR WITH (NOLOCK)
        INNER JOIN @FinalInfo FI
            ON FI.Id = AMUR.ApplicationUserId
        INNER JOIN dbo.AppUser AU WITH (NOLOCK)
            ON AU.Id = AMUR.ManagerUserId
               AND AU.IsAreaManager = 1
    WHERE AMUR.ApplicationUserId = FI.Id
          AND ISNULL(AMUR.IsDeleted, 0) = 0
    GROUP BY AMUR.ApplicationUserId,
             AMUR.ManagerUserId,
             AU.Name;

    INSERT INTO @ManagerListUserWise
    (
        UserId,
        Name
    )
    SELECT a.UserId,
           Name = STUFF(
                  (
                      SELECT ', ' + b.Name
                      FROM @ManagerList b
                      WHERE b.UserId = a.UserId
                      FOR XML PATH('')
                  ),
                  1,
                  2,
                  ''
                       )
    FROM @ManagerList a
    GROUP BY a.UserId;

    DECLARE @UserInfoTbl AS TABLE
    (
        AppUserId BIGINT,
        AppUserName VARCHAR(100),
        UserImageURL VARCHAR(500),
        EmailId VARCHAR(200),
        MobileNo VARCHAR(20),
        CompanyName VARCHAR(200),
        Manager VARCHAR(MAX),
        ContactMasterId BIGINT,
        IsManager BIT
    );

    IF EXISTS
    (
        SELECT *
        FROM dbo.AppUser
        WHERE Id = @AppUserId
              AND IsAreaManager = 1
    )
    BEGIN
        INSERT INTO @UserInfoTbl
        (
            AppUserId,
            AppUserName,
            UserImageURL,
            EmailId,
            MobileNo,
            CompanyName,
            Manager,
            ContactMasterId,
            IsManager
        )
        SELECT FI.Id AS AppUserId,
               FI.Name AS AppUserName,
               ISNULL(ImageURL, '') AS UserImageURL,
               ISNULL(Email, '') EmailId,
               ISNULL(Mobile, '') AS MobileNo,
               ISNULL(CompanyName, '') AS CompanyName,
               ML.Name AS Manager,
               ISNULL(FI.ContactMasterId, 0) AS ContactMasterId,
               IsManager
        FROM @FinalInfo FI
            LEFT JOIN @ManagerListUserWise ML
                ON ML.UserId = FI.Id
        WHERE ISNULL(FI.ContactMasterId, 0) <> 0;

    END;
    ELSE
    BEGIN
        INSERT INTO @UserInfoTbl
        (
            AppUserId,
            AppUserName,
            UserImageURL,
            EmailId,
            MobileNo,
            CompanyName,
            Manager,
            ContactMasterId,
            IsManager
        )
        SELECT FI.Id AS AppUserId,
               FI.Name AS AppUserName,
               ISNULL(ImageURL, '') AS UserImageURL,
               ISNULL(Email, '') EmailId,
               ISNULL(Mobile, '') AS MobileNo,
               ISNULL(CompanyName, '') AS CompanyName,
               ML.Name AS Manager,
               ISNULL(FI.ContactMasterId, 0) AS ContactMasterId,
               IsManager
        FROM @FinalInfo FI
            LEFT JOIN @ManagerListUserWise ML
                ON ML.UserId = FI.Id
        WHERE ISNULL(FI.ContactMasterId, 0) <> 0;
    END;

    SELECT *
    FROM @UserInfoTbl
    ORDER BY AppUserName ASC;

    SELECT E.Id,
           EstablishmentName,
           AUE.AppUserId,
           (
               SELECT COUNT(SCA.Id)
               FROM dbo.SeenClientAnswerMaster SCA WITH (NOLOCK)
               WHERE SCA.ContactMasterId = FI.ContactMasterId
                     AND SCA.EstablishmentId = E.Id
                     AND ISNULL(SCA.IsDeleted, 0) = 0
                     AND IsResolved = 'Unresolved'
                     AND ISNULL(SCA.IsUnAllocated, 0) = 0
                     AND (
                             SCA.IsPositive IN (
                                                   SELECT Data FROM dbo.Split(@SmileyType, ',')
                                               )
                             OR @SmileyType = ''
                         )
                     AND (
                             (CAST(SCA.CreatedOn AS DATE)
                     BETWEEN CAST((DATEADD(MINUTE, E.TimeOffSet, @FromDate)) AS DATE) AND CAST((DATEADD(
                                                                                                           MINUTE,
                                                                                                           E.TimeOffSet,
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
                             @StatusIds = ''
                             OR ((
                                     SELECT TOP 1
                                         SH.EstablishmentStatusId
                                     FROM dbo.StatusHistory SH WITH (NOLOCK)
                                     WHERE SH.ReferenceNo = SCA.Id
                                     ORDER BY SH.Id DESC
                                 ) IN (
                                          SELECT Data FROM dbo.Split(@StatusIds, ',')
                                      )
                                )
                         )
           ) AS TotalPendingTasks
    FROM dbo.Establishment E WITH (NOLOCK)
        INNER JOIN @EstablishmentList EL
            ON EL.Id = E.Id
        INNER JOIN dbo.AppUserEstablishment AUE WITH (NOLOCK)
            ON AUE.EstablishmentId = E.Id
               AND ISNULL(AUE.IsDeleted, 0) = 0
               AND ISNULL(E.IsDeleted, 0) = 0
        INNER JOIN @FinalInfo FI
            ON FI.Id = AUE.AppUserId;

SET NOCOUNT OFF;
END;
