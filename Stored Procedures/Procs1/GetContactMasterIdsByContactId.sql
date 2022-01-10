-- =============================================
-- Author:		<Author,,GD>
-- Create date: <Create Date,, Jun 2015>
-- Description:	<Description,,>
-- Call SP:		WSGetContactMasterIdByContactId 36
-- =============================================
CREATE PROCEDURE [dbo].[GetContactMasterIdsByContactId]
    @ContactId BIGINT
AS 
    BEGIN
        SELECT CM.Id as ContactMasterId
        FROM   dbo.ContactMaster as CM
        WHERE  
                 CM.ContactId = @ContactId
				 and cm.IsDeleted = 0

	
 END