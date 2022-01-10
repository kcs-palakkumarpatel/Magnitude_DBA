-- =============================================
-- Author:		<Author,,GD>
-- Create date: <Create Date, ,24 Oct 2015>
-- Description:	<Description, ,>
-- Call Function: select dbo.GetRefernceQuestionImagePath('28072021183808872_1621834717169.JPEG',1,88224)
-- =============================================
CREATE FUNCTION dbo.GetMappingImageQuestionPath
(
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

    DECLARE @ImagePath NVARCHAR(100);

    IF @ImageQuestionId <> 0
    BEGIN
        SELECT @ImagePath = KeyValue + 'Feedback/'
        FROM dbo.AAAAConfigSettings
        WHERE KeyName = 'DocViewerRootFolderPathWebApp';
    END;
    ELSE
    BEGIN
        SELECT @ImagePath = KeyValue + 'SeenClient/'
        FROM dbo.AAAAConfigSettings
        WHERE KeyName = 'DocViewerRootFolderPathWebApp';
    END;

    -- Return the result of the function
    RETURN @ImagePath;
--SELECT @Image
END;
