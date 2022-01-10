-- =============================================
-- Author:		<Author,,GD>
-- Create date: <Create Date, ,24 Oct 2015>
-- Description:	<Description, ,>
-- Call Function: select dbo.GetFileTypeQuestionImageString('20180726145513724_CullisErinAmblerreply.jpg', 1)
-- =============================================
CREATE FUNCTION dbo.GetFileTypeQuestionImageString
(
    @Details NVARCHAR(MAX),
    @IsOut BIT,
    @QuestionId BIGINT = 0
)
RETURNS NVARCHAR(MAX)
AS
BEGIN
    -- Declare the return variable here
    DECLARE @ServerUrl NVARCHAR(MAX);
    DECLARE @ImageQuestionId BIGINT;
    SELECT @ServerUrl = KeyValue
    FROM dbo.AAAAConfigSettings
    WHERE KeyName = 'DocViewerRootFolderPath';
    SELECT @ImageQuestionId = FromQuestionId
    FROM dbo.MapingWorkFlowConfiguration
    WHERE ToQuestionId = @QuestionId;
    DECLARE @Image NVARCHAR(MAX),
            @ImagePath NVARCHAR(100);

    IF @ImageQuestionId <> 0
    BEGIN
        SELECT @ImagePath = KeyValue + 'Feedback/'
        FROM dbo.AAAAConfigSettings
        WHERE KeyName = 'DocViewerRootFolderPathWebApp';
    END;
    ELSE
    BEGIN
        SELECT @ImagePath = KeyValue + CASE @IsOut
                                           WHEN 1 THEN
                                               'SeenClient/'
                                           ELSE
                                               'Feedback/'
                                       END
        FROM dbo.AAAAConfigSettings
        WHERE KeyName = 'DocViewerRootFolderPathWebApp';
    END;
    SELECT @Image
        = COALESCE(@Image, '')
          + CASE
                WHEN Data LIKE '%.jpg%'
                     OR Data LIKE '%.jpeg%'
                     OR Data LIKE '%.png%'
                     OR Data LIKE '%.gif%'
                     OR Data LIKE '%.svg%'
                     OR Data LIKE '%.bmp%' THEN
                    '<a style="margin-right: 10px" target="_blank" href="' + @ImagePath + Data
                    + '"><img  width="170" alt="" title="" style="height: auto; width: 100%; max-width: 170px;"" src="'
                    + @ImagePath + Data + '" alt="' + @ImagePath + Data + '" /></a><br />'
                WHEN Data LIKE '%.xls%' THEN
                    '<a target="_blank" href="' + @ImagePath + Data + '"><img src="' + @ServerUrl
                    + 'Content/Image/excel.png" style="margin-right: 10px;"></img></a><br />'
                WHEN Data LIKE '%.xlxs%' THEN
                    '<a target="_blank" href="' + @ImagePath + Data + '"><img src="' + @ServerUrl
                    + 'Content/Image/excel.png" style="margin-right: 10px;"></img></a><br />'
                WHEN Data LIKE '%.Doc%' THEN
                    '<a target="_blank" href="' + @ImagePath + Data + '"><img src="' + @ServerUrl
                    + 'Content/Image/word.png" style="margin-right: 10px;"></img></a><br />'
                WHEN Data LIKE '%.ppt%' THEN
                    '<a target="_blank" href="' + @ImagePath + Data + '"><img src="' + @ServerUrl
                    + 'Content/Image/ppt.png" style="margin-right: 10px;"></img></a><br />'
                WHEN Data LIKE '%.pdf%' THEN
                    '<a target="_blank" href="' + @ImagePath + Data + '"><img src="' + @ServerUrl
                    + 'Content/Image/pdf.png" style="margin-right: 10px;"></img></a><br />'
                WHEN Data LIKE '%.txt%' THEN
                    '<a target="_blank" href="' + @ImagePath + Data + '"><img src="' + @ServerUrl
                    + 'Content/Image/text.png" style="margin-right: 10px;"></img></a><br />'
                WHEN Data LIKE '%.zip%'
                     OR Data LIKE '%.rar%' THEN
                    '<a target="_blank" href="' + @ImagePath + Data + '"><img src="' + @ServerUrl
                    + 'Content/Image/archive.png" style="margin-right: 10px;"></img></a><br />'
                WHEN Data LIKE '%.mp4%'
                     OR Data LIKE '%.mov%'
                     OR Data LIKE '%.avi%'
                     OR Data LIKE '%.3gp%' THEN
                    '<a target="_blank" href="' + @ImagePath + Data + '"><img src="' + @ServerUrl
                    + 'Content/Image/videoicon.png" width="32px" height="32px" style="margin-right: 10px;"></img></a><br />'
                ELSE
                    ''
            END
    FROM dbo.Split(@Details, ',');

    -- Return the result of the function
    RETURN '<p style="display:flex">' + @Image + '</p>';

END;


