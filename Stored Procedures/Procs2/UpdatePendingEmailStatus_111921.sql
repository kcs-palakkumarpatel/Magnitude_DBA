
-- =============================================
-- Author:		<Author,,GD>
-- Create date: <Create Date,,03 Jul 2015>
-- Description:	<Description,,>
-- Call SP:		UpdatePendingEmailStatus
-- =============================================
CREATE PROCEDURE [dbo].[UpdatePendingEmailStatus_111921]
(
    @Id BIGINT,
    @EmailSubject NVARCHAR(MAX) = NULL,
    @EmailText NVARCHAR(MAX) = NULL
)
AS
BEGIN
    UPDATE dbo.PendingEmail
    SET IsSent = 1,
        Counter = Counter + 1,
        SentDate = GETUTCDATE(),
        FinalEmailSubject = @EmailSubject,
        FinalEmailText = @EmailText
    WHERE Id = @Id;
END;
