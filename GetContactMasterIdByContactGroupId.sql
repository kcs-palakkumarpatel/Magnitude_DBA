-- =============================================
-- Author:			Sunil Vaghasiya
-- Create date:	07-June-2017
-- Description:	Get ContactMasterId list By ContactGroupId
--	Call:					dbo.GetContactMasterIdByContactGroupId
-- =============================================
CREATE PROCEDURE [dbo].[GetContactMasterIdByContactGroupId]
    @ContactGroupId BIGINT
AS
BEGIN
DECLARE @TEMP TABLE ( ContactGroupId BIGINT NULL,  ContactMasterId BIGINT  NULL )
	IF EXISTS( SELECT * FROM dbo.ContactGroup WHERE Id=@ContactGroupId AND IsDeleted = 0 )
	BEGIN
	INSERT INTO @TEMP
	        ( ContactGroupId, ContactMasterId )
	    SELECT  ContactGroupId, ContactMasterId  FROM dbo.ContactGroupRelation WHERE ContactGroupId=@ContactGroupId AND IsDeleted = 0
	END

	SELECT * FROM @TEMP
END
