-- =============================================
-- Author: Matthew Grinaker	
-- Create date:			2020/03/30
-- Description:		Find ContactMasterId using GroupID, Email, 
-- Call SP:			fn_IsContactMasterExistsByAppUserId 4557
-- =============================================
CREATE FUNCTION [dbo].[fn_IsContactMasterExistsByAppUserId]
(
   @AppUserID BIGINT
)
RETURNS BIGINT
AS
    BEGIN
    DECLARE @EmailID NVARCHAR(100), @MobileNo NVARCHAR(50);
	DECLARE @AppUserContactId BIGINT = 0;
	DECLARE @nGroupID BIGINT = 0;
					

				Select @EmailID = Email, @MobileNo = Mobile, @nGroupID = GroupId from AppUser where id = @AppUserID;

					IF @EmailId IS NULL SET @EmailId = ''
					IF @MobileNo IS NULL SET @MobileNo = ''

					IF (@EmailId IS NOT NULL)
					BEGIN
						SET @AppUserContactId = (SELECT top 1 CM.ID
						FROM dbo.ContactMaster AS CM 
						LEFT JOIN dbo.ContactDetails AS CD ON CD.ContactMasterId = CM.Id			
						WHERE CM.GroupId = @nGroupID 
						AND CM.IsDeleted = 0
						AND CD.QuestionTypeId IN (10, 11) 
						--AND (CD.Detail = @MobileNo OR CD.Detail = @EmailId)
						AND CD.Detail = @EmailId
						AND CD.Detail <> '')
					END

					RETURN ISNULL(@AppUserContactId,0);
END;
