
-- =============================================
-- Author:		<Author,,GD>
-- Create date: <Create Date,,03 Jul 2015>
-- Description:	<Description,,>
-- Call SP:		UpdatePendingEmailStatus
-- =============================================
CREATE PROCEDURE [dbo].[UpdatePendingEmailStatus]
(
    @Id BIGINT,
    @EmailSubject NVARCHAR(MAX) = NULL,
    @EmailText NVARCHAR(MAX) = NULL
)
AS
BEGIN
	SET DEADLOCK_PRIORITY NORMAL;
	
	BEGIN TRY
    UPDATE dbo.PendingEmail
    SET IsSent = 1,
        Counter = Counter + 1,
        SentDate = GETUTCDATE(),
        FinalEmailSubject = @EmailSubject,
        FinalEmailText = @EmailText
    WHERE Id = @Id;
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
         'dbo.UpdatePendingEmailStatus',
         N'DATABASE',
         ERROR_MESSAGE(),
         ('ERROR_NUMBER=' + CONVERT(VARCHAR(100), ERROR_NUMBER()) + ',ERROR_STATE='
          + CONVERT(VARCHAR(20), ERROR_STATE()) + ',ERROR_SEVERITY=' + CONVERT(VARCHAR(20), ERROR_SEVERITY())
         )  ,
         GETUTCDATE(),
         N'',
        @Id+','+@EmailSubject+','+@EmailText,
	    GETUTCDATE(),
         N''
        );
END CATCH
END;
