
CREATE PROCEDURE [dbo].[GetEstablishmentStatusByActivityIdAndAppUserId_111721]
    @ActivityId BIGINT,
	@AppUserId BIGINT
AS
   BEGIN
   SET NOCOUNT ON;
		
		SELECT ES.Id AS StatusId, ES.StatusName, ES.EstablishmentId, SI.IconPath AS StatusImage
		FROM dbo.EstablishmentStatus AS ES
		INNER JOIN dbo.StatusIconImage AS SI ON SI.Id = ES.StatusIconImageId
		INNER JOIN dbo.Establishment AS E ON E.Id = ES.EstablishmentId
		INNER JOIN dbo.AppUserEstablishment AS AE ON AE.EstablishmentId = E.Id AND AE.AppUserId = @AppUserId AND AE.IsDeleted = 0
		WHERE E.EstablishmentGroupId = @ActivityId AND ES.IsDeleted = 0
		ORDER BY AE.EstablishmentId, ES.Id

   SET NOCOUNT OFF;
   END;
