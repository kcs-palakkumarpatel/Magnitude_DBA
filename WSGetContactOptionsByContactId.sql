-- =============================================
-- Author:		<Author,,GD>
-- Create date: <Create Date,,19 Jun 2015>
-- Description:	<Description,,>
-- Call SP:		WSGetContactOptionsByActivityId 1
-- =============================================
CREATE PROCEDURE [dbo].[WSGetContactOptionsByContactId] @ContactId BIGINT
AS
    BEGIN
        SELECT  O.Id AS OptionId ,
                Name AS OptionName ,
                DefaultValue AS IsDefaultValue ,
                Q.Id AS QuestionId ,
                O.Value AS OptionValue
        FROM    dbo.ContactOptions AS O
                INNER JOIN dbo.ContactQuestions AS Q ON O.ContactQuestionId = Q.Id
        WHERE   Q.ContactId = @ContactId
                AND O.IsDeleted = 0
                AND Q.IsDeleted = 0
        ORDER BY Q.Id ,
                O.Position;      
    END;