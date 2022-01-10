-- =============================================
-- Author:		Matthew Grinaker
-- Create date:	05-June-2017
-- Description:	Get Capture Master Data from for Web API Using MerchantKey(GroupId)
-- Call:    dbo.APIGetCaptureStatusOptionsByMerchantKeyAndReportId 201, 121430
-- =============================================
CREATE PROCEDURE [dbo].[APIGetCaptureStatusOptionsByMerchantKeyAndReportId]
    (
      @MerchantKey BIGINT = 0 ,
	  @ReportId NVARCHAR(MAX) = '0'
	)
AS
    BEGIN
        SELECT  ISNULL(ES.Id, 0) AS EstablishmentStatusId,
				ISNULL(ES.StatusName, '') AS StatusName
        FROM    dbo.SeenClientAnswerMaster AS CAM
				INNER JOIN dbo.Establishment AS EST ON EST.Id = CAM.EstablishmentId
				LEFT JOIN dbo.EstablishmentStatus ES on ES.EstablishmentId = EST.Id
        WHERE   EST.GroupId = @MerchantKey
				AND CAM.Id IN ( SELECT Data FROM dbo.Split(@ReportId, ','))
				AND ES.id != (Select top 1 EstablishmentStatusId from StatusHistory where ReferenceNo = CAM.id order by CreatedOn desc)      
        ORDER BY CAM.CreatedOn DESC
END;
