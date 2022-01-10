-- =============================================
-- Author:			
-- Create date:	
-- Description:	For Check Duplicate Contact Entry With Role
-- Call SP:			dbo.IsContactMasterExists 373,0,'', '0824133878'
-- =============================================
CREATE PROCEDURE [dbo].[IsContactMasterExists]
(
    @GroupId BIGINT ,
    @ContactMasterId BIGINT ,
    @EmailId NVARCHAR(100) ,
    @MobileNo NVARCHAR(50)
)
AS
    BEGIN
              IF ( ( @EmailId <> '' AND @EmailId IS NOT NULL) OR ( @MobileNo <> '' AND @MobileNo IS NOT NULL))
            BEGIN
					IF @EmailId IS NULL SET    @EmailId = ''
					IF @MobileNo IS NULL SET @MobileNo = ''
					SELECT CM.Id AS ContactMasterId ,
					dbo.ConcateString('DuplicateContact', CM.Id) AS Detail ,
					CASE WHEN QuestionTypeId = 10 then ISNULL(Detail,'') ELSE '' END AS Email ,
                    CASE WHEN QuestionTypeId = 11 THEN ISNULL(Detail,'')ELSE '' END  AS Mobile ,
					ISNULL((SELECT STUFF((SELECT DISTINCT  ', ' + CR.RoleName FROM dbo.AppUserContactRole AS AUCR  INNER JOIN dbo.ContactRole AS CR ON CR.Id = AUCR.ContactRoleId WHERE AUCR.AppUserId = CM.CreatedBy AND CR.GroupId = @GroupId  FOR XML PATH('')) ,1,1,'')), '')  AS RoleName ,
					--ISNULL(AU.Name, 'Contact Created From Feedback.') AS UserName
					ISNULL(dbo.ConcateString('DuplicateContact ', CM.Id),ISNULL(AU.Name, 'Contact Created From Feedback.')) + '.' AS UserName
					FROM dbo.ContactMaster AS CM 
					INNER JOIN dbo.ContactDetails AS CD ON CD.ContactMasterId = CM.Id			
					LEFT JOIN dbo.AppUser AS AU ON (AU.Email = @EmailId OR AU.Mobile = @MobileNo) WHERE CM.GroupId = @GroupId 
					AND CM.Id <> @ContactMasterId 
					AND CM.IsDeleted = 0
					AND CD.QuestionTypeId IN (10, 11) 
					AND (CD.Detail = @MobileNo OR CD.Detail = @EmailId)
					AND CD.Detail <> ''
            END;
            END;
