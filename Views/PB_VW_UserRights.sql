CREATE VIEW PB_VW_UserRights AS

SELECT au.Id,au.Name,au.UserName,g.GroupName,e.EstablishmentName,eg.EstablishmentGroupName FROM 
dbo.AppUser au
INNER JOIN dbo.AppUserEstablishment aue ON aue.AppUserId = au.Id AND aue.IsDeleted=0
INNER JOIN dbo.Establishment e ON e.Id = aue.EstablishmentId
INNER JOIN dbo.EstablishmentGroup eg ON eg.Id = e.EstablishmentGroupId AND eg.EstablishmentGroupName NOT LIKE '%tell us%'
INNER JOIN dbo.[Group] g ON g.Id = au.GroupId AND g.Id IN (462,437,450,463,497,477,505,432,509,515,400,537,355,296,416,353,373,329,484,514,27,378,413,414,438,343,32,234,196,366,392,422)

