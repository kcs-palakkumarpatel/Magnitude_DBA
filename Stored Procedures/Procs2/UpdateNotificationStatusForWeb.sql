
-- =============================================
-- Author:		<Disha Patel>
-- Create date: <27-JUL-2015>
-- Description:	<Update notification read flag for webapp by id>
-- Call SP:		UpdateNotificationStatusForWeb
-- =============================================
CREATE PROCEDURE [dbo].[UpdateNotificationStatusForWeb]
    @Id BIGINT ,
    @ModuleId BIGINT ,
    @RefId BIGINT
AS
    BEGIN
        IF @Id > 0
            BEGIN
                UPDATE  dbo.PendingNotificationWeb
                SET     IsRead = 1 ,
                        UpdatedOn = GETUTCDATE()
                WHERE   Id = @Id
            END
        ELSE
            BEGIN
                UPDATE  dbo.PendingNotificationWeb
                SET     IsRead = 1 ,
                        UpdatedOn = GETUTCDATE()
                WHERE   RefId = @RefId
                        AND ModuleId = @ModuleId
            END
    END