

-- =============================================
-- Author:		<Vasudev Patel>
-- Create date: <28 Mar 2017>
-- Description:	<Mobi link>
-- Call: GetMobilinkForm 73256,313
-- =============================================
CREATE PROCEDURE [dbo].[GetMobilinkForm] 
	-- Add the parameters for the stored procedure here
	@ReportedId BIGINT,
	@AppuserId BIGINT
AS
BEGIN
	
	SET DEADLOCK_PRIORITY NORMAL;
	
	BEGIN TRY
--DECLARE @Url VARCHAR(50)
--SELECT  @url = KeyValue FROM  dbo.AAAAConfigSettings WHERE KeyName = 'FeedbackUrl'

SELECT CASE ISNULL(am.IsSubmittedForGroup,0) WHEN 0 THEN dbo.GetMObilink(@ReportedId,@AppuserId,0) ELSE dbo.GetMObilink(@ReportedId,@AppuserId,1) END AS MobiLink
FROM dbo.SeenClientAnswerMaster am WHERE id = @ReportedId

--SELECT CASE WHEN Am.ContactGroupId != 0 THEN ''
--             ELSE ( CASE WHEN ( SELECT  COUNT(1)
--                                FROM    dbo.ContactDetails AS c
--                                        INNER JOIN dbo.AppUser AS App ON c.Detail = App.Email
--                                WHERE   c.ContactMasterId = Am.ContactMasterId
--                                        AND QuestionTypeId = 10
--                                        AND App.Id = @AppuserId
--                              ) > 0 THEN @Url
--                         ELSE ''
--                    END )
--        END AS MobiLink
--FROM dbo.SeenClientAnswerMaster am WHERE id = @ReportedId
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
         'dbo.GetMobilinkForm',
         N'DATABASE',
         ERROR_MESSAGE(),
         ('ERROR_NUMBER=' + CONVERT(VARCHAR(100), ERROR_NUMBER()) + ',ERROR_STATE='
          + CONVERT(VARCHAR(20), ERROR_STATE()) + ',ERROR_SEVERITY=' + CONVERT(VARCHAR(20), ERROR_SEVERITY())
         )  ,
         GETUTCDATE(),
         ISNULL(@AppUserId,0),
         @ReportedId+','+@AppUserId,
         GETUTCDATE(),
         ISNULL(@AppUserId,0)
        );
END CATCH
END

