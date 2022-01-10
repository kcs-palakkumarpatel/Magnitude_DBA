
-- =============================================
-- Author:		<Author,,GD>
-- Create date: <Create Date,19, Mar 2015>
-- Description:	<Description,,>
-- Call SP:		GetEmailConfiguration
-- =============================================
CREATE PROCEDURE [dbo].[GetEmailConfiguration_111721]
AS
BEGIN
    DECLARE @SMTPServer NVARCHAR(50),
            @SMTPPort INT,
            @SMTPUserName NVARCHAR(100),
            @SMTPPassword NVARCHAR(100),
            @SMTPDisplayName NVARCHAR(100),
            @SMTPEnableSSL BIT,
            @BCCReceiver NVARCHAR(MAX),
            @EmailFrom NVARCHAR(100),
            @SendEmailConfiguration NVARCHAR(100),
            @SendGridApiKey NVARCHAR(200);

    SELECT @SendEmailConfiguration = KeyValue
    FROM dbo.AAAAConfigSettings
    WHERE KeyName = 'SendEmailConfiguration';

    SELECT @SMTPServer = Value
    FROM dbo.EmailConfiguration
    WHERE Flag = @SendEmailConfiguration
          AND Name = 'SMTPServer';

    SELECT @SMTPPort = Value
    FROM dbo.EmailConfiguration
    WHERE Flag = @SendEmailConfiguration
          AND Name = 'SMTPPort';

    SELECT @SMTPUserName = Value
    FROM dbo.EmailConfiguration
    WHERE Flag = @SendEmailConfiguration
          AND Name = 'SMTPUserName';

    SELECT @SMTPPassword = Value
    FROM dbo.EmailConfiguration
    WHERE Flag = @SendEmailConfiguration
          AND Name = 'SMTPPassword';

    SELECT @SMTPEnableSSL = Value
    FROM dbo.EmailConfiguration
    WHERE Flag = @SendEmailConfiguration
          AND Name = 'SMTPEnableSSL';

    SELECT @SendGridApiKey = Value
    FROM dbo.EmailConfiguration
    WHERE Flag = @SendEmailConfiguration
          AND Name = 'SendGridApiKey';

    SELECT @BCCReceiver = KeyValue
    FROM dbo.AAAAConfigSettings
    WHERE KeyName = 'BCCReceiver';

    SELECT @EmailFrom = KeyValue
    FROM dbo.AAAAConfigSettings
    WHERE KeyName = 'FromEmailId';

    SELECT @SMTPDisplayName = KeyValue
    FROM dbo.AAAAConfigSettings
    WHERE KeyName = 'SMTPDisplayName';

    SELECT ISNULL(@SendEmailConfiguration, '1') AS SendEmailConfiguration,
           ISNULL(@SMTPServer, '') AS SMTPServer,
           ISNULL(@SMTPPort, 25) AS SMTPPort,
           ISNULL(@SMTPUserName, '') AS SMTPUserName,
           ISNULL(@SMTPPassword, '') AS SMTPPassword,
           ISNULL(@SMTPDisplayName, '') AS SMTPDisplayName,
           ISNULL(@SMTPEnableSSL, 0) AS SMTPEnableSSL,
           ISNULL(@BCCReceiver, '') AS BCCReceiver,
           ISNULL(@EmailFrom, '') AS EmailFrom,
		   ISNULL(@SendGridApiKey, '') AS SendGridApiKey,
           '' AS CCReceiver;
END;
