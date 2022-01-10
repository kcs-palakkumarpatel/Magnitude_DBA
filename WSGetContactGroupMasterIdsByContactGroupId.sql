-- =============================================
-- Author:		<Author,,GD>
-- Create date: <Create Date,, Jun 2015>
-- Description:	<Description,,>
-- Call SP:		WSGetContactGroupMasterIdsByContactGroupId 5225
-- =============================================
CREATE PROCEDURE [dbo].[WSGetContactGroupMasterIdsByContactGroupId]
    @ContactGroupId BIGINT
AS 
    BEGIN
        DECLARE @ContactMasterId BIGINT ,
            @GroupName NVARCHAR(50)
        SELECT  ISNULL(CGR.ContactMasterId, 0)
        FROM   dbo.ContactGroupRelation as CGR
        WHERE  
                 CGR.ContactGroupId = @ContactGroupId

	
 END