
-- =============================================
-- Author:      Matthew Grinaker
-- Create Date: 21-Sep-20
-- Description: Add new record in Pending Email of existing RefID
-- Call:		dbo.ResendPendingEmailByRefId
-- =============================================
CREATE PROCEDURE [dbo].[ResendPendingEmailByRefId]
(
@RefID BIGINT
)
AS
BEGIN
INSERT INTO PendingEmail
(
ModuleId,EmailId,EmailSubject,EmailText,IsSent,SentDate,RefId,ScheduleDateTime,ReplyTo,CreatedOn,CreatedBy,UpdatedOn,UpdatedBy,DeletedOn,DeletedBy,IsDeleted,Counter,Attachment,FinalEmailSubject,FinalEmailText,EmailType)
Select top 1 ModuleId, EmailId, 
EmailSubject, EmailText, 0,
NULL, 
RefId, DATEADD(Minute,125,GETDATE()), 
ReplyTo, DATEADD(Minute,120,GETDATE()), CreatedBy, 
NULL, NULL, 
NULL, NULL, 
IsDeleted, 0, NULL, 
FinalEmailSubject, FinalEmailText, 0 from PendingEmail where RefId = @RefID
END;
