-- =============================================
-- Author:		Matthew Grinaker
-- Create date:	05-June-2017
-- Description:	Get Capture Master Data from for Web API Using MerchantKey(GroupId)
-- Call:    dbo.APIGetCaptureStatusHistoryByMerchantKeyAndReportId 201, 123172
-- =============================================
CREATE PROCEDURE [dbo].[APIGetCaptureStatusHistoryByMerchantKeyAndReportId]
    (
      @MerchantKey BIGINT = 0 ,
	  @ReportId NVARCHAR(MAX) = '0'
	)
AS
    BEGIN
        SELECT  --ISNULL(CAM.Id, 0) AS ReportId,
				ISNULL(ES.StatusName, '') AS CaptureStatus,
				ISNULL(CONVERT(varchar, SH.StatusDateTime, 20), '') as StatusDateTime,
				ISNULL(AU.Name, '') as AppUser
        FROM    dbo.SeenClientAnswerMaster AS CAM
				INNER JOIN dbo.Establishment AS EST ON EST.Id = CAM.EstablishmentId
				--LEFT JOIN dbo.StatusHistory SH ON SH.id = CAM.StatusHistoryId
				LEFT JOIN dbo.StatusHistory SH ON SH.ReferenceNo = CAM.id
				LEFT JOIN dbo.EstablishmentStatus ES on ES.EstablishmentId = EST.Id AND ES.Id = SH.EstablishmentStatusId
				LEFT JOIN dbo.AppUser AS AU ON AU.Id = SH.CreatedBy
        WHERE   EST.GroupId = @MerchantKey
				AND CAM.Id IN ( SELECT Data FROM dbo.Split(@ReportId, ','))
                --AND CAM.CreatedOn BETWEEN CONVERT(DATETIME, @FromDate, 103) AND CONVERT(DATETIME, @ToDate + ' 23:59:59.000',  103)
        ORDER BY SH.StatusDateTime ASC
END;
