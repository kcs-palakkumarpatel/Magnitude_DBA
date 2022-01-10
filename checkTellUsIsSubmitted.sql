-- =============================================
-- Author:		<Vasudev Patel>
-- Create date: <08 Nov 2017>
-- Description:	<Description,,>
-- Call:	checkTellUsIsSubmitted 1672,2847
-- =============================================
CREATE PROCEDURE [dbo].[checkTellUsIsSubmitted] 
	@AppUserId BIGINT,
	@ActivityId BIGINT
AS
BEGIN

	SELECT QuestionnaireId, (SELECT dbo.IsTellUsSubmitted(@AppUserId,@ActivityId)) AS IstelluseSubmitted FROM dbo.EstablishmentGroup WHERE id = @ActivityId

END
