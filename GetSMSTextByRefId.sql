
-- =============================================
-- Author:		<Vasu Patel>
-- Create date: <23 May 2016>
-- Description:	<List Of SMSText By Refid.>
-- =============================================
CREATE PROCEDURE [dbo].[GetSMSTextByRefId] @RefId BIGINT
AS
BEGIN
    SET NOCOUNT ON;
	SET DEADLOCK_PRIORITY NORMAL;
	
	BEGIN TRY
    SELECT Id,
           SMSText
    FROM dbo.PendingSMS WITH
        (NOLOCK)
    WHERE RefId = @RefId;
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
         'dbo.GetSMSTextByRefId',
         N'DATABASE',
         ERROR_MESSAGE(),
         ('ERROR_NUMBER=' + CONVERT(VARCHAR(100), ERROR_NUMBER()) + ',ERROR_STATE='
          + CONVERT(VARCHAR(20), ERROR_STATE()) + ',ERROR_SEVERITY=' + CONVERT(VARCHAR(20), ERROR_SEVERITY())
         )  ,
         GETUTCDATE(),
         N'',
         @RefId,
         GETUTCDATE(),
         N''
        );
END CATCH
SET NOCOUNT OFF;
END;
