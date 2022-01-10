-- =============================================
-- Author:		Developer D3
-- Create date:	19-June-2020
-- Description:	Get Feedback Master Data from for Web API Using filter date
-- Call:		dbo.APIGetFeedbackMasterDataForRB 534, '23-June-2020 08:31'
-- =============================================
CREATE PROCEDURE [dbo].[UpdateScreenUserHistory]
    (
      @Id BIGINT
	
	)
AS

BEGIN
	UPDATE RBScreeningDataHistory SET IsSent = 1 , SentDated = GETUTCDATE() where Id = @Id;  
END

