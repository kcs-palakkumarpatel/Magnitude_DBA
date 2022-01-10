-- =============================================
-- Author:			Developer D3
-- Create date:	30-May-2017
-- Description:	Get Capture Database from for Web API Using MerchantKey(GroupId)
-- Call: dbo.APIGetCaptureDatabaseByMerchantKey 201
-- =============================================
CREATE PROCEDURE [dbo].[APIGetCaptureDatabaseByCaptureIdEstablishmentId]
(
    @MerchantKey BIGINT,
    @CaptureId BIGINT = 0,
    @EstablishmentId BIGINT
)
AS
BEGIN
    SET NOCOUNT ON;

    SELECT EST.Id AS EstablishmentId,
           EST.EstablishmentName AS EstablishmentName,
           ESTG.SeenClientId AS CaptureId,
           ISNULL(SC.SeenClientTitle, '') AS CaptureTitle,
           0 AS ContactMasterId,
           0 AS IsContactGroup,
           0 AS ContactGroupId,
           '' AS Latitude,
           '' AS Longitude,
           GP.ContactId AS ContactId,
           ISNULL(ESTG.ContactQuestion, '') AS ContactQuestionsId
    FROM dbo.EstablishmentGroup AS ESTG WITH (NOLOCK)
        INNER JOIN dbo.[Group] AS GP WITH (NOLOCK)
            ON GP.Id = ESTG.GroupId
        INNER JOIN dbo.Establishment AS EST WITH (NOLOCK)
            ON EST.EstablishmentGroupId = ESTG.Id
        LEFT OUTER JOIN dbo.SeenClient AS SC WITH (NOLOCK)
            ON SC.Id = ESTG.SeenClientId
    WHERE ESTG.GroupId = @MerchantKey
          AND ESTG.SeenClientId IS NOT NULL
          AND ESTG.IsDeleted = 0
          AND EST.IsDeleted = 0
          AND ESTG.EstablishmentGroupId IS NOT NULL
          AND ESTG.SeenClientId = @CaptureId
          AND EST.Id = @EstablishmentId
    GROUP BY ISNULL(SC.SeenClientTitle, ''),
             EST.Id,
             EST.EstablishmentName,
             ESTG.SeenClientId,
             GP.ContactId,
             ESTG.ContactQuestion
    ORDER BY EST.Id ASC;

SET NOCOUNT OFF;
END;
