-- =============================================
-- Author:		<Author,,GD>
-- Create date: <Create Date,, Jun 2015>
-- Description:	<Description,,>
-- Call SP:		GetContactOriginalQuestionPositions 789
-- =============================================
CREATE PROCEDURE [dbo].[GetContactOriginalQuestionPositions]
    @ContactId BIGINT
AS 
    BEGIN
	DECLARE @updated INT;
	SET @updated = (Select 1 FROM (
	SELECT top 1 *  FROM ContactQuestions where ContactId = @ContactId 
	AND UpdatedOn >= DATEADD(SECOND, -120, GETUTCDATE())) A )
	SELECT ISNULL(@updated,0) as IsUpdated
 END