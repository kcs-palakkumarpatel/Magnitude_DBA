CREATE VIEW dbo.PB_VW_Toyota_Contacts AS

SELECT P.Id,'Added' AS [Status],P.IsDeleted,P.ContactGropName,P.CreatedOn AS [Date],P.[User],P.Usermobile,P.Useremail,[Name],[Surname],[Mobile Phone],[Email],[Company Name],[Position],[Area],[Company Physical Address],[Home Phone],[Work Phone],[CustomerNumber],[Title],[Department],[Employee ID],[Address],
CONCAT(P.Name,P.[Mobile Phone],P.Email,P.[Company Name],P.CustomerNumber) AS UniqueId
From(
SELECT cm.Id,cd.Detail AS Answer,cq.QuestionTitle AS Question,cg.ContactGropName,cm.CreatedOn,cm.IsDeleted,cm.CreatedBy,a.Name AS [User],a.Mobile AS Usermobile,a.Email AS Useremail FROM dbo.ContactMaster cm
LEFT JOIN dbo.ContactDetails cd ON cm.Id=cd.ContactMasterId
LEFT JOIN dbo.ContactQuestions cq ON cq.Id=cd.ContactQuestionId AND cq.Id IN (3071,3072,3073,3074,3075,3098,3099,3123,3257,3258,3280,3293,3294,3295,3296)
LEFT JOIN dbo.ContactGroupRelation gr ON cd.ContactMasterId=gr.ContactMasterId
LEFT JOIN dbo.ContactGroup cg ON cg.Id=gr.ContactGroupId 
LEFT JOIN dbo.AppUser a ON a.Id=cm.CreatedBy
WHERE cm.ContactId=485
)S PIVOT(Max(Answer) FOR  Question In ([Name],[Surname],[Mobile Phone],[Email],[Company Name],[Position],[Area],[Company Physical Address],[Home Phone],[Work Phone],[CustomerNumber],[Title],[Department],[Employee ID],[Address]))P 

UNION ALL

SELECT P.Id,'Deleted' AS [Status],P.IsDeleted,P.ContactGropName,P.CreatedOn AS [Date],P.[User],P.Usermobile,P.Useremail,[Name],[Surname],[Mobile Phone],[Email],[Company Name],[Position],[Area],[Company Physical Address],[Home Phone],[Work Phone],[CustomerNumber],[Title],[Department],[Employee ID],[Address],
CONCAT(P.Name,P.[Mobile Phone],P.Email,P.[Company Name],P.CustomerNumber) AS UniqueId
From(
SELECT cm.Id,cd.Detail AS Answer,cq.QuestionTitle AS Question,cg.ContactGropName,cm.CreatedOn,cm.IsDeleted,cm.CreatedBy,a.Name AS [User],a.Mobile AS Usermobile,a.Email AS Useremail FROM dbo.ContactMaster cm
LEFT JOIN dbo.ContactDetails cd ON cm.Id=cd.ContactMasterId
LEFT JOIN dbo.ContactQuestions cq ON cq.Id=cd.ContactQuestionId AND cq.Id IN (3071,3072,3073,3074,3075,3098,3099,3123,3257,3258,3280,3293,3294,3295,3296)
LEFT JOIN dbo.ContactGroupRelation gr ON cd.ContactMasterId=gr.ContactMasterId
LEFT JOIN dbo.ContactGroup cg ON cg.Id=gr.ContactGroupId 
LEFT JOIN dbo.AppUser a ON a.Id=cm.DeletedBy
WHERE cm.ContactId=485 AND cm.IsDeleted=1
)S PIVOT(Max(Answer) FOR  Question In ([Name],[Surname],[Mobile Phone],[Email],[Company Name],[Position],[Area],[Company Physical Address],[Home Phone],[Work Phone],[CustomerNumber],[Title],[Department],[Employee ID],[Address]))P 

UNION ALL

SELECT P.Id,'Edited' AS [Status],P.IsDeleted,P.ContactGropName,P.CreatedOn AS [Date],P.[User],P.Usermobile,P.Useremail,[Name],[Surname],[Mobile Phone],[Email],[Company Name],[Position],[Area],[Company Physical Address],[Home Phone],[Work Phone],[CustomerNumber],[Title],[Department],[Employee ID],[Address],
CONCAT(P.Name,P.[Mobile Phone],P.Email,P.[Company Name],P.CustomerNumber) AS UniqueId
From(
SELECT cm.Id,cd.Detail AS Answer,cq.QuestionTitle AS Question,cg.ContactGropName,cm.CreatedOn,cm.IsDeleted,cm.CreatedBy,a.Name AS [User],a.Mobile AS Usermobile,a.Email AS Useremail FROM dbo.ContactMaster cm
LEFT JOIN dbo.ContactDetails cd ON cm.Id=cd.ContactMasterId
LEFT JOIN dbo.ContactQuestions cq ON cq.Id=cd.ContactQuestionId AND cq.Id IN (3071,3072,3073,3074,3075,3098,3099,3123,3257,3258,3280,3293,3294,3295,3296)
LEFT JOIN dbo.ContactGroupRelation gr ON cd.ContactMasterId=gr.ContactMasterId
LEFT JOIN dbo.ContactGroup cg ON cg.Id=gr.ContactGroupId 
LEFT JOIN dbo.AppUser a ON a.Id=cm.UpdatedBy
WHERE cm.ContactId=485 AND cm.UpdatedOn IS NOT NULL
)S PIVOT(Max(Answer) FOR  Question In ([Name],[Surname],[Mobile Phone],[Email],[Company Name],[Position],[Area],[Company Physical Address],[Home Phone],[Work Phone],[CustomerNumber],[Title],[Department],[Employee ID],[Address]))P 


