-- =============================================
-- Author:		<Author,,Vasudev Patel>
-- Create date: <Create Date,, 25,Nov 2019>
-- Description:	<Description,,InsertOrUpdateAppUserReminder>
-- Call SP    :	InsertOrUpdateApplicationUserByManagrId '<ApplicationUser><row><lgAppUserId>19557</lgAppUserId><UserId>19572</UserId></row><row><lgAppUserId>19566</lgAppUserId>UserId>19572</UserId></row></ApplicationUser>',0
-- =============================================
CREATE PROCEDURE dbo.InsertOrUpdateApplicationUserByManagrId
    @ApplicationUser XML,
    @ApplicationUserId BIGINT = 0
AS
BEGIN
    IF (@ApplicationUserId = 0)
    BEGIN
        DECLARE @ManagerId BIGINT;
        CREATE TABLE #TempTable
        (
            AppUserId BIGINT,
            ManagerId BIGINT
        );
        INSERT INTO #TempTable
        (
            AppUserId,
            ManagerId
        )
        SELECT AppUserId = XCol.value('(lgAppUserId)[1]', 'BIGINT'),
               EstablishmentType = XCol.value('(UserId)[1]', 'BIGINT')
        FROM @ApplicationUser.nodes('/ApplicationUser/row') AS XTbl(XCol);
        SELECT TOP 1
            @ManagerId = ManagerId
        FROM #TempTable;

        CREATE TABLE #ExistTable
        (
            Id BIGINT IDENTITY(1, 1),
            AppUserId BIGINT,
            ManagerId VARCHAR(20)
        );

        CREATE TABLE #NotExistTable
        (
            Id BIGINT IDENTITY(1, 1),
            AppUserId BIGINT,
            ManagerId VARCHAR(20)
        );
        CREATE TABLE #DeleteEstabilshment
        (
            id BIGINT IDENTITY(1, 1),
            AppUserId BIGINT,
            ManagerId VARCHAR(20)
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
            AppUserId,
            ManagerId
        )
        SELECT AUE.ApplicationUserId,
               AUE.ManagerUserId
        FROM dbo.AppUserofManage AS AUE
            INNER JOIN
            (SELECT AppUserId, ManagerId FROM #TempTable) AS E
                ON AUE.ApplicationUserId = E.AppUserId
                   AND AUE.ManagerUserId = E.ManagerId
        WHERE ManagerUserId = @ManagerId;

        INSERT INTO #NotExistTable
        (
            AppUserId,
            ManagerId
        )
        SELECT E.AppUserId,
               E.ManagerId
        FROM #TempTable AS E
        WHERE E.AppUserId NOT IN (
                                     SELECT AppUserId FROM #ExistTable
                                 );

        INSERT INTO #DeleteEstabilshment
        (
            AppUserId,
            ManagerId
        )
        SELECT AUE.ApplicationUserId,
               AUE.ManagerUserId
        FROM dbo.AppUserofManage AUE
        WHERE AUE.ApplicationUserId NOT IN (
                                               SELECT AppUserId FROM #ExistTable
                                           )
              AND ManagerUserId = @ManagerId;

        UPDATE AUE
        SET IsDeleted = 1,
            DeletedBy = @ManagerId,
            DeletedOn = GETUTCDATE()
        FROM dbo.AppUserofManage AUE
            INNER JOIN #DeleteEstabilshment E
                ON E.AppUserId = AUE.ApplicationUserId
                   AND AUE.ManagerUserId = E.ManagerId;

        IF EXISTS (SELECT 1 FROM #NotExistTable)
        BEGIN
            INSERT INTO dbo.AppUserofManage
            (
                ApplicationUserId,
                ManagerUserId,
                CreatedOn,
                CreatedBy,
                DeletedBy,
                IsDeleted
            )
            SELECT AppUserId, -- ApplicationUserId - bigint
                   ManagerId, -- ManagerUserId - bigint
                   GETDATE(), -- CreatedOn - datetime
                   ManagerId, -- CreatedBy - bigint
                   0,         -- DeletedBy - bigint
                   0          -- IsDeleted - bit
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
            SELECT @ManagerId,
                   1,
                   'Update record in table AppUserofManage',
                   'AppUserofManage',
                   @ManagerId,
                   GETUTCDATE(),
                   @ManagerId,
                   0
            FROM #NotExistTable;
        END;
        ELSE
        BEGIN
            UPDATE AUE
            SET [UpdatedOn] = GETUTCDATE(),
                [UpdatedBy] = @ManagerId,
                IsDeleted = 0,
                DeletedBy = NULL,
                DeletedOn = NULL
            FROM dbo.AppUserofManage AUE
                INNER JOIN #ExistTable E
                    ON E.AppUserId = AUE.ApplicationUserId
                       AND E.ManagerId = AUE.ManagerUserId
                       AND AUE.ManagerUserId = @ManagerId;
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
            SELECT AppUserId,
                   1,
                   'Update record in table AppUserofManage',
                   'AppUserofManage',
                   @ManagerId,
                   GETUTCDATE(),
                   @ManagerId,
                   0
            FROM #ExistTable;
        END;
    END;
    ELSE
    BEGIN
        UPDATE AUE
        SET IsDeleted = 1,
            DeletedBy = @ManagerId,
            DeletedOn = GETUTCDATE()
        FROM dbo.AppUserofManage AUE
        WHERE ManagerUserId = @ManagerId;
    END;
    SELECT 1 AS InsertedId;
END;

