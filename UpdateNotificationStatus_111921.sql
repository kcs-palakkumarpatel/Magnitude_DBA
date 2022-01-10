
-- =============================================
-- Author:		<Author,,GD>
-- Create date: <Create Date,,07 Jul 2015>
-- Description:	<Description,,>
-- Call SP:		UpdateNotificatoinStatus
-- =============================================
CREATE PROCEDURE [dbo].[UpdateNotificationStatus_111921]
    @Id BIGINT,
    @ModuleId BIGINT,
    @RefId BIGINT
AS
BEGIN
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
END;
