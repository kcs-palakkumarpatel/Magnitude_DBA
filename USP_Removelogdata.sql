
Create PROCEDURE USP_Removelogdata
AS 
BEGIN	


DELETE FROM ParkNotification WHERE YEAR(CreatedOn)<=year(dateAdd(yyyy,-2,getdate()))

DELETE FROM PendingNotification  WHERE YEAR(CreatedOn)<=year(dateAdd(yyyy,-2,getdate()))

DELETE FROM PendingNotificationWeb  WHERE YEAR(CreatedOn)<=year(dateAdd(yyyy,-2,getdate()))

DELETE FROM PendingSMS  WHERE YEAR(CreatedOn)<=year(dateAdd(yyyy,-2,getdate()))

DELETE FROM ErrorLog  WHERE YEAR(CreatedOn)=year(dateAdd(yyyy,-2,getdate()))

DELETE FROM ActivityLog WHERE YEAR(CreatedOn)<=year(dateAdd(yyyy,-2,getdate()))

END