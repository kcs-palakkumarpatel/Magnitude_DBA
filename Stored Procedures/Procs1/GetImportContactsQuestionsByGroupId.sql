-- =============================================  
-- Author:			Sunil Vaghasiya
-- Create date:	11-Mar-2017
-- Description:	Get Contacts Questions Details For Mass Upload.
-- Call SP:			dbo.GetImportContactsQuestionsByGroupId 171
-- =============================================
CREATE PROCEDURE [dbo].[GetImportContactsQuestionsByGroupId] @GroupId BIGINT
AS
    BEGIN  
        DECLARE @ContactId BIGINT = 0;

        SELECT  @ContactId = ContactId
        FROM    dbo.[Group]
        WHERE   Id = @GroupId;

        SELECT  Id AS QuestionId ,
                QuestionTypeId ,
                QuestionTitle ,
                ShortName ,
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
        ORDER BY Position ASC;
  
    END;  
