
-- =============================================
-- Author:		<Author,,MATTHEW GRINAKER>
-- Create date: <Create Date,, 22 Nov 2019>
-- Description:	<Description,,DeleteLagoonBeachUnresolvedFeedbackData>
-- Call SP    :	DeleteLagoonBeachUnresolvedFeedbackData
-- =============================================
CREATE PROCEDURE [dbo].[DeleteLagoonBeachUnresolvedFeedbackData]
AS
BEGIN
Update SeenClientAnswers SET IsDeleted = 1
WHERE SeenClientAnswerMasterId IN (SELECT DISTINCT SCA.SeenClientAnswerMasterId
    FROM SeenClientAnswers SCA
        INNER JOIN dbo.SeenClientAnswerMaster SCAM
            ON SCAM.Id = SCA.SeenClientAnswerMasterId
			   AND SCAM.IsResolved = 'Unresolved'
			   AND SCAM.IsDeleted = '0'
			   AND SCAM.SeenClientId = '1451'
			   AND SCAM.CreatedOn < getdate())

Update SeenClientAnswerChild SET IsDeleted = 1
WHERE SeenClientAnswerMasterId IN (SELECT DISTINCT SCA.SeenClientAnswerMasterId
    FROM SeenClientAnswers SCA
        INNER JOIN dbo.SeenClientAnswerMaster SCAM
            ON SCAM.Id = SCA.SeenClientAnswerMasterId
			   AND SCAM.IsResolved = 'Unresolved'
			   AND SCAM.IsDeleted = '0'
			  AND SCAM.SeenClientId = '1451'
			  AND SCAM.CreatedOn < getdate())

Update SeenClientAnswerMaster SET IsDeleted = 1
WHERE ID IN (SELECT DISTINCT SCA.SeenClientAnswerMasterId
    FROM SeenClientAnswers SCA
        INNER JOIN dbo.SeenClientAnswerMaster SCAM
            ON SCAM.Id = SCA.SeenClientAnswerMasterId
			   AND SCAM.IsResolved = 'Unresolved'
			   AND SCAM.IsDeleted = '0'
			   AND SCAM.SeenClientId = '1451'
			   AND SCAM.CreatedOn < getdate())
END
