
-- =============================================
-- Author:		Sunil Vaghasiya
-- Create date: 06-Jan-2017
-- Description:	Update group users in child table "[SeenClientAnswerChild]"
-- Call SP    :		dbo.UpdateSeenClientAnswerChild 256122,399
-- =============================================
CREATE PROCEDURE [dbo].[UpdateSeenClientAnswerChild]
    @SeenClientAnswerMasterId BIGINT,
    @ContactMasterId BIGINT
AS
BEGIN
	SET DEADLOCK_PRIORITY NORMAL;
	
	BEGIN TRY
    DECLARE @Id BIGINT = 0;
    SELECT @Id = Id
    FROM dbo.SeenClientAnswerChild WITH
        (NOLOCK)
    WHERE SeenClientAnswerMasterId = @SeenClientAnswerMasterId
          AND ContactMasterId = @ContactMasterId;
    IF NOT EXISTS
    (
        SELECT Id
        FROM dbo.SeenClientAnswerChild WITH
            (NOLOCK)
        WHERE SeenClientAnswerMasterId = @SeenClientAnswerMasterId
              AND ContactMasterId = @ContactMasterId
    )
    BEGIN
        PRINT 1;
        INSERT INTO dbo.SeenClientAnswerChild
        (
            SeenClientAnswerMasterId,
            ContactMasterId
        )
        VALUES
        (@SeenClientAnswerMasterId, @ContactMasterId);
        SELECT @Id = Id
        FROM dbo.SeenClientAnswerChild WITH
            (NOLOCK)
        WHERE SeenClientAnswerMasterId = @SeenClientAnswerMasterId
              AND ContactMasterId = @ContactMasterId;
    END;
    ELSE
    BEGIN
        UPDATE dbo.SeenClientAnswerChild
        SET SeenClientAnswerMasterId = @SeenClientAnswerMasterId,
            ContactMasterId = @ContactMasterId
        WHERE Id = @Id;
    END;
    SELECT ISNULL(@Id, 0) AS UpdateId;
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
         'dbo.UpdateSeenClientAnswerChild',
         N'DATABASE',
         ERROR_MESSAGE(),
         ('ERROR_NUMBER=' + CONVERT(VARCHAR(100), ERROR_NUMBER()) + ',ERROR_STATE='
          + CONVERT(VARCHAR(20), ERROR_STATE()) + ',ERROR_SEVERITY=' + CONVERT(VARCHAR(20), ERROR_SEVERITY())
         )  ,
         GETUTCDATE(),
         N'',
        @SeenClientAnswerMasterId+','+@ContactMasterId,
	    GETUTCDATE(),
         N''
        );
END CATCH
END;
