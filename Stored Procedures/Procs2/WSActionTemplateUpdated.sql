
-- =============================================
-- Author:		<Author,,GD>
-- Create date: <Create Date,,04 Jul 2015>
-- Description:	<Description,,>
-- Call SP:		WSActionTemplateUpdated_111921 1, '01 Jan 2015'
-- =============================================
CREATE PROCEDURE [dbo].[WSActionTemplateUpdated]
    @ActivityId BIGINT ,
    @LastDate DATETIME
AS 
    BEGIN
	SET DEADLOCK_PRIORITY NORMAL;
	
	BEGIN TRY
        SELECT  COUNT(1) AS UpdatedCount, GETUTCDATE() AS ServerDate
        FROM    dbo.CloseLoopTemplate
        WHERE   EstablishmentGroupId = @ActivityId
                AND ISNULL(UpdatedOn, CreatedOn) > @LastDate
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
         'dbo.WSActionTemplateUpdated',
         N'DATABASE',
         ERROR_MESSAGE(),
         ('ERROR_NUMBER=' + CONVERT(VARCHAR(100), ERROR_NUMBER()) + ',ERROR_STATE='
          + CONVERT(VARCHAR(20), ERROR_STATE()) + ',ERROR_SEVERITY=' + CONVERT(VARCHAR(20), ERROR_SEVERITY())
         )  ,
         GETUTCDATE(),
         N'',
        @ActivityId,
	    GETUTCDATE(),
         N''
        );
END CATCH
    END
