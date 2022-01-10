
CREATE PROCEDURE [dbo].[getGroupIdByGroupName]
	@GroupName NVARCHAR(500)
AS

SELECT Id FROM dbo.ContactGroup WHERE  ContactGropName=@GroupName