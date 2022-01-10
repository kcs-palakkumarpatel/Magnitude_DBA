-- =============================================
-- Author:		<Author,,GD>
-- Create date: <Create Date,,29 Oct 2015>
-- Description:	<Description,,>
-- Call SP:		
-- =============================================
CREATE PROCEDURE [dbo].[UpdateAutoReportStatus] @Id BIGINT
AS
    BEGIN
        UPDATE  dbo.PendingAutoReportingScheduler
        SET     IsExecuted = 1 ,
                ExecutedOn = GETUTCDATE()
        WHERE   Id = @Id;
    END;