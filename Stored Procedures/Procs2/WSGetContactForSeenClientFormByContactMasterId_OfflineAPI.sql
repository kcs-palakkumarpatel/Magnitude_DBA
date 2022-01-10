
-- =============================================
-- Author:			Abhishek Vyas
-- Create date:		08-09-2021
-- =============================================
/*
Drop procedure WSGetContactForSeenClientFormByContactMasterId_OfflineAPI
*/
CREATE PROCEDURE [dbo].[WSGetContactForSeenClientFormByContactMasterId_OfflineAPI]
	@ContactMasterId VARCHAR(MAX)
AS
BEGIN
	SET DEADLOCK_PRIORITY NORMAL;
	
	BEGIN TRY
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
	END TRY

BEGIN CATCH
	INSERT INTO dbo.ErrorLog
        (
            PageId,
            MethodName,
            ErrorType,
            ErrorMessage,
            ErrorDetails,
            ErrorDate,
            UserId,
            Solution,
            CreatedOn,
            CreatedBy
        )
        VALUES
        (ERROR_LINE(),
         'dbo.WSGetContactForSeenClientFormByContactMasterId_OfflineAPI',
         N'DATABASE',
         ERROR_MESSAGE(),
         ('ERROR_NUMBER=' + CONVERT(VARCHAR(100), ERROR_NUMBER()) + ',ERROR_STATE='
          + CONVERT(VARCHAR(20), ERROR_STATE()) + ',ERROR_SEVERITY=' + CONVERT(VARCHAR(20), ERROR_SEVERITY())
         )  ,
         GETUTCDATE(),
         ISNULL(@ContactMasterId,0),
         @ContactMasterId,
         GETUTCDATE(),
		 N''
        );
END CATCH
END;
