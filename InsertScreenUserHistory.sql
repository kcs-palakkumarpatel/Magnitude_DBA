-- =============================================
-- Author:		Developer D3
-- Create date:	19-June-2020
-- Description:	Get Feedback Master Data from for Web API Using filter date
-- Call:		dbo.APIGetFeedbackMasterDataForRB 534
-- =============================================
CREATE PROCEDURE [dbo].[InsertScreenUserHistory]
    (
      @ReportId BIGINT
	)
AS
BEGIN
		  IF NOT EXISTS
        (
            SELECT *
            FROM dbo.RBScreeningDataHistory
            WHERE ID = @ReportId
		
        )
	BEGIN
		INSERT INTO RBScreeningDataHistory (Id, CreatedOn,isSent, SentDated)
		VALUES( @ReportId, (DATEADD(MINUTE, 120, GETUTCDATE())), 0, NULL)
	END
END

