
-- =============================================
-- Author:		<Author,,Anant>
-- Create date: <Create Date,,19 Jun 2019>
-- Description:	<Description,,>
-- Call SP:		GetPendingCaptureFormForJohnDeer
-- =============================================
CREATE PROCEDURE [dbo].[GetPendingCaptureFormForJohnDeer]
AS
BEGIN
	SET DEADLOCK_PRIORITY NORMAL;
	
	BEGIN TRY
    SELECT Id,
           WorkflowMasterID,
           ISNULL(fromReferenceNumber,0) AS fromReferenceNumber,
           ISNULL(ToEstablishnmentId,0) AS ToEstablishnmentId,
           isActioned
    FROM dbo.MapingWorkFlowData
    WHERE isActioned = 0
          AND IsDeleted = 0;END TRY

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
         'dbo.GetPendingCaptureFormForJohnDeer',
         N'DATABASE',
         ERROR_MESSAGE(),
         ('ERROR_NUMBER=' + CONVERT(VARCHAR(100), ERROR_NUMBER()) + ',ERROR_STATE='
          + CONVERT(VARCHAR(20), ERROR_STATE()) + ',ERROR_SEVERITY=' + CONVERT(VARCHAR(20), ERROR_SEVERITY())
         )  ,
         GETUTCDATE(),
         N'',
         N'',
         GETUTCDATE(),
         N''
        );
END CATCH
END;
