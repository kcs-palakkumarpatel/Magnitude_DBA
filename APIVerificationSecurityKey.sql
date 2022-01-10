-- =============================================
-- Author:			Developer D3
-- Create date:	04-09-2016
-- Description:	Check Verification Client Group Details From Group Table  for Web API Using SecurityKey
-- Call:					dbo.APIVerificationSecurityKey 70,'CAR SERVICE CITY','01-15-2016','NzBfQ0FSIFNFUlZJQ0UgQ0lUWV8wMS0xNS0yMDE2'
-- =============================================
CREATE PROCEDURE [dbo].[APIVerificationSecurityKey]
    (
      @groupId NVARCHAR(50) = NULL ,
      @groupName NVARCHAR(200) = NULL ,
      @groupCreatedOnDate NVARCHAR(50) = NULL ,
      @securityKey NVARCHAR(500) = NULL
	)
AS
    BEGIN
        SET NOCOUNT OFF;

        SELECT TOP 1
                Id
        FROM    dbo.[Group]
        WHERE   Id = CAST(@groupId AS BIGINT)
                AND GroupName = @groupName
                AND CONVERT(VARCHAR(20),CreatedOn, 110) = @groupCreatedOnDate
                AND SecurityKey = @securityKey;
				SET NOCOUNT ON;
    END;
