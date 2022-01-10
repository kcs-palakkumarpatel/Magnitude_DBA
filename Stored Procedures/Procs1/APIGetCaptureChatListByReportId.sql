-- =============================================
-- Author:			Developer D3
-- Create date:	05-June-2017
-- Description:	Get Capture from Chat Data for Web API Using ReportId
-- Call:					dbo.APIGetCaptureChatListByReportId '71091, 71037'
-- =============================================
CREATE PROCEDURE [dbo].[APIGetCaptureChatListByReportId] @ReportId VARCHAR(MAX)
AS
BEGIN
    DECLARE @list VARCHAR(100);
    DECLARE @path VARCHAR(100);
    SELECT @path =
    (
        SELECT TOP 1
               KeyValue + 'Actions/'
        FROM dbo.AAAAConfigSettings
        WHERE KeyName = 'DocViewerRootFolderPathWebApp'
    ) ;

    SELECT LA.SeenClientAnswerMasterId AS ReportId,
           LA.Id AS ChatId,
           [Conversation],
           U.Name AS Sender,
           dbo.ChangeDateFormat(DATEADD(MINUTE, E.TimeOffSet, LA.CreatedOn), 'dd/MMM/yyyy hh:mm AM/PM') AS CreatedDate,
           CASE LA.IsReminderSet
               WHEN 1 THEN
                   'Reminder'
               ELSE
                   ''
           END AS ReminderSet,
           ISNULL(LA.Attachment, '') AS Attachment,
           @path AS FilePath,
           ISNULL(PNW.IsRead, 1) AS IsRead
    FROM dbo.CloseLoopAction AS LA
        INNER JOIN dbo.AppUser AS U
            ON LA.AppUserId = U.Id
        INNER JOIN dbo.SeenClientAnswerMaster AS Am
            ON Am.Id = LA.SeenClientAnswerMasterId
        INNER JOIN dbo.Establishment AS E
            ON E.Id = Am.EstablishmentId
        LEFT JOIN dbo.PendingNotificationWeb PNW
            ON PNW.RefId IN
               (
                   SELECT Data FROM dbo.Split(@ReportId, ',')
               )
               AND LA.[Conversation] = PNW.[Message]
    WHERE LA.SeenClientAnswerMasterId IN
          (
              SELECT Data FROM dbo.Split(@ReportId, ',')
          )
    UNION
    SELECT LA.SeenClientAnswerMasterId AS ReportId,
           LA.Id AS ChatId,
           [Conversation],
           U.Name AS Sender,
           dbo.ChangeDateFormat(DATEADD(MINUTE, E.TimeOffSet, LA.CreatedOn), 'dd/MMM/yyyy hh:mm AM/PM') AS CreatedDate,
           CASE LA.IsReminderSet
               WHEN 1 THEN
                   'Reminder'
               ELSE
                   ''
           END AS ReminderSet,
           ISNULL(LA.Attachment, '') AS Attachment,
           @path AS FilePath,
           PNW.IsRead AS IsRead
    FROM dbo.CloseLoopAction AS LA
        INNER JOIN dbo.AppUser AS U
            ON LA.AppUserId = U.Id
        INNER JOIN dbo.AnswerMaster AS Am
            ON Am.Id = LA.AnswerMasterId
        INNER JOIN dbo.Establishment AS E
            ON E.Id = Am.EstablishmentId
        LEFT JOIN dbo.PendingNotificationWeb PNW
            ON PNW.RefId IN
               (
                   SELECT Data FROM dbo.Split(@ReportId, ',')
               )
               AND LA.[Conversation] = PNW.[Message]
    WHERE Am.SeenClientAnswerMasterId IN
          (
              SELECT Data FROM dbo.Split(@ReportId, ',')
          )
    UNION
    SELECT LA.SeenClientAnswerMasterId AS ReportId,
           LA.Id AS ChatId,
           [Conversation],
           U.Name AS Sender,
           dbo.ChangeDateFormat(DATEADD(MINUTE, E.TimeOffSet, LA.CreatedOn), 'dd/MMM/yyyy hh:mm AM/PM') AS CreatedDate,
           CASE LA.IsReminderSet
               WHEN 1 THEN
                   'Reminder'
               ELSE
                   ''
           END AS ReminderSet,
           ISNULL(LA.Attachment, '') AS Attachment,
           @path AS FilePath,
           PNW.IsRead AS IsRead
    FROM dbo.CloseLoopAction AS LA
        INNER JOIN dbo.AppUser AS U
            ON LA.AppUserId = U.Id
        INNER JOIN dbo.AnswerMaster AS Am
            ON Am.Id = LA.AnswerMasterId
        INNER JOIN dbo.Establishment AS E
            ON E.Id = Am.EstablishmentId
        INNER JOIN dbo.PendingNotificationWeb PNW
            ON PNW.RefId = LA.AnswerMasterId
               AND LA.[Conversation] = PNW.[Message]
    WHERE LA.AnswerMasterId IN
          (
              SELECT Data FROM dbo.Split(@ReportId, ',')
          )
    UNION
    SELECT LA.SeenClientAnswerMasterId AS ReportId,
           LA.Id AS ChatId,
           [Conversation],
           U.Name AS Sender,
           dbo.ChangeDateFormat(DATEADD(MINUTE, E.TimeOffSet, LA.CreatedOn), 'dd/MMM/yyyy hh:mm AM/PM') AS CreatedDate,
           CASE LA.IsReminderSet
               WHEN 1 THEN
                   'Reminder'
               ELSE
                   ''
           END AS ReminderSet,
           ISNULL(LA.Attachment, '') AS Attachment,
           @path AS FilePath,
           PNW.IsRead AS IsRead
    FROM dbo.CloseLoopAction AS LA
        INNER JOIN dbo.AppUser AS U
            ON LA.AppUserId = U.Id
        INNER JOIN dbo.AnswerMaster AS Am
            ON Am.Id = LA.AnswerMasterId
        INNER JOIN dbo.Establishment AS E
            ON E.Id = Am.EstablishmentId
        INNER JOIN dbo.PendingNotificationWeb AS PNW
            ON PNW.RefId = Am.SeenClientAnswerMasterId
               AND LA.[Conversation] = PNW.[Message]
    WHERE Am.SeenClientAnswerMasterId =
    (
        SELECT ISNULL(SeenClientAnswerMasterId, 0)
        FROM AnswerMaster
        WHERE Id IN
              (
                  SELECT Data FROM dbo.Split(@ReportId, ',')
              )
    )
    UNION
    SELECT LA.SeenClientAnswerMasterId AS ReportId,
           LA.Id AS ChatId,
           [Conversation],
           U.Name AS Sender,
           dbo.ChangeDateFormat(DATEADD(MINUTE, E.TimeOffSet, LA.CreatedOn), 'dd/MMM/yyyy hh:mm AM/PM') AS CreatedDate,
           CASE LA.IsReminderSet
               WHEN 1 THEN
                   'Reminder'
               ELSE
                   ''
           END AS ReminderSet,
           ISNULL(LA.Attachment, '') AS Attachment,
           @path AS FilePath,
           PNW.IsRead AS IsRead
    FROM dbo.CloseLoopAction AS LA
        INNER JOIN dbo.AppUser AS U
            ON LA.AppUserId = U.Id
        INNER JOIN dbo.SeenClientAnswerMaster AS Am
            ON Am.Id = LA.SeenClientAnswerMasterId
        INNER JOIN dbo.Establishment AS E
            ON E.Id = Am.EstablishmentId
        INNER JOIN dbo.PendingNotificationWeb PNW
            ON PNW.RefId = LA.SeenClientAnswerMasterId
               AND LA.[Conversation] = PNW.[Message]
    WHERE LA.SeenClientAnswerMasterId =
    (
        SELECT ISNULL(SeenClientAnswerMasterId, 0)
        FROM dbo.AnswerMaster
        WHERE Id IN
              (
                  SELECT Data FROM dbo.Split(@ReportId, ',')
              )
    );
END;

