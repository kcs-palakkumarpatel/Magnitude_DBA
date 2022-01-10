




  
CREATE VIEW [dbo].[JDF_BI_Vw_Establishment_Group]  
AS  
  /*
  
SELECT X.[Establishment Group Id],  
(Case when X.[Establishment Group Name] = 'JOHN DEERE FINANCIAL' Then 'JDF' Else [Establishment Group Name] End) as [Establishment Group Name],
X.[Establishment Group Type],
(CASE WHEN [Establishment Group Name]  LIKE '%SALES%' THEN '            SALES CALL'  
	  WHEN [Establishment Group Name]  LIKE '%JDF%' or [Establishment Group Name]  LIKE '%JOHN DEERE FINANCIAL%' THEN '       JDF'  
END) AS [Group Name],  
  
(CASE WHEN [Establishment Group Name]  LIKE '%SALES%' THEN 1 ELSE 2 END)  [Sort Id]  
  
FROM (  
 SELECT EG.Id AS [Establishment Group Id],  
 ISNULL(UPPER(LTRIM(RTRIM(SUBSTRING(EG.EstablishmentGroupName, PATINDEX('%[^0-9]%',EG.EstablishmentGroupName), 100)))),'UNDEFINED') AS [Establishment Group Name],  
 ISNULL(UPPER(EG.EstablishmentGroupType),'UNDEFINED') AS [Establishment Group Type]  
 FROM dbo.EstablishmentGroup EG   
 LEFT OUTER JOIN dbo.[Group] G ON G.Id = EG.GroupId  AND G.IsDeleted = 0  
 WHERE EG.Id IN (963,2315,2661,2667,2729,2727,2731,2733)  
 AND EG.IsDeleted = 0   
 AND EG.CreatedBy NOT IN (363,54)  
) X  
UNION ALL  
SELECT -100 AS [Establishment Group Id], 'QUOTE' AS [Establishment Group Name], 'SALES' AS [Establishment Group Type],'      QUOTE' AS [Group Name],3 AS [Sort Id]  
UNION ALL  
SELECT -200 AS [Establishment Group Id], 'INFORMATION COLLECTION' AS [Establishment Group Name], 'SALES' AS [Establishment Group Type],'     INFORMATION COLLECTION' AS [Group Name],4 AS [Sort Id]  
UNION ALL  
SELECT -300 AS [Establishment Group Id], 'AT CREDIT' AS [Establishment Group Name], 'SALES' AS [Establishment Group Type],'    AT CREDIT' AS [Group Name],5 AS [Sort Id]  
UNION ALL  
SELECT -400 AS [Establishment Group Id], 'EXTRA INFORMATION' AS [Establishment Group Name], 'SALES' AS [Establishment Group Type],'    EXTRA INFORMATION' AS [Group Name],6 AS [Sort Id]  
UNION ALL  
SELECT -500 AS [Establishment Group Id], 'APPROVED' AS [Establishment Group Name], 'SALES' AS [Establishment Group Type],'   APPROVED' AS [Group Name],7 AS [Sort Id]  
UNION ALL  
SELECT -600 AS [Establishment Group Id], 'PRE-APPROVED' AS [Establishment Group Name], 'SALES' AS [Establishment Group Type],'   PRE-APPROVED' AS [Group Name],8 AS [Sort Id]  
UNION ALL  
SELECT -700 AS [Establishment Group Id], 'DISBURSEMENT' AS [Establishment Group Name], 'SALES' AS [Establishment Group Type],'  DISBURSEMENT' AS [Group Name],9 AS [Sort Id]  
UNION ALL
SELECT -800 AS [Establishment Group Id], 'DCP' AS [Establishment Group Name], 'SALES' AS [Establishment Group Type],' DCP' AS [Group Name],10 AS [Sort Id] 

*/
 /*
SELECT X.[Establishment Group Id],  
(Case when X.[Establishment Group Name] = 'JOHN DEERE FINANCIAL' Then 'JDF' Else [Establishment Group Name] End) as [Establishment Group Name],
X.[Establishment Group Type],
(CASE WHEN [Establishment Group Name]  LIKE '%SALES%' THEN '            SALES CALL'  
	  WHEN [Establishment Group Name]  LIKE '%JDF%' or [Establishment Group Name]  LIKE '%JOHN DEERE FINANCIAL%' THEN '       JDF'  
END) AS [Group Name],  
  
(CASE WHEN [Establishment Group Name]  LIKE '%SALES%' THEN 1 ELSE 2 END)  [Sort Id]  
  
FROM (  
 SELECT EG.Id AS [Establishment Group Id],  
 ISNULL(UPPER(LTRIM(RTRIM(SUBSTRING(EG.EstablishmentGroupName, PATINDEX('%[^0-9]%',EG.EstablishmentGroupName), 100)))),'UNDEFINED') AS [Establishment Group Name],  
 ISNULL(UPPER(EG.EstablishmentGroupType),'UNDEFINED') AS [Establishment Group Type]  
 FROM dbo.EstablishmentGroup EG   
 LEFT OUTER JOIN dbo.[Group] G ON G.Id = EG.GroupId  AND G.IsDeleted = 0  
 WHERE EG.Id IN (963,2315,2661,2667,2729,2727,2731,2733)  
 AND EG.IsDeleted = 0   
 AND EG.CreatedBy NOT IN (363,54)  
) X  
UNION ALL  
SELECT -100 AS [Establishment Group Id], 'QUOTE' AS [Establishment Group Name], 'SALES' AS [Establishment Group Type],'      QUOTE' AS [Group Name],3 AS [Sort Id]  
UNION ALL  
SELECT -200 AS [Establishment Group Id], 'INFORMATION COLLECTION' AS [Establishment Group Name], 'SALES' AS [Establishment Group Type],'     INFORMATION COLLECTION' AS [Group Name],4 AS [Sort Id]  
UNION ALL  
SELECT -300 AS [Establishment Group Id], 'AT CREDIT' AS [Establishment Group Name], 'SALES' AS [Establishment Group Type],'    AT CREDIT' AS [Group Name],5 AS [Sort Id]  
UNION ALL  
SELECT -400 AS [Establishment Group Id], 'EXTRA INFORMATION' AS [Establishment Group Name], 'SALES' AS [Establishment Group Type],'    EXTRA INFORMATION' AS [Group Name],6 AS [Sort Id]  
UNION ALL  
SELECT -500 AS [Establishment Group Id], 'APPROVED' AS [Establishment Group Name], 'SALES' AS [Establishment Group Type],'   APPROVED' AS [Group Name],7 AS [Sort Id]  
UNION ALL  
SELECT -600 AS [Establishment Group Id], 'PRE-APPROVED' AS [Establishment Group Name], 'SALES' AS [Establishment Group Type],'   PRE-APPROVED' AS [Group Name],8 AS [Sort Id]  
UNION ALL  
SELECT -700 AS [Establishment Group Id], 'DISBURSEMENT' AS [Establishment Group Name], 'SALES' AS [Establishment Group Type],'  DISBURSEMENT' AS [Group Name],9 AS [Sort Id]  
UNION ALL
SELECT -800 AS [Establishment Group Id], 'DCP' AS [Establishment Group Name], 'SALES' AS [Establishment Group Type],' DCP' AS [Group Name],11 AS [Sort Id] 
UNION ALL
SELECT -900 AS [Establishment Group Id], 'Closed Deals' AS [Establishment Group Name], 'SALES' AS [Establishment Group Type],' Closed Deals' AS [Group Name],10 AS [Sort Id] 

*/
 
SELECT X.[Establishment Group Id],  
(Case when X.[Establishment Group Name] = 'JOHN DEERE FINANCIAL' Then 'JDF' Else [Establishment Group Name] End) as [Establishment Group Name],
X.[Establishment Group Type],
(CASE WHEN [Establishment Group Name]  LIKE '%SALES%' THEN '            SALES CALL'  
	  WHEN [Establishment Group Name]  LIKE '%JDF%' or [Establishment Group Name]  LIKE '%JOHN DEERE FINANCIAL%' THEN '       JDF'  
END) AS [Group Name],  
  
(CASE WHEN [Establishment Group Name]  LIKE '%SALES%' THEN 1 ELSE 2 END)  [Sort Id]  
  
FROM (  
 SELECT EG.Id AS [Establishment Group Id],  
 ISNULL(UPPER(LTRIM(RTRIM(SUBSTRING(EG.EstablishmentGroupName, PATINDEX('%[^0-9]%',EG.EstablishmentGroupName), 100)))),'UNDEFINED') AS [Establishment Group Name],  
 ISNULL(UPPER(EG.EstablishmentGroupType),'UNDEFINED') AS [Establishment Group Type]  
 FROM dbo.EstablishmentGroup EG   
 LEFT OUTER JOIN dbo.[Group] G ON G.Id = EG.GroupId  AND G.IsDeleted = 0  
 WHERE EG.Id IN (963,2315,2661,2667,2729,2727,2731,2733)  
 AND EG.IsDeleted = 0   
 AND EG.CreatedBy NOT IN (363,54)  
) X  
UNION ALL  
SELECT -100 AS [Establishment Group Id], 'QUOTE' AS [Establishment Group Name], 'SALES' AS [Establishment Group Type],'QUOTE' AS [Group Name],3 AS [Sort Id]  
UNION ALL  
SELECT -200 AS [Establishment Group Id], 'INFORMATION COLLECTION' AS [Establishment Group Name], 'SALES' AS [Establishment Group Type],'INFORMATION COLLECTION' AS [Group Name],4 AS [Sort Id]  
UNION ALL  
SELECT -300 AS [Establishment Group Id], 'AT ANALYST' AS [Establishment Group Name], 'SALES' AS [Establishment Group Type],'AT ANALYST' AS [Group Name],5 AS [Sort Id]  
UNION ALL  
SELECT -400 AS [Establishment Group Id], 'APPROVED' AS [Establishment Group Name], 'SALES' AS [Establishment Group Type],'APPROVED' AS [Group Name],6 AS [Sort Id]  
UNION ALL  
SELECT -500 AS [Establishment Group Id], 'EXTRA INFORMATION' AS [Establishment Group Name], 'SALES' AS [Establishment Group Type],'EXTRA INFORMATION' AS [Group Name],7 AS [Sort Id]  
UNION ALL  
SELECT -600 AS [Establishment Group Id], 'CONTRACT REQUESTED' AS [Establishment Group Name], 'SALES' AS [Establishment Group Type],'CONTRACT REQUESTED' AS [Group Name],8 AS [Sort Id]  
UNION ALL  
SELECT -700 AS [Establishment Group Id], 'DISBURSEMENT' AS [Establishment Group Name], 'SALES' AS [Establishment Group Type],'DISBURSEMENT' AS [Group Name],9 AS [Sort Id]  
UNION ALL
SELECT -800 AS [Establishment Group Id], 'LOST DEAL' AS [Establishment Group Name], 'SALES' AS [Establishment Group Type],'LOST DEAL' AS [Group Name],10 AS [Sort Id] 
UNION ALL
SELECT -900 AS [Establishment Group Id], 'PRE-APPROVED' AS [Establishment Group Name], 'SALES' AS [Establishment Group Type],'PRE-APPROVED' AS [Group Name],11 AS [Sort Id] 
UNION ALL
SELECT -1000 AS [Establishment Group Id], 'CLOSED DEALS' AS [Establishment Group Name], 'SALES' AS [Establishment Group Type],'CLOSED DEALS' AS [Group Name],12 AS [Sort Id] 


