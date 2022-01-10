
-- =============================================
-- Author:		<Vasu patel>
-- Create date: <24 Jan 2017>
-- Description:	<Update SMS Status>
-- =============================================
CREATE PROCEDURE [dbo].[UpdateSMSStatus]
    @PendingSMSId INT,
    @SMSText NVARCHAR(MAX) = NULL
AS
BEGIN
	SET DEADLOCK_PRIORITY NORMAL;
	
	BEGIN TRY
    UPDATE dbo.PendingSMS
    SET IsSent = 1,
        SentDate = GETUTCDATE(),
        FinalSMSText = @SMSText,
        [Counter] = [Counter] + 1
    WHERE Id = @PendingSMSId;
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
         'dbo.UpdateSMSStatus',
         N'DATABASE',
         ERROR_MESSAGE(),
         ('ERROR_NUMBER=' + CONVERT(VARCHAR(100), ERROR_NUMBER()) + ',ERROR_STATE='
          + CONVERT(VARCHAR(20), ERROR_STATE()) + ',ERROR_SEVERITY=' + CONVERT(VARCHAR(20), ERROR_SEVERITY())
         )  ,
         GETUTCDATE(),
         N'',
        @PendingSMSId+','+@SMSText,
	    GETUTCDATE(),
         N''
        );
END CATCH
END;
