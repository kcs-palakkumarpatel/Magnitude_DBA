-- =============================================
-- Author:		<Author,,GD>
-- Create date: <Create Date,,02 Jul 2015>
-- Description:	<Description,,>
-- Call SP:		WSGetActionListByReportId_31052017 94982, 1,1243
--				WSGetActionListByReportId 88860,1,1243
-- =============================================
CREATE PROCEDURE [dbo].[WSGetActionListByReportId]
    @ReportId BIGINT ,
    @IsOut BIT ,
    @AppUserId BIGINT
AS
    BEGIN
        DECLARE @list VARCHAR(100);
        DECLARE @path VARCHAR(100);
        SELECT  @path = ( SELECT TOP 1
                                    KeyValue + 'Actions/'
                          FROM      dbo.AAAAConfigSettings
                          WHERE     KeyName = 'DocViewerRootFolderPathWebApp'
                        );

        IF @IsOut = 1
            BEGIN
                SELECT  LA.Id ,
                        [Conversation] ,
                     ISNULL(LA.AppUserId, 0) AS AppUserId,
               CASE
                   WHEN ISNULL(CustomerAppId, 0) = '0' THEN
                       U.Name
                   ELSE
                       ISNULL(LA.CustomerName, U.Name)
               END AS UserName,
                        dbo.ChangeDateFormat(DATEADD(MINUTE, E.TimeOffSet,
                                                     LA.CreatedOn),
                                             'dd/MMM/yy hh:mm') AS CaptureDate ,
                        CASE LA.IsReminderSet
                          WHEN 1 THEN 'Reminder'
                          ELSE ''
                        END AS ReminderSet ,
                        ISNULL(LA.Attachment, '') AS Attachment ,
                        @path AS FilePath ,
                        ISNULL(PNW.IsRead, 1) AS IsRead ,
                        ISNULL(LA.IsNote, 0) AS IsNote ,
                        ISNULL(LA.IsExternalType, 0) AS IsExternaltype ,
                        ISNULL(F.IsFlag, 0) AS [IsFlag] ,
                        ISNULL(F.NotificationId, 0) AS [NotificationId],
						Am.StatusHistoryId as StatusIcon
                FROM    dbo.CloseLoopAction AS LA
                        INNER JOIN dbo.AppUser AS U ON LA.AppUserId = U.Id
                        INNER JOIN dbo.SeenClientAnswerMaster AS Am ON Am.Id = LA.SeenClientAnswerMasterId
                        INNER JOIN dbo.Establishment AS E ON E.Id = Am.EstablishmentId
                        LEFT JOIN dbo.PendingNotificationWeb PNW ON PNW.RefId = @ReportId
                                                              AND PNW.AppUserId = @AppUserId
                                                              AND LA.[Conversation] = PNW.[Message]
						LEFT OUTER JOIN dbo.FlagMaster AS F ON F.ReportId = Am.Id AND F.AppUserId = @AppUserId AND F.NotificationId = PNW.Id AND F.Type = 3
                WHERE   LA.SeenClientAnswerMasterId = @ReportId
                UNION
                SELECT  LA.Id ,
                        [Conversation] ,
                      ISNULL(LA.AppUserId, 0) AS AppUserId,
               CASE
                   WHEN ISNULL(CustomerAppId, 0) = '0' THEN
                       U.Name
                   ELSE
                       ISNULL(LA.CustomerName, U.Name)
               END AS UserName,
                        dbo.ChangeDateFormat(DATEADD(MINUTE, E.TimeOffSet,
                                                     LA.CreatedOn),
                                             'dd/MMM/yy hh:mm') AS CaptureDate ,
                        CASE LA.IsReminderSet
                          WHEN 1 THEN 'Reminder'
                          ELSE ''
                        END AS ReminderSet ,
                        ISNULL(LA.Attachment, '') AS Attachment ,
                        @path AS FilePath ,
                        ISNULL(PNW.IsRead, 1) AS IsRead ,
                        ISNULL(LA.IsNote, 0) AS IsNote ,
                        ISNULL(LA.IsExternalType, 0) AS IsExternaltype ,
                        ISNULL(F.IsFlag, 0) AS [IsFlag] ,
                        ISNULL(F.NotificationId, 0) AS [NotificationId],
						0 as StatusIcon
                FROM    dbo.CloseLoopAction AS LA
                        INNER JOIN dbo.AppUser AS U ON LA.AppUserId = U.Id
                        INNER JOIN dbo.AnswerMaster AS Am ON Am.Id = LA.AnswerMasterId
                        INNER JOIN dbo.Establishment AS E ON E.Id = Am.EstablishmentId
						LEFT JOIN dbo.PendingNotificationWeb PNW ON PNW.RefId = @ReportId
                                                              AND PNW.AppUserId = @AppUserId
                                                              AND LA.[Conversation] = PNW.[Message]
						LEFT OUTER JOIN dbo.FlagMaster AS F ON F.ReportId = Am.Id AND F.AppUserId = @AppUserId AND F.NotificationId = PNW.Id AND F.Type = 3
                WHERE   Am.SeenClientAnswerMasterId = @ReportId
                UNION
                SELECT  LA.Id ,
                        [Conversation] ,
                    ISNULL(LA.AppUserId, 0) AS AppUserId,
               CASE
                   WHEN ISNULL(CustomerAppId, 0) = '0' THEN
                       U.Name
                   ELSE
                       ISNULL(LA.CustomerName, U.Name)
               END AS UserName,
                        dbo.ChangeDateFormat(DATEADD(MINUTE, E.TimeOffSet,
                                                     LA.CreatedOn),
                                             'dd/MMM/yy hh:mm') AS CaptureDate ,
                        CASE LA.IsReminderSet
                          WHEN 1 THEN 'Reminder'
                          ELSE ''
                        END AS ReminderSet ,
                        ISNULL(LA.Attachment, '') AS Attachment ,
                        @path AS FilePath ,
                        ISNULL(PNW.IsRead, 1) AS IsRead ,
                        ISNULL(LA.IsNote, 0) AS IsNote ,
                        ISNULL(LA.IsExternalType, 0) AS IsExternaltype ,
                        ISNULL(F.IsFlag, 0) AS [IsFlag] ,
                        ISNULL(f.NotificationId, 0) AS [NotificationId],
						Am.StatusHistoryId as StatusIcon
                FROM    dbo.CloseLoopAction AS LA
                        INNER JOIN dbo.AppUser AS U ON LA.AppUserId = U.Id
                        INNER JOIN dbo.SeenClientAnswerMaster AS Am ON Am.Id = LA.SeenClientAnswerMasterId
                        INNER JOIN dbo.Establishment AS E ON E.Id = Am.EstablishmentId
                        LEFT JOIN dbo.PendingNotificationWeb PNW ON PNW.RefId = @ReportId
                                                              AND PNW.AppUserId = @AppUserId
                                                              AND LA.[Conversation] = PNW.[Message]
						LEFT OUTER JOIN dbo.FlagMaster AS F ON F.ReportId = Am.Id AND F.AppUserId = @AppUserId AND F.NotificationId = PNW.Id AND F.Type = 3
                WHERE   LA.AppUserId = @AppUserId
                        AND LA.SeenClientAnswerMasterId = @ReportId;
            END;
        ELSE
            BEGIN
                SELECT  LA.Id ,
                        [Conversation] ,
                      ISNULL(LA.AppUserId, 0) AS AppUserId,
               CASE
                   WHEN ISNULL(CustomerAppId, 0) = '0' THEN
                       U.Name
                   ELSE
                       ISNULL(LA.CustomerName, U.Name)
               END AS UserName,
                        dbo.ChangeDateFormat(DATEADD(MINUTE, E.TimeOffSet,
                                                     LA.CreatedOn),
                                             'dd/MMM/yy hh:mm') AS CaptureDate ,
                        CASE LA.IsReminderSet
                          WHEN 1 THEN 'Reminder'
                          ELSE ''
                        END AS ReminderSet ,
                        ISNULL(LA.Attachment, '') AS Attachment ,
                        @path AS FilePath ,
                        ISNULL(PNW.IsRead, 1) AS IsRead ,
                        ISNULL(LA.IsNote, 0) AS IsNote ,
                        ISNULL(LA.IsExternalType, 0) AS IsExternaltype ,
                        ISNULL(F.IsFlag, 0) AS [IsFlag] ,
                        ISNULL(f.NotificationId, 0) AS [NotificationId],
						 0 as StatusIcon
                FROM    dbo.CloseLoopAction AS LA
                        INNER JOIN dbo.AppUser AS U ON LA.AppUserId = U.Id
                        INNER JOIN dbo.AnswerMaster AS Am ON Am.Id = LA.AnswerMasterId
                        INNER JOIN dbo.Establishment AS E ON E.Id = Am.EstablishmentId
                        LEFT JOIN dbo.PendingNotificationWeb PNW ON PNW.RefId = @ReportId
                                                              AND PNW.AppUserId = @AppUserId
                                                              AND LA.[Conversation] = PNW.[Message]
					LEFT OUTER JOIN dbo.FlagMaster AS F ON F.ReportId = Am.Id AND F.AppUserId = @AppUserId AND F.NotificationId = PNW.Id AND F.Type =3 
                WHERE   LA.AnswerMasterId = @ReportId
                UNION
                SELECT  LA.Id ,
                        [Conversation] ,
                    ISNULL(LA.AppUserId, 0) AS AppUserId,
               CASE
                   WHEN ISNULL(CustomerAppId, 0) = '0' THEN
                       U.Name
                   ELSE
                       ISNULL(LA.CustomerName, U.Name)
               END AS UserName,
                        dbo.ChangeDateFormat(DATEADD(MINUTE, E.TimeOffSet,
                                                     LA.CreatedOn),
                                             'dd/MMM/yy hh:mm') AS CaptureDate ,
                        CASE LA.IsReminderSet
                          WHEN 1 THEN 'Reminder'
                          ELSE ''
                        END AS ReminderSet ,
                        ISNULL(LA.Attachment, '') AS Attachment ,
                        @path AS FilePath ,
                        ISNULL(PNW.IsRead, 1) AS IsRead ,
                        ISNULL(LA.IsNote, 0) AS IsNote ,
                        ISNULL(LA.IsExternalType, 0) AS IsExternaltype ,
                        ISNULL(Am.IsFlag, 0) AS [IsFlag] ,
                        ISNULL(f.NotificationId, 0) AS [NotificationId],
						0 as StatusIcon
                FROM    dbo.CloseLoopAction AS LA
                        INNER JOIN dbo.AppUser AS U ON LA.AppUserId = U.Id
                        INNER JOIN dbo.AnswerMaster AS Am ON Am.Id = LA.AnswerMasterId
                        INNER JOIN dbo.Establishment AS E ON E.Id = Am.EstablishmentId
                        LEFT JOIN dbo.PendingNotificationWeb AS PNW ON PNW.RefId = @ReportId
                                                              AND PNW.AppUserId = @AppUserId
                                                              AND LA.[Conversation] = PNW.[Message]
						LEFT OUTER JOIN dbo.FlagMaster AS F ON F.ReportId = Am.Id AND F.AppUserId = @AppUserId AND F.NotificationId = PNW.Id AND F.Type = 3
                WHERE   Am.SeenClientAnswerMasterId = ( SELECT
                                                              ISNULL(SeenClientAnswerMasterId,
                                                              0)
                                                        FROM  AnswerMaster
                                                        WHERE Id = @ReportId
                                                      )
                UNION
                SELECT  LA.Id ,
                        [Conversation] ,
                     ISNULL(LA.AppUserId, 0) AS AppUserId,
               CASE
                   WHEN ISNULL(CustomerAppId, 0) = '0' THEN
                       U.Name
                   ELSE
                       ISNULL(LA.CustomerName, U.Name)
               END AS UserName,
                        dbo.ChangeDateFormat(DATEADD(MINUTE, E.TimeOffSet,
                                                     LA.CreatedOn),
                                             'dd/MMM/yy hh:mm') AS CaptureDate ,
                        CASE LA.IsReminderSet
                          WHEN 1 THEN 'Reminder'
                          ELSE ''
                        END AS ReminderSet ,
                        ISNULL(LA.Attachment, '') AS Attachment ,
                        @path AS FilePath ,
                        ISNULL(PNW.IsRead, 1) AS IsRead ,
                        ISNULL(LA.IsNote, 0) AS IsNote ,
                        ISNULL(LA.IsExternalType, 0) AS IsExternaltype ,
                        ISNULL(F.IsFlag, 0) AS [IsFlag] ,
                        ISNULL(f.NotificationId, 0) AS [NotificationId],
						Am.StatusHistoryId as StatusIcon
                FROM    dbo.CloseLoopAction AS LA
                        INNER JOIN dbo.AppUser AS U ON LA.AppUserId = U.Id
                        INNER JOIN dbo.SeenClientAnswerMaster AS Am ON Am.Id = LA.SeenClientAnswerMasterId
                        INNER JOIN dbo.Establishment AS E ON E.Id = Am.EstablishmentId
                        LEFT JOIN dbo.PendingNotificationWeb PNW ON PNW.RefId = @ReportId
                                                              AND PNW.AppUserId = @AppUserId
                                                              AND LA.[Conversation] = PNW.[Message]
						LEFT OUTER JOIN dbo.FlagMaster AS F ON F.ReportId = Am.Id AND F.AppUserId = @AppUserId AND F.NotificationId = PNW.Id AND F.Type = 3
                WHERE   LA.SeenClientAnswerMasterId = ( SELECT
                                                              ISNULL(SeenClientAnswerMasterId,
                                                              0)
                                                        FROM  dbo.AnswerMaster
                                                        WHERE Id = @ReportId
                                                      );
            END;
    END;
