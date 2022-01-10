-- =============================================
-- Author:			Developer D3
-- Create date: 31-May-2017
-- Description:	Insert group users in child table "[SeenClientAnswerChild]"
-- Call SP    :	APIGetContactMasterIdsByContactGroupId 1490
-- =============================================
CREATE PROCEDURE [dbo].[APIGetSeenClientIdByEstablishmentId]
    @ActivityId BIGINT 
AS
    BEGIN
		 Select SeenClientId from EstablishmentGroup where id  = @ActivityId and IsDeleted = 0;
    END;
