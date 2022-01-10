-- =============================================
-- Author:			Developer D3
-- Create date:	30-May-2017
-- Description:	Get Contact Data from for Web API Using MerchantKey(GroupId)
-- Call:					dbo.APIGetContactMasterDataByMerchantKey 551, '01-Oct-2016',  '10-Oct-2021'
-- =============================================
CREATE PROCEDURE dbo.APIGetContactMasterDataByMerchantKey
    (
      @MerchantKey BIGINT = 0 ,
      @FromDate NVARCHAR(50) = NULL ,
      @ToDate NVARCHAR(50) = NULL
	)
AS
    BEGIN
        SET NOCOUNT OFF;
		DECLARE @ContactId BIGINT
		SELECT TOP 1 @ContactId = ContactId FROM dbo.ContactMaster WHERE GroupId=@MerchantKey AND IsDeleted = 0 

	SELECT  ISNULL(CM.ContactId, 0) AS ContactId ,
                ISNULL(CM.GroupId, 0) AS GroupId ,
                ISNULL(CC.ContactTitle, '') AS ContactFormTitle ,
                ISNULL(CM.Remarks, '') AS Remarks ,
                --ISNULL(AU.Name, '') AS CreatedBy ,
                ISNULL(CONVERT(NVARCHAR(30), CM.CreatedOn, 120), '') AS CreatedDate ,
                ISNULL(CAST(CM.Id AS VARCHAR(50)), '') AS ContactMasterId ,
				CAST(0 AS BIT)     AS IsGroupContact ,
               0 AS ContactGroupId ,
               '' AS ContactGroupName 
        FROM    dbo.ContactMaster AS CM
		 INNER JOIN dbo.Contact AS CC ON CC.Id = CM.ContactId
		   --INNER JOIN dbo.AppUser AS AU ON AU.Id = CM.CreatedBy
        WHERE   CM.GroupId = @MerchantKey
                AND CM.IsDeleted = 0
				AND CM.CreatedOn BETWEEN @FromDate AND @ToDate
				UNION ALL
					SELECT  @ContactId AS ContactId ,
                ISNULL(CG.GroupId, 0) AS GroupId ,
                ISNULL(CC.ContactTitle, '') AS ContactFormTitle ,
                ISNULL(CG.[Description], '') AS Remarks ,
                --ISNULL(AU.Name, '') AS CreatedBy ,
                ISNULL(CONVERT(NVARCHAR(30), CG.CreatedOn, 120), '') AS CreatedDate ,
               ISNULL(SUBSTRING((SELECT ',' + CAST(ContactMasterId AS VARCHAR(50)) FROM ContactGroupRelation WHERE ContactGroupId = CG.Id AND IsDeleted = 0 FOR XML PATH('') ), 2, 1000000), '0') AS ContactMasterId ,
				CAST(1 AS BIT)     AS IsGroupContact ,
                ISNULL(CG.Id, 0) AS ContactGroupId ,
               ISNULL(CG.ContactGropName, '') AS ContactGroupName 
        FROM    dbo.ContactGroup AS CG
		 INNER JOIN dbo.Contact AS CC ON CC.Id = @ContactId
		   --INNER JOIN dbo.AppUser AS AU ON AU.Id = CG.CreatedBy	
        WHERE   CG.GroupId = @MerchantKey
                AND CG.IsDeleted = 0
				AND CG.CreatedOn BETWEEN @FromDate AND @ToDate;
			
    END;

