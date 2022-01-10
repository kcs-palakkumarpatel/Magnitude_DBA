-- =============================================
-- Author:			Developer D3
-- Create date:	29-09-2016
-- Description:	Get Contact Database from for Web API Using MerchantKey(GroupId)
-- Call:					dbo.APIGetContactDatabaseByMerchantKey 293
-- =============================================
CREATE PROCEDURE [dbo].[APIGetContactDatabaseByMerchantKey]
    (
      @MerchantKey BIGINT = 0
	)
AS
    BEGIN
        SET NOCOUNT OFF;

        SELECT  CF.Id AS ContactId ,
                ISNULL(CF.ContactTitle, '') AS ContactTitle
        FROM    [dbo].[Group] AS GP
                LEFT OUTER JOIN dbo.Contact AS CF ON CF.Id = GP.ContactId
                                                     AND CF.IsDeleted = 0
        WHERE   GP.Id = @MerchantKey;

    END;