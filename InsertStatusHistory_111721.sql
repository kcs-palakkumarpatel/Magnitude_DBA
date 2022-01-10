
--EXEC dbo.InsertStatusHistory @ReferenceNo = 193878,                        -- bigint
--                             @EstablishmentStatusId = 4377,              -- bigint
--                             @UserId = 5335,                             -- bigint
--                             @Latitude = N'23.029',                         -- nvarchar(50)
--                             @Longitude = N'72.57',                        -- nvarchar(50)
--                             @StatusDateTime = '2021-10-19 07:20:00', -- datetime
--                             @isWeb = 1,                           -- bit
--                             @IsFromTaskType = 0,                  -- bit
--                             @EstablishmentId = 23595                     -- bigint
CREATE PROCEDURE [dbo].[InsertStatusHistory_111721]
    @ReferenceNo BIGINT,
    @EstablishmentStatusId BIGINT,
    @UserId BIGINT,
    @Latitude NVARCHAR(50),
    @Longitude NVARCHAR(50),
    @StatusDateTime DATETIME,
    @isWeb BIT,
    @IsFromTaskType BIT = 0,
    @EstablishmentId BIGINT = 0
AS
SET NOCOUNT ON;

DECLARE @id BIGINT,
        @Offset INT,
        @CurrentEstablishmentStatusId BIGINT,
        @StatusIconImageId INT,
        @sHistoryId BIGINT,
        @DefaultEndStatus BIGINT;

SET @StatusIconImageId = @EstablishmentStatusId;

IF (@IsFromTaskType = 1)
BEGIN
    SELECT @EstablishmentStatusId = Id
    FROM dbo.EstablishmentStatus WITH (NOLOCK)
    WHERE EstablishmentId = @EstablishmentId
          AND StatusIconImageId = @EstablishmentStatusId;
END;

SET @CurrentEstablishmentStatusId =
(
    SELECT TOP 1
        EstablishmentStatusId
    FROM dbo.StatusHistory WITH (NOLOCK)
    WHERE ReferenceNo = @ReferenceNo
    ORDER BY CreatedOn DESC
);

IF (@CurrentEstablishmentStatusId <> @EstablishmentStatusId)
BEGIN
    SELECT @Offset = MAX(E.TimeOffSet)
    FROM dbo.Establishment AS E WITH (NOLOCK)
        INNER JOIN dbo.EstablishmentStatus AS ES WITH (NOLOCK)
            ON ES.EstablishmentId = E.Id
    WHERE E.IsDeleted = 0
          AND ES.Id = @EstablishmentStatusId;

    IF (@isWeb = 1)
    BEGIN
        SET @StatusDateTime = GETUTCDATE();
    END;
    INSERT INTO dbo.StatusHistory
    (
        [ReferenceNo],
        [EstablishmentStatusId],
        [UserId],
        [StatusDateTime],
        [Latitude],
        [Longitude],
        [CreatedOn],
        [CreatedBy]
    )
    VALUES
    (@ReferenceNo,
     @EstablishmentStatusId,
     @UserId,
     DATEADD(MINUTE, @Offset, @StatusDateTime),
     @Latitude,
     @Longitude,
     GETUTCDATE(),
     @UserId
    );
    SELECT @id = ISNULL(CAST(SCOPE_IDENTITY() AS BIGINT), 0);

    UPDATE dbo.SeenClientAnswerMaster
    SET StatusHistoryId = @id,
        UpdatedOn = DATEADD(MINUTE, @Offset, @StatusDateTime),
        UpdatedBy = @UserId
    WHERE Id = @ReferenceNo;

    SELECT TOP 1
        @sHistoryId = Id
    FROM dbo.StatusHistory
    WHERE ReferenceNo = @ReferenceNo
    ORDER BY StatusDateTime DESC;

    UPDATE dbo.SeenClientAnswerMaster
    SET StatusHistoryId = @sHistoryId
    WHERE Id = @ReferenceNo;

    IF (@IsFromTaskType = 1)
    BEGIN
        IF (@StatusIconImageId = 5)
        BEGIN
            UPDATE dbo.SeenClientAnswerMaster
            SET IsResolved = 'Resolved',
                UpdatedOn = DATEADD(MINUTE, @Offset, @StatusDateTime),
                UpdatedBy = @UserId
            WHERE Id = @ReferenceNo;
        END;
        ELSE
        BEGIN
            UPDATE dbo.SeenClientAnswerMaster
            SET IsResolved = 'Unresolved',
                UpdatedOn = DATEADD(MINUTE, @Offset, @StatusDateTime),
                UpdatedBy = @UserId
            WHERE Id = @ReferenceNo;
        END;
    END;
    SELECT TOP 1
        SH.Id,
        ES.Id AS StatusId,
        SH.ReferenceNo,
        ES.StatusName AS StatusName,
        SII.IconPath AS StatusImage,
        (
            SELECT FORMAT(CAST(SH.StatusDateTime AS DATETIME), 'dd/MMM/yy HH:mm', 'en-us')
        ) AS StatusTime,
        (
            SELECT dbo.DifferenceDatefun(
                                            ISNULL(SH.StatusDateTime, GETUTCDATE()),
                                            DATEADD(MINUTE, @Offset, GETUTCDATE())
                                        )
        ) AS StatusCounter
    FROM dbo.StatusHistory AS SH WITH (NOLOCK)
        INNER JOIN dbo.EstablishmentStatus AS ES WITH (NOLOCK)
            ON SH.EstablishmentStatusId = ES.Id
        INNER JOIN dbo.StatusIconImage SII WITH (NOLOCK)
            ON ES.StatusIconImageId = SII.Id
    WHERE SH.Id = @id;
END;
ELSE
BEGIN
    SELECT @Offset = MAX(E.TimeOffSet)
    FROM dbo.Establishment AS E WITH (NOLOCK)
        INNER JOIN dbo.EstablishmentStatus AS ES WITH (NOLOCK)
            ON ES.EstablishmentId = E.Id
    WHERE E.IsDeleted = 0
          AND ES.Id = @EstablishmentStatusId;

    SELECT TOP 1
        SH.Id,
        ES.Id AS StatusId,
        SH.ReferenceNo,
        ES.StatusName AS StatusName,
        SII.IconPath AS StatusImage,
        (
            SELECT FORMAT(CAST(SH.StatusDateTime AS DATETIME), 'dd/MMM/yy HH:mm', 'en-us')
        ) AS StatusTime,
        (
            SELECT dbo.DifferenceDatefun(
                                            ISNULL(SH.StatusDateTime, GETUTCDATE()),
                                            DATEADD(MINUTE, @Offset, GETUTCDATE())
                                        )
        ) AS StatusCounter
    FROM dbo.StatusHistory AS SH WITH (NOLOCK)
        INNER JOIN dbo.EstablishmentStatus AS ES WITH (NOLOCK)
            ON SH.EstablishmentStatusId = ES.Id
        INNER JOIN dbo.StatusIconImage SII WITH (NOLOCK)
            ON ES.StatusIconImageId = SII.Id
    WHERE SH.ReferenceNo = @ReferenceNo
    ORDER BY SH.StatusDateTime DESC;
    SET NOCOUNT OFF;
END;
--Auto resolve added by mittal
SELECT @DefaultEndStatus = DefaultEndStatus
FROM dbo.EstablishmentStatus WITH (NOLOCK)
WHERE EstablishmentId = @EstablishmentId
      AND Id = @EstablishmentStatusId;

IF (@DefaultEndStatus = 1)
BEGIN
    EXEC dbo.WSResolveUnresolveForm @ReportId = @ReferenceNo, -- bigint
                                    @IsResolved = 'Resolved', -- nvarchar(20)
                                    @AppUserId = @UserId,     -- bigint
                                    @IsOut = 1;               -- bit								

END;
---end

