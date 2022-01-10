-- =============================================
-- Author:		<Author,,GD>
-- Create date: <Create Date,, Jun 2015>
-- Description:	<Description,,>
-- Call SP:		WSGetContactGroupMasterIdsByContactGroupId 5225
-- =============================================
CREATE PROCEDURE [dbo].[WSGetContactMasterIdByContactId]
    @ContactId BIGINT
AS 
    BEGIN
        SELECT CM.Id as ContactMasterId
        FROM   dbo.ContactMaster as CM
        WHERE  
                 CM.ContactId = @ContactId
				 and cm.IsDeleted = 0

	
 END