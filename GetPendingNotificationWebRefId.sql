-- =============================================
-- Author:		<Vasu Patel>
-- Create date: <22 Dec 2018>
-- Description:	<List Of PendingNotificationWeb By Refid.>
-- =============================================
CREATE PROCEDURE [dbo].[GetPendingNotificationWebRefId] @RefId BIGINT
AS
    BEGIN
        SELECT  Id ,
                [Message]
        FROM    PendingNotificationWeb
        WHERE   RefId = @RefId;
    END;