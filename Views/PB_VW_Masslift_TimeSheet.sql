CREATE VIEW dbo.PB_VW_Masslift_TimeSheet AS

SELECT * FROM 
(SELECT REPLACE(K.EstablishmentName,'ML Time Sheets- ','') AS Branch,
	   --IIF(K.EstablishmentName LIKE '%JHB',114.50,IIF(K.EstablishmentName LIKE '%CPT',34.00,IIF(K.EstablishmentName LIKE '%DBN',9.00,IIF(K.EstablishmentName LIKE '%PE',9.00,0.00)))) AS [Annual Leave],
       CAST(K.CapturedDate AS DATE) AS CapturedDate,
	   FORMAT(IIF(K.Date IS NULL,K.CapturedDate,k.Date),'yyyy-MMMM') AS [Month],
	   DATENAME(dw,K.CapturedDate) AS [Weekday],
       K.ReferenceNo,
       K.UserName,
       J.RepeatCount,
	   CAST(IIF(K.Date IS NULL,K.CapturedDate,k.Date) AS DATE) AS [Date],
       K.[Vehicle registration],
       J.[Start time],
       J.[End time],
	   CONVERT(DECIMAL(18,2),DATEDIFF(MINUTE,J.[Start time],J.[End time]))/60 AS [Total Time],
       J.[WIP number],
       J.[Travel (KM)],
       J.Productive,
       J.[Type of work],
       J.[Start KM],
       J.[End KM],
       J.[Chargeable KM],
       J.[Work KM],
	   CONCAT(K.[Vehicle registration],' ',J.[WIP number]) AS [UniqueId] 
	   FROM 
(
SELECT EstablishmentName,CapturedDate,ReferenceNo,IsPositive,UserName,RepeatCount,
[Date],[Vehicle registration],[Start time],[End time],[WIP number],[Travel (KM)],[Productive],[Type of work],[Start KM],[End KM],[Chargeable KM],[Work KM]
From(
SELECT E.EstablishmentName,dateadd(MINUTE,AM.TimeOffSet,AM.CreatedOn) as CapturedDate,AM.id as ReferenceNo,
AM.IsPositive,A.Detail as Answer,U.id as UserId, u.name as UserName,A.RepeatCount,AM.Longitude ,AM.Latitude,
CASE WHEN q.Id=37820 THEN 'Type of work'
WHEN q.Id=50713 THEN 'Type of work' ELSE Q.QuestionTitle END AS Question
from dbo.[Group] G
inner join EstablishmentGroup EG on G.id=EG.groupid and g.id = 463 and eg.id=4391 
inner join Establishment E on  E.EstablishmentGroupId=EG.Id 
inner join SeenClientAnswerMaster AM on AM.EstablishmentId=E.id ANd (AM.IsDeleted=0 or AM.IsDeleted=null)
inner join [SeenClientAnswers] A on A.SeenclientAnswerMasterId=AM.id 
inner join SeenClientQuestions Q on Q.id=A.QuestionId and q.id in (37814,37815,37816,37817,37818,37819,37820,37821,37822,37823,37824,49784,50715,50716,52778,52531)
left outer join dbo.[Appuser] u on u.id=AM.CreatedBy
left outer join SeenClientAnswerChild SAC on AM.id=SAC.SeenClientAnswerMasterId WHERE A.RepeatCount<>0
)S
pivot(
Max(Answer)
For  Question In (
[Date],[Vehicle registration],[Start time],[End time],[WIP number],[Travel (KM)],[Productive],[Type of work],[Start KM],[End KM],[Chargeable KM],[Work KM]
))P
)J
FULL JOIN 
(
SELECT EstablishmentName,CapturedDate,ReferenceNo,IsPositive,UserName,RepeatCount,
[Date],[Vehicle registration],[Start time],[End time],[WIP number],[Travel (KM)],[Productive],[Type of work],[Start KM],[End KM],[Chargeable KM],[Work KM]
From(
SELECT E.EstablishmentName,dateadd(MINUTE,AM.TimeOffSet,AM.CreatedOn) as CapturedDate,AM.id as ReferenceNo,
AM.IsPositive,A.Detail as Answer,U.id as UserId, u.name as UserName,A.RepeatCount,AM.Longitude ,AM.Latitude,
CASE WHEN q.Id=37820 THEN 'Type of work'
WHEN q.Id=50713 THEN 'Type of work' ELSE Q.QuestionTitle END AS Question
from dbo.[Group] G
inner join EstablishmentGroup EG on G.id=EG.groupid and g.id = 463 and eg.id=4391 
inner join Establishment E on  E.EstablishmentGroupId=EG.Id 
inner join SeenClientAnswerMaster AM on AM.EstablishmentId=E.id ANd (AM.IsDeleted=0 or AM.IsDeleted=null)
inner join [SeenClientAnswers] A on A.SeenclientAnswerMasterId=AM.id 
inner join SeenClientQuestions Q on Q.id=A.QuestionId and q.id in (37814,37815,37816,37817,37818,37819,37820,37821,37822,37823,37824,49784,50715,50716,52778,52531)
left outer join dbo.[Appuser] u on u.id=AM.CreatedBy
left outer join SeenClientAnswerChild SAC on AM.id=SAC.SeenClientAnswerMasterId WHERE A.RepeatCount=0
)S
pivot(
Max(Answer)
For  Question In (
[Date],[Vehicle registration],[Start time],[End time],[WIP number],[Travel (KM)],[Productive],[Type of work],[Start KM],[End KM],[Chargeable KM],[Work KM]
))P
)K ON K.ReferenceNo=J.ReferenceNo
)z WHERE z.UserName<>'Masslift Admin'

