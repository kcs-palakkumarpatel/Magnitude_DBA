
-- =============================================
-- Author:		Matthew Grinaker
-- Create date: 2020/05/18
-- Description:	WSGetInitiatorAsDirectRespondentByEstablishmentId 2301
-- =============================================

CREATE PROCEDURE [dbo].[WSGetInitiatorAsDirectRespondentByEstablishmentId] @EstablishmentId BIGINT
AS
BEGIN
    SET NOCOUNT ON;
	SET DEADLOCK_PRIORITY NORMAL;
	
	BEGIN TRY
    SELECT ISNULL((SELECT ISNULL(InitiatorAsRespondent, 0) AS InitiatorAsDirectRespondent
    FROM dbo.Establishment WITH
        (NOLOCK)
    WHERE Id = @EstablishmentId), 0) AS InitiatorAsDirectRespondent;
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
         'dbo.WSGetInitiatorAsDirectRespondentByEstablishmentId',
         N'DATABASE',
         ERROR_MESSAGE(),
         ('ERROR_NUMBER=' + CONVERT(VARCHAR(100), ERROR_NUMBER()) + ',ERROR_STATE='
          + CONVERT(VARCHAR(20), ERROR_STATE()) + ',ERROR_SEVERITY=' + CONVERT(VARCHAR(20), ERROR_SEVERITY())
         )  ,
         GETUTCDATE(),
         ISNULL(@EstablishmentId,0),
         @EstablishmentId,
         GETUTCDATE(),
         N''
        );
END CATCH
SET NOCOUNT OFF;
END;
