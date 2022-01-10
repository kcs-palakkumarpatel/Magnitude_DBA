-- =============================================
-- Author:			Abhishek Vyas
-- Create date:		09 Nov 2021
-- Description:		application user update IsNotified
-- =============================================
CREATE PROCEDURE dbo.UpdateIsNotifiedByAppUserId
    @AppUserId BIGINT 
AS
BEGIN
    UPDATE  dbo.AppUser
    SET     IsNotified = 1, UpdatedOn = GETUTCDATE(), UpdatedBy = @AppUserId
    WHERE   Id = @AppUserId;
END
