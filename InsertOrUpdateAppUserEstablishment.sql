-- =============================================
-- Author:		<Author,,GD>
-- Create date: <Create Date,, 09 Jun 2015>
-- Description:	<Description,,InsertOrUpdateAppUserEstablishment>
-- Call SP    :	InsertOrUpdateAppUserEstablishment
-- =============================================
CREATE PROCEDURE [dbo].[InsertOrUpdateAppUserEstablishment] @Establishment XML
AS
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
    FROM dbo.AppUserEstablishment AS AUE
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
           CASE
           (
               SELECT EG.EstablishmentGroupType
               FROM dbo.EstablishmentGroup AS EG
                   JOIN dbo.Establishment AS ES
                       ON ES.EstablishmentGroupId = EG.Id
               WHERE ES.Id = E.EstablishmentId
           )
               WHEN 'Task' THEN
                   'Task'
               ELSE
                   E.EstablishmentType
           END AS EstablishmentType
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
    FROM dbo.AppUserEstablishment AUE
    WHERE AUE.EstablishmentId NOT IN (
                                         SELECT EstablishmentId FROM #ExistTable
                                     )
          AND AUE.AppUserId = @AppUserId;

    UPDATE AUE
    SET IsDeleted = 1,
        DeletedBy = @UserId,
        DeletedOn = GETUTCDATE()
    FROM dbo.AppUserEstablishment AUE
        INNER JOIN #DeleteEstabilshment E
            ON E.EstablishmentId = AUE.EstablishmentId
               AND AUE.AppUserId = @AppUserId
               AND AUE.EstablishmentType COLLATE SQL_Latin1_General_CP1_CI_AS = E.EstablishmentType COLLATE SQL_Latin1_General_CP1_CI_AS;

    IF EXISTS (SELECT 1 FROM #NotExistTable)
    BEGIN
        PRINT 1;
        INSERT INTO dbo.[AppUserEstablishment]
        (
            [AppUserId],
            [EstablishmentId],
            [NotificationStatus],
            [EstablishmentType],
            [DelayTime],
            [CreatedOn],
            [CreatedBy],
            [IsDeleted],
            ActivitySequence
        )
        SELECT @AppUserId,
               EstablishmentId,
               1,
               EstablishmentType,
               NULL,
               GETUTCDATE(),
               @UserId,
               0,
               0
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
               'Update record in table AppUserEstablishment',
               'AppUserEstablishment',
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
        FROM dbo.AppUserEstablishment AUE
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
               'Update record in table AppUserEstablishment',
               'AppUserEstablishment',
               EstablishmentId,
               GETUTCDATE(),
               @UserId,
               0
        FROM #ExistTable;
    END;
    SELECT 1 AS InsertedId;
--- SELECT  ISNULL(@Id, 0) AS InsertedId
END;

