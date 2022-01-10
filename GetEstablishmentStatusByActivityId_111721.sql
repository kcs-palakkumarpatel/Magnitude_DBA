
--EXEC GetEstablishmentStatusByActivityId 1941,'1970-01-01'
CREATE PROCEDURE [dbo].[GetEstablishmentStatusByActivityId_111721] 
	@ActivityId BIGINT,
	@LastDate DATETIME
AS
SET NOCOUNT ON;

SELECT ES.[Id] AS StatusId,
       [EstablishmentId],
       ES.StatusName AS StatusName,
       SSI.IconPath AS StatusImage,
       [DefaultStartStatus],
       [DefaultEndStatus],
       [IsActive],
	   0 AS CurrentStatusId
FROM EstablishmentStatus AS ES
    INNER JOIN dbo.Establishment AS E
        ON E.Id = ES.EstablishmentId
	INNER JOIN dbo.StatusIconImage AS SSI ON SSI.Id = ES.StatusIconImageId
WHERE E.EstablishmentGroupId = @ActivityId
      AND ES.IsDeleted = 0
	  AND ISNULL(ES.UpdatedOn, ES.CreatedOn) > @LastDate
	  ORDER BY ES.Id ASC;
SET NOCOUNT OFF;
