-- =============================================
-- Author:		<Mittal,,GD>
-- Create date: <Create Date,12, May 2021>
-- Description:	<Description,,>
-- Call SP:		GetAAAAConfiguration
-- =============================================
CREATE PROCEDURE dbo.GetAAAAConfiguration
AS
BEGIN
    DECLARE @MaxFileSize NVARCHAR(500),
            @FTPUrl NVARCHAR(500),
            @FTPUserName NVARCHAR(500),
            @FTPPassword NVARCHAR(500),
            @AndroidVersion NVARCHAR(500),
			@DocViewerRootFolderPathCMS NVARCHAR(500);

    SELECT @MaxFileSize = KeyValue
    FROM dbo.AAAAConfigSettings
    WHERE KeyName = 'MaxFileSize';

    SELECT @FTPUrl = KeyValue
    FROM dbo.AAAAConfigSettings
    WHERE KeyName = 'FTPUrl';

    SELECT @FTPUserName = KeyValue
    FROM dbo.AAAAConfigSettings
    WHERE KeyName = 'FTPUserName';

    SELECT @FTPPassword = KeyValue
    FROM dbo.AAAAConfigSettings
    WHERE KeyName = 'FTPPassword';

    SELECT @AndroidVersion = KeyValue
    FROM dbo.AAAAConfigSettings
    WHERE KeyName = 'AndroidVersion';

	SELECT @DocViewerRootFolderPathCMS =  KeyValue
    FROM dbo.AAAAConfigSettings
    WHERE KeyName = 'DocViewerRootFolderPathCMS';

    SELECT ISNULL(@MaxFileSize, '') AS MaxFileSize,
           ISNULL(@FTPUrl, '') AS FTPUrl,
           ISNULL(@FTPUserName, '') AS FTPUserName,
           ISNULL(@FTPPassword, '') AS FTPPassword,
           ISNULL(@AndroidVersion, '') AS AndroidVersion,
		   ISNULL(@DocViewerRootFolderPathCMS, '') AS DocViewerRootFolderPathCMS;
END;
