
-- =============================================
-- Author:		Rushin
-- Create date: 16-12-15
-- Description:	Insert group users in child table "[SeenClientAnswerChild]"
-- Call SP    :	InsertSeenClientAnswerChild
-- =============================================
CREATE PROCEDURE [dbo].[InsertSeenClientAnswerChild]
    @SeenClientAnswerMasterId BIGINT ,
    @ContactMasterId BIGINT
AS
    BEGIN
	SET DEADLOCK_PRIORITY NORMAL;
	
	BEGIN TRY
        INSERT  INTO dbo.SeenClientAnswerChild(
			SeenClientAnswerMasterId
			,ContactMasterId)
		OUTPUT Inserted.Id
        VALUES  ( @SeenClientAnswerMasterId ,
                  @ContactMasterId
                );
        --SELECT  @Id = SCOPE_IDENTITY();
        --SELECT  ISNULL(@Id, 0) AS InsertedId;
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
         'dbo.InsertSeenClientAnswerChild',
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
