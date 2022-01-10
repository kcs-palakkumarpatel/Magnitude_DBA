
-- =============================================
-- Author:		<Author,,GD>
-- Create date: <Create Date,,17 Jul 2015>
-- Description:	<Description,,>
-- Call SP:		UpdateProcessStatus 1, 1
-- =============================================
CREATE PROCEDURE [dbo].[UpdateProcessStatus]
    @ProcessId BIGINT ,
    @Status BIT
AS 
    BEGIN
	SET DEADLOCK_PRIORITY NORMAL;
	
	BEGIN TRY
        UPDATE  dbo.ProcessStatus
        SET     IsRunning = @Status
        WHERE   ProcessId = @ProcessId
        IF @Status = 1 
            BEGIN
                UPDATE  dbo.ProcessStatus
                SET     LastUpdatedTime = GETUTCDATE()
                WHERE   ProcessId = @ProcessId
            END
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
         'dbo.UpdateProcessStatus',
         N'DATABASE',
         ERROR_MESSAGE(),
         ('ERROR_NUMBER=' + CONVERT(VARCHAR(100), ERROR_NUMBER()) + ',ERROR_STATE='
          + CONVERT(VARCHAR(20), ERROR_STATE()) + ',ERROR_SEVERITY=' + CONVERT(VARCHAR(20), ERROR_SEVERITY())
         )  ,
         GETUTCDATE(),
         N'',
        @ProcessId+','+@Status,
	    GETUTCDATE(),
         N''
        );
END CATCH
    END
