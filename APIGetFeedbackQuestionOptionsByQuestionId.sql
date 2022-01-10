-- =============================================
-- Author:			Developer D3
-- Create date:	05-June-2017
-- Description:	Get Feedback Question Options List for Web API Using QuestionId
-- Call:					dbo.APIGetFeedbackQuestionOptionsByQuestionId 759
-- =============================================
CREATE PROCEDURE [dbo].[APIGetFeedbackQuestionOptionsByQuestionId] ( @QuestionId VARCHAR(MAX) = '' )
AS
    BEGIN
        SET NOCOUNT OFF;

        SELECT  QuestionId AS QuestionId ,
                Id AS OptionId ,
                ISNULL(Name, '') AS OptionName ,
                ISNULL(Value, '') AS OptionValue 
        FROM    dbo.Options
        WHERE   QuestionId IN ( SELECT Data FROM dbo.Split(@QuestionId, ','))
        ORDER BY Position ASC;

    END;
