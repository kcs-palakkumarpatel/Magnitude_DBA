-- =============================================
-- Author:		<Author,,GD>
-- Create date: <Create Date,,27 May 2015>
-- Description:	<Description,,>
-- Call SP:		GetAllQuestionType 'en'
-- =============================================
CREATE PROCEDURE [dbo].[GetAllQuestionType]
@lang VARCHAR(5)
AS
    BEGIN
        SELECT  Id ,
                CASE @lang WHEN 'en' THEN QuestionTypeName ELSE QuestionTypeName_es END AS QuestionTypeName
        FROM    dbo.QuestionType
        WHERE   IsDeleted = 0
        ORDER BY Position, Id;
    END;
