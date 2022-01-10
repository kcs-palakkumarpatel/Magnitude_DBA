-- =============================================
-- Author:		<Author,,GD>
-- Create date: <Create Date,, Jun 2015>
-- Description:	<Description,,>
-- Call SP:		WSGetActionTemplateByActivityId 1
-- =============================================
CREATE PROCEDURE [dbo].[WSGetActionTemplateByActivityId] @ActivityId BIGINT
AS 
    BEGIN
	SET DEADLOCK_PRIORITY NORMAL;
	
	BEGIN TRY
        SELECT  Id ,
                TemplateText
        FROM    dbo.CloseLoopTemplate
        WHERE   EstablishmentGroupId = @ActivityId
                AND IsDeleted = 0
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
         'dbo.WSGetActionTemplateByActivityId',
         N'DATABASE',
         ERROR_MESSAGE(),
         ('ERROR_NUMBER=' + CONVERT(VARCHAR(100), ERROR_NUMBER()) + ',ERROR_STATE='
          + CONVERT(VARCHAR(20), ERROR_STATE()) + ',ERROR_SEVERITY=' + CONVERT(VARCHAR(20), ERROR_SEVERITY())
         )  ,
         GETUTCDATE(),
         ISNULL(@ActivityId,0),
         @ActivityId,
         GETUTCDATE(),
         N''
        );
END CATCH
    END