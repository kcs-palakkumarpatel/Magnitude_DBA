CREATE VIEW PB_VW_ManagerRights AS

select amr.Id,amr.UserId,e.EstablishmentName,au.Name 
FROM dbo.AppManagerUserRights amr
INNER JOIN dbo.AppUser au ON au.Id = amr.ManagerUserId
INNER JOIN dbo.Establishment e ON e.Id = amr.EstablishmentId AND e.EstablishmentName NOT LIKE '%tell us%'
INNER JOIN dbo.[Group] g ON g.Id = au.GroupId AND g.Id IN (462,437,450,463,497,477,505,432,509,515,400,537,355,296,416,353,373,329,484,514,27,378,413,414,438,343,32,234,196,366,392,422)
WHERE amr.IsDeleted=0

