-- =============================================
-- Author:		<Author,,Vasudev Patel>
-- Create date: <Create Date,, 25,Nov 2019>
-- Description:	<Description,,InsertOrUpdateAppUserReminder>
-- Call SP    :	InsertOrUpdateAppUserReminder
-- =============================================
CREATE PROCEDURE [dbo].[InsertOrUpdateAppUserReminder]
    @Establishment XML,
    @ApplicationUserId BIGINT
AS
BEGIN
    IF (@ApplicationUserId = 0)
    BEGIN
        DECLARE @AppUserId BIGINT;
        DECLARE @EstablishmentId BIGINT;
        DECLARE @EstablishmentType NVARCHAR(10);
        DECLARE @UserId BIGINT;
        DECLARE @PageId BIGINT;
        CREATE TABLE #TempTable
        (
            AppUserId BIGINT,
            EstablishmentType NVARCHAR(10) COLLATE SQL_Latin1_General_CP1_CI_AS,
            UserId BIGINT,
            PageId BIGINT,
            EstablishmentId BIGINT
        );

        INSERT INTO #TempTable
        (
            AppUserId,
            EstablishmentType,
            UserId,
            PageId,
            EstablishmentId
        )
        SELECT AppUserId = XCol.value('(lgAppUserId)[1]', 'BIGINT'),
               EstablishmentType = XCol.value('(Type)[1]', 'NVARCHAR(10)'),
               UserId = XCol.value('(UserId)[1]', 'BIGINT'),
               PageId = XCol.value('(AppUser)[1]', 'BIGINT'),
               EstablishmentId = XCol.value('(EstablishmentId)[1]', 'BIGINT')
        FROM @Establishment.nodes('/Establishment/row') AS XTbl(XCol);
        SELECT TOP 1
            @AppUserId = AppUserId,
            @PageId = PageId,
            @UserId = UserId
        FROM #TempTable;
        SELECT *
        FROM #TempTable;
        CREATE TABLE #ExistTable
        (
            Id BIGINT IDENTITY(1, 1),
            EstablishmentId BIGINT,
            EstablishmentType VARCHAR(20)
        );
        CREATE TABLE #NotExistTable
        (
            Id BIGINT IDENTITY(1, 1),
            EstablishmentId BIGINT,
            EstablishmentType VARCHAR(20)
        );
        CREATE TABLE #DeleteEstabilshment
        (
            id BIGINT IDENTITY(1, 1),
            EstablishmentId BIGINT,
            EstablishmentType VARCHAR(20)
        );
        DECLARE @Counter INT,
                @TotalCount INT;
        SET @Counter = 1;
        SET @TotalCount =
        (
            SELECT COUNT(*) FROM #TempTable
        );
        INSERT INTO #ExistTable
        (
            EstablishmentId,
            EstablishmentType
        )
        SELECT AUE.EstablishmentId,
               AUE.EstablishmentType
        FROM dbo.AppUserReminder AS AUE
            INNER JOIN
            (SELECT EstablishmentId, EstablishmentType FROM #TempTable) AS E
                ON AUE.EstablishmentId = E.EstablishmentId
                   AND AUE.EstablishmentType = E.EstablishmentType
        WHERE AppUserId = @AppUserId;
        INSERT INTO #NotExistTable
        (
            EstablishmentId,
            EstablishmentType
        )
        SELECT E.EstablishmentId,
               E.EstablishmentType
        FROM #TempTable AS E
        WHERE E.EstablishmentId NOT IN (
                                           SELECT EstablishmentId FROM #ExistTable
                                       );
        INSERT INTO #DeleteEstabilshment
        (
            EstablishmentId,
            EstablishmentType
        )
        SELECT AUE.EstablishmentId,
               AUE.EstablishmentType
        FROM dbo.AppUserReminder AUE
        WHERE AUE.EstablishmentId NOT IN (
                                             SELECT EstablishmentId FROM #ExistTable
                                         )
              AND AUE.AppUserId = @AppUserId;
        UPDATE AUE
        SET IsDeleted = 1,
            DeletedBy = @UserId,
            DeletedOn = GETUTCDATE()
        FROM dbo.AppUserReminder AUE
            INNER JOIN #DeleteEstabilshment E
                ON E.EstablishmentId = AUE.EstablishmentId
                   AND AUE.AppUserId = @AppUserId
                   AND AUE.EstablishmentType COLLATE SQL_Latin1_General_CP1_CI_AS = E.EstablishmentType COLLATE SQL_Latin1_General_CP1_CI_AS;
        IF EXISTS (SELECT 1 FROM #NotExistTable)
        BEGIN
            INSERT INTO dbo.AppUserReminder
            (
                AppUserId,
                EstablishmentId,
                EstablishmentType,
                CreatedOn,
                CreatedBy,
                UpdatedOn,
                UpdatedBy,
                DeletedOn,
                DeletedBy,
                IsDeleted
            )
            SELECT @AppUserId,        -- AppUserId - bigint
                   EstablishmentId,   -- EstablishmentId - bigint
                   EstablishmentType, -- EstablishmentType - nchar(10)
                   GETDATE(),         -- CreatedOn - datetime
                   0,                 -- CreatedBy - bigint
                   GETDATE(),         -- UpdatedOn - datetime
                   0,                 -- UpdatedBy - bigint
                   NULL,         -- DeletedOn - datetime
                   0,                 -- DeletedBy - bigint
                   0                  -- IsDeleted - bit
            FROM #NotExistTable;

            INSERT INTO dbo.ActivityLog
            (
                UserId,
                PageId,
                AuditComments,
                TableName,
                RecordId,
                CreatedOn,
                CreatedBy,
                IsDeleted
            )
            SELECT @UserId,
                   @PageId,
                   'Update record in table AppUserReminder',
                   'AppUserReminder',
                   EstablishmentId,
                   GETUTCDATE(),
                   @UserId,
                   0
            FROM #NotExistTable;
        END;
        ELSE
        BEGIN
            PRINT 2;
            UPDATE AUE
            SET [UpdatedOn] = GETUTCDATE(),
                [UpdatedBy] = @UserId,
                IsDeleted = 0,
                DeletedBy = NULL,
                DeletedOn = NULL
            FROM dbo.AppUserReminder AUE
                INNER JOIN #ExistTable E
                    ON E.EstablishmentId = AUE.EstablishmentId
                       AND E.EstablishmentType = AUE.EstablishmentType
                       AND AUE.AppUserId = @AppUserId;

            INSERT INTO dbo.ActivityLog
            (
                UserId,
                PageId,
                AuditComments,
                TableName,
                RecordId,
                CreatedOn,
                CreatedBy,
                IsDeleted
            )
            SELECT @UserId,
                   @PageId,
                   'Update record in table AppUserReminder',
                   'AppUserReminder',
                   EstablishmentId,
                   GETUTCDATE(),
                   @UserId,
                   0
            FROM #ExistTable;
        END;
    END;
    ELSE
    BEGIN
        UPDATE AUE
        SET IsDeleted = 1,
            DeletedBy = @UserId,
            DeletedOn = GETUTCDATE()
        FROM dbo.AppUserReminder AUE
        WHERE AppUserId = @ApplicationUserId;
    END;
    SELECT 1 AS InsertedId;
END;

