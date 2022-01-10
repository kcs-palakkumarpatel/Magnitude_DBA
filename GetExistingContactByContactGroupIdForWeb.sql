-- =============================================
-- Author:		Disha Patel
-- Create date: 13-OCT-2016
-- Description:	Get Existing Contacts by contactgroupid for Webapp with ContactDetails
-- Call SP:		GetExistingContactByContactGroupIdForWeb
-- =============================================
CREATE PROCEDURE [dbo].[GetExistingContactByContactGroupIdForWeb] @ContactGroupId BIGINT
AS
BEGIN
    SET NOCOUNT ON;
    SELECT ContactMasterId AS Id,
           dbo.ConcateString('ContactDetails', ContactMasterId) AS Name
    FROM dbo.ContactGroupRelation WITH
        (NOLOCK)
        INNER JOIN dbo.ContactMaster WITH
        (NOLOCK)
            ON ContactMaster.Id = ContactGroupRelation.ContactMasterId
               AND ContactMaster.IsDeleted = 0
    WHERE ContactGroupRelation.IsDeleted = 0
          AND ContactGroupId = @ContactGroupId;
END;
