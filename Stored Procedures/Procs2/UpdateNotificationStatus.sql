
-- =============================================
-- Author:		<Author,,GD>
-- Create date: <Create Date,,07 Jul 2015>
-- Description:	<Description,,>
-- Call SP:		UpdateNotificatoinStatus
-- =============================================
CREATE PROCEDURE [dbo].[UpdateNotificationStatus]
    @Id BIGINT,
    @ModuleId BIGINT,
    @RefId BIGINT
AS
BEGIN
	SET DEADLOCK_PRIORITY NORMAL;
	
	BEGIN TRY
    IF (@ModuleId != 13)
    BEGIN
        IF @Id > 0
        BEGIN
            UPDATE dbo.PendingNotification
            SET [Status] = 1,
                SentDate = GETUTCDATE()
            WHERE Id = @Id
                  AND ScheduleDate <= GETUTCDATE();
        END;
        ELSE
        BEGIN
            UPDATE dbo.PendingNotification
            SET [Status] = 1,
                SentDate = GETUTCDATE()
            WHERE RefId = @RefId
                  AND ModuleId = @ModuleId
                  AND ScheduleDate <= GETUTCDATE();
        END;
    END;
    ELSE
    BEGIN
        UPDATE PendingEstablishmentReminder
        SET IsSent = 1,
            SentDate = GETUTCDATE()
        WHERE Id = @Id;
    END;
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
         'dbo.UpdateNotificationStatus',
         N'DATABASE',
         ERROR_MESSAGE(),
         ('ERROR_NUMBER=' + CONVERT(VARCHAR(100), ERROR_NUMBER()) + ',ERROR_STATE='
          + CONVERT(VARCHAR(20), ERROR_STATE()) + ',ERROR_SEVERITY=' + CONVERT(VARCHAR(20), ERROR_SEVERITY())
         )  ,
         GETUTCDATE(),
         N'',
        @Id+','+@ModuleId+','+@RefId,
	    GETUTCDATE(),
         N''
        );
END CATCH
END;
