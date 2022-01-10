-- =============================================
-- Author:			Developer D3
-- Create date:	30-May-2017
-- Description:	Get Capture Question Options List for Web API Using QuestionId
-- Call:					dbo.APIGetCaptureQuestionOptionsByQuestionId '11788, 11790'
-- =============================================
CREATE PROCEDURE [dbo].[APIGetCaptureQuestionOptionsByQuestionId] ( @QuestionId NVARCHAR(MAX) = '' )
AS
    BEGIN
        SET NOCOUNT OFF;

        SELECT  QuestionId AS QuestionId ,
                Id AS OptionId ,
                Name AS OptionName ,
                Value AS OptionValue 
        FROM    dbo.SeenClientOptions
        WHERE   QuestionId IN ( SELECT Data FROM dbo.Split(@QuestionId, ','))
        ORDER BY QuestionId, Position ASC;

    END;
