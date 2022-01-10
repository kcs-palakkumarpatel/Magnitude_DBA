--Sp call  GetTaskEstablishmentStatusByEstablishmentId 33530
CREATE PROCEDURE dbo.GetTaskEstablishmentStatusByEstablishmentId @EstablishmentId NVARCHAR(MAX)
AS
SET NOCOUNT ON;

SELECT [Id],
       [EstablishmentId],
       [StatusName],
       [StatusIconImageId],
       [DefaultStartStatus],
       [DefaultEndStatus],
       [IsActive]
FROM dbo.EstablishmentStatus
WHERE EstablishmentId IN (
                             SELECT Data FROM dbo.Split(@EstablishmentId, ',')
                         )
      AND IsDeleted = 0 ORDER BY Id ASC
	  
SET NOCOUNT OFF;
