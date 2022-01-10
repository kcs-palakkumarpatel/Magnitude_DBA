
-- =============================================
-- Author:		<Author,,GD>
-- Create date: <Create Date,,24 Jun 2015>
-- Description:	<Description,,>
-- Call SP:		WsGetContactDetailsForSeenClientByGroupId 42
-- =============================================
CREATE PROCEDURE [dbo].[WsGetContactDetailsForSeenClientByGroupId] @ContactGroupId BIGINT
AS
BEGIN
    SET NOCOUNT ON;
	SET DEADLOCK_PRIORITY NORMAL;
	
	BEGIN TRY
    SELECT Cm.Id AS ContactMasterId,
           Cq.Id AS QuestionId,
           Cq.QuestionTypeId,
           Cq.QuestionTitle,
           CONVERT(NVARCHAR(500), ISNULL(Detail, '')) AS Detail,
           Cq.IsDisplayInDetail,
           Cq.IsDisplayInSummary AS DisplayInList
    FROM dbo.ContactGroupRelation AS CGR WITH
        (NOLOCK)
        INNER JOIN dbo.ContactMaster AS Cm WITH
        (NOLOCK)
            ON CGR.ContactMasterId = Cm.Id
        INNER JOIN dbo.ContactDetails AS Cd WITH
        (NOLOCK)
            ON Cm.Id = Cd.ContactMasterId
        INNER JOIN dbo.ContactQuestions AS Cq WITH
        (NOLOCK)
            ON Cd.ContactQuestionId = Cq.Id
    WHERE Cd.IsDeleted = 0
          AND CGR.IsDeleted = 0
          AND Cm.IsDeleted = 0
          AND Cq.IsDeleted = 0
          AND CGR.ContactGroupId = @ContactGroupId --AND IsDisplayInDetail = 1
		      ORDER BY Cm.Id;
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
         'dbo.WsGetContactDetailsForSeenClientByGroupId',
         N'DATABASE',
         ERROR_MESSAGE(),
         ('ERROR_NUMBER=' + CONVERT(VARCHAR(100), ERROR_NUMBER()) + ',ERROR_STATE='
          + CONVERT(VARCHAR(20), ERROR_STATE()) + ',ERROR_SEVERITY=' + CONVERT(VARCHAR(20), ERROR_SEVERITY())
         )  ,
         GETUTCDATE(),
         @ContactGroupId,
        @ContactGroupId,
	    GETUTCDATE(),
         N''
        );
END CATCH

END;
