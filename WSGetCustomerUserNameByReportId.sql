
-- =============================================
-- Author:		<Author,,GD>
-- Create date: <Create Date,,15 Jun 2015>
-- Description:	<Description,,>
-- Call SP:		WSGetCustomerUserNameByReportId 2868863
-- ============================================
CREATE PROCEDURE [dbo].[WSGetCustomerUserNameByReportId] 
    @ReportId BIGINT
AS 
    BEGIN
	SET DEADLOCK_PRIORITY NORMAL;
	
	BEGIN TRY
	DECLARE @EmailAddress NVARCHAR(100)= '',
	@ContactMasterID BIGINT = 0,
	@CustomerUserId BIGINT = 0;

	SELECT @ContactMasterID = (Select ContactMasterID from SeenClientAnswerMaster where iD  = @ReportId);
 

	If (@ContactMasterID > 0)
	BEGIN
	SET @EmailAddress = (Select ISNULL(Detail,'') from ContactDetails where ContactMasterId = @ContactMasterID and QuestionTypeId = 10 );
	IF (@EmailAddress != '')
	BEGIN
        SELECT @CustomerUserId = 
                Id
				FROM    dbo.AppUser
        WHERE   Email = @EmailAddress
		END

	END

	SELECT @CustomerUserId as CustomerUserId;
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
         'dbo.WSGetCustomerUserNameByReportId',
         N'DATABASE',
         ERROR_MESSAGE(),
         ('ERROR_NUMBER=' + CONVERT(VARCHAR(100), ERROR_NUMBER()) + ',ERROR_STATE='
          + CONVERT(VARCHAR(20), ERROR_STATE()) + ',ERROR_SEVERITY=' + CONVERT(VARCHAR(20), ERROR_SEVERITY())
         )  ,
         GETUTCDATE(),
         ISNULL(@ReportId,0),
         @ReportId,
         GETUTCDATE(),
         N''
        );
END CATCH
    END
