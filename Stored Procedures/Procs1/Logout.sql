-- =============================================
-- Author:		Vasudev Patel
-- Create date: 23 Feb 2018
-- Description:	App Logout
-- =============================================
CREATE PROCEDURE [dbo].[Logout] 
	-- Add the parameters for the stored procedure here
    @AppUser BIGINT = 0 ,
    @ImeId VARCHAR(100)
AS
    BEGIN
    UPDATE  dbo.PendingNotification
    SET     IsDeleted = 1
    WHERE   TokenId IN ( SELECT TokenId
                         FROM   dbo.UserTokenDetails
                         WHERE  AppUserId = @AppUser
                                AND ImeId = @ImeId )
            AND AppUserId = @AppUser;

        DELETE  FROM dbo.UserTokenDetails
        WHERE   AppUserId = @AppUser
                AND ImeId = @ImeId;
    END;
