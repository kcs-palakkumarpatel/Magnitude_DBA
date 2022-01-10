
CREATE PROCEDURE [dbo].[GetUserNotifyMessage_111721]
(
	@AppUserId BIGINT
)
AS
BEGIN
	DECLARE @ReleaseDate DATETIME ;
	DECLARE @Message NVARCHAR(MAX) = '';
	DECLARE @GroupId INT;
	DECLARE @IsNotified BIT;
	SELECT @IsNotified = IsNotified, @GroupId= GroupId FROM dbo.AppUser WHERE Id = @AppUserId;
	IF(@IsNotified = 0)
	BEGIN
		SELECT @ReleaseDate = ReleaseDate, @Message = MESSAGE  FROM dbo.NotificationForNewSeparateInstance WHERE GROUPID = @GroupId;
		IF(DATEADD(MINUTE, 120, GETUTCDATE()) <= @ReleaseDate AND DATEDIFF(DAY, DATEADD(MINUTE, 120, GETUTCDATE()), @ReleaseDate) < 4)
		BEGIN
			SET @Message = @Message;
		END
		ELSE
		BEGIN
			SET @Message = ''; 
		END
	END
    SELECT @Message AS NotifyMessage;
END
