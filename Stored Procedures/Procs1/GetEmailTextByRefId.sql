-- =============================================
-- Author:		<Vasu Patel>
-- Create date: <13 Dec 2018>
-- Description:	<List Of EmailText By Refid.>
-- =============================================
CREATE PROCEDURE [dbo].[GetEmailTextByRefId] @RefId BIGINT
AS
    BEGIN
        SELECT  Id ,
                EmailSubject ,
                EmailText
        FROM    dbo.PendingEmail
        WHERE   RefId = @RefId; 
    END;
