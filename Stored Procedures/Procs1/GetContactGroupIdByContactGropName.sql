-- =============================================
-- Author:			Sunil Vaghasiya
-- Create date:	23-12-2016
-- Description:	Get ContactGroup Id By ContactGropName
-- Call:					GetContactGroupIdByContactGropName 'ITSD GoMobile Team'
-- =============================================
CREATE PROCEDURE [dbo].[GetContactGroupIdByContactGropName]
	@ContactGropName  NVARCHAR(500) = NULL
AS
BEGIN
	SET NOCOUNT OFF;

	DECLARE @ContactMasterIdList NVARCHAR(2000) = '';
	DECLARE @GroupId BIGINT = 0;

		SELECT @GroupId =  Id FROM dbo.ContactGroup WHERE ContactGropName = @ContactGropName AND IsDeleted = 0
	SELECT @ContactMasterIdList  = COALESCE(@ContactMasterIdList + ',' , '') + CAST( ContactMasterId  AS NVARCHAR(100)) FROM dbo.ContactGroupRelation WHERE ContactGroupId = @GroupId AND IsDeleted = 0

	SELECT  @GroupId AS ContactGroupId , @ContactMasterIdList AS ContactMasterIdList
   
END