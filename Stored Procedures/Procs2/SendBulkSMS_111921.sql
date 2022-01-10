
-- call dbo.SendBulkSMS 'TestSMS','27836591690'
CREATE PROCEDURE [dbo].[SendBulkSMS_111921]
    @SMSText NVARCHAR(MAX),
    @MobileNo NVARCHAR(1000)
AS
BEGIN
    DECLARE @ApiId NVARCHAR(50);
    DECLARE @UserName NVARCHAR(50);
    DECLARE @Password NVARCHAR(50);
    DECLARE @Url NVARCHAR(MAX);
    DECLARE @START INT;
    DECLARE @COUNT INT;
    DECLARE @Concat INT;

    SELECT @MobileNo = dbo.fn_StripCharacters(@MobileNo, '^0-9/g');
    IF @MobileNo LIKE '0%'
       AND LEN(@MobileNo) >= 9
    BEGIN
        SET @MobileNo = '27' + RIGHT(@MobileNo, 9);
    END;

    IF @MobileNo NOT LIKE '27%'
       AND LEN(@MobileNo) = 9
    BEGIN
        SET @MobileNo = '27' + @MobileNo;
    END;

    SELECT @UserName = UserName,
           @Password = [Password],
           @ApiId = ApiId,
           @Concat = [Concat]
    FROM SMSConfig;
    PRINT @Concat;

    --SET @UserName = 'gom.magnitude';
    --SET @Password = 'mag84h56';

    BEGIN TRY
	IF (LEN(@MobileNo) > 8)
	BEGIN
        SET @Url
            = 'https://sms.connect-mobile.co.za/submit/single/?username=' + @UserName + '&password=' + @Password
              + '&account=' + @UserName + '&da=' + @MobileNo + '&ud=' + @SMSText;


        --PRINT @Url;        
        --DECLARE @Object AS INT;              
        --DECLARE @ResponseText AS NVARCHAR(MAX);              
        --EXEC sp_OACreate 'MSXML2.XMLHTTP', @Object OUT;              
        --EXEC sp_OAMethod @Object, 'open', NULL, 'post', @Url, 'false';              
        --EXEC sp_OAMethod @Object, 'send';              
        --EXEC sp_OAMethod @Object, 'responseText', @ResponseText OUTPUT;              
        --EXEC sp_OADestroy @Object;        
        --PRINT @Object;            
        --PRINT @ResponseText;           

        INSERT INTO SMSLog
        (
            ApiId,
            [SMSTo],
            [SMSText],
            [udh],
            IsReceived,
            moMsgId,
            CreatedOn
        )
        VALUES
        (   @ApiId,
            @MobileNo,
            @SMSText,
            0, --@ResponseText ,
            0,
            0, --@ResponseText ,
            GETUTCDATE()
        );
		END
        ELSE
        BEGIN
		SET @Url = NULL;
		END
    END TRY
    BEGIN CATCH
        SET @Url = NULL;
    END CATCH;
    SELECT @Url AS url;
END;

