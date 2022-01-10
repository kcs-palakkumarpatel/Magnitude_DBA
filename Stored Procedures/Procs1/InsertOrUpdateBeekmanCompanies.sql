-- =============================================  
-- Author:  <Ankit,,GD>  
-- Create date: <Create Date,, 18 Jun 2019>  
-- Description: <Description,,InsertOrUpdateSeenClient>  
-- Call SP    : InsertOrUpdateBeekmanCompanies  
-- =============================================  
CREATE PROCEDURE dbo.InsertOrUpdateBeekmanCompanies @BeekmanCompaniesTableType BeekmanCompaniesTableType READONLY  
AS  
BEGIN  
    INSERT INTO dbo.BeekmanCompanies  
    (  
        ApiId,  
        Subscription_Id,  
        [Name],  
        Stars,  
        Latitude,  
        Longitude,  
        [Address],  
        City,  
        Region,  
        Postal_Code,  
        Country,  
        Country_Code,  
        Website,  
        Email,  
        Phone,  
        EstablishmentId,  
        ContactMasterId,  
        SeenClientId  
    )  
    SELECT BCT.ApiId,  
           BCT.Subscription_Id,  
           BCT.[Name],  
           BCT.Stars,  
           BCT.Latitude,  
           BCT.Longitude,  
           BCT.[Address],  
           BCT.City,  
           BCT.Region,  
           BCT.Postal_Code,  
           BCT.Country,  
           BCT.Country_Code,  
           BCT.Website,  
           BCT.Email,  
           BCT.Phone,  
           ISNULL(E.Id, 0),  
           0,  
           EG.SeenClientId  
    FROM @BeekmanCompaniesTableType BCT  
        LEFT JOIN BeekmanCompanies BC  
            ON BCT.ApiId = BC.ApiId  
        LEFT JOIN dbo.Establishment E  
            ON LTRIM(RTRIM(BCT.[Name])) = LTRIM(RTRIM(E.EstablishmentName))
               AND E.IsDeleted = 0  
               AND E.GroupId = 488  
        INNER JOIN dbo.EstablishmentGroup EG  
            ON E.EstablishmentGroupId = EG.Id  
               AND EG.IsDeleted = 0  
    WHERE BC.Id IS NULL;  
  
  --SELECT TOP 10 * FROM dbo.Establishment WHERE GroupId=488 ORDER BY id DESC
--;  
--WITH CLT  
--AS (SELECT ConditionQuestionId,  
--           DeletedBy,  
--           IsDeleted,  
--           QuestionId,  
--           AnswerText,  
--           OperationId  
--    FROM @ConditionLogicTableType  
--    WHERE IsDeleted = 1  
--   )  
--UPDATE ConditionLogic  
--SET DeletedOn = GETUTCDATE(),  
--    DeletedBy = CLT.DeletedBy,  
--    IsDeleted = CLT.IsDeleted  
--FROM ConditionLogic AS CL  
--    INNER JOIN CLT  
--        ON CL.ConditionQuestionId = CLT.ConditionQuestionId  
--           AND CLT.AnswerText = CL.AnswerText  
--           AND CL.OperationId = CLT.OperationId;  
  
END;  
