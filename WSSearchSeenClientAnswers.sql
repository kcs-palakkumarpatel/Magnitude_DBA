
/*
 =============================================
 Author		:	Hitesh Darji	
 Create date:	22-Feb-2017
 Description:	Search keywords
 Call SP    :	WSSearchSeenClientAnswers 49553, "12345"
 =============================================
*/
CREATE PROCEDURE [dbo].[WSSearchSeenClientAnswers]
    @QuestionID BIGINT ,
    @SearchText VARCHAR(MAX)
AS
    BEGIN
        SET NOCOUNT ON;
			select top 1 ISNULL(SeenClientAnswerMasterId,0) from SeenClientAnswers where QuestionId = @QuestionID and Detail = @SearchText and IsDeleted = 0
        SET NOCOUNT OFF;
    END;
