
-- =============================================
-- Author:		<Vasu Patel>
-- Create date: <23 May 2016>
-- Description:	<Update SMS Text with Encript>
--Sp Call : UpdateEncryptSMSTextById '<UpdateEncryptSMSText><row><Id>298474</Id><strEncriptSmsText>%23%23%5b11844%5d%23%23+a+009+ITSD+Technical+Issue+has+been+reported+by+Vasudev+Patel+CMS+follow+the+link+to+review+and+respond+http%3a%2f%2f192.168.1.73%3a4001%2fFb%3fSid%3dHY40dfrkwp01%26Cid%3dqCD2hMoXvxM1</strEncriptSmsText></row><row><Id>298475</Id><strEncriptSmsText>%23%23%5b11844%5d%23%23+a+009+ITSD+Technical+Issue+has+been+reported+by+Vasudev+Patel+CMS+follow+the+link+to+review+and+respond+http%3a%2f%2f192.168.1.73%3a4001%2fFb%3fSid%3dHY40dfrkwp01%26Cid%3ds44d-Mhz41o1</strEncriptSmsText></row><row><Id>298476</Id><strEncriptSmsText>%23%23%5b11844%5d%23%23+a+009+ITSD+Technical+Issue+has+been+reported+by+Vasudev+Patel+CMS+follow+the+link+to+review+and+respond+http%3a%2f%2f192.168.1.73%3a4001%2fFb%3fSid%3dHY40dfrkwp01%26Cid%3dRiTH-z6fY8Y1</strEncriptSmsText></row></UpdateEncryptSMSText>'
-- =============================================
CREATE PROCEDURE [dbo].[UpdateEncryptSMSTextById_111921] @EncryptSmsText XML
AS
    BEGIN
        DECLARE @TempTable TABLE
            (
              Id BIGINT IDENTITY(1, 1) ,
              anaswerMasterId BIGINT ,
              EncryptSmsText NVARCHAR(MAX)
            );

        INSERT  INTO @TempTable
                ( anaswerMasterId ,
                  EncryptSmsText 
                )
                SELECT  Id = XTbl.XCol.value('(Id)[1]', 'varchar(25)') ,
                        EncryptSmsText = XTbl.XCol.value('(strEncriptSmsText)[1]',
                                                         'NVARCHAR(MAX)')
                FROM    @EncryptSmsText.nodes('/UpdateEncryptSMSText/row') AS XTbl ( XCol );
                 
				 
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
                DECLARE @SMSText NVARCHAR(MAX);;

                SELECT  @anaswerMasterId = anaswerMasterId ,
                        @SMSText = EncryptSmsText
                FROM    @TempTable
                WHERE   Id = @Counter;

                UPDATE  dbo.PendingSMS
                SET     SMSText = @SMSText
                WHERE   Id = @anaswerMasterId;
				SET @Counter = @Counter + 1;
                CONTINUE;
            END;
    END;
      
