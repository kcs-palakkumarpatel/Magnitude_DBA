
-- =============================================
-- Author:		<Mittal,,GD>
-- Create date: <Create Date,,25-12-2019>
-- Description:	<Description,Insert Capture and Feedback Notification in PendingNotificationWeb Table	>
-- Call SP:		InsertCaptureFeedbackNotification 

-- =============================================
CREATE PROCEDURE [dbo].[InsertCaptureFeedbackNotification]
AS
BEGIN
	SET DEADLOCK_PRIORITY NORMAL;
	
	BEGIN TRY
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
	END TRY

BEGIN CATCH
	INSERT INTO dbo.ErrorLog
        (
            PageId,
            MethodName,
            ErrorType,
            ErrorMessage,
            ErrorDetails,
            ErrorDate,
            UserId,
            Solution,
            CreatedOn,
            CreatedBy
        )
        VALUES
        (ERROR_LINE(),
         'dbo.InsertCaptureFeedbackNotification',
         N'DATABASE',
         ERROR_MESSAGE(),
         ('ERROR_NUMBER=' + CONVERT(VARCHAR(100), ERROR_NUMBER()) + ',ERROR_STATE='
          + CONVERT(VARCHAR(20), ERROR_STATE()) + ',ERROR_SEVERITY=' + CONVERT(VARCHAR(20), ERROR_SEVERITY())
         )  ,
         GETUTCDATE(),
         N'',
         N'',
         GETUTCDATE(),
         N''
        );
END CATCH
END;
