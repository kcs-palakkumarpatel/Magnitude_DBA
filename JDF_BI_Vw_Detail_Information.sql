



CREATE VIEW [dbo].[JDF_BI_Vw_Detail_Information]
AS
/*
SELECT EstablishmentGroup_Id,SeenClientAnswerMasterId,
(CASE WHEN CompanyId = 27 AND ET.IsNorth = 1 THEN 'AFGRI NORTH' ELSE 
(CASE WHEN CompanyId = 27 AND ET.IsNorth = 0 THEN 'AFGRI SOUTH' ELSE
[CompanyName] END)END) AS [CompanyName],
--[CompanyName] AS [CompanyName],
[PostDate],
EstablishmentGroupName,SalesPerson,[Establishment Name],
[Naam],[Van],[Selfoon Nommer],[E-Pos Adres],
[(1 = Swak ; 5 = Uitstekend)],[As ander, besryf asseblief],[Comments (No Confidential Information)],[Enige mededingende kwotasies?],
[Preferred financial solution?],[Prys],[Total Quote Amount],[Wat was die uiteinde van u besoek?],[Watter produkte was bespreek?],
[Quote Price],[Deposit Amount (This must be the amount)],[Estimated Equipment Delivery Date],[Follow Up Date],[Model],[Comments],
[Quote],[InformationCollection],[AtCredit],[ExtraInfo],[Approved],[PreApproved],[Disbursement],[DCP],
Stage1_Date,Stage2_Date,Stage3_Date,Stage4_Date,Stage5_Date,Stage6_Date,Stage7_Date,Stage8_Date,
Stage_1st_Days,Stage_2nd_Days,Stage_3rd_Days,Stage_4th_Days,Stage_5th_Days,Stage_6th_Days,Stage_7th_Days,Stage_8th_Days,
Stage_TotalDays,Flag

FROM (


	SELECT EstablishmentGroup_Id,SeenClientAnswerMasterId,CompanyId,[PostDate],
	[CompanyName],EstablishmentGroupName,SalesPerson,[Establishment Name],
	[Naam],[Van],[Selfoon Nommer],
	[E-Pos Adres],
	[Maatskappy Naam],
	[(1 = Swak ; 5 = Uitstekend)],
	[As ander, besryf asseblief],
	[Comments (No Confidential Information)],
	[Enige mededingende kwotasies?],
	[Preferred financial solution?],
	[Prys],
	[Total Quote Amount],
	[Wat was die uiteinde van u besoek?],
	[Watter produkte was bespreek?],
	NULL AS [Quote Price],
	NULL AS [Deposit Amount (This must be the amount)],
	NULL AS [Estimated Equipment Delivery Date],
	NULL AS [Follow Up Date],
	NULL AS [Model],
	NULL AS [Comments],
	NULL AS [Quote],
	NULL AS [InformationCollection],
	NULL AS [AtCredit],
	NULL AS [ExtraInfo],
	NULL AS [Approved],
	NULL AS [PreApproved],
	NULL AS [Disbursement],
	NULL AS [DCP],
	NULL AS Stage1_Date,
	NULL AS Stage2_Date,
	NULL AS Stage3_Date,
	NULL AS Stage4_Date,
	NULL AS Stage5_Date,
	NULL AS Stage6_Date,
	NULL AS Stage7_Date,
	NULL AS Stage8_Date,
	NULL AS Stage_1st_Days,
	NULL AS Stage_2nd_Days,
	NULL AS Stage_3rd_Days,
	NULL AS Stage_4th_Days,
	NULL AS Stage_5th_Days,
	NULL AS Stage_6th_Days,
	NULL AS Stage_7th_Days,
	NULL AS Stage_8th_Days,
	NULL AS Stage_TotalDays,
	0 AS Flag
	FROM (
		SELECT 
		DATEADD(mi,SAM.TimeOffSet,SAM.CreatedOn) AS [PostDate],
		SA.SeenClientAnswerMasterId,Q.QuestionTitle,SA.Detail ,G.Id AS CompanyId,
		G.GroupName AS [CompanyName],EG.Id AS EstablishmentGroup_Id,
		REPLACE(REPLACE(REPLACE(EG.EstablishmentGroupName,'01',''),'02',''),'03','') AS EstablishmentGroupName,
		ISNULL(U.Name,'UNDEFINED') AS SalesPerson,UPPER(ISNULL(EstablishmentName,'UNDEFINED')) AS [Establishment Name]
		FROM SeenClientQuestions Q
		INNER JOIN dbo.SeenClientAnswerMaster AS SAM ON SAM.SeenClientId = Q.SeenClientId  AND ISNULL(SAM.IsDeleted,0) = 0
		INNER JOIN dbo.SeenClientAnswers AS SA ON SA.SeenClientAnswerMasterId = SAM.Id AND SA.QuestionId = Q.Id AND ISNULL(SA.IsDeleted,0) = 0  
		INNER JOIN dbo.Establishment E ON E.Id = SAM.EstablishmentId AND E.EstablishmentGroupId IN (963,2661)
		INNER JOIN dbo.EstablishmentGroup EG ON E.EstablishmentGroupId = EG.Id AND E.IsDeleted = 0
		INNER JOIN dbo.[group] G ON G.Id = EG.GroupId AND EG.IsDeleted = 0
		INNER JOIN dbo.AppUser U ON U.Id = SAM.AppUserId AND U.IsDeleted = 0
		INNER JOIN dbo.JDF_BI_Vw_FinancedBy FIN ON Fin.SeenClientAnswerMasterId = SAM.Id AND FIN.[Financed By] = 'John Deere Finance'
		WHERE Q.IsDeleted = 0
		AND U.Id NOT IN (363,54)
	) S
	PIVOT (
		MAX(Detail)
		FOR  QuestionTitle IN (
			[Naam],
			[Van],
			[Selfoon Nommer],
			[E-Pos Adres],
			[Maatskappy Naam],
			[Watter produkte was bespreek?], 
			[(1 = Swak ; 5 = Uitstekend)],
			[As ander, besryf asseblief],
			[Comments (No Confidential Information)],
			[Enige mededingende kwotasies?],
			[Preferred financial solution?],
			[Prys],
			[Total Quote Amount],
			[Wat was die uiteinde van u besoek?]
		)
	) P

UNION ALL

Select EstablishmentGroup_Id,SeenClientAnswerMasterId,CompanyId,[PostDate],
[CompanyName],EstablishmentGroupName,SalesPerson,[Establishment Name],
[Naam],[Van],[Selfoon Nommer],[E-Pos Adres],[Maatskappy Naam],[(1 = Swak ; 5 = Uitstekend)],
[As ander, besryf asseblief],[Comments (No Confidential Information)],[Enige mededingende kwotasies?],
[Preferred financial solution?],[Prys],[Total Quote Amount],[Wat was die uiteinde van u besoek?],
[Watter produkte was bespreek?],[Quote Price],[Deposit Amount (This must be the amount)],
[Estimated Equipment Delivery Date],[Follow Up Date],[Model],[Comments],
[Quote],[InformationCollection],[AtCredit],[ExtraInfo],[Approved],[PreApproved],[Disbursement],[DCP],
Stage1_Date,Stage2_Date,Stage3_Date,Stage4_Date,Stage5_Date,Stage6_Date,Stage7_Date,Stage8_Date,
Stage_1st_Days,Stage_2nd_Days,Stage_3rd_Days,Stage_4rd_Days,Stage_5th_Days,Stage_6th_Days,Stage_7th_Days,Stage_8th_Days,
IsNull(Stage_1st_Days,0)+ IsNull(Stage_2nd_Days,0) + IsNull(Stage_3rd_Days,0) + IsNull(Stage_4rd_Days,0) + 
IsNull(Stage_5th_Days,0) + IsNull(Stage_6th_Days,0) + IsNull(Stage_7th_Days,0) + IsNull(Stage_8th_Days,0) as Stage_TotalDays,
Flag
FROM (
	SELECT EstablishmentGroup_Id,SeenClientAnswerMasterId,CompanyId,
	[PostDate],
	[CompanyName],EstablishmentGroupName,SalesPerson,[Establishment Name],
	[Naam],
	[Van],
	[Selfoon Nommer],
	[E-Pos Adres],
	[Maatskappy Naam],
	NULL AS [(1 = Swak ; 5 = Uitstekend)],
	NULL AS [As ander, besryf asseblief],
	NULL AS [Comments (No Confidential Information)],
	NULL AS [Enige mededingende kwotasies?],
	NULL AS [Preferred financial solution?],
	NULL AS [Prys],
	NULL AS [Total Quote Amount],
	NULL AS [Wat was die uiteinde van u besoek?],
	NULL AS [Watter produkte was bespreek?],
	[Quote Price],
	LEFT(SUBSTRING([Deposit Amount (This must be the amount)], PATINDEX('%[0-9.-]%', [Deposit Amount (This must be the amount)]), 8000),
			   PATINDEX('%[^0-9.-]%', SUBSTRING([Deposit Amount (This must be the amount)], PATINDEX('%[0-9.-]%', [Deposit Amount (This must be the amount)]), 8000) + 'X') -1)
	AS [Deposit Amount (This must be the amount)],
	[Estimated Equipment Delivery Date],
	[Follow Up Date],
	[Model],
	[Comments],
	[Quote],[InformationCollection],[AtCredit],[ExtraInfo],[Approved],[PreApproved],[Disbursement],[DCP],
	Stage1_Date,Stage2_Date,Stage3_Date,Stage4_Date,Stage5_Date,Stage6_Date,Stage7_Date,Stage8_Date,
	DATEDIFF(DAY,[PostDate],Stage1_Date) + 1 AS Stage_1st_Days,
	DATEDIFF(DAY,COALESCE(Stage1_Date,[PostDate]),[InformationCollection]) + 1 AS Stage_2nd_Days,
	DATEDIFF(DAY,COALESCE(Stage2_Date,Stage1_Date,[PostDate]),[AtCredit]) + 1 AS Stage_3rd_Days,
	DATEDIFF(DAY,COALESCE(Stage3_Date,Stage2_Date,Stage1_Date,[PostDate]),[ExtraInfo]) + 1 AS Stage_4rd_Days,
	DATEDIFF(DAY,COALESCE(Stage4_Date,Stage3_Date,Stage2_Date,Stage1_Date,[PostDate]),[Approved]) + 1 AS Stage_5th_Days,
	DATEDIFF(DAY,COALESCE(Stage5_Date,Stage4_Date,Stage3_Date,Stage2_Date,Stage1_Date,[PostDate]),[PreApproved]) + 1 AS Stage_6th_Days,
	DATEDIFF(DAY,COALESCE(Stage6_Date,Stage5_Date,Stage4_Date,Stage3_Date,Stage2_Date,Stage1_Date,[PostDate]),[Disbursement]) + 1 AS Stage_7th_Days,
	DATEDIFF(DAY,COALESCE(Stage7_Date,Stage6_Date,Stage5_Date,Stage4_Date,Stage3_Date,Stage2_Date,Stage1_Date,[PostDate]),[DCP]) + 1 AS Stage_8th_Days,
	Flag
	FROM (
		SELECT 
		DATEADD(mi,SAM.TimeOffSet,SAM.CreatedOn) AS [PostDate],
		SA.SeenClientAnswerMasterId,Q.QuestionTitle,SA.Detail ,G.Id AS CompanyId,
		G.GroupName AS [CompanyName],EG.Id AS EstablishmentGroup_Id,
		REPLACE(REPLACE(REPLACE(EG.EstablishmentGroupName,'01',''),'02',''),'03','') AS EstablishmentGroupName,
		ISNULL(U.Name,'UNDEFINED') AS SalesPerson,UPPER(ISNULL(EstablishmentName,'UNDEFINED')) AS [Establishment Name],
		[Quote],[InformationCollection],[AtCredit],[ExtraInfo],[Approved],[PreApproved],[Disbursement],[DCP],
		Stage1_Date,Stage2_Date,Stage3_Date,Stage4_Date,Stage5_Date,Stage6_Date,Stage7_Date,Stage8_Date,Flag
		FROM SeenClientQuestions Q
		INNER JOIN dbo.SeenClientAnswerMaster AS SAM ON SAM.SeenClientId = Q.SeenClientId  AND ISNULL(SAM.IsDeleted,0) = 0
		INNER JOIN dbo.SeenClientAnswers AS SA ON SA.SeenClientAnswerMasterId = SAM.Id AND SA.QuestionId = Q.Id AND ISNULL(SA.IsDeleted,0) = 0  
		INNER JOIN dbo.Establishment E ON E.Id = SAM.EstablishmentId AND E.EstablishmentGroupId in( 2315,2667,2729,2727,2731,2733)
		INNER JOIN dbo.EstablishmentGroup EG ON E.EstablishmentGroupId = EG.Id AND E.IsDeleted = 0
		INNER JOIN dbo.[group] G ON G.Id = EG.GroupId AND EG.IsDeleted = 0
		INNER JOIN dbo.AppUser U ON U.Id = SAM.AppUserId AND U.IsDeleted = 0
		LEFT JOIN (
			SELECT SeenClientAnswerMasterId,
			MAX(CASE WHEN StageName = 'Quote' THEN CreatedOn ELSE NULL END) AS Quote,
			MAX(CASE WHEN StageName = 'Information Collection' THEN CreatedOn ELSE NULL END) AS InformationCollection,
			MAX(CASE WHEN StageName = 'At Credit' THEN CreatedOn ELSE NULL END) AS AtCredit,
			MAX(CASE WHEN StageName = 'Extra Information' THEN CreatedOn ELSE NULL END) AS ExtraInfo,
			MAX(CASE WHEN StageName = 'Approved' THEN CreatedOn ELSE NULL END) AS Approved,
			MAX(CASE WHEN StageName = 'Pre-approved' THEN CreatedOn ELSE NULL END) AS PreApproved,
			MAX(CASE WHEN StageName = 'Disbursement' THEN CreatedOn ELSE NULL END) AS Disbursement,
			MAX(CASE WHEN StageName = 'DCP' THEN CreatedOn ELSE NULL END) AS DCP,

			MAX(CASE WHEN Stage_Level =1 THEN CreatedOn ELSE NULL END) AS Stage1_Date,
			MAX(CASE WHEN Stage_Level =2 THEN CreatedOn ELSE NULL END) AS Stage2_Date,
			MAX(CASE WHEN Stage_Level =3 THEN CreatedOn ELSE NULL END) AS Stage3_Date,
			MAX(CASE WHEN Stage_Level = 4 THEN CreatedOn ELSE NULL END) AS Stage4_Date,
			MAX(CASE WHEN Stage_Level = 5 THEN CreatedOn ELSE NULL END) AS Stage5_Date,
			MAX(CASE WHEN Stage_Level = 6 THEN CreatedOn ELSE NULL END) AS Stage6_Date,
			MAX(CASE WHEN Stage_Level = 7 THEN CreatedOn ELSE NULL END) AS Stage7_Date,
			MAX(CASE WHEN Stage_Level = 8 THEN CreatedOn ELSE NULL END) AS Stage8_Date,
			1 AS Flag
			FROM [dbo].[NEW_JDF_BI_Vw_Stage]
			GROUP BY SeenClientAnswerMasterId
		) Stage ON Stage.SeenClientAnswerMasterId = SAM.Id
		WHERE Q.IsDeleted = 0
		AND U.Id NOT IN (363,54)
	) S
	PIVOT (
		MAX(Detail)
		FOR  QuestionTitle IN (
			[Deposit Amount (This must be the amount)],
			[Estimated Equipment Delivery Date],
			[Maatskappy Naam],
			[Quote Price],
			[Selfoon Nommer],
			[Comments],
			[Van],
			[E-Pos Adres],
			[Follow Up Date],
			[Model],
			[Naam]
		)
	) P
) X

/*Stage Data section*/
UNION ALL 

	SELECT EstablishmentGroup_Id,SeenClientAnswerMasterId,CompanyId,
	[PostDate],	[CompanyName],EstablishmentGroupName,SalesPerson,[Establishment Name],
	[Naam],	[Van],	[Selfoon Nommer],[E-Pos Adres],	[Maatskappy Naam],
	[(1 = Swak ; 5 = Uitstekend)],[As ander, besryf asseblief],	[Comments (No Confidential Information)],
	[Enige mededingende kwotasies?],[Preferred financial solution?],[Prys],
	[Total Quote Amount],[Wat was die uiteinde van u besoek?],[Watter produkte was bespreek?],
	[Quote Price],[Deposit Amount (This must be the amount)],[Estimated Equipment Delivery Date],
	[Follow Up Date],[Model],[Comments],
	[Quote],[InformationCollection],[AtCredit],[ExtraInfo],[Approved],[PreApproved],[Disbursement],[DCP],
	Stage1_Date,Stage2_Date,Stage3_Date,Stage4_Date,Stage5_Date,Stage6_Date,Stage7_Date,Stage8_Date,
	Stage_1st_Days,Stage_2nd_Days,Stage_3rd_Days,Stage_4rd_Days,Stage_5th_Days,Stage_6th_Days,Stage_7th_Days,Stage_8th_Days,
	IsNull(Stage_1st_Days,0)+ IsNull(Stage_2nd_Days,0) + IsNull(Stage_3rd_Days,0) + IsNull(Stage_4rd_Days,0) + 
	IsNull(Stage_5th_Days,0) + IsNull(Stage_6th_Days,0) + IsNull(Stage_7th_Days,0) + IsNull(Stage_8th_Days,0) as Stage_TotalDays,
	Flag
	FROM (
		SELECT EstablishmentGroup_Id,SeenClientAnswerMasterId,CompanyId,
		[PostDate],
		[CompanyName],EstablishmentGroupName,SalesPerson,[Establishment Name],
		[Naam],
		[Van],
		[Selfoon Nommer],
		[E-Pos Adres],
		[Maatskappy Naam],
		NULL AS [(1 = Swak ; 5 = Uitstekend)],
		NULL AS [As ander, besryf asseblief],
		NULL AS [Comments (No Confidential Information)],
		NULL AS [Enige mededingende kwotasies?],
		NULL AS [Preferred financial solution?],
		NULL AS [Prys],
		NULL AS [Total Quote Amount],
		NULL AS [Wat was die uiteinde van u besoek?],
		NULL AS [Watter produkte was bespreek?],
		[Quote Price],
		LEFT(SUBSTRING([Deposit Amount (This must be the amount)], PATINDEX('%[0-9.-]%', [Deposit Amount (This must be the amount)]), 8000),
					PATINDEX('%[^0-9.-]%', SUBSTRING([Deposit Amount (This must be the amount)], PATINDEX('%[0-9.-]%', [Deposit Amount (This must be the amount)]), 8000) + 'X') -1)
		AS [Deposit Amount (This must be the amount)],
		[Estimated Equipment Delivery Date],
		[Follow Up Date],
		[Model],
		[Comments],
		[Quote],[InformationCollection],[AtCredit],[ExtraInfo],[Approved],[PreApproved],[Disbursement],[DCP],
		Stage1_Date,Stage2_Date,Stage3_Date,Stage4_Date,Stage5_Date,Stage6_Date,Stage7_Date,Stage8_Date,
		DATEDIFF(DAY,[PostDate],Stage1_Date) + 1 AS Stage_1st_Days,
		DATEDIFF(DAY,COALESCE(Stage1_Date,[PostDate]),[InformationCollection]) + 1 AS Stage_2nd_Days,
		DATEDIFF(DAY,COALESCE(Stage2_Date,Stage1_Date,[PostDate]),[AtCredit]) + 1 AS Stage_3rd_Days,
		DATEDIFF(DAY,COALESCE(Stage3_Date,Stage2_Date,Stage1_Date,[PostDate]),[ExtraInfo]) + 1 AS Stage_4rd_Days,
		DATEDIFF(DAY,COALESCE(Stage4_Date,Stage3_Date,Stage2_Date,Stage1_Date,[PostDate]),[Approved]) + 1 AS Stage_5th_Days,
		DATEDIFF(DAY,COALESCE(Stage5_Date,Stage4_Date,Stage3_Date,Stage2_Date,Stage1_Date,[PostDate]),[PreApproved]) + 1 AS Stage_6th_Days,
		DATEDIFF(DAY,COALESCE(Stage6_Date,Stage5_Date,Stage4_Date,Stage3_Date,Stage2_Date,Stage1_Date,[PostDate]),[Disbursement]) + 1 AS Stage_7th_Days,
		DATEDIFF(DAY,COALESCE(Stage7_Date,Stage6_Date,Stage5_Date,Stage4_Date,Stage3_Date,Stage2_Date,Stage1_Date,[PostDate]),[DCP]) + 1 AS Stage_8th_Days,Flag
		FROM (
			SELECT
			DATEADD(mi,SAM.TimeOffSet,SAM.CreatedOn) AS [PostDate],
			F.Id AS SeenClientAnswerMasterId,Q.QuestionTitle,SA.Detail ,G.Id AS CompanyId,
			G.GroupName AS [CompanyName],F.EstablishmentGroupId AS EstablishmentGroup_Id,
			REPLACE(REPLACE(REPLACE(EG.EstablishmentGroupName,'01',''),'02',''),'03','') AS EstablishmentGroupName,
			ISNULL(U.Name,'UNDEFINED') AS SalesPerson,UPPER(ISNULL(EstablishmentName,'UNDEFINED')) AS [Establishment Name],
			[Quote],[InformationCollection],[AtCredit],[ExtraInfo],[Approved],[PreApproved],[Disbursement],[DCP],
			Stage1_Date,Stage2_Date,Stage3_Date,Stage4_Date,Stage5_Date,Stage6_Date,Stage7_Date,Stage8_Date,Flag
			FROM JDF_BI_Vw_FACT_Magnitude F
			INNER JOIN dbo.SeenClientAnswerMaster AS SAM ON F.Scam_Id = SAM.Id
			INNER JOIN SeenClientQuestions Q ON SAM.SeenClientId = Q.SeenClientId  AND ISNULL(Q.IsDeleted,0) = 0
			INNER JOIN dbo.SeenClientAnswers AS SA ON SA.SeenClientAnswerMasterId = SAM.Id AND SA.QuestionId = Q.Id AND ISNULL(SA.IsDeleted,0) = 0  
			INNER JOIN dbo.Establishment E ON E.Id = SAM.EstablishmentId AND E.EstablishmentGroupId in(2315,2667,2729,2727,2731,2733)
			INNER JOIN dbo.EstablishmentGroup EG ON E.EstablishmentGroupId = EG.Id AND E.IsDeleted = 0
			INNER JOIN dbo.[group] G ON G.Id = EG.GroupId AND EG.IsDeleted = 0
			INNER JOIN dbo.AppUser U ON U.Id = SAM.AppUserId AND U.IsDeleted = 0
			LEFT JOIN 
			(
				SELECT SeenClientAnswerMasterId,
				MAX(CASE WHEN StageName = 'Quote' THEN CreatedOn ELSE NULL END) AS Quote,
				MAX(CASE WHEN StageName = 'Information Collection' THEN CreatedOn ELSE NULL END) AS InformationCollection,
				MAX(CASE WHEN StageName = 'At Credit' THEN CreatedOn ELSE NULL END) AS AtCredit,
				MAX(CASE WHEN StageName = 'Extra Information' THEN CreatedOn ELSE NULL END) AS ExtraInfo,
				MAX(CASE WHEN StageName = 'Approved' THEN CreatedOn ELSE NULL END) AS Approved,
				MAX(CASE WHEN StageName = 'Pre-approved' THEN CreatedOn ELSE NULL END) AS PreApproved,
				MAX(CASE WHEN StageName = 'Disbursement' THEN CreatedOn ELSE NULL END) AS Disbursement,
				MAX(CASE WHEN StageName = 'DCP' THEN CreatedOn ELSE NULL END) AS DCP,

				MAX(CASE WHEN Stage_Level =1 THEN CreatedOn ELSE NULL END) AS Stage1_Date,
				MAX(CASE WHEN Stage_Level =2 THEN CreatedOn ELSE NULL END) AS Stage2_Date,
				MAX(CASE WHEN Stage_Level =3 THEN CreatedOn ELSE NULL END) AS Stage3_Date,
				MAX(CASE WHEN Stage_Level = 4 THEN CreatedOn ELSE NULL END) AS Stage4_Date,
				MAX(CASE WHEN Stage_Level = 5 THEN CreatedOn ELSE NULL END) AS Stage5_Date,
				MAX(CASE WHEN Stage_Level = 6 THEN CreatedOn ELSE NULL END) AS Stage6_Date,
				MAX(CASE WHEN Stage_Level = 7 THEN CreatedOn ELSE NULL END) AS Stage7_Date,
				MAX(CASE WHEN Stage_Level = 8 THEN CreatedOn ELSE NULL END) AS Stage8_Date,
				1 AS Flag
				FROM [dbo].[NEW_JDF_BI_Vw_Stage]
				GROUP BY SeenClientAnswerMasterId
			) Stage ON Stage.SeenClientAnswerMasterId = SAM.Id
			WHERE F.EstablishmentGroupId < 0
			AND U.Id NOT IN (363,54)
		) S
		PIVOT (
			MAX(Detail)
			FOR  QuestionTitle IN (
				[Deposit Amount (This must be the amount)],
				[Estimated Equipment Delivery Date],
				[Maatskappy Naam],
				[Quote Price],
				[Selfoon Nommer],
				[Comments],
				[Van],
				[E-Pos Adres],
				[Follow Up Date],
				[Model],
				[Naam]
			)
		) P
	) XX
) Z
LEFT OUTER JOIN [dbo].[Establishment_Town]  ET ON ET.[Town Name] = LTRIM(SUBSTRING(LTRIM(Z.[Establishment Name]),(LEN(LTRIM(Z.[Establishment Name])) - LEN(LTRIM(ET.[Town Name]))+1),LEN(LTRIM(ET.[Town Name]))))

*/
/* SELECT EstablishmentGroup_Id,SeenClientAnswerMasterId,
(CASE WHEN CompanyId = 27 AND ET.IsNorth = 1 THEN 'AFGRI NORTH' ELSE 
(CASE WHEN CompanyId = 27 AND ET.IsNorth = 0 THEN 'AFGRI SOUTH' ELSE
[CompanyName] END)END) AS [CompanyName],
--[CompanyName] AS [CompanyName],
[PostDate],
EstablishmentGroupName,SalesPerson,[Establishment Name],
[Naam],[Van],[Selfoon Nommer],[E-Pos Adres],
[(1 = Swak ; 5 = Uitstekend)],[As ander, besryf asseblief],[Comments (No Confidential Information)],[Enige mededingende kwotasies?],
[Preferred financial solution?],[Prys],[Total Quote Amount],[Wat was die uiteinde van u besoek?],[Watter produkte was bespreek?],
[Quote Price],[Deposit Amount (This must be the amount)],[Estimated Equipment Delivery Date],[Follow Up Date],[Model],[Comments],
[Quote],[InformationCollection],[AtCredit],[ExtraInfo],[Approved],[PreApproved],[Disbursement],[DCP],[Closed Deals],
Stage1_Date,Stage2_Date,Stage3_Date,Stage4_Date,Stage5_Date,Stage6_Date,Stage7_Date,Stage8_Date,Stage9_Date,
Stage_1st_Days,Stage_2nd_Days,Stage_3rd_Days,Stage_4th_Days,Stage_5th_Days,Stage_6th_Days,Stage_7th_Days,Stage_8th_Days,Stage_9th_Days,
Stage_TotalDays,Flag

FROM (


	SELECT EstablishmentGroup_Id,SeenClientAnswerMasterId,CompanyId,[PostDate],
	[CompanyName],EstablishmentGroupName,SalesPerson,[Establishment Name],
	[Naam],[Van],[Selfoon Nommer],
	[E-Pos Adres],
	[Maatskappy Naam],
	[(1 = Swak ; 5 = Uitstekend)],
	[As ander, besryf asseblief],
	[Comments (No Confidential Information)],
	[Enige mededingende kwotasies?],
	[Preferred financial solution?],
	[Prys],
	[Total Quote Amount],
	[Wat was die uiteinde van u besoek?],
	[Watter produkte was bespreek?],
	NULL AS [Quote Price],
	NULL AS [Deposit Amount (This must be the amount)],
	NULL AS [Estimated Equipment Delivery Date],
	NULL AS [Follow Up Date],
	NULL AS [Model],
	NULL AS [Comments],
	NULL AS [Quote],
	NULL AS [InformationCollection],
	NULL AS [AtCredit],
	NULL AS [ExtraInfo],
	NULL AS [Approved],
	NULL AS [PreApproved],
	NULL AS [Disbursement],
	
	NULL AS [Closed Deals],
	NULL AS [DCP],
	NULL AS Stage1_Date,
	NULL AS Stage2_Date,
	NULL AS Stage3_Date,
	NULL AS Stage4_Date,
	NULL AS Stage5_Date,
	NULL AS Stage6_Date,
	NULL AS Stage7_Date,
	NULL AS Stage8_Date,
	NULL AS Stage9_Date,
	NULL AS Stage_1st_Days,
	NULL AS Stage_2nd_Days,
	NULL AS Stage_3rd_Days,
	NULL AS Stage_4th_Days,
	NULL AS Stage_5th_Days,
	NULL AS Stage_6th_Days,
	NULL AS Stage_7th_Days,
	NULL AS Stage_8th_Days,
	NULL AS Stage_9th_Days,
	NULL AS Stage_TotalDays,
	0 AS Flag
	FROM (
		SELECT 
		DATEADD(mi,SAM.TimeOffSet,SAM.CreatedOn) AS [PostDate],
		SA.SeenClientAnswerMasterId,Q.QuestionTitle,SA.Detail ,G.Id AS CompanyId,
		G.GroupName AS [CompanyName],EG.Id AS EstablishmentGroup_Id,
		REPLACE(REPLACE(REPLACE(EG.EstablishmentGroupName,'01',''),'02',''),'03','') AS EstablishmentGroupName,
		ISNULL(U.Name,'UNDEFINED') AS SalesPerson,UPPER(ISNULL(EstablishmentName,'UNDEFINED')) AS [Establishment Name]
		FROM SeenClientQuestions Q
		INNER JOIN dbo.SeenClientAnswerMaster AS SAM ON SAM.SeenClientId = Q.SeenClientId  AND ISNULL(SAM.IsDeleted,0) = 0
		INNER JOIN dbo.SeenClientAnswers AS SA ON SA.SeenClientAnswerMasterId = SAM.Id AND SA.QuestionId = Q.Id AND ISNULL(SA.IsDeleted,0) = 0  
		INNER JOIN dbo.Establishment E ON E.Id = SAM.EstablishmentId AND E.EstablishmentGroupId IN (963,2661)
		INNER JOIN dbo.EstablishmentGroup EG ON E.EstablishmentGroupId = EG.Id AND E.IsDeleted = 0
		INNER JOIN dbo.[group] G ON G.Id = EG.GroupId AND EG.IsDeleted = 0
		INNER JOIN dbo.AppUser U ON U.Id = SAM.AppUserId AND U.IsDeleted = 0
		INNER JOIN dbo.JDF_BI_Vw_FinancedBy FIN ON Fin.SeenClientAnswerMasterId = SAM.Id AND FIN.[Financed By] = 'John Deere Finance'
		WHERE Q.IsDeleted = 0
		AND U.Id NOT IN (363,54)
	) S
	PIVOT (
		MAX(Detail)
		FOR  QuestionTitle IN (
			[Naam],
			[Van],
			[Selfoon Nommer],
			[E-Pos Adres],
			[Maatskappy Naam],
			[Watter produkte was bespreek?], 
			[(1 = Swak ; 5 = Uitstekend)],
			[As ander, besryf asseblief],
			[Comments (No Confidential Information)],
			[Enige mededingende kwotasies?],
			[Preferred financial solution?],
			[Prys],
			[Total Quote Amount],
			[Wat was die uiteinde van u besoek?]
		)
	) P

UNION ALL

Select EstablishmentGroup_Id,SeenClientAnswerMasterId,CompanyId,[PostDate],
[CompanyName],EstablishmentGroupName,SalesPerson,[Establishment Name],
[Naam],[Van],[Selfoon Nommer],[E-Pos Adres],[Maatskappy Naam],[(1 = Swak ; 5 = Uitstekend)],
[As ander, besryf asseblief],[Comments (No Confidential Information)],[Enige mededingende kwotasies?],
[Preferred financial solution?],[Prys],[Total Quote Amount],[Wat was die uiteinde van u besoek?],
[Watter produkte was bespreek?],[Quote Price],[Deposit Amount (This must be the amount)],
[Estimated Equipment Delivery Date],[Follow Up Date],[Model],[Comments],
[Quote],[InformationCollection],[AtCredit],[ExtraInfo],[Approved],[PreApproved],[Disbursement],[Closed Deals],[DCP],
Stage1_Date,Stage2_Date,Stage3_Date,Stage4_Date,Stage5_Date,Stage6_Date,Stage7_Date,Stage8_Date,Stage9_Date,
Stage_1st_Days,Stage_2nd_Days,Stage_3rd_Days,Stage_4rd_Days,Stage_5th_Days,Stage_6th_Days,Stage_7th_Days,Stage_8th_Days,Stage_9th_Days,
IsNull(Stage_1st_Days,0)+ IsNull(Stage_2nd_Days,0) + IsNull(Stage_3rd_Days,0) + IsNull(Stage_4rd_Days,0) + 
IsNull(Stage_5th_Days,0) + IsNull(Stage_6th_Days,0) + IsNull(Stage_7th_Days,0) + IsNull(Stage_8th_Days,0) +IsNull(Stage_9th_Days,0) as Stage_TotalDays,
Flag
FROM (
	SELECT EstablishmentGroup_Id,SeenClientAnswerMasterId,CompanyId,
	[PostDate],
	[CompanyName],EstablishmentGroupName,SalesPerson,[Establishment Name],
	[Naam],
	[Van],
	[Selfoon Nommer],
	[E-Pos Adres],
	[Maatskappy Naam],
	NULL AS [(1 = Swak ; 5 = Uitstekend)],
	NULL AS [As ander, besryf asseblief],
	NULL AS [Comments (No Confidential Information)],
	NULL AS [Enige mededingende kwotasies?],
	NULL AS [Preferred financial solution?],
	NULL AS [Prys],
	NULL AS [Total Quote Amount],
	NULL AS [Wat was die uiteinde van u besoek?],
	NULL AS [Watter produkte was bespreek?],
	[Quote Price],
	LEFT(SUBSTRING([Deposit Amount (This must be the amount)], PATINDEX('%[0-9.-]%', [Deposit Amount (This must be the amount)]), 8000),
			   PATINDEX('%[^0-9.-]%', SUBSTRING([Deposit Amount (This must be the amount)], PATINDEX('%[0-9.-]%', [Deposit Amount (This must be the amount)]), 8000) + 'X') -1)
	AS [Deposit Amount (This must be the amount)],
	[Estimated Equipment Delivery Date],
	[Follow Up Date],
	[Model],
	[Comments],
	[Quote],[InformationCollection],[AtCredit],[ExtraInfo],[Approved],[PreApproved],[Disbursement],[Closed Deals],[DCP],
	Stage1_Date,Stage2_Date,Stage3_Date,Stage4_Date,Stage5_Date,Stage6_Date,Stage7_Date,Stage8_Date,Stage9_Date,
	DATEDIFF(DAY,[PostDate],Stage1_Date) + 1 AS Stage_1st_Days,
	DATEDIFF(DAY,COALESCE(Stage1_Date,[PostDate]),[InformationCollection]) + 1 AS Stage_2nd_Days,
	DATEDIFF(DAY,COALESCE(Stage2_Date,Stage1_Date,[PostDate]),[AtCredit]) + 1 AS Stage_3rd_Days,
	DATEDIFF(DAY,COALESCE(Stage3_Date,Stage2_Date,Stage1_Date,[PostDate]),[ExtraInfo]) + 1 AS Stage_4rd_Days,
	DATEDIFF(DAY,COALESCE(Stage4_Date,Stage3_Date,Stage2_Date,Stage1_Date,[PostDate]),[Approved]) + 1 AS Stage_5th_Days,
	DATEDIFF(DAY,COALESCE(Stage5_Date,Stage4_Date,Stage3_Date,Stage2_Date,Stage1_Date,[PostDate]),[PreApproved]) + 1 AS Stage_6th_Days,
	DATEDIFF(DAY,COALESCE(Stage6_Date,Stage5_Date,Stage4_Date,Stage3_Date,Stage2_Date,Stage1_Date,[PostDate]),[Disbursement]) + 1 AS Stage_7th_Days,
	DATEDIFF(DAY,COALESCE(Stage7_Date,Stage6_Date,Stage5_Date,Stage4_Date,Stage3_Date,Stage2_Date,Stage1_Date,[PostDate]),[Closed Deals]) + 1 AS Stage_8th_Days,
	DATEDIFF(DAY,COALESCE(Stage8_Date,Stage7_Date,Stage6_Date,Stage5_Date,Stage4_Date,Stage3_Date,Stage2_Date,Stage1_Date,[PostDate]),[DCP]) + 1 AS Stage_9th_Days,
	Flag
	FROM (
		SELECT 
		DATEADD(mi,SAM.TimeOffSet,SAM.CreatedOn) AS [PostDate],
		SA.SeenClientAnswerMasterId,Q.QuestionTitle,SA.Detail ,G.Id AS CompanyId,
		G.GroupName AS [CompanyName],EG.Id AS EstablishmentGroup_Id,
		REPLACE(REPLACE(REPLACE(EG.EstablishmentGroupName,'01',''),'02',''),'03','') AS EstablishmentGroupName,
		ISNULL(U.Name,'UNDEFINED') AS SalesPerson,UPPER(ISNULL(EstablishmentName,'UNDEFINED')) AS [Establishment Name],
		[Quote],[InformationCollection],[AtCredit],[ExtraInfo],[Approved],[PreApproved],[Disbursement],[Closed Deals],[DCP],
		Stage1_Date,Stage2_Date,Stage3_Date,Stage4_Date,Stage5_Date,Stage6_Date,Stage7_Date,Stage8_Date,Stage9_Date,Flag
		FROM SeenClientQuestions Q
		INNER JOIN dbo.SeenClientAnswerMaster AS SAM ON SAM.SeenClientId = Q.SeenClientId  AND ISNULL(SAM.IsDeleted,0) = 0
		INNER JOIN dbo.SeenClientAnswers AS SA ON SA.SeenClientAnswerMasterId = SAM.Id AND SA.QuestionId = Q.Id AND ISNULL(SA.IsDeleted,0) = 0  
		INNER JOIN dbo.Establishment E ON E.Id = SAM.EstablishmentId AND E.EstablishmentGroupId in( 2315,2667,2729,2727,2731,2733)
		INNER JOIN dbo.EstablishmentGroup EG ON E.EstablishmentGroupId = EG.Id AND E.IsDeleted = 0
		INNER JOIN dbo.[group] G ON G.Id = EG.GroupId AND EG.IsDeleted = 0
		INNER JOIN dbo.AppUser U ON U.Id = SAM.AppUserId AND U.IsDeleted = 0
		LEFT JOIN (
			SELECT SeenClientAnswerMasterId,
			MAX(CASE WHEN StageName = 'Quote' THEN CreatedOn ELSE NULL END) AS Quote,
			MAX(CASE WHEN StageName = 'Information Collection' THEN CreatedOn ELSE NULL END) AS InformationCollection,
			MAX(CASE WHEN StageName = 'At Credit' THEN CreatedOn ELSE NULL END) AS AtCredit,
			MAX(CASE WHEN StageName = 'Extra Information' THEN CreatedOn ELSE NULL END) AS ExtraInfo,
			MAX(CASE WHEN StageName = 'Approved' THEN CreatedOn ELSE NULL END) AS Approved,
			MAX(CASE WHEN StageName = 'Pre-approved' THEN CreatedOn ELSE NULL END) AS PreApproved,
			MAX(CASE WHEN StageName = 'Disbursement' THEN CreatedOn ELSE NULL END) AS Disbursement,
			MAX(CASE WHEN StageName = 'Closed Deals' THEN CreatedOn ELSE NULL END) AS [Closed Deals],
			MAX(CASE WHEN StageName = 'DCP' THEN CreatedOn ELSE NULL END) AS DCP,
			MAX(CASE WHEN Stage_Level =1 THEN CreatedOn ELSE NULL END) AS Stage1_Date,
			MAX(CASE WHEN Stage_Level =2 THEN CreatedOn ELSE NULL END) AS Stage2_Date,
			MAX(CASE WHEN Stage_Level =3 THEN CreatedOn ELSE NULL END) AS Stage3_Date,
			MAX(CASE WHEN Stage_Level = 4 THEN CreatedOn ELSE NULL END) AS Stage4_Date,
			MAX(CASE WHEN Stage_Level = 5 THEN CreatedOn ELSE NULL END) AS Stage5_Date,
			MAX(CASE WHEN Stage_Level = 6 THEN CreatedOn ELSE NULL END) AS Stage6_Date,
			MAX(CASE WHEN Stage_Level = 7 THEN CreatedOn ELSE NULL END) AS Stage7_Date,
			MAX(CASE WHEN Stage_Level = 8 THEN CreatedOn ELSE NULL END) AS Stage8_Date,
			MAX(CASE WHEN Stage_Level = 9 THEN CreatedOn ELSE NULL END) AS Stage9_Date,
			1 AS Flag
			FROM [dbo].[NEW_JDF_BI_Vw_Stage]
			GROUP BY SeenClientAnswerMasterId
		) Stage ON Stage.SeenClientAnswerMasterId = SAM.Id
		WHERE Q.IsDeleted = 0
		AND U.Id NOT IN (363,54)
	) S
	PIVOT (
		MAX(Detail)
		FOR  QuestionTitle IN (
			[Deposit Amount (This must be the amount)],
			[Estimated Equipment Delivery Date],
			[Maatskappy Naam],
			[Quote Price],
			[Selfoon Nommer],
			[Comments],
			[Van],
			[E-Pos Adres],
			[Follow Up Date],
			[Model],
			[Naam]
		)
	) P
) X

/*Stage Data section*/
UNION ALL 

	SELECT EstablishmentGroup_Id,SeenClientAnswerMasterId,CompanyId,
	[PostDate],	[CompanyName],EstablishmentGroupName,SalesPerson,[Establishment Name],
	[Naam],	[Van],	[Selfoon Nommer],[E-Pos Adres],	[Maatskappy Naam],
	[(1 = Swak ; 5 = Uitstekend)],[As ander, besryf asseblief],	[Comments (No Confidential Information)],
	[Enige mededingende kwotasies?],[Preferred financial solution?],[Prys],
	[Total Quote Amount],[Wat was die uiteinde van u besoek?],[Watter produkte was bespreek?],
	[Quote Price],[Deposit Amount (This must be the amount)],[Estimated Equipment Delivery Date],
	[Follow Up Date],[Model],[Comments],
	[Quote],[InformationCollection],[AtCredit],[ExtraInfo],[Approved],[PreApproved],[Disbursement],[Closed Deals],[DCP],
	Stage1_Date,Stage2_Date,Stage3_Date,Stage4_Date,Stage5_Date,Stage6_Date,Stage7_Date,Stage8_Date,Stage9_Date,
	Stage_1st_Days,Stage_2nd_Days,Stage_3rd_Days,Stage_4rd_Days,Stage_5th_Days,Stage_6th_Days,Stage_7th_Days,Stage_8th_Days,Stage_9th_Days,
	IsNull(Stage_1st_Days,0)+ IsNull(Stage_2nd_Days,0) + IsNull(Stage_3rd_Days,0) + IsNull(Stage_4rd_Days,0) + 
	IsNull(Stage_5th_Days,0) + IsNull(Stage_6th_Days,0) + IsNull(Stage_7th_Days,0) + IsNull(Stage_8th_Days,0) +IsNull(Stage_9th_Days,0) as Stage_TotalDays,
	Flag
	FROM (
		SELECT EstablishmentGroup_Id,SeenClientAnswerMasterId,CompanyId,
		[PostDate],
		[CompanyName],EstablishmentGroupName,SalesPerson,[Establishment Name],
		[Naam],
		[Van],
		[Selfoon Nommer],
		[E-Pos Adres],
		[Maatskappy Naam],
		NULL AS [(1 = Swak ; 5 = Uitstekend)],
		NULL AS [As ander, besryf asseblief],
		NULL AS [Comments (No Confidential Information)],
		NULL AS [Enige mededingende kwotasies?],
		NULL AS [Preferred financial solution?],
		NULL AS [Prys],
		NULL AS [Total Quote Amount],
		NULL AS [Wat was die uiteinde van u besoek?],
		NULL AS [Watter produkte was bespreek?],
		[Quote Price],
		LEFT(SUBSTRING([Deposit Amount (This must be the amount)], PATINDEX('%[0-9.-]%', [Deposit Amount (This must be the amount)]), 8000),
					PATINDEX('%[^0-9.-]%', SUBSTRING([Deposit Amount (This must be the amount)], PATINDEX('%[0-9.-]%', [Deposit Amount (This must be the amount)]), 8000) + 'X') -1)
		AS [Deposit Amount (This must be the amount)],
		[Estimated Equipment Delivery Date],
		[Follow Up Date],
		[Model],
		[Comments],
		[Quote],[InformationCollection],[AtCredit],[ExtraInfo],[Approved],[PreApproved],[Disbursement],[Closed Deals],[DCP],
		Stage1_Date,Stage2_Date,Stage3_Date,Stage4_Date,Stage5_Date,Stage6_Date,Stage7_Date,Stage8_Date,Stage9_Date,
		DATEDIFF(DAY,[PostDate],Stage1_Date) + 1 AS Stage_1st_Days,
		DATEDIFF(DAY,COALESCE(Stage1_Date,[PostDate]),[InformationCollection]) + 1 AS Stage_2nd_Days,
		DATEDIFF(DAY,COALESCE(Stage2_Date,Stage1_Date,[PostDate]),[AtCredit]) + 1 AS Stage_3rd_Days,
		DATEDIFF(DAY,COALESCE(Stage3_Date,Stage2_Date,Stage1_Date,[PostDate]),[ExtraInfo]) + 1 AS Stage_4rd_Days,
		DATEDIFF(DAY,COALESCE(Stage4_Date,Stage3_Date,Stage2_Date,Stage1_Date,[PostDate]),[Approved]) + 1 AS Stage_5th_Days,
		DATEDIFF(DAY,COALESCE(Stage5_Date,Stage4_Date,Stage3_Date,Stage2_Date,Stage1_Date,[PostDate]),[PreApproved]) + 1 AS Stage_6th_Days,
		DATEDIFF(DAY,COALESCE(Stage6_Date,Stage5_Date,Stage4_Date,Stage3_Date,Stage2_Date,Stage1_Date,[PostDate]),[Disbursement]) + 1 AS Stage_7th_Days,
		DATEDIFF(DAY,COALESCE(Stage7_Date,Stage6_Date,Stage5_Date,Stage4_Date,Stage3_Date,Stage2_Date,Stage1_Date,[PostDate]),[Closed Deals]) + 1 AS Stage_8th_Days,
		DATEDIFF(DAY,COALESCE(Stage8_Date,Stage7_Date,Stage6_Date,Stage5_Date,Stage4_Date,Stage3_Date,Stage2_Date,Stage1_Date,[PostDate]),[DCP]) + 1 AS Stage_9th_Days,Flag
		FROM (
			SELECT
			DATEADD(mi,SAM.TimeOffSet,SAM.CreatedOn) AS [PostDate],
			F.Id AS SeenClientAnswerMasterId,Q.QuestionTitle,SA.Detail ,G.Id AS CompanyId,
			G.GroupName AS [CompanyName],F.EstablishmentGroupId AS EstablishmentGroup_Id,
			REPLACE(REPLACE(REPLACE(EG.EstablishmentGroupName,'01',''),'02',''),'03','') AS EstablishmentGroupName,
			ISNULL(U.Name,'UNDEFINED') AS SalesPerson,UPPER(ISNULL(EstablishmentName,'UNDEFINED')) AS [Establishment Name],
			[Quote],[InformationCollection],[AtCredit],[ExtraInfo],[Approved],[PreApproved],[Disbursement],[Closed Deals],[DCP],
			Stage1_Date,Stage2_Date,Stage3_Date,Stage4_Date,Stage5_Date,Stage6_Date,Stage7_Date,Stage8_Date,Stage9_Date,Flag
			FROM JDF_BI_Vw_FACT_Magnitude F
			INNER JOIN dbo.SeenClientAnswerMaster AS SAM ON F.Scam_Id = SAM.Id
			INNER JOIN SeenClientQuestions Q ON SAM.SeenClientId = Q.SeenClientId  AND ISNULL(Q.IsDeleted,0) = 0
			INNER JOIN dbo.SeenClientAnswers AS SA ON SA.SeenClientAnswerMasterId = SAM.Id AND SA.QuestionId = Q.Id AND ISNULL(SA.IsDeleted,0) = 0  
			INNER JOIN dbo.Establishment E ON E.Id = SAM.EstablishmentId AND E.EstablishmentGroupId in(2315,2667,2729,2727,2731,2733)
			INNER JOIN dbo.EstablishmentGroup EG ON E.EstablishmentGroupId = EG.Id AND E.IsDeleted = 0
			INNER JOIN dbo.[group] G ON G.Id = EG.GroupId AND EG.IsDeleted = 0
			INNER JOIN dbo.AppUser U ON U.Id = SAM.AppUserId AND U.IsDeleted = 0
			LEFT JOIN 
			(
				SELECT SeenClientAnswerMasterId,
				MAX(CASE WHEN StageName = 'Quote' THEN CreatedOn ELSE NULL END) AS Quote,
				MAX(CASE WHEN StageName = 'Information Collection' THEN CreatedOn ELSE NULL END) AS InformationCollection,
				MAX(CASE WHEN StageName = 'At Credit' THEN CreatedOn ELSE NULL END) AS AtCredit,
				MAX(CASE WHEN StageName = 'Extra Information' THEN CreatedOn ELSE NULL END) AS ExtraInfo,
				MAX(CASE WHEN StageName = 'Approved' THEN CreatedOn ELSE NULL END) AS Approved,
				MAX(CASE WHEN StageName = 'Pre-approved' THEN CreatedOn ELSE NULL END) AS PreApproved,
				MAX(CASE WHEN StageName = 'Disbursement' THEN CreatedOn ELSE NULL END) AS Disbursement,
				
				MAX(CASE WHEN StageName = 'Closed Deals' THEN CreatedOn ELSE NULL END) AS [Closed Deals],
				MAX(CASE WHEN StageName = 'DCP' THEN CreatedOn ELSE NULL END) AS DCP,

				MAX(CASE WHEN Stage_Level =1 THEN CreatedOn ELSE NULL END) AS Stage1_Date,
				MAX(CASE WHEN Stage_Level =2 THEN CreatedOn ELSE NULL END) AS Stage2_Date,
				MAX(CASE WHEN Stage_Level =3 THEN CreatedOn ELSE NULL END) AS Stage3_Date,
				MAX(CASE WHEN Stage_Level = 4 THEN CreatedOn ELSE NULL END) AS Stage4_Date,
				MAX(CASE WHEN Stage_Level = 5 THEN CreatedOn ELSE NULL END) AS Stage5_Date,
				MAX(CASE WHEN Stage_Level = 6 THEN CreatedOn ELSE NULL END) AS Stage6_Date,
				MAX(CASE WHEN Stage_Level = 7 THEN CreatedOn ELSE NULL END) AS Stage7_Date,
				MAX(CASE WHEN Stage_Level = 8 THEN CreatedOn ELSE NULL END) AS Stage8_Date,
				MAX(CASE WHEN Stage_Level = 9 THEN CreatedOn ELSE NULL END) AS Stage9_Date,
				1 AS Flag
				FROM [dbo].[NEW_JDF_BI_Vw_Stage]
				GROUP BY SeenClientAnswerMasterId
			) Stage ON Stage.SeenClientAnswerMasterId = SAM.Id
			WHERE F.EstablishmentGroupId < 0
			AND U.Id NOT IN (363,54)
		) S
		PIVOT (
			MAX(Detail)
			FOR  QuestionTitle IN (
				[Deposit Amount (This must be the amount)],
				[Estimated Equipment Delivery Date],
				[Maatskappy Naam],
				[Quote Price],
				[Selfoon Nommer],
				[Comments],
				[Van],
				[E-Pos Adres],
				[Follow Up Date],
				[Model],
				[Naam]
			)
		) P
	) XX
) Z
LEFT OUTER JOIN [dbo].[Establishment_Town]  ET ON ET.[Town Name] = LTRIM(SUBSTRING(LTRIM(Z.[Establishment Name]),(LEN(LTRIM(Z.[Establishment Name])) - LEN(LTRIM(ET.[Town Name]))+1),LEN(LTRIM(ET.[Town Name]))))

*/

/*

select Main.*,Chats.Date,Chats.Conversation
from

(
SELECT EstablishmentGroup_Id,SeenClientAnswerMasterId,
(CASE WHEN CompanyId = 27 AND ET.IsNorth = 1 THEN 'AFGRI NORTH' ELSE 
(CASE WHEN CompanyId = 27 AND ET.IsNorth = 0 THEN 'AFGRI SOUTH' ELSE
[CompanyName] END)END) AS [CompanyName],
--[CompanyName] AS [CompanyName],
[PostDate],
EstablishmentGroupName,SalesPerson,BDO,[Establishment Name],
[Name],[Surname],[Cell],[Email],[Company],
[(1 = Swak ; 5 = Uitstekend)],[As ander, besryf asseblief],[Comments (No Confidential Information)],[Enige mededingende kwotasies?],
[Preferred financial solution?],[Prys],[Total Quote Amount],[Wat was die uiteinde van u besoek?],[Watter produkte was bespreek?],
[Quote Price],[Deposit Amount (This must be the amount)],[Estimated Equipment Delivery Date],[Follow Up Date],[Model],[Comments],
[Quote],[InformationCollection],[AtCredit],[ExtraInfo],[Approved],[PreApproved],[Disbursement],[DCP],[Closed Deals],
Stage1_Date,Stage2_Date,Stage3_Date,Stage4_Date,Stage5_Date,Stage6_Date,Stage7_Date,Stage8_Date,Stage9_Date,
Stage_1st_Days,Stage_2nd_Days,Stage_3rd_Days,Stage_4th_Days,Stage_5th_Days,Stage_6th_Days,Stage_7th_Days,Stage_8th_Days,Stage_9th_Days,
Stage_TotalDays,Flag

FROM (


	SELECT EstablishmentGroup_Id,SeenClientAnswerMasterId,CompanyId,[PostDate],
	[CompanyName],EstablishmentGroupName,SalesPerson,BDO,[Establishment Name],
	[Naam] as [Name],
	[Van] as [Surname],
	[Selfoon Nommer] as[Cell],
	[E-Pos Adres] as Email,
	[Maatskappy Naam] as Company,
	[(1 = Swak ; 5 = Uitstekend)],
	[As ander, besryf asseblief],
	[Comments (No Confidential Information)],
	[Enige mededingende kwotasies?],
	[Preferred financial solution?],
	[Prys],
	[Total Quote Amount],
	[Wat was die uiteinde van u besoek?],
	[Watter produkte was bespreek?],
	NULL AS [Quote Price],
	NULL AS [Deposit Amount (This must be the amount)],
	NULL AS [Estimated Equipment Delivery Date],
	NULL AS [Follow Up Date],
	NULL AS [Model],
	NULL AS [Comments],
	NULL AS [Quote],
	NULL AS [InformationCollection],
	NULL AS [AtCredit],
	NULL AS [ExtraInfo],
	NULL AS [Approved],
	NULL AS [PreApproved],
	NULL AS [Disbursement],
	
	NULL AS [Closed Deals],
	NULL AS [DCP],
	NULL AS Stage1_Date,
	NULL AS Stage2_Date,
	NULL AS Stage3_Date,
	NULL AS Stage4_Date,
	NULL AS Stage5_Date,
	NULL AS Stage6_Date,
	NULL AS Stage7_Date,
	NULL AS Stage8_Date,
	NULL AS Stage9_Date,
	NULL AS Stage_1st_Days,
	NULL AS Stage_2nd_Days,
	NULL AS Stage_3rd_Days,
	NULL AS Stage_4th_Days,
	NULL AS Stage_5th_Days,
	NULL AS Stage_6th_Days,
	NULL AS Stage_7th_Days,
	NULL AS Stage_8th_Days,
	NULL AS Stage_9th_Days,
	NULL AS Stage_TotalDays,
	0 AS Flag
	FROM (
		SELECT 
		DATEADD(mi,SAM.TimeOffSet,SAM.CreatedOn) AS [PostDate],
		SA.SeenClientAnswerMasterId,Q.QuestionTitle,SA.Detail ,G.Id AS CompanyId,
		G.GroupName AS [CompanyName],EG.Id AS EstablishmentGroup_Id,
		REPLACE(REPLACE(REPLACE(EG.EstablishmentGroupName,'01',''),'02',''),'03','') AS EstablishmentGroupName,
		E.EstablishmentName as SalesPerson,ISNULL(U.Name,'UNDEFINED') AS BDO,UPPER(ISNULL(EstablishmentName,'UNDEFINED')) AS [Establishment Name]
		FROM SeenClientQuestions Q
		INNER JOIN dbo.SeenClientAnswerMaster AS SAM ON SAM.SeenClientId = Q.SeenClientId  AND ISNULL(SAM.IsDeleted,0) = 0
		INNER JOIN dbo.SeenClientAnswers AS SA ON SA.SeenClientAnswerMasterId = SAM.Id AND SA.QuestionId = Q.Id AND ISNULL(SA.IsDeleted,0) = 0  
		INNER JOIN dbo.Establishment E ON E.Id = SAM.EstablishmentId AND E.EstablishmentGroupId IN (963,2661)
		INNER JOIN dbo.EstablishmentGroup EG ON E.EstablishmentGroupId = EG.Id AND E.IsDeleted = 0
		INNER JOIN dbo.[group] G ON G.Id = EG.GroupId AND EG.IsDeleted = 0
		INNER JOIN dbo.AppUser U ON U.Id = SAM.AppUserId AND U.IsDeleted = 0
		INNER JOIN dbo.JDF_BI_Vw_FinancedBy FIN ON Fin.SeenClientAnswerMasterId = SAM.Id AND FIN.[Financed By] = 'John Deere Finance'
		WHERE Q.IsDeleted = 0
		AND U.Id NOT IN (363,54)
	) S
	PIVOT (
		MAX(Detail)
		FOR  QuestionTitle IN (
			[Naam],
			[Van],
			[Selfoon Nommer],
			[E-Pos Adres],
			[Maatskappy Naam],
			[Watter produkte was bespreek?], 
			[(1 = Swak ; 5 = Uitstekend)],
			[As ander, besryf asseblief],
			[Comments (No Confidential Information)],
			[Enige mededingende kwotasies?],
			[Preferred financial solution?],
			[Prys],
			[Total Quote Amount],
			[Wat was die uiteinde van u besoek?]
		)
	) P

UNION ALL

Select EstablishmentGroup_Id,SeenClientAnswerMasterId,CompanyId,[PostDate],
[CompanyName],EstablishmentGroupName,SalesPerson,BDO,[Establishment Name],
[Name],[Surname],[Cell],[Email],[Company],[(1 = Swak ; 5 = Uitstekend)],
[As ander, besryf asseblief],[Comments (No Confidential Information)],[Enige mededingende kwotasies?],
[Preferred financial solution?],[Prys],[Total Quote Amount],[Wat was die uiteinde van u besoek?],
[Watter produkte was bespreek?],[Quote Price],[Deposit Amount (This must be the amount)],
[Estimated Equipment Delivery Date],[Follow Up Date],[Model],[Comments],
[Quote],[InformationCollection],[AtCredit],[ExtraInfo],[Approved],[PreApproved],[Disbursement],[Closed Deals],[DCP],
Stage1_Date,Stage2_Date,Stage3_Date,Stage4_Date,Stage5_Date,Stage6_Date,Stage7_Date,Stage8_Date,Stage9_Date,
Stage_1st_Days,Stage_2nd_Days,Stage_3rd_Days,Stage_4rd_Days,Stage_5th_Days,Stage_6th_Days,Stage_7th_Days,Stage_8th_Days,Stage_9th_Days,
IsNull(Stage_1st_Days,0)+ IsNull(Stage_2nd_Days,0) + IsNull(Stage_3rd_Days,0) + IsNull(Stage_4rd_Days,0) + 
IsNull(Stage_5th_Days,0) + IsNull(Stage_6th_Days,0) + IsNull(Stage_7th_Days,0) + IsNull(Stage_8th_Days,0) +IsNull(Stage_9th_Days,0) as Stage_TotalDays,
Flag
FROM (
	SELECT EstablishmentGroup_Id,SeenClientAnswerMasterId,CompanyId,
	[PostDate],
	[CompanyName],EstablishmentGroupName,SalesPerson,BDO,[Establishment Name],
	[Naam] as [Name],
	[Van] as [Surname],
	[Selfoon Nommer] as [Cell],
	[E-Pos Adres] as Email,
	[Maatskappy Naam] as Company,
	NULL AS [(1 = Swak ; 5 = Uitstekend)],
	NULL AS [As ander, besryf asseblief],
	NULL AS [Comments (No Confidential Information)],
	NULL AS [Enige mededingende kwotasies?],
	NULL AS [Preferred financial solution?],
	NULL AS [Prys],
	NULL AS [Total Quote Amount],
	NULL AS [Wat was die uiteinde van u besoek?],
	NULL AS [Watter produkte was bespreek?],
	[Quote Price],
	LEFT(SUBSTRING([Deposit Amount (This must be the amount)], PATINDEX('%[0-9.-]%', [Deposit Amount (This must be the amount)]), 8000),
			   PATINDEX('%[^0-9.-]%', SUBSTRING([Deposit Amount (This must be the amount)], PATINDEX('%[0-9.-]%', [Deposit Amount (This must be the amount)]), 8000) + 'X') -1)
	AS [Deposit Amount (This must be the amount)],
	[Estimated Equipment Delivery Date],
	[Follow Up Date],
	[Model],
	[Comments],
	[Quote],[InformationCollection],[AtCredit],[ExtraInfo],[Approved],[PreApproved],[Disbursement],[Closed Deals],[DCP],
	Stage1_Date,Stage2_Date,Stage3_Date,Stage4_Date,Stage5_Date,Stage6_Date,Stage7_Date,Stage8_Date,Stage9_Date,
	DATEDIFF(DAY,[PostDate],Stage1_Date) + 1 AS Stage_1st_Days,
	DATEDIFF(DAY,COALESCE(Stage1_Date,[PostDate]),[InformationCollection]) + 1 AS Stage_2nd_Days,
	DATEDIFF(DAY,COALESCE(Stage2_Date,Stage1_Date,[PostDate]),[AtCredit]) + 1 AS Stage_3rd_Days,
	DATEDIFF(DAY,COALESCE(Stage3_Date,Stage2_Date,Stage1_Date,[PostDate]),[ExtraInfo]) + 1 AS Stage_4rd_Days,
	DATEDIFF(DAY,COALESCE(Stage4_Date,Stage3_Date,Stage2_Date,Stage1_Date,[PostDate]),[Approved]) + 1 AS Stage_5th_Days,
	DATEDIFF(DAY,COALESCE(Stage5_Date,Stage4_Date,Stage3_Date,Stage2_Date,Stage1_Date,[PostDate]),[PreApproved]) + 1 AS Stage_6th_Days,
	DATEDIFF(DAY,COALESCE(Stage6_Date,Stage5_Date,Stage4_Date,Stage3_Date,Stage2_Date,Stage1_Date,[PostDate]),[Disbursement]) + 1 AS Stage_7th_Days,
	DATEDIFF(DAY,COALESCE(Stage7_Date,Stage6_Date,Stage5_Date,Stage4_Date,Stage3_Date,Stage2_Date,Stage1_Date,[PostDate]),[Closed Deals]) + 1 AS Stage_8th_Days,
	DATEDIFF(DAY,COALESCE(Stage8_Date,Stage7_Date,Stage6_Date,Stage5_Date,Stage4_Date,Stage3_Date,Stage2_Date,Stage1_Date,[PostDate]),[DCP]) + 1 AS Stage_9th_Days,
	Flag
	FROM (
		SELECT 
		DATEADD(mi,SAM.TimeOffSet,SAM.CreatedOn) AS [PostDate],
		SA.SeenClientAnswerMasterId,Q.QuestionTitle,SA.Detail ,G.Id AS CompanyId,
		G.GroupName AS [CompanyName],EG.Id AS EstablishmentGroup_Id,
		REPLACE(REPLACE(REPLACE(EG.EstablishmentGroupName,'01',''),'02',''),'03','') AS EstablishmentGroupName,
		E.EstablishmentName as SalesPerson,ISNULL(U.Name,'UNDEFINED') AS BDO,UPPER(ISNULL(EstablishmentName,'UNDEFINED')) AS [Establishment Name],
		[Quote],[InformationCollection],[AtCredit],[ExtraInfo],[Approved],[PreApproved],[Disbursement],[Closed Deals],[DCP],
		Stage1_Date,Stage2_Date,Stage3_Date,Stage4_Date,Stage5_Date,Stage6_Date,Stage7_Date,Stage8_Date,Stage9_Date,Flag
		FROM SeenClientQuestions Q
		INNER JOIN dbo.SeenClientAnswerMaster AS SAM ON SAM.SeenClientId = Q.SeenClientId  AND ISNULL(SAM.IsDeleted,0) = 0
		INNER JOIN dbo.SeenClientAnswers AS SA ON SA.SeenClientAnswerMasterId = SAM.Id AND SA.QuestionId = Q.Id AND ISNULL(SA.IsDeleted,0) = 0  
		INNER JOIN dbo.Establishment E ON E.Id = SAM.EstablishmentId AND E.EstablishmentGroupId in( 2315)
		INNER JOIN dbo.EstablishmentGroup EG ON E.EstablishmentGroupId = EG.Id AND E.IsDeleted = 0
		INNER JOIN dbo.[group] G ON G.Id = EG.GroupId AND EG.IsDeleted = 0
		INNER JOIN dbo.AppUser U ON U.Id = SAM.AppUserId AND U.IsDeleted = 0
		LEFT JOIN (
			SELECT SeenClientAnswerMasterId,
			MAX(CASE WHEN StageName = 'Quote' THEN CreatedOn ELSE NULL END) AS Quote,
			MAX(CASE WHEN StageName = 'Information Collection' THEN CreatedOn ELSE NULL END) AS InformationCollection,
			MAX(CASE WHEN StageName = 'At Credit' THEN CreatedOn ELSE NULL END) AS AtCredit,
			MAX(CASE WHEN StageName = 'Extra Information' THEN CreatedOn ELSE NULL END) AS ExtraInfo,
			MAX(CASE WHEN StageName = 'Approved' THEN CreatedOn ELSE NULL END) AS Approved,
			MAX(CASE WHEN StageName = 'Pre-approved' THEN CreatedOn ELSE NULL END) AS PreApproved,
			MAX(CASE WHEN StageName = 'Disbursement' THEN CreatedOn ELSE NULL END) AS Disbursement,
			MAX(CASE WHEN StageName = 'Closed Deals' THEN CreatedOn ELSE NULL END) AS [Closed Deals],
			MAX(CASE WHEN StageName = 'DCP' THEN CreatedOn ELSE NULL END) AS DCP,
			MAX(CASE WHEN Stage_Level =1 THEN CreatedOn ELSE NULL END) AS Stage1_Date,
			MAX(CASE WHEN Stage_Level =2 THEN CreatedOn ELSE NULL END) AS Stage2_Date,
			MAX(CASE WHEN Stage_Level =3 THEN CreatedOn ELSE NULL END) AS Stage3_Date,
			MAX(CASE WHEN Stage_Level = 4 THEN CreatedOn ELSE NULL END) AS Stage4_Date,
			MAX(CASE WHEN Stage_Level = 5 THEN CreatedOn ELSE NULL END) AS Stage5_Date,
			MAX(CASE WHEN Stage_Level = 6 THEN CreatedOn ELSE NULL END) AS Stage6_Date,
			MAX(CASE WHEN Stage_Level = 7 THEN CreatedOn ELSE NULL END) AS Stage7_Date,
			MAX(CASE WHEN Stage_Level = 8 THEN CreatedOn ELSE NULL END) AS Stage8_Date,
			MAX(CASE WHEN Stage_Level = 9 THEN CreatedOn ELSE NULL END) AS Stage9_Date,
			1 AS Flag
			FROM [dbo].[NEW_JDF_BI_Vw_Stage]
			GROUP BY SeenClientAnswerMasterId
		) Stage ON Stage.SeenClientAnswerMasterId = SAM.Id
		WHERE Q.IsDeleted = 0
		AND U.Id NOT IN (363,54)
	) S
	PIVOT (
		MAX(Detail)
		FOR  QuestionTitle IN (
			[Deposit Amount (This must be the amount)],
			[Estimated Equipment Delivery Date],
			[Maatskappy Naam],
			[Quote Price],
			[Selfoon Nommer],
			[Comments],
			[Van],
			[E-Pos Adres],
			[Follow Up Date],
			[Model],
			[Naam]
		)
	) P
) X
UNION ALL

Select EstablishmentGroup_Id,SeenClientAnswerMasterId,CompanyId,[PostDate],
[CompanyName],EstablishmentGroupName,SalesPerson,BDO,[Establishment Name],
[Name],[Surname],[Cell],[Email],[Company],[(1 = Swak ; 5 = Uitstekend)],
[As ander, besryf asseblief],[Comments (No Confidential Information)],[Enige mededingende kwotasies?],
[Preferred financial solution?],[Prys],[Total Quote Amount],[Wat was die uiteinde van u besoek?],
[Watter produkte was bespreek?],[Quote Price],[Deposit Amount (This must be the amount)],
[Estimated Equipment Delivery Date],[Follow Up Date],[Model],[Comments],
[Quote],[InformationCollection],[AtCredit],[ExtraInfo],[Approved],[PreApproved],[Disbursement],[Closed Deals],[DCP],
Stage1_Date,Stage2_Date,Stage3_Date,Stage4_Date,Stage5_Date,Stage6_Date,Stage7_Date,Stage8_Date,Stage9_Date,
Stage_1st_Days,Stage_2nd_Days,Stage_3rd_Days,Stage_4rd_Days,Stage_5th_Days,Stage_6th_Days,Stage_7th_Days,Stage_8th_Days,Stage_9th_Days,
IsNull(Stage_1st_Days,0)+ IsNull(Stage_2nd_Days,0) + IsNull(Stage_3rd_Days,0) + IsNull(Stage_4rd_Days,0) + 
IsNull(Stage_5th_Days,0) + IsNull(Stage_6th_Days,0) + IsNull(Stage_7th_Days,0) + IsNull(Stage_8th_Days,0) +IsNull(Stage_9th_Days,0) as Stage_TotalDays,
Flag
FROM (
	SELECT EstablishmentGroup_Id,SeenClientAnswerMasterId,CompanyId,
	[PostDate],
	[CompanyName],EstablishmentGroupName,SalesPerson,BDO,[Establishment Name],
	[Name],
	[Surname],
	[Cell],
	[Email],
	[Company],
	NULL AS [(1 = Swak ; 5 = Uitstekend)],
	NULL AS [As ander, besryf asseblief],
	NULL AS [Comments (No Confidential Information)],
	NULL AS [Enige mededingende kwotasies?],
	NULL AS [Preferred financial solution?],
	NULL AS [Prys],
	NULL AS [Total Quote Amount],
	NULL AS [Wat was die uiteinde van u besoek?],
	NULL AS [Watter produkte was bespreek?],
	[Quote Price],
	LEFT(SUBSTRING([Deposit Amount (This must be the amount)], PATINDEX('%[0-9.-]%', [Deposit Amount (This must be the amount)]), 8000),
			   PATINDEX('%[^0-9.-]%', SUBSTRING([Deposit Amount (This must be the amount)], PATINDEX('%[0-9.-]%', [Deposit Amount (This must be the amount)]), 8000) + 'X') -1)
	AS [Deposit Amount (This must be the amount)],
	[Estimated Equipment Delivery Date],
	[Follow Up Date],
	[Model],
	[Comments],
	[Quote],[InformationCollection],[AtCredit],[ExtraInfo],[Approved],[PreApproved],[Disbursement],[Closed Deals],[DCP],
	Stage1_Date,Stage2_Date,Stage3_Date,Stage4_Date,Stage5_Date,Stage6_Date,Stage7_Date,Stage8_Date,Stage9_Date,
	DATEDIFF(DAY,[PostDate],Stage1_Date) + 1 AS Stage_1st_Days,
	DATEDIFF(DAY,COALESCE(Stage1_Date,[PostDate]),[InformationCollection]) + 1 AS Stage_2nd_Days,
	DATEDIFF(DAY,COALESCE(Stage2_Date,Stage1_Date,[PostDate]),[AtCredit]) + 1 AS Stage_3rd_Days,
	DATEDIFF(DAY,COALESCE(Stage3_Date,Stage2_Date,Stage1_Date,[PostDate]),[ExtraInfo]) + 1 AS Stage_4rd_Days,
	DATEDIFF(DAY,COALESCE(Stage4_Date,Stage3_Date,Stage2_Date,Stage1_Date,[PostDate]),[Approved]) + 1 AS Stage_5th_Days,
	DATEDIFF(DAY,COALESCE(Stage5_Date,Stage4_Date,Stage3_Date,Stage2_Date,Stage1_Date,[PostDate]),[PreApproved]) + 1 AS Stage_6th_Days,
	DATEDIFF(DAY,COALESCE(Stage6_Date,Stage5_Date,Stage4_Date,Stage3_Date,Stage2_Date,Stage1_Date,[PostDate]),[Disbursement]) + 1 AS Stage_7th_Days,
	DATEDIFF(DAY,COALESCE(Stage7_Date,Stage6_Date,Stage5_Date,Stage4_Date,Stage3_Date,Stage2_Date,Stage1_Date,[PostDate]),[Closed Deals]) + 1 AS Stage_8th_Days,
	DATEDIFF(DAY,COALESCE(Stage8_Date,Stage7_Date,Stage6_Date,Stage5_Date,Stage4_Date,Stage3_Date,Stage2_Date,Stage1_Date,[PostDate]),[DCP]) + 1 AS Stage_9th_Days,
	Flag
	FROM (
		SELECT 
		DATEADD(mi,SAM.TimeOffSet,SAM.CreatedOn) AS [PostDate],
		SA.SeenClientAnswerMasterId,Q.QuestionTitle,SA.Detail ,G.Id AS CompanyId,
		G.GroupName AS [CompanyName],EG.Id AS EstablishmentGroup_Id,
		REPLACE(REPLACE(REPLACE(EG.EstablishmentGroupName,'01',''),'02',''),'03','') AS EstablishmentGroupName,
		E.EstablishmentName as SalesPerson,ISNULL(U.Name,'UNDEFINED') AS BDO,UPPER(ISNULL(EstablishmentName,'UNDEFINED')) AS [Establishment Name],
		[Quote],[InformationCollection],[AtCredit],[ExtraInfo],[Approved],[PreApproved],[Disbursement],[Closed Deals],[DCP],
		Stage1_Date,Stage2_Date,Stage3_Date,Stage4_Date,Stage5_Date,Stage6_Date,Stage7_Date,Stage8_Date,Stage9_Date,Flag
		FROM SeenClientQuestions Q
		INNER JOIN dbo.SeenClientAnswerMaster AS SAM ON SAM.SeenClientId = Q.SeenClientId  AND ISNULL(SAM.IsDeleted,0) = 0
		INNER JOIN dbo.SeenClientAnswers AS SA ON SA.SeenClientAnswerMasterId = SAM.Id AND SA.QuestionId = Q.Id AND ISNULL(SA.IsDeleted,0) = 0  
		INNER JOIN dbo.Establishment E ON E.Id = SAM.EstablishmentId AND E.EstablishmentGroupId in(2667,2729,2727,2731,2733)
		INNER JOIN dbo.EstablishmentGroup EG ON E.EstablishmentGroupId = EG.Id AND E.IsDeleted = 0
		INNER JOIN dbo.[group] G ON G.Id = EG.GroupId AND EG.IsDeleted = 0
		INNER JOIN dbo.AppUser U ON U.Id = SAM.AppUserId AND U.IsDeleted = 0
		LEFT JOIN (
			SELECT SeenClientAnswerMasterId,
			MAX(CASE WHEN StageName = 'Quote' THEN CreatedOn ELSE NULL END) AS Quote,
			MAX(CASE WHEN StageName = 'Information Collection' THEN CreatedOn ELSE NULL END) AS InformationCollection,
			MAX(CASE WHEN StageName = 'At Credit' THEN CreatedOn ELSE NULL END) AS AtCredit,
			MAX(CASE WHEN StageName = 'Extra Information' THEN CreatedOn ELSE NULL END) AS ExtraInfo,
			MAX(CASE WHEN StageName = 'Approved' THEN CreatedOn ELSE NULL END) AS Approved,
			MAX(CASE WHEN StageName = 'Pre-approved' THEN CreatedOn ELSE NULL END) AS PreApproved,
			MAX(CASE WHEN StageName = 'Disbursement' THEN CreatedOn ELSE NULL END) AS Disbursement,
			MAX(CASE WHEN StageName = 'Closed Deals' THEN CreatedOn ELSE NULL END) AS [Closed Deals],
			MAX(CASE WHEN StageName = 'DCP' THEN CreatedOn ELSE NULL END) AS DCP,
			MAX(CASE WHEN Stage_Level =1 THEN CreatedOn ELSE NULL END) AS Stage1_Date,
			MAX(CASE WHEN Stage_Level =2 THEN CreatedOn ELSE NULL END) AS Stage2_Date,
			MAX(CASE WHEN Stage_Level =3 THEN CreatedOn ELSE NULL END) AS Stage3_Date,
			MAX(CASE WHEN Stage_Level = 4 THEN CreatedOn ELSE NULL END) AS Stage4_Date,
			MAX(CASE WHEN Stage_Level = 5 THEN CreatedOn ELSE NULL END) AS Stage5_Date,
			MAX(CASE WHEN Stage_Level = 6 THEN CreatedOn ELSE NULL END) AS Stage6_Date,
			MAX(CASE WHEN Stage_Level = 7 THEN CreatedOn ELSE NULL END) AS Stage7_Date,
			MAX(CASE WHEN Stage_Level = 8 THEN CreatedOn ELSE NULL END) AS Stage8_Date,
			MAX(CASE WHEN Stage_Level = 9 THEN CreatedOn ELSE NULL END) AS Stage9_Date,
			1 AS Flag
			FROM [dbo].[NEW_JDF_BI_Vw_Stage]
			GROUP BY SeenClientAnswerMasterId
		) Stage ON Stage.SeenClientAnswerMasterId = SAM.Id
		WHERE Q.IsDeleted = 0
		AND U.Id NOT IN (363,54)
	) S
	PIVOT (
		MAX(Detail)
		FOR  QuestionTitle IN (
			[Deposit Amount (This must be the amount)],
			[Estimated Equipment Delivery Date],
			[Company],
			[Quote Price],
			[Cell],
			[Comments],
			[Surname],
			[Email],
			[Follow Up Date],
			[Model],
			[Name]
		)
	) P
) X2

/*Stage Data section*/
UNION ALL 

	SELECT EstablishmentGroup_Id,SeenClientAnswerMasterId,CompanyId,
	[PostDate],	[CompanyName],EstablishmentGroupName,SalesPerson,BDO,[Establishment Name],
	[Name],	Surname,	[Cell],[Email],	[Company],
	[(1 = Swak ; 5 = Uitstekend)],[As ander, besryf asseblief],	[Comments (No Confidential Information)],
	[Enige mededingende kwotasies?],[Preferred financial solution?],[Prys],
	[Total Quote Amount],[Wat was die uiteinde van u besoek?],[Watter produkte was bespreek?],
	[Quote Price],[Deposit Amount (This must be the amount)],[Estimated Equipment Delivery Date],
	[Follow Up Date],[Model],[Comments],
	[Quote],[InformationCollection],[AtCredit],[ExtraInfo],[Approved],[PreApproved],[Disbursement],[Closed Deals],[DCP],
	Stage1_Date,Stage2_Date,Stage3_Date,Stage4_Date,Stage5_Date,Stage6_Date,Stage7_Date,Stage8_Date,Stage9_Date,
	Stage_1st_Days,Stage_2nd_Days,Stage_3rd_Days,Stage_4rd_Days,Stage_5th_Days,Stage_6th_Days,Stage_7th_Days,Stage_8th_Days,Stage_9th_Days,
	IsNull(Stage_1st_Days,0)+ IsNull(Stage_2nd_Days,0) + IsNull(Stage_3rd_Days,0) + IsNull(Stage_4rd_Days,0) + 
	IsNull(Stage_5th_Days,0) + IsNull(Stage_6th_Days,0) + IsNull(Stage_7th_Days,0) + IsNull(Stage_8th_Days,0) +IsNull(Stage_9th_Days,0) as Stage_TotalDays,
	Flag
	FROM (
		SELECT EstablishmentGroup_Id,SeenClientAnswerMasterId,CompanyId,
		[PostDate],
		[CompanyName],EstablishmentGroupName,SalesPerson,BDO,[Establishment Name],
		[Naam] as Name,
		[Van] as Surname,
		[Selfoon Nommer] as Cell,
		[E-Pos Adres] as Email,
		[Maatskappy Naam] as Company,
		NULL AS [(1 = Swak ; 5 = Uitstekend)],
		NULL AS [As ander, besryf asseblief],
		NULL AS [Comments (No Confidential Information)],
		NULL AS [Enige mededingende kwotasies?],
		NULL AS [Preferred financial solution?],
		NULL AS [Prys],
		NULL AS [Total Quote Amount],
		NULL AS [Wat was die uiteinde van u besoek?],
		NULL AS [Watter produkte was bespreek?],
		[Quote Price],
		LEFT(SUBSTRING([Deposit Amount (This must be the amount)], PATINDEX('%[0-9.-]%', [Deposit Amount (This must be the amount)]), 8000),
					PATINDEX('%[^0-9.-]%', SUBSTRING([Deposit Amount (This must be the amount)], PATINDEX('%[0-9.-]%', [Deposit Amount (This must be the amount)]), 8000) + 'X') -1)
		AS [Deposit Amount (This must be the amount)],
		[Estimated Equipment Delivery Date],
		[Follow Up Date],
		[Model],
		[Comments],
		[Quote],[InformationCollection],[AtCredit],[ExtraInfo],[Approved],[PreApproved],[Disbursement],[Closed Deals],[DCP],
		Stage1_Date,Stage2_Date,Stage3_Date,Stage4_Date,Stage5_Date,Stage6_Date,Stage7_Date,Stage8_Date,Stage9_Date,
		DATEDIFF(DAY,[PostDate],Stage1_Date) + 1 AS Stage_1st_Days,
		DATEDIFF(DAY,COALESCE(Stage1_Date,[PostDate]),[InformationCollection]) + 1 AS Stage_2nd_Days,
		DATEDIFF(DAY,COALESCE(Stage2_Date,Stage1_Date,[PostDate]),[AtCredit]) + 1 AS Stage_3rd_Days,
		DATEDIFF(DAY,COALESCE(Stage3_Date,Stage2_Date,Stage1_Date,[PostDate]),[ExtraInfo]) + 1 AS Stage_4rd_Days,
		DATEDIFF(DAY,COALESCE(Stage4_Date,Stage3_Date,Stage2_Date,Stage1_Date,[PostDate]),[Approved]) + 1 AS Stage_5th_Days,
		DATEDIFF(DAY,COALESCE(Stage5_Date,Stage4_Date,Stage3_Date,Stage2_Date,Stage1_Date,[PostDate]),[PreApproved]) + 1 AS Stage_6th_Days,
		DATEDIFF(DAY,COALESCE(Stage6_Date,Stage5_Date,Stage4_Date,Stage3_Date,Stage2_Date,Stage1_Date,[PostDate]),[Disbursement]) + 1 AS Stage_7th_Days,
		DATEDIFF(DAY,COALESCE(Stage7_Date,Stage6_Date,Stage5_Date,Stage4_Date,Stage3_Date,Stage2_Date,Stage1_Date,[PostDate]),[Closed Deals]) + 1 AS Stage_8th_Days,
		DATEDIFF(DAY,COALESCE(Stage8_Date,Stage7_Date,Stage6_Date,Stage5_Date,Stage4_Date,Stage3_Date,Stage2_Date,Stage1_Date,[PostDate]),[DCP]) + 1 AS Stage_9th_Days,Flag
		FROM (
			SELECT
			DATEADD(mi,SAM.TimeOffSet,SAM.CreatedOn) AS [PostDate],
			F.Id AS SeenClientAnswerMasterId,Q.QuestionTitle,SA.Detail ,G.Id AS CompanyId,
			G.GroupName AS [CompanyName],F.EstablishmentGroupId AS EstablishmentGroup_Id,
			REPLACE(REPLACE(REPLACE(EG.EstablishmentGroupName,'01',''),'02',''),'03','') AS EstablishmentGroupName,
			E.EstablishmentName as SalesPerson,ISNULL(U.Name,'UNDEFINED') AS BDO,UPPER(ISNULL(EstablishmentName,'UNDEFINED')) AS [Establishment Name],
			[Quote],[InformationCollection],[AtCredit],[ExtraInfo],[Approved],[PreApproved],[Disbursement],[Closed Deals],[DCP],
			Stage1_Date,Stage2_Date,Stage3_Date,Stage4_Date,Stage5_Date,Stage6_Date,Stage7_Date,Stage8_Date,Stage9_Date,Flag
			FROM JDF_BI_Vw_FACT_Magnitude F
			INNER JOIN dbo.SeenClientAnswerMaster AS SAM ON F.Scam_Id = SAM.Id
			INNER JOIN SeenClientQuestions Q ON SAM.SeenClientId = Q.SeenClientId  AND ISNULL(Q.IsDeleted,0) = 0
			INNER JOIN dbo.SeenClientAnswers AS SA ON SA.SeenClientAnswerMasterId = SAM.Id AND SA.QuestionId = Q.Id AND ISNULL(SA.IsDeleted,0) = 0  
			INNER JOIN dbo.Establishment E ON E.Id = SAM.EstablishmentId AND E.EstablishmentGroupId in(2315)
			INNER JOIN dbo.EstablishmentGroup EG ON E.EstablishmentGroupId = EG.Id AND E.IsDeleted = 0
			INNER JOIN dbo.[group] G ON G.Id = EG.GroupId AND EG.IsDeleted = 0
			INNER JOIN dbo.AppUser U ON U.Id = SAM.AppUserId AND U.IsDeleted = 0
			LEFT JOIN 
			(
				SELECT SeenClientAnswerMasterId,
				MAX(CASE WHEN StageName = 'Quote' THEN CreatedOn ELSE NULL END) AS Quote,
				MAX(CASE WHEN StageName = 'Information Collection' THEN CreatedOn ELSE NULL END) AS InformationCollection,
				MAX(CASE WHEN StageName = 'At Credit' THEN CreatedOn ELSE NULL END) AS AtCredit,
				MAX(CASE WHEN StageName = 'Extra Information' THEN CreatedOn ELSE NULL END) AS ExtraInfo,
				MAX(CASE WHEN StageName = 'Approved' THEN CreatedOn ELSE NULL END) AS Approved,
				MAX(CASE WHEN StageName = 'Pre-approved' THEN CreatedOn ELSE NULL END) AS PreApproved,
				MAX(CASE WHEN StageName = 'Disbursement' THEN CreatedOn ELSE NULL END) AS Disbursement,
				
				MAX(CASE WHEN StageName = 'Closed Deals' THEN CreatedOn ELSE NULL END) AS [Closed Deals],
				MAX(CASE WHEN StageName = 'DCP' THEN CreatedOn ELSE NULL END) AS DCP,

				MAX(CASE WHEN Stage_Level =1 THEN CreatedOn ELSE NULL END) AS Stage1_Date,
				MAX(CASE WHEN Stage_Level =2 THEN CreatedOn ELSE NULL END) AS Stage2_Date,
				MAX(CASE WHEN Stage_Level =3 THEN CreatedOn ELSE NULL END) AS Stage3_Date,
				MAX(CASE WHEN Stage_Level = 4 THEN CreatedOn ELSE NULL END) AS Stage4_Date,
				MAX(CASE WHEN Stage_Level = 5 THEN CreatedOn ELSE NULL END) AS Stage5_Date,
				MAX(CASE WHEN Stage_Level = 6 THEN CreatedOn ELSE NULL END) AS Stage6_Date,
				MAX(CASE WHEN Stage_Level = 7 THEN CreatedOn ELSE NULL END) AS Stage7_Date,
				MAX(CASE WHEN Stage_Level = 8 THEN CreatedOn ELSE NULL END) AS Stage8_Date,
				MAX(CASE WHEN Stage_Level = 9 THEN CreatedOn ELSE NULL END) AS Stage9_Date,
				1 AS Flag
				FROM [dbo].[NEW_JDF_BI_Vw_Stage]
				GROUP BY SeenClientAnswerMasterId
			) Stage ON Stage.SeenClientAnswerMasterId = SAM.Id
			WHERE F.EstablishmentGroupId < 0
			AND U.Id NOT IN (363,54)
		) S
		PIVOT (
			MAX(Detail)
			FOR  QuestionTitle IN (
				[Deposit Amount (This must be the amount)],
				[Estimated Equipment Delivery Date],
				[Maatskappy Naam],
				[Quote Price],
				[Selfoon Nommer],
				[Comments],
				[Van],
				[E-Pos Adres],
				[Follow Up Date],
				[Model],
				[Naam]
			)
		) P
	) XX

UNION ALL 

	SELECT EstablishmentGroup_Id,SeenClientAnswerMasterId,CompanyId,
	[PostDate],	[CompanyName],EstablishmentGroupName,SalesPerson,BDO,[Establishment Name],
	[Name],	[Surname],	[Cell],[Email],	[Company],
	[(1 = Swak ; 5 = Uitstekend)],[As ander, besryf asseblief],	[Comments (No Confidential Information)],
	[Enige mededingende kwotasies?],[Preferred financial solution?],[Prys],
	[Total Quote Amount],[Wat was die uiteinde van u besoek?],[Watter produkte was bespreek?],
	[Quote Price],[Deposit Amount (This must be the amount)],[Estimated Equipment Delivery Date],
	[Follow Up Date],[Model],[Comments],
	[Quote],[InformationCollection],[AtCredit],[ExtraInfo],[Approved],[PreApproved],[Disbursement],[Closed Deals],[DCP],
	Stage1_Date,Stage2_Date,Stage3_Date,Stage4_Date,Stage5_Date,Stage6_Date,Stage7_Date,Stage8_Date,Stage9_Date,
	Stage_1st_Days,Stage_2nd_Days,Stage_3rd_Days,Stage_4rd_Days,Stage_5th_Days,Stage_6th_Days,Stage_7th_Days,Stage_8th_Days,Stage_9th_Days,
	IsNull(Stage_1st_Days,0)+ IsNull(Stage_2nd_Days,0) + IsNull(Stage_3rd_Days,0) + IsNull(Stage_4rd_Days,0) + 
	IsNull(Stage_5th_Days,0) + IsNull(Stage_6th_Days,0) + IsNull(Stage_7th_Days,0) + IsNull(Stage_8th_Days,0) +IsNull(Stage_9th_Days,0) as Stage_TotalDays,
	Flag
	FROM (
		SELECT EstablishmentGroup_Id,SeenClientAnswerMasterId,CompanyId,
		[PostDate],
		[CompanyName],EstablishmentGroupName,SalesPerson,BDO,[Establishment Name],
		[Name],
		[Surname],
		Cell,
		[Email],
		[Company],
		NULL AS [(1 = Swak ; 5 = Uitstekend)],
		NULL AS [As ander, besryf asseblief],
		NULL AS [Comments (No Confidential Information)],
		NULL AS [Enige mededingende kwotasies?],
		NULL AS [Preferred financial solution?],
		NULL AS [Prys],
		NULL AS [Total Quote Amount],
		NULL AS [Wat was die uiteinde van u besoek?],
		NULL AS [Watter produkte was bespreek?],
		[Quote Price],
		LEFT(SUBSTRING([Deposit Amount (This must be the amount)], PATINDEX('%[0-9.-]%', [Deposit Amount (This must be the amount)]), 8000),
					PATINDEX('%[^0-9.-]%', SUBSTRING([Deposit Amount (This must be the amount)], PATINDEX('%[0-9.-]%', [Deposit Amount (This must be the amount)]), 8000) + 'X') -1)
		AS [Deposit Amount (This must be the amount)],
		[Estimated Equipment Delivery Date],
		[Follow Up Date],
		[Model],
		[Comments],
		[Quote],[InformationCollection],[AtCredit],[ExtraInfo],[Approved],[PreApproved],[Disbursement],[Closed Deals],[DCP],
		Stage1_Date,Stage2_Date,Stage3_Date,Stage4_Date,Stage5_Date,Stage6_Date,Stage7_Date,Stage8_Date,Stage9_Date,
		DATEDIFF(DAY,[PostDate],Stage1_Date) + 1 AS Stage_1st_Days,
		DATEDIFF(DAY,COALESCE(Stage1_Date,[PostDate]),[InformationCollection]) + 1 AS Stage_2nd_Days,
		DATEDIFF(DAY,COALESCE(Stage2_Date,Stage1_Date,[PostDate]),[AtCredit]) + 1 AS Stage_3rd_Days,
		DATEDIFF(DAY,COALESCE(Stage3_Date,Stage2_Date,Stage1_Date,[PostDate]),[ExtraInfo]) + 1 AS Stage_4rd_Days,
		DATEDIFF(DAY,COALESCE(Stage4_Date,Stage3_Date,Stage2_Date,Stage1_Date,[PostDate]),[Approved]) + 1 AS Stage_5th_Days,
		DATEDIFF(DAY,COALESCE(Stage5_Date,Stage4_Date,Stage3_Date,Stage2_Date,Stage1_Date,[PostDate]),[PreApproved]) + 1 AS Stage_6th_Days,
		DATEDIFF(DAY,COALESCE(Stage6_Date,Stage5_Date,Stage4_Date,Stage3_Date,Stage2_Date,Stage1_Date,[PostDate]),[Disbursement]) + 1 AS Stage_7th_Days,
		DATEDIFF(DAY,COALESCE(Stage7_Date,Stage6_Date,Stage5_Date,Stage4_Date,Stage3_Date,Stage2_Date,Stage1_Date,[PostDate]),[Closed Deals]) + 1 AS Stage_8th_Days,
		DATEDIFF(DAY,COALESCE(Stage8_Date,Stage7_Date,Stage6_Date,Stage5_Date,Stage4_Date,Stage3_Date,Stage2_Date,Stage1_Date,[PostDate]),[DCP]) + 1 AS Stage_9th_Days,Flag
		FROM (
			SELECT
			DATEADD(mi,SAM.TimeOffSet,SAM.CreatedOn) AS [PostDate],
			F.Id AS SeenClientAnswerMasterId,Q.QuestionTitle,SA.Detail ,G.Id AS CompanyId,
			G.GroupName AS [CompanyName],F.EstablishmentGroupId AS EstablishmentGroup_Id,
			REPLACE(REPLACE(REPLACE(EG.EstablishmentGroupName,'01',''),'02',''),'03','') AS EstablishmentGroupName,
			E.EstablishmentName as SalesPerson,ISNULL(U.Name,'UNDEFINED') AS BDO,UPPER(ISNULL(EstablishmentName,'UNDEFINED')) AS [Establishment Name],
			[Quote],[InformationCollection],[AtCredit],[ExtraInfo],[Approved],[PreApproved],[Disbursement],[Closed Deals],[DCP],
			Stage1_Date,Stage2_Date,Stage3_Date,Stage4_Date,Stage5_Date,Stage6_Date,Stage7_Date,Stage8_Date,Stage9_Date,Flag
			FROM JDF_BI_Vw_FACT_Magnitude F
			INNER JOIN dbo.SeenClientAnswerMaster AS SAM ON F.Scam_Id = SAM.Id
			INNER JOIN SeenClientQuestions Q ON SAM.SeenClientId = Q.SeenClientId  AND ISNULL(Q.IsDeleted,0) = 0
			INNER JOIN dbo.SeenClientAnswers AS SA ON SA.SeenClientAnswerMasterId = SAM.Id AND SA.QuestionId = Q.Id AND ISNULL(SA.IsDeleted,0) = 0  
			INNER JOIN dbo.Establishment E ON E.Id = SAM.EstablishmentId AND E.EstablishmentGroupId in(2667,2729,2727,2731,2733)
			INNER JOIN dbo.EstablishmentGroup EG ON E.EstablishmentGroupId = EG.Id AND E.IsDeleted = 0
			INNER JOIN dbo.[group] G ON G.Id = EG.GroupId AND EG.IsDeleted = 0
			INNER JOIN dbo.AppUser U ON U.Id = SAM.AppUserId AND U.IsDeleted = 0
			LEFT JOIN 
			(
				SELECT SeenClientAnswerMasterId,
				MAX(CASE WHEN StageName = 'Quote' THEN CreatedOn ELSE NULL END) AS Quote,
				MAX(CASE WHEN StageName = 'Information Collection' THEN CreatedOn ELSE NULL END) AS InformationCollection,
				MAX(CASE WHEN StageName = 'At Credit' THEN CreatedOn ELSE NULL END) AS AtCredit,
				MAX(CASE WHEN StageName = 'Extra Information' THEN CreatedOn ELSE NULL END) AS ExtraInfo,
				MAX(CASE WHEN StageName = 'Approved' THEN CreatedOn ELSE NULL END) AS Approved,
				MAX(CASE WHEN StageName = 'Pre-approved' THEN CreatedOn ELSE NULL END) AS PreApproved,
				MAX(CASE WHEN StageName = 'Disbursement' THEN CreatedOn ELSE NULL END) AS Disbursement,
				
				MAX(CASE WHEN StageName = 'Closed Deals' THEN CreatedOn ELSE NULL END) AS [Closed Deals],
				MAX(CASE WHEN StageName = 'DCP' THEN CreatedOn ELSE NULL END) AS DCP,

				MAX(CASE WHEN Stage_Level =1 THEN CreatedOn ELSE NULL END) AS Stage1_Date,
				MAX(CASE WHEN Stage_Level =2 THEN CreatedOn ELSE NULL END) AS Stage2_Date,
				MAX(CASE WHEN Stage_Level =3 THEN CreatedOn ELSE NULL END) AS Stage3_Date,
				MAX(CASE WHEN Stage_Level = 4 THEN CreatedOn ELSE NULL END) AS Stage4_Date,
				MAX(CASE WHEN Stage_Level = 5 THEN CreatedOn ELSE NULL END) AS Stage5_Date,
				MAX(CASE WHEN Stage_Level = 6 THEN CreatedOn ELSE NULL END) AS Stage6_Date,
				MAX(CASE WHEN Stage_Level = 7 THEN CreatedOn ELSE NULL END) AS Stage7_Date,
				MAX(CASE WHEN Stage_Level = 8 THEN CreatedOn ELSE NULL END) AS Stage8_Date,
				MAX(CASE WHEN Stage_Level = 9 THEN CreatedOn ELSE NULL END) AS Stage9_Date,
				1 AS Flag
				FROM [dbo].[NEW_JDF_BI_Vw_Stage]
				GROUP BY SeenClientAnswerMasterId
			) Stage ON Stage.SeenClientAnswerMasterId = SAM.Id
			WHERE F.EstablishmentGroupId < 0
			AND U.Id NOT IN (363,54)
		) S
		PIVOT (
			MAX(Detail)
			FOR  QuestionTitle IN (
				[Deposit Amount (This must be the amount)],
				[Estimated Equipment Delivery Date],
				[Company],
				[Quote Price],
				[Cell],
				[Comments],
				[Surname],
				[Email],
				[Follow Up Date],
				[Model],
				[Name]
			)
		) P
	) X3





) Z
LEFT OUTER JOIN [dbo].[Establishment_Town]  ET ON ET.[Town Name] = LTRIM(SUBSTRING(LTRIM(Z.[Establishment Name]),(LEN(LTRIM(Z.[Establishment Name])) - LEN(LTRIM(ET.[Town Name]))+1),LEN(LTRIM(ET.[Town Name]))))

)Main

left outer join

BI_Vw_DimChats Chats on Main.seenclientanswermasterid =Chats.SeenClientAnswerMasterId
*/



select Main.*,Chats.Date,Chats.Conversation
from

(
SELECT EstablishmentGroup_Id,SeenClientAnswerMasterId,
(CASE WHEN CompanyId = 27 AND ET.IsNorth = 1 THEN 'AFGRI NORTH' ELSE 
(CASE WHEN CompanyId = 27 AND ET.IsNorth = 0 THEN 'AFGRI SOUTH' ELSE
[CompanyName] END)END) AS [CompanyName],
--[CompanyName] AS [CompanyName],
[PostDate],
EstablishmentGroupName,SalesPerson,BDO,[Establishment Name],
[Name],[Surname],[Cell],[Email],[Company],
[(1 = Swak ; 5 = Uitstekend)],[As ander, besryf asseblief],[Comments (No Confidential Information)],[Enige mededingende kwotasies?],
[Preferred financial solution?],[Prys],[Total Quote Amount],[Wat was die uiteinde van u besoek?],[Watter produkte was bespreek?],
[Quote Price],[Deposit Amount (This must be the amount)],[Estimated Equipment Delivery Date],[Follow Up Date],[Model],[Comments],
[Quote],[InformationCollection],AtAnalyst,[Approved],[ExtraInfo],ContractRequired,[Disbursement],[Lost Deal],PreApproved,[Closed Deals],
Stage1_Date,Stage2_Date,Stage3_Date,Stage4_Date,Stage5_Date,Stage6_Date,Stage7_Date,Stage8_Date,Stage9_Date,Stage10_date,
Stage_1st_Days,Stage_2nd_Days,Stage_3rd_Days,Stage_4th_Days,Stage_5th_Days,Stage_6th_Days,Stage_7th_Days,Stage_8th_Days,Stage_9th_Days,Stage_10th_Days,
Stage_TotalDays,Flag

FROM (


	SELECT EstablishmentGroup_Id,SeenClientAnswerMasterId,CompanyId,[PostDate],
	[CompanyName],EstablishmentGroupName,SalesPerson,BDO,[Establishment Name],
	[Naam] as [Name],
	[Van] as [Surname],
	[Selfoon Nommer] as[Cell],
	[E-Pos Adres] as Email,
	[Maatskappy Naam] as Company,
	[(1 = Swak ; 5 = Uitstekend)],
	[As ander, besryf asseblief],
	[Comments (No Confidential Information)],
	[Enige mededingende kwotasies?],
	[Preferred financial solution?],
	[Prys],
	[Total Quote Amount],
	[Wat was die uiteinde van u besoek?],
	[Watter produkte was bespreek?],
	NULL AS [Quote Price],
	NULL AS [Deposit Amount (This must be the amount)],
	NULL AS [Estimated Equipment Delivery Date],
	NULL AS [Follow Up Date],
	NULL AS [Model],
	NULL AS [Comments],
	NULL AS [Quote],
	NULL AS [InformationCollection],
	NULL AS AtAnalyst,
	NULL AS [Approved],
	NULL AS [ExtraInfo],
	NULL AS ContractRequired,
	NULL AS [Disbursement],
	NULL as [Lost Deal],
	null as PreApproved,
	NULL AS [Closed Deals],
	NULL AS Stage1_Date,
	NULL AS Stage2_Date,
	NULL AS Stage3_Date,
	NULL AS Stage4_Date,
	NULL AS Stage5_Date,
	NULL AS Stage6_Date,
	NULL AS Stage7_Date,
	NULL AS Stage8_Date,
	NULL AS Stage9_Date,
	Null as Stage10_Date,
	NULL AS Stage_1st_Days,
	NULL AS Stage_2nd_Days,
	NULL AS Stage_3rd_Days,
	NULL AS Stage_4th_Days,
	NULL AS Stage_5th_Days,
	NULL AS Stage_6th_Days,
	NULL AS Stage_7th_Days,
	NULL AS Stage_8th_Days,
	NULL AS Stage_9th_Days,
	NULL AS Stage_10th_Days,
	NULL AS Stage_TotalDays,
	0 AS Flag
	FROM (
		SELECT 
		DATEADD(mi,SAM.TimeOffSet,SAM.CreatedOn) AS [PostDate],
		SA.SeenClientAnswerMasterId,Q.QuestionTitle,SA.Detail ,G.Id AS CompanyId,
		G.GroupName AS [CompanyName],EG.Id AS EstablishmentGroup_Id,
		REPLACE(REPLACE(REPLACE(EG.EstablishmentGroupName,'01',''),'02',''),'03','') AS EstablishmentGroupName,
		E.EstablishmentName as SalesPerson,ISNULL(U.Name,'UNDEFINED') AS BDO,UPPER(ISNULL(EstablishmentName,'UNDEFINED')) AS [Establishment Name]
		FROM SeenClientQuestions Q
		INNER JOIN dbo.SeenClientAnswerMaster AS SAM ON SAM.SeenClientId = Q.SeenClientId  AND ISNULL(SAM.IsDeleted,0) = 0
		INNER JOIN dbo.SeenClientAnswers AS SA ON SA.SeenClientAnswerMasterId = SAM.Id AND SA.QuestionId = Q.Id AND ISNULL(SA.IsDeleted,0) = 0  
		INNER JOIN dbo.Establishment E ON E.Id = SAM.EstablishmentId AND E.EstablishmentGroupId IN (963,2661)
		INNER JOIN dbo.EstablishmentGroup EG ON E.EstablishmentGroupId = EG.Id AND E.IsDeleted = 0
		INNER JOIN dbo.[group] G ON G.Id = EG.GroupId AND EG.IsDeleted = 0
		INNER JOIN dbo.AppUser U ON U.Id = SAM.AppUserId AND U.IsDeleted = 0
		INNER JOIN dbo.JDF_BI_Vw_FinancedBy FIN ON Fin.SeenClientAnswerMasterId = SAM.Id AND FIN.[Financed By] = 'John Deere Finance'
		WHERE Q.IsDeleted = 0
		AND U.Id NOT IN (363,54)
	) S
	PIVOT (
		MAX(Detail)
		FOR  QuestionTitle IN (
			[Naam],
			[Van],
			[Selfoon Nommer],
			[E-Pos Adres],
			[Maatskappy Naam],
			[Watter produkte was bespreek?], 
			[(1 = Swak ; 5 = Uitstekend)],
			[As ander, besryf asseblief],
			[Comments (No Confidential Information)],
			[Enige mededingende kwotasies?],
			[Preferred financial solution?],
			[Prys],
			[Total Quote Amount],
			[Wat was die uiteinde van u besoek?]
		)
	) P

UNION ALL

Select EstablishmentGroup_Id,SeenClientAnswerMasterId,CompanyId,[PostDate],
[CompanyName],EstablishmentGroupName,SalesPerson,BDO,[Establishment Name],
[Name],[Surname],[Cell],[Email],[Company],[(1 = Swak ; 5 = Uitstekend)],
[As ander, besryf asseblief],[Comments (No Confidential Information)],[Enige mededingende kwotasies?],
[Preferred financial solution?],[Prys],[Total Quote Amount],[Wat was die uiteinde van u besoek?],
[Watter produkte was bespreek?],[Quote Price],[Deposit Amount (This must be the amount)],
[Estimated Equipment Delivery Date],[Follow Up Date],[Model],[Comments],
[Quote],[InformationCollection],AtAnalyst,[Approved],[ExtraInfo],ContractRequired,[Disbursement],[Lost Deal],PreApproved,[Closed Deals],
Stage1_Date,Stage2_Date,Stage3_Date,Stage4_Date,Stage5_Date,Stage6_Date,Stage7_Date,Stage8_Date,Stage9_Date,Stage10_Date,
Stage_1st_Days,Stage_2nd_Days,Stage_3rd_Days,Stage_4rd_Days,Stage_5th_Days,Stage_6th_Days,Stage_7th_Days,Stage_8th_Days,Stage_9th_Days,Stage_10th_Days,
IsNull(Stage_1st_Days,0)+ IsNull(Stage_2nd_Days,0) + IsNull(Stage_3rd_Days,0) + IsNull(Stage_4rd_Days,0) + 
IsNull(Stage_5th_Days,0) + IsNull(Stage_6th_Days,0) + IsNull(Stage_7th_Days,0) + IsNull(Stage_8th_Days,0) +IsNull(Stage_9th_Days,0)+IsNull(Stage_10th_Days,0) as Stage_TotalDays,
Flag
FROM (
	SELECT EstablishmentGroup_Id,SeenClientAnswerMasterId,CompanyId,
	[PostDate],
	[CompanyName],EstablishmentGroupName,SalesPerson,BDO,[Establishment Name],
	[Naam] as [Name],
	[Van] as [Surname],
	[Selfoon Nommer] as [Cell],
	[E-Pos Adres] as Email,
	[Maatskappy Naam] as Company,
	NULL AS [(1 = Swak ; 5 = Uitstekend)],
	NULL AS [As ander, besryf asseblief],
	NULL AS [Comments (No Confidential Information)],
	NULL AS [Enige mededingende kwotasies?],
	NULL AS [Preferred financial solution?],
	NULL AS [Prys],
	NULL AS [Total Quote Amount],
	NULL AS [Wat was die uiteinde van u besoek?],
	NULL AS [Watter produkte was bespreek?],
	[Quote Price],
	LEFT(SUBSTRING([Deposit Amount (This must be the amount)], PATINDEX('%[0-9.-]%', [Deposit Amount (This must be the amount)]), 8000),
			   PATINDEX('%[^0-9.-]%', SUBSTRING([Deposit Amount (This must be the amount)], PATINDEX('%[0-9.-]%', [Deposit Amount (This must be the amount)]), 8000) + 'X') -1)
	AS [Deposit Amount (This must be the amount)],
	[Estimated Equipment Delivery Date],
	[Follow Up Date],
	[Model],
	[Comments],
	[Quote],[InformationCollection],AtAnalyst,[Approved],[ExtraInfo],ContractRequired,[Disbursement],[Lost Deal],PreApproved,[Closed Deals],
	Stage1_Date,Stage2_Date,Stage3_Date,Stage4_Date,Stage5_Date,Stage6_Date,Stage7_Date,Stage8_Date,Stage9_Date,Stage10_Date,
	DATEDIFF(DAY,[PostDate],Stage1_Date) + 1 AS Stage_1st_Days,
	DATEDIFF(DAY,COALESCE(Stage1_Date,[PostDate]),[InformationCollection]) + 1 AS Stage_2nd_Days,
	DATEDIFF(DAY,COALESCE(Stage2_Date,Stage1_Date,[PostDate]),AtAnalyst) + 1 AS Stage_3rd_Days,
	DATEDIFF(DAY,COALESCE(Stage3_Date,Stage2_Date,Stage1_Date,[PostDate]),[Approved]) + 1 AS Stage_4rd_Days,
	DATEDIFF(DAY,COALESCE(Stage4_Date,Stage3_Date,Stage2_Date,Stage1_Date,[PostDate]),ExtraInfo) + 1 AS Stage_5th_Days,
	DATEDIFF(DAY,COALESCE(Stage5_Date,Stage4_Date,Stage3_Date,Stage2_Date,Stage1_Date,[PostDate]),ContractRequired) + 1 AS Stage_6th_Days,
	DATEDIFF(DAY,COALESCE(Stage6_Date,Stage5_Date,Stage4_Date,Stage3_Date,Stage2_Date,Stage1_Date,[PostDate]),[Disbursement]) + 1 AS Stage_7th_Days,
	DATEDIFF(DAY,COALESCE(Stage7_Date,Stage6_Date,Stage5_Date,Stage4_Date,Stage3_Date,Stage2_Date,Stage1_Date,[PostDate]),[Lost Deal]) + 1 AS Stage_8th_Days,
	DATEDIFF(DAY,COALESCE(Stage8_Date,Stage7_Date,Stage6_Date,Stage5_Date,Stage4_Date,Stage3_Date,Stage2_Date,Stage1_Date,[PostDate]),PreApproved) + 1 AS Stage_9th_Days,
	DATEDIFF(DAY,COALESCE(stage9_Date,Stage8_Date,Stage7_Date,Stage6_Date,Stage5_Date,Stage4_Date,Stage3_Date,Stage2_Date,Stage1_Date,[PostDate]),[Closed Deals]) + 1 AS Stage_10th_Days,
	Flag
	FROM (
		SELECT 
		DATEADD(mi,SAM.TimeOffSet,SAM.CreatedOn) AS [PostDate],
		SA.SeenClientAnswerMasterId,Q.QuestionTitle,SA.Detail ,G.Id AS CompanyId,
		G.GroupName AS [CompanyName],EG.Id AS EstablishmentGroup_Id,
		REPLACE(REPLACE(REPLACE(EG.EstablishmentGroupName,'01',''),'02',''),'03','') AS EstablishmentGroupName,
		E.EstablishmentName as SalesPerson,ISNULL(U.Name,'UNDEFINED') AS BDO,UPPER(ISNULL(EstablishmentName,'UNDEFINED')) AS [Establishment Name],
		[Quote],[InformationCollection],AtAnalyst,[Approved],[ExtraInfo],ContractRequired,[Disbursement],[Lost Deal],PreApproved,[Closed Deals],
		Stage1_Date,Stage2_Date,Stage3_Date,Stage4_Date,Stage5_Date,Stage6_Date,Stage7_Date,Stage8_Date,Stage9_Date,Stage10_Date,Flag
		FROM SeenClientQuestions Q
		INNER JOIN dbo.SeenClientAnswerMaster AS SAM ON SAM.SeenClientId = Q.SeenClientId  AND ISNULL(SAM.IsDeleted,0) = 0
		INNER JOIN dbo.SeenClientAnswers AS SA ON SA.SeenClientAnswerMasterId = SAM.Id AND SA.QuestionId = Q.Id AND ISNULL(SA.IsDeleted,0) = 0  
		INNER JOIN dbo.Establishment E ON E.Id = SAM.EstablishmentId AND E.EstablishmentGroupId in( 2315)
		INNER JOIN dbo.EstablishmentGroup EG ON E.EstablishmentGroupId = EG.Id AND E.IsDeleted = 0
		INNER JOIN dbo.[group] G ON G.Id = EG.GroupId AND EG.IsDeleted = 0
		INNER JOIN dbo.AppUser U ON U.Id = SAM.AppUserId AND U.IsDeleted = 0
		LEFT JOIN (
			SELECT SeenClientAnswerMasterId,
			MAX(CASE WHEN StageName = 'Quote' THEN CreatedOn ELSE NULL END) AS Quote,
			MAX(CASE WHEN StageName = 'Information Collection' THEN CreatedOn ELSE NULL END) AS InformationCollection,
			MAX(CASE WHEN StageName = 'At Analyst' THEN CreatedOn ELSE NULL END) AS AtAnalyst,
			MAX(CASE WHEN StageName = 'Approved' THEN CreatedOn ELSE NULL END) AS Approved,
			MAX(CASE WHEN StageName = 'Extra Information' THEN CreatedOn ELSE NULL END) AS ExtraInfo,
			MAX(CASE WHEN StageName = 'Contract Requested' THEN CreatedOn ELSE NULL END) AS ContractRequired,
			MAX(CASE WHEN StageName = 'Disbursement' THEN CreatedOn ELSE NULL END) AS Disbursement,

			MAX(CASE WHEN StageName = 'Lost Deal' THEN CreatedOn ELSE NULL END) AS [Lost Deal],	
			MAX(CASE WHEN StageName = 'Pre-approved' THEN CreatedOn ELSE NULL END) AS PreApproved,	
			MAX(CASE WHEN StageName = 'Closed Deals' THEN CreatedOn ELSE NULL END) AS [Closed Deals],
			
			MAX(CASE WHEN Stage_Level =1 THEN CreatedOn ELSE NULL END) AS Stage1_Date,
			MAX(CASE WHEN Stage_Level =2 THEN CreatedOn ELSE NULL END) AS Stage2_Date,
			MAX(CASE WHEN Stage_Level =3 THEN CreatedOn ELSE NULL END) AS Stage3_Date,
			MAX(CASE WHEN Stage_Level = 4 THEN CreatedOn ELSE NULL END) AS Stage4_Date,
			MAX(CASE WHEN Stage_Level = 5 THEN CreatedOn ELSE NULL END) AS Stage5_Date,
			MAX(CASE WHEN Stage_Level = 6 THEN CreatedOn ELSE NULL END) AS Stage6_Date,
			MAX(CASE WHEN Stage_Level = 7 THEN CreatedOn ELSE NULL END) AS Stage7_Date,
			MAX(CASE WHEN Stage_Level = 8 THEN CreatedOn ELSE NULL END) AS Stage8_Date,
			MAX(CASE WHEN Stage_Level = 9 THEN CreatedOn ELSE NULL END) AS Stage9_Date,
				MAX(CASE WHEN Stage_Level = 10 THEN CreatedOn ELSE NULL END) AS Stage10_Date,
			1 AS Flag
			FROM [dbo].[NEW_JDF_BI_Vw_Stage]
			GROUP BY SeenClientAnswerMasterId
		) Stage ON Stage.SeenClientAnswerMasterId = SAM.Id
		WHERE Q.IsDeleted = 0
		AND U.Id NOT IN (363,54)
	) S
	PIVOT (
		MAX(Detail)
		FOR  QuestionTitle IN (
			[Deposit Amount (This must be the amount)],
			[Estimated Equipment Delivery Date],
			[Maatskappy Naam],
			[Quote Price],
			[Selfoon Nommer],
			[Comments],
			[Van],
			[E-Pos Adres],
			[Follow Up Date],
			[Model],
			[Naam]
		)
	) P
) X
UNION ALL

Select EstablishmentGroup_Id,SeenClientAnswerMasterId,CompanyId,[PostDate],
[CompanyName],EstablishmentGroupName,SalesPerson,BDO,[Establishment Name],
[Name],[Surname],[Cell],[Email],[Company],[(1 = Swak ; 5 = Uitstekend)],
[As ander, besryf asseblief],[Comments (No Confidential Information)],[Enige mededingende kwotasies?],
[Preferred financial solution?],[Prys],[Total Quote Amount],[Wat was die uiteinde van u besoek?],
[Watter produkte was bespreek?],[Quote Price],[Deposit Amount (This must be the amount)],
[Estimated Equipment Delivery Date],[Follow Up Date],[Model],[Comments],
[Quote],[InformationCollection],AtAnalyst,Approved,ExtraInfo,ContractRequired,[Disbursement],[Lost Deal],PreApproved,[Closed Deals],
Stage1_Date,Stage2_Date,Stage3_Date,Stage4_Date,Stage5_Date,Stage6_Date,Stage7_Date,Stage8_Date,Stage9_Date,Stage10_Date,
Stage_1st_Days,Stage_2nd_Days,Stage_3rd_Days,Stage_4rd_Days,Stage_5th_Days,Stage_6th_Days,Stage_7th_Days,Stage_8th_Days,Stage_9th_Days,Stage_10th_Days,
IsNull(Stage_1st_Days,0)+ IsNull(Stage_2nd_Days,0) + IsNull(Stage_3rd_Days,0) + IsNull(Stage_4rd_Days,0) + 
IsNull(Stage_5th_Days,0) + IsNull(Stage_6th_Days,0) + IsNull(Stage_7th_Days,0) + IsNull(Stage_8th_Days,0) +IsNull(Stage_9th_Days,0)+IsNull(Stage_10th_Days,0) as Stage_TotalDays,
Flag
FROM (
	SELECT EstablishmentGroup_Id,SeenClientAnswerMasterId,CompanyId,
	[PostDate],
	[CompanyName],EstablishmentGroupName,SalesPerson,BDO,[Establishment Name],
	[Name],
	[Surname],
	[Cell],
	[Email],
	[Company],
	NULL AS [(1 = Swak ; 5 = Uitstekend)],
	NULL AS [As ander, besryf asseblief],
	NULL AS [Comments (No Confidential Information)],
	NULL AS [Enige mededingende kwotasies?],
	NULL AS [Preferred financial solution?],
	NULL AS [Prys],
	NULL AS [Total Quote Amount],
	NULL AS [Wat was die uiteinde van u besoek?],
	NULL AS [Watter produkte was bespreek?],
	[Quote Price],
	LEFT(SUBSTRING([Deposit Amount (This must be the amount)], PATINDEX('%[0-9.-]%', [Deposit Amount (This must be the amount)]), 8000),
			   PATINDEX('%[^0-9.-]%', SUBSTRING([Deposit Amount (This must be the amount)], PATINDEX('%[0-9.-]%', [Deposit Amount (This must be the amount)]), 8000) + 'X') -1)
	AS [Deposit Amount (This must be the amount)],
	[Estimated Equipment Delivery Date],
	[Follow Up Date],
	[Model],
	[Comments],
	[Quote],[InformationCollection],AtAnalyst,Approved,ExtraInfo,ContractRequired,[Disbursement],[Lost Deal],PreApproved,[Closed Deals],
	Stage1_Date,Stage2_Date,Stage3_Date,Stage4_Date,Stage5_Date,Stage6_Date,Stage7_Date,Stage8_Date,Stage9_Date,Stage10_Date,
	DATEDIFF(DAY,[PostDate],Stage1_Date) + 1 AS Stage_1st_Days,
	DATEDIFF(DAY,COALESCE(Stage1_Date,[PostDate]),[InformationCollection]) + 1 AS Stage_2nd_Days,
	DATEDIFF(DAY,COALESCE(Stage2_Date,Stage1_Date,[PostDate]),AtAnalyst) + 1 AS Stage_3rd_Days,
	DATEDIFF(DAY,COALESCE(Stage3_Date,Stage2_Date,Stage1_Date,[PostDate]),Approved) + 1 AS Stage_4rd_Days,
	DATEDIFF(DAY,COALESCE(Stage4_Date,Stage3_Date,Stage2_Date,Stage1_Date,[PostDate]),ExtraInfo) + 1 AS Stage_5th_Days,
	DATEDIFF(DAY,COALESCE(Stage5_Date,Stage4_Date,Stage3_Date,Stage2_Date,Stage1_Date,[PostDate]),ContractRequired) + 1 AS Stage_6th_Days,
	DATEDIFF(DAY,COALESCE(Stage6_Date,Stage5_Date,Stage4_Date,Stage3_Date,Stage2_Date,Stage1_Date,[PostDate]),[Disbursement]) + 1 AS Stage_7th_Days,
	DATEDIFF(DAY,COALESCE(Stage7_Date,Stage6_Date,Stage5_Date,Stage4_Date,Stage3_Date,Stage2_Date,Stage1_Date,[PostDate]),[Lost Deal]) + 1 AS Stage_8th_Days,
	DATEDIFF(DAY,COALESCE(Stage8_Date,Stage7_Date,Stage6_Date,Stage5_Date,Stage4_Date,Stage3_Date,Stage2_Date,Stage1_Date,[PostDate]),PreApproved) + 1 AS Stage_9th_Days,
	DATEDIFF(DAY,COALESCE(stage9_Date,Stage8_Date,Stage7_Date,Stage6_Date,Stage5_Date,Stage4_Date,Stage3_Date,Stage2_Date,Stage1_Date,[PostDate]),[Closed Deals]) + 1 AS Stage_10th_Days,
	Flag
	FROM (
		SELECT 
		DATEADD(mi,SAM.TimeOffSet,SAM.CreatedOn) AS [PostDate],
		SA.SeenClientAnswerMasterId,Q.QuestionTitle,SA.Detail ,G.Id AS CompanyId,
		G.GroupName AS [CompanyName],EG.Id AS EstablishmentGroup_Id,
		REPLACE(REPLACE(REPLACE(EG.EstablishmentGroupName,'01',''),'02',''),'03','') AS EstablishmentGroupName,
		E.EstablishmentName as SalesPerson,ISNULL(U.Name,'UNDEFINED') AS BDO,UPPER(ISNULL(EstablishmentName,'UNDEFINED')) AS [Establishment Name],
		[Quote],[InformationCollection],AtAnalyst,Approved,ExtraInfo,ContractRequired,[Disbursement],[Lost Deal],PreApproved,[Closed Deals],
		Stage1_Date,Stage2_Date,Stage3_Date,Stage4_Date,Stage5_Date,Stage6_Date,Stage7_Date,Stage8_Date,Stage9_Date,Stage10_Date,Flag
		FROM SeenClientQuestions Q
		INNER JOIN dbo.SeenClientAnswerMaster AS SAM ON SAM.SeenClientId = Q.SeenClientId  AND ISNULL(SAM.IsDeleted,0) = 0
		INNER JOIN dbo.SeenClientAnswers AS SA ON SA.SeenClientAnswerMasterId = SAM.Id AND SA.QuestionId = Q.Id AND ISNULL(SA.IsDeleted,0) = 0  
		INNER JOIN dbo.Establishment E ON E.Id = SAM.EstablishmentId AND E.EstablishmentGroupId in(2667,2729,2727,2731,2733)
		INNER JOIN dbo.EstablishmentGroup EG ON E.EstablishmentGroupId = EG.Id AND E.IsDeleted = 0
		INNER JOIN dbo.[group] G ON G.Id = EG.GroupId AND EG.IsDeleted = 0
		INNER JOIN dbo.AppUser U ON U.Id = SAM.AppUserId AND U.IsDeleted = 0
		LEFT JOIN (
			SELECT SeenClientAnswerMasterId,
			MAX(CASE WHEN StageName = 'Quote' THEN CreatedOn ELSE NULL END) AS Quote,
			MAX(CASE WHEN StageName = 'Information Collection' THEN CreatedOn ELSE NULL END) AS InformationCollection,
			MAX(CASE WHEN StageName = 'At Analyst' THEN CreatedOn ELSE NULL END) AS AtAnalyst,
			MAX(CASE WHEN StageName = 'Approved' THEN CreatedOn ELSE NULL END) AS Approved,
			MAX(CASE WHEN StageName = 'Extra Information' THEN CreatedOn ELSE NULL END) AS ExtraInfo,
			MAX(CASE WHEN StageName = 'Contract Requested' THEN CreatedOn ELSE NULL END) AS ContractRequired,
			MAX(CASE WHEN StageName = 'Disbursement' THEN CreatedOn ELSE NULL END) AS Disbursement,

			MAX(CASE WHEN StageName = 'Lost Deal' THEN CreatedOn ELSE NULL END) AS [Lost Deal],	
			MAX(CASE WHEN StageName = 'Pre-approved' THEN CreatedOn ELSE NULL END) AS PreApproved,	
			MAX(CASE WHEN StageName = 'Closed Deals' THEN CreatedOn ELSE NULL END) AS [Closed Deals],
			MAX(CASE WHEN Stage_Level =1 THEN CreatedOn ELSE NULL END) AS Stage1_Date,
			MAX(CASE WHEN Stage_Level =2 THEN CreatedOn ELSE NULL END) AS Stage2_Date,
			MAX(CASE WHEN Stage_Level =3 THEN CreatedOn ELSE NULL END) AS Stage3_Date,
			MAX(CASE WHEN Stage_Level = 4 THEN CreatedOn ELSE NULL END) AS Stage4_Date,
			MAX(CASE WHEN Stage_Level = 5 THEN CreatedOn ELSE NULL END) AS Stage5_Date,
			MAX(CASE WHEN Stage_Level = 6 THEN CreatedOn ELSE NULL END) AS Stage6_Date,
			MAX(CASE WHEN Stage_Level = 7 THEN CreatedOn ELSE NULL END) AS Stage7_Date,
			MAX(CASE WHEN Stage_Level = 8 THEN CreatedOn ELSE NULL END) AS Stage8_Date,
			MAX(CASE WHEN Stage_Level = 9 THEN CreatedOn ELSE NULL END) AS Stage9_Date,
			MAX(CASE WHEN Stage_Level = 10 THEN CreatedOn ELSE NULL END) AS Stage10_Date,
			1 AS Flag
			FROM [dbo].[NEW_JDF_BI_Vw_Stage]
			GROUP BY SeenClientAnswerMasterId
		) Stage ON Stage.SeenClientAnswerMasterId = SAM.Id
		WHERE Q.IsDeleted = 0
		AND U.Id NOT IN (363,54)
	) S
	PIVOT (
		MAX(Detail)
		FOR  QuestionTitle IN (
			[Deposit Amount (This must be the amount)],
			[Estimated Equipment Delivery Date],
			[Company],
			[Quote Price],
			[Cell],
			[Comments],
			[Surname],
			[Email],
			[Follow Up Date],
			[Model],
			[Name]
		)
	) P
) X2

/*Stage Data section*/
UNION ALL 

	SELECT EstablishmentGroup_Id,SeenClientAnswerMasterId,CompanyId,
	[PostDate],	[CompanyName],EstablishmentGroupName,SalesPerson,BDO,[Establishment Name],
	[Name],	Surname,	[Cell],[Email],	[Company],
	[(1 = Swak ; 5 = Uitstekend)],[As ander, besryf asseblief],	[Comments (No Confidential Information)],
	[Enige mededingende kwotasies?],[Preferred financial solution?],[Prys],
	[Total Quote Amount],[Wat was die uiteinde van u besoek?],[Watter produkte was bespreek?],
	[Quote Price],[Deposit Amount (This must be the amount)],[Estimated Equipment Delivery Date],
	[Follow Up Date],[Model],[Comments],
[Quote],[InformationCollection],AtAnalyst,[Approved],[ExtraInfo],ContractRequired,[Disbursement],[Lost Deal],PreApproved,[Closed Deals],
Stage1_Date,Stage2_Date,Stage3_Date,Stage4_Date,Stage5_Date,Stage6_Date,Stage7_Date,Stage8_Date,Stage9_Date,Stage10_Date,
Stage_1st_Days,Stage_2nd_Days,Stage_3rd_Days,Stage_4rd_Days,Stage_5th_Days,Stage_6th_Days,Stage_7th_Days,Stage_8th_Days,Stage_9th_Days,Stage_10th_Days,
IsNull(Stage_1st_Days,0)+ IsNull(Stage_2nd_Days,0) + IsNull(Stage_3rd_Days,0) + IsNull(Stage_4rd_Days,0) + 
IsNull(Stage_5th_Days,0) + IsNull(Stage_6th_Days,0) + IsNull(Stage_7th_Days,0) + IsNull(Stage_8th_Days,0) +IsNull(Stage_9th_Days,0)+IsNull(Stage_10th_Days,0) as Stage_TotalDays,
Flag
	FROM (
		SELECT EstablishmentGroup_Id,SeenClientAnswerMasterId,CompanyId,
		[PostDate],
		[CompanyName],EstablishmentGroupName,SalesPerson,BDO,[Establishment Name],
		[Naam] as Name,
		[Van] as Surname,
		[Selfoon Nommer] as Cell,
		[E-Pos Adres] as Email,
		[Maatskappy Naam] as Company,
		NULL AS [(1 = Swak ; 5 = Uitstekend)],
		NULL AS [As ander, besryf asseblief],
		NULL AS [Comments (No Confidential Information)],
		NULL AS [Enige mededingende kwotasies?],
		NULL AS [Preferred financial solution?],
		NULL AS [Prys],
		NULL AS [Total Quote Amount],
		NULL AS [Wat was die uiteinde van u besoek?],
		NULL AS [Watter produkte was bespreek?],
		[Quote Price],
		LEFT(SUBSTRING([Deposit Amount (This must be the amount)], PATINDEX('%[0-9.-]%', [Deposit Amount (This must be the amount)]), 8000),
					PATINDEX('%[^0-9.-]%', SUBSTRING([Deposit Amount (This must be the amount)], PATINDEX('%[0-9.-]%', [Deposit Amount (This must be the amount)]), 8000) + 'X') -1)
		AS [Deposit Amount (This must be the amount)],
		[Estimated Equipment Delivery Date],
		[Follow Up Date],
		[Model],
		[Comments],
		[Quote],[InformationCollection],AtAnalyst,[Approved],[ExtraInfo],ContractRequired,[Disbursement],[Lost Deal],PreApproved,[Closed Deals],
	Stage1_Date,Stage2_Date,Stage3_Date,Stage4_Date,Stage5_Date,Stage6_Date,Stage7_Date,Stage8_Date,Stage9_Date,Stage10_Date,
	DATEDIFF(DAY,[PostDate],Stage1_Date) + 1 AS Stage_1st_Days,
	DATEDIFF(DAY,COALESCE(Stage1_Date,[PostDate]),[InformationCollection]) + 1 AS Stage_2nd_Days,
	DATEDIFF(DAY,COALESCE(Stage2_Date,Stage1_Date,[PostDate]),AtAnalyst) + 1 AS Stage_3rd_Days,
	DATEDIFF(DAY,COALESCE(Stage3_Date,Stage2_Date,Stage1_Date,[PostDate]),[Approved]) + 1 AS Stage_4rd_Days,
	DATEDIFF(DAY,COALESCE(Stage4_Date,Stage3_Date,Stage2_Date,Stage1_Date,[PostDate]),ExtraInfo) + 1 AS Stage_5th_Days,
	DATEDIFF(DAY,COALESCE(Stage5_Date,Stage4_Date,Stage3_Date,Stage2_Date,Stage1_Date,[PostDate]),ContractRequired) + 1 AS Stage_6th_Days,
	DATEDIFF(DAY,COALESCE(Stage6_Date,Stage5_Date,Stage4_Date,Stage3_Date,Stage2_Date,Stage1_Date,[PostDate]),[Disbursement]) + 1 AS Stage_7th_Days,
	DATEDIFF(DAY,COALESCE(Stage7_Date,Stage6_Date,Stage5_Date,Stage4_Date,Stage3_Date,Stage2_Date,Stage1_Date,[PostDate]),[Lost Deal]) + 1 AS Stage_8th_Days,
	DATEDIFF(DAY,COALESCE(Stage8_Date,Stage7_Date,Stage6_Date,Stage5_Date,Stage4_Date,Stage3_Date,Stage2_Date,Stage1_Date,[PostDate]),PreApproved) + 1 AS Stage_9th_Days,
	DATEDIFF(DAY,COALESCE(stage9_Date,Stage8_Date,Stage7_Date,Stage6_Date,Stage5_Date,Stage4_Date,Stage3_Date,Stage2_Date,Stage1_Date,[PostDate]),[Closed Deals]) + 1 AS Stage_10th_Days,
	Flag FROM (
			SELECT
			DATEADD(mi,SAM.TimeOffSet,SAM.CreatedOn) AS [PostDate],
			F.Id AS SeenClientAnswerMasterId,Q.QuestionTitle,SA.Detail ,G.Id AS CompanyId,
			G.GroupName AS [CompanyName],F.EstablishmentGroupId AS EstablishmentGroup_Id,
			REPLACE(REPLACE(REPLACE(EG.EstablishmentGroupName,'01',''),'02',''),'03','') AS EstablishmentGroupName,
			E.EstablishmentName as SalesPerson,ISNULL(U.Name,'UNDEFINED') AS BDO,UPPER(ISNULL(EstablishmentName,'UNDEFINED')) AS [Establishment Name],
			[Quote],[InformationCollection],AtAnalyst,Approved,ExtraInfo,ContractRequired,Disbursement,[Lost Deal],PreApproved,[Closed Deals],
			Stage1_Date,Stage2_Date,Stage3_Date,Stage4_Date,Stage5_Date,Stage6_Date,Stage7_Date,Stage8_Date,Stage9_Date,Stage10_Date,Flag
			FROM JDF_BI_Vw_FACT_Magnitude F
			INNER JOIN dbo.SeenClientAnswerMaster AS SAM ON F.Scam_Id = SAM.Id
			INNER JOIN SeenClientQuestions Q ON SAM.SeenClientId = Q.SeenClientId  AND ISNULL(Q.IsDeleted,0) = 0
			INNER JOIN dbo.SeenClientAnswers AS SA ON SA.SeenClientAnswerMasterId = SAM.Id AND SA.QuestionId = Q.Id AND ISNULL(SA.IsDeleted,0) = 0  
			INNER JOIN dbo.Establishment E ON E.Id = SAM.EstablishmentId AND E.EstablishmentGroupId in(2315)
			INNER JOIN dbo.EstablishmentGroup EG ON E.EstablishmentGroupId = EG.Id AND E.IsDeleted = 0
			INNER JOIN dbo.[group] G ON G.Id = EG.GroupId AND EG.IsDeleted = 0
			INNER JOIN dbo.AppUser U ON U.Id = SAM.AppUserId AND U.IsDeleted = 0
			LEFT JOIN 
			(
				SELECT SeenClientAnswerMasterId,
					MAX(CASE WHEN StageName = 'Quote' THEN CreatedOn ELSE NULL END) AS Quote,
			MAX(CASE WHEN StageName = 'Information Collection' THEN CreatedOn ELSE NULL END) AS InformationCollection,
			MAX(CASE WHEN StageName = 'At Analyst' THEN CreatedOn ELSE NULL END) AS AtAnalyst,
			MAX(CASE WHEN StageName = 'Approved' THEN CreatedOn ELSE NULL END) AS Approved,
			MAX(CASE WHEN StageName = 'Extra Information' THEN CreatedOn ELSE NULL END) AS ExtraInfo,
			MAX(CASE WHEN StageName = 'Contract Requested' THEN CreatedOn ELSE NULL END) AS ContractRequired,
			MAX(CASE WHEN StageName = 'Disbursement' THEN CreatedOn ELSE NULL END) AS Disbursement,

			MAX(CASE WHEN StageName = 'Lost Deal' THEN CreatedOn ELSE NULL END) AS [Lost Deal],	
			MAX(CASE WHEN StageName = 'Pre-approved' THEN CreatedOn ELSE NULL END) AS PreApproved,	
			MAX(CASE WHEN StageName = 'Closed Deals' THEN CreatedOn ELSE NULL END) AS [Closed Deals],

				MAX(CASE WHEN Stage_Level =1 THEN CreatedOn ELSE NULL END) AS Stage1_Date,
				MAX(CASE WHEN Stage_Level =2 THEN CreatedOn ELSE NULL END) AS Stage2_Date,
				MAX(CASE WHEN Stage_Level =3 THEN CreatedOn ELSE NULL END) AS Stage3_Date,
				MAX(CASE WHEN Stage_Level = 4 THEN CreatedOn ELSE NULL END) AS Stage4_Date,
				MAX(CASE WHEN Stage_Level = 5 THEN CreatedOn ELSE NULL END) AS Stage5_Date,
				MAX(CASE WHEN Stage_Level = 6 THEN CreatedOn ELSE NULL END) AS Stage6_Date,
				MAX(CASE WHEN Stage_Level = 7 THEN CreatedOn ELSE NULL END) AS Stage7_Date,
				MAX(CASE WHEN Stage_Level = 8 THEN CreatedOn ELSE NULL END) AS Stage8_Date,
				MAX(CASE WHEN Stage_Level = 9 THEN CreatedOn ELSE NULL END) AS Stage9_Date,
				MAX(CASE WHEN Stage_Level = 10 THEN CreatedOn ELSE NULL END) AS Stage10_Date,
				1 AS Flag
				FROM [dbo].[NEW_JDF_BI_Vw_Stage]
				GROUP BY SeenClientAnswerMasterId
			) Stage ON Stage.SeenClientAnswerMasterId = SAM.Id
			WHERE F.EstablishmentGroupId < 0
			AND U.Id NOT IN (363,54)
		) S
		PIVOT (
			MAX(Detail)
			FOR  QuestionTitle IN (
				[Deposit Amount (This must be the amount)],
				[Estimated Equipment Delivery Date],
				[Maatskappy Naam],
				[Quote Price],
				[Selfoon Nommer],
				[Comments],
				[Van],
				[E-Pos Adres],
				[Follow Up Date],
				[Model],
				[Naam]
			)
		) P
	) XX

UNION ALL 

	SELECT EstablishmentGroup_Id,SeenClientAnswerMasterId,CompanyId,
	[PostDate],	[CompanyName],EstablishmentGroupName,SalesPerson,BDO,[Establishment Name],
	[Name],	[Surname],	[Cell],[Email],	[Company],
	[(1 = Swak ; 5 = Uitstekend)],[As ander, besryf asseblief],	[Comments (No Confidential Information)],
	[Enige mededingende kwotasies?],[Preferred financial solution?],[Prys],
	[Total Quote Amount],[Wat was die uiteinde van u besoek?],[Watter produkte was bespreek?],
	[Quote Price],[Deposit Amount (This must be the amount)],[Estimated Equipment Delivery Date],
	[Follow Up Date],[Model],[Comments],
	[Quote],[InformationCollection],AtAnalyst,[Approved],[ExtraInfo],ContractRequired,[Disbursement],[Lost Deal],PreApproved,[Closed Deals],
Stage1_Date,Stage2_Date,Stage3_Date,Stage4_Date,Stage5_Date,Stage6_Date,Stage7_Date,Stage8_Date,Stage9_Date,Stage10_Date,
Stage_1st_Days,Stage_2nd_Days,Stage_3rd_Days,Stage_4rd_Days,Stage_5th_Days,Stage_6th_Days,Stage_7th_Days,Stage_8th_Days,Stage_9th_Days,Stage_10th_Days,
IsNull(Stage_1st_Days,0)+ IsNull(Stage_2nd_Days,0) + IsNull(Stage_3rd_Days,0) + IsNull(Stage_4rd_Days,0) + 
IsNull(Stage_5th_Days,0) + IsNull(Stage_6th_Days,0) + IsNull(Stage_7th_Days,0) + IsNull(Stage_8th_Days,0) +IsNull(Stage_9th_Days,0)+IsNull(Stage_10th_Days,0) as Stage_TotalDays,
Flag
	FROM (
		SELECT EstablishmentGroup_Id,SeenClientAnswerMasterId,CompanyId,
		[PostDate],
		[CompanyName],EstablishmentGroupName,SalesPerson,BDO,[Establishment Name],
		[Name],
		[Surname],
		Cell,
		[Email],
		[Company],
		NULL AS [(1 = Swak ; 5 = Uitstekend)],
		NULL AS [As ander, besryf asseblief],
		NULL AS [Comments (No Confidential Information)],
		NULL AS [Enige mededingende kwotasies?],
		NULL AS [Preferred financial solution?],
		NULL AS [Prys],
		NULL AS [Total Quote Amount],
		NULL AS [Wat was die uiteinde van u besoek?],
		NULL AS [Watter produkte was bespreek?],
		[Quote Price],
		LEFT(SUBSTRING([Deposit Amount (This must be the amount)], PATINDEX('%[0-9.-]%', [Deposit Amount (This must be the amount)]), 8000),
					PATINDEX('%[^0-9.-]%', SUBSTRING([Deposit Amount (This must be the amount)], PATINDEX('%[0-9.-]%', [Deposit Amount (This must be the amount)]), 8000) + 'X') -1)
		AS [Deposit Amount (This must be the amount)],
		[Estimated Equipment Delivery Date],
		[Follow Up Date],
		[Model],
		[Comments],
		[Quote],[InformationCollection],AtAnalyst,[Approved],[ExtraInfo],ContractRequired,[Disbursement],[Lost Deal],PreApproved,[Closed Deals],
	Stage1_Date,Stage2_Date,Stage3_Date,Stage4_Date,Stage5_Date,Stage6_Date,Stage7_Date,Stage8_Date,Stage9_Date,Stage10_Date,
	DATEDIFF(DAY,[PostDate],Stage1_Date) + 1 AS Stage_1st_Days,
	DATEDIFF(DAY,COALESCE(Stage1_Date,[PostDate]),[InformationCollection]) + 1 AS Stage_2nd_Days,
	DATEDIFF(DAY,COALESCE(Stage2_Date,Stage1_Date,[PostDate]),AtAnalyst) + 1 AS Stage_3rd_Days,
	DATEDIFF(DAY,COALESCE(Stage3_Date,Stage2_Date,Stage1_Date,[PostDate]),[Approved]) + 1 AS Stage_4rd_Days,
	DATEDIFF(DAY,COALESCE(Stage4_Date,Stage3_Date,Stage2_Date,Stage1_Date,[PostDate]),ExtraInfo) + 1 AS Stage_5th_Days,
	DATEDIFF(DAY,COALESCE(Stage5_Date,Stage4_Date,Stage3_Date,Stage2_Date,Stage1_Date,[PostDate]),ContractRequired) + 1 AS Stage_6th_Days,
	DATEDIFF(DAY,COALESCE(Stage6_Date,Stage5_Date,Stage4_Date,Stage3_Date,Stage2_Date,Stage1_Date,[PostDate]),[Disbursement]) + 1 AS Stage_7th_Days,
	DATEDIFF(DAY,COALESCE(Stage7_Date,Stage6_Date,Stage5_Date,Stage4_Date,Stage3_Date,Stage2_Date,Stage1_Date,[PostDate]),[Lost Deal]) + 1 AS Stage_8th_Days,
	DATEDIFF(DAY,COALESCE(Stage8_Date,Stage7_Date,Stage6_Date,Stage5_Date,Stage4_Date,Stage3_Date,Stage2_Date,Stage1_Date,[PostDate]),PreApproved) + 1 AS Stage_9th_Days,
	DATEDIFF(DAY,COALESCE(stage9_Date,Stage8_Date,Stage7_Date,Stage6_Date,Stage5_Date,Stage4_Date,Stage3_Date,Stage2_Date,Stage1_Date,[PostDate]),[Closed Deals]) + 1 AS Stage_10th_Days,
	Flag FROM (
			SELECT
			DATEADD(mi,SAM.TimeOffSet,SAM.CreatedOn) AS [PostDate],
			F.Id AS SeenClientAnswerMasterId,Q.QuestionTitle,SA.Detail ,G.Id AS CompanyId,
			G.GroupName AS [CompanyName],F.EstablishmentGroupId AS EstablishmentGroup_Id,
			REPLACE(REPLACE(REPLACE(EG.EstablishmentGroupName,'01',''),'02',''),'03','') AS EstablishmentGroupName,
			E.EstablishmentName as SalesPerson,ISNULL(U.Name,'UNDEFINED') AS BDO,UPPER(ISNULL(EstablishmentName,'UNDEFINED')) AS [Establishment Name],
			[Quote],[InformationCollection],AtAnalyst,Approved,ExtraInfo,ContractRequired,Disbursement,[Lost Deal],PreApproved,[Closed Deals],
			Stage1_Date,Stage2_Date,Stage3_Date,Stage4_Date,Stage5_Date,Stage6_Date,Stage7_Date,Stage8_Date,Stage9_Date,Stage10_Date,Flag
			FROM JDF_BI_Vw_FACT_Magnitude F
			INNER JOIN dbo.SeenClientAnswerMaster AS SAM ON F.Scam_Id = SAM.Id
			INNER JOIN SeenClientQuestions Q ON SAM.SeenClientId = Q.SeenClientId  AND ISNULL(Q.IsDeleted,0) = 0
			INNER JOIN dbo.SeenClientAnswers AS SA ON SA.SeenClientAnswerMasterId = SAM.Id AND SA.QuestionId = Q.Id AND ISNULL(SA.IsDeleted,0) = 0  
			INNER JOIN dbo.Establishment E ON E.Id = SAM.EstablishmentId AND E.EstablishmentGroupId in(2667,2729,2727,2731,2733)
			INNER JOIN dbo.EstablishmentGroup EG ON E.EstablishmentGroupId = EG.Id AND E.IsDeleted = 0
			INNER JOIN dbo.[group] G ON G.Id = EG.GroupId AND EG.IsDeleted = 0
			INNER JOIN dbo.AppUser U ON U.Id = SAM.AppUserId AND U.IsDeleted = 0
			LEFT JOIN 
			(
				SELECT SeenClientAnswerMasterId,
				MAX(CASE WHEN StageName = 'Quote' THEN CreatedOn ELSE NULL END) AS Quote,
			MAX(CASE WHEN StageName = 'Information Collection' THEN CreatedOn ELSE NULL END) AS InformationCollection,
			MAX(CASE WHEN StageName = 'At Analyst' THEN CreatedOn ELSE NULL END) AS AtAnalyst,
			MAX(CASE WHEN StageName = 'Approved' THEN CreatedOn ELSE NULL END) AS Approved,
			MAX(CASE WHEN StageName = 'Extra Information' THEN CreatedOn ELSE NULL END) AS ExtraInfo,
			MAX(CASE WHEN StageName = 'Contract Requested' THEN CreatedOn ELSE NULL END) AS ContractRequired,
			MAX(CASE WHEN StageName = 'Disbursement' THEN CreatedOn ELSE NULL END) AS Disbursement,

			MAX(CASE WHEN StageName = 'Lost Deal' THEN CreatedOn ELSE NULL END) AS [Lost Deal],	
			MAX(CASE WHEN StageName = 'Pre-approved' THEN CreatedOn ELSE NULL END) AS PreApproved,	
			MAX(CASE WHEN StageName = 'Closed Deals' THEN CreatedOn ELSE NULL END) AS [Closed Deals],
				MAX(CASE WHEN Stage_Level =1 THEN CreatedOn ELSE NULL END) AS Stage1_Date,
				MAX(CASE WHEN Stage_Level =2 THEN CreatedOn ELSE NULL END) AS Stage2_Date,
				MAX(CASE WHEN Stage_Level =3 THEN CreatedOn ELSE NULL END) AS Stage3_Date,
				MAX(CASE WHEN Stage_Level = 4 THEN CreatedOn ELSE NULL END) AS Stage4_Date,
				MAX(CASE WHEN Stage_Level = 5 THEN CreatedOn ELSE NULL END) AS Stage5_Date,
				MAX(CASE WHEN Stage_Level = 6 THEN CreatedOn ELSE NULL END) AS Stage6_Date,
				MAX(CASE WHEN Stage_Level = 7 THEN CreatedOn ELSE NULL END) AS Stage7_Date,
				MAX(CASE WHEN Stage_Level = 8 THEN CreatedOn ELSE NULL END) AS Stage8_Date,
				MAX(CASE WHEN Stage_Level = 9 THEN CreatedOn ELSE NULL END) AS Stage9_Date,
				MAX(CASE WHEN Stage_Level = 10 THEN CreatedOn ELSE NULL END) AS Stage10_Date,
				1 AS Flag
				FROM [dbo].[NEW_JDF_BI_Vw_Stage]
				GROUP BY SeenClientAnswerMasterId
			) Stage ON Stage.SeenClientAnswerMasterId = SAM.Id
			WHERE F.EstablishmentGroupId < 0
			AND U.Id NOT IN (363,54)
		) S
		PIVOT (
			MAX(Detail)
			FOR  QuestionTitle IN (
				[Deposit Amount (This must be the amount)],
				[Estimated Equipment Delivery Date],
				[Company],
				[Quote Price],
				[Cell],
				[Comments],
				[Surname],
				[Email],
				[Follow Up Date],
				[Model],
				[Name]
			)
		) P
	) X3





) Z
LEFT OUTER JOIN [dbo].[Establishment_Town]  ET ON ET.[Town Name] = LTRIM(SUBSTRING(LTRIM(Z.[Establishment Name]),(LEN(LTRIM(Z.[Establishment Name])) - LEN(LTRIM(ET.[Town Name]))+1),LEN(LTRIM(ET.[Town Name]))))

)Main

left outer join

BI_Vw_DimChats Chats on Main.seenclientanswermasterid =Chats.SeenClientAnswerMasterId




