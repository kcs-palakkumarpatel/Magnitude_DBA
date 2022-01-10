-- =============================================
-- Author:		<Ankit >
-- Create date: <17 May 2017>
-- Description:	<Get Base Count>
-- Call:	GetControlStyleByQuestionType 0
-- =============================================
CREATE PROCEDURE [dbo].[GetControlStyleByQuestionType] @QuestionTypeId BIGINT
AS
BEGIN
    SELECT Id,
           ControlStyleName,
           QuestionTypeId
    FROM dbo.ControlStyle;
--IF (@QuestionTypeId = 0)
--BEGIN
--    SELECT Id,
--           ControlStyleName,
--  QuestionTypeId
--    FROM dbo.ControlStyle
--END;
--ELSE
--BEGIN
--    SELECT Id,
--           ControlStyleName
--    FROM dbo.ControlStyle
--    WHERE QuestionTypeId = @QuestionTypeId;
--END;
END;
