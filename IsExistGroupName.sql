--EXEC IsExistGroupName "Pal18test,test5"
CREATE PROCEDURE [dbo].[IsExistGroupName]
@GroupName NVARCHAR(MAX)
AS
SELECT DISTINCT(GroupName)
FROM dbo.[Group]
WHERE GroupName IN (SELECT data FROM split(@GroupName,',')) AND ISNULL(IsDeleted,0) = 0
