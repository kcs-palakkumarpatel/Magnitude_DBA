-- =============================================
-- Author:			Developer D3
-- Create date:	30-May-2017
-- Description:	Get Contact Data from for Web API Using MerchantKey(GroupId)
-- Call:	dbo.APIGetDefaultContactId 8273,4266
-- =============================================
CREATE PROCEDURE [dbo].[APIGetDefaultContactId]
    (
      @ActivityId BIGINT ,
	  @AppUserID BIGINT
	)
AS
    BEGIN
	DECLARE @ContactID BIGINT = 0;
	DECLARE @isGroup INT = 0;

       IF EXISTS
        (
            SELECT *
            FROM dbo.DefaultContact
            WHERE 
			 ActivityId = @ActivityId
			AND AppUserId = @AppUserID
			AND IsDeleted = 0
        )
		BEGIN
		Select @ContactID = ContactId, @isGroup = IsGroup from DefaultContact  WHERE 			
			 ActivityId = @ActivityId
			AND AppUserId = @AppUserID
			AND IsDeleted = 0
		END			

		SELECT @ContactID as ContactId, @isGroup as isGroup;
    END;

