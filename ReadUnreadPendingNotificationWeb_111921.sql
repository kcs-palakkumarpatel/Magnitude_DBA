
-- =============================================
-- Author:		<Disha Patel>
-- Create date: <27-JUL-2015>
-- Description:	<Delete Notifications>
-- Call SP    :	DeletePendingNotificationWeb
-- =============================================
CREATE PROCEDURE [dbo].[ReadUnreadPendingNotificationWeb_111921] @IdList NVARCHAR(MAX), @ActionType varchar(6) 
AS
    BEGIN
        DECLARE @Start INT = 1 ,
            @Total INT ,
            @IsUsed BIT ,
            @Id BIGINT ,
            @Result NVARCHAR(MAX) = '' ,
            @Count INT = 0
        DECLARE @Tbl TABLE ( Id INT, Data INT )
        INSERT  INTO @Tbl
                ( Id ,
                  Data 
                )
                SELECT  Id ,
                        Data
                FROM    dbo.Split(@IdList, ',')
        SELECT  @Total = COUNT(1)
        FROM    @Tbl
		IF(@ActionType = 'Read')
		BEGIN
		 UPDATE  dbo.[PendingNotificationWeb]
                    SET     IsRead = 1 
                    WHERE   [Id] IN (SELECT data FROM @Tbl)


					INSERT  INTO dbo.ActivityLog
                            ( UserId ,
                              PageId ,
                              AuditComments ,
                              TableName ,
                              RecordId ,
                              CreatedOn ,
                              CreatedBy ,
                              IsDeleted 
                            )
                    SELECT P.AppUserId,
							0,
							'Update as Read recourd in table Pendingnotificationweb', 
							'PendingNotificationWeb', 
							T.Id,
							GETUTCDATE(),
							P.AppUserId,
							0 
					FROM dbo.PendingNotificationWeb AS P INNER JOIN @Tbl AS T ON T.Id = P.Id
		END
        ELSE IF (@ActionType = 'Unread')
			BEGIN
			 UPDATE  dbo.[PendingNotificationWeb]
                    SET     IsRead = 0 
                    WHERE   [Id] IN (SELECT data FROM @Tbl)


					INSERT  INTO dbo.ActivityLog
                            ( UserId ,
                              PageId ,
                              AuditComments ,
                              TableName ,
                              RecordId ,
                              CreatedOn ,
                              CreatedBy ,
                              IsDeleted 
                            )
                    SELECT P.AppUserId,
							0,
							'Update as Unread recourd in table Pendingnotificationweb', 
							'PendingNotificationWeb', 
							T.Id,
							GETUTCDATE(),
							P.AppUserId,
							0 
					FROM dbo.PendingNotificationWeb AS P INNER JOIN @Tbl AS T ON T.Id = P.Id
			END
            
    END
