-- =============================================
-- Author:		Developer D3
-- Create date:	19-June-2020
-- Description:	Get Feedback Master Data from for Web API Using filter date
-- Call:		dbo.APIGetFeedbackAnswerDataForRB 534, 328459
-- =============================================
CREATE PROCEDURE [dbo].[APIGetFeedbackAnswerDataForRB]
    (
      @MerchantKey BIGINT = 0 ,
      @ReportId BIGINT = 0
	)
AS
BEGIN
	Select Detail as EmployeeId,(DATEADD(MINUTE, 120, GETUTCDATE())) as CreatedOn from Answers where AnswerMasterId = @ReportId and IsDeleted = 0 and QuestionId = 40884;
END