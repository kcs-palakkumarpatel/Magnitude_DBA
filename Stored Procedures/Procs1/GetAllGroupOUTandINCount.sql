-- GetAllGroupOUTandINCount '01 Aug 2017','31 Aug 2017'
CREATE PROCEDURE dbo.GetAllGroupOUTandINCount
@FromDate DATETIME,
@ToDate DATETIME
AS
BEGIN
WITH cte_name AS
     (
SELECT  G.GroupName AS [Group],
        EG.EstablishmentGroupName [Activity],
        COUNT(AM.Id) AS [OUT],
		0 AS [IN]
FROM    dbo.SeenClientAnswerMaster AM
        INNER JOIN dbo.Establishment E ON AM.EstablishmentId = E.Id
        INNER JOIN dbo.EstablishmentGroup EG ON EG.Id = E.EstablishmentGroupId
        INNER JOIN dbo.[Group] AS G ON G.Id = E.GroupId
WHERE   --G.Id = 201 AND 
		AM.IsDeleted = 0
		AND AM.CreatedOn BETWEEN @FromDate AND @ToDate
GROUP BY G.GroupName ,
        EG.EstablishmentGroupName
UNION ALL
SELECT  G.GroupName ,
        EG.EstablishmentGroupName ,
		0 AS [OUT Count],
        COUNT(AM.Id) AS [IN Count]
FROM    dbo.AnswerMaster AM
        INNER JOIN dbo.Establishment E ON AM.EstablishmentId = E.Id
        INNER JOIN dbo.EstablishmentGroup EG ON EG.Id = E.EstablishmentGroupId
        INNER JOIN dbo.[Group] AS G ON G.Id = E.GroupId
WHERE   --G.Id = 201 AND 
		AM.IsDeleted = 0
		AND AM.CreatedOn BETWEEN @FromDate AND @ToDate
GROUP BY G.GroupName ,
        EG.EstablishmentGroupName
--UNION ALL
--SELECT  G.GroupName ,
--        EG.EstablishmentGroupName ,
--        0 ,
--        0
--FROM    dbo.Establishment AS E
--        INNER JOIN dbo.EstablishmentGroup AS EG ON EG.Id = E.EstablishmentGroupId
--        INNER JOIN dbo.[Group] AS G ON G.Id = E.GroupId
--WHERE   ( E.Id NOT IN (
--          SELECT    EstablishmentId
--          FROM      dbo.SeenClientAnswerMaster
--          WHERE     IsDeleted = 0
--                    AND CreatedOn BETWEEN @FromDate AND @ToDate )
--          AND ( E.Id NOT IN (
--                SELECT  EstablishmentId
--                FROM    dbo.AnswerMaster
--                WHERE   IsDeleted = 0
--                        AND CreatedOn BETWEEN @FromDate AND @ToDate ) )
--        )
--        AND E.IsDeleted = 0 
		) SELECT cte_name.[Group],cte_name.Activity,SUM(cte_name.[OUT]) AS [OUT],SUM(cte_name.[IN]) AS [IN] FROM cte_name 
		GROUP BY cte_name.[Group],cte_name.Activity ORDER BY cte_name.[Group]
END
