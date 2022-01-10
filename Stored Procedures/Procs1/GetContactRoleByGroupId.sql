-- =============================================
-- Author:		<Vasu Patel>
-- Create date: <14 Oct 2016>
-- Description:	<Get Contact Role By GroupId>
-- =============================================
CREATE PROCEDURE [dbo].[GetContactRoleByGroupId] 
	@GroupId BIGINT
AS
BEGIN
    SELECT  Id ,
            RoleName
    FROM    dbo.ContactRole
    WHERE   GroupId = @GroupId AND IsDeleted = 0;
END