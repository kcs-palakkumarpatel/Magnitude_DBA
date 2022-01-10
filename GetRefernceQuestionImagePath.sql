-- =============================================
-- Author:		<Author,,GD>
-- Create date: <Create Date, ,24 Oct 2015>
-- Description:	<Description, ,>
-- Call Function: select dbo.GetRefernceQuestionImagePath('28072021183808872_1621834717169.JPEG',1,88224)
-- =============================================
CREATE FUNCTION dbo.GetRefernceQuestionImagePath
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
    SELECT @Image = COALESCE(@Image, '') + @ImagePath + Data + ','
    FROM dbo.Split(@Details, ',');
	END
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
    SELECT @Image = COALESCE(@Image, '') + @ImagePath + Data + ','
    FROM dbo.Split(@Details, ',');
	END
   
    -- Return the result of the function
    RETURN @Image;
--SELECT @Image
END;
