
CREATE PROCEDURE [dbo].[WSGetHeaderSetting_111921]
    -- Add the parameters for the stored procedure here
    @GroupId BIGINT,
    @LastServerDate DATETIME,
	@AppUserId BIGINT
AS
BEGIN

    SELECT DISTINCT
        WA.Id AS HeaderId,
        HeaderName AS HeaderName,
        HeaderValue AS HeaderDisplayName,
        HS.EstablishmentGroupId AS ActivityId
    FROM dbo.WebAppHeaders AS WA
        LEFT JOIN dbo.HeaderSetting AS HS
            ON HS.HeaderName = WA.LabelName
		LEFT JOIN dbo.Establishment AS E WITH(NOLOCK) ON E.EstablishmentGroupId = HS.EstablishmentGroupId
		LEFT JOIN dbo.AppUserEstablishment AS AUE WITH(NOLOCK) ON AUE.EstablishmentId = E.Id
    WHERE HS.GroupId = @GroupId AND AUE.AppUserId = @AppUserId
          AND (
                  ISNULL(HS.UpdatedOn, HS.CreatedOn) >= @LastServerDate
                  OR @LastServerDate IS NULL
              )
		  AND Hs.IsDeleted = 0 AND E.IsDeleted = 0 AND AUE.IsDeleted = 0
    ORDER BY HS.EstablishmentGroupId;
END;
