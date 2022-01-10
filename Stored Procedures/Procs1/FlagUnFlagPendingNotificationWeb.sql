-- =============================================
-- Author:		<Anant Bhatt>
-- Create date: <10-DEC-2018>
-- Description:	<Delete Notifications>
-- Call SP    :	DeletePendingNotificationWeb
-- =============================================
CREATE PROCEDURE [dbo].[FlagUnFlagPendingNotificationWeb]
    @IdList NVARCHAR(MAX),
    @ActionType VARCHAR(6)
AS
BEGIN
    DECLARE @Start INT = 1,
            @Total INT,
            @IsUsed BIT,
            @Id BIGINT,
            @Result NVARCHAR(MAX) = '',
            @Count INT = 0;
    DECLARE @Tbl TABLE
    (
        Id INT,
        Data INT
    );
    INSERT INTO @Tbl
    (
        Id,
        Data
    )
    SELECT Id,
           Data
    FROM dbo.Split(@IdList, ',');
    SELECT @Total = COUNT(1)
    FROM @Tbl;
    IF (@ActionType = 'Flag')
    BEGIN
        UPDATE dbo.[PendingNotificationWeb]
        SET IsFlag = 1
        WHERE [Id] IN (
                          SELECT Data FROM @Tbl
                      );
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
        SELECT P.AppUserId,
               0,
               'Update as Flag recourd in table Pendingnotificationweb',
               'PendingNotificationWeb',
               T.Id,
               GETUTCDATE(),
               P.AppUserId,
               0
        FROM dbo.PendingNotificationWeb AS P
            INNER JOIN @Tbl AS T
                ON T.Id = P.Id;
    END;
    ELSE IF (@ActionType = 'UnFlag')
    BEGIN
        UPDATE dbo.[PendingNotificationWeb]
        SET IsFlag = 0
        WHERE [Id] IN (
                          SELECT Data FROM @Tbl
                      );
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
        SELECT P.AppUserId,
               0,
               'Update as UnFlag recourd in table Pendingnotificationweb',
               'PendingNotificationWeb',
               T.Id,
               GETUTCDATE(),
               P.AppUserId,
               0
        FROM dbo.PendingNotificationWeb AS P
            INNER JOIN @Tbl AS T
                ON T.Id = P.Id;
    END;

END;
