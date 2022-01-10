-- =============================================
-- Author:		<Author,,GD>
-- Create date: <Create Date,,22 Jun 2015>
-- Description:	<Description,,>
-- Call SP:		WSGetExistingContactByContactGroupId 245
-- =============================================
CREATE PROCEDURE [dbo].[WSGetExistingContactByContactGroupId]
    @ContactGroupId BIGINT
AS 
     BEGIN
        SELECT  ContactMasterId AS Id ,
                dbo.ConcateString('ContactSummary', ContactMasterId) AS Name
        FROM    dbo.ContactGroupRelation INNER JOIN dbo.ContactMaster ON ContactMaster.Id = ContactGroupRelation.ContactMasterId AND ContactMaster.IsDeleted = 0
        WHERE   ContactGroupRelation.IsDeleted = 0
                AND ContactGroupId = @ContactGroupId
		ORDER BY Name ASC
    END
