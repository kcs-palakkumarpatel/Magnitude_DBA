-- =============================================
-- Author:		<Vasu Patel>
-- Create date: <23 May 2016>
-- Description:	<List Of PendingNotification By Refid.>
-- =============================================
CREATE PROCEDURE [dbo].[GetPendingNotificationRefId] @RefId BIGINT
AS
    BEGIN
        SELECT  Id ,
                [Message]
        FROM    PendingNotification
        WHERE   RefId = @RefId;
    END;