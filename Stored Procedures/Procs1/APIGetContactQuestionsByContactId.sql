-- =============================================
-- Author:			Developer D3
-- Create date:	30-09-2016
-- Description:	Get Contact Questions List for Web API Using ContactId
-- Call:					dbo.APIGetContactQuestionsByContactId 80
-- =============================================
CREATE PROCEDURE dbo.APIGetContactQuestionsByContactId ( @ContactId BIGINT = 0 )
AS
    BEGIN
        SET NOCOUNT OFF;

        SELECT  CQ.Id AS QuestionId ,
                CQ.QuestionTypeId ,
                CQ.QuestionTitle ,
                CQ.[Required] AS [Required],
                '' AS Answer
        FROM    dbo.ContactQuestions AS CQ
        WHERE   CQ.IsDeleted = 0
                AND ContactId = @ContactId
        ORDER BY CQ.Position ASC;

    END;
