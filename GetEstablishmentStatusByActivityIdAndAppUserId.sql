
CREATE PROCEDURE [dbo].[GetEstablishmentStatusByActivityIdAndAppUserId]
    @ActivityId BIGINT,
	@AppUserId BIGINT
AS
   BEGIN
   SET NOCOUNT ON;
		SET DEADLOCK_PRIORITY NORMAL;
	
		BEGIN TRY
		SELECT ES.Id AS StatusId, ES.StatusName, ES.EstablishmentId, SI.IconPath AS StatusImage
		FROM dbo.EstablishmentStatus AS ES
		INNER JOIN dbo.StatusIconImage AS SI ON SI.Id = ES.StatusIconImageId
		INNER JOIN dbo.Establishment AS E ON E.Id = ES.EstablishmentId
		INNER JOIN dbo.AppUserEstablishment AS AE ON AE.EstablishmentId = E.Id AND AE.AppUserId = @AppUserId AND AE.IsDeleted = 0
		WHERE E.EstablishmentGroupId = @ActivityId AND ES.IsDeleted = 0
		ORDER BY AE.EstablishmentId, ES.Id
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
         'dbo.GetEstablishmentStatusByActivityIdAndAppUserId',
         N'DATABASE',
         ERROR_MESSAGE(),
         ('ERROR_NUMBER=' + CONVERT(VARCHAR(100), ERROR_NUMBER()) + ',ERROR_STATE='
          + CONVERT(VARCHAR(20), ERROR_STATE()) + ',ERROR_SEVERITY=' + CONVERT(VARCHAR(20), ERROR_SEVERITY())
         )  ,
         GETUTCDATE(),
         ISNULL(@AppUserId,0),
         @ActivityId+','+@AppUserId,
         GETUTCDATE(),
         ISNULL(@AppUserId,0)
        );
END CATCH
   SET NOCOUNT OFF;
   END;
