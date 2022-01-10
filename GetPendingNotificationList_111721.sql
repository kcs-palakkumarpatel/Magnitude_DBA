
-- =============================================
-- Author:		<Author,,GD>
-- Create date: <Create Date,,07 Jul 2015>
-- Description:	<Description,,>
-- Call SP:		GetPendingNotificationList 

-- =============================================
CREATE PROCEDURE [dbo].[GetPendingNotificationList_111721]
AS
BEGIN

    DECLARE @LatestAppVersion INT;
    SELECT @LatestAppVersion = CAST(KeyValue AS INT)
    FROM dbo.AAAAConfigSettings
    WHERE KeyName = 'androidVersion';

    EXEC dbo.InsertCaptureFeedbackNotification;
    SELECT Id,
           ModuleId,
           Message,
           UserDeviceId AS TokenId,
           SentDate,
           ScheduleDate,
           CAST(ISNULL(0, 0) AS BIGINT) AS RefId,
           AppUserId,
           P.DeviceType AS DeviceType,
           1 AS VersionCheck, --PASS 1 DUE TO CHANGE LOGIC FOR ANDROID NOTIFICATION
           ISNULL(CAST(0 AS BIT), 0) AS IsDevelopment,
           ISNULL(0, 0) AS BaseCount,
           ISNULL(0, 0) AS unreadCount,
           (
               SELECT E.EstablishmentGroupId
               FROM dbo.Establishment E
               WHERE Id = P.EstablishmentId
           ) AS ActivityId
    FROM PendingEstablishmentReminder P
    WHERE IsOut = 1
          AND IsSent = 0
          AND FormCapturedbyUser = 0
          AND (ScheduleDate <= GETUTCDATE())
          AND IsDeleted = 0
          AND LEN(UserDeviceId) > 10
          AND ModuleId IN ( 13 )
    UNION
    SELECT Id,
           ModuleId,
           Message,
           TokenId,
           SentDate,
           ScheduleDate,
           RefId,
           AppUserId,
           DeviceType,
           1 AS VersionCheck, --PASS 1 DUE TO CHANGE LOGIC FOR ANDROID NOTIFICATION
           ISNULL(CAST(0 AS BIT), 0) AS IsDevelopment,
           (
               SELECT dbo.GetBadgeCount(PendingNotification.AppUserId)
           ) AS BaseCount,
           (
               SELECT
                   (
                       SELECT COUNT(1)
                       FROM dbo.PendingNotificationWeb
                       WHERE AppUserId = dbo.PendingNotificationWeb.AppUserId
                             AND IsRead = 0
                             AND ModuleId = 11
                             AND RefId = dbo.PendingNotification.RefId
                   ) +
                   (
                       SELECT COUNT(1)
                       FROM dbo.PendingNotificationWeb
                       WHERE AppUserId = PendingNotification.AppUserId
                             AND IsRead = 0
                             AND ModuleId = 12
                             AND RefId = dbo.PendingNotification.RefId
                   )
           ) AS unreadCount,
           CASE
               WHEN ModuleId IN ( 2, 5, 7, 11 ) THEN
               (
                   SELECT E.EstablishmentGroupId
                   FROM dbo.AnswerMaster AS AM
                       INNER JOIN dbo.Establishment AS E
                           ON AM.EstablishmentId = E.Id
                   WHERE AM.Id = RefId
               )
               WHEN ModuleId IN ( 3, 6, 8, 12 ) THEN
               (
                   SELECT E.EstablishmentGroupId
                   FROM dbo.SeenClientAnswerMaster AS AM
                       INNER JOIN dbo.Establishment AS E
                           ON AM.EstablishmentId = E.Id
                   WHERE AM.Id = RefId
               )
           END AS ActivityId
    FROM PendingNotification
    WHERE ([Status] = 0)
          AND (ScheduleDate <= GETUTCDATE())
          AND IsDeleted = 0
          AND LEN(TokenId) > 10
          AND ModuleId IN ( 2, 3, 5, 6, 7, 8, 11, 12 );
END;
