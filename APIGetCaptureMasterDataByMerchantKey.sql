-- =============================================
-- Author:		Matthew Grinaker
-- Create date:	05-June-2017
-- Updated Date: 2020-04-09
-- Description:	Get Capture Master Data from for Web API Using MerchantKey(GroupId)
-- Call:    dbo.APIGetCaptureMasterDataByMerchantKey 413, '05-June-2017',  '05-June-2020', 507386
-- =============================================
CREATE PROCEDURE [dbo].[APIGetCaptureMasterDataByMerchantKey]
(
    @MerchantKey BIGINT = 0,
    @FromDate NVARCHAR(50) = NULL,
    @ToDate NVARCHAR(50) = NULL,
    @CaptureId NVARCHAR(MAX) = '0',
    @ActivityId NVARCHAR(MAX) = '0'
)
AS
BEGIN
    SET NOCOUNT OFF;
    SELECT ISNULL(CAM.Id, 0) AS ReportId,
           ISNULL(ESTG.Id, 0) AS ActivityId,
           ISNULL(ESTG.EstablishmentGroupName, '') AS ActivityName,
           ISNULL(CAM.EstablishmentId, 0) AS EstablishmentId,
           ISNULL(EST.EstablishmentName, '') AS EstablishmentName,
           ISNULL(CAM.SeenClientId, 0) AS CaptureId,
           ISNULL(SC.SeenClientTitle, '') AS CaptureFormTitle,
           ISNULL(AU.Name, '') AS AppUser,
           ISNULL(CAM.IsOutStanding, 0) AS OutStanding,
           ISNULL(AU.Name, '') AS ReadBy,
           ISNULL(CAM.Latitude, '') AS Latitude,
           ISNULL(CAM.Longitude, '') AS Longitude,
           ISNULL(CAM.TimeOffSet, 0) AS TimeOffSet,
           ISNULL(CAM.IsPositive, '') AS Positive,
           ISNULL(CAM.EI, 0) AS EI,
           ISNULL(CAM.IsResolved, '') AS Resolved,
           ISNULL(CAM.IsTransferred, 0) AS Transferred,
           ISNULL(CAM.IsActioned, 0) AS Actioned,
           ISNULL(CAM.SenderCellNo, '') AS SenderCellNo,
           ISNULL(CAM.IsSubmittedForGroup, 0) AS SubmittedForGroup,
           ISNULL(CAM.[PI], 0) AS [PI ],
           ISNULL(ES.StatusName, '') AS StatusName,
           ISNULL(SH.StatusDateTime, '') AS StatusDate,
           ISNULL(CAM.Narration, '') AS Narration,
           ISNULL(CAM.IsRecursion, 0) AS Recursion,
           ISNULL(CONVERT(VARCHAR(24), CAM.EscalationSendDate, 113), '') AS EscalationSendDate,
           ISNULL(CONVERT(VARCHAR(24), CAM.CreatedOn, 113), '') AS CreatedDate,
           ISNULL(AU.Name, '') AS CreatedBy
    FROM dbo.Establishment AS EST
        INNER JOIN dbo.EstablishmentGroup AS ESTG
            ON ESTG.Id = EST.EstablishmentGroupId
        INNER JOIN dbo.SeenClientAnswerMaster AS CAM
            ON EST.Id = CAM.EstablishmentId
        INNER JOIN dbo.SeenClient AS SC
            ON SC.Id = CAM.SeenClientId
        LEFT JOIN dbo.AppUser AS AU
            ON AU.Id = CAM.AppUserId
        LEFT JOIN dbo.StatusHistory SH
            ON SH.Id = CAM.StatusHistoryId
        LEFT JOIN dbo.EstablishmentStatus ES
            ON ES.EstablishmentId = EST.Id
               AND ES.Id = SH.EstablishmentStatusId
    WHERE EST.GroupId = @MerchantKey
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
          AND CAM.CreatedOn
          BETWEEN CONVERT(DATETIME, @FromDate, 103) AND CONVERT(DATETIME, @ToDate + ' 23:59:59.000', 103)
    ORDER BY CAM.CreatedOn DESC;
END;
