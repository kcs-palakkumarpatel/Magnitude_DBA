-- =============================================
-- Author:			Developer D3
-- Create date:	30-09-2016
-- Description:	Get App Users List for Web API Using MerchantKey
-- Call:					dbo.APIGetUsersByMerchantKey 284
-- =============================================
CREATE PROCEDURE [dbo].[APIGetUsersByMerchantKey]
    (
      @MerchantKey BIGINT = 0
	)
AS
    BEGIN
        SET NOCOUNT OFF;

        SELECT  Id AS UserId ,
                Name AS UserName ,
                Mobile AS MobileNo ,
                CASE WHEN ISNULL(IsAreaManager, 0) = 0 THEN 'No'
                     ELSE 'Yes'
                END AS AreaManager
        FROM    dbo.AppUser
        WHERE   GroupId = @MerchantKey
                AND IsActive = 1
                AND IsDeleted = 0;


    END;