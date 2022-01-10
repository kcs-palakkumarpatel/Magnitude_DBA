-- =============================================  
-- Author:			Sunil Vaghasiya
-- Create date:	22-Oct-2017
-- Description:	Get Contacts Questions Details For Mass Upload.
-- Call SP:			dbo.GetContactFormQuestionListByAppUserId
-- =============================================
CREATE PROCEDURE dbo.GetContactFormQuestionListByAppUserId
    (
      @AppUserId BIGINT ,
      @GroupId BIGINT ,
      @ActivityId BIGINT
    )
AS
    BEGIN  
        DECLARE @ContactId BIGINT = 0 ,
            @ContactQuestionIds VARCHAR(2000) = '';
        SELECT  @ContactId = ContactId
        FROM    dbo.[Group]
        WHERE   Id = @GroupId;
        SELECT  @ContactQuestionIds = ContactQuestion
        FROM    dbo.EstablishmentGroup
        WHERE   Id = @ActivityId;


        SELECT  ISNULL(ContactId, 0) AS ContactId ,
                QuestionTitle ,
                ISNULL(Id, 0) AS QuestionId ,
                ISNULL(QuestionTypeId, 0) AS QuestionTypeId ,
                [Required] ,
                IsDisplayInSummary ,
                IsDisplayInDetail ,
                [MaxLength] ,
                IsDecimal ,
                IsCommentCompulsory ,
                ContactId ,
                Position
        FROM    dbo.ContactQuestions
        WHERE   ContactId = @ContactId
                AND QuestionTypeId NOT IN ( 16, 17, 23, 25, 1 )
                AND IsDeleted = 0
                AND Id IN ( SELECT  Data
                            FROM    dbo.Split(@ContactQuestionIds, ',') )
        ORDER BY Position ASC;
    END;
