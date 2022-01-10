-- =============================================
-- Author:			Developer D3
-- Create date:	29-09-2016
-- Description:	Get Contact Question Options from for Web API Using by ContactQuestionId
-- Call:					dbo.APIGetContactOptionsByContactQuestionId '1437,1440,1438,1439,1441'
-- =============================================
CREATE PROCEDURE [dbo].[APIGetContactOptionsByContactQuestionId]
    (
      @ContactQuestionId NVARCHAR(MAX) = ''
    )
AS
    BEGIN
        SET NOCOUNT OFF;

        SELECT  ContactQuestionId AS QuestionId ,
                Id AS OptionId ,
                RTRIM(Name) AS OptionName ,
                RTRIM(Value) AS OptionValue
        FROM    dbo.ContactOptions
        WHERE   ContactQuestionId IN ( SELECT Data FROM dbo.Split(@ContactQuestionId, ','))
        ORDER BY ContactQuestionId, Position ASC;

    END;
