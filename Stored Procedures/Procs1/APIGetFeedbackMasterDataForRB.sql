-- =============================================
-- Author:		Developer D3
-- Create date:	19-June-2020
-- Description:	Get Feedback Master Data from for Web API Using filter date
-- Call:		dbo.APIGetFeedbackMasterDataForRB 534, '17-July-2020 00:00'
-- =============================================
CREATE PROCEDURE [dbo].[APIGetFeedbackMasterDataForRB]
    (
      @MerchantKey BIGINT = 0 ,
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
		Select DISTINCT AM.Id as FeedbackId, AM.PI, DATEADD(MINUTE, TimeOffSet, AM.CreatedOn) AS CreatedOn from AnswerMaster AS AM
		WHERE EstablishmentId = 28838 and QuestionnaireId = 3245 and IsDeleted = 0 and AM.Id NOT IN (Select Id from RBScreeningDataHistory) ORDER BY Id DESC;;
	END
	ELSE
	BEGIN
		Select DISTINCT Id as FeedbackId, PI, DATEADD(MINUTE, TimeOffSet, CreatedOn) AS CreatedOn from AnswerMaster
		WHERE EstablishmentId = 28838 and QuestionnaireId = 3245 and (DATEADD(MINUTE, TimeOffSet, CreatedOn) >= @FromDate) and IsDeleted = 0 ORDER BY Id DESC;
	END
END

--338549