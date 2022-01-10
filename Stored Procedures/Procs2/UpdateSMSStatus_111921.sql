
-- =============================================
-- Author:		<Vasu patel>
-- Create date: <24 Jan 2017>
-- Description:	<Update SMS Status>
-- =============================================
CREATE PROCEDURE [dbo].[UpdateSMSStatus_111921]
    @PendingSMSId INT,
    @SMSText NVARCHAR(MAX) = NULL
AS
BEGIN

    UPDATE dbo.PendingSMS
    SET IsSent = 1,
        SentDate = GETUTCDATE(),
        FinalSMSText = @SMSText,
        [Counter] = [Counter] + 1
    WHERE Id = @PendingSMSId;
END;
