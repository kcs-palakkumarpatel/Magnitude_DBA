CREATE VIEW dbo.PB_VW_Masslift_Fact_Salesmen AS
SELECT ReferenceNo,
RepeatCount,
[Sale reps],
[New sales target] AS [New sales target ],
[New sales YTD],
[Used sales target],
[Used sales YTD],
Month AS [Month ],
Year AS [Year ] FROM masslift_salesmen_summary

--UNION ALL

--SELECT 
--ReferenceNo,
--RepeatCount,
--[Sale representatives] as [Sale reps],
--[New sales target ],
--[New sales YTD],
--[Used sales target],
--[Used sales YTD],
--[Month ],
--[Year ]

--FROM(
--SELECT  E.EstablishmentName,DATEADD(MINUTE,AM.TimeOffSet,AM.CreatedOn) AS CapturedDate,AM.id AS ReferenceNo,
--AM.IsPositive,AM.IsResolved AS Status,AM.PI,
--A.Detail AS Answer
--,Q.QuestionTitle AS Question ,U.Id AS UserId, u.name AS UserName,
--AM.Longitude,AM.Latitude,A.RepeatCount


--FROM dbo.[Group] G
--INNER JOIN EstablishmentGroup EG ON G.id=EG.groupid AND G.Id=463 AND EG.Id =5477
--INNER JOIN Establishment E ON  E.EstablishmentGroupId=EG.Id
--INNER JOIN SeenClientAnswerMaster AM ON AM.EstablishmentId=E.id AND (AM.IsDeleted=0 OR AM.IsDeleted=NULL) AND (AM.IsDisabled=0 OR AM.IsDisabled IS NULL)
--INNER JOIN [SeenClientAnswers] A ON A.SeenclientAnswerMasterId=AM.id
--INNER JOIN SeenClientQuestions Q ON Q.id=A.QuestionId AND Q.IsRequiredInBI=1
--LEFT OUTER JOIN dbo.[Appuser] u ON u.id=AM.CreatedBy
----left outer join ContactDetails CD on CD.contactMasterid=AM.ContactMasterid and CD.contactQuestionId=2839
--LEFT OUTER JOIN (
--	SELECT AM.SeenClientAnswerMasterid AS ReferenceNo,MIN(DATEADD(MINUTE,AM.TimeOffSet,AM.CreatedOn)) AS FirstResponseDate FROM 
--	AnswerMaster AM 
--	RIGHT OUTER JOIN seenclientanswermaster SAM ON SAM.Id=AM.SeenClientAnswerMasterId
--	GROUP BY AM.SeenClientAnswerMasterId
--) AS FRD ON FRD.ReferenceNo = AM.Id
--/*Where (G.Id=463 and EG.Id =5477 --and u.id not in (3722,3973)
--ANd (AM.IsDeleted=0 or AM.IsDeleted=null)) and (AM.IsDisabled=0 or AM.IsDisabled is null)
--and Q.id in(44690,44691,44692,44693,44694,44695,44696,44689,67960)*/
--) S
--PIVOT (
--MAX(Answer)
--FOR  Question IN (
--[Sale representatives],
--[New sales target ],
--[New sales YTD],
--[Used sales target],
--[Used sales YTD],
--[Month ],
--[Year ],
--[Monthly Capture]

--))P

