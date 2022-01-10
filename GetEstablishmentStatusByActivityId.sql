
--EXEC GetEstablishmentStatusByActivityId 1941,'1970-01-01'
CREATE PROCEDURE [dbo].[GetEstablishmentStatusByActivityId] 
	@ActivityId BIGINT,
	@LastDate DATETIME
AS
SET NOCOUNT ON;
	SET DEADLOCK_PRIORITY NORMAL;
	
	BEGIN TRY
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
         'dbo.GetEstablishmentStatusByActivityId',
         N'DATABASE',
         ERROR_MESSAGE(),
         ('ERROR_NUMBER=' + CONVERT(VARCHAR(100), ERROR_NUMBER()) + ',ERROR_STATE='
          + CONVERT(VARCHAR(20), ERROR_STATE()) + ',ERROR_SEVERITY=' + CONVERT(VARCHAR(20), ERROR_SEVERITY())
         )  ,
         GETUTCDATE(),
         N'',
         @ActivityId+','+@LastDate,
         GETUTCDATE(),
         N''
        );
END CATCH
SET NOCOUNT OFF;
