
-- =============================================
-- Author:			Sunil Vaghasiya
-- Create date:	15-June-2017
-- Description:
-- Call SP:			dbo.GetPreviousFormLastChatByReportId 1117488, 5108,1
-- =============================================
CREATE PROCEDURE [dbo].[GetPreviousFormLastChatByReportId_111721]
    @ReportId BIGINT,
    @AppUserId BIGINT,
    @HasOutForm BIT
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @TMP TABLE
    (
        UnreadActionCount INT,
        [Conversation] NVARCHAR(MAX),
        [Message] NVARCHAR(MAX),
        [User] NVARCHAR(150),
        [Date] NVARCHAR(50)
    );
    DECLARE @seenclientAnswerId BIGINT;
    IF (@HasOutForm = 0)
    BEGIN
        SELECT @seenclientAnswerId = ISNULL(SeenClientAnswerMasterId, 0)
        FROM dbo.AnswerMaster WITH
            (NOLOCK)
        WHERE Id = @ReportId;
        IF (@seenclientAnswerId > 0)
        BEGIN
            SET @ReportId = @seenclientAnswerId;
            SET @HasOutForm = 1;
        END;
    END;

    IF (@HasOutForm = 0)
    BEGIN
        INSERT INTO @TMP
        (
            UnreadActionCount,
            [Conversation],
            [Message],
            [User],
            [Date]
        )
        SELECT TOP 1
               ISNULL(
               (
                   SELECT TOP 1
                          SUM(   CASE
                                     WHEN IsRead = 0 THEN
                                         1
                                     ELSE
                                         0
                                 END
                             ) OVER () AS Unread
                   FROM dbo.PendingNotificationWeb WITH
                       (NOLOCK)
                   WHERE RefId = @ReportId
                         AND AppUserId = @AppUserId
                         AND ModuleId IN ( 11, 12 )
               ),
               0
                     ) AS UnreadActionCount,
               CASE
                   WHEN ISNULL(CustomerAppId, 0) = '0' THEN
                       AU.Name
                   ELSE
                       ISNULL(CLA.CustomerName, AU.Name)
               END + ': ' + [Conversation] + IIF(ISNULL(CLA.Attachment, '') = '', '', ' Attachment added.') AS [Conversation],
               [Conversation] + IIF(ISNULL(CLA.Attachment, '') = '', '', ' Attachment added.') AS [Message],
               CASE
                   WHEN ISNULL(CustomerAppId, 0) = '0' THEN
                       AU.Name
                   ELSE
                       ISNULL(CLA.CustomerName, AU.Name)
               END AS [User],
               dbo.ChangeDateFormat(CLA.CreatedOn, 'dd/MMM/yy hh:mm') AS [Date]
        FROM dbo.CloseLoopAction AS CLA WITH
            (NOLOCK)
            INNER JOIN dbo.AppUser AS AU WITH(NOLOCK)
                ON AU.Id = CLA.AppUserId
        WHERE (CLA.AnswerMasterId = @ReportId) --AND CLA.IsNote = 0
        ORDER BY CLA.CreatedOn DESC;
    END;
    ELSE
    BEGIN
        INSERT INTO @TMP
        (
            UnreadActionCount,
            [Conversation],
            [Message],
            [User],
            [Date]
        )
        SELECT TOP 1
               ISNULL(
               (
                   SELECT TOP 1
                          SUM(   CASE
                                     WHEN IsRead = 0 THEN
                                         1
                                     ELSE
                                         0
                                 END
                             ) OVER () AS Unread
                   FROM dbo.PendingNotificationWeb WITH
                       (NOLOCK)
                   WHERE RefId = @ReportId
                         AND AppUserId = @AppUserId
                         AND ModuleId IN ( 11, 12 )
               ),
               0
                     ) AS UnreadActionCount,
               CASE
                   WHEN ISNULL(CustomerAppId, 0) = '0' THEN
                       AU.Name
                   ELSE
                       ISNULL(CLA.CustomerName, AU.Name)
               END + ': ' + [Conversation] + IIF(ISNULL(CLA.Attachment, '') = '', '', ' Attachment added.') AS [Conversation],
               [Conversation] + IIF(ISNULL(CLA.Attachment, '') = '', '', ' Attachment added.') AS [Message],
               CASE
                   WHEN ISNULL(CustomerAppId, 0) = '0' THEN
                       AU.Name
                   ELSE
                       ISNULL(CLA.CustomerName, AU.Name)
               END AS [User],
               dbo.ChangeDateFormat(CLA.CreatedOn, 'dd/MMM/yy hh:mm') AS [Date]
        FROM dbo.CloseLoopAction AS CLA WITH
            (NOLOCK)
            INNER JOIN dbo.AppUser AS AU WITH
            (NOLOCK)
                ON AU.Id = CLA.AppUserId
        WHERE (
                  CLA.SeenClientAnswerMasterId = @ReportId
                  OR CLA.AnswerMasterId IN
                     (
                         SELECT Id
                         FROM dbo.AnswerMaster WITH
                             (NOLOCK)
                         WHERE SeenClientAnswerMasterId = @ReportId
                               AND IsDeleted = 0
                     )
              ) --AND CLA.IsNote = 0
        ORDER BY CLA.CreatedOn DESC;
    END;

    --IF ((SELECT COUNT(1) FROM @TMP) = 0)
    --BEGIN
    --    INSERT INTO @TMP
    --    (
    --        UnreadActionCount,
    --        [Conversation],
    --        [Message],
    --        [User],
    --        [Date]
    --    )
    --    SELECT TOP 1
    --           ISNULL(
    --           (
    --               SELECT TOP 1
    --                      SUM(   CASE
    --                                 WHEN IsRead = 0 THEN
    --                                     1
    --                                 ELSE
    --                                     0
    --                             END
    --                         ) OVER () AS Unread
    --               FROM dbo.PendingNotificationWeb WITH
    --                   (NOLOCK)
    --               WHERE RefId = @ReportId
    --                     AND AppUserId = @AppUserId
    --                     AND ModuleId IN ( 11, 12 )
    --           ),
    --           0
    --                 ) AS UnreadActionCount,
    --           CASE
    --               WHEN ISNULL(CustomerAppId, 0) = '0' THEN
    --                   AU.Name
    --               ELSE
    --                   ISNULL(CLA.CustomerName, AU.Name)
    --           END + ': ' + [Conversation] + IIF(ISNULL(CLA.Attachment, '') = '', '', ' Attachment added.') AS [Conversation],
    --           [Conversation] + IIF(ISNULL(CLA.Attachment, '') = '', '', ' Attachment added.') AS [Message],
    --           CASE
    --               WHEN ISNULL(CustomerAppId, 0) = '0' THEN
    --                   AU.Name
    --               ELSE
    --                   ISNULL(CLA.CustomerName, AU.Name)
    --           END AS [USER],
    --           dbo.ChangeDateFormat(CLA.CreatedOn, 'dd/MMM/yy hh:mm') AS [Date]
    --    FROM dbo.CloseLoopAction AS CLA WITH
    --        (NOLOCK)
    --        INNER JOIN dbo.AppUser AS AU WITH
    --        (NOLOCK)
    --            ON AU.Id = CLA.AppUserId
    --    WHERE (CLA.SeenClientAnswerMasterId =
    --          (
    --              SELECT SeenClientAnswerMasterId
    --              FROM dbo.AnswerMaster WITH
    --                  (NOLOCK)
    --              WHERE Id = @ReportId
    --          )
    --          ) --AND CLA.IsNote = 0
    --    ORDER BY CLA.CreatedOn DESC;
    --END;

    IF ((SELECT COUNT(1) FROM @TMP) = 0)
    BEGIN
        INSERT INTO @TMP
        (
            UnreadActionCount,
            [Conversation],
            [Message],
            [User],
            [Date]
        )
        VALUES
        (0, N'No Action.', N'No Action.', N'', '');
    END;

    SELECT *
    FROM @TMP;
SET NOCOUNT OFF;
END;
