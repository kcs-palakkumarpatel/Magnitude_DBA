-- =============================================
-- Author:			Developer D3
-- Create date: 31-May-2017
-- Description:	Insert group users in child table "[SeenClientAnswerChild]"
-- Call SP    :	APIGetContactMasterIdsByContactGroupId 1490
-- =============================================
CREATE PROCEDURE [dbo].[APIGetContactMasterIdsByContactGroupId]
    @ContactGroupId BIGINT 
AS
    BEGIN
		 Select ContactMasterId from ContactGroupRelation where ContactGroupId = @ContactGroupId and IsDeleted = 0;
    END;
