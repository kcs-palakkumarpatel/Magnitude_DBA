CREATE FUNCTION [dbo].[EmailAttachment]
    (
      @Attachment NVARCHAR(MAX)
    )
RETURNS NVARCHAR(MAX)
AS
    BEGIN  
        DECLARE @ServerUrl NVARCHAR(MAX) ,
            @ImageServerUrl NVARCHAR(MAX) ,
            @AttachmentText NVARCHAR(MAX);

        SELECT  @ServerUrl = KeyValue
        FROM    dbo.AAAAConfigSettings
        WHERE   KeyName = 'DocViewerRootFolderPath';

        SELECT  @ImageServerUrl = KeyValue
        FROM    dbo.AAAAConfigSettings
        WHERE   KeyName = 'DocViewerRootFolderPathWebApp';

        DECLARE @AttachmentDetails AS TABLE
            (
              ID INT IDENTITY(1, 1) ,
              AttachmentName VARCHAR(MAX)
            );

        INSERT  INTO @AttachmentDetails
                ( AttachmentName
                )
                SELECT  Data
                FROM    dbo.Split(@Attachment, ',');

        DECLARE @Counter INT ,
            @TotalCount INT;
        SET @Counter = 1;
        SET @TotalCount = ( SELECT  COUNT(*)
                            FROM    @AttachmentDetails
                          );
        SET @AttachmentText = '<p> <h3> Attachments: </h3> </p>';
        SET @AttachmentText = CONCAT(@AttachmentText, '<p>');
        WHILE ( @Counter <= @TotalCount )
            BEGIN
                DECLARE @AttachmentURL NVARCHAR(MAX) ,
                    @FileExtension NVARCHAR(MAX) ,
                    @AttachmentName NVARCHAR(MAX);

                SELECT  @AttachmentURL = CONCAT(@ImageServerUrl + 'Actions/',
                                                AttachmentName) ,
                        @AttachmentName = AttachmentName
                FROM    @AttachmentDetails
                WHERE   ID = @Counter;

                SET @AttachmentText = CONCAT(@AttachmentText,
                                             '<a class="view-file" target="_blank" href="'
                                             + @AttachmentURL + '" >');

                SELECT TOP 1
                        @FileExtension = LOWER(Data)
                FROM    dbo.Split(@AttachmentName, '.')
                ORDER BY Id DESC;

                SELECT  @AttachmentText = CASE WHEN @FileExtension = 'xls'
                                                    OR @FileExtension = 'xlsx'
                                               THEN CONCAT(@AttachmentText,
                                                           '<img src="'
                                                           + @ServerUrl
                                                           + 'Content/Image/excel.png"></img>')
                                               WHEN @FileExtension = 'doc'
                                                    OR @FileExtension = 'docx'
                                               THEN CONCAT(@AttachmentText,
                                                           '<img src="'
                                                           + @ServerUrl
                                                           + 'Content/Image/word.png"></img>')
                                               WHEN @FileExtension = 'ppt'
                                                    OR @FileExtension = 'pptx'
                                               THEN CONCAT(@AttachmentText,
                                                           '<img src="'
                                                           + @ServerUrl
                                                           + 'Content/Image/ppt.png"></img>')
                                               WHEN @FileExtension = 'txt'
                                               THEN CONCAT(@AttachmentText,
                                                           '<img src="'
                                                           + @ServerUrl
                                                           + 'Content/Image/text.png"></img>')
                                               WHEN @FileExtension = 'pdf'
                                               THEN CONCAT(@AttachmentText,
                                                           '<img src="'
                                                           + @ServerUrl
                                                           + 'Content/Image/pdf.png"></img>')
                                               WHEN @FileExtension = 'zip'
                                                    OR @FileExtension = 'rar'
                                               THEN CONCAT(@AttachmentText,
                                                           '<img src="'
                                                           + @ServerUrl
                                                           + 'Content/Image/archive.png"></img>')
                                               WHEN @FileExtension = 'jpg'
                                                    OR @FileExtension = 'jpeg'
                                                    OR @FileExtension = 'png'
                                                    OR @FileExtension = 'gif'
                                                    OR @FileExtension = 'bmp'
                                                    OR @FileExtension = 'svg'
                                               THEN CONCAT(@AttachmentText,
                                                           '<img src="'
                                                           + @AttachmentURL
                                                           + '" width="32px" height="32px"></img>')
                                               WHEN @FileExtension = 'mp4'
                                                    OR @FileExtension = 'mov'
                                                    OR @FileExtension = 'avi'
                                                    OR @FileExtension = '3gp'
                                               THEN CONCAT(@AttachmentText,
                                                           '<img src="'
                                                           + @ServerUrl
                                                           + 'Content/Image/videoicon.png" width="32px" height="32px"></img>')
                                               ELSE CONCAT(@AttachmentText,
                                                           '<img src="'
                                                           + @ServerUrl
                                                           + 'Content/Image/other.png"></img>')
                                          END; 

                SET @AttachmentText = CONCAT(@AttachmentText, '</a>');
                SET @Counter = @Counter + 1;
                CONTINUE;
            END; 

        SET @AttachmentText = CONCAT(@AttachmentText, '</p>');
        RETURN @AttachmentText;
    END;
