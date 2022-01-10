CREATE PROCEDURE dbo.UpdateReadAction_PALAK
	@AppUserId BIGINT
AS
BEGIN
	UPDATE dbo.PendingNotificationWeb SET IsRead = 1,UpdatedOn = GETUTCDATE() WHERE AppUserId = @AppUserId AND IsRead = 0 AND IsDeleted = 0
	AND ID IS NOT NULL;	
END;
