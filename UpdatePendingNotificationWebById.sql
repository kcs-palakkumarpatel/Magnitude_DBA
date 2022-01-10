-- =============================================
-- Author:		<Vasu Patel>
-- Create date: <22 Dec 2018>
-- Description:	<Update PendingNotificationWeb Text>
-- Sp Call : UpdatePendingNotificationWebById 
-- =============================================
CREATE PROCEDURE [dbo].[UpdatePendingNotificationWebById] @PendingNotificationWeb XML
AS
    BEGIN
        DECLARE @TempTable TABLE
            (
              Id BIGINT IDENTITY(1, 1) ,
              anaswerMasterId BIGINT ,
              PendingNotificationWeb NVARCHAR(MAX)
            );

        INSERT  INTO @TempTable
                ( anaswerMasterId ,
                  PendingNotificationWeb 
                )
                SELECT  Id = XTbl.XCol.value('(Id)[1]', 'varchar(25)') ,
                        EncryptPendingNotificationWeb = XTbl.XCol.value('(strPendingNotificationWeb)[1]',
                                                         'NVARCHAR(MAX)')
                FROM    @PendingNotificationWeb.nodes('/UpdatePendingNotificationWeb/row') AS XTbl ( XCol );
                 
				 
        SELECT  *
        FROM    @TempTable;   
        DECLARE @Counter INT ,
            @TotalCount INT;
        SET @Counter = 1;
        SET @TotalCount = ( SELECT  COUNT(*)
                            FROM    @TempTable
                          );	 
				        
        WHILE ( @Counter <= @TotalCount )
            BEGIN

                DECLARE @Id BIGINT;
                DECLARE @anaswerMasterId BIGINT;
                DECLARE @UpdatePendingNotificationWeb NVARCHAR(MAX);;

                SELECT  @anaswerMasterId = anaswerMasterId ,
                        @UpdatePendingNotificationWeb = PendingNotificationWeb
                FROM    @TempTable
                WHERE   Id = @Counter;

                UPDATE  dbo.PendingNotificationWeb
                SET     Message = @UpdatePendingNotificationWeb
                WHERE   Id = @anaswerMasterId;
				SET @Counter = @Counter + 1;
                CONTINUE;
            END;
    END;
