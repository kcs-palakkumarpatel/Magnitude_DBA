CREATE PROCEDURE [dbo].[UpdatelastRunTimeAndIsRinning] 
AS

BEGIN
	SET NOCOUNT ON;
		UPDATE dbo.Scheduler SET IsRunning = 0,LastRunTime = GETDATE() WHERE IsRunning = 1
END