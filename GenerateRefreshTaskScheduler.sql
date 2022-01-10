-- =============================================
-- Author:		Krishna Panchal
-- Create date: 2-June-2021
-- Description:	Generate Refresh Task Scheduler
-- Call SP:		GenerateRefreshTaskScheduler

-- =============================================
CREATE PROCEDURE dbo.GenerateRefreshTaskScheduler
AS
BEGIN
    DECLARE @SeenClientList AS TABLE
    (
        SeenClientId BIGINT
    );
    INSERT INTO @SeenClientList
    (
        SeenClientId
    )
    SELECT SeenClientId
    FROM dbo.EstablishmentGroup
    WHERE ISNULL(AllowToRefreshTheTaskDaily, 0) = 1
          AND ISNULL(IsDeleted, 0) = 0;

    DECLARE @Data AS TABLE
    (
        Id BIGINT PRIMARY KEY IDENTITY(1, 1),
        SeenClientAnswerMasterId BIGINT,
        EstablishmentId BIGINT,
        AppUserId BIGINT
    );
    INSERT INTO @Data
    (
        SeenClientAnswerMasterId,
        EstablishmentId,
        AppUserId
    )
    SELECT SCA.Id,
           SCA.EstablishmentId,
           SCA.AppUserId
    FROM dbo.SeenClientAnswerMaster SCA
        INNER JOIN @SeenClientList SC
            ON SC.SeenClientId = SCA.SeenClientId
               AND SCA.IsResolved = 'Unresolved'
               AND ISNULL(SCA.IsUnAllocated, 0) = 0
    WHERE ISNULL(SCA.IsDeleted, 0) = 0;

    DECLARE @ServerDate DATETIME = GETUTCDATE(),
            @count INT = 1,
            @TotalRecord INT,
            @SeenClientAnswerMaster BIGINT,
            @EstablishmentId BIGINT,
            @EstablishmentStatusId BIGINT,
            @AppUserId BIGINT;

    SELECT @TotalRecord = COUNT(*)
    FROM @Data;
    WHILE @count <= @TotalRecord
    BEGIN
        SELECT @SeenClientAnswerMaster = SeenClientAnswerMasterId,
               @EstablishmentId = EstablishmentId,
               @AppUserId = AppUserId
        FROM @Data
        WHERE Id = @count;

        SELECT TOP 1
               @EstablishmentStatusId = Id
        FROM dbo.EstablishmentStatus
        WHERE EstablishmentId = @EstablishmentId
              AND DefaultEndStatus = 1
              AND IsDeleted = 0;

        EXEC dbo.InsertStatusHistory @ReferenceNo = @SeenClientAnswerMaster,          -- bigint
                                     @EstablishmentStatusId = @EstablishmentStatusId, -- bigint
                                     @UserId = @AppUserId,                            -- bigint
                                     @Latitude = '0.0',                               -- nvarchar(50)
                                     @Longitude = '0.0',                              -- nvarchar(50)
                                     @StatusDateTime = @ServerDate,                   -- datetime
                                     @isWeb = NULL;
        SET @count = @count + 1;
    END;

    UPDATE SCA
    SET SCA.IsResolved = 'Resolved',
        SCA.UpdatedOn = @ServerDate
    FROM dbo.SeenClientAnswerMaster SCA
        INNER JOIN @SeenClientList SC
            ON SC.SeenClientId = SCA.SeenClientId
               AND SCA.IsResolved = 'Unresolved'
               AND ISNULL(SCA.IsUnAllocated, 0) = 0
    WHERE ISNULL(SCA.IsDeleted, 0) = 0;
END;
