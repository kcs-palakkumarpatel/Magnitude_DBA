
-- =============================================
-- Author:		<Mittal,,GD>
-- Create date: <Create Date,,25-12-2019>
-- Description:	<Description,Insert Capture and Feedback Notification in PendingNotificationWeb Table	>
-- Call SP:		InsertCaptureFeedbackNotification 

-- =============================================
CREATE PROCEDURE [dbo].[InsertCaptureFeedbackNotification_111721]
AS
BEGIN

    WITH cte
    AS (SELECT ModuleId,
               AppUserId,
               EstablishmentId,
               Message,
               ScheduleDate,
               CreatedBy,
               ROW_NUMBER() OVER (PARTITION BY EstablishmentId, AppUserId ORDER BY Id DESC) #num
        FROM PendingEstablishmentReminder
		  WHERE IsOut = 1
              AND IsSent = 0
              AND FormCapturedbyUser = 0
              AND (ScheduleDate <= GETUTCDATE())
              AND IsDeleted = 0
              AND LEN(UserDeviceId) > 10
              AND ModuleId = 13
       )
    INSERT INTO dbo.PendingNotificationWeb
    (
        ModuleId,
        Message,
        IsRead,
        ScheduleDate,
        RefId,
        AppUserId,
        CreatedOn,
        UpdatedOn,
        DeletedOn,
        IsDeleted,
        CreatedBy,
        IsFlag,
        CustomerName
    )
    SELECT cte.ModuleId,
           cte.Message,
           0,
           cte.ScheduleDate,
           0,
           cte.AppUserId,
           GETUTCDATE(),
           NULL,
           NULL,
           0,
           cte.CreatedBy,
           0,
           NULL
    FROM cte
    WHERE cte.#num = 1;

END;

