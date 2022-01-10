-- =============================================
-- Author:		Anant Bhatt
-- Create date: 17 Aug 2021
-- Description:	DeleteUserTokenDetails
-- =============================================
CREATE PROCEDURE [dbo].[DeleteUserTokenDetails] 
    @TokenId VARCHAR(Max),
	@AppUserId BIGINT
AS
    BEGIN
    UPDATE  dbo.PendingNotification
    SET     IsDeleted = 1
    WHERE   TokenId IN ( SELECT TokenId
                         FROM   dbo.UserTokenDetails
                         WHERE  AppUserId = @AppUserId
                                AND TokenId = @TokenId )
            AND AppUserId = @AppUserId;

        DELETE  FROM dbo.UserTokenDetails
        WHERE   AppUserId = @AppUserId
                AND TokenId = @TokenId;
    END;
