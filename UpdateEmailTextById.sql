-- =============================================
-- Author:		<Vasu Patel>
-- Create date: <13 Dec 2018>
-- Description:	<Update Email Text>
-- Sp Call : UpdateEmailTextById 
-- =============================================
CREATE PROCEDURE [dbo].[UpdateEmailTextById] @EmailText XML
AS
    BEGIN
        DECLARE @TempTable TABLE
            (
              Id BIGINT IDENTITY(1, 1) ,
              anaswerMasterId BIGINT ,
              EmailText NVARCHAR(MAX)
            );

        INSERT  INTO @TempTable
                ( anaswerMasterId ,
                  EmailText 
                )
                SELECT  Id = XTbl.XCol.value('(Id)[1]', 'varchar(25)') ,
                        EncryptEmailText = XTbl.XCol.value('(strEmailText)[1]',
                                                         'NVARCHAR(MAX)')
                FROM    @EmailText.nodes('/UpdateEmailText/row') AS XTbl ( XCol );
                 
				 
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
                DECLARE @UpdateEmailText NVARCHAR(MAX);;

                SELECT  @anaswerMasterId = anaswerMasterId ,
                        @UpdateEmailText = EmailText
                FROM    @TempTable
                WHERE   Id = @Counter;

                UPDATE  dbo.PendingEmail
                SET     EmailText = @UpdateEmailText
                WHERE   Id = @anaswerMasterId;
				SET @Counter = @Counter + 1;
                CONTINUE;
            END;
    END;
