
-- =============================================
-- Author:		<Vasu Patel>
-- Create date: <02 Feb 2016>
-- Description:	<Get Pi by AnswerMasterid>
-- Call: GetPIByAnswerMasterId 1154
-- =============================================
CREATE PROCEDURE [dbo].[GetPIByAnswerMasterId]
	@Id bigint
AS
BEGIN
	SET DEADLOCK_PRIORITY NORMAL;
	
	BEGIN TRY
	select PI from answermaster where id = @Id
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
         'dbo.GetPIByAnswerMasterId',
         N'DATABASE',
         ERROR_MESSAGE(),
         ('ERROR_NUMBER=' + CONVERT(VARCHAR(100), ERROR_NUMBER()) + ',ERROR_STATE='
          + CONVERT(VARCHAR(20), ERROR_STATE()) + ',ERROR_SEVERITY=' + CONVERT(VARCHAR(20), ERROR_SEVERITY())
         )  ,
         GETUTCDATE(),
         N'',
         @Id,
         GETUTCDATE(),
         N''
        );
END CATCH
END
