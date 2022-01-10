-- =============================================
-- Author:		Developer D3
-- Create date:	19-June-2020
-- Description:	Get Feedback Master Data from for Web API Using filter date
-- Call:		dbo.APIGetFeedbackMasterDataForRB 534, '17-July-2020 00:01', 0
-- =============================================
CREATE PROCEDURE [dbo].[APIGetFeedbackMasterDataHistoryForRB]
AS
BEGIN
--	INSERT INTO RBScreeningDataHistory (Id, PI, CreatedOn,isSent, SentDated)
--	Select DISTINCT Id as FeedbackId, PI, DATEADD(MINUTE, TimeOffSet,CreatedOn ) AS CreatedOn, 0, NULL from AnswerMaster WHERE EstablishmentId = 28838 and QuestionnaireId = 3245 and (DATEADD(MINUTE, TimeOffSet, CreatedOn) >= @FromDate) and IsDeleted = 0 ORDER BY Id DESC
--;
 
		Select DISTINCT Id from RBScreeningDataHistory
		 ORDER BY Id DESC;

END

--338549