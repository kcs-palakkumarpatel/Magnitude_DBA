-- =============================================
-- Author:		<Vasudev Patel>
-- Create date: <12 Dec 2018>
-- Description:	Flag Unflag chat and form    
-- Format of ID parameter = ReportId | Notification Id | Type --> 1 = IN, 2 = OUT, 3 = CHAT | ActivityType --> 1 = customer, 0 = sales
-- call: UpdateNotificationFlag '37067|395698|1|1,37065|395690|1|1',1,1864 37049|395534|1|0 37049|395534|1|0
-- =============================================
CREATE PROCEDURE [dbo].[UpdateNotificationFlag]
    @Id VARCHAR(MAX),
    @Flag BIT,
    @AppUserId BIGINT
AS
BEGIN

    DECLARE @Type VARCHAR(10);
    DECLARE @tempId TABLE (id VARCHAR(100));
    DECLARE @InActivity INT;
    DECLARE @delimiter NVARCHAR(100) = '|';

    INSERT INTO @tempId
    SELECT Data
    FROM dbo.Split(@Id, ',');

    DECLARE @TempType TABLE
    (
        Id BIGINT IDENTITY(1, 1),
        ReportId BIGINT,
        NotificationId BIGINT,
        [Type] VARCHAR(10),
        ActivityType INT
    );

    DECLARE @TempType1 TABLE
    (
        Id BIGINT IDENTITY(1, 1),
        ReportId BIGINT,
        NotificationId BIGINT,
        [Type] VARCHAR(10),
        ActivityType INT
    );

    --INSERT INTO @TempType
    --SELECT SUBSTRING(id, 1, CHARINDEX('|', id) - 1),
    --       SUBSTRING(
    --                    SUBSTRING(id, CHARINDEX('|', id) + 1, LEN(SUBSTRING(id, CHARINDEX('|', id) + 1, LEN(id)))),
    --                    1,
    --                    CHARINDEX('|', SUBSTRING(id, CHARINDEX('|', id) + 1, LEN(id))) - 1
    --                ),
    --       REVERSE(SUBSTRING(
    --                            REVERSE(@Id),
    --                            LEN(REPLACE(SUBSTRING(@Id, LEN(@Id) - 1, LEN(@Id) + 1), '|', '')) + 2,
    --                            CHARINDEX(
    --                                         '|',
    --                                         SUBSTRING(
    --                                                      REVERSE(@Id),
    --                                                      CHARINDEX('|', REVERSE(@Id)) + 1,
    --                                                      LEN(REVERSE(@Id))
    --                                                  )
    --                                     ) - 1
    --                        )
    --              ),
    --       REPLACE(SUBSTRING(id, LEN(id) - 1, LEN(id) + 1), '|', '')
    --FROM @tempId;

    IF OBJECT_ID('tempdb..#t', 'u') IS NOT NULL
        DROP TABLE #t;
    CREATE TABLE #t
    (
        id INT IDENTITY(1, 1),
        val BIGINT
    );

    BEGIN
        IF OBJECT_ID('tempdb..#temp', 'u') IS NOT NULL
            DROP TABLE #temp;
        CREATE TABLE #temp (id XML);
        INSERT INTO #temp
        SELECT N'<root><r>' + REPLACE(id, @delimiter, '</r><r>') + '</r></root>'
        FROM @tempId;

        DECLARE @xml XML;
        SET @xml =
        (
            SELECT id FROM #temp FOR XML AUTO
        );

        INSERT INTO #t
        (
            val
        )
        SELECT r.value('.', 'varchar(max)') AS item
        FROM @xml.nodes('//root/r') AS records(r);

        INSERT INTO @TempType
        (
            ReportId,
            NotificationId,
            [Type],
            ActivityType
        )
        SELECT pvt.[0] AS ReportId,
               pvt.[1] AS NotificationId,
               pvt.[2] AS Type,
               pvt.[3] ActivityType
        FROM
        (
            SELECT val,
                   (ROW_NUMBER() OVER (ORDER BY id) - 1) / 4 AS grp,
                   (ROW_NUMBER() OVER (ORDER BY id) - 1) % 4 AS Num1
            FROM #t
        ) p
        PIVOT
        (
            SUM(val)
            FOR Num1 IN ([0], [1], [2], [3])
        ) AS pvt;
    END;

    DECLARE @START INT,
            @COUNT INT;
    SET @START = 1;
    SET @COUNT =
    (
        SELECT COUNT(*) FROM @TempType
    );
    SET @COUNT = @COUNT + 1;

    WHILE (@START < @COUNT)
    BEGIN

        DECLARE @RowType INT,
                @RowNotificationId BIGINT,
                @RowReportId BIGINT,
                @RowActivityTypeId INT;

        SELECT @RowType = [Type],
               @RowNotificationId = NotificationId,
               @RowReportId = ReportId,
               @RowActivityTypeId = ActivityType
        FROM @TempType
        WHERE Id = @START;

        IF (@RowType = 3) -- Chat
        BEGIN
            IF (@Flag = 1)
            BEGIN
                IF NOT EXISTS
                (
                    SELECT *
                    FROM dbo.FlagMaster
                    WHERE ReportId = @RowReportId
                          AND AppUserId = @AppUserId
                )
                    IF NOT EXISTS (SELECT * FROM @TempType1 WHERE ReportId = @RowReportId)
                    BEGIN

                        INSERT INTO @TempType1
                        (
                            ReportId,
                            NotificationId,
                            Type
                        )
                        SELECT RefId,
                               0,
                               1
                        FROM dbo.PendingNotificationWeb
                        WHERE Id = @RowNotificationId
                              AND ModuleId IN ( 2, 5, 7, 11 );

                        INSERT INTO @TempType1
                        (
                            ReportId,
                            NotificationId,
                            Type
                        )
                        SELECT RefId,
                               0,
                               2
                        FROM dbo.PendingNotificationWeb
                        WHERE Id = @RowNotificationId
                              AND ModuleId IN ( 3, 6, 8, 12 );
                    END;

                INSERT INTO @TempType1
                (
                    ReportId,
                    NotificationId,
                    [Type]
                )
                VALUES
                (   @RowReportId,       -- ReportId - bigint
                    @RowNotificationId, -- NotificationId - bigint
                    @RowType            -- Type - varchar(10)
                );
            END;
            DELETE FROM dbo.FlagMaster
            WHERE Id IN (
                            SELECT FM.Id
                            FROM dbo.FlagMaster AS FM
                                INNER JOIN @TempType AS TT
                                    ON FM.ReportId = @RowReportId
                                       AND FM.NotificationId = TT.NotificationId
                                       AND FM.Type = TT.Type
                            WHERE FM.AppUserId = @AppUserId
                                  AND FM.Type IN ( 3 )
                        );
        END;

        ELSE IF (@RowType = 1) -- In
        BEGIN
            IF (@Flag = 1)
            BEGIN
                IF (@RowActivityTypeId = 0) -- Sales
                BEGIN
                    IF NOT EXISTS
                    (
                        SELECT *
                        FROM dbo.FlagMaster
                        WHERE ReportId = @RowReportId
                              AND AppUserId = @AppUserId
                    --AND NotificationId = 0
                    )
                        IF NOT EXISTS (SELECT * FROM @TempType1 WHERE ReportId = @RowReportId)
                        BEGIN

                            INSERT INTO @TempType1
                            (
                                ReportId,
                                NotificationId,
                                Type
                            )
                            SELECT SeenClientAnswerMasterId,
                                   0,
                                   2
                            FROM dbo.AnswerMaster
                            WHERE Id = @RowReportId;
                        END;
                END;
                --ELSE -- Customer
                --BEGIN
                --    INSERT INTO @TempType1
                --    (
                --        ReportId,
                --        NotificationId,
                --        Type
                --    )
                --    SELECT Id,
                --           0,
                --           1
                --    FROM dbo.AnswerMaster
                --    WHERE Id = @RowReportId;

                --END;
                INSERT INTO @TempType1
                (
                    ReportId,
                    NotificationId,
                    [Type]
                )
                VALUES
                (   @RowReportId,       -- ReportId - bigint
                    @RowNotificationId, -- NotificationId - bigint
                    @RowType            -- Type - varchar(10)
                );
            END;

            DELETE FROM dbo.FlagMaster
            WHERE Id IN (
                            SELECT FM.Id
                            FROM dbo.FlagMaster AS FM
                                INNER JOIN @TempType AS TT
                                    ON FM.ReportId = @RowReportId

                                       --AND FM.NotificationId = TT.NotificationId
                                       AND FM.Type = TT.Type
                            WHERE FM.AppUserId = @AppUserId
                                  AND FM.Type = 1
                        );

        END;

        ELSE -- Out -- @rowType = 2
        BEGIN

            IF (@Flag = 1)
            BEGIN
                IF NOT EXISTS
                (
                    SELECT *
                    FROM dbo.FlagMaster
                    WHERE ReportId = @RowReportId
                          AND AppUserId = @AppUserId
                --AND NotificationId = 0
                )
                    IF NOT EXISTS (SELECT * FROM @TempType1 WHERE ReportId = @RowReportId)
                    BEGIN
                        INSERT INTO @TempType1
                        (
                            ReportId,
                            NotificationId,
                            Type
                        )
                        --SELECT ReportId,
                        --       NotificationId,
                        --       Type
                        --FROM @TempType1;
                        SELECT Id,
                               @RowNotificationId,
                               @RowType
                        FROM dbo.SeenClientAnswerMaster
                        WHERE Id = @RowReportId;
                    END;

            END;

            DELETE FROM dbo.FlagMaster
            WHERE Id IN (
                            SELECT FM.Id
                            FROM dbo.FlagMaster AS FM
                                INNER JOIN @TempType AS TT
                                    ON FM.ReportId = @RowReportId

                                       --AND FM.NotificationId = TT.NotificationId
                                       AND FM.Type = TT.Type
                            WHERE FM.AppUserId = @AppUserId
                                  AND FM.Type = 2
                        );
        END;
        SET @START = @START + 1;
    END;

    INSERT INTO dbo.FlagMaster
    (
        ReportId,
        NotificationId,
        Type,
        IsFlag,
        AppUserId,
        CreatedOn,
        CreatedBy,
        IsDeleted
    )
    SELECT ReportId,
           NotificationId,
           [Type],
           @Flag,
           @AppUserId,
           GETUTCDATE(),
           @AppUserId,
           0
    FROM @TempType1;
END;
