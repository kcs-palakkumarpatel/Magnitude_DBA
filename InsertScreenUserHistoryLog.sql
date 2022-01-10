-- =============================================
-- Author:		Developer D3
-- Create date:	19-June-2020
-- Description:	Get Feedback Master Data from for Web API Using filter date
-- Call:		dbo.APIGetFeedbackMasterDataForRB 534
-- =============================================
CREATE PROCEDURE [dbo].[InsertScreenUserHistoryLog]
    (
      @ReportId BIGINT,
	  @PI DECIMAL(18,2),
	  @ScreeningDate DATETIME
	)
AS
BEGIN
		 

		UPDATE RBScreeningDataHistoryLog SET isSent = 1, SentON = (DATEADD(MINUTE, 120, GETUTCDATE())), PI = @PI WHERE ID = @ReportId;
				
				INSERT INTO RBScreeningDataHistoryLog_Activity (Id, PI, CreatedOn, isSent, SentON)
		VALUES( @ReportId, @PI, @ScreeningDate , 1, (DATEADD(MINUTE, 120, GETUTCDATE())))

END

