-- =============================================
-- Author:			Developer D3
-- Create date:	10-10-2016
-- Description:	Check Duplicate Contact from for Web API Using MerchantKey(GroupId)
-- Call:					dbo.APICheckContactMasterExists
-- =============================================
CREATE PROCEDURE [dbo].[APICheckContactMasterExists]
    @MerchantKey BIGINT ,
    @ContactMasterId BIGINT ,
    @EmailId NVARCHAR(100) ,
    @MobileNo NVARCHAR(50)
AS
    BEGIN
        IF ( @EmailId = '' )
            BEGIN
                SET @EmailId = 0;
            END;
        IF ( @MobileNo = '' )
            BEGIN
                SET @MobileNo = 0;
            END;

			SELECT TT.ContactMasterId FROM (
	
        SELECT  CM.Id AS ContactMasterId ,
                dbo.ConcateString('DuplicateContact', CM.Id) AS Detail ,
                ISNULL(( SELECT CASE Detail
                                  WHEN '' THEN '0'
                                  ELSE Detail
                                END
                         FROM   dbo.ContactDetails
                         WHERE  ContactMasterId = CM.Id
                                AND QuestionTypeId = 10
                       ), '') AS Email ,
                ISNULL(( SELECT CASE Detail
                                  WHEN '' THEN '0'
                                  ELSE Detail
                                END
                         FROM   dbo.ContactDetails
                         WHERE  ContactMasterId = CM.Id
                                AND QuestionTypeId = 11
                       ), '') AS Mobile
        FROM    dbo.ContactDetails AS CD
                INNER JOIN dbo.ContactMaster AS CM ON CD.ContactMasterId = CM.Id
        WHERE   CD.QuestionTypeId IN ( 10, 11 )
                AND GroupId = @MerchantKey
                AND CM.Id <> @ContactMasterId
                AND ( Detail = @MobileNo
                      OR Detail = @EmailId
                    )
                AND CM.IsDeleted = 0
                AND CD.IsDeleted = 0
        GROUP BY CM.Id ) AS TT

    END;