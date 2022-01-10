-- =============================================
-- Author:			Developer D3
-- Create date:	31-MAY-2017
-- Description:	Get Contact Answers Data from for Web API Using MerchantKey(GroupId)
-- Call: dbo.APIGetContactDataByUniqueField 534,69009266,3245,0
-- =============================================
CREATE PROCEDURE dbo.APIGetContactDataByUniqueField_BP
(
    @GroupId BIGINT = 0,
    @SearchText NVARCHAR(100) = '',
    @formId BIGINT = 0,
    @isCapture BIT
)
AS
BEGIN
    SET NOCOUNT OFF;
    DECLARE @ContactMasterId BIGINT = 0;
    SET @ContactMasterId =
    (
        SELECT TOP 1
            ContactMasterId
        FROM ContactDetails
        WHERE LOWER(Detail) = LOWER(@SearchText)
              AND IsDeleted = 0
    );
    IF (@ContactMasterId > 0)
    BEGIN
        IF (@isCapture = 0)
        BEGIN
            SELECT DISTINCT
                0 AS AnswerMasterId,
                Q.Id AS QuestionId,
                Q.QuestionTypeId AS QuestionType,
                Q.QuestionTitle AS Question,
                CD.Detail AS Answer
            FROM Questions Q
                LEFT JOIN ContactDetails CD
                    ON CD.ContactQuestionId = Q.ContactQuestionIdRef
                LEFT JOIN ContactMaster CM
                    ON CM.Id = CD.ContactMasterId
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
END;
