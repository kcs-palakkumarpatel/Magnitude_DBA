CREATE PROCEDURE dbo.UpdateReadAction_Abhishek
	@AppUserId BIGINT
AS
BEGIN
	DECLARE @batchSize INT = 4000;
	DECLARE @countToUpdate INT = 0;
	DECLARE @MAX INT = 0;
	SELECT @countToUpdate = COUNT(*) FROM dbo.PendingNotificationWeb WHERE AppUserId = @AppUserId AND IsRead = 0 AND IsDeleted = 0;
	SET @MAX = @countToUpdate/@batchSize + 1;
	WHILE(@MAX > 0)
	BEGIN
		UPDATE TOP(@batchSize) dbo.PendingNotificationWeb SET IsRead = 1,UpdatedOn = GETUTCDATE() WHERE AppUserId = @AppUserId AND IsRead = 0 AND IsDeleted = 0;
		SET @MAX = @MAX - 1;
	END
END
