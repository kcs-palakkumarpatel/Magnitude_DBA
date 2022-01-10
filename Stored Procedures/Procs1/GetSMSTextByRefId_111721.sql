
-- =============================================
-- Author:		<Vasu Patel>
-- Create date: <23 May 2016>
-- Description:	<List Of SMSText By Refid.>
-- =============================================
CREATE PROCEDURE [dbo].[GetSMSTextByRefId_111721] @RefId BIGINT
AS
BEGIN
    SET NOCOUNT ON;
    SELECT Id,
           SMSText
    FROM dbo.PendingSMS WITH
        (NOLOCK)
    WHERE RefId = @RefId;
END;
