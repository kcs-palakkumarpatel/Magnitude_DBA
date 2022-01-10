
-- =============================================
-- Author:			Developer D3
-- Create date:	30-09-2016
-- Description:	Get Get Establishment List for Web API Using MerchantKey
-- Call:					dbo.APIGetEstablishmentsByMerchantKey 284
-- =============================================
CREATE PROCEDURE [dbo].[APIGetEstablishmentsByMerchantKey]
    (
      @MerchantKey BIGINT = 0
	)
AS
    BEGIN
        SET NOCOUNT OFF;

        SELECT  Id AS EstablishmentId ,
                ISNULL(EstablishmentName, '') AS EstablishmentName ,
                EstablishmentGroupId AS EstablishmentGroupId
        FROM    dbo.Establishment
        WHERE   GroupId = @MerchantKey
                AND IsDeleted = 0;
    
    END;