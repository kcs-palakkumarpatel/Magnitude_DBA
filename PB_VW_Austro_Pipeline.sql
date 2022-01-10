CREATE VIEW PB_VW_Austro_Pipeline AS

SELECT z.Type,
       z.CapturedDate,
       z.ReferenceNo,
       z.Status,
       z.UserName,
       z.Latitude,
       z.Longitude,
       z.CustomerName,
       z.CustomerCompany,
       z.CustomerEmail,
       z.CustomerMobile,
       z.[Is there a new or existing opportunity?],
       z.[Company Name:],
       z.[Is this a Biesse opportunity?],
       z.[Company Tier],
       z.Confidence,
       z.[Brands Presented],
       z.[Short Feedback],
       z.[Long Feedback],
       z.[What is the opportunity spotted?],
       z.[What is the customer interested in?],
       REPLACE(z.[Price of total opportunity (ZAR):],',','') AS [Price of total opportunity (ZAR):],
       z.[Expected date of invoice:],
       z.[Name:],
       z.[Surname:],
       z.[Mobile:],
       z.Email,
       z.[Attachments:],
       z.ResponseDate,
       z.Responseno,
       z.[Quote Status],
       z.[Reason for lost sale:],
       z.[Who did we loose the deal to?],
       z.[What can you do better?],
       z.[Type of follow up],
       z.[General comments],
	   CASE WHEN z.[Quote Status]='Captured' THEN 1
			WHEN z.[Quote Status]='Initial engagement' THEN 2
			WHEN z.[Quote Status]='Send Quote' THEN 3
			WHEN z.[Quote Status]='Acceptance of Quote' THEN 4
			WHEN z.[Quote Status]='Follow up' THEN 5
			WHEN z.[Quote Status]='Deposit Paid' THEN 6
			WHEN z.[Quote Status]='Received customer order' THEN 7
			WHEN z.[Quote Status]='Lost deal' THEN 8 ELSE 9 END AS sortorder
	   FROM 
(SELECT 'Sales' AS Type,
	   AA.CapturedDate,
       AA.ReferenceNo,
       AA.Status,
       AA.UserName,
       AA.Latitude,
       AA.Longitude,
       AA.CustomerName,
       AA.CustomerCompany,
       AA.CustomerEmail,
       AA.CustomerMobile,
       AA.[Is there a new or existing opportunity?],
       AA.[Company Name:],
       AA.[Is this a Biesse opportunity?],
       AA.[Company Tier],
       AA.Confidence,
       AA.[Brands Presented],
       AA.[Short Feedback],
       AA.[Long Feedback],
       AA.[What is the opportunity spotted?],
       AA.[What is the customer interested in?],
       AA.[Price of total opportunity (ZAR):],
       AA.[Expected date of invoice:],
       AA.[Name:],
       AA.[Surname:],
       AA.[Mobile:],
       AA.Email,
       AA.[Attachments:],
       BB.ResponseDate,
       --BB.SeenClientAnswerMasterId,
       BB.Responseno,
       REPLACE(BB.[Quote Status],'Acceptance of quote or positive feedback','Acceptance of Quote') AS [Quote Status],
       BB.[Reason for lost sale:],
       BB.[Who did we loose the deal to?],
       BB.[What can you do better?],
       BB.[Type of follow up],
       BB.[General comments] FROM 
(select CAST(CapturedDate AS DATE) AS CapturedDate,ReferenceNo,Status,UserName,P.Latitude,P.Longitude,CustomerName,CustomerCompany,CustomerEmail,CustomerMobile,
[Is there a new or existing opportunity?],[Company Name:],[Is this a Biesse opportunity?],[Company Tier],[Confidence],[Brands Presented],[Short Feedback],[Long Feedback],[What is the opportunity spotted?],[What is the customer interested in?],[Price of total opportunity (ZAR):],[Expected date of invoice:],[Name:],[Surname:],[Mobile:],[Email],[Attachments:]
From(
select
E.EstablishmentName,dateadd(MINUTE,AM.TimeOffSet,AM.CreatedOn) as CapturedDate,AM.id as ReferenceNo,
AM.IsResolved as Status,A.Detail as Answer,U.Name as UserName,AM.Latitude,AM.Longitude,q.QuestionTitle AS Question,
(SELECT TOP 1 cd.Detail FROM ContactDetails CD WHERE   CD.ContactMasterId=(case when AM.IsSubmittedForGroup=1 then SAC.ContactMasterId  else AM.ContactMasterId end) and CD.IsDeleted = 0 and CD.Detail<>'' 
and CD.contactQuestionId=2928
) as CustomerCompany,
(SELECT TOP 1 cd.Detail FROM ContactDetails CD WHERE   CD.ContactMasterId=(case when AM.IsSubmittedForGroup=1 then SAC.ContactMasterId  else AM.ContactMasterId end) and CD.IsDeleted = 0 and CD.Detail<>'' 
and CD.contactQuestionId=2837
) as CustomerEmail,
(SELECT TOP 1 cd.Detail FROM ContactDetails CD WHERE   CD.ContactMasterId=(case when AM.IsSubmittedForGroup=1 then SAC.ContactMasterId  else AM.ContactMasterId end) and CD.IsDeleted = 0 and CD.Detail<>'' 
and CD.contactQuestionId=2836
) as CustomerMobile,
(SELECT TOP 1 cd.Detail FROM ContactDetails CD WHERE   CD.ContactMasterId=(case when AM.IsSubmittedForGroup=1 then SAC.ContactMasterId  else AM.ContactMasterId end) and CD.IsDeleted = 0 and CD.Detail<>'' 
and CD.contactQuestionId=2834
) as CustomerName
from dbo.[Group] G
inner join EstablishmentGroup EG on G.id=EG.groupid and g.id = 462 and eg.id=4525
inner join Establishment E on  E.EstablishmentGroupId=EG.Id 
inner join SeenClientAnswerMaster AM on AM.EstablishmentId=E.id ANd (AM.IsDeleted=0 or AM.IsDeleted=null)
inner join [SeenClientAnswers] A on A.SeenclientAnswerMasterId=AM.id 
inner join SeenClientQuestions Q on Q.id=A.QuestionId and q.id in (70836,72634,37212,45331,45332,45333,45334,45335,36626,36627,36628,36629,36631,36632,36633,70837,36634,35745)
LEFT outer join dbo.[Appuser] u on u.Id=AM.CreatedBy
left outer join SeenClientAnswerChild SAC on AM.id=SAC.SeenClientAnswerMasterId 
)S
pivot(
Max(Answer)
For  Question In (
[Is there a new or existing opportunity?],[Company Name:],[Is this a Biesse opportunity?],[Company Tier],[Confidence],[Brands Presented],[Short Feedback],[Long Feedback],[What is the opportunity spotted?],[What is the customer interested in?],[Price of total opportunity (ZAR):],[Expected date of invoice:],[Name:],[Surname:],[Mobile:],[Email],[Attachments:]
))P
)AA

LEFT JOIN 

(select ResponseDate,SeenClientAnswerMasterId,Responseno,
[Status] AS [Quote Status],[Reason for lost sale:],[Who did we loose the deal to?],[What can you do better?],[Type of follow up],[General comments]
from (
select
dateadd(MINUTE,am.TimeOffSet,am.CreatedOn) as ResponseDate,am.id as Responseno,cam.Id as SeenClientAnswerMasterId,
a.Detail as Answer,
CASE WHEN q.Id IN (24390,24478,23977,23096,23461,23460) THEN 'Status' ELSE q.QuestionTitle END AS Question
from dbo.[Group] g
inner join EstablishmentGroup eg on g.id=eg.groupid and g.id = 462 and eg.id=4525 
inner join Establishment e on  e.EstablishmentGroupId=eg.Id 
inner join answermaster am on am.EstablishmentId=e.id and (am.IsDeleted=0 or am.IsDeleted IS NULL)
inner join Answers a on a.AnswerMasterId=am.id 
inner join Questions q on q.id=a.QuestionId and q.Id IN (53882,23978,53840,23979,53841,56191,24390,24478,23977,23096,23461,23460,24012,23482)
left join SeenClientAnswerMaster cam on cam.Id=am.SeenClientAnswerMasterId and (cam.IsDeleted=0 or cam.IsDeleted IS NULL)
) s
pivot(
Max(Answer)
For  Question In (
[Status],[Reason for lost sale:],[Who did we loose the deal to?],[What can you do better?],[Type of follow up],[General comments]
))P
)BB ON AA.ReferenceNo=BB.SeenClientAnswerMasterId

UNION ALL

SELECT 'Sales' AS Type,
	   AA.CapturedDate,
       AA.ReferenceNo,
       AA.Status,
       AA.UserName,
       AA.Latitude,
       AA.Longitude,
       AA.CustomerName,
       AA.CustomerCompany,
       AA.CustomerEmail,
       AA.CustomerMobile,
       AA.[Is there a new or existing opportunity?],
       AA.[Company Name:],
       AA.[Is this a Biesse opportunity?],
       AA.[Company Tier],
       AA.Confidence,
       AA.[Brands Presented],
       AA.[Short Feedback],
       AA.[Long Feedback],
       AA.[What is the opportunity spotted?],
       AA.[What is the customer interested in?],
       AA.[Price of total opportunity (ZAR):],
       AA.[Expected date of invoice:],
       AA.[Name:],
       AA.[Surname:],
       AA.[Mobile:],
       AA.Email,
       AA.[Attachments:],
       NULL AS ResponseDate,
       NULL AS Responseno,
       'Captured' AS [Quote Status],
       NULL AS [Reason for lost sale:],
       NULL AS [Who did we loose the deal to?],
       NULL AS [What can you do better?],
       NULL AS [Type of follow up],
       NULL AS [General comments] FROM 
(select CAST(CapturedDate AS DATE) AS CapturedDate,ReferenceNo,Status,UserName,P.Latitude,P.Longitude,CustomerName,CustomerCompany,CustomerEmail,CustomerMobile,
[Is there a new or existing opportunity?],[Company Name:],[Is this a Biesse opportunity?],[Company Tier],[Confidence],[Brands Presented],[Short Feedback],[Long Feedback],[What is the opportunity spotted?],[What is the customer interested in?],[Price of total opportunity (ZAR):],[Expected date of invoice:],[Name:],[Surname:],[Mobile:],[Email],[Attachments:]
From(
select
E.EstablishmentName,dateadd(MINUTE,AM.TimeOffSet,AM.CreatedOn) as CapturedDate,AM.id as ReferenceNo,
AM.IsResolved as Status,A.Detail as Answer,U.Name as UserName,AM.Latitude,AM.Longitude,q.QuestionTitle AS Question,
(SELECT TOP 1 cd.Detail FROM ContactDetails CD WHERE   CD.ContactMasterId=(case when AM.IsSubmittedForGroup=1 then SAC.ContactMasterId  else AM.ContactMasterId end) and CD.IsDeleted = 0 and CD.Detail<>'' 
and CD.contactQuestionId=2928
) as CustomerCompany,
(SELECT TOP 1 cd.Detail FROM ContactDetails CD WHERE   CD.ContactMasterId=(case when AM.IsSubmittedForGroup=1 then SAC.ContactMasterId  else AM.ContactMasterId end) and CD.IsDeleted = 0 and CD.Detail<>'' 
and CD.contactQuestionId=2837
) as CustomerEmail,
(SELECT TOP 1 cd.Detail FROM ContactDetails CD WHERE   CD.ContactMasterId=(case when AM.IsSubmittedForGroup=1 then SAC.ContactMasterId  else AM.ContactMasterId end) and CD.IsDeleted = 0 and CD.Detail<>'' 
and CD.contactQuestionId=2836
) as CustomerMobile,
(SELECT TOP 1 cd.Detail FROM ContactDetails CD WHERE   CD.ContactMasterId=(case when AM.IsSubmittedForGroup=1 then SAC.ContactMasterId  else AM.ContactMasterId end) and CD.IsDeleted = 0 and CD.Detail<>'' 
and CD.contactQuestionId=2834
) as CustomerName
from dbo.[Group] G
inner join EstablishmentGroup EG on G.id=EG.groupid and g.id = 462 and eg.id=4525
inner join Establishment E on  E.EstablishmentGroupId=EG.Id 
inner join SeenClientAnswerMaster AM on AM.EstablishmentId=E.id ANd (AM.IsDeleted=0 or AM.IsDeleted=null)
inner join [SeenClientAnswers] A on A.SeenclientAnswerMasterId=AM.id 
inner join SeenClientQuestions Q on Q.id=A.QuestionId and q.id in (70836,72634,37212,45331,45332,45333,45334,45335,36626,36627,36628,36629,36631,36632,36633,70837,36634,35745)
LEFT outer join dbo.[Appuser] u on u.Id=AM.CreatedBy
left outer join SeenClientAnswerChild SAC on AM.id=SAC.SeenClientAnswerMasterId 
)S
pivot(
Max(Answer)
For  Question In (
[Is there a new or existing opportunity?],[Company Name:],[Is this a Biesse opportunity?],[Company Tier],[Confidence],[Brands Presented],[Short Feedback],[Long Feedback],[What is the opportunity spotted?],[What is the customer interested in?],[Price of total opportunity (ZAR):],[Expected date of invoice:],[Name:],[Surname:],[Mobile:],[Email],[Attachments:]
))P
)AA

UNION ALL

SELECT 'Consumables' AS Type,
	   AA.CapturedDate,
       AA.ReferenceNo,
       AA.Status,
       AA.UserName,
       AA.Latitude,
       AA.Longitude,
       AA.CustomerName,
       AA.CustomerCompany,
       AA.CustomerEmail,
       AA.CustomerMobile,
       AA.[Is the a new or existing opportunity?],
       AA.[Company Name:],
	   NULL AS [Is this a Biesse opportunity?],
       NULL AS [Company Tier],
       NULL AS Confidence,
       NULL AS [Brands Presented],
       NULL AS [Short Feedback],
       NULL AS [Long Feedback],
       AA.[What is the opportunity spotted?],
       AA.[What is the customer interested in?],
       AA.[Price of total opportunity (ZAR):],
       AA.[Expected date of delivery:],
       AA.[Name:],
       AA.[Surname:],
       AA.[Mobile:],
       AA.Email,
       AA.[Attachments:],
       BB.ResponseDate,
       --BB.SeenClientAnswerMasterId,
       BB.Responseno,
       REPLACE(BB.[Quote Status],'Acceptance of quote or positive feedback','Acceptance of Quote') AS [Quote Status],
       BB.[Reason for lost sale:],
       BB.[Who did we loose the deal to?],
       BB.[What can you do better?],
       BB.[Type of follow up],
       BB.[General comments] FROM 
(select CAST(CapturedDate AS DATE) AS CapturedDate,ReferenceNo,Status,UserName,P.Latitude,P.Longitude,CustomerName,CustomerCompany,CustomerEmail,CustomerMobile,
[Is the a new or existing opportunity?],[Company Name:],[What is the opportunity spotted?],[What is the customer interested in?],[Price of total opportunity (ZAR):],[Expected date of delivery:],[Name:],[Surname:],[Mobile:],[Email],[Attachments:]
From(
select
E.EstablishmentName,dateadd(MINUTE,AM.TimeOffSet,AM.CreatedOn) as CapturedDate,AM.id as ReferenceNo,
AM.IsResolved as Status,A.Detail as Answer,U.Name as UserName,AM.Latitude,AM.Longitude,q.QuestionTitle AS Question,
(SELECT TOP 1 cd.Detail FROM ContactDetails CD WHERE   CD.ContactMasterId=(case when AM.IsSubmittedForGroup=1 then SAC.ContactMasterId  else AM.ContactMasterId end) and CD.IsDeleted = 0 and CD.Detail<>'' 
and CD.contactQuestionId=2928
) as CustomerCompany,
(SELECT TOP 1 cd.Detail FROM ContactDetails CD WHERE   CD.ContactMasterId=(case when AM.IsSubmittedForGroup=1 then SAC.ContactMasterId  else AM.ContactMasterId end) and CD.IsDeleted = 0 and CD.Detail<>'' 
and CD.contactQuestionId=2837
) as CustomerEmail,
(SELECT TOP 1 cd.Detail FROM ContactDetails CD WHERE   CD.ContactMasterId=(case when AM.IsSubmittedForGroup=1 then SAC.ContactMasterId  else AM.ContactMasterId end) and CD.IsDeleted = 0 and CD.Detail<>'' 
and CD.contactQuestionId=2836
) as CustomerMobile,
(SELECT TOP 1 cd.Detail FROM ContactDetails CD WHERE   CD.ContactMasterId=(case when AM.IsSubmittedForGroup=1 then SAC.ContactMasterId  else AM.ContactMasterId end) and CD.IsDeleted = 0 and CD.Detail<>'' 
and CD.contactQuestionId=2834
) as CustomerName
from dbo.[Group] G
inner join EstablishmentGroup EG on G.id=EG.groupid and g.id = 462 and eg.id=4855
inner join Establishment E on  E.EstablishmentGroupId=EG.Id 
inner join SeenClientAnswerMaster AM on AM.EstablishmentId=E.id ANd (AM.IsDeleted=0 or AM.IsDeleted=null)
inner join [SeenClientAnswers] A on A.SeenclientAnswerMasterId=AM.id 
inner join SeenClientQuestions Q on Q.id=A.QuestionId and q.id in (70843,72633,36745,36648,36649,36650,36652,36653,36654,70845,36655)
LEFT outer join dbo.[Appuser] u on u.Id=AM.CreatedBy
left outer join SeenClientAnswerChild SAC on AM.id=SAC.SeenClientAnswerMasterId 
)S
pivot(
Max(Answer)
For  Question In (
[Is the a new or existing opportunity?],[Company Name:],[What is the opportunity spotted?],[What is the customer interested in?],[Price of total opportunity (ZAR):],[Expected date of delivery:],[Name:],[Surname:],[Mobile:],[Email],[Attachments:]
))P
)AA

LEFT JOIN 

(select ResponseDate,SeenClientAnswerMasterId,Responseno,
[Status] AS [Quote Status],[Reason for lost sale:],[Who did we loose the deal to?],[What can you do better?],[Type of follow up],[General comments]
from (
select
dateadd(MINUTE,am.TimeOffSet,am.CreatedOn) as ResponseDate,am.id as Responseno,cam.Id as SeenClientAnswerMasterId,
a.Detail as Answer,q.QuestionTitle AS Question
from dbo.[Group] g
inner join EstablishmentGroup eg on g.id=eg.groupid and g.id = 462 and eg.id=4855 
inner join Establishment e on  e.EstablishmentGroupId=eg.Id 
inner join answermaster am on am.EstablishmentId=e.id and (am.IsDeleted=0 or am.IsDeleted IS NULL)
inner join Answers a on a.AnswerMasterId=am.id 
inner join Questions q on q.id=a.QuestionId and q.Id IN (53883,23990,53865,23991,53866,56190)
left join SeenClientAnswerMaster cam on cam.Id=am.SeenClientAnswerMasterId and (cam.IsDeleted=0 or cam.IsDeleted IS NULL)
) s
pivot(
Max(Answer)
For  Question In (
[Status],[Reason for lost sale:],[Who did we loose the deal to?],[What can you do better?],[Type of follow up],[General comments]
))P
)BB ON AA.ReferenceNo=BB.SeenClientAnswerMasterId

UNION ALL

SELECT 'Consumables' AS Type,
	   AA.CapturedDate,
       AA.ReferenceNo,
       AA.Status,
       AA.UserName,
       AA.Latitude,
       AA.Longitude,
       AA.CustomerName,
       AA.CustomerCompany,
       AA.CustomerEmail,
       AA.CustomerMobile,
       AA.[Is the a new or existing opportunity?],
       AA.[Company Name:],
	   NULL AS [Is this a Biesse opportunity?],
       NULL AS [Company Tier],
       NULL AS Confidence,
       NULL AS [Brands Presented],
       NULL AS [Short Feedback],
       NULL AS [Long Feedback],
       AA.[What is the opportunity spotted?],
       AA.[What is the customer interested in?],
       AA.[Price of total opportunity (ZAR):],
       AA.[Expected date of delivery:],
       AA.[Name:],
       AA.[Surname:],
       AA.[Mobile:],
       AA.Email,
       AA.[Attachments:],
       NULL AS ResponseDate,
       NULL AS Responseno,
       'Captured' AS [Quote Status],
       NULL AS [Reason for lost sale:],
       NULL AS [Who did we loose the deal to?],
       NULL AS [What can you do better?],
       NULL AS [Type of follow up],
       NULL AS [General comments] FROM 
(select CAST(CapturedDate AS DATE) AS CapturedDate,ReferenceNo,Status,UserName,P.Latitude,P.Longitude,CustomerName,CustomerCompany,CustomerEmail,CustomerMobile,
[Is the a new or existing opportunity?],[Company Name:],[What is the opportunity spotted?],[What is the customer interested in?],[Price of total opportunity (ZAR):],[Expected date of delivery:],[Name:],[Surname:],[Mobile:],[Email],[Attachments:]
From(
select
E.EstablishmentName,dateadd(MINUTE,AM.TimeOffSet,AM.CreatedOn) as CapturedDate,AM.id as ReferenceNo,
AM.IsResolved as Status,A.Detail as Answer,U.Name as UserName,AM.Latitude,AM.Longitude,q.QuestionTitle AS Question,
(SELECT TOP 1 cd.Detail FROM ContactDetails CD WHERE   CD.ContactMasterId=(case when AM.IsSubmittedForGroup=1 then SAC.ContactMasterId  else AM.ContactMasterId end) and CD.IsDeleted = 0 and CD.Detail<>'' 
and CD.contactQuestionId=2928
) as CustomerCompany,
(SELECT TOP 1 cd.Detail FROM ContactDetails CD WHERE   CD.ContactMasterId=(case when AM.IsSubmittedForGroup=1 then SAC.ContactMasterId  else AM.ContactMasterId end) and CD.IsDeleted = 0 and CD.Detail<>'' 
and CD.contactQuestionId=2837
) as CustomerEmail,
(SELECT TOP 1 cd.Detail FROM ContactDetails CD WHERE   CD.ContactMasterId=(case when AM.IsSubmittedForGroup=1 then SAC.ContactMasterId  else AM.ContactMasterId end) and CD.IsDeleted = 0 and CD.Detail<>'' 
and CD.contactQuestionId=2836
) as CustomerMobile,
(SELECT TOP 1 cd.Detail FROM ContactDetails CD WHERE   CD.ContactMasterId=(case when AM.IsSubmittedForGroup=1 then SAC.ContactMasterId  else AM.ContactMasterId end) and CD.IsDeleted = 0 and CD.Detail<>'' 
and CD.contactQuestionId=2834
) as CustomerName
from dbo.[Group] G
inner join EstablishmentGroup EG on G.id=EG.groupid and g.id = 462 and eg.id=4855
inner join Establishment E on  E.EstablishmentGroupId=EG.Id 
inner join SeenClientAnswerMaster AM on AM.EstablishmentId=E.id ANd (AM.IsDeleted=0 or AM.IsDeleted=null)
inner join [SeenClientAnswers] A on A.SeenclientAnswerMasterId=AM.id 
inner join SeenClientQuestions Q on Q.id=A.QuestionId and q.id in (70843,72633,36745,36648,36649,36650,36652,36653,36654,70845,36655)
LEFT outer join dbo.[Appuser] u on u.Id=AM.CreatedBy
left outer join SeenClientAnswerChild SAC on AM.id=SAC.SeenClientAnswerMasterId 
)S
pivot(
Max(Answer)
For  Question In (
[Is the a new or existing opportunity?],[Company Name:],[What is the opportunity spotted?],[What is the customer interested in?],[Price of total opportunity (ZAR):],[Expected date of delivery:],[Name:],[Surname:],[Mobile:],[Email],[Attachments:]
))P
)AA

)z WHERE z.[Quote Status] IS NOT NULL

