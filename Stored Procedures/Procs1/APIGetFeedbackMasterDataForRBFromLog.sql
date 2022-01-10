-- =============================================
-- Author:		Developer D3
-- Create date:	19-June-2020
-- Description:	Get Feedback Master Data from for Web API Using filter date
-- Call:		dbo.APIGetFeedbackMasterDataForRBFromLog '20-July-2019 10:00', 1
-- =============================================
CREATE PROCEDURE [dbo].[APIGetFeedbackMasterDataForRBFromLog]
    (
      @FromDate NVARCHAR(50) = NULL,
	  @FlagUseDate BIT = 1
	)
AS
BEGIN
--	INSERT INTO RBScreeningDataHistory (Id, PI, CreatedOn,isSent, SentDated)
--	Select DISTINCT Id as FeedbackId, PI, DATEADD(MINUTE, TimeOffSet,CreatedOn ) AS CreatedOn, 0, NULL from AnswerMaster WHERE EstablishmentId = 28838 and QuestionnaireId = 3245 and (DATEADD(MINUTE, TimeOffSet, CreatedOn) >= @FromDate) and IsDeleted = 0 ORDER BY Id DESC
--;

	If (@FlagUseDate = 0)
	BEGIN
		Select DISTINCT RBL.Id as FeedbackId, AM.PI , RBL.CreatedOn AS CreatedOn from RBScreeningDataHistoryLog AS RBL
		LEFT JOIN AnswerMaster as AM on RBL.Id = AM.Id
		WHERE RBL.isSent = 0 and AM.IsDeleted = 0 ORDER BY RBL.Id DESC;
	END
	ELSE
	BEGIN
		--Select DISTINCT RBL.Id as FeedbackId, AM.PI , RBL.CreatedOn AS CreatedOn from RBScreeningDataHistoryLog AS RBL
		--LEFT JOIN AnswerMaster as AM on RBL.Id = AM.Id
		--WHERE RBL.CreatedOn >= @FromDate and AM.IsDeleted = 0 ORDER BY RBL.Id DESC;
		
		Select DISTINCT RBL.Id as FeedbackId, AM.PI , RBL.CreatedOn AS CreatedOn from RBScreeningDataHistoryLog_Activity AS RBL
		LEFT JOIN AnswerMaster as AM on RBL.Id = AM.Id
		WHERE RBL.CreatedOn >= @FromDate and AM.IsDeleted = 0 
		GROUP BY RBL.Id, AM.PI, RBL.CreatedOn
		ORDER BY RBL.Id DESC
	END
END

--338549