-- =============================================
-- Author:		<Author,,GD>
-- Create date: <Create Date,,19 Dec 2015>
-- Description:	<Description,,>
-- Call SP:		WSGetExistingGroupContactsByFeedbackID 39999
-- =============================================
CREATE PROCEDURE [dbo].[WSGetExistingGroupContactsByFeedbackID]
	@search VARCHAR(50),
    @SeenClientAnswerMasterId BIGINT
AS 
    BEGIN
	SELECT * FROM (
		SELECT  ISNULL(Ac.ContactMasterId,Am.ContactMasterId) AS Id, dbo.ConcateString('ContactSummary', ISNULL(Ac.ContactMasterId,Am.ContactMasterId) ) AS Detail
		FROM dbo.SeenClientAnswerMaster AM
			LEFT JOIN  dbo.SeenClientAnswerChild AC ON AC.SeenClientAnswerMasterId=AM.Id
		WHERE Am.Id=@SeenClientAnswerMasterId
		)i
		WHERE i.Detail LIKE '%'+@search+'%'
    END