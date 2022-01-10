-- =============================================
-- Author:		<Vasu Patel>
-- Create date: <21 Dec 2018>
-- Description:	<Update PendingNotification Text>
-- Sp Call : UpdatePendingNotificationById 
-- =============================================
CREATE PROCEDURE [dbo].[UpdatePendingNotificationById] @PendingNotification XML
AS
    BEGIN
        DECLARE @TempTable TABLE
            (
              Id BIGINT IDENTITY(1, 1) ,
              anaswerMasterId BIGINT ,
              PendingNotification NVARCHAR(MAX)
            );

        INSERT  INTO @TempTable
                ( anaswerMasterId ,
                  PendingNotification 
                )
                SELECT  Id = XTbl.XCol.value('(Id)[1]', 'varchar(25)') ,
                        EncryptPendingNotification = XTbl.XCol.value('(strPendingNotification)[1]',
                                                         'NVARCHAR(MAX)')
                FROM    @PendingNotification.nodes('/UpdatePendingNotification/row') AS XTbl ( XCol );
                 
				 
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
                DECLARE @UpdatePendingNotification NVARCHAR(MAX);;

                SELECT  @anaswerMasterId = anaswerMasterId ,
                        @UpdatePendingNotification = PendingNotification
                FROM    @TempTable
                WHERE   Id = @Counter;

                UPDATE  dbo.PendingNotification
                SET     Message = @UpdatePendingNotification
                WHERE   Id = @anaswerMasterId;
				SET @Counter = @Counter + 1;
                CONTINUE;
            END;
    END;
