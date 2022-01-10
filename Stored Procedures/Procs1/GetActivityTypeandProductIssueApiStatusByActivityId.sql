
-- =============================================
-- Author:			Developer D3
-- Create date:	10-10-2017
-- Description:	
-- Call:					
-- =============================================
CREATE PROCEDURE [dbo].[GetActivityTypeandProductIssueApiStatusByActivityId] @ActivityId BIGINT
AS
BEGIN
	SET DEADLOCK_PRIORITY NORMAL;
	
	BEGIN TRY
    SELECT ISNULL(EstablishmentGroupType, '') AS ActivityType,
           ISNULL(ProductIssueApiStatus, 0) AS ProductIssueApiStatus
    FROM dbo.EstablishmentGroup
    WHERE Id = @ActivityId
          AND IsDeleted = 0;
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
         'dbo.GetActivityTypeandProductIssueApiStatusByActivityId',
         N'DATABASE',
         ERROR_MESSAGE(),
         ('ERROR_NUMBER=' + CONVERT(VARCHAR(100), ERROR_NUMBER()) + ',ERROR_STATE='
          + CONVERT(VARCHAR(20), ERROR_STATE()) + ',ERROR_SEVERITY=' + CONVERT(VARCHAR(20), ERROR_SEVERITY())
         )  ,
         GETUTCDATE(),
         N'',
         @ActivityId,
         GETUTCDATE(),
         N''
        );
END CATCH

END;
