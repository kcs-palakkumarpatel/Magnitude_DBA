-- =============================================
-- Author: Matthew Grinaker	
-- Create date:			2020/03/30
-- Description:		Find ContactMasterId using GroupID, Email, 
-- Call SP:			dbo.IsContactMasterExists_Matt 201,'mkgrinaker@gmail.com','0836591690'
-- =============================================
CREATE PROCEDURE [dbo].[IsContactMasterExists_Matt]
(
    @GroupId BIGINT ,
    @EmailId NVARCHAR(100) ,
    @MobileNo NVARCHAR(50)
)
AS
    BEGIN
					IF @EmailId IS NULL SET @EmailId = ''
					IF @MobileNo IS NULL SET @MobileNo = ''
					
					DECLARE @AppUserContactId BIGINT;
					SET @AppUserContactId = 0;

					If(@MobileNo = '' AND @EmailId ='')
					BEGIN
					Select 0 As ContactMasterId
					END
					ELSE
					BEGIN
					SELECT @AppUserContactId = CM.ID
					FROM dbo.ContactMaster AS CM 
					LEFT JOIN dbo.ContactDetails AS CD ON CD.ContactMasterId = CM.Id			
					WHERE CM.GroupId = @GroupId 
					AND CM.IsDeleted = 0
					AND CD.QuestionTypeId IN (10, 11) 
					AND (CD.Detail = @MobileNo OR CD.Detail = @EmailId)
					AND CD.Detail <> ''
					END
					SELECT ISNULL(@AppUserContactId,0) as ContactMasterId
END;
