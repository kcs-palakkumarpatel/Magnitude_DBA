
/*
 =============================================
 Author:		Disha Patel
 Create date: 03-10-2016
 Description:	1) Fetches all the notifications prior to 2 days from PendingNotification table 
					and inserts into the ParkNotification table.
				2) Delete all the notifications from the PendingNotification table prior to 2 days.
 Call SP: InsertParkNotification
 =============================================
*/

CREATE PROCEDURE [dbo].[InsertParkNotification]
AS 
    BEGIN
		/* Insert all notifications into ParkNotification table prior 2 days */
		INSERT INTO ParkNotification
		SELECT Id, ModuleId, [Message], TokenId, [Status], SentDate, ScheduleDate, RefId, AppUserId, DeviceType, 
				CreatedOn , UpdatedOn , DeletedOn , IsDeleted
		FROM PendingNotification WHERE CONVERT(NVARCHAR(15),ScheduleDate,111) < CONVERT(NVARCHAR(15),DATEADD(DAY,-2,GETUTCDATE()),111)

		/* Delete all notifications from PendingNotifications prior 2 days */
		DELETE FROM dbo.PendingNotification WHERE CONVERT(NVARCHAR(15),ScheduleDate,111) < CONVERT(NVARCHAR(15),DATEADD(DAY,-2,GETUTCDATE()),111)
    END