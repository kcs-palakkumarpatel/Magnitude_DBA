-- =============================================  
-- Author:  <Vasu Patel>  
-- Create date: <06 Apr 2017>  
-- Description: <Mobi link>  
-- Call select dbo.GetMObilink(35627,313,0)  
-- =============================================  
CREATE FUNCTION [dbo].[fn_GetMObilink]  
(  
 @ReportId BIGINT,  
 @AppUserId BIGINT,  
 @IsGroup BIT  
)  
RETURNS VARCHAR(1000)  
AS  
BEGIN  
  
 DECLARE @url VARCHAR(200)  
 DECLARE @Return VARCHAR(1000) = ''  
  
 SELECT  @url = KeyValue FROM  dbo.AAAAConfigSettings WITH (NOLOCK) WHERE KeyName = 'FeedbackUrl'  
   
IF (@IsGroup = 1)  
BEGIN  
 SELECT  @Return = CONVERT(VARCHAR(20), SA.Id) + ' | ' + @url  
 FROM    dbo.ContactDetails AS c WITH (NOLOCK) 
        INNER JOIN dbo.AppUser AS App WITH (NOLOCK) ON c.Detail = App.Email  
		AND c.QuestionTypeId = 10  
        AND App.Id = @AppUserId  
        INNER JOIN dbo.SeenClientAnswerMaster AS A WITH (NOLOCK) ON A.Id = @ReportId  
		AND	c.ContactMasterId IN ( SELECT   ContactMasterId  
                               FROM     dbo.ContactGroupRelation  WITH (NOLOCK) 
                               WHERE    ContactGroupId = A.ContactGroupId  
                                        AND IsDeleted = 0 )  
        INNER JOIN dbo.SeenClientAnswerChild AS SA WITH (NOLOCK) ON SA.ContactMasterId = c.ContactMasterId  
                                                      AND SA.SeenClientAnswerMasterId = A.Id  

  END  
  ELSE  
  BEGIN  
           SELECT  @Return = ( SELECT  CASE WHEN ( SELECT  
                                                              COUNT(1)  
                                                        FROM  dbo.ContactDetails  
                                                              AS C  WITH (NOLOCK)
                                                              INNER JOIN dbo.AppUser  
                                                              AS App WITH (NOLOCK) ON C.Detail = App.Email AND App.Id = @AppUserId 
                                                        WHERE C.ContactMasterId = A.ContactMasterId  
                                                              AND QuestionTypeId = 10  
                                                              
                                                      ) > 0  
                                                 THEN @url  
                                                 ELSE ''  
                                            END )  
            FROM    dbo.SeenClientAnswerMaster A WITH (NOLOCK) WHERE A.Id = @ReportId;  
  END  
          
 RETURN @Return  
  
END  
  