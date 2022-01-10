




CREATE VIEW [dbo].[JDF_BI_Vw_FACT_Magnitude]
AS
/*
WITH CTE AS
(

SELECT FACT.Id,FACT.Id AS SCAM_ID,
--(CASE WHEN FACT.[Company Id] = 27 AND ET.IsNorth = 0 THEN -1001 ELSE FACT.[Company Id] END) AS [Company Id],
FACT.[Company Id] AS [Company Id],
FACT.EstablishmentId,FACT.[EstablishmentGroupId],
AppUserId AS [Sales Person Id],
ISNULL(ET.TownId,-100) AS TownId,IsResolved AS [Status],
CONVERT(DATETIME,FACT.[Post Date]) AS [Date],
FACT.Latitude AS Latitude, 
FACT.Longitude AS Longitude,
SPName,ISNULL(ET.[Town Name],'UNDEFINED') AS TName,BranchName--,JDF_Financed
FROM (
	SELECT Id,EstablishmentId,[EstablishmentGroupId],AppUserId,[Company Id],[Company Name],IsResolved,/*IsPositive,SenderCellNo,*/
	[Post Date],Latitude,Longitude,SPName,
	[Town Name],BranchName,JDF_Financed
	FROM (
		SELECT SAM.Id,EstablishmentId,
		E.Establishmentgroupid AS [EstablishmentGroupId],AppUserId,
		G.Id AS [Company Id],G.GroupName AS [Company Name],IsResolved,
		CONVERT(DATE,DATEADD(mi,SAM.TimeOffSet,SAM.CreatedOn)) AS [Post Date],
		Latitude,Longitude,[U].[Name] AS SPName,
		ISNULL(UPPER(LTRIM(RTRIM(REPLACE(EstablishmentName,'SALES CALL','')))),'UNDEFINED') AS [Town Name],
		ISNULL(UPPER(LTRIM(RTRIM(REPLACE(EstablishmentName,'SALES CALL','')))),'UNDEFINED') AS BranchName,
		U.Name AS UserName,
		(CASE WHEN  EG.Id IN (2661,963) AND FIN.[Financed By] = 'John Deere Finance' THEN 1 
		ELSE (CASE WHEN  EG.Id in(2315,2667,2729,2727,2731,2733) THEN 1 ELSE 0 END)END) AS JDF_Financed
		FROM dbo.SeenClientAnswerMaster AS SAM 
		LEFT OUTER JOIN dbo.JDF_BI_Vw_FinancedBy FIN ON Fin.SeenClientAnswerMasterId = SAM.Id 
		LEFT OUTER JOIN dbo.Establishment E ON E.Id = SAM.EstablishmentId AND E.IsDeleted = 0
		LEFT OUTER JOIN dbo.EstablishmentGroup EG ON EG.Id = E.Establishmentgroupid AND EG.IsDeleted = 0
		LEFT OUTER JOIN dbo.[group] G ON G.Id = EG.Groupid AND G.IsDeleted = 0
		LEFT OUTER JOIN dbo.AppUser U ON SAM.AppUserId = U.Id AND U.IsDeleted = 0
		WHERE G.Id IN (27,353,358,359,360,361)  --AFGRI & JOHN DEERE
		AND EG.Id IN (963,2315,2661,2667,2729,2727,2731,2733)
		AND U.Id NOT IN (363,54)
		AND SAM.IsDeleted = 0 
	) Z
	WHERE JDF_Financed = 1
) FACT
LEFT OUTER JOIN [dbo].[Establishment_Town] ET ON ET.[Town Name] = FACT.[Town Name] --3199
) 


SELECT * FROM CTE WHERE [Date] < GETDATE()

UNION ALL
SELECT ROW_NUMBER()OVER(ORDER BY Id) + 10000000 AS Id,Id AS SCAM_ID,
[Company Id],
EstablishmentId,Z.GroupId AS [EstablishmentGroupId],
[Sales Person Id],TownId,[Status],[Date],Latitude,Longitude,SPName,TName,BranchName--,JDF_Financed

FROM CTE
INNER JOIN (
	SELECT * FROM 
	(
		SELECT C.SeenClientAnswerMasterId,
		(CASE WHEN C.Conversation LIKE '%Quote%' THEN -100 ELSE
		(CASE WHEN C.Conversation LIKE '%Information Collection%' THEN -200 ELSE
		(CASE WHEN C.Conversation LIKE '%At Credit%' THEN -300 ELSE
		(CASE WHEN C.Conversation LIKE '%Extra Information%' THEN -400 ELSE
		(CASE WHEN C.Conversation LIKE '%Approved%' And C.Conversation Not LIKE '%Pre-approved%' THEN -500 ELSE
		(CASE WHEN C.Conversation LIKE '%Pre-approved%' THEN -600 ELSE
		(CASE WHEN C.Conversation LIKE '%Disbursement%' THEN -700 ELSE
		(CASE WHEN C.Conversation LIKE '%DCP%' THEN -800 END)END)END)END)END)END)END)END) AS GroupId
		FROM EstablishmentGroup EG
		JOIN Establishment E ON EG.Id = E.Establishmentgroupid 
		JOIN SeenClientAnswerMaster SAM ON SAM.EstablishmentId = E.Id
		JOIN dbo.AppUser U ON SAM.AppUserId = U.Id AND U.IsDeleted = 0
		JOIN CloseLoopAction C ON C.SeenClientAnswerMasterId = SAM.ID
		WHERE EG.Id in (2315,2667,2729,2727,2731,2733)
		AND EG.IsDeleted = 0
		AND U.Id NOT IN (363,54)
		AND SAM.IsDeleted = 0 
	) Z
	WHERE GroupId IS NOT NULL
) Z ON Z.SeenClientAnswerMasterId = CTE.Id
*/
/*
WITH CTE AS
(

SELECT FACT.Id,FACT.Id AS SCAM_ID,
--(CASE WHEN FACT.[Company Id] = 27 AND ET.IsNorth = 0 THEN -1001 ELSE FACT.[Company Id] END) AS [Company Id],
FACT.[Company Id] AS [Company Id],
FACT.EstablishmentId,FACT.[EstablishmentGroupId],
AppUserId AS [Sales Person Id],
ISNULL(ET.TownId,-100) AS TownId,IsResolved AS [Status],
CONVERT(DATETIME,FACT.[Post Date]) AS [Date],
FACT.Latitude AS Latitude, 
FACT.Longitude AS Longitude,
SPName,ISNULL(ET.[Town Name],'UNDEFINED') AS TName,BranchName--,JDF_Financed
FROM (
	SELECT Id,EstablishmentId,[EstablishmentGroupId],AppUserId,[Company Id],[Company Name],IsResolved,/*IsPositive,SenderCellNo,*/
	[Post Date],Latitude,Longitude,SPName,
	[Town Name],BranchName,JDF_Financed
	FROM (
		SELECT SAM.Id,EstablishmentId,
		E.Establishmentgroupid AS [EstablishmentGroupId],AppUserId,
		G.Id AS [Company Id],G.GroupName AS [Company Name],IsResolved,
		CONVERT(DATE,DATEADD(mi,SAM.TimeOffSet,SAM.CreatedOn)) AS [Post Date],
		Latitude,Longitude,[U].[Name] AS SPName,
		ISNULL(UPPER(LTRIM(RTRIM(REPLACE(EstablishmentName,'SALES CALL','')))),'UNDEFINED') AS [Town Name],
		ISNULL(UPPER(LTRIM(RTRIM(REPLACE(EstablishmentName,'SALES CALL','')))),'UNDEFINED') AS BranchName,
		U.Name AS UserName,
		(CASE WHEN  EG.Id IN (2661,963) AND FIN.[Financed By] = 'John Deere Finance' THEN 1 
		ELSE (CASE WHEN  EG.Id in(2315,2667,2729,2727,2731,2733) THEN 1 ELSE 0 END)END) AS JDF_Financed
		FROM dbo.SeenClientAnswerMaster AS SAM 
		LEFT OUTER JOIN dbo.JDF_BI_Vw_FinancedBy FIN ON Fin.SeenClientAnswerMasterId = SAM.Id 
		LEFT OUTER JOIN dbo.Establishment E ON E.Id = SAM.EstablishmentId AND E.IsDeleted = 0
		LEFT OUTER JOIN dbo.EstablishmentGroup EG ON EG.Id = E.Establishmentgroupid AND EG.IsDeleted = 0
		LEFT OUTER JOIN dbo.[group] G ON G.Id = EG.Groupid AND G.IsDeleted = 0
		LEFT OUTER JOIN dbo.AppUser U ON SAM.AppUserId = U.Id AND U.IsDeleted = 0
		WHERE G.Id IN (27,353,358,359,360,361)  --AFGRI & JOHN DEERE
		AND EG.Id IN (963,2315,2661,2667,2729,2727,2731,2733)
		AND U.Id NOT IN (363,54)
		AND SAM.IsDeleted = 0 
	) Z
	WHERE JDF_Financed = 1
) FACT
LEFT OUTER JOIN [dbo].[Establishment_Town] ET ON ET.[Town Name] = FACT.[Town Name] --3199
) 


SELECT * FROM CTE WHERE [Date] < GETDATE()

UNION ALL
SELECT ROW_NUMBER()OVER(ORDER BY Id) + 10000000 AS Id,Id AS SCAM_ID,
[Company Id],
EstablishmentId,Z.GroupId AS [EstablishmentGroupId],
[Sales Person Id],TownId,[Status],[Date],Latitude,Longitude,SPName,TName,BranchName--,JDF_Financed

FROM CTE
INNER JOIN (
	SELECT * FROM 
	(
		SELECT C.SeenClientAnswerMasterId,
		(CASE WHEN C.Conversation LIKE '%Quote%' THEN -100 ELSE
		(CASE WHEN C.Conversation LIKE '%Information Collection%' THEN -200 ELSE
		(CASE WHEN C.Conversation LIKE '%At Credit%' THEN -300 ELSE
		(CASE WHEN C.Conversation LIKE '%Extra Information%' THEN -400 ELSE
		(CASE WHEN C.Conversation LIKE '%Approved%' And C.Conversation Not LIKE '%Pre-approved%' THEN -500 ELSE
		(CASE WHEN C.Conversation LIKE '%Pre-approved%' THEN -600 ELSE
		(CASE WHEN C.Conversation LIKE '%Disbursement%' THEN -700 ELSE
		(CASE WHEN C.Conversation LIKE '%DCP%' THEN -800  ELSE 
		(CASE WHEN C.Conversation Like '%Resolved - Ref#%' or C.Conversation Like 'Resolved' THEN -900 END) END)END)END)END)END)END)END)END) AS GroupId
		FROM EstablishmentGroup EG
		JOIN Establishment E ON EG.Id = E.Establishmentgroupid 
		JOIN SeenClientAnswerMaster SAM ON SAM.EstablishmentId = E.Id
		JOIN dbo.AppUser U ON SAM.AppUserId = U.Id AND U.IsDeleted = 0
		JOIN CloseLoopAction C ON C.SeenClientAnswerMasterId = SAM.ID
		WHERE EG.Id in (2315,2667,2729,2727,2731,2733)
		AND EG.IsDeleted = 0
		AND U.Id NOT IN (363,54)
		AND SAM.IsDeleted = 0 
	) Z
	WHERE GroupId IS NOT NULL
) Z ON Z.SeenClientAnswerMasterId = CTE.Id




*/

WITH CTE AS
(

SELECT FACT.Id,FACT.Id AS SCAM_ID,
--(CASE WHEN FACT.[Company Id] = 27 AND ET.IsNorth = 0 THEN -1001 ELSE FACT.[Company Id] END) AS [Company Id],
FACT.[Company Id] AS [Company Id],
FACT.EstablishmentId,FACT.[EstablishmentGroupId],
AppUserId AS [Sales Person Id],
ISNULL(ET.TownId,-100) AS TownId,IsResolved AS [Status],
CONVERT(DATETIME,FACT.[Post Date]) AS [Date],
FACT.Latitude AS Latitude, 
FACT.Longitude AS Longitude,
SPName,ISNULL(ET.[Town Name],'UNDEFINED') AS TName,BranchName--,JDF_Financed
FROM (
	SELECT Id,EstablishmentId,[EstablishmentGroupId],AppUserId,[Company Id],[Company Name],IsResolved,/*IsPositive,SenderCellNo,*/
	[Post Date],Latitude,Longitude,SPName,
	[Town Name],BranchName,JDF_Financed
	FROM (
		SELECT SAM.Id,EstablishmentId,
		E.Establishmentgroupid AS [EstablishmentGroupId],AppUserId,
		G.Id AS [Company Id],G.GroupName AS [Company Name],IsResolved,
		CONVERT(DATE,DATEADD(mi,SAM.TimeOffSet,SAM.CreatedOn)) AS [Post Date],
		Latitude,Longitude,[U].[Name] AS SPName,
		ISNULL(UPPER(LTRIM(RTRIM(REPLACE(EstablishmentName,'SALES CALL','')))),'UNDEFINED') AS [Town Name],
		ISNULL(UPPER(LTRIM(RTRIM(REPLACE(EstablishmentName,'SALES CALL','')))),'UNDEFINED') AS BranchName,
		U.Name AS UserName,
		(CASE WHEN  EG.Id IN (2661,963) AND FIN.[Financed By] = 'John Deere Finance' THEN 1 
		ELSE (CASE WHEN  EG.Id in(2315,2667,2729,2727,2731,2733) THEN 1 ELSE 0 END)END) AS JDF_Financed
		FROM dbo.SeenClientAnswerMaster AS SAM 
		LEFT OUTER JOIN dbo.JDF_BI_Vw_FinancedBy FIN ON Fin.SeenClientAnswerMasterId = SAM.Id 
		LEFT OUTER JOIN dbo.Establishment E ON E.Id = SAM.EstablishmentId AND E.IsDeleted = 0
		LEFT OUTER JOIN dbo.EstablishmentGroup EG ON EG.Id = E.Establishmentgroupid AND EG.IsDeleted = 0
		LEFT OUTER JOIN dbo.[group] G ON G.Id = EG.Groupid AND G.IsDeleted = 0
		LEFT OUTER JOIN dbo.AppUser U ON SAM.AppUserId = U.Id AND U.IsDeleted = 0
		WHERE G.Id IN (27,353,358,359,360,361)  --AFGRI & JOHN DEERE
		AND EG.Id IN (963,2315,2661,2667,2729,2727,2731,2733)
		AND U.Id NOT IN (363,54)
		AND SAM.IsDeleted = 0 
	) Z
	WHERE JDF_Financed = 1
) FACT
LEFT OUTER JOIN [dbo].[Establishment_Town] ET ON ET.[Town Name] = FACT.[Town Name] --3199
) 


SELECT * FROM CTE WHERE [Date] < GETDATE()

UNION ALL
SELECT ROW_NUMBER()OVER(ORDER BY Id) + 10000000 AS Id,Id AS SCAM_ID,
[Company Id],
EstablishmentId,Z.GroupId AS [EstablishmentGroupId],
[Sales Person Id],TownId,[Status],[Date],Latitude,Longitude,SPName,TName,BranchName--,JDF_Financed

FROM CTE
INNER JOIN (
	SELECT * FROM 
	(
		SELECT C.SeenClientAnswerMasterId,
		(CASE WHEN C.Conversation LIKE '%Quote%' THEN -100 else
		 (CASE WHEN C.Conversation LIKE '%Information Collection%' THEN -200 else
		(CASE WHEN C.Conversation LIKE '%At Analyst%' THEN -300 else
		 (CASE WHEN C.Conversation LIKE '%Approved%' And C.Conversation Not LIKE '%Pre-approved%' THEN -400 else
		(CASE WHEN C.Conversation LIKE '%Extra Information%' THEN -500 else
			(CASE	 WHEN C.Conversation LIKE '%Contract Requested%' THEN -600 else
			(CASE	  WHEN C.Conversation LIKE '%DISBURSEMENT%' THEN -700 else
				(CASE   WHEN C.Conversation LIKE '%Lost Deal%' THEN -800 else
		(CASE WHEN C.Conversation LIKE '%Pre-approved%' THEN -900 else
	(CASE	 when (C.Conversation Like '%Resolved - Ref#%' or C.Conversation Like 'Resolved') Then -1000 end)end ) END)END)END)END)END)END)END)END) AS GroupId
		FROM EstablishmentGroup EG
		JOIN Establishment E ON EG.Id = E.Establishmentgroupid 
		JOIN SeenClientAnswerMaster SAM ON SAM.EstablishmentId = E.Id
		JOIN dbo.AppUser U ON SAM.AppUserId = U.Id AND U.IsDeleted = 0
		JOIN CloseLoopAction C ON C.SeenClientAnswerMasterId = SAM.ID
		WHERE EG.Id in (2315,2667,2729,2727,2731,2733)
		AND EG.IsDeleted = 0
		AND U.Id NOT IN (363,54)
		AND SAM.IsDeleted = 0 
	) Z
	WHERE GroupId IS NOT NULL
) Z ON Z.SeenClientAnswerMasterId = CTE.Id



