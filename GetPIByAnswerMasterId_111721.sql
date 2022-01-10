
-- =============================================
-- Author:		<Vasu Patel>
-- Create date: <02 Feb 2016>
-- Description:	<Get Pi by AnswerMasterid>
-- Call: GetPIByAnswerMasterId 1154
-- =============================================
CREATE PROCEDURE [dbo].[GetPIByAnswerMasterId_111721]
	@Id bigint
AS
BEGIN
	select PI from answermaster where id = @Id
END
