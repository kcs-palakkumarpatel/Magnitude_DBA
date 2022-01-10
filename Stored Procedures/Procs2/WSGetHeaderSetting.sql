
CREATE PROCEDURE [dbo].[WSGetHeaderSetting]
    -- Add the parameters for the stored procedure here
    @GroupId BIGINT,
    @LastServerDate DATETIME,
	@AppUserId BIGINT
AS
BEGIN
	SET DEADLOCK_PRIORITY NORMAL;
	
	BEGIN TRY
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
	END TRY

BEGIN CATCH
	INSERT INTO dbo.ErrorLog
        (
            PageId,
            MethodName,
            ErrorType,
            ErrorMessage,
            ErrorDetails,
            ErrorDate,
            UserId,
            Solution,
            CreatedOn,
            CreatedBy
        )
        VALUES
        (ERROR_LINE(),
         'dbo.WSGetHeaderSetting',
         N'DATABASE',
         ERROR_MESSAGE(),
         ('ERROR_NUMBER=' + CONVERT(VARCHAR(100), ERROR_NUMBER()) + ',ERROR_STATE='
          + CONVERT(VARCHAR(20), ERROR_STATE()) + ',ERROR_SEVERITY=' + CONVERT(VARCHAR(20), ERROR_SEVERITY())
         )  ,
         GETUTCDATE(),
         ISNULL(@AppUserId,0),
         @GroupId+','+@LastServerDate+','+@AppUserId,
         GETUTCDATE(),
         ISNULL(@AppUserId,0)
        );
END CATCH
END;
