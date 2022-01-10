--GetStatusHistoryById 975746
CREATE PROCEDURE dbo.GetStatusHistoryById
	@Id BIGINT -- ReferenceNo
AS
SET NOCOUNT ON

SELECT
    SH.Id,
	ES.StatusName AS StatusName,
	SSI.IconPath AS StatusImage,
	[ReferenceNo], 
	[EstablishmentStatusId],
	[UserId],
	AU.Name,
	AU.Mobile,
	EG.EstablishmentGroupName,	
	[IsOut], 
	CAST(CASE WHEN (Latitude IS NULL OR Latitude = '') THEN  ROUND(CAST(0.00 AS DECIMAL(10,3)), 3)  ELSE ROUND(CAST(Latitude AS DECIMAL(10,3)), 3)  END AS VARCHAR) AS Latitude,
CAST(CASE WHEN (Longitude IS NULL OR Longitude = '') THEN  ROUND(CAST(0.00 AS DECIMAL(10,3)), 3)  ELSE ROUND(CAST(Longitude AS DECIMAL(10,3)), 3)  END AS VARCHAR) AS Longitude,
	Format(cast(SH.StatusDateTime as datetime),'dd/MMM/yy HH:mm','en-us') AS StatusDateTime
FROM StatusHistory AS SH INNER JOIN dbo.AppUser  AS AU ON AU.Id = SH.UserId
INNER JOIN dbo.EstablishmentStatus AS ES ON ES.Id = SH.EstablishmentStatusId
INNER JOIN dbo.StatusIconImage AS SSI ON SSI.Id = ES.StatusIconImageId
INNER JOIN Establishment E ON E.Id = ES.EstablishmentId
INNER JOIN dbo.EstablishmentGroup EG ON EG.Id = E.EstablishmentGroupId
WHERE [ReferenceNo] = @Id
 AND SH.ISDeleted = 0
 ORDER BY sh.StatusDateTime ASC
SET NOCOUNT OFF
