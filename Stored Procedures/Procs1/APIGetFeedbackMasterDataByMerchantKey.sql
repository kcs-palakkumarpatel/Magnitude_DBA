-- =============================================
-- Author:			Developer D3
-- Create date:	05-June-2017
-- Description:	Get Feedback Master Data from for Web API Using MerchantKey(GroupId)
-- Call:dbo.APIGetFeedbackMasterDataByMerchantKey 201,'01-Jun-2021','15-Jul-2021',"0","0"
-- =============================================
CREATE PROCEDURE [dbo].[APIGetFeedbackMasterDataByMerchantKey]
    (
      @MerchantKey BIGINT = 0 ,
      @FromDate NVARCHAR(50) = NULL ,
      @ToDate NVARCHAR(50) = NULL,
	  @CaptureId NVARCHAR(MAX) = '0',
      @ActivityId NVARCHAR(MAX) = '0'
	)
AS
    BEGIN
        SET NOCOUNT OFF;
        SELECT  ISNULL(CAM.Id, 0) AS ReportId,
				ISNULL(CAM.SeenClientAnswerMasterId, 0) AS CaptureReportId,
				ISNULL(ESTG.Id, 0) AS ActivityId ,
                ISNULL(ESTG.EstablishmentGroupName, '') AS ActivityName ,
				ISNULL(CAM.EstablishmentId, 0) AS EstablishmentId ,
                ISNULL(EST.EstablishmentName, '') AS EstablishmentName ,
                ISNULL(CAM.QuestionnaireId, 0) AS FeedbackId ,
                ISNULL(SC.QuestionnaireTitle, '') AS FeedbackTitle ,
				ISNULL(SC.QuestionnaireFormType, '') AS FeedbackFormType ,
                ISNULL(CAM.IsOutStanding, 0) AS OutStanding ,
                ISNULL(AU.Id, 0) AS ReadById ,
				ISNULL(AU.Name, '') AS ReadByName ,
                ISNULL(CAM.Latitude, '') AS Latitude ,
                ISNULL(CAM.Longitude, '') AS Longitude ,
                ISNULL(CAM.TimeOffSet, 0) AS TimeOffSet ,
                ISNULL(CAM.IsPositive, '') AS Positive ,
                ISNULL(CAM.EI, 0) AS EI ,
                ISNULL(CAM.IsResolved, '') AS Resolved ,
                ISNULL(CAM.IsTransferred, 0) AS Transferred ,
                ISNULL(CAM.IsActioned, 0) AS Actioned ,
                ISNULL(CAM.SenderCellNo, '') AS SenderCellNo ,
                ISNULL(CAM.[PI], 0) AS [PI ] ,
                ISNULL(CAM.Narration, '') AS Narration ,
                ISNULL(CONVERT(NVARCHAR(30), CAM.EscalationSendDate, 120), '') AS EscalationSendDate ,
                ISNULL(CONVERT(NVARCHAR(30), CAM.CreatedOn, 120), '') AS CreatedDate 
        FROM    dbo.Establishment AS EST
		INNER JOIN dbo.EstablishmentGroup	AS ESTG ON ESTG.Id = EST.EstablishmentGroupId
                INNER JOIN dbo.AnswerMaster AS CAM ON EST.Id = CAM.EstablishmentId
                INNER JOIN dbo.Questionnaire AS SC ON SC.Id = CAM.QuestionnaireId
                LEFT JOIN dbo.AppUser AS AU ON AU.Id = CAM.ReadBy
        WHERE   EST.GroupId = @MerchantKey
		           AND (
                  CAM.Id IN (
                                SELECT Data FROM dbo.Split(@CaptureId, ',')
                            )
                  OR @CaptureId = '0'
              )
          AND (
                  ESTG.Id IN (
                                 SELECT Data FROM dbo.Split(@ActivityId, ',')
                             )
                  OR @ActivityId = '0'
              )
                AND CAM.CreatedOn BETWEEN CONVERT(DATETIME, @FromDate, 103) AND CONVERT(DATETIME, @ToDate + ' 23:59:59.000',  103)
        ORDER BY CAM.CreatedOn DESC;

    END;
