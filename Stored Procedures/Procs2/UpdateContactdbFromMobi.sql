-- =============================================
-- Author:		Vasu Patel
-- Create date: 27 Mar 2017
-- Description:	Insert Or Update Contact Database By Feedback From
-- Call:dbo.UpdateContactdbFromMobi  352346,3245
-- =============================================
CREATE PROCEDURE [dbo].[UpdateContactdbFromMobi]
    @QuestionnirQuestionOptionId BIGINT,
	@formId BIGINT
AS
    BEGIN
	DECLARE @ContactOptionId BIGINT
	    SELECT 
             @ContactOptionId = OP.Id
            FROM Questions Q
				LEFT JOIN dbo.Options AS OP ON Q.Id = OP.QuestionId
            WHERE Q.QuestionnaireId = @formId
                  AND Q.ContactQuestionIdRef > 0
                  AND Q.IsDeleted = 0


        SELECT  @ContactOptionId 
    END;
