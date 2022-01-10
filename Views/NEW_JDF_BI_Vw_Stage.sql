


CREATE VIEW [dbo].[NEW_JDF_BI_Vw_Stage]
AS
/*
SELECT * FROM 
(
	SELECT C.SeenClientAnswerMasterId,
	CASE WHEN C.Conversation LIKE '%Quote%' THEN 'Quote' 
		 WHEN C.Conversation LIKE '%Information Collection%' THEN 'Information Collection' 
		 WHEN C.Conversation LIKE '%At Credit%' THEN 'At Credit' 
		 WHEN C.Conversation LIKE '%Extra Information%' THEN 'Extra Information' 
		 WHEN C.Conversation LIKE '%Approved%' And C.Conversation Not LIKE '%Pre-approved%' THEN 'Approved' 
		 WHEN C.Conversation LIKE '%Pre-approved%' THEN 'Pre-approved' 
		 WHEN C.Conversation LIKE '%DISBURSEMENT%' THEN 'DISBURSEMENT' 
		 WHEN C.Conversation LIKE '%DCP%' THEN 'DCP' 
	END AS StageName,

	CASE WHEN C.Conversation LIKE '%Quote%' THEN 1
		 WHEN C.Conversation LIKE '%Information Collection%' THEN 2
		 WHEN C.Conversation LIKE '%At Credit%' THEN 3
		 WHEN C.Conversation LIKE '%Extra Information%' THEN 4
		 WHEN C.Conversation LIKE '%Approved%' And C.Conversation Not LIKE '%Pre-approved%' THEN 5 
		 WHEN C.Conversation LIKE '%Pre-approved%' THEN 6
		 WHEN C.Conversation LIKE '%DISBURSEMENT%' THEN 7
		 WHEN C.Conversation LIKE '%DCP%' THEN 8
	END AS Stage_Level,
		DATEADD(mi,SAM.TimeOffSet,C.CreatedOn) AS CreatedOn
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
WHERE StageName IS NOT NULL

*/
/* SELECT * FROM 
(
	SELECT C.SeenClientAnswerMasterId,
	CASE WHEN C.Conversation LIKE '%Quote%' THEN 'Quote' 
		 WHEN C.Conversation LIKE '%Information Collection%' THEN 'Information Collection' 
		 WHEN C.Conversation LIKE '%At Credit%' THEN 'At Credit' 
		 WHEN C.Conversation LIKE '%Extra Information%' THEN 'Extra Information' 
		 WHEN C.Conversation LIKE '%Approved%' And C.Conversation Not LIKE '%Pre-approved%' THEN 'Approved' 
		 WHEN C.Conversation LIKE '%Pre-approved%' THEN 'Pre-approved' 
		 WHEN C.Conversation LIKE '%DISBURSEMENT%' THEN 'DISBURSEMENT' 
		 WHEN C.Conversation LIKE '%DCP%' THEN 'DCP' 
		 when (C.Conversation Like '%Resolved - Ref#%' or C.Conversation Like 'Resolved') Then 'Closed Deals'
	END AS StageName,

	CASE WHEN C.Conversation LIKE '%Quote%' THEN 1
		 WHEN C.Conversation LIKE '%Information Collection%' THEN 2
		 WHEN C.Conversation LIKE '%At Credit%' THEN 3
		 WHEN C.Conversation LIKE '%Extra Information%' THEN 4
		 WHEN C.Conversation LIKE '%Approved%' And C.Conversation Not LIKE '%Pre-approved%' THEN 5 
		 WHEN C.Conversation LIKE '%Pre-approved%' THEN 6
		 WHEN C.Conversation LIKE '%DISBURSEMENT%' THEN 7
		 WHEN C.Conversation LIKE '%DCP%' THEN 9
		 when (C.Conversation Like '%Resolved - Ref#%' or C.Conversation Like 'Resolved') Then 8
	END AS Stage_Level,
		DATEADD(mi,SAM.TimeOffSet,C.CreatedOn) AS CreatedOn
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
WHERE StageName IS NOT NULL


*/
SELECT * FROM 
(
	SELECT C.SeenClientAnswerMasterId,
	CASE WHEN C.Conversation LIKE '%Quote%' THEN 'Quote' 
		 WHEN C.Conversation LIKE '%Information Collection%' THEN 'Information Collection' 
		 WHEN C.Conversation LIKE '%At Analyst%' THEN 'At Analyst' 
		  WHEN C.Conversation LIKE '%Approved%' And C.Conversation Not LIKE '%Pre-approved%' THEN 'Approved' 
		 WHEN C.Conversation LIKE '%Extra Information%' THEN 'Extra Information' 
				 WHEN C.Conversation LIKE '%Contract Requested%' THEN 'Contract Requested' 
				  WHEN C.Conversation LIKE '%DISBURSEMENT%' THEN 'DISBURSEMENT' 
				   WHEN C.Conversation LIKE '%Lost Deal%' THEN 'Lost Deal' 
		 WHEN C.Conversation LIKE '%Pre-approved%' THEN 'Pre-approved' 
		

		 when (C.Conversation Like '%Resolved - Ref#%' or C.Conversation Like 'Resolved') Then 'Closed Deals'
	END AS StageName,

	 	CASE WHEN C.Conversation LIKE '%Quote%' THEN 1
		 WHEN C.Conversation LIKE '%Information Collection%' THEN 2 
		 WHEN C.Conversation LIKE '%At Analyst%' THEN 3
		  WHEN C.Conversation LIKE '%Approved%' And C.Conversation Not LIKE '%Pre-approved%' THEN 4 
		 WHEN C.Conversation LIKE '%Extra Information%' THEN 5
				 WHEN C.Conversation LIKE '%Contract Requested%' THEN 6
				  WHEN C.Conversation LIKE '%DISBURSEMENT%' THEN 7
				   WHEN C.Conversation LIKE '%Lost Deal%' THEN 8 
		 WHEN C.Conversation LIKE '%Pre-approved%' THEN 9 
		 when (C.Conversation Like '%Resolved - Ref#%' or C.Conversation Like 'Resolved') Then 10
	END AS Stage_Level,
		DATEADD(mi,SAM.TimeOffSet,C.CreatedOn) AS CreatedOn
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
WHERE StageName IS NOT NULL











