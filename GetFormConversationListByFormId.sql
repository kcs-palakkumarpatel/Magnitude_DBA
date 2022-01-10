-- =============================================  
-- Author:   D2  
-- Create date: 06-Sep-017  
-- Description:   
-- Call SP:   GetFormConversationListByFormId 127246,1,4567
-- =============================================  
CREATE PROCEDURE [dbo].[GetFormConversationListByFormId]
    @ReportId BIGINT,
    @IsOut BIT,
    @AppUserId BIGINT
AS
BEGIN
    DECLARE @list VARCHAR(100);
    DECLARE @path VARCHAR(100);
    DECLARE @pathThumbnail VARCHAR(100);
    SELECT @path =
    (
        SELECT TOP 1
            KeyValue + 'Actions/'
        FROM dbo.AAAAConfigSettings
        WHERE KeyName = 'DocViewerRootFolderPathWebApp'
    );

    SELECT @pathThumbnail =
    (
        SELECT TOP 1
            KeyValue + 'Thumbnail/'
        FROM dbo.AAAAConfigSettings
        WHERE KeyName = 'DocViewerRootFolderPathWebApp'
    );

    IF @IsOut = 1
    BEGIN
        SELECT LA.Id,
               [Conversation],
               ISNULL(LA.AppUserId, 0) AS AppUserId,
               CASE
                   WHEN ISNULL(CustomerAppId, 0) = '0' THEN
                       U.Name
                   ELSE
                       ISNULL(LA.CustomerName, U.Name)
               END AS UserName,
               dbo.ChangeDateFormat(DATEADD(MINUTE, E.TimeOffSet, LA.CreatedOn), 'dd/MMM/yy hh:mm') AS CaptureDate,
               CASE LA.IsReminderSet
                   WHEN 1 THEN
                       'Reminder'
                   ELSE
                       ''
               END AS ReminderSet,
               ISNULL(LA.Attachment, '') AS Attachment,
               @path AS FilePath,
               @pathThumbnail AS FilePathThumbnail,
               ISNULL(PNW.IsRead, 1) AS IsRead,
               ISNULL(LA.IsNote, 0) AS IsNote,
               ISNULL(F.IsFlag, 0) AS IsFlag
        FROM dbo.CloseLoopAction AS LA
            INNER JOIN dbo.AppUser AS U
                ON LA.AppUserId = U.Id
            INNER JOIN dbo.SeenClientAnswerMaster AS Am
                ON Am.Id = LA.SeenClientAnswerMasterId
            INNER JOIN dbo.Establishment AS E
                ON E.Id = Am.EstablishmentId
            LEFT JOIN dbo.PendingNotificationWeb PNW
                ON PNW.RefId = @ReportId
                   AND PNW.AppUserId = @AppUserId
                   AND LA.[Conversation] = PNW.[Message]
            LEFT OUTER JOIN dbo.FlagMaster AS F
                ON F.ReportId = Am.Id
                   AND F.AppUserId = @AppUserId
                   AND F.NotificationId = PNW.Id
                   AND F.Type = 3
        WHERE --LA.IsNote = 0 AND   
            LA.SeenClientAnswerMasterId = @ReportId
            AND LA.IsDeleted = 0
        UNION
        SELECT LA.Id,
               [Conversation],
               ISNULL(LA.AppUserId, 0) AS AppUserId,
               CASE
                   WHEN ISNULL(CustomerAppId, 0) = '0' THEN
                       U.Name
                   ELSE
                       ISNULL(LA.CustomerName, U.Name)
               END AS UserName,
               dbo.ChangeDateFormat(DATEADD(MINUTE, E.TimeOffSet, LA.CreatedOn), 'dd/MMM/yy hh:mm') AS CaptureDate,
               CASE LA.IsReminderSet
                   WHEN 1 THEN
                       'Reminder'
                   ELSE
                       ''
               END AS ReminderSet,
               ISNULL(LA.Attachment, '') AS Attachment,
               @path AS FilePath,
               @pathThumbnail AS FilePathThumbnail,
               ISNULL(PNW.IsRead, 1) AS IsRead,
               ISNULL(LA.IsNote, 0) AS IsNote,
               ISNULL(F.IsFlag, 0) AS IsFlag
        FROM dbo.CloseLoopAction AS LA
            INNER JOIN dbo.AppUser AS U
                ON LA.AppUserId = U.Id
            INNER JOIN dbo.AnswerMaster AS Am
                ON Am.Id = LA.AnswerMasterId
            INNER JOIN dbo.Establishment AS E
                ON E.Id = Am.EstablishmentId
            LEFT JOIN dbo.PendingNotificationWeb PNW
                ON PNW.RefId = @ReportId
                   AND PNW.AppUserId = @AppUserId
                   AND LA.[Conversation] = PNW.[Message]
            LEFT OUTER JOIN dbo.FlagMaster AS F
                ON F.ReportId = Am.Id
                   AND F.AppUserId = @AppUserId
                   AND F.NotificationId = PNW.Id
                   AND F.Type = 3
        WHERE Am.SeenClientAnswerMasterId = @ReportId
              AND LA.IsDeleted = 0
        UNION
        SELECT LA.Id,
               [Conversation],
               ISNULL(LA.AppUserId, 0) AS AppUserId,
               CASE
                   WHEN ISNULL(CustomerAppId, 0) = '0' THEN
                       U.Name
                   ELSE
                       ISNULL(LA.CustomerName, U.Name)
               END AS UserName,
               dbo.ChangeDateFormat(DATEADD(MINUTE, E.TimeOffSet, LA.CreatedOn), 'dd/MMM/yy hh:mm') AS CaptureDate,
               CASE LA.IsReminderSet
                   WHEN 1 THEN
                       'Reminder'
                   ELSE
                       ''
               END AS ReminderSet,
               ISNULL(LA.Attachment, '') AS Attachment,
               @path AS FilePath,
               @pathThumbnail AS FilePathThumbnail,
               ISNULL(PNW.IsRead, 1) AS IsRead,
               ISNULL(LA.IsNote, 0) AS IsNote,
               ISNULL(F.IsFlag, 0) AS IsFlag
        FROM dbo.CloseLoopAction AS LA
            INNER JOIN dbo.AppUser AS U
                ON LA.AppUserId = U.Id
            INNER JOIN dbo.SeenClientAnswerMaster AS Am
                ON Am.Id = LA.SeenClientAnswerMasterId
            INNER JOIN dbo.Establishment AS E
                ON E.Id = Am.EstablishmentId
            LEFT JOIN dbo.PendingNotificationWeb PNW
                ON PNW.RefId = @ReportId
                   AND PNW.AppUserId = @AppUserId
                   AND LA.[Conversation] = PNW.[Message]
            LEFT OUTER JOIN dbo.FlagMaster AS F
                ON F.ReportId = Am.Id
                   AND F.AppUserId = @AppUserId
                   AND F.NotificationId = PNW.Id
                   AND F.Type = 3
        WHERE --LA.IsNote = 1 AND   
            LA.AppUserId = @AppUserId
            AND LA.SeenClientAnswerMasterId = @ReportId
            AND LA.IsDeleted = 0;
    END;
    ELSE
    BEGIN
        SELECT LA.Id,
               [Conversation],
               ISNULL(LA.AppUserId, 0) AS AppUserId,
               CASE
                   WHEN ISNULL(CustomerAppId, 0) = '0' THEN
                       U.Name
                   ELSE
                       ISNULL(LA.CustomerName, U.Name)
               END AS UserName,
               dbo.ChangeDateFormat(DATEADD(MINUTE, E.TimeOffSet, LA.CreatedOn), 'dd/MMM/yy hh:mm') AS CaptureDate,
               CASE LA.IsReminderSet
                   WHEN 1 THEN
                       'Reminder'
                   ELSE
                       ''
               END AS ReminderSet,
               ISNULL(LA.Attachment, '') AS Attachment,
               @path AS FilePath,
               @pathThumbnail AS FilePathThumbnail,
               ISNULL(PNW.IsRead, 1) AS IsRead,
               ISNULL(LA.IsNote, 0) AS IsNote,
               ISNULL(F.IsFlag, 0) AS IsFlag
        FROM dbo.CloseLoopAction AS LA
            INNER JOIN dbo.AppUser AS U
                ON LA.AppUserId = U.Id
            INNER JOIN dbo.AnswerMaster AS Am
                ON Am.Id = LA.AnswerMasterId
            INNER JOIN dbo.Establishment AS E
                ON E.Id = Am.EstablishmentId
            LEFT JOIN dbo.PendingNotificationWeb PNW
                ON PNW.RefId = @ReportId
                   AND PNW.AppUserId = @AppUserId
                   AND LA.[Conversation] = PNW.[Message]
            LEFT OUTER JOIN dbo.FlagMaster AS F
                ON F.ReportId = Am.Id
                   AND F.AppUserId = @AppUserId
                   AND F.NotificationId = PNW.Id
                   AND F.Type = 3
        WHERE LA.AnswerMasterId = @ReportId
              AND LA.IsDeleted = 0
        UNION
        SELECT LA.Id,
               [Conversation],
               ISNULL(LA.AppUserId, 0) AS AppUserId,
               CASE
                   WHEN ISNULL(CustomerAppId, 0) = '0' THEN
                       U.Name
                   ELSE
                       ISNULL(LA.CustomerName, U.Name)
               END AS UserName,
               dbo.ChangeDateFormat(DATEADD(MINUTE, E.TimeOffSet, LA.CreatedOn), 'dd/MMM/yy hh:mm') AS CaptureDate,
               CASE LA.IsReminderSet
                   WHEN 1 THEN
                       'Reminder'
                   ELSE
                       ''
               END AS ReminderSet,
               ISNULL(LA.Attachment, '') AS Attachment,
               @path AS FilePath,
               @pathThumbnail AS FilePathThumbnail,
               ISNULL(PNW.IsRead, 1) AS IsRead,
               ISNULL(LA.IsNote, 0) AS IsNote,
               ISNULL(F.IsFlag, 0) AS IsFlag
        FROM dbo.CloseLoopAction AS LA
            INNER JOIN dbo.AppUser AS U
                ON LA.AppUserId = U.Id
            INNER JOIN dbo.AnswerMaster AS Am
                ON Am.Id = LA.AnswerMasterId
            INNER JOIN dbo.Establishment AS E
                ON E.Id = Am.EstablishmentId
            LEFT JOIN dbo.PendingNotificationWeb AS PNW
                ON PNW.RefId = @ReportId
                   AND PNW.AppUserId = @AppUserId
                   AND LA.[Conversation] = PNW.[Message]
            LEFT OUTER JOIN dbo.FlagMaster AS F
                ON F.ReportId = Am.Id
                   AND F.AppUserId = @AppUserId
                   AND F.NotificationId = PNW.Id
                   AND F.Type = 3
        WHERE Am.SeenClientAnswerMasterId =
        (
            SELECT ISNULL(SeenClientAnswerMasterId, 0)
            FROM AnswerMaster
            WHERE Id = @ReportId
        )
              AND LA.IsDeleted = 0
        UNION
        SELECT LA.Id,
               [Conversation],
               ISNULL(LA.AppUserId, 0) AS AppUserId,
               CASE
                   WHEN ISNULL(CustomerAppId, 0) = '0' THEN
                       U.Name
                   ELSE
                       ISNULL(LA.CustomerName, U.Name)
               END AS UserName,
               dbo.ChangeDateFormat(DATEADD(MINUTE, E.TimeOffSet, LA.CreatedOn), 'dd/MMM/yy hh:mm') AS CaptureDate,
               CASE LA.IsReminderSet
                   WHEN 1 THEN
                       'Reminder'
                   ELSE
                       ''
               END AS ReminderSet,
               ISNULL(LA.Attachment, '') AS Attachment,
               @path AS FilePath,
               @pathThumbnail AS FilePathThumbnail,
               ISNULL(PNW.IsRead, 1) AS IsRead,
               ISNULL(LA.IsNote, 0) AS IsNote,
               ISNULL(F.IsFlag, 0) AS IsFlag
        FROM dbo.CloseLoopAction AS LA
            INNER JOIN dbo.AppUser AS U
                ON LA.AppUserId = U.Id
            INNER JOIN dbo.SeenClientAnswerMaster AS Am
                ON Am.Id = LA.SeenClientAnswerMasterId
            INNER JOIN dbo.Establishment AS E
                ON E.Id = Am.EstablishmentId
            LEFT JOIN dbo.PendingNotificationWeb PNW
                ON PNW.RefId = @ReportId
                   AND PNW.AppUserId = @AppUserId
                   AND LA.[Conversation] = PNW.[Message]
            LEFT OUTER JOIN dbo.FlagMaster AS F
                ON F.ReportId = Am.Id
                   AND F.AppUserId = @AppUserId
                   AND F.NotificationId = PNW.Id
                   AND F.Type = 3
        WHERE LA.SeenClientAnswerMasterId =
        (
            SELECT ISNULL(SeenClientAnswerMasterId, 0)
            FROM dbo.AnswerMaster
            WHERE Id = @ReportId
        )
              AND LA.IsDeleted = 0;
    END;
END;
