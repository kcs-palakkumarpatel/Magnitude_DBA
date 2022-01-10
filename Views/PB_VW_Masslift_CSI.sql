CREATE VIEW PB_VW_Masslift_CSI AS

/*Submitted Form*/
SELECT K.EstablishmentName,
	   IIF(K.[Masslift Branch] IS NULL OR K.[Masslift Branch]='' OR K.[Masslift Branch]='-- Select --','N/A',K.[Masslift Branch]) AS Branch,
       --K.CapturedDate,
	   CAST(K.CapturedDate AS DATE) AS CapturedDate,
       K.ReferenceNo,
       K.IsPositive,
       K.Status,
       K.UserName,
       K.CustomerCompany,
       K.CustomerEmail,
       K.CustomerMobile,
       K.CustomerName,
       J.RepeatCount,
       IIF(K.Company='',K.CustomerCompany,K.Company) AS Company,
       K.[WIP Number],
	   REPLACE(K.[Work Completed],'-- Select --','N/A') AS [Work Completed],
       IIF(K.Type IS NULL OR K.Type='','N/A',K.Type) AS Type,
	   K.[Any Masslift specific concerns?],
	   K.[ML Concern category],
	   K.[ML Concerned comments],
       J.[Employee / Supplier Name],
       REPLACE(ISNULL(REPLACE(J.[Department],'','N/A'),'N/A'),'-- Select --','N/A') AS [Department],
       REPLACE(J.Rating,'-- Select --','') AS Rating,
       J.[General Comments],
	   J.[Any person specific concerns],
	   IIF(J.[Emp Concern category]='Other',J.[If Other, please specify],J.[Emp Concern category]) AS [Emp Concern category],
	   --J.[If Other, please specify],
	   J.[Emp Concerned comments],
	   K.[Machine Serial Number],
	   0 AS IsDraft,
	   IIF(K.[Date Capturing for] IS NULL,CAST(K.CapturedDate AS DATE),K.[Date Capturing for]) AS [Date Capturing for],
	   K.[Preferred Calling Time],
	   K.[Preferred Communication Type],
	   iif(K.[Call Status] IS NULL,'Call Answered',K.[Call Status]) AS [Call Status],
	   K.[If other please state] FROM 
(
SELECT EstablishmentName,CapturedDate,ReferenceNo,IsPositive,Status,UserName,ISNULL(CustomerCompany,'N/A') AS CustomerCompany,CustomerEmail,CustomerMobile,CustomerName,RepeatCount,P.[Preferred Calling Time],P.[Preferred Communication Type],
[Company],[WIP Number],[Work Completed],[Type],[Employee / Supplier Name],[Masslift Branch],[Department],[Rating],[General Comments],[Machine Serial Number (please note to press enter when on the web app to lock in your entry)] AS [Machine Serial Number],[Masslift Department],[Any Masslift specific concerns?],[ML Concern category],[ML Concerned comments],[Any person specific concerns],[Emp Concern category],[If Other, please specify],[Emp Concerned comments],[Date Capturing for],[Call Status],[If other please state]
From(
SELECT E.EstablishmentName,dateadd(MINUTE,AM.TimeOffSet,AM.CreatedOn) as CapturedDate,AM.id as ReferenceNo,
AM.IsPositive,AM.IsResolved as Status,
A.Detail as Answer,
CASE WHEN Q.Questiontitle='Employee department' THEN 'Department' 
	 WHEN q.id=47573 THEN 'ML Concern category' 
	 WHEN q.id=81210 THEN 'ML Concern category'
	 WHEN q.id=47574 THEN 'ML Concerned comments'
	 WHEN q.id=47576 THEN 'Emp Concern category'
	 WHEN q.id=57648 THEN 'Emp Concern category'
	 WHEN q.Id=76105 THEN 'Emp Concern category'
	 WHEN q.Id=81211 THEN 'Emp Concern category'
	 WHEN q.id=47577 THEN 'Emp Concerned comments'
	 ELSE Q.QuestionTitle
	 END AS Question,
U.id as UserId, u.name as UserName,A.RepeatCount,
AM.Longitude ,AM.Latitude,
(SELECT TOP 1 cd.Detail FROM ContactDetails CD WHERE   CD.ContactMasterId=(case when AM.IsSubmittedForGroup=1 then SAC.ContactMasterId  else AM.ContactMasterId end) and CD.IsDeleted = 0 and CD.Detail<>'' 
and CD.contactQuestionId=4623
) as [Preferred Calling Time],
(SELECT TOP 1 cd.Detail FROM ContactDetails CD WHERE   CD.ContactMasterId=(case when AM.IsSubmittedForGroup=1 then SAC.ContactMasterId  else AM.ContactMasterId end) and CD.IsDeleted = 0 and CD.Detail<>'' 
and CD.contactQuestionId=4627
) as [Preferred Communication Type],
(SELECT TOP 1 cd.Detail FROM ContactDetails CD WHERE   CD.ContactMasterId=(case when AM.IsSubmittedForGroup=1 then SAC.ContactMasterId  else AM.ContactMasterId end) and CD.IsDeleted = 0 and CD.Detail<>'' 
and CD.contactQuestionId=2843
) as CustomerCompany,
(SELECT TOP 1 cd.Detail FROM ContactDetails CD WHERE   CD.ContactMasterId=(case when AM.IsSubmittedForGroup=1 then SAC.ContactMasterId  else AM.ContactMasterId end) and CD.IsDeleted = 0 and CD.Detail<>'' 
and CD.contactQuestionId=2842
) as CustomerEmail,
(SELECT TOP 1 cd.Detail FROM ContactDetails CD WHERE   CD.ContactMasterId=(case when AM.IsSubmittedForGroup=1 then SAC.ContactMasterId  else AM.ContactMasterId end) and CD.IsDeleted = 0 and CD.Detail<>'' 
and CD.contactQuestionId=2841
) as CustomerMobile,
(SELECT TOP 1 cd.Detail FROM ContactDetails CD WHERE   CD.ContactMasterId=(case when AM.IsSubmittedForGroup=1 then SAC.ContactMasterId  else AM.ContactMasterId end) and CD.IsDeleted = 0 and CD.Detail<>'' 
and CD.contactQuestionId=2839
)+' '+
(SELECT TOP 1 cd.Detail FROM ContactDetails CD WHERE   CD.ContactMasterId=(case when AM.IsSubmittedForGroup=1 then SAC.ContactMasterId  else AM.ContactMasterId end) and CD.IsDeleted = 0 and CD.Detail<>'' 
and CD.contactQuestionId=2840
) as CustomerName
from dbo.[Group] G
inner join EstablishmentGroup EG on G.id=EG.groupid and g.id = 463 and eg.id=5193 
inner join Establishment E on  E.EstablishmentGroupId=EG.Id 
inner join SeenClientAnswerMaster AM on AM.EstablishmentId=E.id ANd (AM.IsDeleted=0 or AM.IsDeleted=null)
inner join [SeenClientAnswers] A on A.SeenclientAnswerMasterId=AM.id 
inner join SeenClientQuestions Q on Q.id=A.QuestionId and q.id in (40976,40977,40978,40981,41352,42068,42069,45429,45430,45432,45533,45647,47580,47572,47573,47574,47575,47576,47577,57648,57653,49711,74284,76099,76106,76100,76101,76102,76105,76129,76131,78797,81210,81211)
left outer join dbo.[Appuser] u on u.id=AM.CreatedBy
left outer join SeenClientAnswerChild SAC on AM.id=SAC.SeenClientAnswerMasterId WHERE A.RepeatCount<>0
)S
pivot(
Max(Answer)
For  Question In (
[Company],[WIP Number],[Type],[Employee / Supplier Name],[Masslift Branch],[Department],[Rating],[General Comments],[Machine Serial Number (please note to press enter when on the web app to lock in your entry)],[Work Completed],[Masslift Department],[Any Masslift specific concerns?],[ML Concern category],[ML Concerned comments],[Any person specific concerns],[Emp Concern category],[If Other, please specify],[Emp Concerned comments],[Date Capturing for],[Call Status],[If other please state]
))P
)J
FULL JOIN 
(
SELECT EstablishmentName,CapturedDate,ReferenceNo,IsPositive,Status,UserName,ISNULL(CustomerCompany,'N/A') AS CustomerCompany,CustomerEmail,CustomerMobile,CustomerName,RepeatCount,P.[Preferred Calling Time],P.[Preferred Communication Type],
[Company],[WIP Number],[Work Completed],[Type],[Employee / Supplier Name],[Masslift Branch],[Department],[Rating],[General Comments],[Machine Serial Number (please note to press enter when on the web app to lock in your entry)] AS [Machine Serial Number],[Masslift Department],[Any Masslift specific concerns?],[ML Concern category],[ML Concerned comments],[Any person specific concerns],[Emp Concern category],[If Other, please specify],[Emp Concerned comments],[Date Capturing for],[Call Status],[If other please state]
From(
SELECT E.EstablishmentName,dateadd(MINUTE,AM.TimeOffSet,AM.CreatedOn) as CapturedDate,AM.id as ReferenceNo,
AM.IsPositive,AM.IsResolved as Status,
A.Detail as Answer,
CASE WHEN Q.Questiontitle='Employee department' THEN 'Department' 
	 WHEN q.id=47573 THEN 'ML Concern category' 
	 WHEN q.id=81210 THEN 'ML Concern category'
	 WHEN q.id=47574 THEN 'ML Concerned comments'
	 WHEN q.id=47576 THEN 'Emp Concern category' 
	 WHEN q.id=57648 THEN 'Emp Concern category'
	 WHEN q.Id=76105 THEN 'Emp Concern category'
	 WHEN q.Id=81211 THEN 'Emp Concern category'
	 WHEN q.id=47577 THEN 'Emp Concerned comments'
	 ELSE Q.QuestionTitle
	 END AS Question,
U.id as UserId, u.name as UserName,A.RepeatCount,
AM.Longitude ,AM.Latitude,
(SELECT TOP 1 cd.Detail FROM ContactDetails CD WHERE   CD.ContactMasterId=(case when AM.IsSubmittedForGroup=1 then SAC.ContactMasterId  else AM.ContactMasterId end) and CD.IsDeleted = 0 and CD.Detail<>'' 
and CD.contactQuestionId=4623
) as [Preferred Calling Time],
(SELECT TOP 1 cd.Detail FROM ContactDetails CD WHERE   CD.ContactMasterId=(case when AM.IsSubmittedForGroup=1 then SAC.ContactMasterId  else AM.ContactMasterId end) and CD.IsDeleted = 0 and CD.Detail<>'' 
and CD.contactQuestionId=4627
) as [Preferred Communication Type],
(SELECT TOP 1 cd.Detail FROM ContactDetails CD WHERE   CD.ContactMasterId=(case when AM.IsSubmittedForGroup=1 then SAC.ContactMasterId  else AM.ContactMasterId end) and CD.IsDeleted = 0 and CD.Detail<>'' 
and CD.contactQuestionId=2843
) as CustomerCompany,
(SELECT TOP 1 cd.Detail FROM ContactDetails CD WHERE   CD.ContactMasterId=(case when AM.IsSubmittedForGroup=1 then SAC.ContactMasterId  else AM.ContactMasterId end) and CD.IsDeleted = 0 and CD.Detail<>'' 
and CD.contactQuestionId=2842
) as CustomerEmail,
(SELECT TOP 1 cd.Detail FROM ContactDetails CD WHERE   CD.ContactMasterId=(case when AM.IsSubmittedForGroup=1 then SAC.ContactMasterId  else AM.ContactMasterId end) and CD.IsDeleted = 0 and CD.Detail<>'' 
and CD.contactQuestionId=2841
) as CustomerMobile,
(SELECT TOP 1 cd.Detail FROM ContactDetails CD WHERE   CD.ContactMasterId=(case when AM.IsSubmittedForGroup=1 then SAC.ContactMasterId  else AM.ContactMasterId end) and CD.IsDeleted = 0 and CD.Detail<>'' 
and CD.contactQuestionId=2839
)+' '+
(SELECT TOP 1 cd.Detail FROM ContactDetails CD WHERE   CD.ContactMasterId=(case when AM.IsSubmittedForGroup=1 then SAC.ContactMasterId  else AM.ContactMasterId end) and CD.IsDeleted = 0 and CD.Detail<>'' 
and CD.contactQuestionId=2840
) as CustomerName
from dbo.[Group] G
inner join EstablishmentGroup EG on G.id=EG.groupid and g.id = 463 and eg.id=5193 
inner join Establishment E on  E.EstablishmentGroupId=EG.Id 
inner join SeenClientAnswerMaster AM on AM.EstablishmentId=E.id ANd (AM.IsDeleted=0 or AM.IsDeleted=null)
inner join [SeenClientAnswers] A on A.SeenclientAnswerMasterId=AM.id 
inner join SeenClientQuestions Q on Q.id=A.QuestionId and q.id in (40976,40977,40978,40981,41352,42068,42069,45429,45430,45432,45533,45647,47580,47572,47573,47574,47575,47576,47577,57653,57648,49711,74284,76099,76106,76100,76101,76102,76105,76129,76131,78797,81210,81211)
left outer join dbo.[Appuser] u on u.id=AM.CreatedBy
left outer join SeenClientAnswerChild SAC on AM.id=SAC.SeenClientAnswerMasterId WHERE A.RepeatCount=0
)S
pivot(
Max(Answer)
For  Question In (
[Company],[WIP Number],[Type],[Employee / Supplier Name],[Masslift Branch],[Department],[Rating],[General Comments],[Machine Serial Number (please note to press enter when on the web app to lock in your entry)],[Work Completed],[Masslift Department],[Any Masslift specific concerns?],[ML Concern category],[ML Concerned comments],[Any person specific concerns],[Emp Concern category],[If Other, please specify],[Emp Concerned comments],[Date Capturing for],[Call Status],[If other please state]
))P
)K ON K.ReferenceNo=J.ReferenceNo WHERE K.UserName NOT LIKE '%admin%'

/*Drafted Form*/
--UNION ALL

--SELECT K.EstablishmentName,
--	   IIF(K.[Masslift Branch] IS NULL OR K.[Masslift Branch]='','N/A',K.[Masslift Branch]) AS Branch,
--       --K.CapturedDate,
--	   CAST(K.CapturedDate AS DATE) AS CapturedDate,
--       K.ReferenceNo,
--       K.IsPositive,
--       K.Status,
--       K.UserName,
--       K.CustomerCompany,
--       K.CustomerEmail,
--       K.CustomerMobile,
--       K.CustomerName,
--       J.RepeatCount,
--       IIF(K.Company='',K.CustomerCompany,K.Company) AS Company,
--       K.[WIP Number],
--	   ISNULL(REPLACE(REPLACE(K.[Work Completed],'-- Select --','N/A'),'','N/A'),'N/A') AS [Work Completed],
--       IIF(K.Type IS NULL OR K.Type='','N/A',K.Type) AS Type,
--	   K.[Any Masslift specific concerns?],
--	   K.[ML Concern category],
--	   K.[ML Concerned comments],
--       J.[Employee / Supplier Name],
--       REPLACE(ISNULL(REPLACE(J.[Department],'','N/A'),'N/A'),'-- Select --','N/A') AS [Department],
--       REPLACE(J.Rating,'-- Select --','') AS Rating,
--       J.[General Comments],
--	   J.[Any person specific concerns],
--	   IIF(J.[Emp Concern category]='Other',J.[If Other, please specify],J.[Emp Concern category]) AS [Emp Concern category],
--	   --J.[If Other, please specify],
--	   J.[Emp Concerned comments],
--	   K.[Machine Serial Number],
--	   1 AS IsDraft, 
--	   IIF(K.[Date Capturing for] IS NULL,CAST(K.CapturedDate AS DATE),K.[Date Capturing for]) AS [Date Capturing for],
--	   K.[Preferred Calling Time],
--	   K.[Preferred Communication Type],
--	   K.[Call Status],
--	   K.[If other please state] FROM 
--(
--SELECT EstablishmentName,CapturedDate,ReferenceNo,IsPositive,Status,UserName,ISNULL(CustomerCompany,'N/A') AS CustomerCompany,CustomerEmail,CustomerMobile,CustomerName,RepeatCount,P.[Preferred Calling Time],P.[Preferred Communication Type],
--[Company],[WIP Number],[Work Completed],[Type],[Employee / Supplier Name],[Masslift Branch],[Department],[Rating],[General Comments],[Machine Serial Number (please note to press enter when on the web app to lock in your entry)] AS [Machine Serial Number],[Masslift Department],[Any Masslift specific concerns?],[ML Concern category],[ML Concerned comments],[Any person specific concerns],[Emp Concern category],[If Other, please specify],[Emp Concerned comments],[Date Capturing for],[Call Status],[If other please state]
--From(
--SELECT E.EstablishmentName,dateadd(MINUTE,AM.TimeOffSet,AM.CreatedOn) as CapturedDate,AM.id as ReferenceNo,
--AM.IsPositive,AM.IsResolved as Status,
--A.Detail as Answer,
--CASE WHEN Q.Questiontitle='Employee department' THEN 'Department' 
--	 WHEN q.id=47573 THEN 'ML Concern category' 
--	 WHEN q.id=47574 THEN 'ML Concerned comments'
--	 WHEN q.id=47576 THEN 'Emp Concern category' 
--	 WHEN q.id=57648 THEN 'Emp Concern category'
--	 WHEN q.Id=76105 THEN 'Emp Concern category'
--	 WHEN q.id=47577 THEN 'Emp Concerned comments'
--	 ELSE Q.QuestionTitle
--	 END AS Question,
--U.id as UserId, u.name as UserName,A.RepeatCount,
--AM.Longitude ,AM.Latitude,
--(SELECT TOP 1 cd.Detail FROM ContactDetails CD WHERE   CD.ContactMasterId=(case when AM.IsSubmittedForGroup=1 then SAC.ContactMasterId  else AM.ContactMasterId end) and CD.IsDeleted = 0 and CD.Detail<>'' 
--and CD.contactQuestionId=4623
--) as [Preferred Calling Time],
--(SELECT TOP 1 cd.Detail FROM ContactDetails CD WHERE   CD.ContactMasterId=(case when AM.IsSubmittedForGroup=1 then SAC.ContactMasterId  else AM.ContactMasterId end) and CD.IsDeleted = 0 and CD.Detail<>'' 
--and CD.contactQuestionId=4627
--) as [Preferred Communication Type],
--(SELECT TOP 1 cd.Detail FROM ContactDetails CD WHERE   CD.ContactMasterId=(case when AM.IsSubmittedForGroup=1 then SAC.ContactMasterId  else AM.ContactMasterId end) and CD.IsDeleted = 0 and CD.Detail<>'' 
--and CD.contactQuestionId=2843
--) as CustomerCompany,
--(SELECT TOP 1 cd.Detail FROM ContactDetails CD WHERE   CD.ContactMasterId=(case when AM.IsSubmittedForGroup=1 then SAC.ContactMasterId  else AM.ContactMasterId end) and CD.IsDeleted = 0 and CD.Detail<>'' 
--and CD.contactQuestionId=2842
--) as CustomerEmail,
--(SELECT TOP 1 cd.Detail FROM ContactDetails CD WHERE   CD.ContactMasterId=(case when AM.IsSubmittedForGroup=1 then SAC.ContactMasterId  else AM.ContactMasterId end) and CD.IsDeleted = 0 and CD.Detail<>'' 
--and CD.contactQuestionId=2841
--) as CustomerMobile,
--(SELECT TOP 1 cd.Detail FROM ContactDetails CD WHERE   CD.ContactMasterId=(case when AM.IsSubmittedForGroup=1 then SAC.ContactMasterId  else AM.ContactMasterId end) and CD.IsDeleted = 0 and CD.Detail<>'' 
--and CD.contactQuestionId=2839
--)+' '+
--(SELECT TOP 1 cd.Detail FROM ContactDetails CD WHERE   CD.ContactMasterId=(case when AM.IsSubmittedForGroup=1 then SAC.ContactMasterId  else AM.ContactMasterId end) and CD.IsDeleted = 0 and CD.Detail<>'' 
--and CD.contactQuestionId=2840
--) as CustomerName
--from dbo.[Group] G
--inner join EstablishmentGroup EG on G.id=EG.groupid and g.id = 463 and eg.id=5193 
--inner join Establishment E on  E.EstablishmentGroupId=EG.Id 
--inner join SeenClientAnswerMaster AM on AM.EstablishmentId=E.id ANd (AM.DraftEntry=1)
--inner join [SeenClientAnswers] A on A.SeenclientAnswerMasterId=AM.id 
--inner join SeenClientQuestions Q on Q.id=A.QuestionId and q.id in (40976,40977,40978,40981,41352,42068,42069,45429,45430,45432,45533,45647,47580,47572,47573,47574,47575,47576,47577,57653,57648,49711,74284,76099,76106,76100,76101,76102,76105)
--left outer join dbo.[Appuser] u on u.id=AM.CreatedBy
--left outer join SeenClientAnswerChild SAC on AM.id=SAC.SeenClientAnswerMasterId WHERE A.RepeatCount<>0
--)S
--pivot(
--Max(Answer)
--For  Question In (
--[Company],[WIP Number],[Type],[Employee / Supplier Name],[Masslift Branch],[Department],[Rating],[General Comments],[Machine Serial Number (please note to press enter when on the web app to lock in your entry)],[Work Completed],[Masslift Department],[Any Masslift specific concerns?],[ML Concern category],[ML Concerned comments],[Any person specific concerns],[Emp Concern category],[If Other, please specify],[Emp Concerned comments],[Date Capturing for],[Call Status],[If other please state]
--))P
--)J
--FULL JOIN 
--(
--SELECT EstablishmentName,CapturedDate,ReferenceNo,IsPositive,Status,UserName,ISNULL(CustomerCompany,'N/A') AS CustomerCompany,CustomerEmail,CustomerMobile,CustomerName,RepeatCount,P.[Preferred Calling Time],P.[Preferred Communication Type],
--[Company],[WIP Number],[Work Completed],[Type],[Employee / Supplier Name],[Masslift Branch],[Department],[Rating],[General Comments],[Machine Serial Number (please note to press enter when on the web app to lock in your entry)] AS [Machine Serial Number],[Masslift Department],[Any Masslift specific concerns?],[ML Concern category],[ML Concerned comments],[Any person specific concerns],[Emp Concern category],[If Other, please specify],[Emp Concerned comments],[Date Capturing for],[Call Status],[If other please state]
--From(
--SELECT E.EstablishmentName,dateadd(MINUTE,AM.TimeOffSet,AM.CreatedOn) as CapturedDate,AM.id as ReferenceNo,
--AM.IsPositive,AM.IsResolved as Status,
--A.Detail as Answer,
--CASE WHEN Q.Questiontitle='Employee department' THEN 'Department' 
--	 WHEN q.id=47573 THEN 'ML Concern category' 
--	 WHEN q.id=47574 THEN 'ML Concerned comments'
--	 WHEN q.id=47576 THEN 'Emp Concern category' 
--	 WHEN q.id=57648 THEN 'Emp Concern category'
--	 WHEN q.Id=76105 THEN 'Emp Concern category'
--	 WHEN q.id=47577 THEN 'Emp Concerned comments'
--	 ELSE Q.QuestionTitle
--	 END AS Question,
--U.id as UserId, u.name as UserName,A.RepeatCount,
--AM.Longitude ,AM.Latitude,
--(SELECT TOP 1 cd.Detail FROM ContactDetails CD WHERE   CD.ContactMasterId=(case when AM.IsSubmittedForGroup=1 then SAC.ContactMasterId  else AM.ContactMasterId end) and CD.IsDeleted = 0 and CD.Detail<>'' 
--and CD.contactQuestionId=4623
--) as [Preferred Calling Time],
--(SELECT TOP 1 cd.Detail FROM ContactDetails CD WHERE   CD.ContactMasterId=(case when AM.IsSubmittedForGroup=1 then SAC.ContactMasterId  else AM.ContactMasterId end) and CD.IsDeleted = 0 and CD.Detail<>'' 
--and CD.contactQuestionId=4627
--) as [Preferred Communication Type],
--(SELECT TOP 1 cd.Detail FROM ContactDetails CD WHERE   CD.ContactMasterId=(case when AM.IsSubmittedForGroup=1 then SAC.ContactMasterId  else AM.ContactMasterId end) and CD.IsDeleted = 0 and CD.Detail<>'' 
--and CD.contactQuestionId=2843
--) as CustomerCompany,
--(SELECT TOP 1 cd.Detail FROM ContactDetails CD WHERE   CD.ContactMasterId=(case when AM.IsSubmittedForGroup=1 then SAC.ContactMasterId  else AM.ContactMasterId end) and CD.IsDeleted = 0 and CD.Detail<>'' 
--and CD.contactQuestionId=2842
--) as CustomerEmail,
--(SELECT TOP 1 cd.Detail FROM ContactDetails CD WHERE   CD.ContactMasterId=(case when AM.IsSubmittedForGroup=1 then SAC.ContactMasterId  else AM.ContactMasterId end) and CD.IsDeleted = 0 and CD.Detail<>'' 
--and CD.contactQuestionId=2841
--) as CustomerMobile,
--(SELECT TOP 1 cd.Detail FROM ContactDetails CD WHERE   CD.ContactMasterId=(case when AM.IsSubmittedForGroup=1 then SAC.ContactMasterId  else AM.ContactMasterId end) and CD.IsDeleted = 0 and CD.Detail<>'' 
--and CD.contactQuestionId=2839
--)+' '+
--(SELECT TOP 1 cd.Detail FROM ContactDetails CD WHERE   CD.ContactMasterId=(case when AM.IsSubmittedForGroup=1 then SAC.ContactMasterId  else AM.ContactMasterId end) and CD.IsDeleted = 0 and CD.Detail<>'' 
--and CD.contactQuestionId=2840
--) as CustomerName
--from dbo.[Group] G
--inner join EstablishmentGroup EG on G.id=EG.groupid and g.id = 463 and eg.id=5193 
--inner join Establishment E on  E.EstablishmentGroupId=EG.Id 
--inner join SeenClientAnswerMaster AM on AM.EstablishmentId=E.id ANd (AM.DraftEntry=1)
--inner join [SeenClientAnswers] A on A.SeenclientAnswerMasterId=AM.id 
--inner join SeenClientQuestions Q on Q.id=A.QuestionId and q.id in (40976,40977,40978,40981,41352,42068,42069,45429,45430,45432,45533,45647,47580,47572,47573,47574,47575,47576,47577,57653,57648,49711,74284,76099,76106,76100,76101,76102,76105)
--left outer join dbo.[Appuser] u on u.id=AM.CreatedBy
--left outer join SeenClientAnswerChild SAC on AM.id=SAC.SeenClientAnswerMasterId WHERE A.RepeatCount=0
--)S
--pivot(
--Max(Answer)
--For  Question In (
--[Company],[WIP Number],[Type],[Employee / Supplier Name],[Masslift Branch],[Department],[Rating],[General Comments],[Machine Serial Number (please note to press enter when on the web app to lock in your entry)],[Work Completed],[Masslift Department],[Any Masslift specific concerns?],[ML Concern category],[ML Concerned comments],[Any person specific concerns],[Emp Concern category],[If Other, please specify],[Emp Concerned comments],[Date Capturing for],[Call Status],[If other please state]
--))P
--)K ON K.ReferenceNo=J.ReferenceNo WHERE K.UserName NOT LIKE '%admin%'

UNION ALL

SELECT * FROM dbo.Masslift_CSI_OldData

