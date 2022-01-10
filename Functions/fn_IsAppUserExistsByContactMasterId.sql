-- =============================================
-- Author: Matthew Grinaker	
-- Create date:			2020/03/30
-- Description:		Find user name using ContactMasterId 
-- Call SP:			fn_IsAppUserExistsByContactMasterId 4557
-- =============================================
CREATE FUNCTION [dbo].[fn_IsAppUserExistsByContactMasterId]
(
   @ContactMasterId BIGINT
)
RETURNS NVARCHAR(100)
AS
    BEGIN
    DECLARE @EmailID NVARCHAR(100), @MobileNo NVARCHAR(50);
	DECLARE @AppUserName NVARCHAR(100);
					

				SET @EmailID = (Select Detail from ContactDetails where ContactMasterId = @ContactMasterId and QuestionTypeId = 10);
				SET @MobileNo =(Select Detail from ContactDetails where ContactMasterId = @ContactMasterId and QuestionTypeId = 11);

					IF @EmailId IS NULL SET @EmailId = ''
					IF @MobileNo IS NULL SET @MobileNo = ''

					SET @AppUserName = (SELECT "Name"
						FROM dbo.AppUser AS AU 
						WHERE AU.Email = @EmailID
						AND Au.IsDeleted = 0
						AND AU.IsActive = 1)

					RETURN ISNULL(@AppUserName,'');
END;
