-- =============================================
-- Author:			Developer D3
-- Create date:	30-May-2017
-- Description:	Get Capture Database from for Web API Using MerchantKey(GroupId)
-- Call: dbo.APIGetCaptureDatabaseByMerchantKey 201
-- =============================================
CREATE PROCEDURE [dbo].[APIGetCaptureDatabaseByMerchantKey]
    (
      @MerchantKey BIGINT = 0
	)
AS
    BEGIN
        SET NOCOUNT OFF;
	    
		SELECT  EST.Id AS EstablishmentId ,
				EST.EstablishmentName AS EstablishmentName,
                ESTG.SeenClientId AS CaptureId ,
                ISNULL(SC.SeenClientTitle, '') AS CaptureTitle ,
                0 AS ContactMasterId ,
                0 AS IsContactGroup ,
                0 AS ContactGroupId ,
                '' AS Latitude ,
                '' AS Longitude,
				GP.ContactId AS ContactId,
				ISNULL(ESTG.ContactQuestion, '') AS ContactQuestionsId
        FROM    dbo.EstablishmentGroup AS ESTG
		INNER JOIN dbo.[Group] AS GP ON GP.Id = ESTG.GroupId
                INNER JOIN dbo.Establishment AS EST ON EST.EstablishmentGroupId = ESTG.Id
                LEFT OUTER JOIN dbo.SeenClient AS SC ON SC.Id = ESTG.SeenClientId
        WHERE   ESTG.GroupId = @MerchantKey AND ESTG.SeenClientId IS NOT NULL AND  ESTG.IsDeleted = 0 AND EST.IsDeleted = 0
                AND ESTG.EstablishmentGroupId IS NOT NULL
        GROUP BY  
				ISNULL(SC.SeenClientTitle, '') ,
                EST.Id ,
				EST.EstablishmentName,
                ESTG.SeenClientId,
				GP.ContactId,
				ESTG.ContactQuestion
        ORDER BY EST.Id ASC
		

    END;
