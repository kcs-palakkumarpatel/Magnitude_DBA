
-- =============================================
-- Author:		<Author,,GD>
-- Create date: <Create Date,,15 Jun 2015>
-- Description:	<Description,,>
-- Call SP:		WSGetCustomerUserNameByReportId 2868863
-- ============================================
CREATE PROCEDURE [dbo].[WSGetCustomerUserNameByReportId_111921] 
    @ReportId BIGINT
AS 
    BEGIN
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
    END
