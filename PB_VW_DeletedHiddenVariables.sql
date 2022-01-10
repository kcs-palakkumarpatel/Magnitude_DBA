CREATE VIEW PB_VW_DeletedHiddenVariables AS 

SELECT DISTINCT g.GroupName,eg.EstablishmentGroupName,q.Id,REPLACE(q.QuestionTitle,'=','-') AS QuestionTitle,DATEADD(MINUTE,120,q.DeletedOn) AS DeletedOn,CONCAT(u.Name,' ',u.SurName) AS DeletedBy,q.IsDeleted,q.IsActive,DATEADD(MINUTE,120,q.UpdatedOn) AS UpdatedOn,CONCAT(u1.Name,' ',u1.SurName) AS UpdatedBy,'Capture' AS Formtype
FROM 
dbo.[Group] g
inner join EstablishmentGroup EG on G.id=EG.groupid AND g.Id IN (462,437,450,463,497,477,505,432,509,515,400,537,355,296,416,353,373,329,484,514,27,378,413,414,438,343,32,234,196,392,422,366)
inner join Establishment E on  E.EstablishmentGroupId=EG.Id 
inner join SeenClientAnswerMaster AM on AM.EstablishmentId=E.id 
inner join [SeenClientAnswers] A on A.SeenclientAnswerMasterId=AM.id
INNER JOIN SeenClientQuestions Q on Q.id=A.QuestionId
LEFT JOIN dbo.[User] u ON u.Id=q.DeletedBy
LEFT JOIN dbo.[User] u1 ON u1.Id=q.UpdatedBy
WHERE q.IsDeleted=1 OR q.IsActive=0 

UNION ALL

SELECT DISTINCT g.GroupName,eg.EstablishmentGroupName,q.Id,REPLACE(q.QuestionTitle,'=','-') AS QuestionTitle,DATEADD(MINUTE,120,q.DeletedOn) AS DeletedOn,CONCAT(u.Name,' ',u.SurName) AS DeletedBy,q.IsDeleted,q.IsActive,DATEADD(MINUTE,120,q.UpdatedOn) AS UpdatedOn,CONCAT(u1.Name,' ',u1.SurName) AS UpdatedBy,'Response' AS Formtype
FROM 
dbo.[Group] g
inner join EstablishmentGroup EG on G.id=EG.groupid AND g.Id IN (462,437,450,463,497,477,505,432,509,515,400,537,355,296,416,353,373,329,484,514,27,378,413,414,438,343,32,234,196,392,422,366)
inner join Establishment E on  E.EstablishmentGroupId=EG.Id 
inner join answermaster AM on AM.EstablishmentId=E.id 
inner join Answers A on A.AnswerMasterId=AM.id 
INNER JOIN Questions Q on Q.id=A.QuestionId
LEFT JOIN dbo.[User] u ON u.Id=q.DeletedBy
LEFT JOIN dbo.[User] u1 ON u1.Id=q.UpdatedBy
WHERE q.IsDeleted=1 OR q.IsActive=0

