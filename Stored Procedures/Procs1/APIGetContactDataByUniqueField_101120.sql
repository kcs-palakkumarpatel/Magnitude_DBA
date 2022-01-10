-- =============================================
-- Author:			Developer D3
-- Create date:	31-MAY-2017
-- Description:	Get Contact Answers Data from for Web API Using MerchantKey(GroupId)
-- =============================================
/*
Drop procedure APIGetContactDataByUniqueField_101120

APIGetContactDataByUniqueField_101120 534,69009266,3245,0
*/
CREATE PROCEDURE dbo.APIGetContactDataByUniqueField_101120
    @GroupId BIGINT = 0,
    @SearchText NVARCHAR(100) = '',
    @formId BIGINT = 0,
    @isCapture BIT
AS
BEGIN
    SET NOCOUNT OFF;
    DECLARE @ContactMasterId BIGINT = 0;
	
	SELECT TOP 1 @ContactMasterId = ContactMasterId
    FROM ContactDetails
    WHERE LOWER(Detail) = LOWER(@SearchText)
    AND IsDeleted = 0

    IF (@ContactMasterId > 0) And (@isCapture = 0)
    BEGIN
		SELECT DISTINCT
			0 AS AnswerMasterId,
			Q.Id AS QuestionId,
			Q.QuestionTypeId AS QuestionType,
			Q.QuestionTitle AS Question,
			CD.Detail AS Answer
		FROM Answers A
        LEFT JOIN Questions Q ON A.QuestionId = Q.ContactQuestionIdRef
        LEFT JOIN ContactDetails CD ON CD.ContactQuestionId = Q.ContactQuestionIdRef
        LEFT JOIN ContactMaster CM ON CM.Id = CD.ContactMasterId
        WHERE Q.QuestionnaireId = @formId
        AND Q.ContactQuestionIdRef > 0
        AND CM.Id = @ContactMasterId
        AND CD.IsDeleted = 0
        AND Q.IsDeleted = 0
        AND CM.IsDeleted = 0
        AND CM.GroupId = @GroupId;
        --ORDER BY Q.Position ASC;
 
    END;
END;

