-- =============================================
-- Author:		<Vasu Patel>
-- Create date: <19 Dec 2018>
-- Description:	<Update Email Subject>
-- Sp Call : UpdateEmailSubjectById 
-- =============================================
CREATE PROCEDURE [dbo].[UpdateEmailSubjectById] @EmailSubject XML
AS
    BEGIN
        DECLARE @TempTable TABLE
            (
              Id BIGINT IDENTITY(1, 1) ,
              anaswerMasterId BIGINT ,
              EmailSubject NVARCHAR(MAX)
            );

        INSERT  INTO @TempTable
                ( anaswerMasterId ,
                  EmailSubject 
                )
                SELECT  Id = XTbl.XCol.value('(Id)[1]', 'varchar(25)') ,
                        EncryptEmailSubject = XTbl.XCol.value('(strEmailSubject)[1]',
                                                         'NVARCHAR(MAX)')
                FROM    @EmailSubject.nodes('/UpdateEmailSubject/row') AS XTbl ( XCol );
                 
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
                DECLARE @UpdateEmailSubject NVARCHAR(MAX);;

                SELECT  @anaswerMasterId = anaswerMasterId ,
                        @UpdateEmailSubject = EmailSubject
                FROM    @TempTable
                WHERE   Id = @Counter;

                UPDATE  dbo.PendingEmail
                SET     EmailSubject = @UpdateEmailSubject
                WHERE   Id = @anaswerMasterId;
				SET @Counter = @Counter + 1;
                CONTINUE;
            END;
    END;
