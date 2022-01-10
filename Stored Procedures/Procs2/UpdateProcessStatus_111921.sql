
-- =============================================
-- Author:		<Author,,GD>
-- Create date: <Create Date,,17 Jul 2015>
-- Description:	<Description,,>
-- Call SP:		UpdateProcessStatus 1, 1
-- =============================================
CREATE PROCEDURE [dbo].[UpdateProcessStatus_111921]
    @ProcessId BIGINT ,
    @Status BIT
AS 
    BEGIN
        UPDATE  dbo.ProcessStatus
        SET     IsRunning = @Status
        WHERE   ProcessId = @ProcessId
        IF @Status = 1 
            BEGIN
                UPDATE  dbo.ProcessStatus
                SET     LastUpdatedTime = GETUTCDATE()
                WHERE   ProcessId = @ProcessId
            END
    END
