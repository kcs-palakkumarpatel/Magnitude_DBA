-- =============================================
-- Author:		<Ankit >
-- Create date: <01 May 2019>
-- Description:	<Get Control Style>
-- Call:	GetControlStyle
-- =============================================
CREATE PROCEDURE [dbo].[GetControlStyle]
AS
BEGIN
    SELECT Id,
           ControlStyleName,
           QuestionTypeId
    FROM dbo.ControlStyle;
END;
