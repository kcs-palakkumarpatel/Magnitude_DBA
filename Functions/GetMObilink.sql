-- =============================================
-- Author:		<Vasu Patel>
-- Create date: <06 Apr 2017>
-- Description:	<Mobi link>
-- Call select dbo.GetMObilink(35627,313,0)
-- =============================================
CREATE FUNCTION dbo.GetMObilink
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

	SELECT  @url = KeyValue FROM  dbo.AAAAConfigSettings WHERE KeyName = 'FeedbackUrl'
	
IF (@IsGroup = 1)
BEGIN
 SELECT  @Return = CONVERT(VARCHAR(20), SA.Id) + ' | ' + @url
FROM    dbo.ContactDetails AS c
        INNER JOIN dbo.AppUser AS App ON c.Detail = App.Email
        INNER JOIN dbo.SeenClientAnswerMaster AS A ON A.Id = @ReportId
        INNER JOIN dbo.SeenClientAnswerChild AS SA ON SA.ContactMasterId = c.ContactMasterId
                                                      AND SA.SeenClientAnswerMasterId = A.Id
WHERE   c.ContactMasterId IN ( SELECT   ContactMasterId
                               FROM     dbo.ContactGroupRelation
                               WHERE    ContactGroupId = A.ContactGroupId
                                        AND IsDeleted = 0 )
        AND c.QuestionTypeId = 10
        AND App.Id = @AppUserId
		END
		ELSE
		BEGIN
           SELECT  @Return = ( SELECT  CASE WHEN ( SELECT
                                                              COUNT(1)
                                                        FROM  dbo.ContactDetails
                                                              AS C
                                                              INNER JOIN dbo.AppUser
                                                              AS App ON C.Detail = App.Email
                                                        WHERE C.ContactMasterId = A.ContactMasterId
                                                              AND QuestionTypeId = 10
                                                              AND App.Id = @AppUserId
                                                      ) > 0
                                                 THEN @url
                                                 ELSE ''
                                            END )
            FROM    dbo.SeenClientAnswerMaster A WHERE A.Id = @ReportId;
		END
        
	RETURN @Return

END

