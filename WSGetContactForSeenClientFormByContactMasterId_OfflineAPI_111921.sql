
-- =============================================
-- Author:			Abhishek Vyas
-- Create date:		08-09-2021
-- =============================================
/*
Drop procedure WSGetContactForSeenClientFormByContactMasterId_OfflineAPI
*/
CREATE PROCEDURE [dbo].[WSGetContactForSeenClientFormByContactMasterId_OfflineAPI_111921]
	@ContactMasterId VARCHAR(MAX)
AS
BEGIN
	
    SELECT Q.Id AS QuestionId,
           Q.QuestionTitle,
           Q.QuestionTypeId,
           ISNULL(Detail, '') AS Detail,
           IsDisplayInDetail,
           IsDisplayInSummary AS IsDisplayInList,
		   cd.ContactMasterId
    FROM dbo.ContactDetails AS cd
	INNER JOIN dbo.ContactQuestions AS Q ON cd.ContactQuestionId = Q.Id AND Q.IsDeleted = 0
    WHERE ContactMasterId IN (SELECT Data FROM Dbo.Split(@ContactMasterId,',')) AND Cd.IsDeleted = 0
    ORDER BY cd.ContactMasterId, Q.Position ASC;
END;
