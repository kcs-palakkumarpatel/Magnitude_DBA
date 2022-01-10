CREATE VIEW dbo.PB_VW_StarkeAyres_CustomerVisit AS

SELECT AA.Region,
       AA.CapturedDate AS [Captured Date],
	   CAST(AA.CapturedDate AS DATE) AS [CapturedDate],
       AA.ReferenceNo,
       AA.Status,
       AA.UserName,
       AA.Longitude,
       AA.Latitude,
       AA.CustomerName,
       AA.CustomerMobile,
       AA.CustomerEmail,
       IIF(AA.[Please enter the CUSTOMER GROUP/GROUP NAME]='' OR AA.[Please enter the CUSTOMER GROUP/GROUP NAME] IS NULL,'N/A',AA.[Please enter the CUSTOMER GROUP/GROUP NAME]) AS [Please enter the CUSTOMER GROUP/GROUP NAME],
       IIF(AA.[Type of Customer]='' OR AA.[Type of Customer] IS NULL,'N/A',AA.[Type of Customer]) AS [Type of Customer],
       IIF(AA.[Customer Name]='' OR AA.[Customer Name] IS NULL,'N/A',AA.[Customer Name]) AS [Customer Name],
       AA.[Please confirm CUSTOMER code],
	   IIF(AA.[Customer Name & Code]='' OR AA.[Customer Name & Code] IS NULL,CONCAT(AA.UserName,' - ',AA.[Please enter the CUSTOMER GROUP/GROUP NAME],' - ',AA.[Customer Name],' - ',AA.[Please confirm CUSTOMER code]),AA.[Customer Name & Code]) AS [Customer Name & Code],
	   IIF(AA.Area='' OR AA.Area IS NULL OR AA.Area='[""]','N/A',IIF(AA.Area='[""],FS- Odendaalsrus','FS- Odendaalsrus',AA.Area)) AS Area,
       IIF(AA.[Type of call:]='' OR AA.[Type of call:] IS NULL,'N/A',AA.[Type of call:]) AS [Type of call:],
	   IIF(AA.[Type of Customer]='' OR AA.[Type of Customer] IS NULL OR AA.[Type of call:]='' OR AA.[Type of call:] IS NULL,'N/A',CONCAT(IIF(AA.[Type of Customer]='Existing Customer','EXC','New/Pot'),' - ',AA.[Type of call:])) AS [Customer & Call],
       IIF(AA.[1. How many Starke Ayres trellis drops do you have in the outlet?]='' OR AA.[1. How many Starke Ayres trellis drops do you have in the outlet?] IS NULL,0,AA.[1. How many Starke Ayres trellis drops do you have in the outlet?]) AS [1. How many Starke Ayres trellis drops do you have in the outlet?],
       IIF(AA.[2. How many Competitor seed trellis drops do competitors collectively have in the outlet?]='' OR AA.[2. How many Competitor seed trellis drops do competitors collectively have in the outlet?] IS NULL,0,AA.[2. How many Competitor seed trellis drops do competitors collectively have in the outlet?]) AS [2. How many Competitor seed trellis drops do competitors collectively have in the outlet?],
       IIF(AA.[3. How many Starke Ayres large rotating trellis stands do you have in the outlet?]='' OR AA.[3. How many Starke Ayres large rotating trellis stands do you have in the outlet?] IS NULL,0,AA.[3. How many Starke Ayres large rotating trellis stands do you have in the outlet?]) AS [3. How many Starke Ayres large rotating trellis stands do you have in the outlet?],
       IIF(AA.[4. How many New Gen Kombat stands do you have in the store?]='' OR AA.[4. How many New Gen Kombat stands do you have in the store?] IS NULL,0,AA.[4. How many New Gen Kombat stands do you have in the store?]) AS [4. How many New Gen Kombat stands do you have in the store?],
       IIF(AA.[5. How many New Gen Starke Ayres stands do you have in the outlet?]='' OR AA.[5. How many New Gen Starke Ayres stands do you have in the outlet?] IS NULL,0,AA.[5. How many New Gen Starke Ayres stands do you have in the outlet?]) AS [5. How many New Gen Starke Ayres stands do you have in the outlet?], 
       IIF(AA.[6. How many Slim Rotating Stands do you have in the outlet?]='' OR AA.[6. How many Slim Rotating Stands do you have in the outlet?] IS NULL,0,AA.[6. How many Slim Rotating Stands do you have in the outlet?]) AS [6. How many Slim Rotating Stands do you have in the outlet?],
       IIF(AA.[7. How many Starke Ayres Power wings do you have in the outlet?]='' OR AA.[7. How many Starke Ayres Power wings do you have in the outlet?] IS NULL,0,AA.[7. How many Starke Ayres Power wings do you have in the outlet?]) AS [7. How many Starke Ayres Power wings do you have in the outlet?],
       IIF(AA.[8. How many Kombat Power Wings do you have in the outlet?]='' OR AA.[8. How many Kombat Power Wings do you have in the outlet?] IS NULL,0,AA.[8. How many Kombat Power Wings do you have in the outlet?]) AS [8. How many Kombat Power Wings do you have in the outlet?],
       IIF(AA.[9. How many Competitor Seeds of shelf stands/displays/ends/power wings are in this outlet?]='' OR AA.[9. How many Competitor Seeds of shelf stands/displays/ends/power wings are in this outlet?] IS NULL,0,AA.[9. How many Competitor Seeds of shelf stands/displays/ends/power wings are in this outlet?]) AS [9. How many Competitor Seeds of shelf stands/displays/ends/power wings are in this outlet?],
       IIF(AA.[10. How many Competitor Chemical off shelf stands/displays/ends/power are in the outlet?]='' OR AA.[10. How many Competitor Chemical off shelf stands/displays/ends/power are in the outlet?] IS NULL,0,AA.[10. How many Competitor Chemical off shelf stands/displays/ends/power are in the outlet?]) AS [10. How many Competitor Chemical off shelf stands/displays/ends/power are in the outlet?],
       AA.[Notes from the call],
       AA.[Follow up actions],
       --AA.[Did you take an order? ( If Yes, confirm below in comment box on what you ordered )],
       AA.[Did you take an order?],
       AA.[What you ordered?],
       AA.[What is the value of the order?],
       AA.[Attach photo],
       --BB.EstablishmentName,
       BB.ResponseDate,
       --BB.SeenClientAnswerMasterId,
       BB.ResponseNo,
	   BB.PI,
       BB.[How would you rate the overall customer visit?],
       BB.[Do you have any notes to provide about the status of the Customer?]
	   FROM 
(SELECT REPLACE(EstablishmentName,'General Customer Visit - ','') AS Region,
CapturedDate,ReferenceNo,Status,UserName,Longitude,Latitude,CustomerName,CustomerMobile,CustomerEmail,
[Please enter the CUSTOMER GROUP/GROUP NAME],[Type of Customer],[Customer Name],[Please confirm CUSTOMER code],[Customer Name & Code],[Area],[Type of call:],[1. How many Starke Ayres trellis drops do you have in the outlet?],[2. How many Competitor seed trellis drops do competitors collectively have in the outlet?],[3. How many Starke Ayres large rotating trellis stands do you have in the outlet?],[4. How many New Gen Kombat stands do you have in the store?],[5. How many New Gen Starke Ayres stands do you have in the outlet?],[6. How many Slim Rotating Stands do you have in the outlet?],[7. How many Starke Ayres Power wings do you have in the outlet?],[8. How many Kombat Power Wings do you have in the outlet?],[9. How many Competitor Seeds of shelf stands/displays/ends/power wings are in this outlet?],[10. How many Competitor Chemical off shelf stands/displays/ends/power are in the outlet?],[Notes from the call],[Follow up actions],
p.[Did you take an order? ( If Yes, confirm below in comment box on what you ordered )],
SUBSTRING([Did you take an order? ( If Yes, confirm below in comment box on what you ordered )],1,
CASE WHEN CHARINDEX(',',p.[Did you take an order? ( If Yes, confirm below in comment box on what you ordered )])=0 THEN LEN(p.[Did you take an order? ( If Yes, confirm below in comment box on what you ordered )])
ELSE CHARINDEX(',',p.[Did you take an order? ( If Yes, confirm below in comment box on what you ordered )])-1 end) AS [Did you take an order?],
SUBSTRING(p.[Did you take an order? ( If Yes, confirm below in comment box on what you ordered )],CHARINDEX(',',p.[Did you take an order? ( If Yes, confirm below in comment box on what you ordered )])+1,LEN(p.[Did you take an order? ( If Yes, confirm below in comment box on what you ordered )])) AS [What you ordered?],
REPLACE([What is the value of the order?],'-',0) AS [What is the value of the order?],
[Attach photo]
from (
select
E.EstablishmentName,dateadd(MINUTE,AM.TimeOffSet,AM.CreatedOn) as CapturedDate,AM.id as ReferenceNo,
AM.IsResolved as Status,u.name as UserName,AM.Longitude ,AM.Latitude,
CASE WHEN q.Id IN (29408,29399,29400,29401,29402,29403,29404,29405,29406,29407) THEN REPLACE(REPLACE(CAST(A.Detail AS VARCHAR(8000)),'select one',''),'-- Select --','') ELSE CAST(A.Detail AS VARCHAR(8000)) END AS Answer,
CASE 
WHEN q.id=27316 THEN 'Please enter the CUSTOMER GROUP/GROUP NAME'
WHEN q.id=70382 THEN 'Please enter the CUSTOMER GROUP/GROUP NAME'
WHEN q.id=27176 THEN '1. How many Starke Ayres trellis drops do you have in the outlet?'
WHEN q.id=27177 THEN '2. How many Competitor seed trellis drops do competitors collectively have in the outlet?'
WHEN q.id=27178 THEN '3. How many Starke Ayres large rotating trellis stands do you have in the outlet?'
WHEN q.id=27179 THEN '4. How many New Gen Kombat stands do you have in the store?'
WHEN q.id=27180 THEN '5. How many New Gen Starke Ayres stands do you have in the outlet?'
WHEN q.id=27181 THEN '6. How many Slim Rotating Stands do you have in the outlet?'
WHEN q.id=27182 THEN '7. How many Starke Ayres Power wings do you have in the outlet?'
WHEN q.id=27183 THEN '8. How many Kombat Power Wings do you have in the outlet?'
WHEN q.id=27184 THEN '9. How many Competitor Seeds of shelf stands/displays/ends/power wings are in this outlet?'
WHEN q.id=27185 THEN '10. How many Competitor Chemical off shelf stands/displays/ends/power are in the outlet?'
WHEN q.id=74354 THEN 'Customer Name & Code'
ELSE Q.Questiontitle END AS Question,
(SELECT TOP 1 cd.Detail FROM ContactDetails CD WHERE   CD.ContactMasterId=(case when AM.IsSubmittedForGroup=1 then SAC.ContactMasterId  else AM.ContactMasterId end) and CD.IsDeleted = 0 and CD.Detail<>'' 
and CD.contactQuestionId=2724
) as CustomerEmail,
(SELECT TOP 1 cd.Detail FROM ContactDetails CD WHERE   CD.ContactMasterId=(case when AM.IsSubmittedForGroup=1 then SAC.ContactMasterId  else AM.ContactMasterId end) and CD.IsDeleted = 0 and CD.Detail<>'' 
and CD.contactQuestionId=2723
) as CustomerMobile,
(SELECT TOP 1 cd.Detail FROM ContactDetails CD WHERE   CD.ContactMasterId=(case when AM.IsSubmittedForGroup=1 then SAC.ContactMasterId  else AM.ContactMasterId end) and CD.IsDeleted = 0 and CD.Detail<>'' 
and CD.contactQuestionId=2721
)+' '+
(SELECT TOP 1 cd.Detail FROM ContactDetails CD WHERE   CD.ContactMasterId=(case when AM.IsSubmittedForGroup=1 then SAC.ContactMasterId  else AM.ContactMasterId end) and CD.IsDeleted = 0 --and CD.Detail<>'' 
and CD.contactQuestionId=2722
) as CustomerName
from dbo.[Group] G
inner join EstablishmentGroup EG on G.id=EG.groupid and g.id = 438 and eg.id=3565
inner join Establishment E on  E.EstablishmentGroupId=EG.Id 
inner join SeenClientAnswerMaster AM on AM.EstablishmentId=E.id ANd (AM.IsDeleted=0 or AM.IsDeleted=null)
inner join [SeenClientAnswers] A on A.SeenclientAnswerMasterId=AM.id 
inner join SeenClientQuestions Q on Q.id=A.QuestionId and q.id in (27596,27316,54560,29074,27317,54156,29216,27176,29408,27177,29399,27178,29400,27179,29401,27180,29402,27181,29403,27182,29404,27183,29405,27184,29406,27185,29407,27186,27187,27188,27189,27190,67850,70382,74354)
left outer join dbo.[Appuser] u on u.id=AM.CreatedBy
left outer join SeenClientAnswerChild SAC on AM.id=SAC.SeenClientAnswerMasterId
)s
pivot(
Max(Answer)
For  Question In (
[Please enter the CUSTOMER GROUP/GROUP NAME],[Type of Customer],[Customer Name],[Please confirm CUSTOMER code],[Customer Name & Code],[Area],[Type of call:],[1. How many Starke Ayres trellis drops do you have in the outlet?],[2. How many Competitor seed trellis drops do competitors collectively have in the outlet?],[3. How many Starke Ayres large rotating trellis stands do you have in the outlet?],[4. How many New Gen Kombat stands do you have in the store?],[5. How many New Gen Starke Ayres stands do you have in the outlet?],[6. How many Slim Rotating Stands do you have in the outlet?],[7. How many Starke Ayres Power wings do you have in the outlet?],[8. How many Kombat Power Wings do you have in the outlet?],[9. How many Competitor Seeds of shelf stands/displays/ends/power wings are in this outlet?],[10. How many Competitor Chemical off shelf stands/displays/ends/power are in the outlet?],[Notes from the call],[Follow up actions],[Did you take an order? ( If Yes, confirm below in comment box on what you ordered )],[What is the value of the order?],[Attach photo]
))p 
)AA

LEFT JOIN 

(select EstablishmentName,ResponseDate,SeenClientAnswerMasterId,ResponseNo,P.PI,
[How would you rate the overall customer visit?],[Do you have any notes to provide about the status of the Customer?]
from (
select
E.EstablishmentName,dateadd(MINUTE,am.TimeOffSet,am.CreatedOn) as ResponseDate,am.id as ResponseNo,cam.Id as SeenClientAnswerMasterId,
CAST(a.Detail  AS Varchar(8000))AS Answer,q.QuestionTitle AS Question,am.PI
from dbo.[Group] g
inner join EstablishmentGroup eg on g.id=eg.groupid and g.id = 438 and eg.id=3565
inner join Establishment e on  e.EstablishmentGroupId=eg.Id 
inner join answermaster am on am.EstablishmentId=e.id and (am.IsDeleted=0 or am.IsDeleted=null)
inner join Answers a on a.AnswerMasterId=am.id 
inner join Questions q on q.id=a.QuestionId and q.id in (16561,16566)
left outer join dbo.[Appuser] u on u.id=am.CreatedBy
left join SeenClientAnswerMaster cam on cam.Id=am.SeenClientAnswerMasterId and (cam.IsDeleted=0 or cam.IsDeleted=null)
) s
pivot(
Max(Answer)
For  Question In (
[Do you have any notes to provide about the status of the Customer?],[How would you rate the overall customer visit?]
))P
)BB ON AA.ReferenceNo=BB.SeenClientAnswerMasterId
WHERE AA.UserName NOT IN ('MoxieStark Admin','Peter Walters','Hermiena Starke Ayres Test','Goodwill Mokoena','Brandon Segolela','Abram Mkhwatsa','Brenda Ntoagae','Zander Bekker','Clint Sandilands','Anusha Valjee','Gary Gielink','Barend Strydom','Nicholas Davies','Anton Beukes','Courtney Whittaker','Ruhan Jonker','Harold Nemund','Simone Vorster','Gerrie Swart','Heinrich February','Harold Nemudzivhadi')
--AND AA.ReferenceNo<>726038

