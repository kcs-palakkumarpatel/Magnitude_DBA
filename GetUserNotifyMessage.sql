
CREATE PROCEDURE [dbo].[GetUserNotifyMessage]
(
	@AppUserId BIGINT
)
AS
BEGIN
	SET DEADLOCK_PRIORITY NORMAL;
	
	BEGIN TRY
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
         'dbo.GetUserNotifyMessage',
         N'DATABASE',
         ERROR_MESSAGE(),
         ('ERROR_NUMBER=' + CONVERT(VARCHAR(100), ERROR_NUMBER()) + ',ERROR_STATE='
          + CONVERT(VARCHAR(20), ERROR_STATE()) + ',ERROR_SEVERITY=' + CONVERT(VARCHAR(20), ERROR_SEVERITY())
         )  ,
         GETUTCDATE(),
         ISNULL(@AppUserId,0),
         @AppUserId,
         GETUTCDATE(),
         ISNULL(@AppUserId,0)
        );
END CATCH
END
